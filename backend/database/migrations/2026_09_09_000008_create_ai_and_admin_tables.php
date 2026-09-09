<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_analysis_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('couple_space_id')->nullable()->constrained('couple_spaces')->nullOnDelete();
            $table->enum('type', [
                'tone_analysis',
                'conflict_prevention',
                'chat_summary',
                'romantic_generator',
                'apology_generator',
                'trip_planner',
                'relationship_advice'
            ]);
            $table->text('input_content');
            $table->longText('analysis_result');
            $table->json('metrics')->nullable()->comment('Tone score, respect index, emotional balance');
            $table->timestamps();
        });

        Schema::create('reports_and_blocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reporter_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('reported_user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('action_type', ['report', 'block'])->default('block');
            $table->string('reason')->nullable();
            $table->text('details')->nullable();
            $table->enum('status', ['pending', 'reviewed', 'dismissed', 'action_taken'])->default('pending');
            $table->timestamps();
        });

        Schema::create('admin_system_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('action');
            $table->string('target_entity')->nullable();
            $table->unsignedBigInteger('target_id')->nullable();
            $table->json('details')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admin_system_logs');
        Schema::dropIfExists('reports_and_blocks');
        Schema::dropIfExists('ai_analysis_reports');
    }
};
