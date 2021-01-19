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
    [[eeuiNewPageManager sharedIntstance] setTitle:params weexInstance:[[WXSDKManager bridgeMgr] topInstance] callback:callback];
}

- (void)setLeftItem:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    [[eeuiNewPageManager sharedIntstance] setLeftItems:params weexInstance:[[WXSDKManager bridgeMgr] topInstance] callback:callback];
}

- (void)setRightItem:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    [[eeuiNewPageManager sharedIntstance] setRightItems:params weexInstance:[[WXSDKManager bridgeMgr] topInstance] callback:callback];
}

- (void)show
{
    [[eeuiNewPageManager sharedIntstance] showNavigationWithWeexInstance:[[WXSDKManager bridgeMgr] topInstance]];
}

- (void)hide
{
    [[eeuiNewPageManager sharedIntstance] hideNavigationWithWeexInstance:[[WXSDKManager bridgeMgr] topInstance]];
}

@end
