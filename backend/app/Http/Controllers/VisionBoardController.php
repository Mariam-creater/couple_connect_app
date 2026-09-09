<?php

namespace App\Http\Controllers;

use App\Models\VisionBoard;
use App\Models\VisionItem;
use App\Services\StreakService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VisionBoardController extends Controller
{
    public function __construct(
        protected StreakService $streakService
    ) {}

    /**
     * List all vision boards for the couple.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $boards = VisionBoard::where('couple_space_id', $user->couple_space_id)
            ->with(['creator:id,name,avatar_url', 'items.creator:id,name', 'items.assignedTo:id,name,avatar_url'])
            ->orderBy('sort_order', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $boards
        ]);
    }

    /**
     * Create a new vision board card.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|in:dream_house,travel,wedding,business,savings,education,children,life_goals,wishlist',
            'description' => 'nullable|string',
            'cover_image_url' => 'nullable|string',
            'target_date' => 'nullable|date',
            'target_amount' => 'nullable|numeric|min:0',
            'current_amount' => 'nullable|numeric|min:0',
            'status' => 'nullable|in:dream,in_progress,achieved',
        ]);

        $progress = 0;
        if (!empty($validated['target_amount']) && $validated['target_amount'] > 0) {
            $current = $validated['current_amount'] ?? 0;
            $progress = (int) min(100, round(($current / $validated['target_amount']) * 100));
        }

        $board = VisionBoard::create([
            ...$validated,
            'couple_space_id' => $user->couple_space_id,
            'creator_id' => $user->id,
            'progress_percentage' => $progress,
            'status' => $validated['status'] ?? 'in_progress',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Vision card created',
            'data' => $board->load('creator:id,name,avatar_url')
        ], 201);
    }

    /**
     * Delete a vision board card.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $board = VisionBoard::where('id', $id)
            ->where('couple_space_id', $request->user()->couple_space_id)
            ->firstOrFail();

        $board->items()->delete();
        $board->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Vision goal deleted successfully'
        ]);
    }

    /**
     * Add a checklist item or sticky note to a vision board.
     */
    public function addItem(Request $request, int $boardId): JsonResponse
    {
        $board = VisionBoard::where('id', $boardId)
            ->where('couple_space_id', $request->user()->couple_space_id)
            ->firstOrFail();

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'nullable|string',
            'type' => 'nullable|in:sticky_note,checklist,milestone,photo',
            'assigned_to_user_id' => 'nullable|exists:users,id',
            'color_hex' => 'nullable|string|max:10',
        ]);

        $item = VisionItem::create([
            'vision_board_id' => $board->id,
            'creator_id' => $request->user()->id,
            'title' => $validated['title'],
            'content' => $validated['content'] ?? null,
            'type' => $validated['type'] ?? 'checklist',
            'assigned_to_user_id' => $validated['assigned_to_user_id'] ?? null,
            'color_hex' => $validated['color_hex'] ?? '#FFE082',
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $item->load('creator:id,name')
        ], 201);
    }

    /**
     * Delete a vision checklist/note item.
     */
    public function deleteItem(Request $request, int $itemId): JsonResponse
    {
        $item = VisionItem::whereHas('visionBoard', function ($q) use ($request) {
            $q->where('couple_space_id', $request->user()->couple_space_id);
        })->findOrFail($itemId);

        $board = $item->visionBoard;
        $item->delete();

        if (empty($board->target_amount)) {
            $total = $board->items()->count();
            $completed = $board->items()->where('is_completed', true)->count();
            $board->progress_percentage = ($total > 0) ? (int) round(($completed / $total) * 100) : 0;
            $board->save();
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Item deleted'
        ]);
    }

    /**
     * Toggle completion of a vision checklist item.
     */
    public function toggleItem(Request $request, int $itemId): JsonResponse
    {
        $item = VisionItem::whereHas('visionBoard', function ($q) use ($request) {
            $q->where('couple_space_id', $request->user()->couple_space_id);
        })->findOrFail($itemId);

        $item->is_completed = !$item->is_completed;
        $item->save();

        if ($item->is_completed) {
            $this->streakService->recordActivity($request->user(), 'completed_vision_item');
        }

        // Recalculate board progress percentage based on items if no target amount
        $board = $item->visionBoard;
        if (empty($board->target_amount)) {
            $total = $board->items()->count();
            $completed = $board->items()->where('is_completed', true)->count();
            $board->progress_percentage = ($total > 0) ? (int) round(($completed / $total) * 100) : 0;
            if ($board->progress_percentage === 100) {
                $board->status = 'achieved';
            }
            $board->save();
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'item' => $item,
                'board_progress' => $board->progress_percentage,
                'board_status' => $board->status,
            ]
        ]);
    }
}
