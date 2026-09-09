<?php

namespace App\Services;

use App\Models\AiAnalysisReport;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AIService
{
    protected string $apiKey;
    protected string $endpoint;

    public function __construct()
    {
        $this->apiKey = config('services.gemini.api_key', env('GEMINI_API_KEY', ''));
        $this->endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
    }

    /**
     * Analyze couple chat message tone, signals, respect index and conflict prevention.
     */
    public function analyzeCommunicationTone(User $user, string $conversationText): array
    {
        $prompt = <<<PROMPT
You are a neutral, highly empathetic, and professional relationship communication psychologist for Couple Connect.
Analyze the following private couple communication snippet. Provide an objective, caring, and zero-bias breakdown:
Text: "{$conversationText}"

Respond ONLY with a valid JSON object matching this schema:
{
  "tone": "Warm | Constructive | Tense | Cold | Vulnerable | Defensive",
  "respect_score": 85,
  "emotional_balance": "Balanced | Initiator-heavy | Partner-guarded",
  "positive_signals": ["Affectionate greeting", "Active listening"],
  "risk_factors": ["Potential passive-aggression in second sentence"],
  "conflict_prevention_tips": ["Acknowledge partner's effort first before stating grievance"],
  "alternative_drafts": [
    "I understand you've been tired lately, could we find 10 minutes tonight to talk about dinner plans?"
  ],
  "summary_advice": "A gentle and encouraging recap with actionable communication guidance."
}
PROMPT;

        $response = $this->queryGemini($prompt);
        $result = $this->parseJsonOrFallback($response, [
            'tone' => 'Constructive',
            'respect_score' => 88,
            'emotional_balance' => 'Balanced',
            'positive_signals' => ['Open communication', 'Direct feedback'],
            'risk_factors' => [],
            'conflict_prevention_tips' => ['Maintain warm tone and use I-statements'],
            'alternative_drafts' => [$conversationText],
            'summary_advice' => 'Your message is clear. Adding a touch of appreciation will make it even more receptive to your partner.'
        ]);

        AiAnalysisReport::create([
            'user_id' => $user->id,
            'couple_space_id' => $user->couple_space_id,
            'type' => 'tone_analysis',
            'input_content' => $conversationText,
            'analysis_result' => json_encode($result),
            'metrics' => [
                'respect_score' => $result['respect_score'] ?? 85,
                'tone' => $result['tone'] ?? 'Constructive',
            ]
        ]);

        return $result;
    }

    /**
     * Generate romantic letters, apology messages, or anniversary wishes.
     */
    public function generateRomanticContent(User $user, string $type, array $context): array
    {
        $partnerName = $context['partner_name'] ?? 'My Love';
        $style = $context['style'] ?? 'poetic and deep';
        $keyMoments = $context['key_moments'] ?? 'our shared memories and future dreams';
        $coreIntent = $context['intent'] ?? 'expressing boundless love';

        $prompt = <<<PROMPT
You are an expert romantic writer and relationship coach for Couple Connect.
Generate a personalized, emotionally resonant message for a partner.
Type: {$type} (e.g. love_letter, apology, anniversary_wish, date_idea)
Recipient: {$partnerName}
Style: {$style}
Context / Shared Memories: {$keyMoments}
Core Intent: {$coreIntent}

Respond in clean JSON:
{
  "title": "A descriptive title",
  "generated_text": "The full beautifully worded letter/message with emotional depth",
  "talking_points": ["Key emotion expressed", "Future commitment"],
  "delivery_tip": "Advice on when and how to send/read this to your partner"
}
PROMPT;

        $response = $this->queryGemini($prompt);
        return $this->parseJsonOrFallback($response, [
            'title' => ucfirst(str_replace('_', ' ', $type)),
            'generated_text' => "To {$partnerName},\n\nEvery day by your side reminds me of why I fell in love with you. Thank you for your warmth, your laughter, and the gentle way you hold my heart.\n\nAlways yours.",
            'talking_points' => ['Gratitude', 'Unconditional support'],
            'delivery_tip' => 'Pair this with their favorite treat or read it during a quiet evening walk.'
        ]);
    }

    /**
     * Plan a personalized couple date or travel itinerary.
     */
    public function planDateOrTrip(User $user, array $preferences): array
    {
        $city = $preferences['location'] ?? 'Our Favorite City';
        $budget = $preferences['budget'] ?? 'Moderate';
        $vibe = $preferences['vibe'] ?? 'Romantic & Cozy';
        $duration = $preferences['duration'] ?? '1 Evening';

        $prompt = <<<PROMPT
Create a romantic, tailored date night or trip itinerary for a couple on Couple Connect.
Location: {$city}
Budget Level: {$budget}
Vibe: {$vibe}
Duration: {$duration}

Respond ONLY in JSON:
{
  "itinerary_title": "Title of the Date Plan",
  "highlight": "One sentence summary",
  "schedule": [
    {"time": "6:00 PM", "activity": "Sunset walk and viewpoint", "note": "Great photo spot"},
    {"time": "7:30 PM", "activity": "Candlelit dinner at an intimate bistro", "note": "Try the artisan dessert"},
    {"time": "9:30 PM", "activity": "Stargazing with hot chocolate", "note": "Play our favorite playlist"}
  ],
  "conversation_starters": [
    "What was the moment you knew we had something special?",
    "If we could teleport anywhere for 24 hours right now, where would we go?"
  ],
  "estimated_budget": "$60 - $120"
}
PROMPT;

        $response = $this->queryGemini($prompt);
        return $this->parseJsonOrFallback($response, [
            'itinerary_title' => 'Enchanted Evening Rendezvous',
            'highlight' => 'A cozy, intimate evening curated for meaningful connection.',
            'schedule' => [
                ['time' => '6:00 PM', 'activity' => 'Sunset walk at the park', 'note' => 'Golden hour moment'],
                ['time' => '7:30 PM', 'activity' => 'Romantic Italian dinner', 'note' => 'Share a dessert'],
                ['time' => '9:30 PM', 'activity' => 'Late night dessert & stargazing', 'note' => 'Listen to shared playlist']
            ],
            'conversation_starters' => [
                'What is your favorite memory of us from this past month?',
                'What is a dream we haven’t talked about yet?'
            ],
            'estimated_budget' => 'Moderate'
        ]);
    }

    protected function queryGemini(string $prompt): string
    {
        if (empty($this->apiKey)) {
            return '';
        }

        try {
            $res = Http::withHeaders(['Content-Type' => 'application/json'])
                ->post("{$this->endpoint}?key={$this->apiKey}", [
                    'contents' => [
                        [
                            'parts' => [
                                ['text' => $prompt]
                            ]
                        ]
                    ],
                    'generationConfig' => [
                        'temperature' => 0.7,
                        'maxOutputTokens' => 1024,
                    ]
                ]);

            if ($res->successful()) {
                $body = $res->json();
                return $body['candidates'][0]['content']['parts'][0]['text'] ?? '';
            }
        } catch (\Exception $e) {
            Log::warning('Gemini AI API call failed: ' . $e->getMessage());
        }

        return '';
    }

    protected function parseJsonOrFallback(string $rawResponse, array $fallback): array
    {
        if (empty($rawResponse)) {
            return $fallback;
        }

        // Clean markdown backticks if present
        $clean = preg_replace('/^```json\s*/i', '', trim($rawResponse));
        $clean = preg_replace('/\s*```$/', '', $clean);

        $decoded = json_decode($clean, true);
        return is_array($decoded) ? $decoded : $fallback;
    }
}
