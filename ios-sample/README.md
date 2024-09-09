## Zoom Virtual Agent Web SDK for iOS Sample App
This README provides guidance on integrating the Zoom Virtual Agent Web SDK for iOS, handling JavaScript callbacks, passing environment parameters, managing WebView scenarios, and processing download requests.

### Prerequisites
- iOS 14.5 or later
- Xcode
- Basic knowledge of Swift or Objective-C

### Setup Instructions

Clone the sample app repository from GitHub to your local machine, then open the project in Xcode.

### Configure the App
Before running the app, you need to configure it with the required parameters.


#### 1.Generate Campaign Chat URL

  1. Navigate to the Campaign Management tab on the [contact center management page](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0058248).
  
  2. Select a campaign, go to the settings tab, and find the "Full-page chat URL" section.
  
  3. Click "Generate" to create the URL.

#### 2. Integration Overview
To integrate on iOS, support essential JavaScript functions in the `WKWebViewConfiguration` and handle JavaScript native callback events in the `WebViewController`.

#### 3. How to Integrate

You can either:
- Use the core code provided in this document and integrate it into your project.
- Utilize the provided sample project on GitHub, available in both Objective-C and Swift.

Example Classes:
- Objective-C: `ZMLiveSDKWebviewController.m`
- Swift: `ZMLiveSDKWebviewControllerSwift.swift`

#### 4. Handle JavaScript Events
##### Inject Environment Parameters
```swift

let userContentController = WKUserContentController()
let webviewConfig = WKWebViewConfiguration()
webviewConfig.userContentController = userContentController

let injectScriptStr = """
window.zoomCampaignSdkConfig = window.zoomCampaignSdkConfig || {
    language: 'en-US',
    firstName: 'John',
    lastName: 'Doe',
    nickName: 'Johnny',
    address: '123 Zoom St.',
    company: 'Zoom',
    email: 'john.doe@zoom.us',
    phoneNumber: '1234567890'
};
"""
let injectScript = WKUserScript(source: injectScriptStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
userContentController.addUserScript(injectScript)
```

##### Handle Exit Callback Functions
```swift
let exitHandlerScriptStr = """
window.addEventListener('zoomCampaignSdk:ready', () => {
    if (window.zoomCampaignSdk) {
        window.zoomCampaignSdk.native = {
            exitHandler: {
                handle: function() {
                    window.webkit.messageHandlers.zoomLiveSDKMessageHandler.postMessage('close_web_vc');
                }
            },
            commonHandler: {
                handle: function(e) {
                    window.webkit.messageHandlers.commonMessageHandler.postMessage(JSON.stringify(e));
                }
            }
        }
    }
})
"""

let exitScript = WKUserScript(source: exitHandlerScriptStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
userContentController.addUserScript(exitScript)

```

##### Handle Handoff Events

```swift
let supportHandoffScriptStr = """
window.addEventListener('support_handoff', (e) => {
    window.webkit.messageHandlers.support_handoff.postMessage(JSON.stringify(e.detail));
});
"""
let supportHandoffScript = WKUserScript(source: supportHandoffScriptStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
userContentController.addUserScript(supportHandoffScript)

```

#### 5. Integration Scenarios
- **Scenario 1: Embed Custom Website in WebView** Embed a customer's website in the iOS WebView with links utilizing the ZVA WebSDK. Since JavaScript callback events are handled by the customer’s website, no additional native code is needed on iOS.
- **Scenario 2: Trigger WebView from Native Button** Trigger native events to open the WebView displaying the Web Chat window. In this scenario, native code needs to handle JavaScript events received from the WebView.



#### 6. Common Cases under Scenario 2
- **Case 1: Close Web Chat View** Handle the callback event in WebViewController and close the current native web view window.
- **Case 2: Pass Native Parameters to Web Chat** Pass parameters from the native app to the WebView context when opening a chat window.
- **Case 3: Open URL in the Current WebView (In-App)** Handle navigation actions within the current WebView.
- **Case 4: Open URL in System Browser** Open URLs from the WebView in the system browser (Safari).
- **Case 5: Open URL in SFSafariViewController (In-App)** Use SFSafariViewController to open URLs within the app.
- **Case 6: Dispatch Support Handoff Event** Use JavaScript's handoff event to pass data from the web to the iOS native app.


For a detailed integration guide, please refer to the [Zoom Virtual Agent Web SDK Documentation](https://developers.zoom.us/docs/virtual-agent/web/).
