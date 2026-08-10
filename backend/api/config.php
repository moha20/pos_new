<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database Credentials for Hostinger
$db_host = "localhost";
$db_user = getenv('DB_USER') ?: "u257760927_posuser";
$db_pass = getenv('DB_PASS') ?: "PosDbPassword2026!";
$db_name = getenv('DB_NAME') ?: "u257760927_posdb";

$GLOBALS['db_type'] = 'json';

// Try MySQL connection
try {
    $conn = @new mysqli($db_host, $db_user, $db_pass, $db_name);
    if ($conn && !$conn->connect_error) {
        $conn->set_charset("utf8mb4");
        $GLOBALS['db_type'] = 'mysqli';
        $GLOBALS['conn'] = $conn;
    }
} catch (Throwable $e) {}

// Fallback to SQLite
if ($GLOBALS['db_type'] !== 'mysqli') {
    try {
        if (class_exists('PDO') && in_array('sqlite', PDO::getAvailableDrivers())) {
            $sqlite_file = __DIR__ . '/pos_database.db';
            $pdo = new PDO("sqlite:" . $sqlite_file);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $GLOBALS['db_type'] = 'sqlite';
            $GLOBALS['pdo'] = $pdo;
        }
    } catch (Throwable $e) {}
}

// JSON Fallback storage files
$GLOBALS['companies_json'] = __DIR__ . '/companies_data.json';
$GLOBALS['sales_json'] = __DIR__ . '/sales_data.json';

function get_json_data($file) {
    if (!file_exists($file)) return [];
    $content = file_get_contents($file);
    return json_decode($content, true) ?: [];
}

function save_json_data($file, $data) {
    file_put_contents($file, json_encode(array_values($data), JSON_PRETTY_PRINT));
}
