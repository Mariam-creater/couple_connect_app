<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
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
     * Login with email or username.
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
