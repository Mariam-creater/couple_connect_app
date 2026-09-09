<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('calendar_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('couple_space_id')->constrained('couple_spaces')->cascadeOnDelete();
            $table->foreignId('creator_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('category', [
                'anniversary',
                'birthday',
                'movie_night',
                'date_night',
                'travel',
                'wedding_planning',
                'bills',
                'appointment',
                'reminder',
                'other'
            ])->default('date_night');
            $table->string('color_hex', 10)->default('#E91E63');
            $table->dateTime('start_time');
            $table->dateTime('end_time')->nullable();
            $table->boolean('is_all_day')->default(false);
            $table->boolean('is_countdown')->default(false);
            $table->enum('recurrence', ['none', 'daily', 'weekly', 'monthly', 'yearly'])->default('none');
            $table->integer('reminder_minutes_before')->default(60);
            $table->boolean('is_completed')->default(false);
            $table->string('location')->nullable();
            $table->timestamps();

            $table->index(['couple_space_id', 'start_time']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('calendar_events');
    }
};
