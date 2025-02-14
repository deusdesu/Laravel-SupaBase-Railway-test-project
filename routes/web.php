<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\NameController;


Route::get('/', [NameController::class, 'index']);
Route::post('/save', [NameController::class, 'store']);




