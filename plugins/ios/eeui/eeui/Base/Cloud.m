//
//  Cloud.m
//  eeuiProject
//
//  Created by 高一 on 2018/9/27.
//

#import "Cloud.h"
#import "Config.h"
#import "DeviceUtil.h"
#import "AFNetworking.h"
#import "SSZipArchive.h"
#import "eeuiStorageManager.h"
#import "eeuiNewPageManager.h"
#import "WeexSDKManager.h"
#import "UIImageView+WebCache.h"

@implementation Cloud

static NSString *apiUrl = @"https://console.eeui.app/";
static UIImageView *welcomeView;
static ClickWelcome myClickWelcome;

//加载启动图
+ (NSInteger) welcome:(nullable UIView *) view click:(nullable ClickWelcome) click
{
    eeuiStorageManager *storage = [eeuiStorageManager sharedIntstance];
    NSString *welcome_image = [storage getCachesString:@"welcome_image" defaultVal:@""];
    if (welcome_image.length == 0 || ![welcome_image hasPrefix:@"http"]) {
        return 0;
    }
    //
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    long timeStamp = interval;
    NSDictionary *appInfo = [Cloud getAppInfo];
    long welcome_limit_s = [WXConvert NSInteger:appInfo[@"welcome_limit_s"]];
    long welcome_limit_e = [WXConvert NSInteger:appInfo[@"welcome_limit_e"]];
    if (welcome_limit_s > 0 && welcome_limit_s > timeStamp) {
        return 0;
    }
    if (welcome_limit_e > 0 && welcome_limit_e < timeStamp) {
        return 0;
    }
    //
    myClickWelcome = click;
    if (view != nil) {
        welcomeView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [welcomeView sd_setImageWithURL:[NSURL URLWithString:(NSString*) welcome_image]];
        welcomeView.contentMode = UIViewContentModeScaleAspectFill;
        welcomeView.clipsToBounds = YES;
        [view addSubview:welcomeView];
        //
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickWelcome:)];
        [view addGestureRecognizer:tapGesture];
    }
    NSInteger welcome_wait = [[storage getCachesString:@"welcome_wait" defaultVal:@"2000"] intValue];
    welcome_wait = welcome_wait > 100 ? welcome_wait : 2000;
    return welcome_wait / 1000;
}

//点击启动图
+ (void)clickWelcome:(UIGestureRecognizer *)gestureRecognizer {
    if (myClickWelcome != nil) {
        myClickWelcome();
    }
}

//手动删除启动图
+ (void) welcomeClose
{
    if (welcomeView != nil) {
        [welcomeView removeFromSuperview];
    }
}

//云数据
+ (void) appData
{
    NSString *appkey = [Config getString:@"appKey" defaultVal:@""];
    if (appkey.length == 0) {
        return;
    }
    NSString *url = [[NSString alloc] initWithFormat:@"%@api/client/app", apiUrl];
    NSString *package = [[NSBundle mainBundle]bundleIdentifier];
    NSString *version = [NSString stringWithFormat:@"%ld", (long)[Config getLocalVersion]];
    NSString *versionName = [Config getLocalVersionName];
    NSString *screenWidth = [NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.width];
    NSString *screenHeight = [NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.height];
    NSString *debug = @"0";
    #if DEBUG
    debug = @"1";
    #endif
    NSDictionary *params = @{@"appkey": appkey,
                             @"package": package,
                             @"version": version,
                             @"versionName": versionName,
                             @"screenWidth": screenWidth,
                             @"screenHeight": screenHeight,
                             @"platform": @"ios",
                             @"debug": debug};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @try {
            if (responseObject) {
                if ([[responseObject objectForKey:@"ret"] integerValue] == 1) {
                    NSDictionary *data = responseObject[@"data"];
                    NSMutableDictionary *jsonData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [[eeuiStorageManager sharedIntstance] setCachesString:@"main::appInfo" value:jsonData expired:0];
                    [self saveWelcomeImage:[NSString stringWithFormat:@"%@", jsonData[@"welcome_image"]] wait:[[jsonData objectForKey:@"welcome_wait"] integerValue]];
                    [self checkUpdateLists:[jsonData objectForKey:@"uplists"] number:0 isReboot:NO];
                }
            }
        }@catch (NSException *exception) { }
    } failure:nil];
}

//获取云数据缓存
+ (NSMutableDictionary *) getAppInfo {
    id jsonString = [[eeuiStorageManager sharedIntstance] getCachesString:@"main::appInfo" defaultVal:@""];
    NSMutableDictionary *appInfo = [NSMutableDictionary new];
    if ([jsonString isKindOfClass:[NSString class]]) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        appInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (err) {
            appInfo = [NSMutableDictionary new];
        }
    } else if ([jsonString isKindOfClass:[NSDictionary class]]) {
        appInfo = jsonString;
    }
    return appInfo;
}

//缓存启动图
+ (void) saveWelcomeImage:(NSString*)url wait:(NSInteger)wait
{
    eeuiStorageManager *storage = [eeuiStorageManager sharedIntstance];
    if ([url hasPrefix:@"http"]) {
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (finished) {
                [storage setCachesString:@"welcome_image" value:[NSString stringWithFormat:@"%@", url] expired:0];
            }
        }];
    }else{
        [storage setCachesString:@"welcome_image" value:@"" expired:0];
    }
    [storage setCachesString:@"welcome_wait" value:[NSString stringWithFormat:@"%ld", (long)wait] expired:0];
}

//更新部分
+ (void) checkUpdateLists:(NSMutableArray*)lists number:(NSInteger)number isReboot:(BOOL)isReboot
{
    if (number >= [lists count]) {
        if (isReboot) {
            [self reboot];
        }
        return;
    }
    NSMutableDictionary *data = [lists objectAtIndex:number];
    NSString *id = [NSString stringWithFormat:@"%@", data[@"id"]];
    NSString *url = [NSString stringWithFormat:@"%@", data[@"path"]];
    NSInteger valid = [WXConvert NSInteger:data[@"valid"]];
    if (![url hasPrefix:@"http"]) {
        [self checkUpdateLists:lists number:number+1 isReboot:isReboot];
        return;
    }
    //
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *tempDir = [Config getSandPath:@"update"];
    NSString *lockFile = [Config getSandPath:[[NSString alloc] initWithFormat:@"update/%@.lock", [Config MD5ForLower32Bate:url]]];
    if (![fm fileExistsAtPath:tempDir]) {
        [fm createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *zipFile = [Config getSandPath:[[NSString alloc] initWithFormat:@"update/%@.zip", id]];
    NSString *zipUnDir = [Config getSandPath:[[NSString alloc] initWithFormat:@"update/%@", id]];
    NSString *releaseFile = [Config getSandPath:[[NSString alloc] initWithFormat:@"update/%@/%ld.release", id, (long)[Config getLocalVersion]]];
    if (valid == 1) {
        //开始修复
        if ([Config isFile:lockFile]) {
            [self checkUpdateLists:lists number:number+1 isReboot:isReboot];
            return;
        }
        //开始下载
        if (![fm fileExistsAtPath:zipFile]) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            [data writeToFile:zipFile atomically:YES];
        }
        //下载成功 > 解压 > 覆盖
        if (![SSZipArchive unzipFileAtPath:zipFile toDestination:zipUnDir]) {
            return;
        }
        //标记回调
        [fm createFileAtPath:lockFile contents:[[Config getyyyMMddHHmmss] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        [fm createFileAtPath:releaseFile contents:[[Config getyyyMMddHHmmss] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *tempUrl = [[NSString alloc] initWithFormat:@"%@api/client/update/success?id=%@", apiUrl, id];
        [manager GET:tempUrl parameters:nil progress:nil success:nil failure:nil];
    }else if (valid == 2) {
        //开始删除
        BOOL isDelete = NO;
        if ([Config isFile:lockFile]) {
            [fm removeItemAtPath:lockFile error:nil];
            isDelete = YES;
        }
        if ([Config isDir:zipUnDir]) {
            [fm removeItemAtPath:zipUnDir error:nil];
            isDelete = YES;
        }
        if (!isDelete) {
            [self checkUpdateLists:lists number:number+1 isReboot:isReboot];
            return;
        }
        //标记回调
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *tempUrl = [[NSString alloc] initWithFormat:@"%@api/client/update/delete?id=%@", apiUrl, id];
        [manager GET:tempUrl parameters:nil progress:nil success:nil failure:nil];
    }
    [Config clear];
    //
    NSString *reboot = [NSString stringWithFormat:@"%@", data[@"reboot"]];
    if ([reboot isEqualToString:@"1"]) {
        [self checkUpdateLists:lists number:number+1 isReboot:YES];
    }else if ([reboot isEqualToString:@"2"]) {
        NSMutableDictionary *rebootInfo = [data objectForKey:@"reboot_info"];
        UIAlertController * alertController = [UIAlertController
                                               alertControllerWithTitle: [NSString stringWithFormat:@"%@", rebootInfo[@"title"]]
                                               message: [NSString stringWithFormat:@"%@", rebootInfo[@"message"]]
                                               preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self checkUpdateLists:lists number:number+1 isReboot:isReboot];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([rebootInfo[@"confirm_reboot"] integerValue] == 1) {
                [self reboot];
                [self appData];
            }else{
                [self checkUpdateLists:lists number:number+1 isReboot:isReboot];
            }
        }]];
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        [alertWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }else{
        [self checkUpdateLists:lists number:number+1 isReboot:isReboot];
    }
}

//重启APP
+ (void) reboot
{
    [Config clear];
    [[[DeviceUtil getTopviewControler] navigationController] popToRootViewControllerAnimated:NO];
    NSDictionary *viewData = [[eeuiNewPageManager sharedIntstance] getViewData];
    for (NSString *pageName in viewData) {
        id view = [viewData objectForKey:pageName];
        if ([view isKindOfClass:[eeuiViewController class]]) {
            eeuiViewController *vc = (eeuiViewController*)view;
            if (vc.isFirstPage) {
                [WeexSDKManager sharedIntstance].weexUrl = [Config getHome];
                [vc setHomeUrl: [Config getHome]];
            }
        }
    }
}

//清除热更新缓存
+ (void) clearUpdate
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[Config getSandPath:@"update"] error:nil];
    [self reboot];
}

@end
