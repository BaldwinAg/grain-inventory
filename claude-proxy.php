<?php
/**
 * GrainTrack Suite v1.7.0
 * Claude API Proxy for POY Import
 * 
 * Setup:
 * 1. Create /portal/grain/api/ folder on server
 * 2. Create config.php in same folder with:
 *    <?php define('ANTHROPIC_KEY', 'sk-ant-api03-xxxxx');
 * 3. Upload this file to /portal/grain/api/claude-proxy.php
 * 4. Test with: curl -X POST https://yourdomain.com/portal/grain/api/claude-proxy.php
 */

require_once 'config.php';

// CORS headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die(json_encode(['error' => 'Method not allowed. POST only.']));
}

// Check API key is configured
if (!defined('ANTHROPIC_KEY') || empty(ANTHROPIC_KEY)) {
    http_response_code(500);
    die(json_encode(['error' => 'API key not configured. Create config.php with ANTHROPIC_KEY.']));
}

// Get request body
$input = file_get_contents('php://input');

if (empty($input)) {
    http_response_code(400);
    die(json_encode(['error' => 'Empty request body']));
}

// Validate JSON
$decoded = json_decode($input, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    die(json_encode(['error' => 'Invalid JSON: ' . json_last_error_msg()]));
}

// Forward to Anthropic API
$ch = curl_init('https://api.anthropic.com/v1/messages');

curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $input,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT => 120,  // 2 minute timeout for large PDFs
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'x-api-key: ' . ANTHROPIC_KEY,
        'anthropic-version: 2023-06-01'
    ]
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
curl_close($ch);

// Handle curl errors
if ($curlError) {
    http_response_code(500);
    die(json_encode(['error' => 'Curl error: ' . $curlError]));
}

// Return response with same status code
http_response_code($httpCode);
echo $response;
