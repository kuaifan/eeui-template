//
//  eeuiIconComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/3.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiIconComponent.h"
#import "WeexSDK.h"
#import "UIImage+TBCityIconFont.h"
#import "DeviceUtil.h"

@interface eeuiIconComponent()

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, strong) NSString *clickColor;
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, strong) UILabel *iconLab;

@end

@implementation eeuiIconComponent

WX_EXPORT_METHOD(@selector(setIcon:))
WX_EXPORT_METHOD(@selector(setIconSize:))
WX_EXPORT_METHOD(@selector(setIconColor:))
WX_EXPORT_METHOD(@selector(setIconClickColor:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _content = @"";
        _color = @"#242424";
        _clickColor = @"#242424";
        _fontSize = FONT(38);

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        _angle = 0;

    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _iconLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _iconLab.text = [self getFontText:_content];
    _iconLab.font = [UIFont fontWithName:@"eeuiicon" size: _fontSize];
    _iconLab.textColor = [WXConvert UIColor:_color];
    _iconLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_iconLab];

    [self fireEvent:@"ready" params:nil];
}

- (NSString*)getFontText:(NSString*)text
{
    NSString *key = @"";
    NSArray *list = [text componentsSeparatedByString:@" "];
    if (list.count == 2) {
        key = [WXConvert NSString:list.firstObject];
        NSString *other = [WXConvert NSString:list.lastObject];
        if ([other hasSuffix:@"px"] || [other hasSuffix:@"dp"] || [other hasSuffix:@"sp"]) {
            _fontSize = FONT([other integerValue]);
        } else if ([other hasSuffix:@"%"]) {
            _fontSize = FONT(38 * [other integerValue] * 1.0 / 100);
        } else if ([other isEqualToString:@"#"]) {
            _color = other;
        } else if ([other isEqualToString:@"spin"]) {
            [self startAnimation];
        }
    } else {
        key = text;
    }
    [TBCityIconFont setFontName:@"eeuiicon"];
    key = [IconFontUtil iconFont:key];
    return key;
}

- (void)startAnimation
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(_angle * (M_PI / 180.0f));

    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        wself.view.transform = endAngle;
    } completion:^(BOOL finished) {
        wself.angle += 2;
        [wself startAnimation];
    }];
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

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"content"]) {
        _content = [WXConvert NSString:value];
        if ([_content hasPrefix:@"'"]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"'" withString:@""];
        }
        if ([_content hasPrefix:@"\""]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
        if (isUpdate) {
            [self setIcon:_content];
        }
    } else if ([key isEqualToString:@"text"]) {
        _content = [WXConvert NSString:value];
        if ([_content hasPrefix:@"'"]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"'" withString:@""];
        }
        if ([_content hasPrefix:@"\""]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
        if (isUpdate) {
            [self setIcon:_content];
        }
    } else if ([key isEqualToString:@"color"]) {
        _color = [WXConvert NSString:value];
        if (isUpdate) {
            _iconLab.textColor = [WXConvert UIColor:_color];
        }
    } else if ([key isEqualToString:@"clickColor"]) {
        _clickColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"fontSize"]) {
        _fontSize = FONT([WXConvert NSInteger:value]);
        if (isUpdate) {
            _iconLab.font = [UIFont fontWithName:@"eeuiicon" size: _fontSize];
        }
    }
}



#pragma mark methods

- (void)setIcon:(id)value
{
    if (value) {
        _content = [WXConvert NSString:value];
        _iconLab.text = [self getFontText:_content];
    }
}

- (void)setIconSize:(id)value
{
    if (value) {
        _fontSize = FONT([WXConvert NSInteger:value]);
        _iconLab.font = [UIFont fontWithName:@"eeuiicon" size: _fontSize];
    }
}

- (void)setIconColor:(id)value
{
    if (value) {
        _color = [WXConvert NSString:value];
        _iconLab.textColor = [WXConvert UIColor:_color];
    }
}

- (void)setIconClickColor:(id)value
{
    if (value) {
        _clickColor = [WXConvert NSString:value];
    }
}

@end
