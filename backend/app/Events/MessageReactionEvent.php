<?php

namespace App\Events;

use App\Models\MessageReaction;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageReactionEvent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public int $coupleSpaceId,
        public int $messageId,
        public int $userId,
        public string $reaction,
        public bool $isRemoved = false
    ) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('couple.' . $this->coupleSpaceId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'message.reaction';
    }

    public function broadcastWith(): array
    {
        return [
            'message_id' => $this->messageId,
            'user_id' => $this->userId,
            'reaction' => $this->reaction,
            'is_removed' => $this->isRemoved,
        ];
    }
}
