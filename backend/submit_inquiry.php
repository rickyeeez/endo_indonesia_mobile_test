<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Method not allowed. Use POST."]);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

$name = isset($input['name']) ? trim($input['name']) : '';
$hospital_name = isset($input['hospital_name']) ? trim($input['hospital_name']) : '';
$email = isset($input['email']) ? trim($input['email']) : '';
$items = isset($input['items']) ? $input['items'] : [];

// Validasi input
if (empty($name) || empty($hospital_name) || empty($email)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Nama, Nama Rumah Sakit, dan Email wajib diisi."]);
    exit();
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Format email tidak valid."]);
    exit();
}

if (empty($items) || !is_array($items)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Daftar alat medis penawaran tidak boleh kosong."]);
    exit();
}

try {
    $pdo->beginTransaction();

    // 1. Simpan Data Inquiry Utama
    $stmt = $pdo->prepare("INSERT INTO inquiries (name, hospital_name, email) VALUES (:name, :hospital_name, :email)");
    $stmt->execute([
        'name' => $name,
        'hospital_name' => $hospital_name,
        'email' => $email
    ]);
    
    $inquiryId = $pdo->lastInsertId();

    // 2. Simpan Detail Item Inquiry & Kurangi Stok Alat Medis
    $stmtItem = $pdo->prepare("INSERT INTO inquiry_items (inquiry_id, device_id, quantity, price) VALUES (:inquiry_id, :device_id, :quantity, :price)");
    $stmtUpdateStock = $pdo->prepare("UPDATE medical_devices SET stock = stock - :quantity WHERE id = :device_id AND stock >= :quantity");

    foreach ($items as $item) {
        $deviceId = isset($item['device_id']) ? (int)$item['device_id'] : 0;
        $quantity = isset($item['quantity']) ? (int)$item['quantity'] : 0;
        $price = isset($item['price']) ? (float)$item['price'] : 0.0;

        if ($deviceId <= 0 || $quantity <= 0) {
            throw new Exception("ID Alat Medis atau Kuantitas tidak valid.");
        }

        // Cek stok alat medis terlebih dahulu
        $stmtCheck = $pdo->prepare("SELECT stock, name FROM medical_devices WHERE id = :id");
        $stmtCheck->execute(['id' => $deviceId]);
        $device = $stmtCheck->fetch();

        if (!$device) {
            throw new Exception("Alat medis dengan ID $deviceId tidak ditemukan.");
        }

        if ($device['stock'] < $quantity) {
            throw new Exception("Stok untuk '" . $device['name'] . "' tidak mencukupi (Tersisa: " . $device['stock'] . ").");
        }

        // Simpan ke inquiry_items
        $stmtItem->execute([
            'inquiry_id' => $inquiryId,
            'device_id' => $deviceId,
            'quantity' => $quantity,
            'price' => $price
        ]);

        // Kurangi stok di tabel medical_devices
        $stmtUpdateStock->execute([
            'quantity' => $quantity,
            'device_id' => $deviceId
        ]);
        
        if ($stmtUpdateStock->rowCount() === 0) {
            throw new Exception("Gagal memperbarui stok untuk '" . $device['name'] . "'. Mungkin stok habis.");
        }
    }

    $pdo->commit();

    http_response_code(201);
    echo json_encode([
        "status" => "success",
        "message" => "Permintaan penawaran berhasil diajukan dengan ID: $inquiryId.",
        "data" => [
            "inquiry_id" => $inquiryId
        ]
    ]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Gagal mengirim penawaran: " . $e->getMessage()]);
}
?>
