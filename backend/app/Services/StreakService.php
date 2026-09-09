<?php

namespace App\Services;

use App\Models\CoupleSpace;
use App\Models\CoupleStreak;
use App\Models\StreakActivityLog;
use App\Models\User;
use Carbon\Carbon;

class StreakService
{
    /**
     * Record a relationship activity and update streak count.
     */
    public function recordActivity(User $user, string $activityType): CoupleStreak
    {
        if (!$user->couple_space_id) {
            throw new \Exception('User has no active couple space');
        }

        $spaceId = $user->couple_space_id;
        $today = Carbon::today();

        // Log specific activity entry
        StreakActivityLog::create([
            'couple_space_id' => $spaceId,
            'user_id' => $user->id,
            'activity_type' => $activityType,
            'activity_date' => $today->toDateString(),
        ]);

        $streak = CoupleStreak::firstOrCreate(
            ['couple_space_id' => $spaceId],
            [
                'current_streak_days' => 1,
                'longest_streak_days' => 1,
                'last_activity_date' => $today->toDateString(),
                'badges' => ['first_step'],
            ]
        );

        $lastDate = $streak->last_activity_date ? Carbon::parse($streak->last_activity_date) : null;

        if ($lastDate && $lastDate->isToday()) {
            // Activity already counted for today, increment counters
            $this->incrementTypeCounter($streak, $activityType);
            $streak->save();
            return $streak;
        }

        if ($lastDate && $lastDate->isYesterday()) {
            // Consecutive day: increment streak
            $streak->current_streak_days += 1;
            if ($streak->current_streak_days > $streak->longest_streak_days) {
                $streak->longest_streak_days = $streak->current_streak_days;
            }
        } elseif (!$lastDate || $lastDate->diffInDays($today) > 1) {
            // Broken streak, reset to 1
            $streak->current_streak_days = 1;
        }

        $streak->last_activity_date = $today->toDateString();
        $this->incrementTypeCounter($streak, $activityType);
        $this->evaluateBadges($streak);
        $streak->save();

        return $streak;
    }

    protected function incrementTypeCounter(CoupleStreak $streak, string $type): void
    {
        match ($type) {
            'daily_chat' => $streak->total_messages_count += 1,
            'played_game' => $streak->total_games_played += 1,
            'added_memory' => $streak->total_memories_added += 1,
            'completed_vision_item' => $streak->total_goals_completed += 1,
            default => null,
        };
    }

    protected function evaluateBadges(CoupleStreak $streak): void
    {
        $badges = $streak->badges ?? [];

        if ($streak->current_streak_days >= 7 && !in_array('7_day_spark', $badges)) {
            $badges[] = '7_day_spark';
        }
        if ($streak->current_streak_days >= 30 && !in_array('30_day_flame', $badges)) {
            $badges[] = '30_day_flame';
        }
        if ($streak->current_streak_days >= 100 && !in_array('100_day_unbreakable', $badges)) {
            $badges[] = '100_day_unbreakable';
        }
        if ($streak->current_streak_days >= 365 && !in_array('365_day_golden_heart', $badges)) {
            $badges[] = '365_day_golden_heart';
        }
        if ($streak->total_games_played >= 10 && !in_array('playful_duo', $badges)) {
            $badges[] = 'playful_duo';
        }
        if ($streak->total_memories_added >= 25 && !in_array('memory_curator', $badges)) {
            $badges[] = 'memory_curator';
        }
        if ($streak->total_goals_completed >= 5 && !in_array('dream_achievers', $badges)) {
            $badges[] = 'dream_achievers';
        }

        $streak->badges = $badges;
    }
}
