<?php

namespace App\Http\Controllers;

use App\Models\AdminSystemLog;
use App\Models\AiAnalysisReport;
use App\Models\CoupleSpace;
use App\Models\GameSession;
use App\Models\Memory;
use App\Models\Message;
use App\Models\ReportAndBlock;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Get system-wide dashboard metrics.
     */
    public function dashboard(Request $request): JsonResponse
    {
        $this->ensureAdmin($request->user());

        $totalUsers = User::count();
        $totalCouples = CoupleSpace::where('status', 'active')->count();
        $totalMessages = Message::count();
        $totalMemories = Memory::count();
        $totalGames = GameSession::count();
        $totalAIInteractions = AiAnalysisReport::count();
        $totalStorageBytes = Memory::sum('file_size_bytes') + Message::count() * 1024;

        return response()->json([
            'status' => 'success',
            'data' => [
                'metrics' => [
                    'total_users' => $totalUsers,
                    'active_couples' => $totalCouples,
                    'total_messages_exchanged' => $totalMessages,
                    'total_memories_vaulted' => $totalMemories,
                    'total_games_played' => $totalGames,
                    'ai_requests_processed' => $totalAIInteractions,
                    'storage_usage_formatted' => round($totalStorageBytes / (1024 * 1024), 2) . ' MB',
                ],
                'recent_registrations' => User::latest()->limit(5)->get(['id', 'name', 'username', 'email', 'relationship_status', 'created_at']),
                'pending_reports' => ReportAndBlock::where('status', 'pending')->count(),
            ]
        ]);
    }

    /**
     * List users with pagination and search.
     */
    public function users(Request $request): JsonResponse
    {
        $this->ensureAdmin($request->user());

        $query = User::with('coupleSpace');
        if ($request->has('search')) {
            $s = $request->input('search');
            $query->where('name', 'like', "%{$s}%")
                  ->orWhere('username', 'like', "%{$s}%")
                  ->orWhere('email', 'like', "%{$s}%")
                  ->orWhere('couple_id', 'like', "%{$s}%");
        }

        return response()->json([
            'status' => 'success',
            'data' => $query->paginate(25)
        ]);
    }

    /**
     * List moderation reports.
     */
    public function reports(Request $request): JsonResponse
    {
        $this->ensureAdmin($request->user());

        $reports = ReportAndBlock::with(['reporter:id,name,username', 'reportedUser:id,name,username'])
            ->latest()
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $reports
        ]);
    }

    protected function ensureAdmin(User $user): void
    {
        if (!$user->isAdmin()) {
            abort(403, 'Unauthorized. Administrator privilege required.');
        }
    }
}
