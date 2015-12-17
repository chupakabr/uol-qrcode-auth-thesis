<?php

require_once "../entry.php";

if ($_SERVER['REQUEST_METHOD'] != "PUT") {
    echo "ERR invalid HTTP method\n";
    http_response_code(405);
    exit(1);
}

// PUT data comes in on the stdin stream
$putdata = fopen("php://input", "r");

// Read the data 1 KB at a time and write to the file
$data = fgets($putdata, QA_MAX_FILE_SIZE);
fclose($putdata);
$info = explode(":", $data);
$cnt = count($info);
if ($cnt != 4) {
    echo "ERR malformed input ($cnt): [$data]\n";
    http_response_code(400);
    exit(2);
}

// Open a file for writing.
// Normalize file name: only characters plus a dot.
$id = QA_normalize_id($info[0]);
$timestamp = $info[1];
$clientPubKey = $info[2];
$credentials = $info[3];

if (!QA_valid_id($id)) {
    echo "ERR invalid ID: [$id]\n";
    http_response_code(400);
    exit(3);
}

$filepath = QA_filepath_by_id($id);
$fp = fopen($filepath, "w");

fwrite($fp, "$timestamp:$clientPubKey:$credentials", QA_MAX_FILE_SIZE);
fclose($fp);

http_response_code(200);
