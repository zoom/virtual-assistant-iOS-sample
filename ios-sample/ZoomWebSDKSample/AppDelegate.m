//
//  AppDelegate.m
//  ZoomWebSDKSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import "AppDelegate.h"
#import "ZMWebDemoHomeViewController.h"

@interface AppDelegate ()
@property (nonatomic, weak) ZMWebDemoHomeViewController *rootVC;
@end

@interface ZoomNavigationController : UINavigationController

@end

@implementation ZoomNavigationController

- (BOOL)shouldAutorotate;
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[self topViewController] respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [[self topViewController] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ZMWebDemoHomeViewController *rootVC = [ZMWebDemoHomeViewController new];
    ZoomNavigationController *nav = [[ZoomNavigationController alloc] initWithRootViewController:rootVC];
    self.rootVC = rootVC;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end
