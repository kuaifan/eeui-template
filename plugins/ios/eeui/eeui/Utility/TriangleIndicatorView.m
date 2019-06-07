//
//  TriangleIndicatorView.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/14.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "TriangleIndicatorView.h"

@implementation TriangleIndicatorView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);//标记
    CGContextMoveToPoint(context, rect.size.width/2, 0);
    CGContextAddLineToPoint(context,rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context,0, rect.size.height);
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    [self.color setFill]; //设置填充色
    [self.color setStroke];//边框也设置为_color，否则为默认的黑色
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

- (void)loadColor:(UIColor*)color
{
    self.color = color;
    [self setNeedsDisplay];
}


@end
