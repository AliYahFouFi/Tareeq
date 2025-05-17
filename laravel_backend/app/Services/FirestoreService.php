<?php

namespace App\Services;

use GuzzleHttp\Client;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Support\Facades\Cache;
use DateTime;

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

    /**
     * Gets all documents in a Firestore collection.
     *
     * @param string $collection
     * @return array
     */
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

    /**
     * Retrieves a specific document from a Firestore collection by its ID.
     *
     * @param string $collection The name of the Firestore collection.
     * @param string $documentId The ID of the document to retrieve.
     * @return array The document data as an associative array.
     */

    public function getDocument($collection, $documentId)
    {
        $projectId = $this->credentials['project_id'];
        $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}/{$documentId}";

        $response = $this->client->get($url, [
            'headers' => [
                'Authorization' => "Bearer {$this->accessToken}",
            ],
        ]);

        return json_decode($response->getBody(), true);
    }

    /**
     * Updates a specific document in a Firestore collection.
     *
     * @param string $collection The name of the Firestore collection.
     * @param string $documentId The ID of the document to update.
     * @param array  $data       The data to update, as an associative array.
     * @return array The updated document data as an associative array.
     */
    public function updateDocument($collection, $documentId, $data)
    {
        $projectId = $this->credentials['project_id'];
        $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}/{$documentId}?currentDocument.exists=true";

        $formattedData = [
            'fields' => $this->formatFields($data),
        ];

        $response = $this->client->patch($url, [
            'headers' => [
                'Authorization' => "Bearer {$this->accessToken}",
                'Content-Type' => 'application/json',
            ],
            'json' => $formattedData,
        ]);

        return json_decode($response->getBody(), true);
    }
    /**
     * Delete a document from a Firestore collection.
     *
     * @param string $collection The collection ID
     * @param string $documentId The document ID
     * @return bool Whether the request was successful
     */

    public function deleteDocument($collection, $documentId)
    {
        $projectId = $this->credentials['project_id'];
        $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}/{$documentId}";

        $response = $this->client->delete($url, [
            'headers' => [
                'Authorization' => "Bearer {$this->accessToken}",
            ],
        ]);

        return $response->getStatusCode() === 200 || $response->getStatusCode() === 204;
    }



    /**
     * Creates a document in a Firestore collection.
     *
     * @param string $collection
     * @param array $data
     * @return array
     */
    public function createDocument($collection, $data, $documentId = null)
    {
        $projectId = $this->credentials['project_id'];

        if ($documentId) {
            // Use document ID in the URL to create document with custom ID
            $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}/{$documentId}";
            $method = 'patch'; // or 'put' — patch is recommended to create or update
        } else {
            // Auto-generated ID
            $url = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents/{$collection}";
            $method = 'post';
        }

        $formattedData = [
            'fields' => $this->formatFields($data),
        ];

        $response = $this->client->{$method}($url, [
            'headers' => [
                'Authorization' => "Bearer {$this->accessToken}",
                'Content-Type' => 'application/json',
            ],
            'json' => $formattedData,
        ]);

        return json_decode($response->getBody(), true);
    }



    /**
     * Format the given data into a Firestore compatible format.
     *
     * Supported types are:
     * - string
     * - int
     * - bool
     *
     * @param array $data
     * @return array
     */
    private function formatFields(array $data): array
    {
        $fields = [];

        foreach ($data as $key => $value) {
            if (is_string($value)) {
                // Check for valid timestamp format
                if (strtotime($value) !== false && preg_match('/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/', $value)) {
                    $fields[$key] = ['timestampValue' => $value];
                } else {
                    $fields[$key] = ['stringValue' => $value];
                }
            } elseif (is_int($value)) {
                $fields[$key] = ['integerValue' => $value];
            } elseif (is_float($value)) {
                $fields[$key] = ['doubleValue' => $value];
            } elseif (is_bool($value)) {
                $fields[$key] = ['booleanValue' => $value];
            } elseif ($value instanceof \DateTime) {
                $fields[$key] = ['timestampValue' => $value->format(DateTime::ATOM)];
            }
            // Add array/map support if needed
        }

        return $fields;
    }
}
