<?php

namespace Tests\Feature;

use App\Models\CoupleSpace;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ChatTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_send_encrypted_message_and_react(): void
    {
        $userA = User::factory()->create([
            'name' => 'Alice',
            'username' => 'alice',
            'email' => 'alice@test.com',
            'couple_id' => 'CP-ALIC-01',
            'relationship_status' => 'connected',
        ]);

        $userB = User::factory()->create([
            'name' => 'Bob',
            'username' => 'bob',
            'email' => 'bob@test.com',
            'couple_id' => 'CP-BOBB-02',
            'relationship_status' => 'connected',
        ]);

        $space = CoupleSpace::create([
            'user_one_id' => $userA->id,
            'user_two_id' => $userB->id,
            'connected_at' => now(),
        ]);

        $userA->update(['couple_space_id' => $space->id]);
        $userB->update(['couple_space_id' => $space->id]);

        Sanctum::actingAs($userA);

        $sendRes = $this->postJson('/api/v1/chat/messages', [
            'type' => 'text',
            'encrypted_payload' => base64_encode('Hey sweetheart! ❤️'),
            'iv' => 'abcd1234efgh5678',
            'mac' => 'tag123456',
        ]);

        $sendRes->assertStatus(201)
            ->assertJsonPath('status', 'success');

        $messageId = $sendRes->json('data.id');

        // Bob reacts with heart
        Sanctum::actingAs($userB);
        $reactRes = $this->postJson("/api/v1/chat/messages/{$messageId}/react", [
            'reaction' => '❤️',
        ]);

        $reactRes->assertStatus(200);
        $this->assertDatabaseHas('message_reactions', [
            'message_id' => $messageId,
            'user_id' => $userB->id,
            'reaction' => '❤️',
        ]);
    }
}
