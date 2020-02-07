//
//  WeexInitManager.m
//  eeui
//
//  Created by 高一 on 2019/3/1.
//

#import "WeexInitManager.h"

@implementation WeexInitManager

//添加入口
+ (void) addInitClass:(Class)cls {
    if (init_lists == nil) {
        init_lists = [NSMutableArray new];
    }
    [init_lists addObject:cls];
}

//启动成功
+ (void) didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(didFinishLaunchingWithOptions:)]) {
                [car performSelector:(@selector(didFinishLaunchingWithOptions:)) withObject:launchOptions];
            }
        }
    });
}

//注册推送成功调用
+ (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:)]) {
                [car performSelector:(@selector(didRegisterForRemoteNotificationsWithDeviceToken:)) withObject:deviceToken];
            }
        }
    });
}

// 注册推送失败调用
+ (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(didFailToRegisterForRemoteNotificationsWithError:)]) {
                [car performSelector:(@selector(didFailToRegisterForRemoteNotificationsWithError:)) withObject:error];
            }
        }
    });
}

//iOS10以下使用这两个方法接收通知
+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(didReceiveRemoteNotification:fetchCompletionHandler:)]) {
                [car performSelector:(@selector(didReceiveRemoteNotification:fetchCompletionHandler:)) withObject:userInfo withObject:completionHandler];
            }
        }
    });
}

//iOS10新增：处理前台收到通知的代理方法
+ (void) willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(willPresentNotification:withCompletionHandler:)]) {
                [car performSelector:(@selector(willPresentNotification:withCompletionHandler:)) withObject:notification withObject:completionHandler];
            }
        }
    });
}

//iOS10新增：处理后台点击通知的代理方法
+ (void) didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(didReceiveNotificationResponse:withCompletionHandler:)]) {
                [car performSelector:(@selector(didReceiveNotificationResponse:withCompletionHandler:)) withObject:response withObject:completionHandler];
            }
        }
    });
}

//捕捉回调
+ (void) openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(openURL:options:)]) {
                [car performSelector:(@selector(openURL:options:)) withObject:url withObject:options];
            }
        }
    });
}

//捕捉握手
+ (void) handleOpenURL:(NSURL *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(handleOpenURL:)]) {
                [car performSelector:(@selector(handleOpenURL:)) withObject:url];
            }
        }
    });
}

//webView JS 接口
+ (void) setJSCallModule:(JSCallCommon *)callCommon webView:(WKWebView*)webView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Class cls in init_lists) {
            id car  = [[cls alloc] init];
            if ([car respondsToSelector:@selector(setJSCallModule:webView:)]) {
                [car performSelector:(@selector(setJSCallModule:webView:)) withObject:callCommon withObject:webView];
            }
        }
    });
}

@end
