//
//  eeuiViewController.h
//  WeexTestDemo
//
//  Created by apple on 2018/5/31.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXModuleProtocol.h"

typedef NS_ENUM(NSInteger, LifeCycleType) {
    LifeCycleReady = 0,
    LifeCycleResume,
    LifeCyclePause,
    LifeCycleDestroy
};

@interface eeuiViewController : UIViewController

@property (nonatomic, assign) BOOL isFirstPage;//是否系统第一页
@property (nonatomic, assign) BOOL isDisSwipeBack;//禁止滑动返回
@property (nonatomic, assign) BOOL isDisSwipeFullBack;//禁止全屏滑动返回
@property (nonatomic, assign) BOOL isDisItemBack;//禁止点击返回按钮
@property (nonatomic, assign) BOOL loading;//显示等待加载效果
@property (nonatomic, assign) BOOL showNavigationBar;//导航栏
@property (nonatomic, assign) BOOL isChildSubview;//是否作为子视图添加，用于判断是否添加自定义状态栏
@property (nonatomic, assign) CGRect parentFrameCGRect;//父视图尺寸，用于isChildSubview时加载效果的定位

@property (nonatomic, assign) BOOL isTabbarChildView;//是否tabbar子视图
@property (nonatomic, assign) BOOL isTabbarChildSelected;//是否tabbar子视图当前页，用于生命周期回传值

@property (nonatomic, strong) NSString *statusBarType;
@property (nonatomic, strong) NSString *statusBarColor;//状态栏颜色值
@property (nonatomic, assign) NSInteger statusBarAlpha;//状态栏透明度， 0-255
@property (nonatomic, strong) NSString *statusBarStyleCustom; //状态栏样式
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSString *backgroundColor;
@property (nonatomic, strong) NSString *softInputMode;
@property (nonatomic, strong) NSString *safeAreaBottom;//底部安全距离
@property (nonatomic, strong) NSString *animatedType;//页面动画效果类型
@property (nonatomic, assign) long loadTime;//最后加载时间

@property (nonatomic, assign) long startLoadTime;
@property (nonatomic, assign) long pauseTimeStart;
@property (nonatomic, assign) long pauseTimeSecond;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSInteger cache;//缓存时长，0则不缓存

@property (nonatomic, strong) NSString *resumeUrl;

@property (nonatomic, copy) void (^statusBlock)(NSString*);
@property (nonatomic, copy) void (^listenerBlock)(id);
@property (nonatomic, copy) void (^webBlock)(NSDictionary*);

@property (nonatomic, copy) void (^refreshHeaderBlock)(void);

@property (nonatomic, strong) NSString *pageType;
@property (nonatomic, strong) id params;

@property (nonatomic,assign) BOOL keyBoardlsVisible;
@property (nonatomic,strong) NSString *identify;

@property (nonatomic,assign) BOOL isCache;
@property (nonatomic, assign) BOOL isResignActive;

- (void)stopLoading;
- (void)startLoading;
- (void)refreshPage;

- (void)setHomeUrl:(NSString*)url refresh:(BOOL)refresh;

- (void)setResumeUrl:(NSString*)url;

- (void)addStatusListener:(NSString*)name;
- (void)clearStatusListener:(NSString*)name;
- (void)postStatusListener:(NSString*)name data:(id)data;

- (void)lifeCycleEvent:(LifeCycleType)type;

- (void)setNavigationTitle:(id) params callback:(WXModuleKeepAliveCallback) callback;
- (void)setNavigationItems:(id) params position:(NSString *)position callback:(WXModuleKeepAliveCallback) callback;
- (void)showNavigation;
- (void)hideNavigation;

- (void)showFixedInfo:(NSString *)text;
- (void)showFixedConsole;
- (void)hideFixedConsole;

- (void)showFixedVersionUpdate:(NSString *)templateId;
- (void)hideFixedVersionUpdate;

@end
