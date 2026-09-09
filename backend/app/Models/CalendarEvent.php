<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CalendarEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'couple_space_id',
        'creator_id',
        'title',
        'description',
        'category',
        'color_hex',
        'start_time',
        'end_time',
        'is_all_day',
        'is_countdown',
        'recurrence',
        'reminder_minutes_before',
        'is_completed',
        'location',
    ];

    protected function casts(): array
    {
        return [
            'start_time' => 'datetime',
            'end_time' => 'datetime',
            'is_all_day' => 'boolean',
            'is_countdown' => 'boolean',
            'is_completed' => 'boolean',
        ];
    }

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'creator_id');
    }
}
