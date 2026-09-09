<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->text('bio')->nullable()->after('avatar_url');
            $table->string('gender', 30)->nullable()->after('bio');
            $table->date('birthday')->nullable()->after('gender');
            $table->string('phone', 30)->nullable()->after('birthday');
            $table->boolean('privacy_show_online_status')->default(true)->after('online_status');
            $table->boolean('privacy_show_read_receipts')->default(true)->after('privacy_show_online_status');
            $table->string('social_provider', 30)->nullable()->after('privacy_show_read_receipts');
            $table->string('social_id')->nullable()->after('social_provider');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'bio',
                'gender',
                'birthday',
                'phone',
                'privacy_show_online_status',
                'privacy_show_read_receipts',
                'social_provider',
                'social_id',
            ]);
        });
    }
};
