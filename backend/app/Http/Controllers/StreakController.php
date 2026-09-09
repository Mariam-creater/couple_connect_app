<?php

namespace App\Http\Controllers;

use App\Models\CoupleStreak;
use App\Models\StreakActivityLog;
use App\Services\StreakService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StreakController extends Controller
{
    public function __construct(
        protected StreakService $streakService
    ) {}

    /**
     * Get current couple streak status & unlocked badges.
     */
    public function status(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $streak = CoupleStreak::firstOrCreate(
            ['couple_space_id' => $user->couple_space_id],
            [
                'current_streak_days' => 1,
                'longest_streak_days' => 1,
                'last_activity_date' => now()->toDateString(),
                'badges' => ['first_step'],
            ]
        );

        $badgeMetadata = [
            'first_step' => ['title' => 'First Step', 'icon' => '🌱', 'desc' => 'Joined Couple Connect together'],
            '7_day_spark' => ['title' => '7-Day Spark', 'icon' => '✨', 'desc' => 'Maintained a 7-day relationship streak'],
            '30_day_flame' => ['title' => '30-Day Flame', 'icon' => '🔥', 'desc' => 'One month of continuous connection'],
            '100_day_unbreakable' => ['title' => '100-Day Unbreakable', 'icon' => '💎', 'desc' => '100 days of mutual affection'],
            '365_day_golden_heart' => ['title' => 'Golden Anniversary', 'icon' => '👑', 'desc' => '365 days of true devotion'],
            'playful_duo' => ['title' => 'Playful Duo', 'icon' => '🎲', 'desc' => 'Played 10+ games together'],
            'memory_curator' => ['title' => 'Memory Curator', 'icon' => '📸', 'desc' => 'Captured 25+ memories'],
            'dream_achievers' => ['title' => 'Dream Achievers', 'icon' => '🎯', 'desc' => 'Completed 5+ shared life goals'],
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'streak' => $streak,
                'badge_definitions' => $badgeMetadata,
                'today_completed' => ($streak->last_activity_date === now()->toDateString()),
            ]
        ]);
    }

    /**
     * Complete daily check-in prompt.
     */
    public function dailyCheckIn(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $streak = $this->streakService->recordActivity($user, 'daily_check_in');

        return response()->json([
            'status' => 'success',
            'message' => 'Daily check-in recorded! Streak kept alive 🔥',
            'data' => $streak
        ]);
    }

    /**
     * Get monthly and annual summary statistics.
     */
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();
        $spaceId = $user->couple_space_id;

        $now = Carbon::now();
        $thisMonthLogs = StreakActivityLog::where('couple_space_id', $spaceId)
            ->whereMonth('activity_date', $now->month)
            ->whereYear('activity_date', $now->year)
            ->get();

        $activityBreakdown = [
            'chats' => $thisMonthLogs->where('activity_type', 'daily_chat')->count(),
            'games' => $thisMonthLogs->where('activity_type', 'played_game')->count(),
            'memories' => $thisMonthLogs->where('activity_type', 'added_memory')->count(),
            'goals' => $thisMonthLogs->where('activity_type', 'completed_vision_item')->count(),
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'month_name' => $now->format('F Y'),
                'total_active_days_this_month' => $thisMonthLogs->groupBy('activity_date')->count(),
                'breakdown' => $activityBreakdown,
            ]
        ]);
    }
}
