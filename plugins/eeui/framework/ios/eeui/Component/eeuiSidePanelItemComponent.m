//
//  eeuiSidePanelItemComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiSidePanelItemComponent.h"

@implementation eeuiSidePanelItemComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _name = attributes[@"name"] ? [WXConvert NSString:attributes[@"name"]] : @"";

    }

    return self;
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    if (attributes[@"name"]) {
        _name = [WXConvert NSString:attributes[@"name"]];
    }
}

@end
