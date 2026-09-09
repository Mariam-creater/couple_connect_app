<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class VisionBoard extends Model
{
    use HasFactory;

    protected $fillable = [
        'couple_space_id',
        'creator_id',
        'title',
        'category',
        'description',
        'cover_image_url',
        'target_date',
        'target_amount',
        'current_amount',
        'progress_percentage',
        'status',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'target_date' => 'date',
            'target_amount' => 'decimal:2',
            'current_amount' => 'decimal:2',
            'progress_percentage' => 'integer',
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

    public function items(): HasMany
    {
        return $this->hasMany(VisionItem::class)->orderBy('sort_order');
    }
}
