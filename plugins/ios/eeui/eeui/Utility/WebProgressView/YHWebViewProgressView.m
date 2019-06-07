//
//  YHWebViewProgressView.m
//  YohoExplorerDemo
//
//  Created by gaoqiang xu on 3/25/15.
//  Copyright (c) 2015 gaoqiang xu. All rights reserved.
//

#import "YHWebViewProgressView.h"

#define kAnimationDurationMultiplier (1.8)

@interface YHWebViewProgressView ()
@property (nonatomic) BOOL isWkWebView;
@end

@implementation YHWebViewProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureViews];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
}

- (void)dealloc
{
    
}

- (void)configureViews
{
    self.isWkWebView = NO;
    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _progressBarView = [[UIView alloc] initWithFrame:self.bounds];
    _progressBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    UIColor *tintColor = [UIColor colorWithRed:52/255.f
                                         green:142/255.f
                                          blue:237/255.f
                                         alpha:1.f];
    
    if ([UIApplication.sharedApplication.delegate.window respondsToSelector:@selector(setTintColor:)]
        && UIApplication.sharedApplication.delegate.window.tintColor) {
        tintColor = UIApplication.sharedApplication.delegate.window.tintColor;
    }
    
    _progressBarView.backgroundColor = tintColor;
    [self addSubview:_progressBarView];
    
    _barAnimationDuration = 0.5f;
    _fadeAnimationDuration = 0.27f;
    
    [self setProgress:0.f];
}

- (void)setProgressBarColor:(UIColor *)progressBarColor
{
    _progressBarView.backgroundColor = progressBarColor;
}

- (UIColor *)progressBarColor
{
    return self.progressBarView.backgroundColor;
}

- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)useWkWebView:(WKWebView *)webView
{
    if (!webView) {
        return;
    }
    self.isWkWebView = YES;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)outWkWebView:(WKWebView *)webView
{
    if (!webView) {
        return;
    }
    [webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    BOOL isGrowing = progress > 0.f;
    
    CGFloat originX = -CGRectGetWidth(self.bounds)/2;
    CGPoint positionBegin = CGPointMake(originX+_progress * self.bounds.size.width, CGRectGetHeight(self.progressBarView.frame)/2);
    CGPoint positionEnd = CGPointMake(originX+progress * self.bounds.size.width, CGRectGetHeight(self.progressBarView.frame)/2);
    
    if (progress < _progress) {
        animated = NO;
    }
    
    if (!isGrowing) {
        if (animated) {
            [UIView animateWithDuration:animated?self.fadeAnimationDuration:0.f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.progressBarView.center = positionEnd;
                                 self.progressBarView.alpha = 1.f;
                             } completion:^(BOOL finished) {}];
        } else {
            self.progressBarView.alpha = 1.f;
            self.progressBarView.center = positionEnd;
        }
    } else {
        [UIView animateWithDuration:animated?self.fadeAnimationDuration:0.f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.progressBarView.alpha = 1.f;
                         } completion:^(BOOL finished) {}];
        
        if (animated) {
            CAAnimation *animationBounds = nil;
            
            if (progress < 1) {
                if (_progress > 0.01 && [self.progressBarView.layer animationForKey:@"positionAnimation"]) {
                    positionBegin = [self.progressBarView.layer.presentationLayer position];
                    self.progressBarView.layer.position = positionBegin;
                    [self.progressBarView.layer removeAnimationForKey:@"positionAnimation"];
                }
                
                CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                keyFrameAnimation.duration = kAnimationDurationMultiplier*(progress-_progress)*10;
                keyFrameAnimation.keyTimes = @[ @0, @.3, @1 ];
                keyFrameAnimation.values = @[ [NSValue valueWithCGPoint:positionBegin],
                                              [NSValue valueWithCGPoint:CGPointMake(positionBegin.x+(positionEnd.x-positionBegin.x)*0.9, positionEnd.y)],
                                              [NSValue valueWithCGPoint:positionEnd] ];
                keyFrameAnimation.timingFunctions = @[ [CAMediaTimingFunction functionWithControlPoints: 0.092 : 0.000 : 0.618 : 1.000],
                                                       [CAMediaTimingFunction functionWithControlPoints: 0.000 : 0.688 : 0.479 : 1.000] ];
                
                animationBounds = keyFrameAnimation;
            } else {
                if (_progress > 0.05 && [self.progressBarView.layer animationForKey:@"positionAnimation"]) {
                    positionBegin = [self.progressBarView.layer.presentationLayer position];
                    self.progressBarView.layer.position = positionBegin;
                    [self.progressBarView.layer removeAnimationForKey:@"positionAnimation"];
                }
                CABasicAnimation *basicAnimationBounds = [CABasicAnimation animationWithKeyPath:@"position"];
                basicAnimationBounds.fromValue = [NSValue valueWithCGPoint:positionBegin];
                basicAnimationBounds.toValue = [NSValue valueWithCGPoint:positionEnd];
                basicAnimationBounds.duration = self.barAnimationDuration;
                basicAnimationBounds.timingFunction = [CAMediaTimingFunction functionWithControlPoints: 0.486 : 0.056 : 0.778 : 0.480];
                
                basicAnimationBounds.delegate = self;
                
                animationBounds = basicAnimationBounds;
            }
            
            [self.progressBarView.layer addAnimation:animationBounds forKey:@"positionAnimation"];
            self.progressBarView.layer.position = positionEnd;

        } else {
            self.progressBarView.layer.position = positionEnd;
        }
    }

    _progress = progress;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _progress = 0.f;
    CABasicAnimation *animationOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationOpacity.fromValue = @1;
    animationOpacity.toValue = @0;
    animationOpacity.duration = self.fadeAnimationDuration;
    animationOpacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.progressBarView.layer addAnimation:animationOpacity forKey:@"opacityAnimation"];
    self.progressBarView.layer.opacity = 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setProgress:[change[@"new"] doubleValue] animated:YES];
}

@end
