<?php

use App\Http\Controllers\AdminController;
use App\Http\Controllers\AIController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CalendarController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\CoupleController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\MemoryController;
use App\Http\Controllers\StreakController;
use App\Http\Controllers\VisionBoardController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| COUPLE CONNECT – REST API Routes v1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Public Health Check
    Route::get('/health', function () {
        return response()->json([
            'status' => 'online',
            'platform' => 'Couple Connect API',
            'version' => '1.0.0',
            'timestamp' => now()->toIso8601String(),
        ]);
    });

    // Public Audio & Document Streaming Routes (Cross-Origin & Byte-Range enabled)
    Route::get('/chat/audio/{filename}', [ChatController::class, 'streamAudio']);
    Route::get('/chat/documents/{identifier}/download', [ChatController::class, 'downloadDocument']);
    Route::get('/chat/documents/{identifier}', [ChatController::class, 'downloadDocument']);

    // Public Authentication Endpoints
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/google', [AuthController::class, 'googleAuth']);
    Route::post('/auth/social-login', [AuthController::class, 'socialLogin']);
    Route::get('/auth/check-username', [AuthController::class, 'checkUsername']);
    Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/auth/reset-password', [AuthController::class, 'resetPassword']);

    // Protected Authenticated Endpoints (Sanctum)
    Route::middleware('auth:sanctum')->group(function () {

        // User Profile, Credentials & Security
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/set-credentials', [AuthController::class, 'setCredentials']);
        Route::put('/auth/profile', [AuthController::class, 'updateProfile']);
        Route::put('/auth/privacy', [AuthController::class, 'updatePrivacySettings']);
        Route::post('/auth/security', [AuthController::class, 'updateSecurity']);
        Route::delete('/auth/account', [AuthController::class, 'deleteAccount']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        // Feature 1: Couple Connection
        Route::get('/couple/search', [CoupleController::class, 'search']);
        Route::post('/couple/request', [CoupleController::class, 'sendRequest']);
        Route::post('/couple/request/{id}/cancel', [CoupleController::class, 'cancelRequest']);
        Route::get('/couple/requests', [CoupleController::class, 'requests']);
        Route::post('/couple/request/{id}/accept', [CoupleController::class, 'acceptRequest']);
        Route::post('/couple/request/{id}/decline', [CoupleController::class, 'declineRequest']);
        Route::post('/couple/remove-partner', [CoupleController::class, 'removePartner']);
        Route::post('/couple/block', [CoupleController::class, 'blockUser']);
        Route::post('/couple/report', [CoupleController::class, 'reportUser']);
        Route::get('/couple/space', [CoupleController::class, 'space']);
        Route::put('/couple/space', [CoupleController::class, 'updateSpace']);

        // Feature 2: Real-Time Chat & E2EE Messages & Documents
        Route::get('/chat/messages', [ChatController::class, 'index']);
        Route::post('/chat/messages', [ChatController::class, 'store']);
        Route::put('/chat/messages/{id}', [ChatController::class, 'edit']);
        Route::post('/chat/messages/{id}/react', [ChatController::class, 'react']);
        Route::post('/chat/messages/read', [ChatController::class, 'markRead']);
        Route::post('/chat/messages/{id}/pin', [ChatController::class, 'togglePin']);
        Route::get('/chat/pinned', [ChatController::class, 'pinned']);
        Route::delete('/chat/messages/{id}', [ChatController::class, 'destroy']);
        Route::post('/chat/upload', [ChatController::class, 'uploadAttachment']);
        Route::post('/chat/documents', [ChatController::class, 'uploadDocument']);

        // Feature 3: Love Calendar
        Route::get('/calendar/events', [CalendarController::class, 'index']);
        Route::post('/calendar/events', [CalendarController::class, 'store']);
        Route::put('/calendar/events/{id}', [CalendarController::class, 'update']);
        Route::delete('/calendar/events/{id}', [CalendarController::class, 'destroy']);

        // Feature 4: Love Memories Vault
        Route::get('/memories', [MemoryController::class, 'index']);
        Route::post('/memories', [MemoryController::class, 'store']);
        Route::post('/memories/{id}/favorite', [MemoryController::class, 'toggleFavorite']);
        Route::get('/memories/albums', [MemoryController::class, 'albums']);

        // Feature 5: Couple Games & Tournaments
        Route::get('/games/sessions', [GameController::class, 'index']);
        Route::post('/games/start', [GameController::class, 'start']);
        Route::post('/games/sessions/{sessionCode}/move', [GameController::class, 'submitMove']);
        Route::get('/games/leaderboard', [GameController::class, 'leaderboard']);

        // Feature 6: Shared Vision Board
        Route::get('/vision-boards', [VisionBoardController::class, 'index']);
        Route::post('/vision-boards', [VisionBoardController::class, 'store']);
        Route::delete('/vision-boards/{id}', [VisionBoardController::class, 'destroy']);
        Route::post('/vision-boards/{boardId}/items', [VisionBoardController::class, 'addItem']);
        Route::delete('/vision-boards/items/{itemId}', [VisionBoardController::class, 'deleteItem']);
        Route::post('/vision-boards/items/{itemId}/toggle', [VisionBoardController::class, 'toggleItem']);

        // Feature 7: Couple Streak & Badges
        Route::get('/streak/status', [StreakController::class, 'status']);
        Route::post('/streak/check-in', [StreakController::class, 'dailyCheckIn']);
        Route::get('/streak/summary', [StreakController::class, 'summary']);

        // Feature 8: AI Relationship Assistant
        Route::post('/ai/analyze-tone', [AIController::class, 'analyzeTone']);
        Route::post('/ai/generate-romance', [AIController::class, 'generateRomance']);
        Route::post('/ai/plan-date', [AIController::class, 'planDate']);

        // Admin Management
        Route::prefix('admin')->group(function () {
            Route::get('/dashboard', [AdminController::class, 'dashboard']);
            Route::get('/users', [AdminController::class, 'users']);
            Route::get('/reports', [AdminController::class, 'reports']);
        });
    });
});
