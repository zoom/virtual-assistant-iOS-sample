//
//  ZMDemoButton.m
//  ZoomCCSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import "ZMDemoButton.h"

@implementation ZMDemoButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 22;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0.06 green:0.45 blue:0.93 alpha:1.0];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addTarget:[self class] action:@selector(handleBlock:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

+ (void)handleBlock:(id)sender {
    ZMDemoButton *btn = sender;
    if (![btn isKindOfClass:[ZMDemoButton class]]) {
        return;
    }
    if (btn.block) {
        btn.block();
    }
}
@end

