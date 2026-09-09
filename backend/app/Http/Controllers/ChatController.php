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
     * Edit an existing message (client re-encrypts updated payload).
     */
    public function edit(Request $request, int $id): JsonResponse
    {
        $message = Message::where('id', $id)
            ->where('sender_id', $request->user()->id)
            ->firstOrFail();

        $validated = $request->validate([
            'encrypted_payload' => 'required|string',
            'iv' => 'required|string',
            'mac' => 'nullable|string',
        ]);

        $message->update([
            'encrypted_payload' => $validated['encrypted_payload'],
            'iv' => $validated['iv'],
            'mac' => $validated['mac'] ?? null,
            'is_edited' => true,
            'edited_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Message edited',
            'data' => $message
        ]);
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
     * Get all pinned messages in the couple space.
     */
    public function pinned(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $pinned = Message::where('couple_space_id', $user->couple_space_id)
            ->where('is_pinned', true)
            ->with(['sender:id,name,avatar_url', 'reactions'])
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $pinned
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
            'file' => 'required|file|max:102400', // max 100MB
            'encryption_hash' => 'nullable|string',
            'type' => 'nullable|in:voice,document,image,video,photo,pdf',
        ]);

        $file = $request->file('file');
        $ext = strtolower($file->getClientOriginalExtension());
        $mime = $file->getClientMimeType();

        // Determine destination folder
        $folder = 'documents';
        if (str_starts_with($mime, 'audio/') || in_array($ext, ['m4a', 'aac', 'mp3', 'ogg', 'wav', 'opus'])) {
            $folder = 'voices';
        } elseif (str_starts_with($mime, 'image/') || in_array($ext, ['jpg', 'jpeg', 'png', 'webp', 'heic', 'gif'])) {
            $folder = 'images';
        } elseif (str_starts_with($mime, 'video/') || in_array($ext, ['mp4', 'mov', 'avi', 'mkv', 'webm'])) {
            $folder = 'videos';
        }

        $filename = Str::uuid() . '.' . $ext;
        $path = $file->storeAs($folder, $filename, 'public');

        return response()->json([
            'status' => 'success',
            'data' => [
                'file_path' => Storage::url($path),
                'storage_path' => $path,
                'folder' => $folder,
                'file_name' => $file->getClientOriginalName(),
                'mime_type' => $mime,
                'file_size_bytes' => $file->getSize(),
                'encryption_hash' => $request->input('encryption_hash'),
            ]
        ]);
    }

    /**
     * Stream voice note or audio file with Byte-Range & MIME headers
     */
    public function streamAudio(string $filename)
    {
        $filename = basename($filename);
        $path = "voices/{$filename}";

        if (!Storage::disk('public')->exists($path)) {
            if (Storage::disk('public')->exists($filename)) {
                $path = $filename;
            } else {
                return response()->json(['status' => 'error', 'message' => 'Audio file not found'], 404);
            }
        }

        $fullPath = Storage::disk('public')->path($path);
        $fileSize = filesize($fullPath);
        $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
        $mimeType = match ($ext) {
            'wav' => 'audio/wav',
            'mp3' => 'audio/mpeg',
            'm4a' => 'audio/mp4',
            'aac' => 'audio/aac',
            'ogg' => 'audio/ogg',
            'opus' => 'audio/opus',
            default => 'audio/wav',
        };

        return response()->file($fullPath, [
            'Content-Type' => $mimeType,
            'Content-Length' => $fileSize,
            'Accept-Ranges' => 'bytes',
            'Cache-Control' => 'public, max-age=86400',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, HEAD, OPTIONS',
            'Access-Control-Allow-Headers' => 'Range, Origin, Content-Type, Accept',
        ]);
    }
}
