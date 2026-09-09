<?php

namespace App\Http\Controllers;

use App\Services\AIService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AIController extends Controller
{
    public function __construct(
        protected AIService $aiService
    ) {}

    /**
     * Analyze message tone, respect index, emotional balance and conflict risk.
     */
    public function analyzeTone(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message_text' => 'required|string|min:5|max:3000',
        ]);

        $analysis = $this->aiService->analyzeCommunicationTone($request->user(), $validated['message_text']);

        return response()->json([
            'status' => 'success',
            'data' => $analysis
        ]);
    }

    /**
     * Generate romantic letters, sincere apologies, or anniversary wishes.
     */
    public function generateRomance(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type' => 'required|in:love_letter,apology,anniversary_wish,encouragement,poem',
            'partner_name' => 'nullable|string',
            'style' => 'nullable|string',
            'key_moments' => 'nullable|string',
            'intent' => 'nullable|string',
        ]);

        $generated = $this->aiService->generateRomanticContent($request->user(), $validated['type'], $validated);

        return response()->json([
            'status' => 'success',
            'data' => $generated
        ]);
    }

    /**
     * Generate a tailored date night or trip itinerary.
     */
    public function planDate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'location' => 'nullable|string',
            'budget' => 'nullable|string',
            'vibe' => 'nullable|string',
            'duration' => 'nullable|string',
        ]);

        $plan = $this->aiService->planDateOrTrip($request->user(), $validated);

        return response()->json([
            'status' => 'success',
            'data' => $plan
        ]);
    }
}
