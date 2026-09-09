<?php

namespace App\Http\Controllers;

use App\Models\CoupleTeam;
use App\Models\GameSession;
use App\Services\GameService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GameController extends Controller
{
    public function __construct(
        protected GameService $gameService
    ) {}

    /**
     * Get active game sessions for current couple.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $sessions = GameSession::where('couple_space_id', $user->couple_space_id)
            ->with(['initiator:id,name,avatar_url', 'opponent:id,name,avatar_url', 'currentTurnUser:id,name'])
            ->orderBy('id', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $sessions
        ]);
    }

    /**
     * Start a new game session (1v1 couple or multiplayer battle).
     */
    public function start(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'game_type' => 'required|in:truth_or_dare,chess,ludo,quiz,puzzle,memory_match,would_you_rather,love_trivia,relationship_quiz',
            'mode' => 'nullable|in:1v1_couple,couple_vs_couple',
            'opponent_space_id' => 'nullable|exists:couple_spaces,id',
        ]);

        $session = $this->gameService->createSession(
            $request->user(),
            $validated['game_type'],
            $validated['mode'] ?? '1v1_couple',
            null,
            $validated['opponent_space_id'] ?? null
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Game room ready',
            'data' => $session->load(['initiator:id,name,avatar_url', 'opponent:id,name,avatar_url'])
        ], 201);
    }

    /**
     * Submit a player turn / move.
     */
    public function submitMove(Request $request, string $sessionCode): JsonResponse
    {
        $validated = $request->validate([
            'move_data' => 'required|array',
        ]);

        $session = GameSession::where('session_code', $sessionCode)->firstOrFail();
        $updatedSession = $this->gameService->submitMove($session, $request->user(), $validated['move_data']);

        return response()->json([
            'status' => 'success',
            'data' => $updatedSession->load(['initiator:id,name,avatar_url', 'opponent:id,name,avatar_url', 'currentTurnUser:id,name', 'winnerUser:id,name'])
        ]);
    }

    /**
     * Get global Couple vs Couple tournament leaderboards.
     */
    public function leaderboard(Request $request): JsonResponse
    {
        $leaderboard = CoupleTeam::orderBy('elo_rating', 'desc')
            ->with('coupleSpace.userOne:id,name,avatar_url', 'coupleSpace.userTwo:id,name,avatar_url')
            ->limit(50)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $leaderboard
        ]);
    }
}
