<?php

namespace App\Services;

use App\Models\CoupleRequest;
use App\Models\CoupleSpace;
use App\Models\CoupleStreak;
use App\Models\CoupleTeam;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CoupleManagerService
{
    /**
     * Search user by username or couple_id.
     */
    public function searchPartner(string $query, User $currentUser): ?User
    {
        return User::where('id', '!=', $currentUser->id)
            ->where(function ($q) use ($query) {
                $q->where('username', $query)
                  ->orWhere('couple_id', $query)
                  ->orWhere('email', $query);
            })
            ->select(['id', 'name', 'username', 'couple_id', 'avatar_url', 'relationship_status', 'public_key'])
            ->first();
    }

    /**
     * Send connection request to a partner.
     */
    public function sendRequest(User $sender, int $receiverId): CoupleRequest
    {
        if ($sender->relationship_status === 'connected') {
            throw new \Exception('You are already connected to a partner. You cannot send new requests.');
        }

        $receiver = User::findOrFail($receiverId);
        if ($receiver->relationship_status === 'connected') {
            throw new \Exception('The requested user is already connected in a private space.');
        }

        // Check for existing pending request
        $existing = CoupleRequest::where('sender_id', $sender->id)
            ->where('receiver_id', $receiverId)
            ->where('status', 'pending')
            ->first();

        if ($existing) {
            return $existing;
        }

        $request = CoupleRequest::create([
            'sender_id' => $sender->id,
            'receiver_id' => $receiverId,
            'status' => 'pending',
        ]);

        $sender->update(['relationship_status' => 'pending']);

        return $request;
    }

    /**
     * Accept a pending request and bootstrap the couple workspace.
     */
    public function acceptRequest(int $requestId, User $receiver): CoupleSpace
    {
        $request = CoupleRequest::where('id', $requestId)
            ->where('receiver_id', $receiver->id)
            ->where('status', 'pending')
            ->firstOrFail();

        $sender = User::findOrFail($request->sender_id);

        if ($sender->relationship_status === 'connected' || $receiver->relationship_status === 'connected') {
            throw new \Exception('One of the users is already in a connected couple space.');
        }

        return DB::transaction(function () use ($request, $sender, $receiver) {
            // Create Space
            $space = CoupleSpace::create([
                'uuid' => (string) Str::uuid(),
                'user_one_id' => $sender->id,
                'user_two_id' => $receiver->id,
                'connected_at' => now(),
                'anniversary_date' => now()->toDateString(),
                'space_name' => "{$sender->name} & {$receiver->name}'s Sanctuary",
                'theme_preset' => 'rose_gold',
                'status' => 'active',
            ]);

            // Update Users
            $sender->update([
                'relationship_status' => 'connected',
                'couple_space_id' => $space->id,
            ]);

            $receiver->update([
                'relationship_status' => 'connected',
                'couple_space_id' => $space->id,
            ]);

            // Update Request
            $request->update([
                'status' => 'accepted',
                'responded_at' => now(),
            ]);

            // Initialize Streak Tracker
            CoupleStreak::create([
                'couple_space_id' => $space->id,
                'current_streak_days' => 1,
                'longest_streak_days' => 1,
                'last_activity_date' => now()->toDateString(),
                'badges' => ['connected_first_day'],
            ]);

            // Initialize Team for Multiplayer Battles
            CoupleTeam::create([
                'couple_space_id' => $space->id,
                'team_name' => "Team {$sender->name} & {$receiver->name}",
                'elo_rating' => 1200,
                'rank_tier' => 'Bronze',
            ]);

            return $space;
        });
    }

    /**
     * Decline a pending connection request.
     */
    public function declineRequest(int $requestId, User $receiver): bool
    {
        $request = CoupleRequest::where('id', $requestId)
            ->where('receiver_id', $receiver->id)
            ->where('status', 'pending')
            ->firstOrFail();

        $request->update([
            'status' => 'declined',
            'responded_at' => now(),
        ]);

        $sender = User::find($request->sender_id);
        if ($sender && $sender->relationship_status === 'pending') {
            $sender->update(['relationship_status' => 'single']);
        }

        return true;
    }
}
