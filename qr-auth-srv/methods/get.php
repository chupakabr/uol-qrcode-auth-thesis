<?php

// TODO Better to use Nginx instead

require_once "../entry.php";

if ($_SERVER['REQUEST_METHOD'] != "GET") {
    echo "ERR invalid HTTP method\n";
    http_response_code(405);
    exit(1);
}

// Normalize file name: only characters plus a dot
$id = QA_normalize_id($_GET["id"]);
if (!QA_valid_id($id)) {
    echo "ERR invalid ID: [$id]\n";
    http_response_code(400);
    exit(2);
}

$filepath = QA_filepath_by_id($id);
if (file_exists($filepath)) {
    $input = fopen($filepath, "r");

    // Read the data 1 KB at a time and write to the file
    while ($data = fread($input, QA_MAX_FILE_SIZE)) {
        echo $data;
    }
    fclose($input);
    echo "\n";

    http_response_code(200);
} else {
    http_response_code(404);
}
