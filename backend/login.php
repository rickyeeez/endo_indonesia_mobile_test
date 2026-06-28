<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Method not allowed. Use POST."]);
    exit();
}

// Ambil input JSON
$input = json_decode(file_get_contents('php://input'), true);

$email = isset($input['email']) ? trim($input['email']) : '';
$password = isset($input['password']) ? trim($input['password']) : '';

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Email dan Password wajib diisi."]);
    exit();
}

try {
    // Cari user berdasarkan email
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = :email");
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        // Generate mock token (untuk keperluan tes coding)
        $token = base64_encode(random_bytes(32) . "_uid_" . $user['id']);
        
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Login berhasil.",
            "data" => [
                "token" => "mock_token_" . $token,
                "user" => [
                    "id" => $user['id'],
                    "name" => $user['name'],
                    "email" => $user['email']
                ]
            ]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(["status" => "error", "message" => "Email atau Password salah."]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Terjadi kesalahan server: " . $e->getMessage()]);
}
?>
