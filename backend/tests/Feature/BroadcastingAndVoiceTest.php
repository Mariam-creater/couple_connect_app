<?php

namespace Tests\Feature;

use App\Events\NewMessageEvent;
use App\Models\CoupleSpace;
use App\Models\Message;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class BroadcastingAndVoiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_upload_voice_note_and_receive_streamable_url(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $partner = User::factory()->create();
        $space = CoupleSpace::create([
            'user_one_id' => $user->id,
            'user_two_id' => $partner->id,
            'space_name' => 'Love Nest',
            'uuid' => 'cp-test-space-uuid-1234',
            'connected_at' => now(),
        ]);
        $user->update(['couple_space_id' => $space->id, 'relationship_status' => 'connected']);

        $voiceFile = UploadedFile::fake()->create('note.m4a', 250, 'audio/mp4');

        $response = $this->actingAs($user)->postJson('/api/v1/chat/voice', [
            'voice' => $voiceFile,
            'duration_seconds' => 12.5,
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'file_path',
                    'storage_path',
                    'disk',
                    'file_name',
                    'mime_type',
                    'file_size_bytes',
                    'duration_seconds',
                ]
            ]);

        $this->assertEquals(12.5, $response->json('data.duration_seconds'));
        Storage::disk('public')->assertExists($response->json('data.storage_path'));
    }

    public function test_sending_message_triggers_new_message_broadcast_event(): void
    {
        Event::fake([NewMessageEvent::class]);

        $user = User::factory()->create();
        $partner = User::factory()->create();
        $space = CoupleSpace::create([
            'user_one_id' => $user->id,
            'user_two_id' => $partner->id,
            'space_name' => 'Love Nest',
            'uuid' => 'cp-test-space-uuid-5678',
            'connected_at' => now(),
        ]);
        $user->update(['couple_space_id' => $space->id, 'relationship_status' => 'connected']);

        $response = $this->actingAs($user)->postJson('/api/v1/chat/messages', [
            'type' => 'voice',
            'encrypted_payload' => 'encrypted_voice_metadata_ciphertext',
            'iv' => 'dummy_iv_16_bytes',
            'metadata' => [
                'file_path' => 'https://media.coupleconnect.app/chat_voices/1/voice_1.m4a',
                'file_name' => 'voice_1.m4a',
                'mime_type' => 'audio/mp4',
                'duration_seconds' => 18.2,
            ]
        ]);

        $response->assertStatus(201);

        Event::assertDispatched(NewMessageEvent::class, function (NewMessageEvent $event) use ($space) {
            return (int) $event->message->couple_space_id === (int) $space->id
                && $event->broadcastAs() === 'message.new'
                && in_array('private-couple.' . $space->id, array_map(fn ($c) => $c->name, $event->broadcastOn()));
        });
    }

    public function test_broadcasting_auth_authorizes_couple_space_member(): void
    {
        $user = User::factory()->create();
        $partner = User::factory()->create();
        $space = CoupleSpace::create([
            'user_one_id' => $user->id,
            'user_two_id' => $partner->id,
            'space_name' => 'Love Space',
            'uuid' => 'cp-test-space-uuid-9999',
            'connected_at' => now(),
        ]);
        $user->update(['couple_space_id' => $space->id, 'relationship_status' => 'connected']);

        $response = $this->actingAs($user)->postJson('/api/v1/broadcasting/auth', [
            'channel_name' => 'private-couple.' . $space->id,
            'socket_id' => '123456.789012',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['auth']);
    }
}
