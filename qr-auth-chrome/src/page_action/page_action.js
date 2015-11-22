
chrome.extension.sendMessage({"name": "page_action.open"}, function(response) {
    // Generate QR code
    new QRCode(document.getElementById("qrcode"), {
        text: '{"url":"https://gmail.com", "ts":' + Date.now() + '}',
        width: 128,
        height: 128,
        colorDark : "#000000",
        colorLight : "#ffffff",
        correctLevel : QRCode.CorrectLevel.H
    });

    // Poll for https://www.dropbox.com/sh/ghdeuyu92y389jh/AAC8MXQwaOzB0CkVxL8Xt3_Ja?dl=0


});


