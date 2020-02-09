//
//  ZYCRippleButton.m
//  ZYCRippleButton
//
//  Created by 朱佳杰 on 2017/4/1.
//  Copyright © 2017年 zjj. All rights reserved.
//

#import "ZYCRippleButton.h"
#import "DeviceUtil.h"
#import "eeuiNewPageManager.h"

const CGFloat ZYCRippleInitialRaius = 20;

@interface ZYCRippleButton()<CAAnimationDelegate>

@end

@implementation ZYCRippleButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]){
        [self initZYCRippleButton];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self == [super initWithCoder:aDecoder]){
        [self initZYCRippleButton];
    }
    return self;
}

#pragma mark - init
- (void)initZYCRippleButton{
    //模拟按钮点击效果
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
    //初始化label
    self.textLabel = [[UILabel alloc]initWithFrame:self.bounds];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.text = @"";
    [self addSubview:_textLabel];

    self.backgroundColor = [UIColor lightGrayColor];
    self.clipsToBounds = YES;
}

- (void) setButtonTittle:(NSString *)tittle{
    self.textLabel.text = tittle;
}

- (void) setButtonTittleColor:(UIColor *)tColor{
    self.textLabel.textColor = tColor;
}

- (void) setButtonBackgroundColor:(UIColor *)bgColor{
    self.backgroundColor = bgColor;
}

- (void) setButtonTittle:(NSString *)tittle withTittleColor:(UIColor *)tColor{
    [self setButtonTittle:tittle withTittleColor:tColor backgroundColor:nil];
}

- (void) setButtonTittle:(NSString *)tittle withTittleColor:(UIColor *)tColor backgroundColor:(UIColor *)bgColor{
    if (tittle){
        self.textLabel.text = tittle;
    }
    if (tColor){
        self.textLabel.textColor = tColor;
    }
    if (bgColor){
        self.backgroundColor = bgColor;
    }
}

#pragma mark - tapped
- (void)tapped:(UITapGestureRecognizer *)tap{
    //获取所点击的那个点
    CGPoint tapPoint = [tap locationInView:self];
    //创建涟漪
    CAShapeLayer *rippleLayer = nil;
    CGFloat buttonWidth = self.frame.size.width;
    CGFloat buttonHeight = self.frame.size.height;
    //CGFloat bigBoard = buttonWidth >= buttonHeight ? buttonWidth : buttonHeight;
    CGFloat smallBoard = buttonWidth <= buttonHeight ? buttonWidth : buttonHeight;
    CGFloat rippleRadiius = smallBoard/2 <= ZYCRippleInitialRaius ? smallBoard/2 : ZYCRippleInitialRaius;

    //CGFloat scale = bigBoard / rippleRadiius + 0.5;

    rippleLayer = [self createRippleLayerWithPosition:tapPoint rect:CGRectMake(0, 0, rippleRadiius * 2, rippleRadiius * 2) radius:rippleRadiius];

    [self.layer addSublayer:rippleLayer];

    //layer动画
    CAAnimationGroup *rippleAnimationGroup = [self createRippleAnimationWithScale:rippleRadiius duration:0.8f];
    //使用KVC消除layer动画以防止内存泄漏
    [rippleAnimationGroup setValue:rippleLayer forKey:@"rippleLayer"];

    [rippleLayer addAnimation:rippleAnimationGroup forKey:nil];
    rippleLayer.delegate = self;

}

#pragma mark - createRippleLayer && CAAnimationGroup
- (CAShapeLayer *)createRippleLayerWithPosition:(CGPoint)position rect:(CGRect)rect radius:(CGFloat)radius{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self createPathWithRadius:rect radius:radius];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    layer.fillColor = self.rippleColor ? self.rippleColor.CGColor : [UIColor whiteColor].CGColor;
    layer.opacity = 0;
    layer.lineWidth = self.rippleLineWidth ? self.rippleLineWidth : 1;

    return layer;
}

- (CAAnimationGroup *)createRippleAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];

    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0.5;
    alphaAnimation.toValue = @0;

    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.delegate = self;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    return animation;
}

- (CGPathRef)createPathWithRadius:(CGRect)frame radius:(CGFloat)radius{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim{
    if (self.rippleBlock){
        if ([[DeviceUtil getTopviewControler] isKindOfClass:[eeuiViewController class]]) {
            eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
            [[eeuiNewPageManager sharedIntstance] setPageStatusListener:@{@"listenerName": @"ZYCRippleButton:listener", @"pageName": vc.pageName} callback:^(id result, BOOL keepAlive) {
                NSString *status = @"";
                if ([result isKindOfClass:[NSString class]]) {
                    status = result;
                } else if ([result isKindOfClass:[NSDictionary class]]) {
                    status = result[@"status"];
                }
                if ([status isEqualToString:@"pause"]) {
                    CALayer *layer = [anim valueForKey:@"rippleLayer"];
                    if (layer) {
                        [layer removeFromSuperlayer];
                    }
                }
            }];
            [[eeuiNewPageManager sharedIntstance] setPageStatusListener:@{@"listenerName": @"otherPlugin", @"pageName": vc.pageName} callback:^(id result, BOOL keepAlive) {
                NSString *status = @"";
                if ([result isKindOfClass:[NSString class]]) {
                    status = result;
                } else if ([result isKindOfClass:[NSDictionary class]]) {
                    status = result[@"status"];
                }
                if ([status isEqualToString:@"pauseBefore"]) {
                    CALayer *layer = [anim valueForKey:@"rippleLayer"];
                    if (layer) {
                        [layer removeFromSuperlayer];
                    }
                }
            }];
        }
        self.rippleBlock();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CALayer *layer = [anim valueForKey:@"rippleLayer"];
    if (layer) {
        [layer removeFromSuperlayer];
    }
}


@end
