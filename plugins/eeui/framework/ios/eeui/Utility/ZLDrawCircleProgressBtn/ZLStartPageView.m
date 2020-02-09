//
//  ZLStartPageView.m
//  ZLStartPageDemo
//
//  Created by ZL on 2017/3/1.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLStartPageView.h"
#import "ZLDrawCircleProgressBtn.h"

@interface ZLStartPageView ()

// 跳过按钮
@property (nonatomic, strong) ZLDrawCircleProgressBtn *drawCircleBtn;
// 倒计时时间
@property (nonatomic, assign) int showTime;
// 监听事件
@property (nonatomic, copy) skipCall skipCallback;

@end


@implementation ZLStartPageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 跳过按钮
        float witdh = 38.0f;
        float height = 38.0f;
        float top = [[UIApplication sharedApplication] statusBarFrame].size.height + 18;
        float letf = kscreenWidth - witdh - 18;
        ZLDrawCircleProgressBtn *drawCircleBtn = [[ZLDrawCircleProgressBtn alloc]initWithFrame:CGRectMake(letf, top, witdh, height)];
        drawCircleBtn.lineWidth = 2;
        [drawCircleBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [drawCircleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        drawCircleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        [drawCircleBtn addTarget:self action:@selector(removeProgress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:drawCircleBtn];
        _drawCircleBtn = drawCircleBtn;
        
    }
    [self setShowTime:3];
    return self;
}

- (void)setShowTime:(int) time {
    _showTime = time;
}

- (void)setSkip:(skipCall)block {
    _skipCallback = block;
}

// 显示按钮
- (void)show {
    // progress 完成时候的回调
    __weak __typeof(self) weakSelf = self;
    [weakSelf.drawCircleBtn startAnimationDuration:_showTime withBlock:^{
        [weakSelf removeProgress];
    }];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

// 移除启动页面
- (void)removeProgress {
    if (self.skipCallback != nil) {
        self.skipCallback();
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.drawCircleBtn.hidden = NO;
    } completion:^(BOOL finished) {
        self.drawCircleBtn.hidden = YES;
    }];
}

@end
