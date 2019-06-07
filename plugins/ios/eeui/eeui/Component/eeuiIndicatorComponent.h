//
//  eeuiIndicatorComponent.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WXComponent.h"
#import "WeexSDK.h"

//指示器位置：0: 中下、1: 右下、2: 左下、3: 中上、4: 右上、5: 左上
typedef enum
{
    eeuiIndicatorAlignCenterDown,
    WXPointIndicatorAlignRightDown,
    WXPointIndicatorAlignLeftDown,
    eeuiIndicatorAlignCenterUp,
    WXPointIndicatorAlignRightUp,
    WXPointIndicatorAlignLeftUp,
} eeuiPointIndicatorAlignStyle;

@interface eeuiIndicatorView : UIView

@property (nonatomic, assign)   NSInteger   pointCount;         // total count point of point indicator
@property (nonatomic, assign)   NSInteger   currentPoint;       // current light index of point at point indicator
@property (nonatomic, strong)   UIColor *pointColor;        // normal point color of point indicator
@property (nonatomic, strong)   UIColor *lightColor;        // highlight point color of point indicator
@property (nonatomic, assign)   eeuiPointIndicatorAlignStyle  alignStyle;    //align style of point indicator
@property (nonatomic, assign)   CGFloat pointSize;          // point size of point indicator
@property (nonatomic, assign)   CGFloat pointSpace;         // point space of point indicator

@end


@protocol eeuiIndicatorComponentDelegate <NSObject>

-(void)setIndicatorView:(WXIndicatorView *)indicatorView;

@end

@interface eeuiIndicatorComponent : WXComponent

@property (nonatomic, weak) id<eeuiIndicatorComponentDelegate> delegate;

@end
