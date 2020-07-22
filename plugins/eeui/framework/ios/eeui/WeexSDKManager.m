//
//  WeexSDKManager.m
//  WeexDemo
//
//  Created by yangshengtao on 16/11/14.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "WeexSDKManager.h"
#import "WeexSDK.h"
#import "WXImgLoaderDefaultImpl.h"

@implementation WeexSDKManager

+ (WeexSDKManager *)sharedIntstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.cacheData = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return self;
}

- (void)setup
{
    [self initWeexSDK];
}

- (void)initWeexSDK
{
    [WXAppConfiguration setAppName:@"EEUI"];
    [WXAppConfiguration setAppGroup:@"EEUI"];

    [WXSDKEngine initSDKEnvironment];

    //Handler
    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];

    //Module
    [WXSDKEngine registerModule:@"eeui" withClass:NSClassFromString(@"eeuiModule")];
    [WXSDKEngine registerModule:@"debug" withClass:NSClassFromString(@"eeuiDebugModule")];
    [WXSDKEngine registerModule:@"versionUpdate" withClass:NSClassFromString(@"eeuiVersionUpdateModule")];
    [WXSDKEngine registerModule:@"navigator" withClass:NSClassFromString(@"eeuiNavigatorModule")];
    [WXSDKEngine registerModule:@"navigationBar" withClass:NSClassFromString(@"eeuiNavigationBarModule")];

    //Component
    [WXSDKEngine registerComponent:@"a" withClass:NSClassFromString(@"eeuiAComponent")];
    [WXSDKEngine registerComponent:@"banner" withClass:NSClassFromString(@"eeuiBannerComponent")];
    [WXSDKEngine registerComponent:@"blur" withClass:NSClassFromString(@"eeuiBlurComponent")];
    [WXSDKEngine registerComponent:@"button" withClass:NSClassFromString(@"eeuiButtonComponent")];
    [WXSDKEngine registerComponent:@"grid" withClass:NSClassFromString(@"eeuiGridComponent")];
    [WXSDKEngine registerComponent:@"icon" withClass:NSClassFromString(@"eeuiIconComponent")];
    [WXSDKEngine registerComponent:@"marquee" withClass:NSClassFromString(@"eeuiMarqueeComponent")];
    [WXSDKEngine registerComponent:@"navbar" withClass:NSClassFromString(@"eeuiNavbarComponent")];
    [WXSDKEngine registerComponent:@"navbar-item" withClass:NSClassFromString(@"eeuiNavbarItemComponent")];
    [WXSDKEngine registerComponent:@"ripple" withClass:NSClassFromString(@"eeuiRippleComponent")];
    [WXSDKEngine registerComponent:@"scroll-text" withClass:NSClassFromString(@"eeuiScrollTextComponent")];
    [WXSDKEngine registerComponent:@"scroll-view" withClass:NSClassFromString(@"eeuiRecylerComponent")];
    [WXSDKEngine registerComponent:@"scroll-header" withClass:NSClassFromString(@"eeuiScrollHeaderComponent")];
    [WXSDKEngine registerComponent:@"side-panel" withClass:NSClassFromString(@"eeuiSidePanelComponent")];
    [WXSDKEngine registerComponent:@"side-panel-menu" withClass:NSClassFromString(@"eeuiSidePanelItemComponent")];
    [WXSDKEngine registerComponent:@"tabbar" withClass:NSClassFromString(@"eeuiTabbarComponent")];
    [WXSDKEngine registerComponent:@"tabbar-page" withClass:NSClassFromString(@"eeuiTabbarPageComponent")];
    [WXSDKEngine registerComponent:@"view" withClass:NSClassFromString(@"eeuiViewComponent")];
    [WXSDKEngine registerComponent:@"web-view" withClass:NSClassFromString(@"eeuiWKWebViewComponent")];

#ifdef DEBUG
    [WXLog setLogLevel:WXLogLevelLog];
#endif
}


@end
