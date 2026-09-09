<?php

namespace App\Http\Controllers;

use App\Models\CoupleRequest;
use App\Models\CoupleSpace;
use App\Models\ReportAndBlock;
use App\Models\User;
use App\Services\CoupleManagerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CoupleController extends Controller
{
    public function __construct(
        protected CoupleManagerService $coupleService
    ) {}

    /**
     * Search for a prospective partner.
     */
    public function search(Request $request): JsonResponse
    {
        $request->validate([
            'query' => 'required|string|min:2',
        ]);

        $user = $this->coupleService->searchPartner($request->input('query'), $request->user());

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'No single user found matching that username or Couple ID.',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $user
        ]);
    }

    /**
     * Send connection request to a partner.
     */
    public function sendRequest(Request $request): JsonResponse
    {
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
        ]);

        try {
            $coupleRequest = $this->coupleService->sendRequest($request->user(), (int) $request->input('receiver_id'));
            return response()->json([
                'status' => 'success',
                'message' => 'Couple invitation sent successfully.',
                'data' => $coupleRequest->load('receiver:id,name,username,avatar_url')
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Cancel an outgoing pending request.
     */
    public function cancelRequest(Request $request, int $id): JsonResponse
    {
        $coupleRequest = CoupleRequest::where('id', $id)
            ->where('sender_id', $request->user()->id)
            ->where('status', 'pending')
            ->firstOrFail();

        $coupleRequest->delete();

        $request->user()->update(['relationship_status' => 'single']);

        return response()->json([
            'status' => 'success',
            'message' => 'Couple request cancelled.'
        ]);
    }

    /**
     * Get pending incoming and outgoing requests.
     */
    public function requests(Request $request): JsonResponse
    {
        $user = $request->user();

        $incoming = CoupleRequest::where('receiver_id', $user->id)
            ->where('status', 'pending')
            ->with('sender:id,name,username,avatar_url,couple_id,public_key,bio')
            ->get();

        $outgoing = CoupleRequest::where('sender_id', $user->id)
            ->where('status', 'pending')
            ->with('receiver:id,name,username,avatar_url,couple_id,bio')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'incoming' => $incoming,
                'outgoing' => $outgoing,
            ]
        ]);
    }

    /**
     * Accept incoming couple request.
     */
    public function acceptRequest(Request $request, int $id): JsonResponse
    {
        try {
            $space = $this->coupleService->acceptRequest($id, $request->user());
            return response()->json([
                'status' => 'success',
                'message' => 'Couple space created! Welcome to your private universe.',
                'data' => $space->load(['userOne', 'userTwo', 'streak', 'team'])
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Decline incoming couple request.
     */
    public function declineRequest(Request $request, int $id): JsonResponse
    {
        try {
            $this->coupleService->declineRequest($id, $request->user());
            return response()->json([
                'status' => 'success',
                'message' => 'Couple request declined.'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Remove / Disconnect from current partner.
     */
    public function removePartner(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        DB::transaction(function () use ($user) {
            $space = CoupleSpace::findOrFail($user->couple_space_id);
            $partner = $space->getPartnerOf($user->id);

            $user->update([
                'relationship_status' => 'single',
                'couple_space_id' => null,
            ]);

            if ($partner) {
                $partner->update([
                    'relationship_status' => 'single',
                    'couple_space_id' => null,
                ]);
            }

            $space->delete();
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Disconnected from partner. Status set to single.'
        ]);
    }

    /**
     * Block a user.
     */
    public function blockUser(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'reason' => 'nullable|string',
        ]);

        ReportAndBlock::create([
            'reporter_id' => $request->user()->id,
            'reported_user_id' => $validated['user_id'],
            'action_type' => 'block',
            'reason' => $validated['reason'] ?? 'User blocked',
            'status' => 'action_taken',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'User blocked.'
        ]);
    }

    /**
     * Report a user.
     */
    public function reportUser(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'reason' => 'required|string|max:255',
            'details' => 'nullable|string|max:1000',
        ]);

        ReportAndBlock::create([
            'reporter_id' => $request->user()->id,
            'reported_user_id' => $validated['user_id'],
            'action_type' => 'report',
            'reason' => $validated['reason'],
            'details' => $validated['details'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Report submitted for review.'
        ]);
    }

    /**
     * Get active couple space details.
     */
    public function space(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->couple_space_id) {
            return response()->json([
                'status' => 'error',
                'message' => 'No connected couple space found.'
            ], 404);
        }

        $space = CoupleSpace::where('id', $user->couple_space_id)
            ->with(['userOne', 'userTwo', 'streak', 'team'])
            ->firstOrFail();

        return response()->json([
            'status' => 'success',
            'data' => [
                'space' => $space,
                'partner' => $space->getPartnerOf($user->id),
            ]
        ]);
    }

    /**
     * Update couple space settings.
     */
    public function updateSpace(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $space = CoupleSpace::findOrFail($user->couple_space_id);

        $validated = $request->validate([
            'space_name' => 'nullable|string|max:100',
            'theme_preset' => 'nullable|string|in:rose_gold,violet_dreams,ocean_breeze,midnight_velvet,emerald_forest',
            'anniversary_date' => 'nullable|date',
            'chat_wallpaper' => 'nullable|string',
        ]);

        $space->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Couple space updated',
            'data' => $space
        ]);
    }
}
