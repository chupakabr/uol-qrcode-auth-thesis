/**
 * QrAuthVault
 *
 * Extension code to be executed on page load plus web site authentication scripts
 *
 * 2015 (c) Valera Chevtaev
 */

chrome.extension.sendMessage({"name": "ready"}, function(response) {
	var readyStateCheckInterval = setInterval(function() {
	if (document.readyState === "complete") {
		clearInterval(readyStateCheckInterval);

		// ----------------------------------------------------------
		// This part of the script triggers when page is done loading
		console.log("Hello from QrAuthVault. This message was sent from scripts/inject.js");
		// ----------------------------------------------------------
	}
	}, 10);
});


if (typeof qrauth === "undefined") {
	qrauth = {};
}
qrauth.auth = {};

// automated authentication to Google Account
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

// extension events listener
chrome.extension.onMessage.addListener(
	function(request, sender, sendResponse) {
		console.info("hello from the other side");

		if (request.name == "qrauth.do") {
			console.info("QrAuthVault - Authenticate on Google")
			var usr = request.usr;
			var pwd = request.pwd;
			qrauth.auth.gmail(usr, pwd);
		} else if (request.name == "qrauth.fail") {
			console.info("QrAuthVault - ERROR: " + request.msg);
			// TODO Handle error by showing an alert or something like that
		} else if (request.name == "qrauth.log") {
			console.info("QrAuthVault - " + request.msg);
		}

		sendResponse();
});
