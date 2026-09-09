<?php

namespace Database\Seeders;

use App\Models\CalendarEvent;
use App\Models\CoupleSpace;
use App\Models\CoupleStreak;
use App\Models\CoupleTeam;
use App\Models\GameSession;
use App\Models\Memory;
use App\Models\Message;
use App\Models\MessageReaction;
use App\Models\User;
use App\Models\VisionBoard;
use App\Models\VisionItem;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class CoupleConnectSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Admin User
        $admin = User::create([
            'name' => 'System Administrator',
            'username' => 'admin',
            'email' => 'admin@coupleconnect.app',
            'password' => Hash::make('AdminSecret123!'),
            'couple_id' => 'CP-ADMIN-01',
            'relationship_status' => 'single',
            'role' => 'admin',
            'online_status' => 'online',
        ]);

        // 2. Demo Couple: Alexander (Alex) & Sophia
        $alex = User::create([
            'name' => 'Alexander Vance',
            'username' => 'alex',
            'email' => 'alex@coupleconnect.app',
            'password' => Hash::make('Password123!'),
            'avatar_url' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
            'couple_id' => 'CP-ALEX-77',
            'relationship_status' => 'connected',
            'role' => 'user',
            'public_key' => 'ecdsa-p256-demo-public-key-alexander-vance-7718',
            'biometric_enabled' => true,
            'online_status' => 'online',
            'last_seen_at' => now(),
        ]);

        $sophia = User::create([
            'name' => 'Sophia Bennett',
            'username' => 'sophia',
            'email' => 'sophia@coupleconnect.app',
            'password' => Hash::make('Password123!'),
            'avatar_url' => 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
            'couple_id' => 'CP-SOPH-88',
            'relationship_status' => 'connected',
            'role' => 'user',
            'public_key' => 'ecdsa-p256-demo-public-key-sophia-bennett-8829',
            'biometric_enabled' => true,
            'online_status' => 'online',
            'last_seen_at' => now(),
        ]);

        // 2b. Demo Couple: Saam Ayanle (Boyfriend) & Boqran Yasin (Girlfriend)
        $saam = User::create([
            'name' => 'Saam Ayanle',
            'username' => 'saam',
            'email' => 'saam@coupleconnect.app',
            'password' => Hash::make('password123'),
            'avatar_url' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
            'couple_id' => 'CP-SAAM-01',
            'gender' => 'male',
            'bio' => 'Forever in love with Boqran ❤️ | My Queen',
            'birthday' => '2001-05-14',
            'relationship_status' => 'connected',
            'role' => 'user',
            'biometric_enabled' => true,
            'online_status' => 'online',
            'last_seen_at' => now(),
        ]);

        $boqran = User::create([
            'name' => 'Boqran Yasin',
            'username' => 'boqran',
            'email' => 'boqran@coupleconnect.app',
            'password' => Hash::make('password123'),
            'avatar_url' => 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
            'couple_id' => 'CP-BOQR-02',
            'gender' => 'female',
            'bio' => 'Saam’s heartbeat 💕 | Soulmates forever',
            'birthday' => '2002-08-22',
            'relationship_status' => 'connected',
            'role' => 'user',
            'biometric_enabled' => true,
            'online_status' => 'online',
            'last_seen_at' => now(),
        ]);

        $saamSpace = CoupleSpace::create([
            'uuid' => (string) Str::uuid(),
            'user_one_id' => $saam->id,
            'user_two_id' => $boqran->id,
            'connected_at' => now()->subMonths(8),
            'anniversary_date' => now()->subMonths(8)->toDateString(),
            'space_name' => 'Saam & Boqran’s Love Sanctuary ❤️',
            'theme_preset' => 'rose_gold',
            'status' => 'active',
        ]);

        $saam->update(['couple_space_id' => $saamSpace->id]);
        $boqran->update(['couple_space_id' => $saamSpace->id]);

        CoupleStreak::create([
            'couple_space_id' => $saamSpace->id,
            'current_streak_days' => 50,
            'longest_streak_days' => 50,
            'last_activity_date' => now()->toDateString(),
            'badges' => ['first_step', '7_day_spark', '30_day_flame', 'playful_duo', 'memory_curator'],
            'total_messages_count' => 840,
            'total_games_played' => 12,
            'total_memories_added' => 15,
            'total_goals_completed' => 5,
        ]);

        CoupleTeam::create([
            'couple_space_id' => $saamSpace->id,
            'team_name' => 'Team Saam & Boqran',
            'elo_rating' => 1520,
            'wins' => 16,
            'losses' => 2,
            'season_points' => 980,
        ]);

        // 3. Create Couple Space
        $space = CoupleSpace::create([
            'uuid' => (string) Str::uuid(),
            'user_one_id' => $alex->id,
            'user_two_id' => $sophia->id,
            'connected_at' => now()->subMonths(14),
            'anniversary_date' => now()->subMonths(14)->toDateString(),
            'space_name' => 'Alex & Sophia’s Sanctuary',
            'theme_preset' => 'rose_gold',
            'status' => 'active',
        ]);

        $alex->update(['couple_space_id' => $space->id]);
        $sophia->update(['couple_space_id' => $space->id]);

        // 4. Initialize Streak
        CoupleStreak::create([
            'couple_space_id' => $space->id,
            'current_streak_days' => 42,
            'longest_streak_days' => 42,
            'last_activity_date' => now()->toDateString(),
            'badges' => ['first_step', '7_day_spark', '30_day_flame', 'playful_duo', 'memory_curator'],
            'total_messages_count' => 1420,
            'total_games_played' => 18,
            'total_memories_added' => 34,
            'total_goals_completed' => 7,
        ]);

        // 5. Initialize Couple Team (for battles)
        CoupleTeam::create([
            'couple_space_id' => $space->id,
            'team_name' => 'The Stargazers',
            'elo_rating' => 1480,
            'wins' => 12,
            'losses' => 3,
            'draws' => 1,
            'rank_tier' => 'Gold',
        ]);

        // 6. Sample Messages (Simulating E2EE ciphertexts & UI previews)
        $m1 = Message::create([
            'message_uuid' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'sender_id' => $alex->id,
            'type' => 'text',
            'encrypted_payload' => base64_encode('Good morning my love! Did you sleep well? ☕✨'),
            'iv' => bin2hex(random_bytes(12)),
            'mac' => bin2hex(random_bytes(16)),
            'status' => 'read',
            'delivered_at' => now()->subHours(8),
            'read_at' => now()->subHours(7),
            'created_at' => now()->subHours(8),
        ]);

        $m2 = Message::create([
            'message_uuid' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'sender_id' => $sophia->id,
            'type' => 'text',
            'encrypted_payload' => base64_encode('Morning handsome! Yes, woke up thinking about our trip next month! 🥰❤️'),
            'iv' => bin2hex(random_bytes(12)),
            'mac' => bin2hex(random_bytes(16)),
            'reply_to_message_id' => $m1->id,
            'status' => 'read',
            'delivered_at' => now()->subHours(7),
            'read_at' => now()->subHours(6),
            'created_at' => now()->subHours(7),
        ]);

        MessageReaction::create([
            'message_id' => $m2->id,
            'user_id' => $alex->id,
            'reaction' => '❤️',
        ]);

        Message::create([
            'message_uuid' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'sender_id' => $alex->id,
            'type' => 'voice',
            'encrypted_payload' => base64_encode('Encrypted voice memo audio note'),
            'iv' => bin2hex(random_bytes(12)),
            'mac' => bin2hex(random_bytes(16)),
            'metadata' => ['duration_seconds' => 14, 'waveform' => [20, 45, 80, 60, 95, 40, 70, 30, 85, 50]],
            'status' => 'read',
            'delivered_at' => now()->subHours(4),
            'read_at' => now()->subHours(3),
            'created_at' => now()->subHours(4),
        ]);

        // 7. Calendar Events & Countdowns
        CalendarEvent::create([
            'couple_space_id' => $space->id,
            'creator_id' => $alex->id,
            'title' => 'Romantic Anniversary Dinner',
            'description' => 'Table reservation at Le Petit Miroir overlooking the skyline.',
            'category' => 'anniversary',
            'color_hex' => '#E91E63',
            'start_time' => now()->addDays(12)->setTime(19, 30),
            'end_time' => now()->addDays(12)->setTime(22, 00),
            'is_countdown' => true,
            'location' => 'Le Petit Miroir, Downtown',
        ]);

        CalendarEvent::create([
            'couple_space_id' => $space->id,
            'creator_id' => $sophia->id,
            'title' => 'Weekend Flight to Kyoto',
            'description' => 'Autumn foliage and ryokan hot spring weekend.',
            'category' => 'travel',
            'color_hex' => '#9C27B0',
            'start_time' => now()->addDays(28)->setTime(8, 00),
            'is_countdown' => true,
            'location' => 'International Terminal Gate 4B',
        ]);

        // 8. Love Memories Vault
        Memory::create([
            'uuid' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'creator_id' => $alex->id,
            'title' => 'Our First Sunset in Santorini',
            'category' => 'photo',
            'album_name' => 'Greece Summer',
            'media_path' => 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
            'memory_date' => now()->subMonths(6)->toDateString(),
            'location_name' => 'Oia, Santorini',
            'is_favorite' => true,
            'tags' => ['vacation', 'sunset', 'unforgettable'],
        ]);

        Memory::create([
            'uuid' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'creator_id' => $sophia->id,
            'title' => 'A Letter for Rainy Days',
            'category' => 'letter',
            'album_name' => 'Love Letters',
            'encrypted_body' => base64_encode("My dearest Alex,\n\nWhenever the skies turn grey, remember that you are the steady warmth in my life. Every laugh we share is a treasure.\n\nForever and always,\nSophia"),
            'memory_date' => now()->subMonths(2)->toDateString(),
            'is_favorite' => true,
            'tags' => ['letter', 'deep'],
        ]);

        // 9. Couple Games
        GameSession::create([
            'session_code' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'game_type' => 'truth_or_dare',
            'mode' => '1v1_couple',
            'initiator_id' => $alex->id,
            'opponent_id' => $sophia->id,
            'game_state' => [
                'deck_category' => 'deep_connection',
                'current_card' => 'What is a small, quiet moment with me that you will never forget?',
                'card_type' => 'truth',
                'rounds_completed' => 4,
            ],
            'current_turn_user_id' => $sophia->id,
            'status' => 'in_progress',
        ]);

        GameSession::create([
            'session_code' => (string) Str::uuid(),
            'couple_space_id' => $space->id,
            'game_type' => 'chess',
            'mode' => '1v1_couple',
            'initiator_id' => $sophia->id,
            'opponent_id' => $alex->id,
            'game_state' => [
                'fen' => 'rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2',
                'last_move' => 'c7c5',
            ],
            'current_turn_user_id' => $alex->id,
            'status' => 'in_progress',
        ]);

        // 10. Shared Vision Board
        $v1 = VisionBoard::create([
            'couple_space_id' => $space->id,
            'creator_id' => $alex->id,
            'title' => 'Modern Scandinavian Home',
            'category' => 'dream_house',
            'description' => 'Bright living room with floor-to-ceiling windows and a cozy stone fireplace.',
            'cover_image_url' => 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
            'target_amount' => 120000.00,
            'current_amount' => 74500.00,
            'progress_percentage' => 62,
            'status' => 'in_progress',
            'sort_order' => 1,
        ]);

        VisionItem::create([
            'vision_board_id' => $v1->id,
            'creator_id' => $alex->id,
            'title' => 'Meet with architect for blueprint concepts',
            'type' => 'checklist',
            'is_completed' => true,
            'assigned_to_user_id' => $alex->id,
        ]);

        VisionItem::create([
            'vision_board_id' => $v1->id,
            'creator_id' => $sophia->id,
            'title' => 'Choose solar panel & sustainable insulation plan',
            'type' => 'checklist',
            'is_completed' => false,
            'assigned_to_user_id' => $sophia->id,
        ]);

        $v2 = VisionBoard::create([
            'couple_space_id' => $space->id,
            'creator_id' => $sophia->id,
            'title' => 'Japan Blossom Journey',
            'category' => 'travel',
            'description' => 'Exploring Tokyo culinary delights and Kyoto shrines.',
            'cover_image_url' => 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
            'target_amount' => 6500.00,
            'current_amount' => 5850.00,
            'progress_percentage' => 90,
            'status' => 'in_progress',
            'sort_order' => 2,
        ]);

        VisionItem::create([
            'vision_board_id' => $v2->id,
            'creator_id' => $sophia->id,
            'title' => 'Book traditional Machiya townhouse in Gion',
            'type' => 'checklist',
            'is_completed' => true,
            'assigned_to_user_id' => $sophia->id,
        ]);
    }
}
