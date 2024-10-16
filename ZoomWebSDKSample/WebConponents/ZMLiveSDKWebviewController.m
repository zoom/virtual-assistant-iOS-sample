//
//  ZMLiveSDKWebviewController.m
//  ZoomCCSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import "ZMLiveSDKWebviewController.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>

@interface ZMWebviewConfiguration()
@end

@implementation ZMWebviewConfiguration
- (instancetype)init {
    if (self = [super init]) {
        [self addUserScripts];
    }
    return self;
}

- (void)addUserScripts {
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    // Firstly, create a WKUserScript to pass default parameters for the web SDK. Developers can modify the parameters here.
    NSString * injectScriptStr = @"window.zoomCampaignSdkConfig = window.zoomCampaignSdkConfig || { "
    "language : '',"  // user language
    "firstName: 'ZVA Demo TestName',"  // user first name
    "lastName: '',"   // user first name
    "nickName: '',"   // user nick name
    "address: '',"    // user address
    "company: '',"    // user company
    "email : 'zva.demo@zoom.us',"     // user email
    "phoneNumber : ''};"; // user phonenumber
    WKUserScript *injectScript = [[WKUserScript alloc] initWithSource:injectScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:injectScript];
    
    /*
    Create an exit message handler to handle the case where the JavaScript context needs to pop to the previous page in the host app.
    Also, create a common message handler to handle commands from the JavaScript context. The command message will be a JSON formatted string containing keys "cmd" and "value". Both key values are strings. The value can be a simple string or a JSON string, depending on the command type. Currently, we support one command in JSON format like {"cmd":"openURL", "value":"https://zoom.us"}. When such a message is received, developers should open a new view controller to load the URL in the value "https://zoom.us". The demo code shows several ways to process the message in the WKWebView delegate method: - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message.
     
     Additionally, the command "openURL" of data format {"cmd":"openURL", "value":"https://zoom.us"} has been deprecated. We recommend our developers to use the dom element like <a href=\"https://www.example.com\" target=\"_blank\">Open in New Tab</a> to open the URL in a new tab, like a WebView controller or the system Webview browser. Or to use "window.open" in js context for the opening purpose. Thus the exitHandlerScriptStr could be like below:
     
     NSString *exitHandlerScriptStr =
     @"window.addEventListener('zoomCampaignSdk:ready', () => {"
       "if (window.zoomCampaignSdk) { "
         "window.zoomCampaignSdk.native = {"
           "exitHandler: {"
             "handle: function() {"
               "window.webkit.messageHandlers.zoomLiveSDKMessageHandler.postMessage('close_web_vc');"
             "}"
           "},"
         "}"
       "}"
     "})";
     */
    
    NSString *exitHandlerScriptStr =
    @"window.addEventListener('zoomCampaignSdk:ready', () => {"
      "if (window.zoomCampaignSdk) { "
        "window.zoomCampaignSdk.native = {"
          "exitHandler: {"
            "handle: function() {"
              "window.webkit.messageHandlers.zoomLiveSDKMessageHandler.postMessage('close_web_vc');"
            "}"
          "},"
          "commonHandler: {"
            "handle: function(e) {"
              "window.webkit.messageHandlers.commonMessageHandler.postMessage(JSON.stringify(e));"
            "}"
          "}"
        "}"
      "}"
    "})";
    
    WKUserScript *exitScript = [[WKUserScript alloc] initWithSource:exitHandlerScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [userContentController addUserScript:exitScript];
    
    // This WKUserScript creates a message handler called "support_handoff" to handle messages from the JavaScript context that should be handled by the host app.
    NSString *supportHandoffScriptStr =
    @"window.addEventListener('support_handoff', (e) => {"
         "window.webkit.messageHandlers.support_handoff.postMessage(JSON.stringify(e.detail));"
    "});";
    WKUserScript *supportHandoffScript = [[WKUserScript alloc] initWithSource:supportHandoffScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false];
    [userContentController addUserScript:supportHandoffScript];
    self.userContentController = userContentController;
}

- (NSArray<NSString *> *)messageHandlerNames {
    return @[kZMCCMessageHandlerName_Exit, kZMCCMessageHandlerName_SuportHandOff, kZMCCMessageHandlerName_CommonHandler];
}
@end


@interface ZMLiveSDKWebviewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,WKDownloadDelegate>
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) ZMWebviewConfiguration *config;
@property (nonatomic, strong) NSURL *localFileDownloadURL;

@end


@implementation ZMLiveSDKWebviewController
- (instancetype)initWithURL:(NSString *)url webviewConfiguration:(ZMWebviewConfiguration *)config
 {
    if (self = [super init]) {
        _url = url;
        _config = config;
        _openURLInSystemBrowser = YES;
        [self configWebViewMessageHandlers];
    }
    return self;
}

- (void)configWebViewMessageHandlers {
    for (NSString *messageHandlerName in [self.config messageHandlerNames]) {
        [self.config.userContentController addScriptMessageHandler:self name: messageHandlerName];
    }
}

- (void)removeWebViewMessageHandlers {
    for (NSString *messageHandlerName in [self.config messageHandlerNames]) {
        [self.config.userContentController removeScriptMessageHandlerForName:messageHandlerName];
    }
}

- (void)dealloc {
    NSLog(@"ZMLiveSDKWebviewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self addNavigationBar];
    [self loadURL];
}

- (void)addNavigationBar {
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.navigationController.navigationBar.bounds.size.height)];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(handleGoBack)];
    navItem.leftBarButtonItem = backButton;
    [navBar setItems:@[navItem] animated:NO];
    [self.view addSubview:navBar];
    [self.view bringSubviewToFront:navBar];
}

- (void)handleGoBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    else {
        __weak typeof(self) wself = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Leave Current Page?" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Canel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [wself removeWebViewMessageHandlers];
            [wself.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.webView.frame = CGRectMake(0, 84, self.view.frame.size.width, self.view.bounds.size.height - 84);
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:_config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    }
    return _webView;
}

- (void)loadURL {
    NSURL *targetURL = [NSURL URLWithString:self.url];
    if (targetURL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:targetURL]];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}


- (void)webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navigationAction didBecomeDownload:(WKDownload *)download API_AVAILABLE(macos(11.3), ios(14.5))
{
    // Set the download delegate to receive callbacks when the download is finished.
    if (download) {
        download.delegate = self;
    }
}

//When logic "windown.open" excuted in js context, this callback will be recevied.
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.request.URL) {
        if (self.openURLInSystemBrowser) {
            if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
                NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly:@NO};
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:options completionHandler:nil];
            }
            else {
                NSLog(@"error, cannot open the navigationAction url");
            }
        }
        else {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:navigationAction.request.URL];
            [self.navigationController presentViewController:safariVC animated:YES completion:nil];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler
{
    // The download action only supports iOS 14.5+.
    if (@available(iOS 14.5, *)) {
        if (navigationAction.shouldPerformDownload) {
            decisionHandler(WKNavigationActionPolicyDownload);
            return;
        }
    }
    
    // For specific URLS, like the URL with scheme "tel", as the WKWebview has no default process logic, here we need to hanlde it ourselves. We should judge the scheme is not "https" and not "http" firstly, then use system method to handle URL.
    NSString *urlScheme = [navigationAction.request.URL.scheme lowercaseString];
    if (urlScheme.length 
        && (![urlScheme isEqualToString:@"https"] && ![urlScheme isEqualToString:@"http"]) && [[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
        NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly:@NO};
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:options completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // Developers can choose to process the navigation by the URL. For example, if the URL is https://zoom.us, developers can choose to open it in Safari or handle it in the current WKWebView by calling the block "decisionHandler(WKNavigationActionPolicyAllow)". This depends on the developer's requirements.
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly:@NO};
        if (navigationAction.targetFrame && navigationAction.targetFrame.isMainFrame) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        else {
            /**
             A dom element like <a href=\"https://www.example.com\" target=\"_blank\">Open in New Tab</a>  would trigger the callback to go into this logic branch. And if the openURLInSystemBrowser been set to YES, we should open it in the system Webview controller. Or if set to NO, we should open it in a new ViewController in the current App. Or to use "window.open" in js context for the opening purpose.
             */
            if (self.openURLInSystemBrowser) {
                NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly:@NO};
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:options completionHandler:nil];
            }
            else {
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:navigationAction.request.URL];
                [self.navigationController presentViewController:safariVC animated:YES completion:nil];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    else {
        decisionHandler(YES);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark -
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:kZMCCMessageHandlerName_Exit]) {
        if ([message.body isEqualToString:kZCMCCMessage_ExitCmdValue]) {
            // Handle the current webview controller's pop action
            [self removeWebViewMessageHandlers];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }
    else if ([message.name isEqualToString:kZMCCMessageHandlerName_CommonHandler]) {
        // Handle the openURL command. Developers should open a new UIViewController to load the URL within the value, or open the URL in Safari.
        if (((NSString *)message.body).length) {
            NSDictionary *dic = nil;
            NSString *messageBody = message.body;
            @try {
                dic = [NSJSONSerialization JSONObjectWithData:[messageBody dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            } @catch (NSException *exception) {
            } @finally {
            }
            if (dic) {
                NSString *cmd = dic[kZMCCWebKitMessageCmdKey];
                /**
                 This command has been deprecated. We recommend our developers to use the dom element like <a href=\"https://www.example.com\" target=\"_blank\">Open in New Tab</a>to open the URL in a new tab, like a WebViewController or the system Webview browser. Or to use "window.open" in js context for the opening purpose.
                 */
                if ([cmd isEqualToString:kZMCCWebkitMessageCmdType_OpenURL]) {
                    NSString *url = dic[kZMCCWebkitMessageValueKey];
                    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (url.length) {
                        NSURL *theURL = [NSURL URLWithString:url];
                        if (theURL && [[UIApplication sharedApplication] canOpenURL:theURL]) {
                            if (self.openURLInSystemBrowser) {
                                // Choose to open the URL with the system default web browser (Safari)
                                NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly:@NO};
                                [[UIApplication sharedApplication] openURL:theURL options:options completionHandler:^(BOOL success) {
                                }];
                            }
                            else {
                                // Or use SFSafariViewController to open the URL
                                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
                                
                                [self.navigationController presentViewController:safariVC animated:YES completion:nil];
                                // Or just open it with another webview like below
                                /*
                                ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
                                ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
                                [self.navigationController pushViewController:vc animated:YES];
                                 */
                            }
                        }
                    }
                }
            }
        }
    }
    else if ([message.name isEqualToString:kZMCCMessageHandlerName_SuportHandOff]) {
        // Handle the support_handoff command. For this event, the JavaScript context will archive all the messages into a JSON string, and post the JSON string to native logic via message.body. Developers should handle the JSON string as needed.
        NSLog(@"%@", message.body);
        if (self.showDialogOfSupportHandoff) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Support handoff message body"  message:message.body preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
    }
}


#pragma mark - WKDownload delegate
- (void)download:(WKDownload *)download decideDestinationUsingResponse:(NSURLResponse *)response suggestedFilename:(NSString *)suggestedFilename completionHandler:(void (^)(NSURL * _Nullable destination))completionHandler API_AVAILABLE(ios(14.5));
{
    // Create a local file download directory and the file path in that directory.
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    NSURL *tmpDirURL = [NSURL fileURLWithPath:tmpDir];
    NSURL *tmpUUIDURL = [tmpDirURL URLByAppendingPathComponent:uuidStr];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:tmpUUIDURL withIntermediateDirectories:NO attributes:nil error:&error]) {
        NSLog(@"creating directory failed: %@", error.localizedDescription);
        completionHandler(nil);
        return;
    }
    self.localFileDownloadURL = [tmpUUIDURL URLByAppendingPathComponent:suggestedFilename];
    completionHandler(self.localFileDownloadURL);
}

- (void)downloadDidFinish:(WKDownload *)download  API_AVAILABLE(ios(14.5)){
    dispatch_async(dispatch_get_main_queue(), ^{
        // When the file is downloaded, use the UIActivityViewController to open it for the next step usage.
        if (!self.localFileDownloadURL) {
            return;
        }
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.localFileDownloadURL] applicationActivities:nil];
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = self.view.frame;
        activityVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
        [self presentViewController:activityVC animated:YES completion:nil];
    });

}

- (void)download:(WKDownload *)download didFailWithError:(NSError *)error resumeData:(nullable NSData *)resumeData
API_AVAILABLE(ios(14.5)){
    NSLog(@"wkwebview download failed");

}

@end
