<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user account.
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:50|unique:users,username',
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
        $coupleId = 'CP-' . strtoupper(Str::random(4)) . '-' . strtoupper(Str::random(2));

        $user = User::create([
            'name' => $validated['name'],
            'username' => strtolower($validated['username']),
            'email' => strtolower($validated['email']),
            'password' => Hash::make($validated['password']),
            'couple_id' => $coupleId,
            'public_key' => $validated['public_key'] ?? null,
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
                'user' => $user,
                'token' => $token,
            ]
        ], 201);
    }

    /**
     * Login with email, username or Couple ID.
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'login' => 'required|string',
            'password' => 'required|string',
            'fcm_token' => 'nullable|string',
        ]);

        $user = User::where('email', strtolower($validated['login']))
            ->orWhere('username', strtolower($validated['login']))
            ->orWhere('couple_id', strtoupper($validated['login']))
            ->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'login' => ['Invalid login credentials.'],
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
                'user' => $user->load('coupleSpace'),
                'partner' => $user->partner,
                'token' => $token,
            ]
        ]);
    }

    /**
     * Social Auth (Google / Apple Login).
     */
    public function socialLogin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'provider' => 'required|in:google,apple',
            'social_id' => 'required|string',
            'email' => 'required|email',
            'name' => 'required|string',
            'avatar_url' => 'nullable|string',
        ]);

        $user = User::where('email', strtolower($validated['email']))
            ->orWhere('social_id', $validated['social_id'])
            ->first();

        if (!$user) {
            $coupleId = 'CP-' . strtoupper(Str::random(4)) . '-' . strtoupper(Str::random(2));
            $username = strtolower(Str::slug($validated['name'])) . rand(100, 999);

            $user = User::create([
                'name' => $validated['name'],
                'username' => $username,
                'email' => strtolower($validated['email']),
                'password' => Hash::make(Str::random(24)),
                'avatar_url' => $validated['avatar_url'] ?? null,
                'couple_id' => $coupleId,
                'social_provider' => $validated['provider'],
                'social_id' => $validated['social_id'],
                'relationship_status' => 'single',
            ]);
        }

        $token = $user->createToken('couple_connect_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Social login successful',
            'data' => [
                'user' => $user->load('coupleSpace'),
                'partner' => $user->partner,
                'token' => $token,
            ]
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

        // Generate demo 6-digit verification code or token
        $resetCode = rand(100000, 999999);
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $validated['email']],
            ['token' => Hash::make((string) $resetCode), 'created_at' => now()]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Password reset verification code sent to your email address.',
            'data' => [
                'demo_reset_code' => $resetCode, // provided for easy sandbox testing
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
            'message' => 'Password reset successfully. You may now login.'
        ]);
    }

    /**
     * Get authenticated user profile & couple state.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['coupleSpace.streak', 'coupleSpace.team']);

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $user,
                'partner' => $user->partner,
            ]
        ]);
    }

    /**
     * Update user profile (Name, bio, birthday, gender, avatar, phone).
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'avatar_url' => 'nullable|string',
            'bio' => 'nullable|string|max:500',
            'gender' => 'nullable|string|in:male,female,other,prefer_not_to_say',
            'birthday' => 'nullable|date',
            'phone' => 'nullable|string|max:30',
        ]);

        $user->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'data' => $user
        ]);
    }

    /**
     * Update privacy settings (Online status, Read receipts).
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
            'data' => $user
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
            'data' => $user
        ]);
    }

    /**
     * Delete Account (GDPR Right to Be Forgotten).
     */
    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        DB::transaction(function () use ($user) {
            // If connected in a space, unbind partner
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
        $user->online_status = 'offline';
        $user->last_seen_at = now();
        $user->save();

        $user->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully'
        ]);
    }
}
