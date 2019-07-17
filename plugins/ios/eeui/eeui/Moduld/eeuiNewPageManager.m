//
//  eeuiNewPageManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiNewPageManager.h"
#import "DeviceUtil.h"
#import "CustomWeexSDKManager.h"
#import "WeexSDKManager.h"

@interface eeuiNewPageManager ()

@property (nonatomic, strong) NSMutableDictionary *pageData;
@property (nonatomic, strong) NSMutableDictionary *viewData;
@property (nonatomic, strong) NSMutableDictionary *callData;

@end

@implementation eeuiNewPageManager

+ (eeuiNewPageManager *)sharedIntstance {
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
        self.pageData = [NSMutableDictionary dictionaryWithCapacity:5];
        self.viewData = [NSMutableDictionary dictionaryWithCapacity:5];
        self.callData = [NSMutableDictionary dictionaryWithCapacity:5];
    }

    return self;
}

- (NSString *) getPageName:(id)params
{
    NSString *name = @"";
    if (params) {
        if ([params isKindOfClass:[NSString class]]) {
            name = params;
        } else if ([params isKindOfClass:[NSDictionary class]]) {
            name = [WXConvert NSString:params[@"pageName"]];
        }
    }
    if (name.length == 0) {
        name = [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    }
    return name;
}

#pragma mark openPage
- (void)openPage:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *url = params[@"url"] ? [WXConvert NSString:params[@"url"]] : @"";

    NSString *pageName = params[@"pageName"] ? [WXConvert NSString:params[@"pageName"]] : [NSString stringWithFormat:@"NewPage-%d", (arc4random() % 100) + 1000];
    NSString *pageTitle = params[@"pageTitle"] ? [WXConvert NSString:params[@"pageTitle"]] : @"";
    NSString *safeAreaBottom = params[@"safeAreaBottom"] ? [WXConvert NSString:params[@"safeAreaBottom"]] : @"";

    NSString *pageType = params[@"pageType"] ? [WXConvert NSString:params[@"pageType"]] : @"app";
    id data = params[@"params"];
    NSInteger cache = params[@"cache"] ? [WXConvert NSInteger:params[@"cache"]] : 0;
    BOOL loading = params[@"loading"] ? [WXConvert BOOL:params[@"loading"]] : YES;

    BOOL swipeBack = params[@"swipeBack"] ? [WXConvert BOOL:params[@"swipeBack"]] : YES;
    BOOL animated = params[@"animated"] ? [WXConvert BOOL:params[@"animated"]] : YES;
    NSString *statusBarType = params[@"statusBarType"] ? [WXConvert NSString:params[@"statusBarType"]] : @"normal";
    NSString *statusBarColor = params[@"statusBarColor"] ? [WXConvert NSString:params[@"statusBarColor"]] : @"";
    NSInteger statusBarAlpha = params[@"statusBarAlpha"] ? [WXConvert NSInteger:params[@"statusBarAlpha"]] : 0;
    NSString *statusBarStyle = params[@"statusBarStyle"] ? [WXConvert NSString:params[@"statusBarStyle"]] : @"";

    NSString *softInputMode = params[@"softInputMode"] ? [WXConvert NSString:params[@"softInputMode"]] : @"auto";
    //BOOL translucent = params[@"translucent"] ? [WXConvert BOOL:params[@"translucent"]] : NO;

    NSString *backgroundColor = params[@"backgroundColor"] ? [WXConvert NSString:params[@"backgroundColor"]] : @"";
    BOOL backPressedClose = params[@"backPressedClose"] ? [WXConvert BOOL:params[@"backPressedClose"]] : YES;

    NSDictionary *currentInfo = [self getPageInfo:nil];
    if (statusBarColor.length == 0) {
        if (currentInfo!= nil) {
            statusBarColor = currentInfo[@"statusBarColor"];
        }
        if (statusBarColor.length == 0) {
            statusBarColor = @"#3EB4FF";
        }
    }
    if (backgroundColor.length == 0) {
        if (currentInfo!= nil) {
            backgroundColor = currentInfo[@"backgroundColor"];
        }
        if (backgroundColor.length == 0) {
            backgroundColor = @"#FFFFFF";
        }
    }

    url = [DeviceUtil rewriteUrl:[DeviceUtil suffixUrl:pageType url:url]];
    NSLog(@"NewPage = %@", url);

    //跳转页面
    eeuiViewController *mainVC = [[eeuiViewController alloc] init];
    mainVC.pageType = pageType;
    mainVC.pageName = pageName;
    mainVC.pageTitle = pageTitle;
    mainVC.safeAreaBottom = safeAreaBottom;
    mainVC.params = data;
    mainVC.url = url;
    mainVC.cache = cache;
    mainVC.isDisSwipeBack = !swipeBack;
    mainVC.isDisItemBack = !backPressedClose;
    mainVC.loading = loading;
    mainVC.statusBarType = statusBarType;
    mainVC.statusBarColor = statusBarColor;
    mainVC.statusBarAlpha = statusBarAlpha;
    mainVC.statusBarStyleCustom = statusBarStyle;
    mainVC.backgroundColor = backgroundColor;
    mainVC.softInputMode = softInputMode;

    mainVC.statusBlock = ^(NSString *status) {
        if (callback) {
            callback(@{@"pageName":pageName, @"status":status, @"webStatus":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@"", @"title":@""}, YES);
        }
    };
    mainVC.webBlock = ^(NSDictionary *dic) {
        if (callback) {
            NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dic];
            [result setObject:pageName forKey:@"pageName"];
            callback(result, YES);
        }
    };

    if (self.weexInstance.viewController.navigationController) {
        [self.weexInstance.viewController.navigationController pushViewController:mainVC animated:animated];
    } else if ([[DeviceUtil getTopviewControler] navigationController]) {
        [[[DeviceUtil getTopviewControler] navigationController] pushViewController:mainVC animated:animated];
    } else {
        [[UIApplication sharedApplication] delegate].window.rootViewController =  [[WXRootViewController alloc] initWithRootViewController:mainVC];
    }

    //存储页面数据
    [self setPageData:pageName vc:mainVC];
}

- (NSDictionary*)getPageInfo:(id)params
{
    NSString *name = [self getPageName:params];
    if (name.length > 0) {
        NSDictionary *data = self.pageData[name];
        if (data) {
            return data;
        }
    }
    return nil;
}

- (void)getPageInfoAsync:(id)params callback:(WXModuleCallback)callback
{
    if (callback == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        callback([self getPageInfo:params]);
    });
}

- (void)reloadPage:(id)params
{
    eeuiViewController *vc = nil;
    NSString *name = [self getPageName:params];
    if (name.length > 0) {
        id data = self.viewData[name];
        if (data && [data isKindOfClass:[UIViewController class]]) {
            vc = data;
        } else {
            vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
        }
    }
    if (vc == nil) {
        return;
    }

    [(eeuiViewController*)vc refreshPage];
}

- (void)setSoftInputMode:(id)params modo:(NSString*)modo
{
    eeuiViewController *vc = nil;
    NSString *name = [self getPageName:params];
    if (name.length > 0) {
        id data = self.viewData[name];
        if (data && [data isKindOfClass:[UIViewController class]]) {
            vc = data;
        } else {
            vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
        }
    }
    if (vc == nil) {
        return;
    }
    vc.softInputMode = modo;
    [CustomWeexSDKManager setSoftInputMode:modo];
}

- (void)setStatusBarStyle:(BOOL)isLight
{
    eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    if (vc == nil) {
        return;
    }
    vc.statusBarStyleCustom = isLight ? @"1" : @"0";
    [[UIApplication sharedApplication] setStatusBarStyle:isLight ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault];
}

- (void)setPageBackPressed:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *name = [self getPageName:params];

    //    if (callback) {
    //        callback(nil, YES);
    //    }
}

- (void)setOnRefreshListener:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    eeuiViewController *vc = nil;
    NSString *name = [self getPageName:params];
    id data = self.viewData[name];
    if (data && [data isKindOfClass:[eeuiViewController class]]) {
        vc = (eeuiViewController*)data;
    } else {
        vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    }
}

- (void)setRefreshing:(id)params refreshing:(BOOL)refreshing
{
    eeuiViewController *vc = nil;
    NSString *name = [self getPageName:params];
    id data = self.viewData[name];
    if (data && [data isKindOfClass:[eeuiViewController class]]) {
        vc = (eeuiViewController*)data;
    } else {
        vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    }

    //    [vc changeRefresh:refreshing];
}


- (void)setPageStatusListener:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *listener = @"";
    NSString *name = @"";
    if ([params isKindOfClass:[NSString class]]) {
        listener = params;
        name = [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        listener = [WXConvert NSString:params[@"listenerName"]];
        name = params[@"pageName"] ? [WXConvert NSString:params[@"pageName"]] : [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    }

    eeuiViewController *vc = nil;
    id data = self.viewData[name];
    if (data && [data isKindOfClass:[eeuiViewController class]]) {
        vc = (eeuiViewController*)data;
    } else {
        vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    }

    [vc addStatusListener:listener];

    //通过监听名称存取相应的block
    [self.callData setObject:callback forKey:listener];

    vc.listenerBlock = ^(id obj) {

        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
            NSString *listenerName = obj[@"listenerName"];
            WXModuleKeepAliveCallback callBack = self.callData[listenerName];

            if (callBack) {
                NSString *status = @"";
                id extra = nil;
                if ([obj isKindOfClass:[NSString class]]) {
                    status = obj;
                } else if ([obj isKindOfClass:[NSDictionary class]]) {
                    status = obj[@"status"];
                    extra = obj[@"extra"];
                }

                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"pageName":name, @"status":status, @"webStatus":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@"", @"title":@""}];
                if (extra) {
                    [dic setObject:extra forKey:@"extra"];
                }

                callBack(dic, YES);
            }
        }
    };
}

- (void)clearPageStatusListener:(id)params
{
    NSString *listener = @"";
    NSString *name = @"";
    if ([params isKindOfClass:[NSString class]]) {
        listener = params;
        name = [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        listener = params[@"listenerName"];
        name = params[@"pageName"] ? params[@"pageName"] : [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    }

    eeuiViewController *vc = nil;
    id data = self.viewData[name];
    if (data && [data isKindOfClass:[eeuiViewController class]]) {
        vc = (eeuiViewController*)data;
    } else {
        vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    }

    [vc clearStatusListener:listener];

    if ([[self.callData allKeys] containsObject:listener]) {
        [self.callData removeObjectForKey:listener];
    }
}

- (void)onPageStatusListener:(id)params status:(NSString*)status
{
    NSString *status2 = @"";
    NSString *listener = @"";
    NSString *name = [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    id extra = nil;

    //第二个参数为空，则表示第一个参数是status
    if (status == nil) {
        if ([params isKindOfClass:[NSString class]]) {
            status2 = params;
        }
    } else {
        status2 = status;

        if ([params isKindOfClass:[NSString class]]) {
            listener = params;
        } else if ([params isKindOfClass:[NSDictionary class]]) {
            listener = [WXConvert NSString:params[@"listenerName"]];
            if (params[@"pageName"]) {
                name = [WXConvert NSString:params[@"pageName"]];
            }
            extra = params[@"extra"];
        }
    }

    eeuiViewController *vc = nil;
    id data = self.viewData[name];
    if (data && [data isKindOfClass:[eeuiViewController class]]) {
        vc = (eeuiViewController*)data;
    } else {
        vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    }

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"status":status2, @"pageName":name, @"listenerName":listener}];

    if (extra) {
        [dic setObject:extra forKey:@"extra"];
    }

    [vc postStatusListener:listener data:dic];
}

- (void)getCacheSizePage:(WXModuleKeepAliveCallback)callback
{
    NSString *filePath =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"page_cache"];
    NSInteger  size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];

    if (callback) {
        callback(@{@"size":@(size)}, YES);
    }
}

- (void)clearCachePage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"page_cache"];

    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)closePage:(id)params
{
    NSString *name = @"";
    BOOL animated = YES;
    if (params) {
        if ([params isKindOfClass:[NSString class]]) {
            name = params;
        } else if ([params isKindOfClass:[NSDictionary class]]) {
            name = [WXConvert NSString:params[@"pageName"]];
            animated = params[@"animated"] ? [WXConvert BOOL:params[@"animated"]] : YES;
        }
    } else {
        name = [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    }
    if ([name isEqualToString:@""]) {
        return;
    }

    id data = self.viewData[name];
    if (data == nil) {
        return;
    }

    UIViewController *vc = nil;
    if (data && [data isKindOfClass:[UIViewController class]]) {
        vc = (UIViewController*)data;
    } else {
        vc = [DeviceUtil getTopviewControler];
    }
    if (vc == nil) {
        return;
    }

    if ([[self.pageData allKeys] containsObject:name]) {
        [self.pageData removeObjectForKey:name];
    }
    if ([[self.viewData allKeys] containsObject:name]) {
        [self.viewData removeObjectForKey:name];
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:self.weexInstance.viewController.navigationController.viewControllers];
    BOOL isDeviceUtil = NO;
    if (array.count == 0) {
        array = [NSMutableArray arrayWithArray:[[DeviceUtil getTopviewControler] navigationController].viewControllers];
        isDeviceUtil = YES;
    }
    for (int i = 0; i < array.count; i++) {
        if (array[i] == vc) {
            [self removePageData:[(eeuiViewController*)array[i] pageName]];
            if (i + 1 == array.count) {
                if (isDeviceUtil) {
                    [[[DeviceUtil getTopviewControler] navigationController] popViewControllerAnimated:animated];
                } else {
                    [self.weexInstance.viewController.navigationController popViewControllerAnimated:animated];
                }
            } else {
                [array removeObjectAtIndex:i];
                if (isDeviceUtil) {
                    [[DeviceUtil getTopviewControler] navigationController].viewControllers = array;
                } else {
                    self.weexInstance.viewController.navigationController.viewControllers = array;
                }
            }
            break;
        }
    }
}

- (void)closePageTo:(id)params
{
    NSString *name = @"";
    if (params) {
        if ([params isKindOfClass:[NSString class]]) {
            name = params;
        } else if ([params isKindOfClass:[NSDictionary class]]) {
            name = [WXConvert NSString:params[@"pageName"]];
        }
    }
    if ([name isEqualToString:@""]) {
        return;
    }

    id data = self.viewData[name];
    if (data == nil) {
        return;
    }

    UIViewController *vc = nil;
    if (data && [data isKindOfClass:[UIViewController class]]) {
        vc = (UIViewController*)data;
    }
    if (vc == nil) {
        return;
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:self.weexInstance.viewController.navigationController.viewControllers];
    BOOL isDeviceUtil = NO;
    if (array.count == 0) {
        array = [NSMutableArray arrayWithArray:[[DeviceUtil getTopviewControler] navigationController].viewControllers];
        isDeviceUtil = YES;
    }

    BOOL isClose = NO;
    BOOL isRemove = NO;
    for (int i = 0; i < array.count; i++) {
        if (isClose == YES) {
            if (i + 1 != array.count) {
                [self removePageData:[(eeuiViewController*)array[i] pageName]];
                [array removeObjectAtIndex:i];
                isRemove = YES;
            }
        }else{
            if (array[i] == vc) {
                isClose = YES;
            }
        }
    }

    if (isRemove) {
        if (isDeviceUtil) {
            [[DeviceUtil getTopviewControler] navigationController].viewControllers = array;
        } else {
            self.weexInstance.viewController.navigationController.viewControllers = array;
        }
    }

    if (isClose) {
        [self closePage:nil];
    }
}

- (void)openWeb:(NSString*)url
{
    NSString* newUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *URL = [NSURL URLWithString:newUrl];
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)goDesktop
{
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

- (void)removePageData:(NSString*)pageName
{
    if ([[self.pageData allKeys] containsObject:pageName]) {
        [self.pageData removeObjectForKey:pageName];
    }
    if ([[self.viewData allKeys] containsObject:pageName]) {
        [self.viewData removeObjectForKey:pageName];
    }
}

- (void)setPageData:(NSString*)pageName vc:(eeuiViewController *)vc
{
    if (pageName.length > 0) {
        [self.viewData setObject:vc forKey:pageName];

        NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:@{}];
        [res setObject:vc.url forKey:@"url"];
        [res setObject:vc.pageName forKey:@"pageName"];
        [res setObject:vc.pageType forKey:@"pageType"];
        [res setObject:vc.params ? vc.params: @{} forKey:@"params"];
        [res setObject:[NSString stringWithFormat:@"%ld", (long)vc.cache] forKey:@"cache"];
        [res setObject:vc.loading ? @"true" : @"false" forKey:@"loading"];
        [res setObject:vc.statusBarType forKey:@"statusBarType"];
        [res setObject:vc.statusBarColor forKey:@"statusBarColor"];
        [res setObject:[NSString stringWithFormat:@"%ld", (long)vc.statusBarAlpha] forKey:@"statusBarAlpha"];
        [res setObject:vc.statusBarStyleCustom forKey:@"statusBarStyle"];
        [res setObject:vc.backgroundColor forKey:@"backgroundColor"];
        [self.pageData setObject:res forKey:pageName];
    }
}

- (NSDictionary *)getViewData
{
    return self.viewData;
}

- (void)setPageDataValue:(NSString*)pageName key:(NSString*)key value:(NSString*)value
{
    NSMutableDictionary *data = self.pageData[pageName];
    if (data) {
        [data setObject:value forKey:key];
    }
}

- (void)setTitle:(id) params callback:(WXModuleKeepAliveCallback) callback
{
    eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    if (vc) {
        [vc setNavigationTitle:params callback:callback];
    }
}

- (void)setLeftItems:(id) params callback:(WXModuleKeepAliveCallback) callback
{
    eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    if (vc) {
        [vc setNavigationItems:params position:@"left" callback:callback];
    }
}

- (void)setRightItems:(id) params callback:(WXModuleKeepAliveCallback) callback
{
    eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    if (vc) {
        [vc setNavigationItems:params position:@"right" callback:callback];
    }
}

- (void)showNavigation
{
    eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    if (vc) {
        [vc showNavigation];
    }
}

- (void)hideNavigation
{
    eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
    if (vc) {
        [vc hideNavigation];
    }
}

+ (void)setTabViewDebug:(NSString*)pageName callback:(WXModuleKeepAliveCallback) callback
{
    if (tabViewDebug == nil) {
        tabViewDebug = [NSMutableDictionary new];
    }
    if (pageName.length > 0) {
        [tabViewDebug setObject:callback forKey:pageName];
    }
}

+ (void)removeTabViewDebug:(NSString*)pageName
{
    if (tabViewDebug == nil) {
        tabViewDebug = [NSMutableDictionary new];
    }
    if (pageName.length > 0) {
        [tabViewDebug removeObjectForKey:pageName];
    }
}

+ (NSMutableDictionary *)getTabViewDebug {
    return tabViewDebug;
}

@end
