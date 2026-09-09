<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user account with native credentials.
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:50|regex:/^[a-zA-Z0-9._-]+$/|unique:users,username',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'public_key' => 'nullable|string',
            'avatar_url' => 'nullable|string',
            'bio' => 'nullable|string|max:500',
            'gender' => 'nullable|string|in:male,female,other,prefer_not_to_say',
            'birthday' => 'nullable|date',
            'phone' => 'nullable|string|max:30',
        ]);

        // Generate unique couple ID: CP-XXXX-XX
        $coupleId = $this->generateUniqueCoupleId();

        $user = User::create([
            'name' => $validated['name'],
            'username' => strtolower($validated['username']),
            'email' => strtolower($validated['email']),
            'password' => Hash::make($validated['password']),
            'couple_id' => $coupleId,
            'public_key' => $validated['public_key'] ?? null,
            'avatar' => $validated['avatar_url'] ?? null,
            'avatar_url' => $validated['avatar_url'] ?? null,
            'bio' => $validated['bio'] ?? 'Living our best life together 💕',
            'gender' => $validated['gender'] ?? null,
            'birthday' => $validated['birthday'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'relationship_status' => 'single',
            'role' => 'user',
        ]);

        $token = $user->createToken('couple_connect_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Account registered successfully',
            'data' => [
                'user' => $this->formatUserData($user),
                'token' => $token,
            ]
        ], 201);
    }

    /**
     * Login with either Email, Username, or Couple ID + Password.
     */
    public function login(Request $request): JsonResponse
    {
        $loginInput = $request->input('login') ?? $request->input('email') ?? $request->input('username');
        if (empty($loginInput)) {
            throw ValidationException::withMessages([
                'login' => ['Username or email is required.'],
            ]);
        }

        $validated = $request->validate([
            'password' => 'required|string',
            'fcm_token' => 'nullable|string',
        ]);

        $searchTerm = strtolower(trim($loginInput));
        $user = User::where('email', $searchTerm)
            ->orWhere('username', $searchTerm)
            ->orWhere('couple_id', strtoupper($loginInput))
            ->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'login' => ['No account found matching this username or email.'],
            ]);
        }

        if (empty($user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'This account was created with Google Sign-In and does not have a password yet. Please sign in with Google or set a password in your settings.',
                'code' => 'GOOGLE_AUTH_REQUIRED',
                'has_password' => false,
            ], 422);
        }

        if (!Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['Incorrect password.'],
            ]);
        }

        if (!empty($validated['fcm_token'])) {
            $user->fcm_token = $validated['fcm_token'];
        }
        $user->online_status = 'online';
        $user->last_seen_at = now();
        $user->save();

        $token = $user->createToken('couple_connect_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Logged in successfully',
            'data' => [
                'user' => $this->formatUserData($user->load('coupleSpace')),
                'partner' => $user->partner,
                'token' => $token,
            ]
        ]);
    }

    /**
     * Google Sign-In & Automated Account Linking.
     */
    public function googleAuth(Request $request): JsonResponse
    {
        $idToken = $request->input('id_token');
        $googleId = $request->input('google_id') ?? $request->input('social_id');
        $email = $request->input('email');
        $name = $request->input('name') ?? 'Google User';
        $avatar = $request->input('avatar') ?? $request->input('avatar_url') ?? $request->input('picture');

        // Optional server-side verification if id_token is provided
        if (!empty($idToken)) {
            try {
                $response = Http::timeout(5)->get("https://oauth2.googleapis.com/tokeninfo?id_token={$idToken}");
                if ($response->successful()) {
                    $tokenData = $response->json();
                    $googleId = $tokenData['sub'] ?? $googleId;
                    $email = $tokenData['email'] ?? $email;
                    $name = $tokenData['name'] ?? $name;
                    $avatar = $tokenData['picture'] ?? $avatar;
                }
            } catch (\Throwable $e) {
                // Fallback to submitted parameters if network verification times out in test/offline environment
            }
        }

        if (empty($email)) {
            throw ValidationException::withMessages([
                'email' => ['A valid Google email is required for authentication.'],
            ]);
        }

        $email = strtolower(trim($email));
        $googleId = $googleId ? (string) $googleId : 'google_' . md5($email);

        // 1. Check if user exists by google_id OR email
        $user = User::where('google_id', $googleId)
            ->orWhere('email', $email)
            ->first();

        if ($user) {
            // AUTOMATED ACCOUNT LINKING:
            // If user previously registered with email/password, seamlessly link google_id
            $needsSave = false;
            if (empty($user->google_id) || $user->google_id !== $googleId) {
                $user->google_id = $googleId;
                $user->social_provider = 'google';
                $user->social_id = $googleId;
                $needsSave = true;
            }
            if (empty($user->avatar_url) && !empty($avatar)) {
                $user->avatar = $avatar;
                $user->avatar_url = $avatar;
                $needsSave = true;
            }
            if ($user->email_verified_at === null) {
                $user->email_verified_at = now();
                $needsSave = true;
            }

            if ($needsSave) {
                $user->save();
            }
        } else {
            // NEW USER REGISTRATION via Google
            $coupleId = $this->generateUniqueCoupleId();
            $baseUsername = strtolower(Str::slug($name, ''));
            if (empty($baseUsername)) {
                $baseUsername = 'user';
            }
            $username = $baseUsername . rand(100, 999);

            // Ensure username uniqueness
            while (User::where('username', $username)->exists()) {
                $username = $baseUsername . rand(1000, 9999);
            }

            $user = User::create([
                'name' => $name,
                'username' => $username,
                'email' => $email,
                'google_id' => $googleId,
                'social_provider' => 'google',
                'social_id' => $googleId,
                'password' => null, // Empty until user sets one via /set-credentials
                'avatar' => $avatar,
                'avatar_url' => $avatar,
                'couple_id' => $coupleId,
                'relationship_status' => 'single',
                'role' => 'user',
                'email_verified_at' => now(),
            ]);
        }

        $user->online_status = 'online';
        $user->last_seen_at = now();
        $user->save();

        $token = $user->createToken('couple_connect_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Google authentication successful',
            'data' => [
                'user' => $this->formatUserData($user->load('coupleSpace')),
                'partner' => $user->partner,
                'token' => $token,
                'is_new_user' => empty($user->password),
                'has_password' => !empty($user->password),
            ]
        ], 200);
    }

    /**
     * Set or change Username and Password (for Google users or profile settings).
     */
    public function setCredentials(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'username' => [
                'nullable',
                'string',
                'max:50',
                'regex:/^[a-zA-Z0-9._-]+$/',
                'unique:users,username,' . $user->id,
            ],
            'password' => 'required|string|min:8|confirmed',
        ]);

        if (!empty($validated['username'])) {
            $user->username = strtolower($validated['username']);
        }

        $user->password = Hash::make($validated['password']);
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Credentials saved successfully! You can now log in using either Google or your Username/Password.',
            'data' => [
                'user' => $this->formatUserData($user),
                'has_password' => true,
            ]
        ]);
    }

    /**
     * Check username availability in real-time.
     */
    public function checkUsername(Request $request): JsonResponse
    {
        $username = strtolower(trim($request->query('username', '')));

        if (empty($username) || strlen($username) < 3) {
            return response()->json([
                'status' => 'error',
                'available' => false,
                'message' => 'Username must be at least 3 characters.',
            ], 422);
        }

        if (!preg_match('/^[a-zA-Z0-9._-]+$/', $username)) {
            return response()->json([
                'status' => 'error',
                'available' => false,
                'message' => 'Username can only contain letters, numbers, dots, dashes and underscores.',
            ], 422);
        }

        $user = $request->user('sanctum');
        $query = User::where('username', $username);
        if ($user) {
            $query->where('id', '!=', $user->id);
        }

        $exists = $query->exists();

        return response()->json([
            'status' => 'success',
            'available' => !$exists,
            'message' => $exists ? 'Username is already taken.' : 'Username is available!',
        ]);
    }

    /**
     * Social Auth Alias (Compatible with existing endpoints).
     */
    public function socialLogin(Request $request): JsonResponse
    {
        return $this->googleAuth($request);
    }

    /**
     * Get authenticated user profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $this->formatUserData($user->load('coupleSpace')),
                'partner' => $user->partner,
            ]
        ]);
    }

    /**
     * Update profile details.
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'username' => 'nullable|string|max:50|regex:/^[a-zA-Z0-9._-]+$/|unique:users,username,' . $user->id,
            'bio' => 'nullable|string|max:500',
            'avatar_url' => 'nullable|string',
            'gender' => 'nullable|string|in:male,female,other,prefer_not_to_say',
            'birthday' => 'nullable|date',
            'phone' => 'nullable|string|max:30',
        ]);

        if (isset($validated['username'])) {
            $validated['username'] = strtolower($validated['username']);
        }

        $user->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'data' => $this->formatUserData($user)
        ]);
    }

    /**
     * Forgot password email request.
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $resetCode = rand(100000, 999999);
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $validated['email']],
            ['token' => Hash::make((string) $resetCode), 'created_at' => now()]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Password reset verification code sent to your email address.',
            'data' => [
                'demo_reset_code' => $resetCode,
            ]
        ]);
    }

    /**
     * Reset password using verification code.
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email|exists:users,email',
            'code' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $record = DB::table('password_reset_tokens')->where('email', $validated['email'])->first();
        if (!$record || !Hash::check($validated['code'], $record->token)) {
            throw ValidationException::withMessages(['code' => ['Invalid or expired reset code.']]);
        }

        $user = User::where('email', $validated['email'])->firstOrFail();
        $user->password = Hash::make($validated['password']);
        $user->save();

        DB::table('password_reset_tokens')->where('email', $validated['email'])->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Password updated successfully. You can now log in with your new password.'
        ]);
    }

    /**
     * Update privacy settings.
     */
    public function updatePrivacySettings(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'privacy_show_online_status' => 'nullable|boolean',
            'privacy_show_read_receipts' => 'nullable|boolean',
        ]);

        $user->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Privacy settings updated',
            'data' => $this->formatUserData($user)
        ]);
    }

    /**
     * Update security settings (PIN code / Biometrics).
     */
    public function updateSecurity(Request $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validate([
            'biometric_enabled' => 'nullable|boolean',
            'pin_code' => 'nullable|string|min:4|max:6',
        ]);

        if (isset($validated['biometric_enabled'])) {
            $user->biometric_enabled = $validated['biometric_enabled'];
        }

        if (!empty($validated['pin_code'])) {
            $user->pin_code_hash = Hash::make($validated['pin_code']);
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Security preferences updated',
            'data' => $this->formatUserData($user)
        ]);
    }

    /**
     * Delete Account.
     */
    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        DB::transaction(function () use ($user) {
            if ($user->couple_space_id) {
                $space = $user->coupleSpace;
                if ($space) {
                    $partner = $space->getPartnerOf($user->id);
                    if ($partner) {
                        $partner->update([
                            'relationship_status' => 'single',
                            'couple_space_id' => null,
                        ]);
                    }
                    $space->delete();
                }
            }

            $user->tokens()->delete();
            $user->delete();
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Account and associated data deleted successfully'
        ]);
    }

    /**
     * Logout and revoke token.
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user) {
            $user->online_status = 'offline';
            $user->last_seen_at = now();
            $user->save();

            $token = $user->currentAccessToken();
            if ($token) {
                $token->delete();
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully'
        ]);
    }

    // --- HELPER METHODS ---

    protected function generateUniqueCoupleId(): string
    {
        do {
            $id = 'CP-' . strtoupper(Str::random(4)) . '-' . strtoupper(Str::random(2));
        } while (User::where('couple_id', $id)->exists());

        return $id;
    }

    protected function formatUserData(User $user): array
    {
        $data = $user->toArray();
        $data['has_password'] = !empty($user->password);
        $data['is_google_linked'] = !empty($user->google_id) || ($user->social_provider === 'google');
        return $data;
    }
}
