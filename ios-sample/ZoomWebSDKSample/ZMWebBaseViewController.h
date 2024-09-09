//
//  ZMWebBaseViewController.h
//  ZoomWebSDKSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface  ZMButtonConfig : NSObject
@property(nonatomic, copy) NSString *btnURLStr;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) SEL selector;
@property(nonatomic, assign) CGFloat fontSize;
@end


@protocol ZMCCContainerViewDelegate <NSObject>
@optional

- (NSArray *)buttonConfigs;
// new test.
- (void)openCampaignChatDemoPage_closeChat:(NSString *)url;
- (void)openCampaignChatDemoPage_bringParamsToWebChat:(NSString *)url;
- (void)openCampaignChatDemoPage_openLinkInWebView:(NSString *)url;
- (void)openCampaignChatDemoPage_openLinkInBrowser:(NSString *)url;
- (void)openCampaignChatDemoPage_openLinkInSeperateViewController:(NSString *)url;
- (void)openCampaignChatDemoPage_supportHandOffEvent:(NSString *)url;
@end


@interface ZMWebBaseViewController : UIViewController
@end



NS_ASSUME_NONNULL_END
