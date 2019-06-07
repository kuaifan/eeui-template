//
//  eeuiScrollTextComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/4.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiScrollTextComponent.h"
#import "SKAutoScrollLabel.h"
#import "DeviceUtil.h"

@interface eeuiScrollTextComponent()

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *ktext;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) CGFloat kspeed;
@property (nonatomic, strong) NSString *kbackgroundColor;

@property (nonatomic, strong) SKAutoScrollLabel *skLab;
@property (nonatomic, assign) BOOL isRemoveObserver;
@property (nonatomic, assign) BOOL isItemClick;

@end

@implementation eeuiScrollTextComponent

WX_EXPORT_METHOD(@selector(setText:))
WX_EXPORT_METHOD(@selector(addText:))
WX_EXPORT_METHOD(@selector(startScroll))
WX_EXPORT_METHOD(@selector(stopScroll))
WX_EXPORT_METHOD(@selector(isStarting))
WX_EXPORT_METHOD(@selector(setSpeed:))
WX_EXPORT_METHOD(@selector(setTextSize:))
WX_EXPORT_METHOD(@selector(setTextColor:))
WX_EXPORT_METHOD(@selector(setBackgroundColor:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _content = @"";
        _color = @"#000000";
        _kspeed = 2.0f;
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

    UIButton *tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tapBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    tapBtn.backgroundColor = [UIColor clearColor];
    [tapBtn addTarget:self action:@selector(itemPanClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tapBtn];

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
        _skLab = [[SKAutoScrollLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _skLab.textContent = _content;
        _skLab.textColor = [WXConvert UIColor:_color];
        _skLab.font = [UIFont systemFontOfSize:_fontSize];
        _skLab.pointsPerFrame = _kspeed / 2.2;
        _skLab.direction = SK_AUTOSCROLL_DIRECTION_LEFT;
        _skLab.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_skLab];

        if (_kbackgroundColor.length > 0) {
            _skLab.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
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

- (void)addEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"itemClick"]) {
        _isItemClick = YES;
    }
}

- (void)removeEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"itemClick"]) {
        _isItemClick = NO;
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
            _skLab.textContent = _content;
        }
    } else if ([key isEqualToString:@"text"]) {
        _content = [WXConvert NSString:value];
        if (isUpdate) {
            _skLab.textContent = _content;
        }
    } else if ([key isEqualToString:@"speed"]) {
        _kspeed = [WXConvert CGFloat:value];
        if (isUpdate) {
            _skLab.pointsPerFrame = _kspeed / 2.2;
        }
    } else if ([key isEqualToString:@"fontSize"]) {
        _fontSize = FONT( [WXConvert NSInteger:value]);
        if (isUpdate) {
            _skLab.font = [UIFont systemFontOfSize:_fontSize];
        }
    } else if ([key isEqualToString:@"color"]) {
        _color = [WXConvert NSString:value];
        if (isUpdate) {
            _skLab.textColor = [WXConvert UIColor:_color];
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
        _skLab.textContent = _content;
    }
}

- (void)addText:(id)value
{
    if (value) {
        _content = [_content stringByAppendingString:[WXConvert NSString:value]];
        _skLab.textContent = _content;
    }
}

- (void)startScroll
{
    [_skLab continueScroll];
    [_skLab setEnableFade:YES];
}

- (void)stopScroll
{
    [_skLab pauseScroll];
    [_skLab setEnableFade:NO];
}

- (BOOL)isStarting
{
    return [_skLab isScroll];
}

- (void)setSpeed:(id)value
{
    if (value) {
        _kspeed = [WXConvert CGFloat:value];
        _skLab.pointsPerFrame = _kspeed / 2.2;
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

#pragma mark action

- (void)itemPanClick
{
    if ([_skLab isScroll]) {
        [self stopScroll];
    } else {
        [self startScroll];
    }

    if (_isItemClick) {
        [self fireEvent:@"itemClick" params:@{@"isStarting":@([_skLab isScroll])}];
    }
}

@end
