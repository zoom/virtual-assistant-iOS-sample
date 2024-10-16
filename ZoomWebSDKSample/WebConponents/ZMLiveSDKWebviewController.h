//
//  ZMLiveSDKWebviewController.h
//  ZoomCCSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN


static const NSString *kZMCCWebkitMessageCmdType_OpenURL_Key __attribute__((deprecated("This command has been deprecated. We recommend our developers to use the dom element like <a href=\"https://www.example.com\" target=\"_blank\">Open in New Tab</a>to open the URL in a new tab, like a WebViewController or the system Webview browser"))) = @"openURL";

#define kZMCCWebKitMessageCmdKey                @"cmd"
#define kZMCCWebkitMessageValueKey              @"value"
#define kZMCCWebkitMessageCmdType_OpenURL       kZMCCWebkitMessageCmdType_OpenURL_Key

#define kZMCCMessageHandlerName_Exit            @"zoomLiveSDKMessageHandler"
#define kZMCCMessageHandlerName_SuportHandOff   @"support_handoff"
#define kZMCCMessageHandlerName_CommonHandler   @"commonMessageHandler"

#define kZCMCCMessage_ExitCmdValue  @"close_web_vc"

@interface ZMWebviewConfiguration: WKWebViewConfiguration
- (NSArray<NSString *> *)messageHandlerNames;
@end

@interface ZMLiveSDKWebviewController : UIViewController

/*!
 @brief Indicates whether to open URLs received from the JavaScript handler "commonMessageHandler" in the system browser. YES to open in the system browser, NO to open within a new view controller in the app. Default is YES.
 
 Additionally, the command "openURL" of data format {"cmd":"openURL", "value":"https://zoom.us"} has been deprecated. We recommend our developers to use the dom element like <a href="https://www.example.com" target="_blank">Open in New Tab</a> to open the URL in a new tab, like a WebView controller or the system Webview browser. Or to use "window.open" in js context for the opening purpose. Thus the property openURLInSystemBrowser would still be used to determine the opening in the system browser or in a natvie Webview  controller.
 
 When using the dom element like <a href="https://www.example.com" target="_blank">Open in New Tab</a>, the callback method "webView:decidePolicyForNavigationAction:decisionHandler:" would be called, our developers refer to the sample code implementation.
 
 When using the "window.open()" in js context, the callback method "webView: createWebViewWithConfiguration: forNavigationAction:windowFeatures:" would be called if the callback method "webView:decidePolicyForNavigationAction:decisionHandler:" not implemented. Our developers refer to the sample code implementation.
 
 */
@property (nonatomic, assign) BOOL openURLInSystemBrowser;


/*!
 @brief Indicates whether to show an alert for messages received from the JavaScript handler "support_handoff". Default is NO.
 */
@property (nonatomic, assign) BOOL showDialogOfSupportHandoff;

/*!
 @brief Creates a ViewController instance to load the specified URL in a WKWebView. Developers can modify the JavaScript message handler if needed, such as changing the default implementation of opening URLs in the system browser.

 @param url The campaign chat URL. To obtain this URL, go to the Campaign Management tab on the campaign admin page, select a campaign, and click "Generate" in the "Full-page chat URL" section.
 @param config A subclass of WKWebViewConfiguration that handles JavaScript injection into the WKWebView. Developers should modify the implementation to pass specific parameters into the JavaScript context, such as language codes.
 @return A new instance of the view controller.
 */
- (instancetype)initWithURL:(NSString *)url webviewConfiguration:(ZMWebviewConfiguration *)config;
@end

NS_ASSUME_NONNULL_END
