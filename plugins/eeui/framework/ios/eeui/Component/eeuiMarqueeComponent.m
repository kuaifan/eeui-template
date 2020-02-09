//
//  eeuiMarqueeComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/3.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiMarqueeComponent.h"
#import "SKAutoScrollLabel1.h"
#import "DeviceUtil.h"

@interface eeuiMarqueeComponent()

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, strong) NSString *textAlign;
@property (nonatomic, strong) NSString *kbackgroundColor;

@property (nonatomic, strong) SKAutoScrollLabel1 *skLab;
@property (nonatomic, assign) BOOL isRemoveObserver;

@end

@implementation eeuiMarqueeComponent

WX_EXPORT_METHOD(@selector(setText:))
WX_EXPORT_METHOD(@selector(addText:))
WX_EXPORT_METHOD(@selector(setTextColor:))
WX_EXPORT_METHOD(@selector(setBackgroundColor:))
WX_EXPORT_METHOD(@selector(setTextSize:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _content = @"";
        _color = @"#000000";
        _textAlign = @"left";
        _kbackgroundColor = @"";
        _fontSize = FONT(24);

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
    }

    return self;
}


- (void)viewDidLoad
{
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    [self loadLabView];

    [self fireEvent:@"ready" params:nil];
}

- (void) viewWillUnload
{
    [super viewWillUnload];
    [self removeObserver];
}

- (void)dealloc
{
    [self removeObserver];
}

- (void) removeObserver
{
    if (_isRemoveObserver != YES) {
        _isRemoveObserver = YES;
        [self.view removeObserver:self forKeyPath:@"frame" context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        [self loadLabView];
    }
}

- (void) loadLabView
{
    CGRect frame = self.view.frame;
    if (_skLab == nil) {
        _skLab = [[SKAutoScrollLabel1 alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _skLab.text = _content;
        _skLab.textColor = [WXConvert UIColor:_color];
        _skLab.font = [UIFont systemFontOfSize:_fontSize];
        _skLab.direction = SK_AUTOSCROLL_DIRECTION_LEFT;
        [self.view addSubview:_skLab];

        if (_kbackgroundColor.length > 0) {
            _skLab.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
        }

        if ([_textAlign isEqualToString:@"right"]) {
            [_skLab alignmentText:NSTextAlignmentRight];
        } else if ([_textAlign isEqualToString:@"center"]) {
            [_skLab alignmentText:NSTextAlignmentCenter];
        } else if ([_textAlign isEqualToString:@"left"]) {
            _skLab.textAlignment = NSTextAlignmentLeft;
        }
    }else{
        _skLab.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
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

        if (isUpdate) {
            _skLab.text = _content;
        }
    } else if ([key isEqualToString:@"text"]) {
        _content = [WXConvert NSString:value];

        if (isUpdate) {
            _skLab.text = _content;
        }
    } else if ([key isEqualToString:@"color"]) {
        _color = [WXConvert NSString:value];
        if (isUpdate) {
            _skLab.textColor = [WXConvert UIColor:_color];
        }
    } else if ([key isEqualToString:@"fontSize"]) {
        _fontSize = FONT([WXConvert NSInteger:value]);
        if (isUpdate) {
            _skLab.font = [UIFont systemFontOfSize:_fontSize];
        }
    } else if ([key isEqualToString:@"textAlign"]) {
        _textAlign = [WXConvert NSString:value];
        if (isUpdate) {
            if ([_textAlign isEqualToString:@"right"]) {
                [_skLab alignmentText:NSTextAlignmentRight];
            } else if ([_textAlign isEqualToString:@"center"]) {
                [_skLab alignmentText:NSTextAlignmentCenter];
            } else if ([_textAlign isEqualToString:@"left"]) {
                _skLab.textAlignment = NSTextAlignmentLeft;
            }
        }
    } else if ([key isEqualToString:@"backgroundColor"]) {
        _kbackgroundColor = [WXConvert NSString:value];
        if (isUpdate) {
            _skLab.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
        }
    }
}

#pragma mark methods

- (void)setText:(id)value
{
    if (value) {
        _content = [WXConvert NSString:value];
        _skLab.text = _content;
    }
}

- (void)addText:(id)value
{
    if (value) {
        _content = [_content stringByAppendingString:[WXConvert NSString:value]];
        _skLab.text = _content;
    }
}

- (void)setTextSize:(id)value
{
    if (value) {
        _fontSize = [WXConvert NSInteger:value];
        _skLab.font = [UIFont systemFontOfSize:_fontSize];
    }
}

- (void)setTextColor:(id)value
{
    if (value) {
        _color = [WXConvert NSString:value];
        _skLab.textColor = [WXConvert UIColor:_color];
    }
}

- (void)setBackgroundColor:(id)value
{
    if (value) {
        _kbackgroundColor = [WXConvert NSString:value];
        _skLab.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
    }
}
@end
