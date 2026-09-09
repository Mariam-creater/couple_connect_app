<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Memory extends Model
{
    use HasFactory;

    protected $fillable = [
        'uuid',
        'couple_space_id',
        'creator_id',
        'title',
        'category',
        'album_name',
        'encrypted_body',
        'media_path',
        'thumbnail_path',
        'file_size_bytes',
        'memory_date',
        'location_name',
        'is_favorite',
        'is_archived',
        'tags',
    ];

    protected function casts(): array
    {
        return [
            'memory_date' => 'date',
            'is_favorite' => 'boolean',
            'is_archived' => 'boolean',
            'tags' => 'array',
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

    public function coupleSpace(): BelongsTo
    {
        return $this->belongsTo(CoupleSpace::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'creator_id');
    }
}
