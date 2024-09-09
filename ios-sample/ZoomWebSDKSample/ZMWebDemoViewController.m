//
//  ZMWebDemoViewController.m
//  ZoomWebSDKSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import "ZMWebDemoViewController.h"
#import "ZMDemoButton.h"
#import "ZMLiveSDKWebviewController.h"

@interface ZMWebDemoViewController () <ZMCCContainerViewDelegate>
@end

@implementation ZMWebDemoViewController
- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scenario 2";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - ZMCCContainerViewDelegate

- (NSArray *)buttonConfigs {
    NSMutableArray *array = [NSMutableArray array];
    ZMButtonConfig *config = [ZMButtonConfig new];
    config.title = @"Case 1: Close Web Chat View";
    config.selector = @selector(openCampaignChatDemoPage_closeChat:);
    config.btnURLStr = @"https://us01ccistatic.zoom.us/us01cci/web-sdk/full-page.html?env=us01&apikey=2s-_NB4IRTe1RWqaDMX5YA&fullScreenId=lWU6-1rZS46r8vopyOERLA";
    [array  addObject:config];
    
    ZMButtonConfig *config2 = [ZMButtonConfig new];
    config2.title = @"Case 2: Pass Native Parameters to Web Chat";
    config2.selector = @selector(openCampaignChatDemoPage_bringParamsToWebChat:);
    config2.btnURLStr = @"https://us01ccistatic.zoom.us/us01cci/web-sdk/full-page.html?env=us01&apikey=2s-_NB4IRTe1RWqaDMX5YA&fullScreenId=GNtDFL20SyCjalmZM4uliA";
    [array  addObject:config2];
    
    
    ZMButtonConfig *config3 = [ZMButtonConfig new];
    config3.title = @"Case 3: Open URL in WebView (In-App)";
    config3.selector = @selector(openCampaignChatDemoPage_openLinkInWebView:);
    config3.btnURLStr = @"https://us01ccistatic.zoom.us/us01cci/web-sdk/full-page.html?env=us01&apikey=2s-_NB4IRTe1RWqaDMX5YA&fullScreenId=xG9m3LZBQP26z-t9IbL6nA";
    [array  addObject:config3];
    
    
    ZMButtonConfig *config4 = [ZMButtonConfig new];
    config4.title = @"Case 4: Open URL in System Browser";
    config4.selector = @selector(openCampaignChatDemoPage_openLinkInBrowser:);
    config4.btnURLStr = @"https://us01ccistatic.zoom.us/us01cci/web-sdk/full-page.html?env=us01&apikey=2s-_NB4IRTe1RWqaDMX5YA&fullScreenId=eknpIJrDQx6zHQ6blOFK4A";
    [array addObject:config4];
    
    
    ZMButtonConfig *config5 = [ZMButtonConfig new];
    config5.title = @"Case 5: Open URL in SFSafariViewController (In-App)";
    config5.selector = @selector(openCampaignChatDemoPage_openLinkInSeperateViewController:);
    config5.btnURLStr = @"https://us01ccistatic.zoom.us/us01cci/web-sdk/full-page.html?env=us01&apikey=2s-_NB4IRTe1RWqaDMX5YA&fullScreenId=j-tZRfa1S_K0XFjgjB461w";
    [array  addObject:config5];
    
    
    ZMButtonConfig *config6 = [ZMButtonConfig new];
    config6.title = @"Case 6: Dispatch Support Handoff Event";
    config6.selector = @selector(openCampaignChatDemoPage_supportHandOffEvent:);
    config6.btnURLStr = @"https://us01ccistatic.zoom.us/us01cci/web-sdk/full-page.html?env=us01&apikey=2s-_NB4IRTe1RWqaDMX5YA&fullScreenId=VvjAbXM2TxCIal_jY41AtA";
    [array  addObject:config6];
    
    return array;
}


// This case demonstrates when the close button in the WebView is clicked, the JS message will be received by the native method "userContentController: didReceiveScriptMessage:" in the ZMLiveSDKWebviewController class. The native logic will then pop the current WebViewController.
- (void)openCampaignChatDemoPage_closeChat:(NSString *)url {
    /**
     Firstly, create a ZMWebviewConfiguration instance. This is a subclass of WKWebViewConfiguration, Innerly it process the javascript injection into the WKWebview. Developers should modify the implementation code to pass specific params into the javascript context, like language code and so on if needed.
     
     The param url  is a campaign chat url. In campaing admin page,  go to Campain Management tab, select a campagin, in the settings tab, there is a "Full-page chat URL" tab, clicke the right button "Generate", there would be a url generated.
     
     Then ceate a ZMLiveSDKWebviewController instance which is subclass of UIViewController. It has a WKWebView to load the url innerly. We will use this instance to display the web page.
     
     Also developers can copy the  files ZMLiveSDKWebviewController.h and ZMLiveSDKWebviewController.m to their project for usage. While made some realization change if needed.
     */
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    [self.navigationController pushViewController:vc animated:YES];
}

// This case demonstrates when the close button in the WebView is clicked, the JS message will be received by the native method "userContentController: didReceiveScriptMessage:" in the ZMLiveSDKWebviewController class. The native logic will then pop the current WebViewController.
- (void)openCampaignChatDemoPage_bringParamsToWebChat:(NSString *)url {
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    [self.navigationController pushViewController:vc animated:YES];
}


// This case demonstrates when the WebView will open a URL internally.
- (void)openCampaignChatDemoPage_openLinkInWebView:(NSString *)url {
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    [self.navigationController pushViewController:vc animated:YES];
}

// This case demonstrates when the WebView notifies native logic to open a URL. The JS message will be received by the native method "userContentController: didReceiveScriptMessage:" in the ZMLiveSDKWebviewController class. The native logic will handle the "cmd" JSON to handle the URL opening. Since openURLInSystemBrowser is set to YES, the inner logic in ZMLiveSDKWebviewController will open it in the browser.
- (void)openCampaignChatDemoPage_openLinkInBrowser:(NSString *)url {
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    
    //When openURLInSystemBrowser set to YES, and when received openURL command from js, we will open the URL in system browser.
    vc.openURLInSystemBrowser = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// This case demonstrates when the WebView notifies native logic to open a URL. The JS message will be received by the native method "userContentController: didReceiveScriptMessage:" in the ZMLiveSDKWebviewController class. The native logic will handle the "cmd" JSON to handle the URL opening. Since openURLInSystemBrowser is set to NO, the inner logic in ZMLiveSDKWebviewController will open it in a new WebViewController like SFSafariViewController.
- (void)openCampaignChatDemoPage_openLinkInSeperateViewController:(NSString *)url {
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    //When openURLInSystemBrowser set to NO, and when received openURL command from js, we will open the URL in a new created WebViewController like SFSafariviewController.
    vc.openURLInSystemBrowser = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

// This case demonstrates when the WebView transmits data via a JS message handler to native logic. The JS handler is called "support_handoff".
- (void)openCampaignChatDemoPage_supportHandOffEvent:(NSString *)url {
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    vc.showDialogOfSupportHandoff = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

