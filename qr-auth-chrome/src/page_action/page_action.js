qrauth = {};
qrauth.auth = {};
qrauth.waiting = false;

// TODO move this kind of authorization steps to a server to be delivered on auth request
// TODO replace hardcoded delay with JS wait for an input field to appear
qrauth.auth.gmail = function(usr, pwd) {
    // enter username and press next button
    $('input[type="email"]').val(usr);
    $('input[id="next"]').click();

    // wait for 2 seconds and then enter password and proceed
    setTimeout(function() {
        $('input[type="password"]').val(pwd);
        $('input[id="signIn"]').click();
    }, 2000);
};

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

    // Poll for http://qrauth.chupakabr.ru/methods/get.php?id=123
    qrauth.waiting = true;
    (function authFilePolling() {
        $.ajax({
            url: "https://qrauth.chupakabr.ru/methods/get.php?id="+id,
            type: "GET",
            //data: {id: id},
            success: function(data, statusText, jqXHR) {
                qrauth.waiting = false;

                alert("response: " + statusText);
                alert("success - data: " + data);
                if (data) {
                    var info = data.split(':', 3);
                    if (info && info.length == 3) {
                        var ts = info[0];
                        var usr = info[1];
                        var pwd = info[2];
                        alert("ts=" + ts + ", user=" + usr + ", pwd=" + pwd);

                        // authorize on gmail.com
                        qrauth.auth.gmail(usr, pwd);

                        return;
                    }
                }

                // Something went wrong?
                alert("invalid data from the server");
            },
        }).done(function(data, statusText, jqXHR) {
            alert("done");
            if (qrauth.waiting) {
                setTimeout(authFilePolling, 5000);
            }
        });
    })();
});
