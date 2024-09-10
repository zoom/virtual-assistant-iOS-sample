//
//  ZMDemoButton.h
//  ZoomCCSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMDemoButton : UIButton
@property (nonatomic, copy) dispatch_block_t block;
@end

NS_ASSUME_NONNULL_END
