<?php

namespace App\Http\Controllers;

use App\Models\CalendarEvent;
use App\Services\StreakService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CalendarController extends Controller
{
    public function __construct(
        protected StreakService $streakService
    ) {}

    /**
     * Get all calendar events for the couple space.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $query = CalendarEvent::where('couple_space_id', $user->couple_space_id)
            ->with('creator:id,name,avatar_url');

        if ($request->has('category')) {
            $query->where('category', $request->input('category'));
        }

        if ($request->has('month') && $request->has('year')) {
            $query->whereMonth('start_time', $request->input('month'))
                  ->whereYear('start_time', $request->input('year'));
        }

        $events = $query->orderBy('start_time', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $events
        ]);
    }

    /**
     * Create a new calendar event.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|in:anniversary,birthday,movie_night,date_night,travel,wedding_planning,bills,appointment,reminder,other',
            'color_hex' => 'nullable|string|max:10',
            'start_time' => 'required|date',
            'end_time' => 'nullable|date|after_or_equal:start_time',
            'is_all_day' => 'nullable|boolean',
            'is_countdown' => 'nullable|boolean',
            'recurrence' => 'nullable|in:none,daily,weekly,monthly,yearly',
            'reminder_minutes_before' => 'nullable|integer',
            'location' => 'nullable|string',
        ]);

        $event = CalendarEvent::create([
            ...$validated,
            'couple_space_id' => $user->couple_space_id,
            'creator_id' => $user->id,
            'color_hex' => $validated['color_hex'] ?? '#E91E63',
            'recurrence' => $validated['recurrence'] ?? 'none',
        ]);

        $this->streakService->recordActivity($user, 'calendar_event');

        return response()->json([
            'status' => 'success',
            'message' => 'Calendar event created',
            'data' => $event->load('creator:id,name,avatar_url')
        ], 201);
    }

    /**
     * Update an existing event.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $event = CalendarEvent::where('id', $id)
            ->where('couple_space_id', $request->user()->couple_space_id)
            ->firstOrFail();

        $validated = $request->validate([
            'title' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'category' => 'nullable|in:anniversary,birthday,movie_night,date_night,travel,wedding_planning,bills,appointment,reminder,other',
            'color_hex' => 'nullable|string|max:10',
            'start_time' => 'nullable|date',
            'end_time' => 'nullable|date',
            'is_all_day' => 'nullable|boolean',
            'is_countdown' => 'nullable|boolean',
            'recurrence' => 'nullable|in:none,daily,weekly,monthly,yearly',
            'is_completed' => 'nullable|boolean',
            'location' => 'nullable|string',
        ]);

        $event->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Event updated successfully',
            'data' => $event
        ]);
    }

    /**
     * Delete an event.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $event = CalendarEvent::where('id', $id)
            ->where('couple_space_id', $request->user()->couple_space_id)
            ->firstOrFail();

        $event->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Event deleted successfully'
        ]);
    }
}
