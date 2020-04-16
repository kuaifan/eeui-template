//
//  eeuiAComponent.m
//  Pods
//
//  Created by 高一 on 2019/4/10.
//

#import "eeuiAComponent.h"
#import "DeviceUtil.h"
#import "eeuiNewPageManager.h"

@interface eeuiAComponent()

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation eeuiAComponent

@synthesize weexInstance;

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
        _tap.delegate = self;

        _params = [[NSMutableDictionary alloc] init];

        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
    }
    return self;
}

- (void)dealloc
{
    if (_tap.delegate) {
        _tap.delegate = nil;
    }
}

- (void)viewDidLoad
{
    [self.view addGestureRecognizer:_tap];
    [self fireEvent:@"ready" params:nil];
}

- (void)openURL
{
    if ([_params[@"url"] isEqualToString:@"-1"]) {
        [[eeuiNewPageManager sharedIntstance] closePage:nil weexInstance:weexInstance];
    }else if (![_params[@"url"] isEqualToString:@""]){
        [[eeuiNewPageManager sharedIntstance] openPage:_params weexInstance:weexInstance callback:nil];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
}

- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"href"]) {
        [_params setObject:[WXConvert NSString:value] forKey:@"url"];
    } else if (![key hasPrefix:@"@"]) {
        [_params setObject:value forKey:key];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
