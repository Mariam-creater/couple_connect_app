<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('couple.{spaceId}', function ($user, $spaceId) {
    return (int) $user->couple_space_id === (int) $spaceId;
});

Broadcast::channel('user.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});
