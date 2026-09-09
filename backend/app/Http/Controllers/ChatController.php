<?php

namespace App\Http\Controllers;

use App\Models\CoupleSpace;
use App\Models\Message;
use App\Models\MessageAttachment;
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
     * Dedicated Real Voice Note Upload Endpoint
     * Stores in S3/R2 cloud storage (or public disk fallback) for persistent playback across devices.
     */
    public function uploadVoice(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $file = $request->file('voice') ?? $request->file('file') ?? $request->file('audio');
        if (!$file) {
            return response()->json([
                'status' => 'error',
                'message' => 'The voice or audio file is required.',
                'errors' => ['file' => ['Audio file is required.']]
            ], 422);
        }

        $request->validate([
            'file' => 'nullable|file|max:51200',
            'voice' => 'nullable|file|max:51200',
            'audio' => 'nullable|file|max:51200',
            'duration_seconds' => 'nullable|numeric',
        ]);

        $ext = strtolower($file->getClientOriginalExtension());
        if (empty($ext) || !in_array($ext, ['m4a', 'aac', 'wav', 'mp3', 'ogg', 'opus', 'caf'])) {
            $ext = 'm4a';
        }

        $filename = 'voice_' . Str::uuid() . '.' . $ext;
        $disk = config('filesystems.default') === 's3' ? 's3' : 'public';
        $folder = 'chat_voices/' . $user->couple_space_id;
        $path = $file->storeAs($folder, $filename, $disk);

        $url = Storage::disk($disk)->url($path);
        if (str_starts_with($url, '/')) {
            $baseUrl = rtrim(config('app.url', 'http://localhost:8000'), '/');
            $url = $baseUrl . $url;
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Voice note uploaded successfully',
            'data' => [
                'file_path' => $url,
                'storage_path' => $path,
                'disk' => $disk,
                'file_name' => $file->getClientOriginalName() ?: $filename,
                'mime_type' => $file->getClientMimeType() ?: 'audio/' . ($ext === 'm4a' ? 'mp4' : $ext),
                'file_size_bytes' => $file->getSize(),
                'duration_seconds' => (float) $request->input('duration_seconds', 0),
            ]
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
        $disk = config('filesystems.default') === 's3' ? 's3' : 'public';
        $path = $file->storeAs($folder, $filename, $disk);

        $url = Storage::disk($disk)->url($path);
        if (str_starts_with($url, '/')) {
            $baseUrl = rtrim(config('app.url', 'http://localhost:8000'), '/');
            $url = $baseUrl . $url;
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'file_path' => $url,
                'storage_path' => $path,
                'disk' => $disk,
                'folder' => $folder,
                'file_name' => $file->getClientOriginalName(),
                'mime_type' => $mime,
                'file_size_bytes' => $file->getSize(),
                'encryption_hash' => $request->input('encryption_hash'),
            ]
        ]);
    }

    /**
     * Dedicated Real Document Upload Endpoint
     * Stores in storage/app/public/chat_documents/{couple_space_id}/
     */
    public function uploadDocument(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $file = $request->file('file') ?? $request->file('document');
        if (!$file) {
            return response()->json([
                'status' => 'error',
                'message' => 'The file or document field is required.',
                'errors' => ['file' => ['The file or document field is required.']]
            ], 422);
        }

        $request->validate([
            'file' => [
                'nullable',
                'file',
                'max:51200', // max 50MB
                'mimes:pdf,doc,docx,xls,xlsx,ppt,pptx,txt,zip,rar,7z,csv,rtf,json',
            ],
            'document' => [
                'nullable',
                'file',
                'max:51200', // max 50MB
                'mimes:pdf,doc,docx,xls,xlsx,ppt,pptx,txt,zip,rar,7z,csv,rtf,json',
            ],
            'caption' => 'nullable|string|max:500',
            'encrypted_payload' => 'nullable|string',
            'iv' => 'nullable|string',
            'mac' => 'nullable|string',
        ]);
        $originalName = $file->getClientOriginalName();
        $ext = strtolower($file->getClientOriginalExtension());
        $mime = $file->getClientMimeType() ?: 'application/octet-stream';
        $sizeBytes = $file->getSize();

        // Computed human-readable size
        $formattedSize = $this->formatBytes($sizeBytes);

        // Store in couple space document directory
        $spaceFolder = "chat_documents/{$user->couple_space_id}";
        $storedFilename = Str::uuid() . '.' . $ext;
        $path = $file->storeAs($spaceFolder, $storedFilename, 'public');

        $downloadUrl = url("api/v1/chat/documents/{$storedFilename}/download");
        $fileUrl = Storage::url($path);

        // Create message
        $caption = $request->input('caption', "📄 [Document: {$originalName}]");
        $encryptedPayload = $request->input('encrypted_payload') ?: base64_encode($caption);
        $iv = $request->input('iv') ?: bin2hex(random_bytes(16));
        $mac = $request->input('mac');

        $message = Message::create([
            'couple_space_id' => $user->couple_space_id,
            'sender_id' => $user->id,
            'type' => 'document',
            'file_path' => $fileUrl,
            'original_name' => $originalName,
            'mime_type' => $mime,
            'file_size_bytes' => $sizeBytes,
            'encrypted_payload' => $encryptedPayload,
            'iv' => $iv,
            'mac' => $mac,
            'status' => 'sent',
            'metadata' => [
                'original_name' => $originalName,
                'file_name' => $originalName,
                'stored_filename' => $storedFilename,
                'file_size_bytes' => $sizeBytes,
                'file_size_formatted' => $formattedSize,
                'mime_type' => $mime,
                'extension' => $ext,
                'storage_path' => $path,
                'download_url' => $downloadUrl,
                'caption' => $caption,
            ],
        ]);

        $attachment = MessageAttachment::create([
            'message_id' => $message->id,
            'file_path' => $path,
            'file_name' => $storedFilename,
            'original_name' => $originalName,
            'mime_type' => $mime,
            'file_size_bytes' => $sizeBytes,
            'encryption_hash' => $request->input('encryption_hash'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Document uploaded successfully',
            'data' => [
                'id' => $message->id,
                'type' => 'document',
                'couple_space_id' => $message->couple_space_id,
                'sender_id' => $message->sender_id,
                'original_name' => $originalName,
                'file_name' => $storedFilename,
                'file_size_bytes' => $sizeBytes,
                'file_size_formatted' => $formattedSize,
                'mime_type' => $mime,
                'file_path' => $fileUrl,
                'download_url' => $downloadUrl,
                'metadata' => $message->metadata,
                'caption' => $caption,
                'message' => $message->load(['sender:id,name,avatar_url', 'attachments']),
                'attachment' => $attachment,
            ]
        ], 201);
    }

    /**
     * Download or stream document
     */
    public function downloadDocument(Request $request, string $identifier)
    {
        $attachment = null;
        $filePath = null;
        $originalName = null;

        // Try numeric ID first
        if (is_numeric($identifier)) {
            $attachment = MessageAttachment::find($identifier);
            if ($attachment) {
                $filePath = $attachment->file_path;
                $originalName = $attachment->original_name ?: $attachment->file_name;
            } else {
                $msg = Message::find($identifier);
                if ($msg && $msg->file_path) {
                    $originalName = $msg->original_name ?: 'document';
                    $filePath = str_replace('/storage/', '', $msg->file_path);
                }
            }
        }

        // If not found by ID, search by filename in chat_documents
        if (!$filePath) {
            $cleanName = basename($identifier);
            // Search all subdirectories in chat_documents
            $files = Storage::disk('public')->allFiles('chat_documents');
            foreach ($files as $file) {
                if (basename($file) === $cleanName) {
                    $filePath = $file;
                    $originalName = $cleanName;
                    break;
                }
            }
            // Check root documents
            if (!$filePath && Storage::disk('public')->exists("documents/{$cleanName}")) {
                $filePath = "documents/{$cleanName}";
                $originalName = $cleanName;
            }
        }

        if (!$filePath || !Storage::disk('public')->exists($filePath)) {
            return response()->json(['status' => 'error', 'message' => 'Document not found'], 404);
        }

        if ($attachment) {
            $attachment->increment('download_count');
        }

        $fullPath = Storage::disk('public')->path($filePath);
        $mimeType = mime_content_type($fullPath) ?: 'application/octet-stream';
        $downloadName = $originalName ?: basename($filePath);

        return response()->download($fullPath, $downloadName, [
            'Content-Type' => $mimeType,
            'Accept-Ranges' => 'bytes',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, HEAD, OPTIONS',
            'Access-Control-Allow-Headers' => 'Range, Origin, Content-Type, Accept',
            'Access-Control-Expose-Headers' => 'Content-Disposition, Content-Length',
        ]);
    }

    private function formatBytes(int $bytes, int $precision = 2): string
    {
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        $bytes = max($bytes, 0);
        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
        $pow = min($pow, count($units) - 1);
        $bytes /= pow(1024, $pow);
        return round($bytes, $precision) . ' ' . $units[$pow];
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
