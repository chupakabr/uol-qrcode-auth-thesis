/**
 * QrAuthVault
 *
 * Extension background scripts
 *
 * 2015 (c) Valera Chevtaev
 */
// if you checked "fancy-settings" in extensionizr.com, uncomment this lines

// var settings = new Store("settings", {
//     "sample_setting": "This is how you use Store.js to remember values"
// });


//example of using a message handler from the inject scripts

//chrome.pageAction.onClicked.addListener(function(tab) {
//    alert("hi from page action");
//    console.info("hi from page action");
//});

// extension events listener
chrome.extension.onMessage.addListener(
  function(request, sender, sendResponse) {

      if (request.name == "ready") {
          // display action_page icon in address bar if page is ready
          chrome.pageAction.show(sender.tab.id);
      } else if (request.name == "page_action.open") {
          // nothing
      }

      sendResponse();
});
