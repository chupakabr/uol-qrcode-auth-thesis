qrauth = {};
qrauth.retry = {};
qrauth.retry.cur = 0;
qrauth.retry.limit = 5; // TODO increase
qrauth.retry.millis = 3000;
qrauth.waiting = false;

qrauth.replacePattern = function(pattern) {
    var possibleC = "qwertyuiopasdfghjklzxcvbnm";
    var possibleV = "1234567890QWERTYUIOPASDFGHJKLZXCVBNM";

    var pIndex = pattern.length;
    var res = new Array(pIndex);
    while (pIndex--) {
        res[pIndex] = pattern[pIndex]
          .replace(/v/,randomCharacter(possibleV))
          .replace(/c/,randomCharacter(possibleC));
    }

    function randomCharacter(bucket) {
        var res = bucket.charAt(Math.floor(Math.random() * bucket.length));
        return res;
    }
    return res.join("").toLowerCase();
};

qrauth.md5 = function(str) {
    return $.md5(str);
};

chrome.extension.sendMessage({"name": "page_action.open"}, function(response) {
    // Generate QR code
    var seq = qrauth.replacePattern("ccvvccvcvcvcccvv"); // 16 chars
    var now = Date.now();
    var id = qrauth.md5(seq + now);
    new QRCode(document.getElementById("qrcode"), {
        text: '{"url":"https://gmail.com", "ts":' + now + ',"seq":"' + now + '"}',
        width: 128,
        height: 128,
        colorDark : "#000000",
        colorLight : "#ffffff",
        correctLevel : QRCode.CorrectLevel.H
    });

    console.info("requested with seq="+seq+", ts="+now+", id="+id);

    // Only if not running yet
    if (qrauth.waiting) {
        return;
    }

    $("#status").text("");

    // Poll for http://qrauth.chupakabr.ru/methods/get.php?id=123
    qrauth.retry.cur = qrauth.retry.limit;
    qrauth.waiting = true;
    (function authFilePolling() {
        //id = "asdasdasd"; // TODO debug only, remove this line later
        $.ajax({
            url: "https://chupakabr.ru/extra-test-qr-api/methods/get.php?id="+id,
            cache: false,
            type: "GET",
            success: function(data, statusText, jqXHR) {
                qrauth.waiting = false;

                console.info("response: " + statusText);
                console.info("success - data: " + data);
                if (data) {
                    var info = data.split(':', 3);
                    if (info && info.length == 3) {
                        var ts = info[0];
                        var usr = info[1];
                        var pwd = info[2];
                        console.info("ts=" + ts + ", user=" + usr + ", pwd=" + pwd);

                        // authorize on gmail.com
                        chrome.tabs.query({active: true, currentWindow: true}, function(tabs){
                            chrome.tabs.sendMessage(
                                tabs[0].id,
                                {
                                    "name": "qrauth.do",
                                    "usr": usr,
                                    "pwd": pwd,
                                },
                                function(response) {
                                    chrome.extension.sendMessage({"name": "qrauth.fail", msg: ""});
                                });
                        });

                        return;
                    }
                }

                // Something went wrong?
                console.info("invalid data from the server");
                chrome.extension.sendMessage({"name": "qrauth.fail", "msg": "Server error"});
            },
            error: function(data) {
                if (qrauth.retry.cur-- > 0) {
                    setTimeout(authFilePolling, qrauth.retry.millis);
                } else {
                    qrauth.waiting = false;
                    console.info("error!");
                    chrome.extension.sendMessage({"name": "qrauth.fail", "msg": "Please check your QrVault app for valid credentials"});
                }
            },
        }).done(function(data, statusText, jqXHR) {
            console.info("done");
        });
    })();
});

chrome.extension.onMessage.addListener(
    function(request, sender, sendResponse) {

        if (request.name == "qrauth.fail") {
            $("#status").text(request.msg);
        } else if (request.name == "qrauth.done") {
            $("#status").text("");
        }

        sendResponse();
});
