<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'status' => 'online',
        'platform' => 'Couple Connect API Backend',
        'environment' => app()->environment(),
        'version' => '1.0.0',
        'health_check' => url('/api/v1/health'),
    ]);
});
