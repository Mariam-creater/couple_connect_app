<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('couple_spaces', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('user_one_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('user_two_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('connected_at');
            $table->date('anniversary_date')->nullable();
            $table->string('space_name')->default('Our Private Space');
            $table->string('theme_preset')->default('rose_gold');
            $table->string('chat_wallpaper')->nullable();
            $table->enum('status', ['active', 'paused', 'archived'])->default('active');
            $table->timestamps();

            $table->unique(['user_one_id', 'user_two_id']);
        });

        Schema::create('couple_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('receiver_id')->constrained('users')->cascadeOnDelete();
            $table->enum('status', ['pending', 'accepted', 'declined', 'blocked'])->default('pending');
            $table->timestamp('responded_at')->nullable();
            $table->timestamps();

            $table->index(['sender_id', 'receiver_id']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('couple_space_id')->nullable()->after('relationship_status')->constrained('couple_spaces')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['couple_space_id']);
            $table->dropColumn('couple_space_id');
        });

        Schema::dropIfExists('couple_requests');
        Schema::dropIfExists('couple_spaces');
    }
};
