<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vision_boards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('couple_space_id')->constrained('couple_spaces')->cascadeOnDelete();
            $table->foreignId('creator_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->enum('category', [
                'dream_house',
                'travel',
                'wedding',
                'business',
                'savings',
                'education',
                'children',
                'life_goals'
            ])->default('life_goals');
            $table->text('description')->nullable();
            $table->string('cover_image_url')->nullable();
            $table->date('target_date')->nullable();
            $table->decimal('target_amount', 12, 2)->nullable();
            $table->decimal('current_amount', 12, 2)->default(0.00);
            $table->unsignedTinyInteger('progress_percentage')->default(0);
            $table->enum('status', ['dream', 'in_progress', 'achieved'])->default('dream');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['couple_space_id', 'category']);
        });

        Schema::create('vision_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vision_board_id')->constrained('vision_boards')->cascadeOnDelete();
            $table->foreignId('creator_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('content')->nullable();
            $table->enum('type', ['sticky_note', 'checklist', 'milestone', 'photo'])->default('checklist');
            $table->boolean('is_completed')->default(false);
            $table->foreignId('assigned_to_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('color_hex', 10)->default('#FFE082');
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vision_items');
        Schema::dropIfExists('vision_boards');
    }
};
