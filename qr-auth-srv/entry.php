<?php

define(QA_UPLOAD_PATH, "/tmp");
define(QA_FILE_EXT, ".txt");
define(QA_MAX_FILE_SIZE, 1024);

function QA_gen_fileid() {
    $randomFilename = "" . microtime(true) . "_" . QA_generateRandomString();
    return $randomFilename;
}

function QA_filepath_by_id($id) {
    // TODO Check file name: only characters plus a dot
    return QA_UPLOAD_PATH . "/" . $id . QA_FILE_EXT;
}

function QA_generateRandomString($length = 16) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; ++$i) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function QA_normalize_id($id) {
    $id = reg_replace("/[^0-9_\-\.a-zA-Z]/", "", $id);
    return $id;
}
