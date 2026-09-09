<?php

namespace App\Http\Controllers;

use App\Models\Memory;
use App\Services\StreakService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MemoryController extends Controller
{
    public function __construct(
        protected StreakService $streakService
    ) {}

    /**
     * Get memories for the couple space.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $query = Memory::where('couple_space_id', $user->couple_space_id)
            ->with('creator:id,name,avatar_url');

        if ($request->has('category')) {
            $query->where('category', $request->input('category'));
        }

        if ($request->has('album_name')) {
            $query->where('album_name', $request->input('album_name'));
        }

        if ($request->boolean('favorites_only')) {
            $query->where('is_favorite', true);
        }

        if ($request->boolean('archived')) {
            $query->where('is_archived', true);
        } else {
            $query->where('is_archived', false);
        }

        $memories = $query->orderBy('memory_date', 'desc')->paginate(30);

        return response()->json([
            'status' => 'success',
            'data' => $memories
        ]);
    }

    /**
     * Store a new memory item.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->couple_space_id) {
            return response()->json(['status' => 'error', 'message' => 'No active couple space'], 404);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|in:photo,video,letter,text_note,voice_note,pdf_document,file',
            'album_name' => 'nullable|string|max:100',
            'encrypted_body' => 'nullable|string',
            'memory_date' => 'required|date',
            'location_name' => 'nullable|string',
            'tags' => 'nullable|array',
            'file' => 'nullable|file|max:51200',
        ]);

        $mediaPath = null;
        $fileSize = null;

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $disk = in_array(config('filesystems.default'), ['s3', 'r2']) ? config('filesystems.default') : 'public';
            $path = $file->storeAs('memories', $filename, $disk);
            $mediaPath = Storage::disk($disk)->url($path);
            if (str_starts_with($mediaPath, '/')) {
                $baseUrl = rtrim(config('app.url', 'http://localhost:8000'), '/');
                $mediaPath = $baseUrl . $mediaPath;
            }
            $fileSize = $file->getSize();
        }

        $memory = Memory::create([
            'uuid' => (string) Str::uuid(),
            'couple_space_id' => $user->couple_space_id,
            'creator_id' => $user->id,
            'title' => $validated['title'],
            'category' => $validated['category'],
            'album_name' => $validated['album_name'] ?? 'Main Memories',
            'encrypted_body' => $validated['encrypted_body'] ?? null,
            'media_path' => $mediaPath,
            'file_size_bytes' => $fileSize,
            'memory_date' => $validated['memory_date'],
            'location_name' => $validated['location_name'] ?? null,
            'tags' => $validated['tags'] ?? [],
        ]);

        $this->streakService->recordActivity($user, 'added_memory');

        return response()->json([
            'status' => 'success',
            'message' => 'Memory preserved forever in your private vault',
            'data' => $memory->load('creator:id,name,avatar_url')
        ], 201);
    }

    /**
     * Toggle favorite status.
     */
    public function toggleFavorite(Request $request, int $id): JsonResponse
    {
        $memory = Memory::where('id', $id)
            ->where('couple_space_id', $request->user()->couple_space_id)
            ->firstOrFail();

        $memory->is_favorite = !$memory->is_favorite;
        $memory->save();

        return response()->json([
            'status' => 'success',
            'data' => ['is_favorite' => $memory->is_favorite]
        ]);
    }

    /**
     * Get distinct album names for the couple space.
     */
    public function albums(Request $request): JsonResponse
    {
        $user = $request->user();
        $albums = Memory::where('couple_space_id', $user->couple_space_id)
            ->selectRaw('album_name, COUNT(*) as count, MAX(media_path) as cover_photo')
            ->groupBy('album_name')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $albums
        ]);
    }
}
