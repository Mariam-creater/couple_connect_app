<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('couple_streaks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('couple_space_id')->unique()->constrained('couple_spaces')->cascadeOnDelete();
            $table->unsignedInteger('current_streak_days')->default(0);
            $table->unsignedInteger('longest_streak_days')->default(0);
            $table->date('last_activity_date')->nullable();
            $table->json('badges')->nullable()->comment('Unlocked badge IDs and timestamps');
            $table->unsignedBigInteger('total_messages_count')->default(0);
            $table->unsignedInteger('total_games_played')->default(0);
            $table->unsignedInteger('total_memories_added')->default(0);
            $table->unsignedInteger('total_goals_completed')->default(0);
            $table->timestamps();
        });

        Schema::create('streak_activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('couple_space_id')->constrained('couple_spaces')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('activity_type', [
                'daily_chat',
                'daily_check_in',
                'played_game',
                'added_memory',
                'calendar_event',
                'completed_vision_item'
            ]);
            $table->date('activity_date');
            $table->timestamps();

            $table->index(['couple_space_id', 'activity_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('streak_activity_logs');
        Schema::dropIfExists('couple_streaks');
    }
};
