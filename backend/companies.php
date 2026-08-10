<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'];
$raw = file_get_contents('php://input');
$input = json_decode($raw ?: '{}', true) ?: $_REQUEST;

try {
    if ($method === 'GET') {
        $rows = [];
        try {
            if ($GLOBALS['db_type'] === 'mysqli') {
                $res = $GLOBALS['conn']->query("SELECT * FROM companies ORDER BY id DESC");
                if ($res) {
                    while ($r = $res->fetch_assoc()) $rows[] = $r;
                }
            } elseif ($GLOBALS['db_type'] === 'sqlite') {
                $stmt = $GLOBALS['pdo']->query("SELECT * FROM companies ORDER BY id DESC");
                if ($stmt) {
                    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                }
            }
        } catch (Throwable $e) {}

        if (empty($rows)) {
            $rows = get_json_data($GLOBALS['companies_json']);
        }
        echo json_encode(["status" => "success", "data" => $rows]);
        exit();
    }

    if ($method === 'POST') {
        $action = $input['action'] ?? 'create';

        // Toggle active status
        if ($action === 'toggle' || isset($input['toggle_id'])) {
            $id = (int)($input['id'] ?? $input['toggle_id']);
            $is_active = (int)($input['is_active'] ?? 0);

            try {
                if ($GLOBALS['db_type'] === 'mysqli') {
                    $stmt = $GLOBALS['conn']->prepare("UPDATE companies SET is_active = ? WHERE id = ?");
                    if ($stmt) {
                        $stmt->bind_param("ii", $is_active, $id);
                        $stmt->execute();
                    }
                } elseif ($GLOBALS['db_type'] === 'sqlite') {
                    $stmt = $GLOBALS['pdo']->prepare("UPDATE companies SET is_active = ? WHERE id = ?");
                    if ($stmt) {
                        $stmt->execute([$is_active, $id]);
                    }
                }
            } catch (Throwable $e) {}

            // Always update JSON data as well for bulletproof persistence
            $list = get_json_data($GLOBALS['companies_json']);
            foreach ($list as &$item) {
                if ((int)$item['id'] === $id) {
                    $item['is_active'] = $is_active;
                }
            }
            save_json_data($GLOBALS['companies_json'], $list);

            echo json_encode([
                "status" => "success",
                "message" => "Company status updated to " . ($is_active ? "Active" : "Inactive"),
                "is_active" => $is_active
            ]);
            exit();
        }

        // Edit Company
        if ($action === 'update' && !empty($input['id'])) {
            $id = (int)$input['id'];
            $name = trim($input['name'] ?? '');
            $phone = trim($input['phone'] ?? '');
            $email = trim($input['email'] ?? '');
            $address = trim($input['address'] ?? '');
            $admin_username = trim($input['admin_username'] ?? 'admin');
            $admin_password = trim($input['admin_password'] ?? 'admin123');
            $is_active = (int)($input['is_active'] ?? 1);

            try {
                if ($GLOBALS['db_type'] === 'mysqli') {
                    $stmt = $GLOBALS['conn']->prepare("UPDATE companies SET name = ?, phone = ?, email = ?, address = ?, admin_username = ?, admin_password = ?, is_active = ? WHERE id = ?");
                    if ($stmt) {
                        $stmt->bind_param("ssssssii", $name, $phone, $email, $address, $admin_username, $admin_password, $is_active, $id);
                        $stmt->execute();
                    }
                } elseif ($GLOBALS['db_type'] === 'sqlite') {
                    $stmt = $GLOBALS['pdo']->prepare("UPDATE companies SET name = ?, phone = ?, email = ?, address = ?, admin_username = ?, admin_password = ?, is_active = ? WHERE id = ?");
                    if ($stmt) {
                        $stmt->execute([$name, $phone, $email, $address, $admin_username, $admin_password, $is_active, $id]);
                    }
                }
            } catch (Throwable $e) {}

            $list = get_json_data($GLOBALS['companies_json']);
            foreach ($list as &$item) {
                if ((int)$item['id'] === $id) {
                    $item['name'] = $name;
                    $item['phone'] = $phone;
                    $item['email'] = $email;
                    $item['address'] = $address;
                    $item['admin_username'] = $admin_username;
                    $item['admin_password'] = $admin_password;
                    $item['is_active'] = $is_active;
                }
            }
            save_json_data($GLOBALS['companies_json'], $list);

            echo json_encode(["status" => "success", "message" => "Company updated successfully"]);
            exit();
        }

        // Delete Company
        if ($action === 'delete' || !empty($input['delete_id'])) {
            $id = (int)($input['id'] ?? $input['delete_id']);

            try {
                if ($GLOBALS['db_type'] === 'mysqli') {
                    $stmt = $GLOBALS['conn']->prepare("DELETE FROM companies WHERE id = ?");
                    if ($stmt) {
                        $stmt->bind_param("i", $id);
                        $stmt->execute();
                    }
                } elseif ($GLOBALS['db_type'] === 'sqlite') {
                    $stmt = $GLOBALS['pdo']->prepare("DELETE FROM companies WHERE id = ?");
                    if ($stmt) {
                        $stmt->execute([$id]);
                    }
                }
            } catch (Throwable $e) {}

            $list = get_json_data($GLOBALS['companies_json']);
            $list = array_filter($list, function($item) use ($id) {
                return (int)$item['id'] !== $id;
            });
            save_json_data($GLOBALS['companies_json'], $list);

            echo json_encode(["status" => "success", "message" => "Company deleted"]);
            exit();
        }

        // Add New Company
        $name = trim($input['name'] ?? '');
        $phone = trim($input['phone'] ?? '');
        $email = trim($input['email'] ?? '');
        $address = trim($input['address'] ?? '');
        $admin_username = trim($input['admin_username'] ?? 'admin');
        $admin_password = trim($input['admin_password'] ?? 'admin123');
        $is_active = (int)($input['is_active'] ?? 1);

        if (empty($name)) {
            echo json_encode(["status" => "error", "message" => "Company name is required"]);
            exit();
        }

        $new_id = time();
        try {
            if ($GLOBALS['db_type'] === 'mysqli') {
                $stmt = $GLOBALS['conn']->prepare("INSERT INTO companies (name, phone, email, address, admin_username, admin_password, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)");
                if ($stmt) {
                    $stmt->bind_param("ssssssi", $name, $phone, $email, $address, $admin_username, $admin_password, $is_active);
                    $stmt->execute();
                    if ($stmt->insert_id) $new_id = $stmt->insert_id;
                }
            } elseif ($GLOBALS['db_type'] === 'sqlite') {
                $stmt = $GLOBALS['pdo']->prepare("INSERT INTO companies (name, phone, email, address, admin_username, admin_password, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)");
                if ($stmt) {
                    $stmt->execute([$name, $phone, $email, $address, $admin_username, $admin_password, $is_active]);
                    $lastId = $GLOBALS['pdo']->lastInsertId();
                    if ($lastId) $new_id = (int)$lastId;
                }
            }
        } catch (Throwable $e) {}

        $list = get_json_data($GLOBALS['companies_json']);
        $list[] = [
            "id" => $new_id,
            "name" => $name,
            "phone" => $phone,
            "email" => $email,
            "address" => $address,
            "admin_username" => $admin_username,
            "admin_password" => $admin_password,
            "is_active" => $is_active,
            "created_at" => date('Y-m-d H:i:s')
        ];
        save_json_data($GLOBALS['companies_json'], $list);

        echo json_encode([
            "status" => "success",
            "message" => "Company created successfully",
            "id" => $new_id
        ]);
        exit();
    }
} catch (Throwable $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
