//
//  eeuiTabbarPageComponent.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/4.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "MJRefreshHeader.h"
#import "WXComponent.h"
#import "WeexSDK.h"

@interface eeuiTabbarPageComponent : WXComponent

@property (nonatomic, strong) NSString *tabName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *unSelectedIcon;
@property (nonatomic, strong) NSString *selectedIcon;
@property (nonatomic, assign) NSInteger message;
@property (nonatomic, assign) BOOL dot;
@property (nonatomic, assign) BOOL isRefreshListener;

@property (nonatomic, strong) MJRefreshHeader *scoView;

- (void)setRefreshListener:(MJRefreshHeader*) scoView;

@end
