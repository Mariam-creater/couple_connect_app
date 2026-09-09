<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Message extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'message_uuid',
        'couple_space_id',
        'sender_id',
        'type',
        'encrypted_payload',
        'iv',
        'mac',
        'reply_to_message_id',
        'is_pinned',
        'is_edited',
        'edited_at',
        'status',
        'delivered_at',
        'read_at',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'is_pinned' => 'boolean',
            'is_edited' => 'boolean',
            'edited_at' => 'datetime',
            'delivered_at' => 'datetime',
            'read_at' => 'datetime',
            'metadata' => 'array',
        ];
    }

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->message_uuid)) {
                $model->message_uuid = (string) Str::uuid();
            }
        });
    }

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function replyTo(): BelongsTo
    {
        return $this->belongsTo(Message::class, 'reply_to_message_id');
    }

    public function reactions(): HasMany
    {
        return $this->hasMany(MessageReaction::class);
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(MessageAttachment::class);
    }
}
