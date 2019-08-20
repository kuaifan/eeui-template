//
//  AnimationBottomBegin.m
//  https://github.com/yuwind/HHTransition
//
//  Created by 豫风 on 2018/4/23.
//  Copyright © 2018年 豫风. All rights reserved.
//

#import "AnimationBottomBegin.h"
#import "UIView+HHLayout.h"

@implementation AnimationBottomBegin

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = transitionContext.containerView.bounds;
    [transitionContext.containerView addSubview:toView];
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    toView.y = toView.height;
    [UIView animateWithDuration:0.3 animations:^{
        toView.y = 0;
        fromView.transform = CGAffineTransformMakeScale(0.93, 0.93);
    } completion:^(BOOL finished) {
        toView.y = 0;
        fromView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}


@end
