//
//  eeuiButtonComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiButtonComponent.h"
#import "DeviceUtil.h"
#import "UIButton+SGImagePosition.h"

@interface eeuiButtonComponent ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) NSString *ktext;//按钮文字
@property (nonatomic, strong) NSString *color;//按钮文字颜色    #FFFFFF
@property (nonatomic, assign) CGFloat fontSize;//字体大小    -
@property (nonatomic, strong) NSString *kbackgroundColor;//按钮背景颜色    #3EB4FF
@property (nonatomic, assign) CGFloat borderRadius;//圆角半径    8
@property (nonatomic, assign) CGFloat borderWidth;//边框大小    0
@property (nonatomic, strong) NSString *borderColor;//边框颜色    -
@property (nonatomic, assign) BOOL kdisabled;//是否禁用    false
@property (nonatomic, assign) BOOL kloading;//是否加载中    false
@property (nonatomic, strong) NSString *kmodel;//预设风格，详细注①    -

@property (nonatomic, assign) BOOL isBackgroundColor;//初始化是否存在背景色

@property (nonatomic, assign) BOOL isRemoveObserver;

@end

@implementation eeuiButtonComponent

WX_EXPORT_METHOD(@selector(setText:))
WX_EXPORT_METHOD(@selector(setTextColor:))
WX_EXPORT_METHOD(@selector(setTextSize:))
WX_EXPORT_METHOD(@selector(setModel:))
WX_EXPORT_METHOD(@selector(setRadius:))
WX_EXPORT_METHOD(@selector(setBackgroundColor:))
WX_EXPORT_METHOD(@selector(setBorder:))
WX_EXPORT_METHOD(@selector(setDisabled:))
WX_EXPORT_METHOD(@selector(setLoading:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _ktext = @"";
        _color = @"#FFFFFF";
        _fontSize = FONT(24);
        _kbackgroundColor = @"#3EB4FF";
        _borderRadius = SCALE(8);
        _borderWidth = 0;
        _borderColor = @"#ffffff";
        _kdisabled = NO;
        _kloading = NO;
        _kmodel = @"";

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        if (!_isBackgroundColor && _kmodel.length > 0) {
            _kbackgroundColor = _kmodel;
            if ([_kmodel isEqualToString:@"white"] && [_color isEqualToString:@"#FFFFFF"]) {
                _color = @"#242424";//背景白色，字体黑色
            }
        }
    }

    return self;
}

- (UIView*)loadView
{
    return [[UIButton alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    UIButton *btn = (UIButton*)self.view;
    [btn setTitle:_ktext forState:UIControlStateNormal];
    [btn setTitleColor:[WXConvert UIColor:_color] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
    btn.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
    btn.layer.cornerRadius = _borderRadius;
    btn.layer.borderWidth = _borderWidth;
    btn.layer.borderColor = [WXConvert CGColor:_borderColor];
    btn.layer.masksToBounds = YES;
    [btn setBackgroundImage:[self imageWithColor:[WXConvert UIColor:@"#e4e4e4"]] forState:UIControlStateDisabled];
    [btn setTitleColor:[WXConvert UIColor:@"#ffffff"] forState:UIControlStateDisabled];
    btn.enabled = !_kdisabled;

    //加载风火轮
    CGFloat width = [_ktext boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : btn.titleLabel.font} context:nil].size.width;
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.activityIndicatorView.center = CGPointMake((btn.frame.size.width - width - 35)/2 + 30/2, btn.frame.size.height/2);
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [btn addSubview:self.activityIndicatorView];

    if (_kloading) {
        [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:35];
        [self.activityIndicatorView startAnimating];
    } else {
        [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:0];
        [self.activityIndicatorView setHidden:YES];
    }

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
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton *btn = (UIButton*)self.view;
            btn.layer.cornerRadius = self.borderRadius;
            CGFloat width = [self.ktext boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : btn.titleLabel.font} context:nil].size.width;
            self.activityIndicatorView.center = CGPointMake((btn.frame.size.width - width - 35)/2 + 30/2, btn.frame.size.height/2);
        });

    }
}

- (UIImage *)imageWithColor:(UIColor *)color {

    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
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
    } else if ([key isEqualToString:@"text"]) {
        _ktext = [WXConvert NSString:value];
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            [btn setTitle:_ktext forState:UIControlStateNormal];
            CGFloat width = [_ktext boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : btn.titleLabel.font} context:nil].size.width;
            self.activityIndicatorView.center = CGPointMake((btn.frame.size.width - width - 35)/2 + 30/2, btn.frame.size.height/2);
        }
    } else if ([key isEqualToString:@"color"]) {
        _color = [WXConvert NSString:value];
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            [btn setTitleColor:[WXConvert UIColor:_color] forState:UIControlStateNormal];
        }
    } else if ([key isEqualToString:@"fontSize"]) {
        _fontSize = FONT([WXConvert NSInteger:value]);
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
        }
    } else if ([key isEqualToString:@"backgroundColor"]) {
        _kbackgroundColor = [WXConvert NSString:value];
        _isBackgroundColor = YES;
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
        }
    } else if ([key isEqualToString:@"borderRadius"]) {
        _borderRadius = SCALE([WXConvert NSInteger:value]);
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.layer.cornerRadius = _borderRadius;
            btn.layer.masksToBounds = YES;
        }
    } else if ([key isEqualToString:@"borderWidth"]) {
       _borderWidth = SCALE([WXConvert NSInteger:value]);
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.layer.borderWidth = _borderWidth;
        }
    } else if ([key isEqualToString:@"borderColor"]) {
        _borderColor = [WXConvert NSString:value];
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.layer.borderColor = [WXConvert CGColor:_borderColor];
        }
    } else if ([key isEqualToString:@"disabled"]) {
        _kdisabled = [WXConvert BOOL:value];
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.enabled = !_kdisabled;
        }
    } else if ([key isEqualToString:@"loading"]) {
        _kloading = [WXConvert BOOL:value];
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            if (_kloading) {
                [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:35];
                [self.activityIndicatorView setHidden:NO];
                [self.activityIndicatorView startAnimating];
            } else {
                [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:0];
                [self.activityIndicatorView setHidden:YES];
                [self.activityIndicatorView stopAnimating];
            }
        }
    } else if ([key isEqualToString:@"model"]) {
        _kmodel = [WXConvert NSString:value];
        if (isUpdate) {
            UIButton *btn = (UIButton*)self.view;
            btn.backgroundColor = [WXConvert UIColor:_kmodel];
        }
    }
    if (isUpdate) {
        UIButton *btn = (UIButton*)self.view;
        if (!btn.enabled) {
            btn.layer.borderColor = [WXConvert CGColor:@"#E4E4E4"];
        }else{
            btn.layer.borderColor = [WXConvert CGColor:_borderColor];
        }
    }
}

#pragma mark methods

- (void)setText:(NSString *)text
{
    if (text) {
        _ktext = text;
        UIButton *btn = (UIButton*)self.view;
        [btn setTitle:text forState:UIControlStateNormal];
    }
}

- (void)setTextColor:(NSString *)textColor
{
    if (textColor) {
        _color = textColor;
        UIButton *btn = (UIButton*)self.view;
        [btn setTitleColor:[WXConvert UIColor:textColor] forState:UIControlStateNormal];
    }
}

- (void)setTextSize:(NSInteger)textSize
{
    if (textSize) {
        _fontSize = textSize;
        UIButton *btn = (UIButton*)self.view;
        btn.titleLabel.font = [UIFont systemFontOfSize:textSize];
    }
}

- (void)setModel:(NSString *)model
{
    if (model) {
        _kmodel = model;
        UIButton *btn = (UIButton*)self.view;
        btn.backgroundColor = [WXConvert UIColor:_kmodel];
    }
}

- (void)setRadius:(NSInteger)radius
{
    if (radius) {
        _borderRadius = radius;
        UIButton *btn = (UIButton*)self.view;
        btn.layer.cornerRadius = radius;
        btn.layer.masksToBounds = YES;
    }
}

- (void)setBackgroundColor:(NSString *)backgroundColor
{
    if (backgroundColor) {
        _kbackgroundColor = backgroundColor;
        UIButton *btn = (UIButton*)self.view;
        btn.backgroundColor = [WXConvert UIColor:backgroundColor];
    }
}

- (void)setBorder:(NSArray *)border
{
    if (border.count == 2) {
        _borderWidth = [border.firstObject integerValue];
        _borderColor = border.lastObject;
        UIButton *btn = (UIButton*)self.view;
        btn.layer.borderWidth = _borderWidth;
        btn.layer.borderColor = [WXConvert CGColor:_borderColor];
    }
}

- (void)setDisabled:(BOOL)disabled
{
    _kdisabled = disabled;
    UIButton *btn = (UIButton*)self.view;
    btn.enabled = !_kdisabled;
}

- (void)setLoading:(BOOL)loading
{
    UIButton *btn = (UIButton*)self.view;
    _kloading = loading;
    if (_kloading) {
        [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:35];
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicatorView startAnimating];
    } else {
        [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:0];
        [self.activityIndicatorView setHidden:YES];
        [self.activityIndicatorView stopAnimating];
    }
}

@end
