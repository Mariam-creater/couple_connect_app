<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'google_id',
        'avatar',
        'avatar_url',
        'bio',
        'gender',
        'birthday',
        'phone',
        'couple_id',
        'relationship_status',
        'couple_space_id',
        'role',
        'public_key',
        'biometric_enabled',
        'pin_code_hash',
        'online_status',
        'privacy_show_online_status',
        'privacy_show_read_receipts',
        'social_provider',
        'social_id',
        'last_seen_at',
        'fcm_token',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'pin_code_hash',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'birthday' => 'date',
            'biometric_enabled' => 'boolean',
            'privacy_show_online_status' => 'boolean',
            'privacy_show_read_receipts' => 'boolean',
            'last_seen_at' => 'datetime',
        ];
    }

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }

    public function coupleRequestsSent(): HasMany
    {
        return $this->hasMany(CoupleRequest::class, 'sender_id');
    }

    public function coupleRequestsReceived(): HasMany
    {
        return $this->hasMany(CoupleRequest::class, 'receiver_id');
    }

    public function getPartnerAttribute(): ?User
    {
        if (!$this->coupleSpace) {
            return null;
        }
        return $this->coupleSpace->getPartnerOf($this->id);
    }

    public function isConnected(): bool
    {
        return $this->relationship_status === 'connected' && $this->couple_space_id !== null;
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function hasPassword(): bool
    {
        return !empty($this->password);
    }

    public function isGoogleLinked(): bool
    {
        return !empty($this->google_id) || ($this->social_provider === 'google' && !empty($this->social_id));
    }
}
