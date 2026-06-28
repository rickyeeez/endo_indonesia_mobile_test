<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Method not allowed. Use GET."]);
    exit();
}

// Simulasikan error acak (20% probabilitas gagal) untuk melatih penanganan error kandidat
if (isset($_GET['simulate_error']) && $_GET['simulate_error'] === 'true') {
    // Dipicu secara manual jika dikirim parameter simulate_error=true
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Internal Server Error (Simulated via param)"]);
    exit();
}

// Atau secara acak (1 dari 5 kali gagal)
if (rand(1, 5) === 5) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Server ENDO Indonesia sedang sibuk (Internal Server Error 500)"]);
    exit();
}

try {
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    
    if (!empty($search)) {
        $stmt = $pdo->prepare("SELECT * FROM medical_devices WHERE name LIKE :search OR category LIKE :search");
        $stmt->execute(['search' => "%$search%"]);
    } else {
        $stmt = $pdo->query("SELECT * FROM medical_devices");
    }
    
    $devices = $stmt->fetchAll();
    
    // Parse specifications JSON
    foreach ($devices as &$device) {
        if (!empty($device['specifications'])) {
            $device['specifications'] = json_decode($device['specifications'], true);
        } else {
            $device['specifications'] = new stdClass();
        }
        // Pastikan tipe data price dan stock sesuai
        $device['price'] = (float)$device['price'];
        $device['stock'] = (int)$device['stock'];
        $device['id'] = (string)$device['id']; // Kembalikan ID sebagai string agar selaras dengan model Dart
    }
    
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "data" => $devices
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
}
?>
