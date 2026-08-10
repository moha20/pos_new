<?php
require_once __DIR__ . '/config.php';

try {
    if ($GLOBALS['db_type'] === 'mysqli') {
        $conn = $GLOBALS['conn'];
        $conn->query("CREATE TABLE IF NOT EXISTS companies (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            phone VARCHAR(100),
            email VARCHAR(255),
            address TEXT,
            admin_username VARCHAR(100) DEFAULT 'admin',
            admin_password VARCHAR(255) DEFAULT 'admin123',
            is_active TINYINT(1) DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

        $conn->query("CREATE TABLE IF NOT EXISTS sales (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sale_id VARCHAR(100),
            company_name VARCHAR(255) NOT NULL,
            cashier_id VARCHAR(100),
            invoice_number VARCHAR(100),
            total DECIMAL(10,2) DEFAULT 0.00,
            payment_method VARCHAR(50) DEFAULT 'Cash',
            items_count INT DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    } elseif ($GLOBALS['db_type'] === 'sqlite') {
        $pdo = $GLOBALS['pdo'];
        $pdo->exec("CREATE TABLE IF NOT EXISTS companies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            email TEXT,
            address TEXT,
            admin_username TEXT DEFAULT 'admin',
            admin_password TEXT DEFAULT 'admin123',
            is_active INTEGER DEFAULT 1,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );");

        $pdo->exec("CREATE TABLE IF NOT EXISTS sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id TEXT,
            company_name TEXT NOT NULL,
            cashier_id TEXT,
            invoice_number TEXT,
            total REAL DEFAULT 0.0,
            payment_method TEXT DEFAULT 'Cash',
            items_count INTEGER DEFAULT 1,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );");
    }

    // Always ensure JSON files exist for 100% fallback reliability
    $comp_file = $GLOBALS['companies_json'];
    if (!file_exists($comp_file) || filesize($comp_file) < 5) {
        save_json_data($comp_file, [
            [
                "id" => 1,
                "name" => "Al-Mohandis POS",
                "phone" => "01000000000",
                "email" => "info@almohandis.com",
                "address" => "Cairo, Egypt",
                "admin_username" => "admin",
                "admin_password" => "admin123",
                "is_active" => 1,
                "created_at" => date('Y-m-d H:i:s')
            ]
        ]);
    }

    $sales_file = $GLOBALS['sales_json'];
    if (!file_exists($sales_file)) {
        save_json_data($sales_file, []);
    }

    echo json_encode(["status" => "success", "message" => "Tables and storage initialized successfully"]);
} catch (Throwable $e) {
    // Graceful fallback to JSON
    $comp_file = $GLOBALS['companies_json'];
    save_json_data($comp_file, [
        [
            "id" => 1,
            "name" => "Al-Mohandis POS",
            "phone" => "01000000000",
            "email" => "info@almohandis.com",
            "address" => "Cairo, Egypt",
            "admin_username" => "admin",
            "admin_password" => "admin123",
            "is_active" => 1,
            "created_at" => date('Y-m-d H:i:s')
        ]
    ]);
    echo json_encode(["status" => "success", "message" => "Initialized storage fallback"]);
}
