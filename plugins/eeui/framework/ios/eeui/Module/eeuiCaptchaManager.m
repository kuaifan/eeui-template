//
//  eeuiCaptchaManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiCaptchaManager.h"
#import "UIButton+WebCache.h"
#import "DeviceUtil.h"

#define CaptchaBgViewTag 200

@interface eeuiCaptchaManager ()

@property (nonatomic, assign) BOOL isCanVerify;
@property (nonatomic, assign) int puzzleY;

@end

@implementation eeuiCaptchaManager

+ (eeuiCaptchaManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)swipeCaptcha:(NSString*)imgUrl callback:(WXModuleKeepAliveCallback)callback
{
    int tag =(arc4random() % 100) + 1000;
    self.pageName = [NSString stringWithFormat:@"captcha-%d", tag];

    self.callback = callback;

    if (imgUrl.length > 0) {
        //获取图片
        //        NSString * imageUrl = [imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * imageUrl = [imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

        UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];//用地址去本地找图片
        if (newImage != nil) {//如果本地有
            [self loadCaptchaView:newImage];
        } else {//如果本地没有
            //下载图片
            [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
                    [self loadCaptchaView:image];
                }
            }];
        }
    } else {
        UIImage *img = [UIImage imageNamed:@"swipecaptcha_bg"];
        [self loadCaptchaView:img];
    }
}

- (void)loadCaptchaView:(UIImage*)img
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;

    UIView *bgView = [[UIView alloc] initWithFrame:window.bounds];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    bgView.tag = CaptchaBgViewTag;
    [window addSubview:bgView];

    CGFloat width = window.bounds.size.width * 0.8;
    CGFloat height = img.size.height / img.size.width * width;
    _puzzleY = [self getRandomNumber:20 to:60];

    _puzzleVerifyView = [[TTGPuzzleVerifyView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _puzzleVerifyView.center = bgView.center;
    _puzzleVerifyView.image = img;
    _puzzleVerifyView.puzzleSize = CGSizeMake(60, 60);
    _puzzleVerifyView.puzzleBlankPosition = CGPointMake([self getRandomNumber:60 to:200], _puzzleY);
    _puzzleVerifyView.puzzlePosition = CGPointMake(10, _puzzleY);
    _puzzleVerifyView.delegate = self;
    [bgView addSubview:_puzzleVerifyView];

    CGRect frame = _puzzleVerifyView.frame;
    frame.origin.y -= 60;
    _puzzleVerifyView.frame = frame;

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(_puzzleVerifyView.frame.origin.x, _puzzleVerifyView.frame.origin.y + _puzzleVerifyView.frame.size.height, width, 60)];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    [slider addTarget:self action:@selector(sliderChangeEvent:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:slider];

    slider.value = 0.1;
    _puzzleVerifyView.puzzleXPercentage = slider.value;

    UILabel *markLab = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.origin.x, slider.frame.size.height + slider.frame.origin.y, slider.frame.size.width, 30)];
    markLab.font = [UIFont systemFontOfSize:14];
    markLab.textColor = [UIColor whiteColor];
    markLab.textAlignment = NSTextAlignmentCenter;
    markLab.text = @"请按住滑块，拖动完成上方拼图";
    [bgView addSubview:markLab];

    UIImage *closeImg = [DeviceUtil getIconText:@"tb-close" font:19 color:@"#ffffff"];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake((bgView.frame.size.width - 50)/2, bgView.frame.size.height - 70, 50, 50);
    [closeBtn setImage:closeImg forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];

    self.callback(@{@"status":@"create", @"pageName":self.pageName}, YES);
}


- (void)sliderChangeEvent:(UISlider*)slider
{
    _puzzleVerifyView.puzzleXPercentage = slider.value;
}

- (void)sliderTouchDown:(UISlider*)slider
{
    _isCanVerify = NO;
}

- (void)sliderTouchUpInSide:(UISlider*)slider
{
    _isCanVerify = YES;
    _puzzleVerifyView.puzzleXPercentage = slider.value;

    if (![_puzzleVerifyView isVerified]) {
        _puzzleVerifyView.puzzleBlankPosition = CGPointMake([self getRandomNumber:60 to:200], _puzzleY);
        _puzzleVerifyView.puzzleXPercentage = 0.1;
        slider.value = 0.1;
    }
}

- (void)closeClick
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    UIView *bgView = [window viewWithTag:CaptchaBgViewTag];
    [bgView removeFromSuperview];

    self.callback(@{@"status":@"failed", @"pageName":self.pageName}, YES);

    self.callback(@{@"status":@"destroy", @"pageName":self.pageName}, NO);
}

#pragma mark - TTGPuzzleVerifyViewDelegate

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified {

    if (!_isCanVerify) {
        return;
    }

    if ([_puzzleVerifyView isVerified]) {
        [_puzzleVerifyView completeVerificationWithAnimation:YES];
        _puzzleVerifyView.enable = NO;
        //        _logLabel.text = @"Verify done !";

        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        UIView *bgView = [window viewWithTag:CaptchaBgViewTag];
        [bgView removeFromSuperview];

        self.callback(@{@"status":@"success", @"pageName":self.pageName}, YES);

        self.callback(@{@"status":@"destroy", @"pageName":self.pageName}, NO);
    }
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedPuzzlePosition:(CGPoint)newPosition xPercentage:(CGFloat)xPercentage yPercentage:(CGFloat)yPercentage
{

}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
