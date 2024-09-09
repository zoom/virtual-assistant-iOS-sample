//
//  ZMWebBaseViewController.m
//  ZoomWebSDKSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

#import "ZMWebBaseViewController.h"
#import "ZMDemoButton.h"
#import "ZMWebDemoViewController.h"
#import "UIView+ZMWebSDKExtensions.h"
#import "ZMLiveSDKWebviewController.h"

#define isSmallDevice [UIScreen mainScreen].bounds.size.width <= 375.0
@implementation ZMButtonConfig
@end

@interface ZMCCContainerView : UIScrollView
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, weak) id<ZMCCContainerViewDelegate> buttonDelegate;
@end

@implementation ZMCCContainerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = YES;
        self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat titleWidth = self.frame.size.width - 40.f * 2,
            titleHeight = self.title.intrinsicContentSize.height;
    self.title.frame = CGRectMake(40.f, 40, titleWidth, titleHeight);
    
    CGFloat buttonWidth = 294,
            buttonHeight = 48.f,
            buttonY = self.title.frame.origin.y + self.title.frame.size.height + 40,
            buttonX = (self.frame.size.width - buttonWidth) / 2.0;
    
    UIButton *lastBtn = nil;
    NSArray *btnConfigs = [self.buttonDelegate buttonConfigs];
    for (int i = 0; i< btnConfigs.count; i++) {
        ZMButtonConfig *config = btnConfigs[i];
        ZMDemoButton *button = [ZMDemoButton buttonWithType:UIButtonTypeCustom];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
        button.titleLabel.numberOfLines = 2;
        if (config.fontSize > 0.) {
            button.titleLabel.font = [UIFont systemFontOfSize:config.fontSize];
        }
        else {
            button.titleLabel.font = [UIFont systemFontOfSize:17];
        }
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button setTitle:config.title forState:UIControlStateNormal];
        [self addSubview:button];
        
        if (lastBtn) {
            button.size = lastBtn.size;
            button.left = lastBtn.left;
            button.top = lastBtn.bottom + 16;
            lastBtn = button;
        } else {
            button.frame = CGRectMake(buttonX, buttonY+16, buttonWidth, buttonHeight);
        }
        lastBtn = button;
        __weak typeof(self) wself = self;
        button.block = ^{
            if (wself.buttonDelegate && [wself.buttonDelegate respondsToSelector:config.selector]) {
                [wself.buttonDelegate performSelector:config.selector withObject:config.btnURLStr];
            }
        };
    }
    
    
    CGFloat contentHeight = buttonY + (buttonHeight + 16) * btnConfigs.count + buttonHeight + 16 + buttonHeight;
    self.contentSize = CGSizeMake(self.frame.size.width, contentHeight);
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.text = @"ZVA Web SDK Sample";
        _title.textColor = [UIColor blackColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:isSmallDevice ? 24.0 : 30.0 weight:UIFontWeightBold];
        [self addSubview:_title];
    }
    return _title;
}


@end


@interface ZMCCBottomTabButton : UIButton
@end

@implementation ZMCCBottomTabButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:@"Text" forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"zmcc_star"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"zmcc_star_selected"] forState:UIControlStateSelected];
        self.titleLabel.font = [UIFont systemFontOfSize:10.f weight:UIFontWeightMedium];
        [self setTitleColor:[UIColor colorWithRed:0.02 green:0.02 blue:0.07 alpha:0.56] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:0.06 green:0.45 blue:0.93 alpha:1.0] forState:UIControlStateSelected];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageX = (self.frame.size.width - 24.f) / 2.f;
    self.imageView.frame = CGRectMake(imageX, 7.f, 24.f, 24.f);
    
    CGFloat titleWidth = self.titleLabel.intrinsicContentSize.width,
            titleX = (self.frame.size.width - titleWidth) / 2.f,
            titleY = self.imageView.frame.origin.y + self.imageView.frame.size.height + 2.f;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleWidth, self.titleLabel.intrinsicContentSize.height);
}

@end


@interface ZMWebBaseViewController () <ZMCCContainerViewDelegate>
@property (nonatomic, strong) ZMCCContainerView *containerView;
@property (nonatomic, strong) UIView *statusBar;
@end

@implementation ZMWebBaseViewController
- (void)dealloc {
    if (@available(ios 13.0, *)) {
        if (_statusBar) {
            [_statusBar removeFromSuperview];
            _statusBar = nil;
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZVA Web SDK Sample";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (@available(iOS 13.0, *)) {
            self.statusBar.frame = UIApplication.sharedApplication.windows.firstObject.windowScene.statusBarManager.statusBarFrame;
        }
    }];
}

- (void)setupStatusBarColor:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
      if (!_statusBar) {
          UIWindow *keyWindow = [UIApplication sharedApplication].windows[0];
          _statusBar = [[UIView alloc] initWithFrame:keyWindow.windowScene.statusBarManager.statusBarFrame];
          [keyWindow addSubview:_statusBar];
      }
    } else {
        _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    if ([_statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        _statusBar.backgroundColor = color;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat bottomY;
        bottomY = self.view.frame.size.height;
    CGFloat containerY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y,
            containerHeight = bottomY - containerY;
    self.containerView.frame = CGRectMake(0.f, containerY, self.view.frame.size.width, MAX(containerHeight, 100));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBarHidden = NO;
    UIColor *color = [UIColor colorWithRed:0.22 green:0.22 blue:0.3 alpha:1.0];
    [self setupStatusBarColor:color];
    self.navigationController.navigationBar.backgroundColor = color;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = color;
    self.extendedLayoutIncludesOpaqueBars = YES;

    if (@available(iOS 13.0, *)) {
        [self.navigationController.navigationBar.standardAppearance setTitleTextAttributes:@{
            NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
            NSForegroundColorAttributeName:[UIColor whiteColor]
        }];
        self.navigationController.navigationBar.standardAppearance.backgroundColor = color;
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:@{
            NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
            NSForegroundColorAttributeName:[UIColor whiteColor]
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIColor *color = [UIColor clearColor];
    [self setupStatusBarColor:color];
    self.navigationController.navigationBar.backgroundColor = color;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - getter
- (ZMCCContainerView *)containerView {
    if (!_containerView) {
        _containerView = [[ZMCCContainerView alloc] init];
        _containerView.buttonDelegate = self;
        [self.view addSubview:_containerView];
    }
    return _containerView;
}

@end
