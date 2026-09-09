<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Str;

class CoupleSpace extends Model
{
    use HasFactory;

    protected $fillable = [
        'uuid',
        'user_one_id',
        'user_two_id',
        'connected_at',
        'anniversary_date',
        'space_name',
        'theme_preset',
        'chat_wallpaper',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'connected_at' => 'datetime',
            'anniversary_date' => 'date',
        ];
    }

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->uuid)) {
                $model->uuid = (string) Str::uuid();
            }
        });
    }

    public function userOne(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_one_id');
    }

    public function userTwo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_two_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class);
    }

    public function calendarEvents(): HasMany
    {
        return $this->hasMany(CalendarEvent::class);
    }

    public function memories(): HasMany
    {
        return $this->hasMany(Memory::class);
    }

    public function gameSessions(): HasMany
    {
        return $this->hasMany(GameSession::class);
    }

    public function visionBoards(): HasMany
    {
        return $this->hasMany(VisionBoard::class);
    }

    public function streak(): HasOne
    {
        return $this->hasOne(CoupleStreak::class);
    }

    public function team(): HasOne
    {
        return $this->hasOne(CoupleTeam::class);
    }

    public function getPartnerOf(int $userId): ?User
    {
        if ($this->user_one_id === $userId) {
            return $this->userTwo;
        }
        if ($this->user_two_id === $userId) {
            return $this->userOne;
        }
        return null;
    }

    public function hasUser(int $userId): bool
    {
        return $this->user_one_id === $userId || $this->user_two_id === $userId;
    }
}
