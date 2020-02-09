//
//  eeuiNavbarComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiNavbarComponent.h"
#import "eeuiNavbarItemComponent.h"
#import "UIImage+TBCityIconFont.h"
#import "WXComponent+Layout.h"
#import "WXComponent_internal.h"
#import "WXUtility.h"
#import "eeuiIconComponent.h"
#import "DeviceUtil.h"

#define kItemViewTag 8000

@interface eeuiNavView : UIView

@end

@implementation eeuiNavView

@end

@interface eeuiNavbarComponent()

@property (nonatomic, strong) NSString *titleType;
@property (nonatomic, strong) NSString *kbackgroundColor;

@property (nonatomic, strong) NSMutableArray *subViews;
@property (nonatomic, strong) NSMutableDictionary *subFrames;

@property (nonatomic, strong) WXSDKInstance *navInstance;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, assign) BOOL isDisItemBack;


@end

@implementation eeuiNavbarComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _titleType = @"middle";
        _kbackgroundColor = @"#3EB4FF";

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        _navInstance = weexInstance;
        
        _subViews = [NSMutableArray arrayWithCapacity:5];
        _subFrames = [[NSMutableDictionary alloc] init];

        [self _fillCSSNode:@{
                             @"flexDirection":@"row",
                             @"alignItems": @"center"} isUpdate:YES];
    }

    return self;
}

- (UIView*)loadView
{
    return [[eeuiNavView alloc] init];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [WXConvert UIColor:_kbackgroundColor];

    [self fireEvent:@"ready" params:nil];
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


- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    [super insertSubview:subcomponent atIndex:index];

    if ([subcomponent isKindOfClass:[eeuiNavbarItemComponent class]]) {
        if (_subViews.count == 0) {
            [_subViews addObject:subcomponent];
        } else {
            [_subViews insertObject:subcomponent atIndex:index];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadComponentView];
        });
    }
}

- (void)loadComponentView
{
    eeuiNavView *navView = (eeuiNavView*)self.view;
    for (UIView *old in navView.subviews) {
        [old removeFromSuperview];
    }

    NSMutableArray *leftList = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *titleList = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *rightList = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i< _subViews.count; i++) {
        eeuiNavbarItemComponent *component = _subViews[i];
        
        UIView *view = component.view;
        CGRect frame = view.frame;

        if ([component.barType isEqualToString:@"back"]) {
            UIImage *backImg = [DeviceUtil getIconText:@"ios-arrow-back" font:19 color:@"#ffffff"];
            UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.height);
            [backBtn setImage:backImg forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(barBackClick) forControlEvents:UIControlEventTouchUpInside];
            [leftList addObject:backBtn];
            backBtn.tag = kItemViewTag + i;
            frame = backBtn.frame;
        } else if ([component.barType isEqualToString:@"title"]) {
            [titleList addObject:component.view];
        } else if ([component.barType isEqualToString:@"left"]) {
            [leftList addObject:component.view];
        } else if ([component.barType isEqualToString:@"right"]) {
            [rightList addObject:component.view];
        }
        
        view.tag = kItemViewTag + i;
        [_subFrames setObject:@{
                                @"w":@(frame.size.width),
                                @"ml":@([component getCssStyleValueForKey:@"margin-left"]),
                                @"mr":@([component getCssStyleValueForKey:@"margin-right"])} forKey:[NSString stringWithFormat:@"tag_%ld", (long)view.tag]];
    }

    CGFloat leftWidth = 0;
    for (UIView *view in leftList) {
        NSString *key = [NSString stringWithFormat:@"tag_%ld", (long)view.tag];
        leftWidth += [WXConvert CGFloat:_subFrames[key][@"ml"]] + [WXConvert CGFloat:_subFrames[key][@"w"]] + [WXConvert CGFloat:_subFrames[key][@"mr"]];
    }

    CGFloat rightWidth = 0;
    for (UIView *view in rightList) {
        NSString *key = [NSString stringWithFormat:@"tag_%ld", (long)view.tag];
        rightWidth += [WXConvert CGFloat:_subFrames[key][@"ml"]] + [WXConvert CGFloat:_subFrames[key][@"w"]] + [WXConvert CGFloat:_subFrames[key][@"mr"]];
    }
    
    CGFloat titleWidth = 0;
    for (UIView *view in titleList) {
        NSString *key = [NSString stringWithFormat:@"tag_%ld", (long)view.tag];
        titleWidth += [WXConvert CGFloat:_subFrames[key][@"ml"]] + [WXConvert CGFloat:_subFrames[key][@"w"]] + [WXConvert CGFloat:_subFrames[key][@"mr"]];
    }

    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftWidth, self.view.frame.size.height)];
    [leftView setClipsToBounds:true];
    [navView addSubview:leftView];

    CGFloat leftX = 0;
    for (UIView *view in leftList) {
        NSString *key = [NSString stringWithFormat:@"tag_%ld", (long)view.tag];
        CGRect frame = view.frame;
        frame.origin.x = [WXConvert NSInteger:_subFrames[key][@"ml"]] + leftX;
        view.frame = frame;
        [leftView addSubview:view];
        leftX += [WXConvert CGFloat:_subFrames[key][@"ml"]] + [WXConvert CGFloat:_subFrames[key][@"w"]] + [WXConvert CGFloat:_subFrames[key][@"mr"]];
    }

    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - rightWidth, 0, rightWidth, self.view.frame.size.height)];
    [rightView setClipsToBounds:true];
    [navView addSubview:rightView];

    CGFloat rightX = 0;
    for (UIView *view in rightList) {
        NSString *key = [NSString stringWithFormat:@"tag_%ld", (long)view.tag];
        CGRect frame = view.frame;
        frame.origin.x = [WXConvert NSInteger:_subFrames[key][@"ml"]] + rightX;
        view.frame = frame;
        [rightView addSubview:view];
        rightX += [WXConvert CGFloat:_subFrames[key][@"ml"]] + [WXConvert CGFloat:_subFrames[key][@"w"]] + [WXConvert CGFloat:_subFrames[key][@"mr"]];
    }

    CGFloat maxWidth = MAX(leftWidth, rightWidth);
    UIView *titleView = nil;
    if ([_titleType isEqualToString:@"left"]) {
        titleView = [[UIView alloc] initWithFrame:CGRectMake(maxWidth, 0, self.view.frame.size.width - (maxWidth * 2), self.view.frame.size.height)];
    }else if ([_titleType isEqualToString:@"right"]) {
        titleWidth = MIN(titleWidth, self.view.frame.size.width - (maxWidth * 2));
        CGFloat titleLeft = self.view.frame.size.width - (maxWidth * 2) - titleWidth + maxWidth;
        titleView = [[UIView alloc] initWithFrame:CGRectMake(titleLeft, 0, titleWidth, self.view.frame.size.height)];
    }else{
        titleWidth = MIN(titleWidth, self.view.frame.size.width - (maxWidth * 2));
        titleView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - titleWidth) / 2, 0, titleWidth, self.view.frame.size.height)];
    }
    [titleView setClipsToBounds:true];
    [navView addSubview:titleView];

    CGFloat titleX = 0;
    for (UIView *view in titleList) {
        NSString *key = [NSString stringWithFormat:@"tag_%ld", (long)view.tag];
        CGRect frame = view.frame;
        frame.origin.x = [WXConvert NSInteger:_subFrames[key][@"ml"]] + titleX;
        view.frame = frame;
        [titleView addSubview:view];
        titleX += [WXConvert CGFloat:_subFrames[key][@"ml"]] + [WXConvert CGFloat:_subFrames[key][@"w"]] + [WXConvert CGFloat:_subFrames[key][@"mr"]];
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
    } else if ([key isEqualToString:@"titleType"]) {
        _titleType = [WXConvert NSString:value];
        if (isUpdate) {
            [self loadComponentView];
        }
    } else if ([key isEqualToString:@"backgroundColor"]) {
        _kbackgroundColor = [WXConvert NSString:value];
        if (isUpdate) {
            self.view.backgroundColor = [WXConvert UIColor:_kbackgroundColor];
        }
    }
}

#pragma mark methods

- (void)barBackClick
{
    [self fireEvent:@"goBack" params:nil];

    if (!_isDisItemBack) {
        [[_navInstance.viewController navigationController] popViewControllerAnimated:YES];
    }
}

- (void)showBack
{
    if (_backBtn) {
        _backBtn.hidden = NO;
    }
}

- (void)hideBack
{
    if (_backBtn) {
        _backBtn.hidden = YES;
    }
}

@end
