<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class VisionItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'vision_board_id',
        'creator_id',
        'title',
        'content',
        'type',
        'is_completed',
        'assigned_to_user_id',
        'color_hex',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'is_completed' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function visionBoard(): BelongsTo
    {
        return $this->belongsTo(VisionBoard::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'creator_id');
    }

    public function assignedTo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to_user_id');
    }
}
