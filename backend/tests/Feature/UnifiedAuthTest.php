<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class UnifiedAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_register_with_native_credentials(): void
    {
        $res = $this->postJson('/api/v1/auth/register', [
            'name' => 'Layla Hassan',
            'username' => 'layla_h',
            'email' => 'layla@example.com',
            'password' => 'SecretPassword123!',
        ]);

        $res->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.username', 'layla_h')
            ->assertJsonPath('data.user.email', 'layla@example.com')
            ->assertJsonPath('data.user.has_password', true);

        $this->assertNotEmpty($res->json('data.token'));
        $this->assertDatabaseHas('users', [
            'email' => 'layla@example.com',
            'username' => 'layla_h',
        ]);
    }

    public function test_can_login_with_either_username_or_email(): void
    {
        $user = User::factory()->create([
            'name' => 'Kahlil Gibran',
            'username' => 'kahlil_g',
            'email' => 'kahlil@example.com',
            'password' => bcrypt('StrongPass2026!'),
            'couple_id' => 'CP-KAHL-99',
        ]);

        // 1. Login with Email
        $emailLoginRes = $this->postJson('/api/v1/auth/login', [
            'login' => 'kahlil@example.com',
            'password' => 'StrongPass2026!',
        ]);

        $emailLoginRes->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.id', $user->id);

        // 2. Login with Username
        $usernameLoginRes = $this->postJson('/api/v1/auth/login', [
            'login' => 'kahlil_g',
            'password' => 'StrongPass2026!',
        ]);

        $usernameLoginRes->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.id', $user->id);
    }

    public function test_google_sign_in_creates_new_user(): void
    {
        $res = $this->postJson('/api/v1/auth/google', [
            'google_id' => 'google_sub_1092837465',
            'email' => 'amina.google@example.com',
            'name' => 'Amina Noor',
            'avatar' => 'https://lh3.googleusercontent.com/a/sample_avatar.jpg',
        ]);

        $res->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.email', 'amina.google@example.com')
            ->assertJsonPath('data.user.is_google_linked', true)
            ->assertJsonPath('data.user.has_password', false);

        $this->assertNotEmpty($res->json('data.token'));
        $this->assertDatabaseHas('users', [
            'email' => 'amina.google@example.com',
            'google_id' => 'google_sub_1092837465',
        ]);
    }

    public function test_google_sign_in_automatically_links_to_existing_email_account(): void
    {
        // User first registers with email and password
        $existingUser = User::factory()->create([
            'name' => 'Rashid Ali',
            'username' => 'rashid_original',
            'email' => 'rashid@example.com',
            'password' => bcrypt('MyOldPassword123!'),
            'couple_id' => 'CP-RASH-77',
            'google_id' => null,
        ]);

        // User later taps "Sign in with Google" using the same email
        $googleRes = $this->postJson('/api/v1/auth/google', [
            'google_id' => 'google_sub_8877665544',
            'email' => 'rashid@example.com',
            'name' => 'Rashid Ali (Google)',
            'avatar' => 'https://lh3.googleusercontent.com/a/rashid.jpg',
        ]);

        $googleRes->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.id', $existingUser->id)
            ->assertJsonPath('data.user.username', 'rashid_original') // Preserves existing username!
            ->assertJsonPath('data.user.is_google_linked', true)
            ->assertJsonPath('data.user.has_password', true); // Preserves existing password!

        // Verify database has linked google_id to the exact same user ID
        $this->assertDatabaseHas('users', [
            'id' => $existingUser->id,
            'email' => 'rashid@example.com',
            'username' => 'rashid_original',
            'google_id' => 'google_sub_8877665544',
        ]);
    }

    public function test_google_user_can_set_username_and_password_and_login_interchangeably(): void
    {
        // 1. User signs up via Google
        $googleRes = $this->postJson('/api/v1/auth/google', [
            'google_id' => 'google_sub_5544332211',
            'email' => 'tariq@example.com',
            'name' => 'Tariq Mansoor',
        ]);

        $googleRes->assertStatus(200);
        $user = User::where('email', 'tariq@example.com')->first();
        $this->assertNull($user->password);

        // 2. User sets a custom username and password
        Sanctum::actingAs($user);

        $setRes = $this->postJson('/api/v1/auth/set-credentials', [
            'username' => 'tariq_custom',
            'password' => 'NewSecurePassword2026!',
            'password_confirmation' => 'NewSecurePassword2026!',
        ]);

        $setRes->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.username', 'tariq_custom')
            ->assertJsonPath('data.has_password', true);

        // 3. User can now log in via Password (interchangeable with Google!)
        $passLoginRes = $this->postJson('/api/v1/auth/login', [
            'login' => 'tariq_custom',
            'password' => 'NewSecurePassword2026!',
        ]);

        $passLoginRes->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.id', $user->id);

        // 4. User can also still log in via Google
        $googleLoginRes = $this->postJson('/api/v1/auth/google', [
            'google_id' => 'google_sub_5544332211',
            'email' => 'tariq@example.com',
        ]);

        $googleLoginRes->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.user.id', $user->id);
    }

    public function test_check_username_availability(): void
    {
        User::factory()->create([
            'username' => 'existing_user',
            'email' => 'existing@example.com',
            'couple_id' => 'CP-EXIS-01',
        ]);

        // Taken username
        $takenRes = $this->getJson('/api/v1/auth/check-username?username=existing_user');
        $takenRes->assertStatus(200)
            ->assertJsonPath('available', false);

        // Available username
        $availRes = $this->getJson('/api/v1/auth/check-username?username=totally_unique_name');
        $availRes->assertStatus(200)
            ->assertJsonPath('available', true);
    }
}
