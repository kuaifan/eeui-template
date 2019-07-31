//
//  eeuiDebugModule.m
//  Pods
//
//  Created by 高一 on 2019/3/13.
//

#import "eeuiDebugModule.h"
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
    }
    if (pageUrl.length == 0) {
        pageUrl = @"";
    }else{
        NSRange range = [pageUrl rangeOfString:@"/pages/"];
        if (range.location != NSNotFound) {
            pageUrl = [pageUrl substringFromIndex:range.location + 1];
        }
    }
    //
    if (historys == nil) {
        historys = [NSMutableArray new];
    }
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    NSDictionary *data = @{@"type":type, @"text": log, @"page": pageUrl, @"time":@(time)};
    if (mJSCallback != nil) {
        mJSCallback(data, YES);
    }
    long int count = [historys count];
    if (count > 1200) {
        NSMutableArray *tmpLists = [NSMutableArray new];
        for (int i = 0 ; i < count; i++) {
            if (i > 200) {
                [tmpLists addObject:[historys objectAtIndex:i]];
            }
        }
        historys = tmpLists;
    }
    [historys addObject:data];
    //
    if (pageUrl.length > 0) {
        pageUrl = [[NSString alloc] initWithFormat:@" (%@)", pageUrl];
    }
    if ([type isEqualToString:@"log"]) {
        NSLog(@"D/jsLog: %@%@", [self descriptionWithLocale:log], pageUrl);
    }else if ([type isEqualToString:@"info"]) {
        NSLog(@"I/jsLog: %@%@", [self descriptionWithLocale:log], pageUrl);
    }else if ([type isEqualToString:@"warn"]) {
        NSLog(@"W/jsLog: %@%@", [self descriptionWithLocale:log], pageUrl);
    }else if ([type isEqualToString:@"error"]) {
        NSLog(@"E/jsLog: %@%@", [self descriptionWithLocale:log], pageUrl);
    }
#endif
}

- (void)getLog:(NSString*)type :(WXModuleCallback)callback
{
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
    if (callback == nil || historys == nil) {
        return;
    }
    callback(historys);
}

- (void)clearLog:(NSString*)type
{
    if (historys == nil) {
        return;
    }
    NSMutableArray *tmpLists = [NSMutableArray new];
    for (id obj in historys) {
        if ([obj isKindOfClass:[NSDictionary class]] && ![obj[@"type"] isEqualToString:type]) {
            [tmpLists addObject:obj];
        }
    }
    historys = tmpLists;
}

- (void)clearLogAll
{
    if (historys == nil) {
        return;
    }
    historys = [NSMutableArray new];
}

- (void)setLogListener:(WXModuleKeepAliveCallback)callback
{
    mJSCallback = callback;
}

- (void)removeLogListener
{
    mJSCallback = nil;
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
    }
}

-(NSString *)descriptionWithLocale:(id)locale {
    if (![locale isKindOfClass:[NSArray class]]) {
        return [WXConvert NSString:locale];
    }
    
    NSMutableString *string = [NSMutableString string];
    // 开头有个[
    [string appendString:@"["];
    
    // 遍历所有的元素
    [locale enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [string appendFormat:@"\"%@\",", obj];
        }else{
            [string appendFormat:@"%@,", obj];
        }
    }];
    
    // 结尾有个]
    [string appendString:@"]"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}

@end
