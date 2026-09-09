<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CoupleStreak extends Model
{
    use HasFactory;

    protected $fillable = [
        'couple_space_id',
        'current_streak_days',
        'longest_streak_days',
        'last_activity_date',
        'badges',
        'total_messages_count',
        'total_games_played',
        'total_memories_added',
        'total_goals_completed',
    ];

    protected function casts(): array
    {
        return [
            'last_activity_date' => 'date',
            'badges' => 'array',
            'current_streak_days' => 'integer',
            'longest_streak_days' => 'integer',
            'total_messages_count' => 'integer',
            'total_games_played' => 'integer',
            'total_memories_added' => 'integer',
            'total_goals_completed' => 'integer',
        ];
    }

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }
}
