<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MessageAttachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'message_id',
        'file_path',
        'file_name',
        'mime_type',
        'file_size_bytes',
        'encryption_hash',
    ];

    public function message(): BelongsTo
    {
        return $this->belongsTo(Message::class);
    }
}
