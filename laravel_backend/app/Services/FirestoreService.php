<?php

namespace App\Services;

use GuzzleHttp\Client;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Support\Facades\Cache;

class FirestoreService
{
    protected $client;
    protected $credentials;
    protected $accessToken;

    public function __construct()
    {
        $this->client = new Client();
        $this->credentials = json_decode(file_get_contents(storage_path('app/firebase/firebase_credentials.json')), true);
        $this->accessToken = $this->getAccessToken();
    }

    private function getAccessToken()
    {
        if (Cache::has('google_access_token')) {
            return Cache::get('google_access_token');
        }

        $now = time();
        $jwtPayload = [
            'iss' => $this->credentials['client_email'],
            'scope' => 'https://www.googleapis.com/auth/datastore',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ];

        $jwt = JWT::encode($jwtPayload, $this->credentials['private_key'], 'RS256');

        $response = $this->client->post('https://oauth2.googleapis.com/token', [
            'form_params' => [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ],
        ]);

        $data = json_decode($response->getBody(), true);

        // Cache for 55 minutes
        Cache::put('google_access_token', $data['access_token'], 3300);

        return $data['access_token'];
    }

    public function getDocuments($collection)
    {
        $projectId = $this->credentials['project_id'];
        $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}";

        $response = $this->client->get($url, [
            'headers' => [
                'Authorization' => "Bearer {$this->accessToken}",
            ],
        ]);

        return json_decode($response->getBody(), true);
    }

    public function createDocument($collection, $data)
    {
        $projectId = $this->credentials['project_id'];
        $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}";

        $formattedData = [
            'fields' => $this->formatFields($data),
        ];

        $response = $this->client->post($url, [
            'headers' => [
                'Authorization' => "Bearer {$this->accessToken}",
                'Content-Type' => 'application/json',
            ],
            'json' => $formattedData,
        ]);

        return json_decode($response->getBody(), true);
    }

    private function formatFields(array $data): array
    {
        $fields = [];

        foreach ($data as $key => $value) {
            if (is_string($value)) {
                $fields[$key] = ['stringValue' => $value];
            } elseif (is_int($value)) {
                $fields[$key] = ['integerValue' => $value];
            } elseif (is_bool($value)) {
                $fields[$key] = ['booleanValue' => $value];
            }
            // Add more types as needed
        }

        return $fields;
    }
}
