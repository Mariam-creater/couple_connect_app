<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('couple_teams', function (Blueprint $table) {
            $table->id();
            $table->foreignId('couple_space_id')->unique()->constrained('couple_spaces')->cascadeOnDelete();
            $table->string('team_name');
            $table->integer('elo_rating')->default(1200);
            $table->integer('wins')->default(0);
            $table->integer('losses')->default(0);
            $table->integer('draws')->default(0);
            $table->string('rank_tier', 32)->default('Bronze');
            $table->timestamps();
        });

        Schema::create('game_sessions', function (Blueprint $table) {
            $table->id();
            $table->uuid('session_code')->unique();
            $table->foreignId('couple_space_id')->constrained('couple_spaces')->cascadeOnDelete();
            $table->enum('game_type', [
                'truth_or_dare',
                'chess',
                'ludo',
                'quiz',
                'puzzle',
                'memory_match',
                'would_you_rather',
                'love_trivia',
                'relationship_quiz'
            ]);
            $table->enum('mode', ['1v1_couple', 'couple_vs_couple'])->default('1v1_couple');
            $table->foreignId('initiator_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('opponent_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('opponent_couple_space_id')->nullable()->constrained('couple_spaces')->nullOnDelete();
            $table->json('game_state')->comment('Board matrix, deck position, current round, scores');
            $table->foreignId('current_turn_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('winner_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('status', ['waiting', 'in_progress', 'completed', 'forfeited'])->default('in_progress');
            $table->integer('score_initiator')->default(0);
            $table->integer('score_opponent')->default(0);
            $table->timestamps();

            $table->index(['couple_space_id', 'game_type']);
        });

        Schema::create('game_moves', function (Blueprint $table) {
            $table->id();
            $table->foreignId('game_session_id')->constrained('game_sessions')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->integer('move_number');
            $table->json('move_data');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('game_moves');
        Schema::dropIfExists('game_sessions');
        Schema::dropIfExists('couple_teams');
    }
};
