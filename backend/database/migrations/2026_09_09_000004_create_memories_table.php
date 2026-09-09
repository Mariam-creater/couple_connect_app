<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memories', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('couple_space_id')->constrained('couple_spaces')->cascadeOnDelete();
            $table->foreignId('creator_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->enum('category', [
                'photo',
                'video',
                'letter',
                'text_note',
                'voice_note',
                'pdf_document',
                'file'
            ])->default('photo');
            $table->string('album_name')->default('Main Memories');
            $table->longText('encrypted_body')->nullable()->comment('Encrypted letter/note content');
            $table->string('media_path')->nullable();
            $table->string('thumbnail_path')->nullable();
            $table->unsignedBigInteger('file_size_bytes')->nullable();
            $table->date('memory_date');
            $table->string('location_name')->nullable();
            $table->boolean('is_favorite')->default(false);
            $table->boolean('is_archived')->default(false);
            $table->json('tags')->nullable();
            $table->timestamps();

            $table->index(['couple_space_id', 'memory_date']);
            $table->index(['couple_space_id', 'album_name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memories');
    }
};
