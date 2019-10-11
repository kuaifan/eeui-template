//
//  eeuiNavbarItemComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiNavbarItemComponent.h"
#import "DeviceUtil.h"
#import "eeuiNavbarComponent.h"

@implementation eeuiNavbarItemComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _barType = @"";

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        [self _fillCSSNode:@{
                             @"justifyContent": @"center",
                             @"alignItems": @"center"} isUpdate:YES];
    }

    return self;
}


- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
}

- (void)layoutDidFinish
{
    [super layoutDidFinish];
    WXComponent * superComponent = [self supercomponent];
    if ([superComponent isKindOfClass:[eeuiNavbarComponent class]]) {
        eeuiNavbarComponent *com = (eeuiNavbarComponent*) superComponent;
        [com loadComponentView];
    }
}

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"type"]) {
        _barType = [WXConvert NSString:value];
    }
}

@end
