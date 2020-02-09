//
//  eeuiAdDialogManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiAdDialogManager.h"
#import "UIButton+WebCache.h"
#import "UIImage+TBCityIconFont.h"
#import "DeviceUtil.h"

#define WindowViewTag 456
#define BgViewTag 457
#define kAdDialog @"adDialog"


@interface eeuiAdDialogView : UIControl

@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) BOOL showClose;
@property (nonatomic, assign) BOOL backClose;
@property (nonatomic, strong) NSString *dialogName;
@property (nonatomic, strong) UIImage *img;
@property(nonatomic, copy)WXModuleKeepAliveCallback callback;

@property (nonatomic, copy) void (^cancelAdDialogBlock)(void);

- (void)colseAdDialog;

@end

@implementation eeuiAdDialogView

- (void)loadAdDialogView
{
    UIView *windowView = [[UIView alloc] initWithFrame:self.bounds];
    windowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    windowView.tag = WindowViewTag;
    [self addSubview:windowView];

    UIControl *bgView = [[UIControl alloc] initWithFrame:CGRectMake(0, windowView.bounds.size.height, windowView.bounds.size.width, windowView.bounds.size.height)];
    bgView.backgroundColor = [UIColor clearColor];
    [bgView addTarget:self action:@selector(controlClick) forControlEvents:UIControlEventTouchUpInside];
    bgView.tag = BgViewTag;
    [windowView addSubview:bgView];

    CGFloat width = 0;
    CGFloat height = 0;
    if (self.width == 0 && self.height == 0) {
        width = bgView.bounds.size.width * 0.8;
        height = _img.size.height/_img.size.width *width;
    } else if (self.width > 0 && self.height > 0) {
        width = self.width;
        height = self.height;
    } else if (self.width > 0 && self.height == 0) {
        width = self.width;
        height = _img.size.height/_img.size.width *width;
    } else if (self.height > 0 && self.width == 0) {
        height = self.height;
        width = _img.size.width/_img.size.height * height;
    }

    UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn.frame = CGRectMake(0, 0, width, height);
    imgBtn.center = windowView.center;
    [imgBtn setBackgroundImage:_img forState:UIControlStateNormal];
    [imgBtn addTarget:self action:@selector(imgClick) forControlEvents:UIControlEventTouchUpInside];
    imgBtn.adjustsImageWhenHighlighted = NO;
    [bgView addSubview:imgBtn];


    UIImage *closeImg = [DeviceUtil getIconText:@"tb-close" font:19 color:@"#ffffff"];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake((bgView.frame.size.width - 50)/2, imgBtn.frame.origin.y + height + 20, 50, 50);
    [closeBtn setImage:closeImg forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];

    closeBtn.hidden = !_showClose;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bgView.frame;
        frame.origin.y = 0;
        bgView.frame = frame;
    }completion:^(BOOL finished) {
        NSDictionary *result = @{@"status":@"show", @"dialogName":self.dialogName, @"imgUrl":self.imgUrl};
        self.callback(result, YES);
    }];
}

- (void)imgClick
{
    NSDictionary *result = @{@"status":@"click", @"dialogName":self.dialogName, @"imgUrl":self.imgUrl};
    self.callback(result, YES);
}

- (void)controlClick
{
    if (_backClose) {
        [self colseAdDialog];
    }
}

- (void)closeClick
{
    [self colseAdDialog];
}

- (void)colseAdDialog
{
    self.cancelAdDialogBlock();

    UIView *windowView = [self viewWithTag:WindowViewTag];
    UIView *bgView = [self viewWithTag:BgViewTag];

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bgView.frame;
        frame.origin.y = windowView.frame.size.height;
        bgView.frame = frame;
    }completion:^(BOOL finished) {
        bgView.hidden = YES;
        windowView.hidden = YES;
        [bgView removeFromSuperview];
        [windowView removeFromSuperview];
        NSDictionary *result = @{@"status":@"destroy", @"dialogName":self.dialogName, @"imgUrl":self.imgUrl};
        self.callback(result, NO);
    }];
}

@end


@implementation eeuiAdDialogManager

+ (eeuiAdDialogManager *)sharedIntstance {
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
        self.adDialogDic = [NSMutableDictionary dictionaryWithCapacity:5];
        self.adDialogList = [NSMutableArray arrayWithCapacity:5];
    }

    return self;
}

- (void)adDialog:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *imgUrl = @"";
    NSString *dialogName = @"";
    if ([params isKindOfClass:[NSDictionary class]]) {
        imgUrl = params[@"imgUrl"] ? [WXConvert NSString:params[@"imgUrl"]] : @"";
        dialogName = params[@"dialogName"] ? [WXConvert NSString:params[@"dialogName"]] : @"";

    } else  if ([params isKindOfClass:[NSString class]]) {
        imgUrl = params;
        dialogName = @"";
    }

    //图片加载中
    NSDictionary *result = @{@"status":@"load", @"dialogName":dialogName, @"imgUrl":imgUrl};
    callback(result, YES);

    //获取图片
    NSString * imageUrl = [imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];//用地址去本地找图片
    if (newImage != nil) {//如果本地有
        [self loadAdDialogView:newImage params:params callback:callback];
    } else {//如果本地没有
        //下载图片
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image) {
                [self loadAdDialogView:image params:params callback:callback];
            }
        }];
    }
}

- (void)loadAdDialogView:(UIImage*)img params:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *imgUrl = @"";
    NSString *dialogName = @"";
    NSInteger width = 0;
    NSInteger height = 0;
    BOOL showClose = YES;
    BOOL backClose = YES;

    if ([params isKindOfClass:[NSDictionary class]]) {
        imgUrl = params[@"imgUrl"] ? [WXConvert NSString:params[@"imgUrl"]] : @"";
        width = params[@"width"] ? [DeviceUtil scale:[WXConvert NSInteger:params[@"width"]]] : 0;
        height = params[@"height"] ? [DeviceUtil scale:[WXConvert NSInteger:params[@"height"]]] : 0;
        showClose = params[@"showClose"] ? [WXConvert BOOL:params[@"showClose"]] : YES;
        backClose = params[@"backClose"] ? [WXConvert BOOL:params[@"backClose"]] : YES;
        dialogName = params[@"dialogName"] ? [WXConvert NSString:params[@"dialogName"]] : @"";
    } else if ([params isKindOfClass:[NSString class]]) {
        imgUrl = params;
    }

    UIWindow *window = [UIApplication sharedApplication].delegate.window;

    eeuiAdDialogView *adDialogView = [[eeuiAdDialogView alloc] initWithFrame:window.bounds];
    adDialogView.imgUrl = imgUrl;
    adDialogView.width = width;
    adDialogView.height = height;
    adDialogView.showClose = showClose;
    adDialogView.backClose = backClose;
    adDialogView.dialogName = dialogName;
    adDialogView.img = img;
    adDialogView.callback = callback;
    [adDialogView loadAdDialogView];
    [window addSubview:adDialogView];

    __weak typeof(adDialogView) weaDV = adDialogView;
    __weak typeof(self) ws = self;
    adDialogView.cancelAdDialogBlock = ^{
        [ws.adDialogDic removeObjectForKey:dialogName];
        [ws.adDialogList removeObject:weaDV];
        [weaDV removeFromSuperview];
    };

    [self.adDialogDic setObject:adDialogView forKey:dialogName];
    [self.adDialogList addObject:adDialogView];

    NSDictionary *result = @{@"status":@"ready", @"dialogName":dialogName, @"imgUrl":imgUrl};
    callback(result, YES);
}

- (void)adDialogClose:(NSString*)dialogName
{
    if (dialogName.length > 0) {
        eeuiAdDialogView *view = [self.adDialogDic objectForKey:dialogName];
        if (view) {
            [view colseAdDialog];
            [_adDialogList removeObject:view];
            [_adDialogDic removeObjectForKey:dialogName];
            [view removeFromSuperview];
            return;
        }
    }

    if (_adDialogList.count > 0) {
        eeuiAdDialogView *view = [_adDialogList firstObject];
        if (view) {
            [view colseAdDialog];
            [_adDialogList removeObject:view];
            [view removeFromSuperview];
        }
    }
}

@end
