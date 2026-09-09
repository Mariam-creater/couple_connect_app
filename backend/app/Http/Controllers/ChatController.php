<?php

namespace App\Http\Controllers;

use App\Models\CoupleSpace;
use App\Models\Message;
use App\Services\ChatService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ChatController extends Controller
{
    public function __construct(
        protected ChatService $chatService
    ) {}

    /**
     * Get paginated chat messages for the couple space.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $space = CoupleSpace::findOrFail($user->couple_space_id);
        $perPage = (int) $request->input('per_page', 40);
        $messages = $this->chatService->getMessages($space, $perPage);

        return response()->json([
            'status' => 'success',
            'data' => $messages
        ]);
    }

    /**
     * Send an end-to-end encrypted message.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $validated = $request->validate([
            'message_uuid' => 'nullable|uuid',
            'type' => 'required|in:text,photo,video,voice,document,location,gif,game_invite',
            'encrypted_payload' => 'required|string',
            'iv' => 'required|string',
            'mac' => 'nullable|string',
            'reply_to_message_id' => 'nullable|exists:messages,id',
            'metadata' => 'nullable|array',
            'attachments' => 'nullable|array',
        ]);

        $message = $this->chatService->sendMessage($user, $validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Message sent',
            'data' => $message
        ], 201);
    }

    /**
     * Toggle a reaction on a message.
     */
    public function react(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'reaction' => 'required|string|max:16',
        ]);

        $message = Message::findOrFail($id);
        $reaction = $this->chatService->toggleReaction($message, $request->user(), $validated['reaction']);

        return response()->json([
            'status' => 'success',
            'data' => $reaction
        ]);
    }

    /**
     * Mark all incoming messages as read.
     */
    public function markRead(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $space = CoupleSpace::findOrFail($user->couple_space_id);
        $updatedCount = $this->chatService->markAsRead($space, $user);

        return response()->json([
            'status' => 'success',
            'message' => "{$updatedCount} messages marked as read"
        ]);
    }

    /**
     * Toggle pinned state of a message.
     */
    public function togglePin(Request $request, int $id): JsonResponse
    {
        $message = Message::findOrFail($id);
        $isPinned = $this->chatService->togglePin($message);

        return response()->json([
            'status' => 'success',
            'message' => $isPinned ? 'Message pinned' : 'Message unpinned',
            'data' => ['is_pinned' => $isPinned]
        ]);
    }

    /**
     * Delete message (soft delete for everyone).
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $message = Message::where('id', $id)
            ->where('sender_id', $request->user()->id)
            ->firstOrFail();

        $message->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Message deleted for everyone'
        ]);
    }

    /**
     * Upload an encrypted attachment (photo, voice note, document, video).
     */
    public function uploadAttachment(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|max:51200', // max 50MB
            'encryption_hash' => 'nullable|string',
        ]);

        $file = $request->file('file');
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs('attachments', $filename, 'public');

        return response()->json([
            'status' => 'success',
            'data' => [
                'file_path' => Storage::url($path),
                'file_name' => $file->getClientOriginalName(),
                'mime_type' => $file->getClientMimeType(),
                'file_size_bytes' => $file->getSize(),
                'encryption_hash' => $request->input('encryption_hash'),
            ]
        ]);
    }
}
