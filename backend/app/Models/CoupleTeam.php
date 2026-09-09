<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CoupleTeam extends Model
{
    use HasFactory;

    protected $fillable = [
        'couple_space_id',
        'team_name',
        'elo_rating',
        'wins',
        'losses',
        'draws',
        'rank_tier',
    ];

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }
}
