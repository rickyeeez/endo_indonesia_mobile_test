<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Method not allowed. Use GET."]);
    exit();
}

http_response_code(200);
echo json_encode([
    "status" => "success",
    "message" => "Server is running.",
    "data" => [
        "timestamp" => date('c'),
        "version" => "1.0.0"
    ]
]);
?>