<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiAnalysisReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'couple_space_id',
        'type',
        'input_content',
        'analysis_result',
        'metrics',
    ];

    protected function casts(): array
    {
        return [
            'metrics' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }
}
