<?php

namespace App\Http\Controllers;

use App\Services\FirestoreService;

class TestFirestoreController extends Controller
{
    public function index(FirestoreService $firestore)
    {
        $docs = $firestore->getDocuments('busses');
        return response()->json($docs);
    }

    public function store(FirestoreService $firestore)
    {
        $data = [
            'name' => 'Ali Yahfouf',
            'age' => 23,
            'verified' => true,
        ];

        $doc = $firestore->createDocument('testCollection', $data);
        return response()->json($doc);
    }
}
