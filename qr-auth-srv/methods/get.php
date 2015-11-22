<?php

// TODO Better to use Nginx instead

require_once "../entry.php";

if ($_SERVER['REQUEST_METHOD'] != "GET") {
    echo "ERR invalid HTTP method\n";
    exit(1);
}

// TODO Check file name: only characters plus a dot
$id = $_GET["id"];
$filepath = QA_filepath_by_id($id);

$input = fopen($filepath, "r");

// Read the data 1 KB at a time and write to the file
while ($data = fread($input, QA_MAX_FILE_SIZE)) {
    echo $data;
}
fclose($input);
echo "\n";

