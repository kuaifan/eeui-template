//
//  ViewController.m
//  eeuiApp
//
//  Created by 高一 on 2018/8/15.
//

#import "ViewController.h"

#import "WeexSDK.h"
#import "WeexSDKManager.h"
#import "eeuiViewController.h"
#import "eeuiNewPageManager.h"
#import "eeuiStorageManager.h"
#import "Config.h"
#import "Cloud.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZLStartPageView.h"

@interface ViewController ()

@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) BOOL bugBtnClick;
@property (nonatomic, assign) BOOL isOpenNext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ViewController

eeuiViewController *homeController;

- (void) viewDidLoad {
    [super viewDidLoad];

    [self setFd_prefersNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.activityIndicatorView.center = self.view.center;
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView setHidden:NO];
    [self.activityIndicatorView startAnimating];

    long welcome_wait = [Cloud welcome:nil click:^{
        [self clickWelcome];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(welcome_wait * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openNext:@""];
    });

    ZLStartPageView *startPageView = [[ZLStartPageView alloc] initWithFrame:self.view.bounds];
    [startPageView setShowTime: (int) welcome_wait];
    [startPageView setSkip: ^{
        [self openNext:@""];
    }];
    if (welcome_wait > 0 && [WXConvert BOOL:[Cloud getAppInfo][@"welcome_skip"]]) {
        [startPageView show];
    }
}

- (void) openNext:(NSString *) pageUrl {
    if (_isOpenNext) {
        return;
    }
    _isOpenNext = YES;
    //
    [Config getHomeUrl:^(NSString * _Nonnull bundleUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [WeexSDKManager sharedIntstance].weexUrl = bundleUrl;
            [[WeexSDKManager sharedIntstance] setup];

            [self.activityIndicatorView setHidden:YES];
            [self.activityIndicatorView stopAnimating];

            self.ready = YES;
            homeController = [[eeuiViewController alloc] init];
            homeController.url = bundleUrl;
            homeController.pageName = [Config getHomeParams:@"pageName" defaultVal:@"firstPage"];
            homeController.pageTitle = [Config getHomeParams:@"pageTitle" defaultVal:@""];
            homeController.pageType = [Config getHomeParams:@"pageType" defaultVal:@"app"];
            homeController.safeAreaBottom = [Config getHomeParams:@"safeAreaBottom" defaultVal:@""];
            homeController.params = [Config getHomeParams:@"params" defaultVal:@"{}"];
            homeController.cache = [[Config getHomeParams:@"cache" defaultVal:@"0"] intValue];
            homeController.loading = [[Config getHomeParams:@"loading" defaultVal:@"true"] isEqualToString:@"true"] ? YES : NO;
            homeController.isFirstPage = YES;
            homeController.isDisSwipeBack = YES;
            homeController.isDisSwipeFullBack = NO;
            homeController.statusBarType = [Config getHomeParams:@"statusBarType" defaultVal:@"normal"];
            homeController.statusBarColor = [Config getHomeParams:@"statusBarColor" defaultVal:@"#3EB4FF"];
            homeController.statusBarAlpha = [[Config getHomeParams:@"statusBarAlpha" defaultVal:@"0"] intValue];
            homeController.statusBarStyleCustom = [Config getHomeParams:@"statusBarStyle" defaultVal:@""];
            homeController.softInputMode = [Config getHomeParams:@"softInputMode" defaultVal:@"auto"];
            homeController.backgroundColor = [Config getHomeParams:@"backgroundColor" defaultVal:@"#ffffff"];
            homeController.statusBlock = ^(NSString *status) {
                if ([status isEqualToString:@"create"]) {
                    [Cloud appData:NO];
                    //
                    if (pageUrl.length > 0) {
                        [[eeuiNewPageManager sharedIntstance] openPage:@{@"url": pageUrl, @"pageType": @"app"} weexInstance:nil callback:nil];
                    }
                }
            };
            [[UIApplication sharedApplication] delegate].window.rootViewController =  [[WXRootViewController alloc] initWithRootViewController:homeController];
            [[eeuiNewPageManager sharedIntstance] setPageData:homeController.pageName vc:homeController];
        });
    }];
}

- (void) loadUrl:(NSString*) url forceRefresh:(BOOL) forceRefresh {
    [WeexSDKManager sharedIntstance].weexUrl = url;
    NSString *curUrl = homeController.url;
    if (forceRefresh || ![url isEqualToString:curUrl] || self.bugBtnClick) {
        [homeController setHomeUrl: url refresh:YES];
    }else{
        [homeController setHomeUrl: url refresh:NO];
    }
}

- (BOOL) isReady {
    return self.ready;
}

- (void) clickWelcome {
    NSDictionary *appInfo = [Cloud getAppInfo];
    NSString *welcome_jump = [NSString stringWithFormat:@"%@", appInfo[@"welcome_jump"]];
    if (welcome_jump.length > 0) {
        [self openNext:welcome_jump];
    }
}

- (BOOL) isBugBtnClick {
    return self.bugBtnClick;
}

- (void) setBugBtnClick {
    self.bugBtnClick = YES;
}

@end
