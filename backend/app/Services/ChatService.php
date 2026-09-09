<?php

namespace App\Services;

use App\Models\CoupleSpace;
use App\Models\Message;
use App\Models\MessageAttachment;
use App\Models\MessageReaction;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ChatService
{
    public function __construct(
        protected StreakService $streakService
    ) {}

    /**
     * Get paginated messages for a couple space.
     */
    public function getMessages(CoupleSpace $space, int $perPage = 30): LengthAwarePaginator
    {
        return Message::where('couple_space_id', $space->id)
            ->with(['sender:id,name,username,avatar_url', 'reactions.user:id,name,avatar_url', 'attachments', 'replyTo'])
            ->orderBy('id', 'desc')
            ->paginate($perPage);
    }

    /**
     * Store and broadcast a client-encrypted E2EE message.
     */
    public function sendMessage(User $sender, array $data): Message
    {
        if (!$sender->couple_space_id) {
            throw new \Exception('User does not have an active couple space.');
        }

        return DB::transaction(function () use ($sender, $data) {
            $message = Message::create([
                'message_uuid' => $data['message_uuid'] ?? (string) Str::uuid(),
                'couple_space_id' => $sender->couple_space_id,
                'sender_id' => $sender->id,
                'type' => $data['type'] ?? 'text',
                'encrypted_payload' => $data['encrypted_payload'],
                'iv' => $data['iv'],
                'mac' => $data['mac'] ?? null,
                'reply_to_message_id' => $data['reply_to_message_id'] ?? null,
                'metadata' => $data['metadata'] ?? null,
                'status' => 'sent',
            ]);

            // Save attachments if provided
            if (!empty($data['attachments']) && is_array($data['attachments'])) {
                foreach ($data['attachments'] as $att) {
                    MessageAttachment::create([
                        'message_id' => $message->id,
                        'file_path' => $att['file_path'],
                        'file_name' => $att['file_name'],
                        'mime_type' => $att['mime_type'],
                        'file_size_bytes' => $att['file_size_bytes'] ?? 0,
                        'encryption_hash' => $att['encryption_hash'] ?? null,
                    ]);
                }
            }

            // Log activity for streak
            $this->streakService->recordActivity($sender, 'daily_chat');

            $loadedMessage = $message->load(['sender', 'reactions', 'attachments', 'replyTo']);

            // Broadcast real-time event
            try {
                \App\Events\NewMessageEvent::dispatch($loadedMessage);
            } catch (\Throwable $e) {
                \Illuminate\Support\Facades\Log::warning('Broadcast failed: ' . $e->getMessage());
            }

            return $loadedMessage;
        });
    }

    /**
     * React to a message.
     */
    public function toggleReaction(Message $message, User $user, string $reaction): MessageReaction
    {
        $existing = MessageReaction::where('message_id', $message->id)
            ->where('user_id', $user->id)
            ->first();

        if ($existing) {
            if ($existing->reaction === $reaction) {
                $existing->delete();
                try {
                    \App\Events\MessageReactionEvent::dispatch($message->couple_space_id, $message->id, $user->id, $reaction, true);
                } catch (\Throwable $e) {}
                return $existing;
            }
            $existing->update(['reaction' => $reaction]);
            try {
                \App\Events\MessageReactionEvent::dispatch($message->couple_space_id, $message->id, $user->id, $reaction, false);
            } catch (\Throwable $e) {}
            return $existing;
        }

        $created = MessageReaction::create([
            'message_id' => $message->id,
            'user_id' => $user->id,
            'reaction' => $reaction,
        ]);

        try {
            \App\Events\MessageReactionEvent::dispatch($message->couple_space_id, $message->id, $user->id, $reaction, false);
        } catch (\Throwable $e) {}

        return $created;
    }

    /**
     * Mark messages as read.
     */
    public function markAsRead(CoupleSpace $space, User $reader): int
    {
        $now = now();
        $updatedCount = Message::where('couple_space_id', $space->id)
            ->where('sender_id', '!=', $reader->id)
            ->whereNull('read_at')
            ->update([
                'status' => 'read',
                'read_at' => $now,
            ]);

        if ($updatedCount > 0) {
            try {
                \App\Events\MessageReadEvent::dispatch($space->id, $reader->id, $now->toISOString());
            } catch (\Throwable $e) {}
        }

        return $updatedCount;
    }

    /**
     * Toggle pin message.
     */
    public function togglePin(Message $message): bool
    {
        $message->is_pinned = !$message->is_pinned;
        $message->save();
        return $message->is_pinned;
    }
}
