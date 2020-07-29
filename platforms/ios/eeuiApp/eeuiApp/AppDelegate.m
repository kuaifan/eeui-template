//
//  AppDelegate.m
//  eeuiApp
//
//  Created by 高一 on 2018/8/15.
//

#import "AppDelegate.h"
#import "WeexSDKManager.h"
#import "WeexInitManager.h"
#import "MNAssistiveBtn.h"
#import "ViewController.h"
#import "eeuiStorageManager.h"
#import "eeuiNewPageManager.h"
#import "scanViewController.h"
#import "DeviceUtil.h"
#import "AFNetworking.h"
#import <CoreTelephony/CTCellularData.h>
#import <SocketRocket/SRWebSocket.h>
#import "Config.h"
#import "Cloud.h"
#import "Debug.h"
#import "eeuiToastManager.h"

@interface AppDelegate ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, assign) BOOL isSocketConnect;
@property (nonatomic, assign) BOOL isDataRestricted;

@end

@implementation AppDelegate

ViewController *mController;
MNAssistiveBtn *debugBtn;
UIView *debugRView;
NSString *socketHost;
NSString *socketPort;
NSString *deBugWsOpenUrl;
NSString *deBugKeepScreen;
NSDictionary *mLaunchOptions;

//启动成功
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    mLaunchOptions = launchOptions;

    #if DEBUG
        mController = [[ViewController alloc]init];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:mController];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = navi;
        [self.window makeKeyAndVisible];
        [self initDebug:0];
    #endif

    if (__IPHONE_10_0) {
        [self networkStatus:application didFinishLaunchingWithOptions:launchOptions];
    }else{
        [self addReachabilityManager:application didFinishLaunchingWithOptions:launchOptions];
    }

    [Cloud welcome:self.window click:nil];
    [WeexInitManager didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

//注册推送成功调用
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [WeexInitManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册推送失败调用
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [WeexInitManager didFailToRegisterForRemoteNotificationsWithError:error];
}

//iOS10以下使用这两个方法接收通知，
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [WeexInitManager didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    [WeexInitManager willPresentNotification:notification withCompletionHandler:completionHandler];
}


//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    [WeexInitManager didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

//捕捉回调
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    [WeexInitManager openURL:url options:options];
    return YES;
}

//捕捉握手
- (BOOL)application:(UIApplication *)app handleOpenURL:(NSURL *)url{
    [WeexInitManager handleOpenURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//获取网络权限状态
- (void)networkStatus:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        switch (state) {
            case kCTCellularDataRestricted:{
                //1权限关闭的情况下 再次请求网络数据会弹出设置网络提示
                EELog(@"gggggggg::网络权限关闭");
                [Cloud appData:NO];
                self.isDataRestricted = YES;
                break;
            }
            case kCTCellularDataNotRestricted:{
                //2已经开启网络权限 监听网络状态
                EELog(@"gggggggg::网络权限开启");
                [self addReachabilityManager:application didFinishLaunchingWithOptions:launchOptions];
                if (self.isDataRestricted == YES) {
                    [Cloud appData:NO];
                    [self refresh];
                }
                self.isDataRestricted = NO;
                break;
            }
            case kCTCellularDataRestrictedStateUnknown:{
                //3未知情况 （还没有遇到推测是有网络但是连接不正常的情况下）
                EELog(@"gggggggg::网络权限未知");
                [Cloud appData:NO];
                break;
            }
        }
    };
}

//监听网络状态（开启网络监视器）
- (void)addReachabilityManager:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                EELog(@"gggggggg::网络不通：%@",@(status) );
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                EELog(@"gggggggg::网络通过WIFI连接：%@",@(status));
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                EELog(@"gggggggg::网络通过无线连接：%@",@(status) );
                break;
            }
            default:
                break;
        }
    }];
    [afNetworkReachabilityManager startMonitoring];
}

//初始化DEBUG
-(void) initDebug:(NSInteger) number {
    if (number > 100) {
        [self setDebugBtn:self.isSocketConnect];
        [self setSocketData];
        [self setSocketConnect:@"initialize"];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([mController isReady]) {
            [self initDebug:999];
        }else{
            [self initDebug:number+1];
        }
    });
}

//添加悬浮按钮
-(void) setDebugBtn:(BOOL)isSuccess {
    if (debugBtn) {
        [debugBtn setBackgroundUIImage: [UIImage imageNamed:isSuccess ? @"debugButtonSuccess" : @"debugButtonConnect"]];
        return;
    }
    CGFloat touchW = 48;
    CGFloat touchH = 48;
    CGFloat touchX = [[UIScreen mainScreen] bounds].size.width - touchW;
    CGFloat touchY = ([[UIScreen mainScreen] bounds].size.height - touchH) / 2;
    CGRect frame = CGRectMake(touchX, touchY, touchW, touchH);
    debugBtn = [MNAssistiveBtn mn_touchWithType:MNAssistiveTypeNone
                                          Frame:frame
                                          title:@"DEV"
                                     titleColor:[UIColor whiteColor]
                                      titleFont:[UIFont systemFontOfSize:12]
                                backgroundColor:nil
                                backgroundImage:[UIImage imageNamed:isSuccess ? @"debugButtonSuccess" : @"debugButtonConnect"]];
    [self.window addSubview:debugBtn];
    [debugBtn addTarget:self action:@selector(clickDebugBtn) forControlEvents:UIControlEventTouchUpInside];
    //
    debugRView = [[UIView alloc] initWithFrame:CGRectMake(33, 2, 8, 8)];
    debugRView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.0];
    debugRView.tag = 9000;
    debugRView.layer.cornerRadius = 4;
    [debugBtn addSubview:debugRView];
    [Debug setDebugBtnCallback:^(id  _Nullable result, BOOL keepAlive) {
        NSInteger tag = [WXConvert NSInteger:result];
        if (tag == 0) {
            debugRView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.0];
            debugRView.tag = 9000;
        } else {
            if (tag <= debugRView.tag) {
                return;
            }
            debugRView.tag = tag;
            if (tag == 9009) {
                debugRView.backgroundColor = [UIColor redColor];
            } else if (tag == 9008) {
                debugRView.backgroundColor = [UIColor orangeColor];
            } else {
                debugRView.backgroundColor = [WXConvert UIColor:@"#3EB4FF"];
            }
        }
    }];
}

//点击悬浮按钮
- (void) clickDebugBtn {
    [mController setBugBtnClick];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"开发工具菜单"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:self.isSocketConnect ? @"WiFi真机同步 [已连接]" : @"WiFi真机同步" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self wifiSetting];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[deBugKeepScreen isEqualToString:@"ON"] ? @"屏幕常亮 [已开启]" : @"屏幕常亮" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([deBugKeepScreen isEqualToString:@"ON"]) {
            deBugKeepScreen = @"OFF";
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        }else{
            deBugKeepScreen = @"ON";
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"页面信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self pageInfo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"扫一扫" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openScan];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"刷新" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [DeviceUtil clearAppboardContent];
        [self refresh];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:debugRView.tag > 9000 ? @"Console[新]" : @"Console" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        debugRView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.0];
        debugRView.tag = 9000;
        [self console];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"隐藏DEV" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self hideDev];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"重启APP" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self rebootConfirm];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"清除缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self clearCache];
    }]];
    if ([Config verifyIsUpdate]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"清除热更新数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [Cloud clearUpdate];
            [Config clearCustomConfig];
        }]];
    }

    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = debugBtn;
        popPresenter.sourceRect = debugBtn.bounds;
    }

    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//WiFi真机同步配置
- (void) wifiSetting {
    UIAlertController * alertController = [UIAlertController
                                           alertControllerWithTitle: @"WiFi真机同步配置"
                                           message: @"配置成功后，可实现真机同步实时预览"
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入IP地址";
        textField.text = socketHost;
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入端口号";
        textField.text = socketPort;
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * hostField = textfields[0];
        UITextField * portFiled = textfields[1];
        socketHost = hostField.text;
        socketPort = portFiled.text;
        [self setSocketConnect:@"initialize"];
    }]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//查看日志
- (void) pageInfo {
    if ([[DeviceUtil getTopviewControler] isKindOfClass:[eeuiViewController class]]) {
        eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
        NSDictionary *info = [[eeuiNewPageManager sharedIntstance] getPageInfo:vc.pageName weexInstance:[[WXSDKManager bridgeMgr] topInstance]];
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
        if(data && !error){
            NSString *infoString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            infoString = [infoString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            [vc showFixedInfo:infoString];
            return;
        }
    }
    UIAlertController * alertController = [UIAlertController
                                           alertControllerWithTitle: @"页面信息"
                                           message: @"当前页面不支持。"
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//打开扫一扫
- (void) openScan {
    scanViewController *scan = [[scanViewController alloc]init];
    scan.headTitle = @"二维码/条码";
    scan.scanerBlock = ^(NSDictionary *dic) {
        if ([dic[@"status"] isEqualToString:@"success"]) {
            NSString *text = dic[@"text"];
            NSString *url = text, *host = @"", *port = @"";
            if ([url hasPrefix:@"http"]) {
                if ([text containsString:@"?socket="]) {
                    url = [Config getMiddle:text start:nil to:@"?socket="];
                    host = [Config getMiddle:text start:@"?socket=" to:@":"];
                    port = [Config getMiddle:text start:[NSString stringWithFormat:@"?socket=%@:", host] to:@"&"];
                }

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[eeuiNewPageManager sharedIntstance] openPage:@{@"url": url, @"pageType": @"auto"} weexInstance:[[WXSDKManager bridgeMgr] topInstance] callback:^(NSDictionary *result, BOOL keepAlive) {
                        if ([result[@"status"] isEqualToString:@"create"]) {
                            if (host.length && port.length) {
                                socketHost = host;
                                socketPort = port;
                                [self setSocketConnect:@"back"];
                            }
                        }
                    }];
                });
            }
        }
    };
    [[[DeviceUtil getTopviewControler] navigationController] pushViewController:scan animated:YES];
}

//刷新当前页面
- (void) refresh {
    [[eeuiNewPageManager sharedIntstance] reloadPage:nil weexInstance:[[WXSDKManager bridgeMgr] topInstance]];
}

//隐藏DEV按钮
- (void) hideDev {
    UIAlertController * alertController = [UIAlertController
                                           alertControllerWithTitle: @"隐藏DEV"
                                           message: @"确认要隐藏DEV漂浮按钮吗？\n隐藏按钮将在下次启动APP时显示。"
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [debugBtn removeFromSuperview];
    }]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//查看日志
- (void) console {
    if ([[DeviceUtil getTopviewControler] isKindOfClass:[eeuiViewController class]]) {
        eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
        [vc showFixedConsole];
        return;
    }
    UIAlertController * alertController = [UIAlertController
                                           alertControllerWithTitle: @"Console"
                                           message: @"当前页面不支持。"
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}


//确认重启APP
- (void) rebootConfirm {
    UIAlertController * alertController = [UIAlertController
                                           alertControllerWithTitle: @"热重启APP"
                                           message: @"确认要关闭所有页面热重启APP吗？"
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [Config clear];
        [[[DeviceUtil getTopviewControler] navigationController] popToRootViewControllerAnimated:NO];
        [Config getHomeUrl:^(NSString * _Nonnull path) {
            [[[ViewController alloc]init] loadUrl:path forceRefresh:YES];
        }];

        [Cloud appData:NO];
        [DeviceUtil clearAppboardContent];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([Cloud welcome:self.window click:nil] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Cloud welcomeClose];
            [self initDebug:0];
        });

        [WeexInitManager didFinishLaunchingWithOptions:mLaunchOptions];
    }]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//清除缓存
- (void) clearCache {
    UIAlertController * alertController = [UIAlertController
                                           alertControllerWithTitle: @"清除缓存"
                                           message: @"确认清除缓存吗？\n（清除包括：clearCustomConfig、clearCacheDir、clearCachePage、clearCacheAjax）"
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Config clearCache];
    }]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//获取socket地址及端口
- (void) setSocketData {
    socketHost = [Config getString:@"socketHost" defaultVal:@""];
    socketPort = [Config getString:@"socketPort" defaultVal:@""];
}

//开始请求连接
- (void) setSocketConnect: (NSString *) param {
    self.webSocket.delegate = nil;
    [self.webSocket close];

    if (self.isSocketConnect != NO) {
        self.isSocketConnect = NO;
        [self setDebugBtn:self.isSocketConnect];
    }

    if ([param isEqualToString:@"initialize"]) {
        deBugWsOpenUrl = @"";
    }

    if (!socketHost.length || !socketPort.length) {
        return;
    }

    NSString *wsUrl = [NSString stringWithFormat:@"ws://%@:%@?mode=%@&version=2", socketHost, socketPort, param];
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wsUrl]]];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

//长链接已连接成功
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    EELog(@"[socket] %@", @"onOpen");
    deBugWsOpenUrl = [NSString stringWithFormat:@"%@:%@", [webSocket url].host, [webSocket url].port];
    if (deBugKeepScreen.length == 0) {
        deBugKeepScreen = @"ON";
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    //
    if (self.isSocketConnect != YES) {
        self.isSocketConnect = YES;
        [self setDebugBtn:self.isSocketConnect];
    }
}

//长链接收到消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSDictionary *data = [DeviceUtil dictionaryWithJsonString:(NSString *)message];
    if (data == nil) {
        EELog(@"eeui-cli版本太低，请先升级eeui-cli版本，详情：https://www.npmjs.com/package/eeui-cli");
        [[eeuiToastManager sharedIntstance] toast:@"eeui-cli版本太低，请先升级eeui-cli版本，详情：https://www.npmjs.com/package/eeui-cli"];
        return;
    }
    NSString *type = [WXConvert NSString:data[@"type"]];
    NSString *value = [WXConvert NSString:data[@"value"]];
    NSInteger version = [WXConvert NSInteger:data[@"version"]];
    if (version < 2) {
        EELog(@"eeui-cli版本太低，请先升级eeui-cli版本，详情：https://www.npmjs.com/package/eeui-cli");
        [[eeuiToastManager sharedIntstance] toast:@"eeui-cli版本太低，请先升级eeui-cli版本，详情：https://www.npmjs.com/package/eeui-cli"];
        return;
    }
    EELog(@"[socket] onMessage: %@:%@", type, value);
    if ([type isEqualToString:@"HOMEPAGE"]) {
        [DeviceUtil clearAppboardWifi];
    }
    NSArray *appboards = data[@"appboards"];
    if ([appboards count] > 0) {
        for (NSDictionary *appboardItem in appboards) {
            [DeviceUtil setAppboardWifi:appboardItem[@"path"] content:appboardItem[@"content"]];
        }
    }
    if ([type isEqualToString:@"HOMEPAGE"]) {
        if (![mController isBugBtnClick]) {
            BOOL meetSkip = YES;
            NSURL *valueUri = [NSURL URLWithString:value];
            NSString *valueHP = [NSString stringWithFormat:@"%@:%ld", [valueUri host], (long)[[valueUri port] integerValue]];
            NSDictionary *viewData = [[eeuiNewPageManager sharedIntstance] getViewData];
            for (NSString *pageName in viewData) {
                id view = [viewData objectForKey:pageName];
                if ([view isKindOfClass:[eeuiViewController class]]) {
                    eeuiViewController *vc = (eeuiViewController*)view;
                    NSURL *hostUri = [NSURL URLWithString:[vc url]];
                    NSString *hostHP = [NSString stringWithFormat:@"%@:%ld", [hostUri host], (long)[[hostUri port] integerValue]];
                    if (![hostHP isEqualToString:valueHP]) {
                        meetSkip = NO;
                    }
                } else {
                    meetSkip = NO;
                }
            }
            if (meetSkip) {
                return;
            }
        }
        [[[DeviceUtil getTopviewControler] navigationController] popToRootViewControllerAnimated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [mController loadUrl:value forceRefresh:NO];
        });
    }else if ([type isEqualToString:@"HOMEPAGEBACK"]) {
        [mController loadUrl:value forceRefresh:YES];
    }else if ([type isEqualToString:@"RECONNECT"]) {
        NSURL *url = [NSURL URLWithString:value];
        NSURL *nowUrl = [NSURL URLWithString:[(eeuiViewController*)[DeviceUtil getTopviewControler] url]];
        NSString *urlHost = [NSString stringWithFormat:@"%@:%ld", [url host], (long)[[url port] integerValue]];
        NSString *nowHost = [NSString stringWithFormat:@"%@:%ld", [nowUrl host], (long)[[nowUrl port] integerValue]];
        if (![nowHost isEqualToString:urlHost]) {
            [self webSocket:webSocket didReceiveMessage:[NSString stringWithFormat:@"HOMEPAGE:%@", [url absoluteString]]];
        }
    }else if ([type isEqualToString:@"RELOADPAGE"]) {
        NSString *url = value;
        NSString *nowUrl = [(eeuiViewController*)[DeviceUtil getTopviewControler] url];
        if ([nowUrl hasPrefix:url]) {
            [self refresh];
            return;
        }
        BOOL already = NO;
        NSDictionary *viewData = [[eeuiNewPageManager sharedIntstance] getViewData];
        for (NSString *pageName in viewData) {
            id view = [viewData objectForKey:pageName];
            if ([view isKindOfClass:[eeuiViewController class]]) {
                eeuiViewController *vc = (eeuiViewController*)view;
                if ([[DeviceUtil realUrl:[vc url]] hasPrefix:url]) {
                    [vc setResumeUrl:url];
                    already = YES;
                }
            }
        }
        if (already == NO) {
            NSDictionary *tabViewDebug = [eeuiNewPageManager getTabViewDebug];
            for (NSString *pageName in tabViewDebug) {
                WXModuleKeepAliveCallback call = (WXModuleKeepAliveCallback) [tabViewDebug objectForKey:pageName];
                if (call != nil) {
                    call(url, true);
                }
            }
        }
    }else if ([type isEqualToString:@"REFRESH"]) {
        [self refresh];
    }
}

//请求长链接失败 及其原因
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    if ([deBugWsOpenUrl isEqualToString:[NSString stringWithFormat:@"%@:%@", socketHost, socketPort]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            EELog(@"[socket] %@ - fail", @"reconnect");
            [self setSocketConnect:@"reconnect"];
        });
    } else {
        EELog(@"[socket] %@", @"onFailure");
        [[eeuiToastManager sharedIntstance] toast:[NSString stringWithFormat:@"WiFi同步连接失败：%@", [error localizedDescription]]];
    }
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    if (self.isSocketConnect != NO) {
        self.isSocketConnect = NO;
        [self setDebugBtn:self.isSocketConnect];
    }
}

//长链接断开 及其原因
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    if ([deBugWsOpenUrl isEqualToString:[NSString stringWithFormat:@"%@:%@", socketHost, socketPort]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            EELog(@"[socket] %@ - close", @"reconnect");
            [self setSocketConnect:@"reconnect"];
        });
    } else {
        EELog(@"[socket] %@", @"onClosed");
        [[eeuiToastManager sharedIntstance] toast:[NSString stringWithFormat:@"WiFi同步连接失败：%@", reason]];
    }
    //
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    if (self.isSocketConnect != NO) {
        self.isSocketConnect = NO;
        [self setDebugBtn:self.isSocketConnect];
    }
}

//配置屏幕可旋转方向
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

@end
