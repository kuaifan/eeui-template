//
//  NavigationBarBridge.m
//  Pods
//
//  Created by 高一 on 2019/3/16.
//

#import "NavigationBarBridge.h"
#import "eeuiNewPageManager.h"

@implementation NavigationBarBridge

- (void)setTitle:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    [[eeuiNewPageManager sharedIntstance] setTitle:params callback:callback];
}

- (void)setLeftItem:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    [[eeuiNewPageManager sharedIntstance] setLeftItems:params callback:callback];
}

- (void)setRightItem:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    [[eeuiNewPageManager sharedIntstance] setRightItems:params callback:callback];
}

- (void)show
{
    [[eeuiNewPageManager sharedIntstance] showNavigation];
}

- (void)hide
{
    [[eeuiNewPageManager sharedIntstance] hideNavigation];
}

@end
