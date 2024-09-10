//
//  ZMWebDemoHomeViewController.m
//  ZoomWebSDKSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import "ZMWebDemoHomeViewController.h"
#import "ZMWebDemoViewController.h"
#import "ZMLiveSDKWebviewController.h"

@interface ZMWebDemoHomeViewController () <ZMCCContainerViewDelegate>
@end

@implementation ZMWebDemoHomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZVA Web SDK Sample";
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - ZMCCContainerViewDelegate
- (NSArray *)buttonConfigs {
    NSMutableArray *array = [NSMutableArray array];
    ZMButtonConfig *config = [ZMButtonConfig new];
    config.title = @"Scenario 1: Embed Custom Website in WebView";
    config.selector = @selector(openSenario_1:);
    config.btnURLStr = @"https://zoom.us/";
    [array addObject:config];
    
    ZMButtonConfig *config2 = [ZMButtonConfig new];
    config2.title = @"Scenario 2: Trigger WebView from Native Button";
    config2.selector = @selector(openSenario_2_demo_pages:);
    config2.fontSize = 15;
    [array  addObject:config2];
    
    return array;
}

- (void)openSenario_1:(NSString *)url {
    ZMWebviewConfiguration *config = [[ZMWebviewConfiguration alloc] init];
    ZMLiveSDKWebviewController *vc = [[ZMLiveSDKWebviewController alloc] initWithURL:url webviewConfiguration:config];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openSenario_2_demo_pages:(NSString *)url {
    ZMWebDemoViewController *vc = [[ZMWebDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
