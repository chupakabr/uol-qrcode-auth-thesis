<?php

define(QA_UPLOAD_PATH, "/mnt/qrvault");
define(QA_FILE_EXT, ".txt");
define(QA_MAX_FILE_SIZE, 512);
define(QA_ID_LEN, 16);

function QA_gen_fileid() {
    $randomFilename = "" . microtime(true) . "_" . QA_generateRandomString();
    return $randomFilename;
}

function QA_filepath_by_id($id) {
    // TODO Split files into directories, i.e. for id="ffacbcef1142acbde" directory path should be "ff/ac/bc/ef/1142acbde"
    // TODO Check file name: only characters plus a dot
    return QA_UPLOAD_PATH . "/" . $id . QA_FILE_EXT;
}

function QA_generateRandomString($length = QA_ID_LEN) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; ++$i) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function QA_normalize_id($id) {
    $id = preg_replace("/[^0-9_\-a-zA-Z]/", "", $id);
    return $id;
}

function QA_valid_id($id) {
    if (strlen($id) < QA_ID_LEN) {
        return false;
    }
    // TODO double preg_match check
    return true;
}
