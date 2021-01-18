//
//  eeuiNavigatorModule.m
//  Pods
//
//  Created by 高一 on 2019/3/13.
//

#import "eeuiNavigatorModule.h"
#import "eeuiNewPageManager.h"
#import "DeviceUtil.h"

@implementation eeuiNavigatorModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(push:callback:))
WX_EXPORT_METHOD(@selector(pop:callback:))

- (void)push:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    if ([params isKindOfClass:[NSString class]]) {
        info[@"url"] = params;
    }else if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    info = [params mutableCopy];
    info[@"pageTitle"] = [info objectForKey:@"pageTitle"] ? [WXConvert NSString:info[@"pageTitle"]] : @" ";
    [[eeuiNewPageManager sharedIntstance] openPage:info weexInstance:weexInstance callback:callback];
}

- (void)pop:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSString *name = @"";
    if ([params isKindOfClass:[NSString class]]) {
        UIViewController *vc = [DeviceUtil getTopviewControler];
        if ([vc isKindOfClass:eeuiViewController.class]) {
            name = [(eeuiViewController*)vc pageName];
        }
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        info = [[NSMutableDictionary alloc] initWithDictionary:params];
        if (params[@"pageName"]) {
            name = [WXConvert NSString:params[@"pageName"]];
        } else {
            UIViewController *vc = [DeviceUtil getTopviewControler];
            if ([vc isKindOfClass:eeuiViewController.class]) {
                name = [(eeuiViewController*)vc pageName];
            }
        }
    }
    info[@"pageName"] = name;
    if (callback) {
        info[@"listenerName"] = @"__navigatorPop";
        [[eeuiNewPageManager sharedIntstance] setPageStatusListener:info weexInstance:weexInstance callback:callback];
    }
    [[eeuiNewPageManager sharedIntstance] closePage:info weexInstance:weexInstance];
}

@end
