<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_and_receives_couple_id_and_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Emma Watson',
            'username' => 'emma_w',
            'email' => 'emma@example.com',
            'password' => 'SecurePassword123!',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'status',
                'data' => [
                    'user' => ['id', 'name', 'username', 'email', 'couple_id', 'relationship_status'],
                    'token',
                ]
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'emma@example.com',
            'username' => 'emma_w',
            'relationship_status' => 'single',
        ]);
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'username' => 'lucas_d',
            'email' => 'lucas@example.com',
            'password' => bcrypt('SecretPass123!'),
            'couple_id' => 'CP-LUCA-01',
            'relationship_status' => 'single',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => 'lucas@example.com',
            'password' => 'SecretPass123!',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonStructure(['data' => ['user', 'token']]);
    }
}
