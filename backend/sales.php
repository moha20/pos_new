<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'];
$raw = file_get_contents('php://input');
$input = json_decode($raw ?: '{}', true) ?: $_REQUEST;

try {
    if ($method === 'GET') {
        $filter_company = trim($_GET['company'] ?? '');
        $sales = [];

        if ($GLOBALS['db_type'] === 'mysqli') {
            $sql = "SELECT * FROM sales ORDER BY id DESC LIMIT 500";
            if (!empty($filter_company) && $filter_company !== 'All') {
                $sql = "SELECT * FROM sales WHERE LOWER(company_name) = LOWER('" . $GLOBALS['conn']->real_escape_string($filter_company) . "') ORDER BY id DESC LIMIT 500";
            }
            $res = $GLOBALS['conn']->query($sql);
            if ($res) {
                while ($row = $res->fetch_assoc()) $sales[] = $row;
            }
        } elseif ($GLOBALS['db_type'] === 'sqlite') {
            $sql = "SELECT * FROM sales ORDER BY id DESC LIMIT 500";
            if (!empty($filter_company) && $filter_company !== 'All') {
                $stmt = $GLOBALS['pdo']->prepare("SELECT * FROM sales WHERE LOWER(company_name) = LOWER(?) ORDER BY id DESC LIMIT 500");
                $stmt->execute([$filter_company]);
                $sales = $stmt->fetchAll(PDO::FETCH_ASSOC);
            } else {
                $stmt = $GLOBALS['pdo']->query($sql);
                $sales = $stmt->fetchAll(PDO::FETCH_ASSOC);
            }
        } else {
            $sales = get_json_data($GLOBALS['sales_json']);
            if (!empty($filter_company) && $filter_company !== 'All') {
                $sales = array_filter($sales, function($s) use ($filter_company) {
                    return strtolower($s['company_name'] ?? '') === strtolower($filter_company);
                });
            }
        }

        echo json_encode(["status" => "success", "data" => array_values($sales)]);
        exit();
    }

    if ($method === 'POST') {
        $company_name = trim($input['companyName'] ?? $input['company_name'] ?? 'Al-Mohandis POS');
        $cashier_id = trim($input['cashierId'] ?? $input['cashier_id'] ?? 'admin');
        $invoice_number = trim($input['invoiceNumber'] ?? $input['invoice_number'] ?? '');
        $total = (float)($input['total'] ?? 0);
        $payment_method = trim($input['paymentMethod'] ?? $input['payment_method'] ?? 'Cash');
        $items_count = (int)($input['itemsCount'] ?? $input['items_count'] ?? 1);
        $sale_id = trim($input['id'] ?? '');

        if (empty($invoice_number)) {
            echo json_encode(["status" => "error", "message" => "Invoice number is required"]);
            exit();
        }

        if ($GLOBALS['db_type'] === 'mysqli') {
            $stmt = $GLOBALS['conn']->prepare("INSERT INTO sales (sale_id, company_name, cashier_id, invoice_number, total, payment_method, items_count, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");
            $stmt->bind_param("ssssdsi", $sale_id, $company_name, $cashier_id, $invoice_number, $total, $payment_method, $items_count);
            $stmt->execute();
        } elseif ($GLOBALS['db_type'] === 'sqlite') {
            $stmt = $GLOBALS['pdo']->prepare("INSERT INTO sales (sale_id, company_name, cashier_id, invoice_number, total, payment_method, items_count, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))");
            $stmt->execute([$sale_id, $company_name, $cashier_id, $invoice_number, $total, $payment_method, $items_count]);
        } else {
            $sales = get_json_data($GLOBALS['sales_json']);
            array_unshift($sales, [
                "id" => time(),
                "sale_id" => $sale_id,
                "company_name" => $company_name,
                "cashier_id" => $cashier_id,
                "invoice_number" => $invoice_number,
                "total" => $total,
                "payment_method" => $payment_method,
                "items_count" => $items_count,
                "created_at" => date('Y-m-d H:i:s')
            ]);
            if (count($sales) > 500) array_pop($sales);
            save_json_data($GLOBALS['sales_json'], $sales);
        }

        echo json_encode(["status" => "success", "message" => "Sale uploaded online successfully"]);
        exit();
    }
} catch (Throwable $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
