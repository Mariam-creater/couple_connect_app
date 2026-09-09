<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            if (!Schema::hasColumn('messages', 'file_path')) {
                $table->string('file_path')->nullable()->after('type');
            }
            if (!Schema::hasColumn('messages', 'original_name')) {
                $table->string('original_name')->nullable()->after('file_path');
            }
            if (!Schema::hasColumn('messages', 'mime_type')) {
                $table->string('mime_type')->nullable()->after('original_name');
            }
            if (!Schema::hasColumn('messages', 'file_size_bytes')) {
                $table->unsignedBigInteger('file_size_bytes')->nullable()->after('mime_type');
            }
        });

        Schema::table('message_attachments', function (Blueprint $table) {
            if (!Schema::hasColumn('message_attachments', 'original_name')) {
                $table->string('original_name')->nullable()->after('file_name');
            }
            if (!Schema::hasColumn('message_attachments', 'download_count')) {
                $table->unsignedInteger('download_count')->default(0)->after('encryption_hash');
            }
        });
    }

    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->dropColumn(['file_path', 'original_name', 'mime_type', 'file_size_bytes']);
        });

        Schema::table('message_attachments', function (Blueprint $table) {
            $table->dropColumn(['original_name', 'download_count']);
        });
    }
};
