<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Name;

class NameController extends Controller
{
    public function index()
{
    $latestName = Name::latest()->first();
    
    return view('welcome', ['latestName' => $latestName]);
}

public function store(Request $request)
{
    $request->validate(['name' => 'required|string|max:255']);
    Name::create(['name' => $request->name]);
    return redirect('/');
}
}
