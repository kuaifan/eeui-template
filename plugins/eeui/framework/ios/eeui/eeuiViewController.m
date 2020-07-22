//
//  eeuiViewController.m
//  WeexTestDemo
//
//  Created by apple on 2018/5/31.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiViewController.h"
#import "WeexSDK.h"
#import "eeuiStorageManager.h"
#import "eeuiNewPageManager.h"
#import "CustomWeexSDKManager.h"
#import "DeviceUtil.h"
#import "Config.h"
#import "Cloud.h"
#import "Debug.h"
#import "AFNetworking.h"
#import "SGEasyButton.h"
#import "SDWebImageDownloader.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@import WebKit;

#define kCacheUrl @"cache_url"
#define kCacheTime @"cache_time"

#define kLifeCycle @"lifecycle"//生命周期

static int easyNavigationButtonTag = 8000;

@interface eeuiViewController ()<WKNavigationDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) WXSDKInstance *instance;
@property (nonatomic, strong) UIView *weexView;
@property (nonatomic, assign) CGFloat weexHeight;
@property (nonatomic, strong) NSMutableArray *listenerList;
@property (nonatomic, strong) NSString *renderUrl;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIView *statusBar;
@property (nonatomic, assign) NSString *notificationStatus;
@property (nonatomic, assign) NSString *lifeCycleLastStatus;
@property (nonatomic, assign) NSString *lifeCycleLastStatusChild;
@property (nonatomic, assign) BOOL didWillEnter;

@property (nonatomic, strong) NSMutableDictionary *navigationCallbackDictionary;

@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UIScrollView *errorInfoView;
@property (nonatomic, strong) NSString *errorContent;
@property (nonatomic, strong) NSString *navigationBarBarColor;
@property (nonatomic, strong) UIColor *navigationBarBarTintColor;

@property (nonatomic, strong) UIView *consoleView;
@property (nonatomic, strong) UIView *consoleWeexView;

@property (nonatomic, strong) UIView *versionUpdateView;
@property (nonatomic, strong) UIView *versionUpdateWeexView;

@end

@implementation eeuiViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setFd_prefersNavigationBarHidden:YES];
    
    if (!_isDisSwipeFullBack) {
        [self setFd_interactivePopMaxAllowedInitialDistanceToLeftEdge:35.0f];
    }

    if (_isDisSwipeBack || [_animatedType isEqualToString:@"present"]) {
        [self setFd_interactivePopDisabled:YES];
    }

    [self.view setClipsToBounds:YES];

    _identify = [NSString stringWithFormat: @"%d", arc4random() % 100000];
    _weexHeight = self.view.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    _cache = 0;

    _showNavigationBar = YES;
    _statusBarAlpha = 0;

    _startLoadTime = 0;
    _pauseTimeStart = 0;
    _pauseTimeSecond = 0;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(postMessage:) name:@"VCPostMessage" object:nil];
    _keyBoardlsVisible = NO;

    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    if (!_isChildSubview) {
        [self.navigationController setNavigationBarHidden:_showNavigationBar];
    }

    if (_backgroundColor) {
        self.view.backgroundColor = [WXConvert UIColor:_backgroundColor];
    }

    [self setupUI];

    if ([_pageType isEqualToString:@"auto"]) {
        _pageType = @"web";
        if ([_url hasSuffix:@".bundle.wx"]) {
            _pageType = @"app";
        }else if ([_url containsString:@"?_wx_tpl="]) {
            NSRange range = [_url rangeOfString:@"?_wx_tpl="];
            _pageType = @"app";
            _url = [_url substringToIndex:range.location];
        }else {
            [self setupActivityView];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.url] encoding:NSUTF8StringEncoding error:nil];
                NSRange range = [html rangeOfString:@"\n"];
                if (range.location != NSNotFound) {
                    html = [html substringToIndex:range.location];
                    html = [html stringByReplacingOccurrencesOfString:@" " withString:@""];
                }
                if ([html hasPrefix:@"//{\"framework\":\"Vue\""]) {
                    self.pageType = @"app";
                }
                [self loadBegin];
            });
            return;
        }
    }

    [self loadBegin];
}

- (void) loadBegin
{
    if ([_pageType isEqualToString:@"web"]) {
        [self loadWebPage];
    } else {
        [self loadWeexPage];
    }

    [self setupActivityView];

    [self setupNaviBar];

    [self updateStatus:@"create"];

    [CustomWeexSDKManager setKeyBoardlsVisible:_keyBoardlsVisible];
    [CustomWeexSDKManager setSoftInputMode:_softInputMode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateStatus:@"start"];

    if ([_statusBarType isEqualToString:@"fullscreen"]) {
        [UIApplication sharedApplication].statusBarHidden = YES;//状态栏隐藏
    } else {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }

    if (!self.isChildSubview) {
        //状态栏样式
        if (!self.isChildSubview) {
            if ([_statusBarStyleCustom isEqualToString:@"1"]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }else{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateInstanceState:WeexInstanceAppear];

    if (_navigationBarBarTintColor != nil) {
        self.navigationController.navigationBar.barTintColor = _navigationBarBarTintColor;
    }

    if (_resumeUrl.length > 0) {
        [self setResumeUrl:@""];
        [self refreshPage];
    }

    [self updateStatus:@"resume"];
    [self lifeCycleEvent:LifeCycleResume];

    [CustomWeexSDKManager setSoftInputMode:_softInputMode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self updateStatus:@"pause"];
    [self lifeCycleEvent:LifeCyclePause];

    if (!self.isChildSubview) {
        //状态栏样式
        if ([_statusBarStyleCustom isEqualToString:@"1"]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }else{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];

    [self updateStatus:@"stop"];
}

//TODO get height
- (void)viewDidLayoutSubviews
{
    _weexHeight = self.view.frame.size.height;
    UIEdgeInsets safeArea = UIEdgeInsetsZero;

    CGFloat plusY = 0.0;

    if (@available(iOS 11.0, *)) {
        safeArea = self.view.safeAreaInsets;
    }else if (@available(iOS 9.0, *)) {
        safeArea.top = 20;
        if (![self fd_prefersNavigationBarHidden]) {
            plusY = self.navigationController.navigationBar.frame.size.height;
        }
    }
    if (_safeAreaBottom.length > 0) {
        safeArea.bottom = [_safeAreaBottom integerValue];
    }

    //自定义状态栏
    if ([_statusBarType isEqualToString:@"fullscreen"] || [_statusBarType isEqualToString:@"immersion"]) {
        _statusBar.hidden = YES;
        if ([_pageType isEqualToString:@"web"]) {
            _webView.frame = CGRectMake(safeArea.left, 0 + plusY, self.view.frame.size.width - safeArea.left - safeArea.right, _weexHeight - plusY - safeArea.bottom);
        }else{
            _instance.frame = CGRectMake(safeArea.left, 0 + plusY, self.view.frame.size.width - safeArea.left - safeArea.right, _weexHeight - plusY - safeArea.bottom);
        }
    } else {
        CGFloat top = 0;
        if (!_isChildSubview) {
            top = safeArea.top;
            _statusBar.hidden = NO;
            _statusBar.frame = CGRectMake(0, 0, self.view.frame.size.width, safeArea.top);
        }

        if ([_pageType isEqualToString:@"web"]) {
            _webView.frame = CGRectMake(safeArea.left, top + plusY, self.view.frame.size.width - safeArea.left - safeArea.right, _weexHeight - top - plusY - safeArea.bottom);
        }else{
            _instance.frame = CGRectMake(safeArea.left, top + plusY, self.view.frame.size.width - safeArea.left - safeArea.right, _weexHeight - top - plusY - safeArea.bottom);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    EELog(@"gggggggg::dealloc:%@", self.pageName);
    [[eeuiStorageManager sharedIntstance] setPageScriptUrl:[NSString stringWithFormat:@"%@", _instance.scriptURL] url:_url];

    self.identify = @"";
    [self updateStatus:@"destroy"];
    [self lifeCycleEvent:LifeCycleDestroy];

    [_instance destroyInstance];
#ifdef DEBUG
    [_instance forceGarbageCollection];
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];

    if (parent == nil) {
        [[eeuiNewPageManager sharedIntstance] removePageData:self.pageName];
    }
}


//键盘弹出触发该方法
- (void)keyboardDidShow:(NSNotification *)notification
{
    _keyBoardlsVisible = YES;
    [CustomWeexSDKManager setKeyBoardlsVisible:_keyBoardlsVisible];
}

// 键盘隐藏触发该方法
- (void)keyboardDidHide:(NSNotification *)notification
{
    _keyBoardlsVisible = NO;
    [CustomWeexSDKManager setKeyBoardlsVisible:_keyBoardlsVisible];
}

// 页面失活
- (void)applicationWillResignActive:(NSNotification *)notification
{
    _isResignActive = YES;
    [_instance fireGlobalEvent:@"__appLifecycleStatus" params:@{
            @"status": @"deactive",
            @"type": @"app",
            @"pageType": _isChildSubview ? @"tabbar" : _pageType,
            @"pageName": _pageName,
            @"pageUrl": _url,
    }];
}

// 页面重活（失活之后）
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (_isResignActive) {
        [_instance fireGlobalEvent:@"__appLifecycleStatus" params:@{
                @"status": @"active",
                @"type": @"app",
                @"pageType": _isChildSubview ? @"tabbar" : _pageType,
                @"pageName": _pageName,
                @"pageUrl": _url,
        }];
    }
}

// 页面接收到消息
- (void)postMessage:(NSNotification *)notification
{
    NSString *pageName = nil;
    id message = [notification object];
    if ([message isKindOfClass:[NSDictionary class]]) {
        pageName = [WXConvert NSString:message[@"pageName"]];
    }
    if (pageName.length == 0 || [pageName isEqualToString:_pageName]) {
        [_instance fireGlobalEvent:@"__appLifecycleStatus" params:@{
                @"status": @"message",
                @"type": @"page",
                @"pageType": _isChildSubview ? @"tabbar" : _pageType,
                @"pageName": _pageName,
                @"pageUrl": _url,
                @"message": message
        }];
    }
}

// iOS 13
- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([_statusBarStyleCustom isEqualToString:@"1"]) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
}

#pragma mark 生命周期
- (void)lifeCycleEvent:(LifeCycleType)type
{
    //页面生命周期:生命周期
    NSString *status = @"";
    switch (type) {
        case LifeCycleReady:
            status = @"ready";
            if (_startLoadTime == 0) {
                _startLoadTime = (long) [[NSDate date] timeIntervalSince1970];
            }
            break;

        case LifeCycleResume:
            status = @"resume";
            if (_pauseTimeStart > 0) {
                _pauseTimeSecond += MAX((long) [[NSDate date] timeIntervalSince1970] - _pauseTimeStart, 0);
            }
            break;

        case LifeCyclePause:
            status = @"pause";
            _pauseTimeStart = (long) [[NSDate date] timeIntervalSince1970];
            break;

        case LifeCycleDestroy:
            status = @"destroy";
            if (!_isChildSubview) {
                [self durationTime];
            }
            break;

        default:
            return;
    }
    if ([status isEqualToString:_lifeCycleLastStatus]) {
        return;
    }
    _lifeCycleLastStatus = status;

    for (UIViewController * childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[eeuiViewController class]]) {
            eeuiViewController *vc = (eeuiViewController*) childViewController;
            if ([status isEqualToString:@"pause"]) {
                if ([vc.lifeCycleLastStatus isEqualToString:@"resume"]) {
                    [vc lifeCycleEvent:type];
                    vc.lifeCycleLastStatusChild = status;
                }
            }else if ([status isEqualToString:@"resume"]) {
                if ([vc.lifeCycleLastStatusChild isEqualToString:@"pause"]) {
                    [vc lifeCycleEvent:type];
                    vc.lifeCycleLastStatusChild = status;
                }
            }
        }
    }

    [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:kLifeCycle params:@{@"status":status} domChanges:nil];
    [_instance fireGlobalEvent:@"__appLifecycleStatus" params:@{
            @"status": status,
            @"type": @"page",
            @"pageType": _isChildSubview ? @"tabbar" : _pageType,
            @"pageName": _pageName,
            @"pageUrl": _url,
    }];
}

#pragma mark duration
- (void)durationTime
{
    long timeStamp = (long) [[NSDate date] timeIntervalSince1970];
    long duration = timeStamp - _startLoadTime - _pauseTimeSecond;
    NSString *url = _url;
    if ([url hasPrefix:@"file://"]) {
        url = [Config getMiddle:url start:@"bundlejs/eeui" to:nil];
    }
    if (duration > 0) {
        NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
        obj[@"s"] = @(_startLoadTime);
        obj[@"d"] = @(duration);
        obj[@"p"] = @(_pauseTimeSecond);
        obj[@"u"] = url;
        //
        eeuiStorageManager *storage = [eeuiStorageManager sharedIntstance];
        long submitTime = [[storage getCaches:@"__system:pageDurationSubmitTime" defaultVal:@(0)] longValue];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        id tmp = [storage getCaches:@"__system:pageDurationData" defaultVal:@[]];
        if ([tmp isKindOfClass:[NSArray class]]) {
            data = [tmp mutableCopy];
        }
        [data addObject:[obj mutableCopy]];
        //
        if (timeStamp - submitTime >= 60 || data.count > 50 || _isFirstPage) {
            [storage setCaches:@"__system:pageDurationSubmitTime" value:@(timeStamp) expired:60];
            [self durationSubmit:data];
            data = [[NSMutableArray alloc] init];
        }
        [storage setCaches:@"__system:pageDurationData" value:data expired:0];
    }
}

- (void)durationSubmit:(NSArray *)array
{
    if (array.count == 0) {
        return;
    }
    NSString *appkey = [Config getString:@"appKey" defaultVal:@""];
    if (appkey.length == 0) {
        return;
    }
    NSString *url = [Cloud getUrl:@"duration"];
    NSString *package = [[NSBundle mainBundle]bundleIdentifier];
    NSString *version = [NSString stringWithFormat:@"%ld", (long)[Config getLocalVersion]];
    NSString *versionName = [Config getLocalVersionName];
    NSString *screenWidth = [NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.width];
    NSString *screenHeight = [NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.height];
    NSString *debug = @"0";
    #if DEBUG
    debug = @"1";
    #endif
    NSDictionary *params = @{@"firstpage": @(_isFirstPage ? 1 : 0),
            @"data": [DeviceUtil arrayToJson:array],
            @"appkey": appkey,
            @"package": package,
            @"version": version,
            @"versionName": versionName,
            @"screenWidth": screenWidth,
            @"screenHeight": screenHeight,
            @"platform": @"ios",
            @"debug": debug};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @try {
            if (responseObject) {
                if ([[responseObject objectForKey:@"ret"] integerValue] == 1) {
                    NSDictionary *data = responseObject[@"data"];
                    NSMutableDictionary *jsonData = [NSMutableDictionary dictionaryWithDictionary:data];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        //
                        if ([[jsonData objectForKey:@"uplists"] isKindOfClass:[NSArray class]]) {
                            [Cloud checkUpdateLists:[jsonData objectForKey:@"uplists"] number:0];
                        }
                        [Cloud checkVersionUpdate:jsonData];
                    });
                }
            }
        }@catch (NSException *exception) { }
    } failure:nil];
}

#pragma mark view
- (void)setupUI
{
    self.statusBar = [[UIView alloc] init];
    CGFloat alpha = ((255 - _statusBarAlpha)*1.0/255);
    _statusBar.backgroundColor = [[WXConvert UIColor:_statusBarColor?_statusBarColor : @"#3EB4FF"] colorWithAlphaComponent:alpha];
    [self.view addSubview:_statusBar];
    _statusBar.hidden = YES;
}

- (void)setupActivityView
{
    //加载图
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        if (self.isChildSubview) {
            self.activityIndicatorView.center = CGPointMake(self.parentFrameCGRect.size.width * 0.5, self.parentFrameCGRect.size.height * 0.5);
        }else{
            self.activityIndicatorView.center = self.view.center;
        }
        self.activityIndicatorView.color = [WXConvert UIColor:@"#cccccc"];
        [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.activityIndicatorView];
    }
    [self startLoading];
}

- (void)setupNaviBar
{
    if (_pageTitle.length > 0) {
        [self setNavigationTitle:_pageTitle callback:nil];
    }
}

- (void)loadWebPage
{
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.navigationDelegate = self;
    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

- (void)loadWeexPage
{
    [self readyWeexPage:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self renderView];
        });
    }];
}

- (void)readyWeexPage:(void(^)(void))callback
{
    NSInteger cache = self.cache;
    if ([_url hasPrefix:@"file://"]) {
        cache = 0;
    }
    NSString *tempUrl = [Config verifyFile:_url];
    NSString *appboard = [DeviceUtil getAppboardContent];
    if (cache >= 1000 || appboard.length > 0) {
        _isCache = YES;
        [DeviceUtil downloadScript:tempUrl appboard:appboard cache:cache callback:^(NSString *path) {
            self.renderUrl = path == nil ? tempUrl : path;
            callback();
        }];
    }else{
        _isCache = NO;
        self.renderUrl = tempUrl;
        callback();
    }
}

- (void)renderView
{
    if (self.errorView != nil) {
        [self.errorView removeFromSuperview];
        self.errorView = nil;
    }
    if (self.errorInfoView != nil) {
        [self.errorInfoView removeFromSuperview];
        self.errorInfoView = nil;
    }

    CGFloat width = self.view.frame.size.width;
    [_instance destroyInstance];
    _instance = [[WXSDKInstance alloc] init];

    if([WXPrerenderManager isTaskExist:self.url]){
        _instance = [WXPrerenderManager instanceFromUrl:self.url];
    }

    _instance.viewController = self;
    UIEdgeInsets safeArea = UIEdgeInsetsZero;

    if (@available(iOS 11.0, *)) {
        safeArea = self.view.safeAreaInsets;
    }else if (@available(iOS 9.0, *)) {
        safeArea.top = 20;
    }

    _instance.frame = CGRectMake(self.view.frame.size.width-width, safeArea.top, width, _weexHeight-safeArea.bottom);

    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, weakSelf.weexView);
        if (weakSelf.consoleView != nil) {
            [weakSelf.view bringSubviewToFront:weakSelf.consoleView];
        }
        if (weakSelf.versionUpdateView != nil) {
            [weakSelf.view bringSubviewToFront:weakSelf.versionUpdateView];
        }

        [weakSelf updateStatus:@"viewCreated"];
    };

    _instance.onJSRuntimeException = ^(WXJSExceptionInfo *jsException) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopLoading];
            [weakSelf updateStatus:@"error"];
            [weakSelf showErrorBox:jsException.errorCode];
            weakSelf.errorContent = jsException.exception;
            [Debug addDebug:@"error" log:[NSString stringWithFormat: @"%@ (errCode:%@)", weakSelf.errorContent, jsException.errorCode] pageUrl:weakSelf.url];
        });
    };

    _instance.onFailed = ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopLoading];
            [weakSelf updateStatus:@"error"];
            
            if ([[error domain] isEqualToString:@"1"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableString *errMsg=[NSMutableString new];
                    [errMsg appendFormat:@"ErrorType:%@\n",[error domain]];
                    [errMsg appendFormat:@"ErrorCode:%ld\n",(long)[error code]];
                    [errMsg appendFormat:@"ErrorInfo:%@\n", [error userInfo]];
                    EELog(@"%@", errMsg);
                });
            }
            
            [weakSelf showErrorBox:[NSString stringWithFormat: @"%ld", (long)[error code]]];
            weakSelf.errorContent = [error description];
            [Debug addDebug:@"error" log:[NSString stringWithFormat: @"%@ (errCode:%ld)", weakSelf.errorContent, (long)[error code]] pageUrl:weakSelf.url];
        });
    };

    _instance.renderFinish = ^(UIView *view) {
        WXLogDebug(@"%@", @"Render Finish...");
        [weakSelf updateInstanceState:WeexInstanceAppear];
        [weakSelf stopLoading];
        [weakSelf updateStatus:@"renderSuccess"];
        [weakSelf lifeCycleEvent:LifeCycleReady];
        if (!weakSelf.isTabbarChildView || weakSelf.isTabbarChildSelected) {
            [weakSelf lifeCycleEvent:LifeCycleResume];
        }
    };

    _instance.updateFinish = ^(UIView *view) {
        WXLogDebug(@"%@", @"Update Finish...");
    };

    if (!self.url) {
        WXLogError(@"error: render url is nil");
        return;
    }
    if([WXPrerenderManager isTaskExist:self.url]){
        WX_MONITOR_INSTANCE_PERF_START(WXPTJSDownload, _instance);
        WX_MONITOR_INSTANCE_PERF_END(WXPTJSDownload, _instance);
        WX_MONITOR_INSTANCE_PERF_START(WXPTFirstScreenRender, _instance);
        WX_MONITOR_INSTANCE_PERF_START(WXPTAllRender, _instance);
        [WXPrerenderManager renderFromCache:self.url];
        return;
    }
    _instance.viewController = self;

    [_instance renderWithURL:[NSURL URLWithString:self.renderUrl] options:@{@"params":_params?_params:@""} data:nil];

    if (_didWillEnter == NO) {
        _didWillEnter = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

//显示错误页面
-(void)showErrorBox:(NSString *)errCode
{
    if (self.errorView == nil) {
        self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.errorView setBackgroundColor:[UIColor whiteColor]];

        NSInteger top = [self fd_prefersNavigationBarHidden] == YES ? 100 : 120;
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, 50)];
        label1.text = @"bibi~ 出错啦！";
        label1.textColor = [WXConvert UIColor:@"#3EB4FF"];
        label1.font = [UIFont systemFontOfSize:30.f];
        label1.textAlignment = NSTextAlignmentCenter;
        [self.errorView addSubview:label1];

        top += 50;
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, 30)];
        label2.text = [@"错误代码：" stringByAppendingString:errCode];
        label2.textColor = [WXConvert UIColor:@"#c6c6c6"];
        label2.font = [UIFont systemFontOfSize:13.f];
        label2.textAlignment = NSTextAlignmentCenter;
        [self.errorView addSubview:label2];

        top += 30;
        UILabel * label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, 30)];
        label3.tag = 1000;
        #if DEBUG
            label3.text = @"页面打不开！查看详情";
        #else
            label3.text = @"抱歉！页面出现错误了";
        #endif
        label3.textColor = [WXConvert UIColor:@"#3EB4FF"];
        label3.font = [UIFont systemFontOfSize:13.f];
        label3.textAlignment = NSTextAlignmentCenter;
        #if DEBUG
            label3.userInteractionEnabled = YES;
            [label3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorTabGesture:)]];
        #endif
        [self.errorView addSubview:label3];

        top += 50;
        CGFloat w = self.view.frame.size.width / 24;
        UIButton * button1 = [[UIButton alloc] initWithFrame:CGRectMake(w * 5, top, w * 6, 36)];
        button1.tag = 2000;
        button1.titleLabel.font = [UIFont systemFontOfSize: 13.0];
        button1.layer.cornerRadius = 3;
        [button1 setTitle:@"刷新一下" forState:UIControlStateNormal];
        [button1 setTitleColor:[WXConvert UIColor:@"#ffffff"] forState:UIControlStateNormal];
        [button1 setBackgroundColor:[WXConvert UIColor:@"#327AE2"]];
        [button1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorTabGesture:)]];
        [self.errorView addSubview:button1];

        if (self.isChildSubview) {
            [button1 setFrame:CGRectMake(w * 9, top, w * 6, 36)];
        }else{
            UIButton * button2 = [[UIButton alloc] initWithFrame:CGRectMake(w * 13, top, w * 6, 36)];
            button2.tag = 3000;
            button2.titleLabel.font = [UIFont systemFontOfSize: 13.0];
            button2.layer.cornerRadius = 3;
            [button2 setTitle:@"退后一步" forState:UIControlStateNormal];
            [button2 setTitleColor:[WXConvert UIColor:@"#ffffff"] forState:UIControlStateNormal];
            [button2 setBackgroundColor:[WXConvert UIColor:@"#3497E2"]];
            [button2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorTabGesture:)]];
            [self.errorView addSubview:button2];
        }

        [self.view addSubview:self.errorView];
    }else{
        [self.view bringSubviewToFront:self.errorView];
    }
}

-(void)errorTabGesture:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.view.tag == 1000) {
        [self showFixedInfo:_errorContent];
    }else if (tapGesture.view.tag == 1001) {
        if (self.errorInfoView != nil) {
            [self.errorInfoView removeFromSuperview];
            self.errorInfoView = nil;
        }
    }else if (tapGesture.view.tag == 1002) {
        if (self.consoleView != nil) {
            [Debug setDebugBtnStatus:0];
            [self.consoleView removeFromSuperview];
            self.consoleView = nil;
        }
    }else if (tapGesture.view.tag == 2000) {
        [self refreshPage];
    }else if (tapGesture.view.tag == 3000) {
        [[eeuiNewPageManager sharedIntstance] closePage:nil weexInstance:_instance];
    }
}

- (void)showFixedInfo:(NSString *)text
{
    if (self.errorInfoView == nil) {
        UIEdgeInsets safeArea = UIEdgeInsetsZero;
        self.errorInfoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.errorInfoView.tag = 1001;
        if (@available(iOS 11.0, *)) {
            safeArea = self.view.safeAreaInsets;
            self.errorInfoView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.errorInfoView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.81f]];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        label.text = text;
        label.textColor = [WXConvert UIColor:@"#FFFFFF"];
        label.font = [UIFont systemFontOfSize:13.f];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [label sizeToFit];
        CGRect temp = label.frame;
        temp.origin.y+= safeArea.top;
        [label setFrame:temp];
        [self.errorInfoView setContentSize:CGSizeMake(label.frame.size.width, label.frame.size.height + safeArea.top + safeArea.bottom)];
        [self.errorInfoView addSubview:label];
        [self.errorInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorTabGesture:)]];
        [self.view addSubview:self.errorInfoView];
    }else{
        [self.view bringSubviewToFront:self.errorInfoView];
    }
}

- (void)showFixedConsole
{
    if (self.consoleView == nil) {
        UIEdgeInsets safeArea = UIEdgeInsetsZero;
        self.consoleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.consoleView.tag = 1002;
        if (@available(iOS 11.0, *)) {
            safeArea = self.view.safeAreaInsets;
        }
        [self.consoleView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.75f]];
        CGFloat viewY = self.view.frame.size.height / 5.5;
        UIView * myView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, self.view.frame.size.width, self.view.frame.size.height - viewY)];
        myView.backgroundColor = [WXConvert UIColor:@"#FFFFFF"];
        CGRect temp = myView.frame;
        temp.origin.y+= safeArea.top;
        temp.size.height-= safeArea.top;
        [myView setFrame:temp];
        [self.consoleView addSubview:myView];
        [self.consoleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorTabGesture:)]];
        [self.view addSubview:self.consoleView];
        
        WXSDKInstance *instance = [[WXSDKInstance alloc] init];
        instance.frame = CGRectMake(0, 0, temp.size.width, temp.size.height - safeArea.bottom);
        instance.onCreate = ^(UIView *view) {
            [self->_consoleWeexView removeFromSuperview];
            self->_consoleWeexView = view;
            [myView addSubview:self->_consoleWeexView];
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self->_consoleWeexView);
        };
        NSString *tempUrl = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs/main-console.js"]];
        NSString *appboard = [DeviceUtil getAppboardContent];
        if (appboard.length > 0) {
            [DeviceUtil downloadScript:tempUrl appboard:appboard cache:0 callback:^(NSString *path) {
                [instance renderWithURL:[NSURL URLWithString:path == nil ? tempUrl : path] options:nil data:nil];
            }];
        }else{
            [instance renderWithURL:[NSURL URLWithString:tempUrl] options:nil data:nil];
        }
    }else{
        [self.view bringSubviewToFront:self.consoleView];
    }
}

- (void)hideFixedConsole
{
    if (self.consoleView != nil) {
        [self.consoleView removeFromSuperview];
        self.consoleView = nil;
    }
}

- (void)showFixedVersionUpdate:(NSString *)templateId
{
    if (self.versionUpdateView == nil) {
        UIEdgeInsets safeArea = UIEdgeInsetsZero;
        self.versionUpdateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.versionUpdateView.tag = 1003;
        if (@available(iOS 11.0, *)) {
            safeArea = self.view.safeAreaInsets;
        }
        [self.versionUpdateView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.0f]];
        UIView * myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGRect temp = myView.frame;
        temp.origin.y+= safeArea.top;
        temp.size.height-= safeArea.top;
        [myView setFrame:temp];
        [self.versionUpdateView addSubview:myView];
        [self.view addSubview:self.versionUpdateView];
        
        WXSDKInstance *instance = [[WXSDKInstance alloc] init];
        instance.frame = CGRectMake(0, 0, temp.size.width, temp.size.height - safeArea.bottom);
        instance.onCreate = ^(UIView *view) {
            [self->_versionUpdateWeexView removeFromSuperview];
            self->_versionUpdateWeexView = view;
            [myView addSubview:self->_versionUpdateWeexView];
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self->_versionUpdateWeexView);
        };
        NSString *tempUrl = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:[NSString stringWithFormat:@"bundlejs/version_update/%@.js", templateId]]];
        NSString *appboard = [DeviceUtil getAppboardContent];
        if (appboard.length > 0) {
            [DeviceUtil downloadScript:tempUrl appboard:appboard cache:0 callback:^(NSString *path) {
                [instance renderWithURL:[NSURL URLWithString:path == nil ? tempUrl : path] options:nil data:nil];
            }];
        }else{
            [instance renderWithURL:[NSURL URLWithString:tempUrl] options:nil data:nil];
        }
    }else{
        [self.view bringSubviewToFront:self.versionUpdateView];
    }
}

- (void)hideFixedVersionUpdate
{
    if (self.versionUpdateView != nil) {
        [self.versionUpdateView removeFromSuperview];
        self.versionUpdateView = nil;
    }
}

- (void)appDidEnterBackground:(NSNotification*)notification
{
    if ([self.lifeCycleLastStatus isEqualToString:@"resume"]) {
        [self updateStatus:@"pause"];
        [self lifeCycleEvent:LifeCyclePause];
        self.lifeCycleLastStatusChild = @"pause";
    }
}

- (void)appWillEnterForeground:(NSNotification*)notification
{
    if ([self.lifeCycleLastStatusChild isEqualToString:@"pause"]) {
        [self updateStatus:@"resume"];
        [self lifeCycleEvent:LifeCycleResume];
        self.lifeCycleLastStatusChild = @"resume";
    }
}

- (void)stopLoading
{
    [self.activityIndicatorView setHidden:YES];
    [self.activityIndicatorView stopAnimating];
}

- (void)startLoading
{
    if (_loading) {
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicatorView startAnimating];
    }
}

- (void)updateInstanceState:(WXState)state
{
    if (_instance && _instance.state != state) {
        _instance.state = state;

        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}

- (void)updateStatus:(NSString*)status
{
    if (self.statusBlock) {
        self.statusBlock(status);
    }
    
    if ([status isEqualToString:@"viewCreated"]) {
        _loadTime = (long) [[NSDate date] timeIntervalSince1970];
        [[eeuiNewPageManager sharedIntstance] setPageDataValue:self.pageName key:@"loadTime"
                                                         value:[DeviceUtil timesFromString:[NSString stringWithFormat:@"%ld", (long)_loadTime]]];
    }

    //通知监听
    if ([status isEqualToString:_notificationStatus]) {
        return;
    }
    _notificationStatus = status;
    for (NSString *key in self.listenerList) {
        [[NSNotificationCenter defaultCenter] postNotificationName:key object:@{@"status":status, @"listenerName":key}];
    }
}

- (void)setHomeUrl:(NSString*)url refresh:(BOOL)refresh
{
    self.url = url;
    [[eeuiNewPageManager sharedIntstance] setPageDataValue:self.pageName key:@"url" value:self.url];
    if (refresh) {
        [self refreshPage];
    }
}

- (void)setResumeUrl:(NSString *)url
{
    _resumeUrl = url;
}

- (void)addStatusListener:(NSString*)name
{
    if (!self.listenerList) {
        self.listenerList = [NSMutableArray arrayWithCapacity:5];
    }

    if (![self.listenerList containsObject:name]) {
        [self.listenerList addObject:name];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listennerEvent:) name:name object:nil];
    }
}

- (void)clearStatusListener:(NSString*)name
{
    if ([self.listenerList containsObject:name]) {
        [self.listenerList removeObject:name];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
    }
}

- (void)listennerEvent:(NSNotification*)notification
{
    id obj = notification.object;
    if (obj) {
        if (self.listenerBlock) {
            self.listenerBlock(obj);
        }
    }
}

- (void)postStatusListener:(NSString*)name data:(id)data
{
    if (name.length > 0) {
        if ([self.listenerList containsObject:name]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:data];
        }
    } else {
        for (NSString *key in self.listenerList) {
            [[NSNotificationCenter defaultCenter] postNotificationName:key object:data];
        }
    }
}


#pragma mark - refresh
- (void)refreshPage
{
    [self startLoading];
    
    if (_isCache) {
        [self readyWeexPage:^{ [self refreshPageExecution]; }];
    }else{
        [self refreshPageExecution];
    }
}

- (void)refreshPageExecution
{
    self.identify = [NSString stringWithFormat: @"%d", arc4random() % 100000];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideNavigation];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.titleView = nil;
        [self setupNaviBar];
        
        if ([self->_pageType isEqualToString:@"web"]) {
            [self.webView reload];
        } else {
            [self renderView];
            [self updateStatus:@"restart"];
        }
    });
}

#pragma mark - notification
- (void)notificationRefreshInstance:(NSNotification *)notification {
    [self refreshPage];
}

#pragma mark- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController && [self.navigationController.viewControllers count] == 1) {
        return NO;
    }
    return YES;
}

#pragma mark webDelegate
//开始加载网页
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    self.webBlock(@{@"status":@"statusChanged", @"webStatus":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@"", @"title":@""});
}

//网页加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:( WKNavigation *)navigation
{
    [self stopLoading];

    NSString *title = [webView title];
    if (![self.title isEqualToString:title]) {
        self.title = title;
        self.webBlock(@{@"status":@"titleChanged", @"webStatus":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@"", @"title":title});
    }
}

//网页加载错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error) {
        [self stopLoading];

        if (error) {
            NSString *code = [NSString stringWithFormat:@"%ld", (long) error.code];
            NSString *msg = [NSString stringWithFormat:@"%@", error.description];
            self.webBlock(@{@"status":@"errorChanged", @"webStatus":@"", @"errCode":code, @"errMsg":msg, @"errUrl":_url, @"title":@""});
        }
    }
}

//设置页面标题栏标题
- (void)setNavigationTitle:(id) params callback:(WXModuleKeepAliveCallback) callback
{
    if ([_statusBarType isEqualToString:@"fullscreen"] || [_statusBarType isEqualToString:@"immersion"]) {
        return;
    }
    if (nil == _navigationCallbackDictionary) {
        _navigationCallbackDictionary = [[NSMutableDictionary alloc] init];
    }

    NSDictionary *defaultStyles = [Config getObject:@"navigationBarStyle"];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    if ([params isKindOfClass:[NSString class]]) {
        item[@"title"] = [WXConvert NSString:params];
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        item = [params copy];
    }

    
    NSString *title = item[@"title"] ? [WXConvert NSString:item[@"title"]] : (defaultStyles[@"title"] ? [WXConvert NSString:defaultStyles[@"title"]] : @"");
    NSString *titleColor = item[@"titleColor"] ? [WXConvert NSString:item[@"titleColor"]] : (defaultStyles[@"titleColor"] ? [WXConvert NSString:defaultStyles[@"titleColor"]] : @"");
    CGFloat titleSize = item[@"titleSize"] ? [WXConvert CGFloat:item[@"titleSize"]] : (defaultStyles[@"titleSize"] ? [WXConvert CGFloat:defaultStyles[@"titleSize"]] : 32.0);
    BOOL titleBold = item[@"titleBold"] ? [item[@"titleBold"] boolValue] : [defaultStyles[@"titleBold"] boolValue];
    NSString *subtitle = item[@"subtitle"] ? [WXConvert NSString:item[@"subtitle"]] : (defaultStyles[@"subtitle"] ? [WXConvert NSString:defaultStyles[@"subtitle"]] : @"");
    NSString *subtitleColor = item[@"subtitleColor"] ? [WXConvert NSString:item[@"subtitleColor"]] : (defaultStyles[@"subtitleColor"] ? [WXConvert NSString:defaultStyles[@"subtitleColor"]] : @"");
    CGFloat subtitleSize = item[@"subtitleSize"] ? [WXConvert CGFloat:item[@"subtitleSize"]] : (defaultStyles[@"subtitleSize"] ? [WXConvert CGFloat:defaultStyles[@"subtitleSize"]] : 24.0);
    _navigationBarBarColor = item[@"backgroundColor"] ? [WXConvert NSString:item[@"backgroundColor"]] : (_statusBarColor ? _statusBarColor : (defaultStyles[@"backgroundColor"] ? [WXConvert NSString:defaultStyles[@"backgroundColor"]] : @"#3EB4FF"));

    //背景色
    CGFloat alpha = (255 - _statusBarAlpha) * 1.0 / 255;
    _navigationBarBarTintColor = [[WXConvert UIColor:_navigationBarBarColor] colorWithAlphaComponent:alpha];
    self.navigationController.navigationBar.barTintColor = _navigationBarBarTintColor;
    [self showNavigation];
    
    //文字默认颜色
    if (titleColor.length == 0) {
        titleColor = [_navigationBarBarColor isEqualToString:@"#3EB4FF"] ? @"#ffffff" : @"#232323";
    }
    if (subtitleColor.length == 0) {
        subtitleColor = [_navigationBarBarColor isEqualToString:@"#3EB4FF"] ? @"#ffffff" : @"#232323";
    }

    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[WXConvert UIColor:titleColor]];
    [titleLabel setText:[[NSString alloc] initWithFormat:@"  %@  ", title]];
    if (titleBold) {
        [titleLabel setFont:[UIFont boldSystemFontOfSize:[self NAVSCALE:titleSize]]];
    } else {
        [titleLabel setFont:[UIFont systemFontOfSize:[self NAVSCALE:titleSize]]];
    }
    
    [titleLabel sizeToFit];

    if (subtitle.length > 0) {
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 19, 0, 0)];
        [subtitleLabel setBackgroundColor:[UIColor clearColor]];
        [subtitleLabel setTextColor:[WXConvert UIColor:subtitleColor]];
        [subtitleLabel setText:[[NSString alloc] initWithFormat:@"  %@  ", subtitle]];
        [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:[self NAVSCALE:subtitleSize]]];
        [subtitleLabel sizeToFit];

        UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subtitleLabel.frame.size.width, titleLabel.frame.size.width), 30)];
        [twoLineTitleView addSubview:titleLabel];
        [twoLineTitleView addSubview:subtitleLabel];

        float widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width;
        if (widthDiff > 0) {
            CGRect frame = titleLabel.frame;
            frame.origin.x = widthDiff / 2;
            titleLabel.frame = CGRectIntegral(frame);
        } else{
            CGRect frame = subtitleLabel.frame;
            frame.origin.x = fabs(widthDiff) / 2;
            subtitleLabel.frame = CGRectIntegral(frame);
        }
        if (callback) {
            twoLineTitleView.userInteractionEnabled = YES;
            twoLineTitleView.tag = ++easyNavigationButtonTag;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationTitleClick:)];
            [twoLineTitleView addGestureRecognizer:tapGesture];
            [_navigationCallbackDictionary setObject:@{@"callback":[callback copy], @"params":[item copy]} forKey:@(twoLineTitleView.tag)];
        }
        self.navigationItem.titleView = twoLineTitleView;
    }else{
        if (callback) {
            titleLabel.userInteractionEnabled = YES;
            titleLabel.tag = ++easyNavigationButtonTag;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationTitleClick:)];
            [titleLabel addGestureRecognizer:tapGesture];
            [_navigationCallbackDictionary setObject:@{@"callback":[callback copy], @"params":[item copy]} forKey:@(titleLabel.tag)];
        }
        self.navigationItem.titleView = titleLabel;
    }

    if (!_isFirstPage && self.navigationItem.leftBarButtonItems.count == 0) {
        NSDictionary *defaultStyles = [Config getObject:@"navigationBarStyle"];
        defaultStyles = defaultStyles[@"left"] ? defaultStyles[@"left"] : nil;
        [self setNavigationItems:@{@"icon":defaultStyles[@"icon"] ? defaultStyles[@"icon"] : @"tb-back", @"iconSize":defaultStyles[@"iconSize"] ? defaultStyles[@"iconSize"] : @(36)} position:@"left" callback:^(id result, BOOL keepAlive) {
            [[[DeviceUtil getTopviewControler] navigationController] popViewControllerAnimated:YES];
        }];
    }
}

//设置页面标题栏左右按钮
- (void)setNavigationItems:(id) params position:(NSString *)position callback:(WXModuleKeepAliveCallback) callback
{
    if (nil == _navigationCallbackDictionary) {
        _navigationCallbackDictionary = [[NSMutableDictionary alloc] init];
    }

    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];

    if ([params isKindOfClass:[NSString class]]) {
        [buttonArray addObject:@{@"title": [WXConvert NSString:params]}];
    } else if ([params isKindOfClass:[NSArray class]]) {
        buttonArray = params;
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        [buttonArray addObject:params];
    }

    NSDictionary *defaultStyles = [Config getObject:@"navigationBarStyle"];
    defaultStyles = defaultStyles[position] ? defaultStyles[position] : nil;
    
    UIView *buttonItems = [[UIView alloc] init];
    for (NSDictionary *item in buttonArray)
    {
        NSString *title = item[@"title"] ? [WXConvert NSString:item[@"title"]] : (defaultStyles[@"title"] ? [WXConvert NSString:defaultStyles[@"title"]] : @"");
        NSString *titleColor = item[@"titleColor"] ? [WXConvert NSString:item[@"titleColor"]] : (defaultStyles[@"titleColor"] ? [WXConvert NSString:defaultStyles[@"titleColor"]] : @"");
        CGFloat titleSize = item[@"titleSize"] ? [WXConvert CGFloat:item[@"titleSize"]] : (defaultStyles[@"titleSize"] ? [WXConvert CGFloat:defaultStyles[@"titleSize"]] : 28.0);
        BOOL titleBold = item[@"titleBold"] ? [item[@"titleBold"] boolValue] : [defaultStyles[@"titleBold"] boolValue];
        NSString *icon = item[@"icon"] ? [WXConvert NSString:item[@"icon"]] : (defaultStyles[@"icon"] ? [WXConvert NSString:defaultStyles[@"icon"]] : @"");
        NSString *iconColor = item[@"iconColor"] ? [WXConvert NSString:item[@"iconColor"]] : (defaultStyles[@"iconColor"] ? [WXConvert NSString:defaultStyles[@"iconColor"]] : @"");
        CGFloat iconSize = item[@"iconSize"] ? [WXConvert CGFloat:item[@"iconSize"]] : (defaultStyles[@"iconSize"] ? [WXConvert CGFloat:defaultStyles[@"iconSize"]] : 28.0);
        NSInteger width = item[@"width"] ? [WXConvert NSInteger:item[@"width"]]  : (defaultStyles[@"width"] ? [WXConvert CGFloat:defaultStyles[@"width"]] : 0);
        NSInteger spacing = item[@"spacing"] ? [WXConvert NSInteger:item[@"spacing"]] : (defaultStyles[@"spacing"] ? [WXConvert CGFloat:defaultStyles[@"spacing"]] : 10);
        
        //文字默认颜色
        if (titleColor.length == 0) {
            titleColor = [_navigationBarBarColor isEqualToString:@"#3EB4FF"] ? @"#ffffff" : @"#232323";
        }
        if (iconColor.length == 0) {
            iconColor = [_navigationBarBarColor isEqualToString:@"#3EB4FF"] ? @"#ffffff" : @"#232323";
        }

        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (icon.length > 0) {
            if (![self isFontIcon:icon]) {
                icon = [DeviceUtil rewriteUrl:icon mInstance:[[WXSDKManager bridgeMgr] topInstance]];
                [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:icon] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image) {
                        WXPerformBlockOnMainThread(^{
                            [customButton setImage:[DeviceUtil imageResize:image andResizeTo:CGSizeMake([self NAVSCALE:iconSize], [self NAVSCALE:iconSize]) icon:nil] forState:UIControlStateNormal];
                            [customButton SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing: (icon.length > 0 && title.length > 0) ? [self NAVSCALE:spacing] : 0];
                        });
                    }
                }];
            } else {
                [customButton setImage:[DeviceUtil getIconText:icon font:[self NAVSCALE:iconSize] color:iconColor] forState:UIControlStateNormal];
            }
        }
        if (title.length > 0){
            if (titleBold) {
                customButton.titleLabel.font = [UIFont boldSystemFontOfSize:[self NAVSCALE:titleSize]];
            } else {
                customButton.titleLabel.font = [UIFont systemFontOfSize:[self NAVSCALE:titleSize]];
            }
            
            [customButton setTitle:title forState:UIControlStateNormal];
            [customButton setTitleColor:[WXConvert UIColor:titleColor] forState:UIControlStateNormal];
            [customButton.titleLabel sizeToFit];
        }
        [customButton SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing: (icon.length > 0 && title.length > 0) ? [self NAVSCALE:spacing] : 0];
        if (callback) {
            customButton.tag = ++easyNavigationButtonTag;
            [customButton addTarget:self action:@selector(navigationItemClick:) forControlEvents:UIControlEventTouchUpInside];
            [_navigationCallbackDictionary setObject:@{@"callback":[callback copy], @"params":[item copy]} forKey:@(customButton.tag)];
        }
        [customButton sizeToFit];
        if (width > 0) {
            CGRect customCGRect = customButton.frame;
            customCGRect.size.width = [self NAVSCALE:width];
            [customButton setFrame:customCGRect];
        }
        CGFloat bWitdh = buttonItems.frame.size.width;
        CGFloat cWitdh = MAX(self.navigationController.navigationBar.frame.size.height, customButton.frame.size.width);
        CGFloat cHeight = self.navigationController.navigationBar.frame.size.height;
        [customButton setFrame:CGRectMake(bWitdh, 0, cWitdh, cHeight)];
        [buttonItems setFrame:CGRectMake(0, 0, bWitdh + cWitdh, cHeight)];
        [buttonItems addSubview:customButton];
    }

    if ([position isEqualToString:@"right"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItems];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItems];
    }

    if (_navigationBarBarTintColor == nil) {
        [self setNavigationTitle:@" " callback:nil];
    }else{
        [self showNavigation];
    }
}

//标题栏标题点击回调
- (void)navigationTitleClick:(UITapGestureRecognizer *)tapGesture
{
    id item = [_navigationCallbackDictionary objectForKey:@(tapGesture.view.tag)];
    if ([item isKindOfClass:[NSDictionary class]]) {
        WXModuleKeepAliveCallback callback = item[@"callback"];
        if (callback) {
            callback([item[@"params"] isKindOfClass:[NSDictionary class]] ? item[@"params"] : @{}, YES);
        }
    }
}

//标题栏菜单点击回调
-(void)navigationItemClick:(UIButton *) button
{
    id item = [_navigationCallbackDictionary objectForKey:@(button.tag)];
    if ([item isKindOfClass:[NSDictionary class]]) {
        WXModuleKeepAliveCallback callback = item[@"callback"];
        if (callback) {
            callback([item[@"params"] isKindOfClass:[NSDictionary class]] ? item[@"params"] : @{}, YES);
        }
    }
}

//标题栏显示
- (void)showNavigation
{
    if ([_statusBarType isEqualToString:@"fullscreen"] || [_statusBarType isEqualToString:@"immersion"]) {
        return;
    }
    [self setFd_prefersNavigationBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [self.view setNeedsLayout];
}

//标题栏隐藏
- (void)hideNavigation
{
    if ([_statusBarType isEqualToString:@"fullscreen"] || [_statusBarType isEqualToString:@"immersion"]) {
        return;
    }
    [self setFd_prefersNavigationBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setNeedsLayout];
}

- (CGFloat)NAVSCALE:(CGFloat)size
{
    return MIN([UIScreen mainScreen].bounds.size.width, 375) * 1.0f/750 * size;
}

- (BOOL)isFontIcon:(NSString*)var
{
    if (var == nil) {
        return NO;
    }
    NSString *val = [var lowercaseString];
    if ([val containsString:@"//"] || [val hasPrefix:@"data:"] || [val hasSuffix:@".png"] || [val hasSuffix:@".jpg"] || [val hasSuffix:@".jpeg"] || [val hasSuffix:@".gif"]) {
        return NO;
    }else{
        return YES;
    }
}

@end
