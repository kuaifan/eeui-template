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

+ (eeuiNewPageManager *)sharedIntstance;

- (void)openPage:(NSDictionary*)params weexInstance:(WXSDKInstance*)weexInstance callback:(WXModuleKeepAliveCallback)callback;
- (NSDictionary*)getPageInfo:(id)params weexInstance:(WXSDKInstance*)weexInstance;
- (void)getPageInfoAsync:(id)params weexInstance:(WXSDKInstance*)weexInstance callback:(WXModuleCallback)callback;
- (void)reloadPage:(id)params weexInstance:(WXSDKInstance*)weexInstance;
- (void)setSoftInputMode:(id)params modo:(NSString*)modo weexInstance:(WXSDKInstance*)weexInstance;
- (void)setStatusBarStyle:(BOOL)isLight;
- (void)setPageBackPressed:(id)params callback:(WXModuleKeepAliveCallback)callback;
- (void)setOnRefreshListener:(id)params weexInstance:(WXSDKInstance*)weexInstance callback:(WXModuleKeepAliveCallback)callback;
- (void)setRefreshing:(id)params refreshing:(BOOL)refreshing weexInstance:(WXSDKInstance*)weexInstance;
- (void)setPageStatusListener:(id)params callback:(WXModuleKeepAliveCallback)callback;
- (void)clearPageStatusListener:(id)params;
- (void)onPageStatusListener:(id)params status:(NSString*)status;
- (void)postMessage:(id)params;
- (void)getCacheSizePage:(WXModuleKeepAliveCallback)callback;
- (void)clearCachePage;
- (void)closePage:(id)params weexInstance:(WXSDKInstance*)weexInstance;
- (void)closePageTo:(id)params weexInstance:(WXSDKInstance*)weexInstance;
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
