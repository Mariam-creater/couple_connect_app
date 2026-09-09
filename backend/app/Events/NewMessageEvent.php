<?php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewMessageEvent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Message $message
    ) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('couple.' . $this->message->couple_space_id),
        ];
    }

    public function broadcastAs(): string
    {
        return 'message.new';
    }

    public function broadcastWith(): array
    {
        return [
            'id' => $this->message->id,
            'message_uuid' => $this->message->message_uuid,
            'couple_space_id' => $this->message->couple_space_id,
            'sender_id' => $this->message->sender_id,
            'type' => $this->message->type,
            'encrypted_payload' => $this->message->encrypted_payload,
            'iv' => $this->message->iv,
            'mac' => $this->message->mac,
            'reply_to_message_id' => $this->message->reply_to_message_id,
            'status' => $this->message->status,
            'is_pinned' => (bool) $this->message->is_pinned,
            'is_edited' => (bool) $this->message->is_edited,
            'metadata' => $this->message->metadata,
            'created_at' => $this->message->created_at?->toISOString() ?? now()->toISOString(),
            'sender' => [
                'id' => $this->message->sender?->id,
                'name' => $this->message->sender?->name,
                'username' => $this->message->sender?->username,
                'avatar_url' => $this->message->sender?->avatar_url,
            ],
            'attachments' => $this->message->attachments ? $this->message->attachments->map(fn ($att) => [
                'id' => $att->id,
                'file_path' => $att->file_path,
                'file_name' => $att->file_name,
                'mime_type' => $att->mime_type,
                'file_size_bytes' => $att->file_size_bytes,
                'encryption_hash' => $att->encryption_hash,
            ])->toArray() : [],
            'reactions' => $this->message->reactions ? $this->message->reactions->map(fn ($r) => [
                'id' => $r->id,
                'user_id' => $r->user_id,
                'reaction' => $r->reaction,
            ])->toArray() : [],
        ];
    }
}
