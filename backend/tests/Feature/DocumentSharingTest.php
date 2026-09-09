<?php

namespace Tests\Feature;

use App\Models\CoupleSpace;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DocumentSharingTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_upload_and_download_real_document(): void
    {
        Storage::fake('public');

        $userA = User::factory()->create([
            'name' => 'Saam Ayanle',
            'username' => 'saam',
            'email' => 'saam@example.com',
            'couple_id' => 'CP-SAAM-01',
            'relationship_status' => 'connected',
        ]);

        $userB = User::factory()->create([
            'name' => 'Boqran Yasin',
            'username' => 'boqran',
            'email' => 'boqran@example.com',
            'couple_id' => 'CP-BOQR-02',
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

        $fakePdfContent = "%PDF-1.4 ... Test Real PDF Content for Couple Connect ... %%EOF";
        $file = UploadedFile::fake()->createWithContent('Vacation_Itinerary_Paris_2026.pdf', $fakePdfContent);

        $response = $this->postJson('/api/v1/chat/documents', [
            'document' => $file,
            'caption' => 'Our flight and hotel itinerary for Paris trip! ✈️🗼',
            'iv' => 'sample_iv_12345678',
            'mac' => 'sample_mac_tag_123',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.type', 'document')
            ->assertJsonPath('data.original_name', 'Vacation_Itinerary_Paris_2026.pdf')
            ->assertJsonPath('data.metadata.file_name', 'Vacation_Itinerary_Paris_2026.pdf');

        $messageId = $response->json('data.id');
        $storagePath = $response->json('data.metadata.storage_path');

        $this->assertNotNull($storagePath);
        Storage::disk('public')->assertExists($storagePath);

        // Partner (Bob) can download the document
        Sanctum::actingAs($userB);

        $downloadRes = $this->get("/api/v1/chat/documents/{$messageId}/download");
        $downloadRes->assertStatus(200)
            ->assertHeader('Content-Disposition', 'attachment; filename=Vacation_Itinerary_Paris_2026.pdf');
    }

    public function test_rejects_document_exceeding_max_file_size_or_invalid_type(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'name' => 'User One',
            'username' => 'userone',
            'email' => 'user1@test.com',
            'couple_id' => 'CP-USER-01',
            'relationship_status' => 'connected',
        ]);

        $partner = User::factory()->create([
            'name' => 'User Two',
            'username' => 'usertwo',
            'email' => 'user2@test.com',
            'couple_id' => 'CP-USER-02',
            'relationship_status' => 'connected',
        ]);

        $space = CoupleSpace::create([
            'user_one_id' => $user->id,
            'user_two_id' => $partner->id,
            'connected_at' => now(),
        ]);

        $user->update(['couple_space_id' => $space->id]);

        Sanctum::actingAs($user);

        // Attempting to upload invalid extension executable (.exe)
        $invalidFile = UploadedFile::fake()->create('malicious.exe', 100);

        $res = $this->postJson('/api/v1/chat/documents', [
            'document' => $invalidFile,
        ]);

        $res->assertStatus(422)
            ->assertJsonValidationErrors(['document']);
    }
}
