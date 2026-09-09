<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->uuid('message_uuid')->unique();
            $table->foreignId('couple_space_id')->constrained('couple_spaces')->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->enum('type', ['text', 'photo', 'video', 'voice', 'document', 'location', 'gif', 'game_invite'])->default('text');
            $table->longText('encrypted_payload')->comment('AES-256-GCM ciphertext');
            $table->string('iv', 64)->comment('Initialization Vector');
            $table->string('mac', 64)->nullable()->comment('Authentication Tag');
            $table->foreignId('reply_to_message_id')->nullable()->constrained('messages')->nullOnDelete();
            $table->boolean('is_pinned')->default(false);
            $table->boolean('is_edited')->default(false);
            $table->timestamp('edited_at')->nullable();
            $table->enum('status', ['sent', 'delivered', 'read'])->default('sent');
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->json('metadata')->nullable()->comment('Dimensions, voice duration, coordinates, etc.');
            $table->softDeletes();
            $table->timestamps();

            $table->index(['couple_space_id', 'created_at']);
        });

        Schema::create('message_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained('messages')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('reaction', 16);
            $table->timestamps();

            $table->unique(['message_id', 'user_id']);
        });

        Schema::create('message_attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained('messages')->cascadeOnDelete();
            $table->string('file_path');
            $table->string('file_name');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size_bytes');
            $table->string('encryption_hash')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('message_attachments');
        Schema::dropIfExists('message_reactions');
        Schema::dropIfExists('messages');
    }
};
