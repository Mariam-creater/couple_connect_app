<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class GameSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'session_code',
        'couple_space_id',
        'game_type',
        'mode',
        'initiator_id',
        'opponent_id',
        'opponent_couple_space_id',
        'game_state',
        'current_turn_user_id',
        'winner_user_id',
        'status',
        'score_initiator',
        'score_opponent',
    ];

    protected function casts(): array
    {
        return [
            'game_state' => 'array',
        ];
    }

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->session_code)) {
                $model->session_code = (string) Str::uuid();
            }
        });
    }

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }

    public function initiator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'initiator_id');
    }

    public function opponent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'opponent_id');
    }

    public function currentTurnUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'current_turn_user_id');
    }

    public function winnerUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'winner_user_id');
    }

    public function moves(): HasMany
    {
        return $this->hasMany(GameMove::class);
    }
}
