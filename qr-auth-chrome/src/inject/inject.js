chrome.extension.sendMessage({"name": "ready"}, function(response) {
	var readyStateCheckInterval = setInterval(function() {
	if (document.readyState === "complete") {
		clearInterval(readyStateCheckInterval);

		// ----------------------------------------------------------
		// This part of the script triggers when page is done loading
		console.log("Hello from QrVault. This message was sent from scripts/inject.js");
		// ----------------------------------------------------------
	}
	}, 10);
});


qrauth = {};
qrauth.auth = {};

// TODO move this kind of authorization steps to a server to be delivered on auth request
// TODO replace hardcoded delay with JS wait for an input field to appear
qrauth.auth.gmail = function(usr, pwd) {
	// enter username and press next button
	$('input[type="email"]').val(usr);
	$('input#next').delay(1000).click();

	// wait for 2 seconds and then enter password and proceed
	setTimeout(function() {
		$('input[type="password"]').val(pwd);
		$('input#signIn').delay(1000).click();
	}, 2000);
};

console.info("kukunya!");
chrome.extension.onMessage.addListener(
	function(request, sender, sendResponse) {
		console.info("hello from the other side");

		if (request.name == "qrauth.do") {
			var usr = request.usr;
			var pwd = request.pwd;
			qrauth.auth.gmail(usr, pwd);
		}

		sendResponse();
});
