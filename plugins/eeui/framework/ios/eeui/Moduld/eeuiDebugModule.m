//
//  eeuiDebugModule.m
//  Pods
//
//  Created by 高一 on 2019/3/13.
//

#import "eeuiDebugModule.h"
#import "eeuiStorageManager.h"
#import "eeuiNewPageManager.h"
#import "DeviceUtil.h"
#import "eeuiViewController.h"

@implementation eeuiDebugModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(addLog::))
WX_EXPORT_METHOD(@selector(getLog::))
WX_EXPORT_METHOD(@selector(getLogAll:))
WX_EXPORT_METHOD(@selector(clearLog:))
WX_EXPORT_METHOD(@selector(clearLogAll))
WX_EXPORT_METHOD(@selector(setLogListener:))
WX_EXPORT_METHOD(@selector(removeLogListener))
WX_EXPORT_METHOD(@selector(openConsole))
WX_EXPORT_METHOD(@selector(closeConsole))

- (void)addLog:(NSString*)type :(id)log
{
#if DEBUG
    NSString *pageUrl = nil;
    if ([weexInstance.viewController isKindOfClass:[eeuiViewController class]]) {
        eeuiViewController *top = (eeuiViewController *) weexInstance.viewController;
        pageUrl = top.url;
    }else{
        pageUrl = [[eeuiStorageManager sharedIntstance] getPageScriptUrl:[NSString stringWithFormat:@"%@", weexInstance.scriptURL] defaultVal:@""];
    }
    if (pageUrl.length == 0) {
        pageUrl = @"";
    }else{
        NSRange range = [pageUrl rangeOfString:@"/pages/"];
        if (range.location != NSNotFound) {
            pageUrl = [pageUrl substringFromIndex:range.location + 1];
        }
    }
    [Debug addDebug:type log:log pageUrl:pageUrl];
    //
    if (pageUrl.length > 0) {
        pageUrl = [[NSString alloc] initWithFormat:@" (%@)", pageUrl];
    }
    if ([log isKindOfClass:[NSArray class]]) {
        [log enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self outLog:type log:obj pageUrl:pageUrl];
        }];
    }else{
        [self outLog:type log:log pageUrl:pageUrl];
    }
#endif
}

-(void)outLog:(NSString *)type log:(id)log pageUrl:(NSString *)pageUrl
{
    if ([type isEqualToString:@"log"]) {
        EELog(@"D/jsLog: %@%@", log, pageUrl);
    }else if ([type isEqualToString:@"info"]) {
        EELog(@"I/jsLog: %@%@", log, pageUrl);
    }else if ([type isEqualToString:@"warn"]) {
        EELog(@"W/jsLog: %@%@", log, pageUrl);
    }else if ([type isEqualToString:@"error"]) {
        EELog(@"E/jsLog: %@%@", log, pageUrl);
    }
}

- (void)getLog:(NSString*)type :(WXModuleCallback)callback
{
    NSMutableArray* historys = [Debug getDebugHistorys];
    if (callback == nil || historys == nil) {
        return;
    }
    NSMutableArray *tmpLists = [NSMutableArray new];
    for (id obj in historys) {
        if ([obj isKindOfClass:[NSDictionary class]] && [obj[@"type"] isEqualToString:type]) {
            [tmpLists addObject:obj];
        }
    }
    callback(tmpLists);
}

- (void)getLogAll:(WXModuleCallback)callback
{
    NSMutableArray* historys = [Debug getDebugHistorys];
    if (callback == nil || historys == nil) {
        return;
    }
    callback(historys);
}

- (void)clearLog:(NSString*)type
{
    NSMutableArray* historys = [Debug getDebugHistorys];
    if (historys == nil) {
        return;
    }
    NSMutableArray *tmpLists = [NSMutableArray new];
    for (id obj in historys) {
        if ([obj isKindOfClass:[NSDictionary class]] && ![obj[@"type"] isEqualToString:type]) {
            [tmpLists addObject:obj];
        }
    }
    [Debug setDebugHistorys:tmpLists];
}

- (void)clearLogAll
{
    NSMutableArray* historys = [Debug getDebugHistorys];
    if (historys == nil) {
        return;
    }
    [Debug setDebugHistorys:[NSMutableArray new]];
    [Debug setDebugBtnStatus:0];
}

- (void)setLogListener:(WXModuleKeepAliveCallback)callback
{
    [Debug setDebugJSCallback:callback];
}

- (void)removeLogListener
{
    [Debug setDebugJSCallback:nil];
}

- (void)openConsole
{
    if ([[DeviceUtil getTopviewControler] isKindOfClass:[eeuiViewController class]]) {
        eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
        [vc showFixedConsole];
    }
}

- (void)closeConsole
{
    if ([[DeviceUtil getTopviewControler] isKindOfClass:[eeuiViewController class]]) {
        eeuiViewController *vc = (eeuiViewController*)[DeviceUtil getTopviewControler];
        [vc hideFixedConsole];
        [Debug setDebugBtnStatus:0];
    }
}

@end
