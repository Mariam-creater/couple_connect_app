<?php

namespace Tests\Feature;

use App\Models\CoupleRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CoupleConnectionTest extends TestCase
{
    use RefreshDatabase;

    public function test_couple_request_and_accept_lifecycle(): void
    {
        $userA = User::factory()->create([
            'name' => 'Romeo',
            'username' => 'romeo',
            'email' => 'romeo@verona.it',
            'couple_id' => 'CP-ROME-01',
            'relationship_status' => 'single',
        ]);

        $userB = User::factory()->create([
            'name' => 'Juliet',
            'username' => 'juliet',
            'email' => 'juliet@verona.it',
            'couple_id' => 'CP-JULI-02',
            'relationship_status' => 'single',
        ]);

        // User A searches for Juliet
        Sanctum::actingAs($userA);
        $searchRes = $this->getJson('/api/v1/couple/search?query=CP-JULI-02');
        $searchRes->assertStatus(200)
            ->assertJsonPath('data.username', 'juliet');

        // User A sends request
        $sendRes = $this->postJson('/api/v1/couple/request', [
            'receiver_id' => $userB->id,
        ]);
        $sendRes->assertStatus(201);
        $requestId = $sendRes->json('data.id');

        // User B accepts request
        Sanctum::actingAs($userB);
        $acceptRes = $this->postJson("/api/v1/couple/request/{$requestId}/accept");
        $acceptRes->assertStatus(200)
            ->assertJsonPath('status', 'success');

        // Verify both users are connected in the database
        $userA->refresh();
        $userB->refresh();

        $this->assertEquals('connected', $userA->relationship_status);
        $this->assertEquals('connected', $userB->relationship_status);
        $this->assertNotNull($userA->couple_space_id);
        $this->assertEquals($userA->couple_space_id, $userB->couple_space_id);
    }
}
