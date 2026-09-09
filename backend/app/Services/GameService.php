<?php

namespace App\Services;

use App\Models\CoupleSpace;
use App\Models\CoupleTeam;
use App\Models\GameMove;
use App\Models\GameSession;
use App\Models\User;
use Illuminate\Support\Str;

class GameService
{
    public function __construct(
        protected StreakService $streakService
    ) {}

    /**
     * Start a new game session.
     */
    public function createSession(User $initiator, string $gameType, string $mode = '1v1_couple', ?int $opponentId = null, ?int $opponentSpaceId = null): GameSession
    {
        $space = $initiator->coupleSpace;
        $opponent = $opponentId ? User::find($opponentId) : $space?->getPartnerOf($initiator->id);

        $initialState = $this->getDefaultGameState($gameType);

        $session = GameSession::create([
            'session_code' => (string) Str::uuid(),
            'couple_space_id' => $initiator->couple_space_id,
            'game_type' => $gameType,
            'mode' => $mode,
            'initiator_id' => $initiator->id,
            'opponent_id' => $opponent?->id,
            'opponent_couple_space_id' => $opponentSpaceId,
            'game_state' => $initialState,
            'current_turn_user_id' => $initiator->id,
            'status' => 'in_progress',
        ]);

        $this->streakService->recordActivity($initiator, 'played_game');

        return $session;
    }

    /**
     * Submit a move or turn action.
     */
    public function submitMove(GameSession $session, User $user, array $moveData): GameSession
    {
        $movesCount = $session->moves()->count();

        GameMove::create([
            'game_session_id' => $session->id,
            'user_id' => $user->id,
            'move_number' => $movesCount + 1,
            'move_data' => $moveData,
        ]);

        $state = $session->game_state;
        $state['last_move'] = $moveData;
        $state['move_count'] = $movesCount + 1;

        // Switch turn
        $nextTurnUserId = ($session->initiator_id === $user->id) ? $session->opponent_id : $session->initiator_id;
        $session->current_turn_user_id = $nextTurnUserId;

        // Check completion
        if (!empty($moveData['is_game_over'])) {
            $session->status = 'completed';
            $session->winner_user_id = $moveData['winner_user_id'] ?? null;

            if ($session->mode === 'couple_vs_couple') {
                $this->updateTournamentElo($session);
            }
        }

        $session->game_state = $state;
        $session->save();

        return $session;
    }

    /**
     * Update couple team Elo ratings after a multiplayer battle.
     */
    protected function updateTournamentElo(GameSession $session): void
    {
        $teamA = CoupleTeam::where('couple_space_id', $session->couple_space_id)->first();
        $teamB = CoupleTeam::where('couple_space_id', $session->opponent_couple_space_id)->first();

        if (!$teamA || !$teamB) {
            return;
        }

        $kFactor = 32;
        $expectedA = 1 / (1 + pow(10, ($teamB->elo_rating - $teamA->elo_rating) / 400));
        $expectedB = 1 / (1 + pow(10, ($teamA->elo_rating - $teamB->elo_rating) / 400));

        $actualA = ($session->winner_user_id === $session->initiator_id) ? 1.0 : (($session->winner_user_id === null) ? 0.5 : 0.0);
        $actualB = 1.0 - $actualA;

        $teamA->elo_rating = (int) round($teamA->elo_rating + $kFactor * ($actualA - $expectedA));
        $teamB->elo_rating = (int) round($teamB->elo_rating + $kFactor * ($actualB - $expectedB));

        if ($actualA === 1.0) {
            $teamA->wins += 1;
            $teamB->losses += 1;
        } elseif ($actualA === 0.5) {
            $teamA->draws += 1;
            $teamB->draws += 1;
        } else {
            $teamA->losses += 1;
            $teamB->wins += 1;
        }

        $teamA->save();
        $teamB->save();
    }

    /**
     * Default game states for initial setup.
     */
    protected function getDefaultGameState(string $gameType): array
    {
        return match ($gameType) {
            'chess' => [
                'fen' => 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
                'captured_white' => [],
                'captured_black' => [],
            ],
            'ludo' => [
                'board' => 'standard_couple',
                'positions' => ['player1' => [0, 0, 0, 0], 'player2' => [0, 0, 0, 0]],
                'last_dice_roll' => 6,
            ],
            'truth_or_dare' => [
                'deck_category' => 'romantic_intimate',
                'current_card' => 'What is the most endearing habit your partner has that always makes you smile?',
                'card_type' => 'truth',
                'rounds_completed' => 0,
            ],
            'love_trivia', 'quiz', 'relationship_quiz' => [
                'current_question_index' => 0,
                'total_questions' => 5,
                'questions' => [
                    [
                        'q' => 'Where was our first date?',
                        'options' => ['Cozy Cafe', 'Seaside Walk', 'Cinema', 'Italian Restaurant'],
                        'correct_answer' => 'Cozy Cafe',
                    ],
                    [
                        'q' => 'What is your partner’s ultimate comfort food?',
                        'options' => ['Artisan Pizza', 'Warm Ramen', 'Chocolate Fudge', 'Homemade Pasta'],
                        'correct_answer' => 'Warm Ramen',
                    ],
                    [
                        'q' => 'What is the dream destination we always talk about?',
                        'options' => ['Santorini Sunset', 'Kyoto Cherry Blossoms', 'Swiss Alps Cabin', 'Amalfi Coast'],
                        'correct_answer' => 'Kyoto Cherry Blossoms',
                    ]
                ]
            ],
            default => ['status' => 'initialized', 'data' => []],
        };
    }
}
