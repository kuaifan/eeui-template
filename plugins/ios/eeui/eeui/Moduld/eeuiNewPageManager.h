//
//  eeuiNewPageManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"
#import "eeuiViewController.h"

static NSMutableDictionary *tabViewDebug;

@interface eeuiNewPageManager : NSObject

@property (nonatomic, strong) WXSDKInstance *weexInstance;

+ (eeuiNewPageManager *)sharedIntstance;

- (void)openPage:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback;

- (NSDictionary*)getPageInfo:(id)params;
- (void)getPageInfoAsync:(id)params callback:(WXModuleCallback)callback;
- (void)reloadPage:(id)params;
- (void)setSoftInputMode:(id)params modo:(NSString*)modo;
- (void)setStatusBarStyle:(BOOL)isLight;
- (void)setPageBackPressed:(id)params callback:(WXModuleKeepAliveCallback)callback;
- (void)setOnRefreshListener:(id)params callback:(WXModuleKeepAliveCallback)callback;
- (void)setRefreshing:(id)params refreshing:(BOOL)refreshing;
- (void)setPageStatusListener:(id)params callback:(WXModuleKeepAliveCallback)callback;
- (void)clearPageStatusListener:(id)params;
- (void)onPageStatusListener:(id)params status:(NSString*)status;
- (void)getCacheSizePage:(WXModuleKeepAliveCallback)callback;
- (void)clearCachePage;
- (void)closePage:(id)params;
- (void)closePageTo:(id)params;
- (void)openWeb:(NSString*)url;
- (void)goDesktop;
- (void)removePageData:(NSString*)pageName;
- (void)setPageData:(NSString*)pageName vc:(eeuiViewController *)vc;
- (void)setPageDataValue:(NSString*)pageName key:(NSString*)key value:(NSString*)value;
- (NSDictionary *)getViewData;

- (void)setTitle:(id) params callback:(WXModuleKeepAliveCallback) callback;
- (void)setLeftItems:(id) params callback:(WXModuleKeepAliveCallback) callback;
- (void)setRightItems:(id) params callback:(WXModuleKeepAliveCallback) callback;
- (void)showNavigation;
- (void)hideNavigation;

+ (void)setTabViewDebug:(NSString*)pageName callback:(WXModuleKeepAliveCallback) callback;
+ (void)removeTabViewDebug:(NSString*)pageName;
+ (NSMutableDictionary *)getTabViewDebug;

@end
