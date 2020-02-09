//
//  eeuiScrollHeaderComponent.m
//  Pods
//
//  Created by 高一 on 2019/7/14.
//

#import "eeuiScrollHeaderComponent.h"


@implementation eeuiScrollHeaderComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _bx = -1;
        _by = -1;
        _status = @"static";
        _isCallback = [events containsObject:@"stateChanged"];
    }    
    return self;
}

- (void)stateCallback:(NSString *)status {
    if (_status == status) {
        return;
    }
    _status = status;
    if (_isCallback) {        
        [self fireEvent:@"stateChanged" params:@{@"status":status}];
    }
}

@end
