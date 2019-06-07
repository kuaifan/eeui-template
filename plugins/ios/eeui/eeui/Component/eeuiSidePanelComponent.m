//
//  eeuiSidePanelComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/4.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiSidePanelComponent.h"
#import "eeuiSidePanelItemComponent.h"
#import "UIImage+TBCityIconFont.h"
#import "DeviceUtil.h"

#define SideItemComponentTag 800

@interface eeuiSidePanelComponent()

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) BOOL scrollbar;
@property (nonatomic, strong) NSString *backgroundColor;
@property (nonatomic, strong) NSMutableArray *subViews;
@property (nonatomic, strong) NSMutableArray *otherViews;
@property (nonatomic, strong) WXSDKInstance *sideInstance;

@property (nonatomic, strong) UIControl *bgView;
@property (nonatomic, strong) UIScrollView *sideScrollView;
@property (nonatomic, assign) BOOL showPanel;

@property (nonatomic, assign) CGFloat pageComHeight;

@end

@implementation eeuiSidePanelComponent

WX_EXPORT_METHOD(@selector(menuShow))
WX_EXPORT_METHOD(@selector(menuHide))
WX_EXPORT_METHOD(@selector(menuToggle))
WX_EXPORT_METHOD_SYNC(@selector(getMenuShow))
WX_EXPORT_METHOD(@selector(setMenuWidth:))
WX_EXPORT_METHOD(@selector(setMenuScrollbar:))
WX_EXPORT_METHOD(@selector(setMenuBackgroundColor:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _width = SCALE(380);
        _scrollbar = NO;
        _backgroundColor = @"#ffffff";

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        _subViews = [NSMutableArray arrayWithCapacity:5];

        _sideInstance = weexInstance;
        _showPanel = NO;
        _pageComHeight = 0;

    }

    return self;
}

- (UIView*)loadView
{
    return [[UIView alloc] init];
}

- (void)viewDidLoad
{
    self.bgView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    [self.bgView addTarget:self action:@selector(menuHide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bgView];

    self.sideScrollView = [[UIScrollView alloc] init];
    [self.bgView addSubview:self.sideScrollView];

    self.bgView.hidden = YES;
    self.sideScrollView.hidden = YES;

    [self loadSideScrollView];

    [self fireEvent:@"ready" params:nil];
}

-(void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
    [self loadSideScrollView];
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
    [self loadSideScrollView];
}

- (void)loadSideScrollView
{
    self.sideScrollView.frame = CGRectMake(-_width, 0, _width, self.view.frame.size.height);
    self.sideScrollView.backgroundColor = [WXConvert UIColor:_backgroundColor];
    self.sideScrollView.showsVerticalScrollIndicator = _scrollbar;
}

- (void)loadComponentView
{
    for (UIView *oldView in self.sideScrollView.subviews) {
        if (oldView.tag >= SideItemComponentTag) {
            [oldView removeFromSuperview];
        }
    }

    CGFloat allHeight = 0;
    for (int i = 0; i< _subViews.count; i++) {
        eeuiSidePanelItemComponent *component = _subViews[i];
        UIView *view = component.view;
        CGRect frame = view.frame;
        frame.origin.y = allHeight;
        view.frame = frame;
        view.tag = SideItemComponentTag + i;
        [self.sideScrollView addSubview:view];
        allHeight += frame.size.height;


        if (![self.sideScrollView.subviews containsObject:view]) {
            if (index < 0) {
                [self.sideScrollView addSubview:view];
            } else {
                [self.sideScrollView insertSubview:view atIndex:i];
            }
        }

        //添加手势
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemPanClick:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tapRecognizer];

        //长按
        UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongClick:)];
        longRecognizer.minimumPressDuration = 1.0;
        [view addGestureRecognizer:longRecognizer];

        // 如果长按确定偵測失败才會触发单击
        [tapRecognizer requireGestureRecognizerToFail:longRecognizer];
    }

    [self.sideScrollView setContentSize:CGSizeMake(0, allHeight)];
}


- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    UIView *view = subcomponent.view;

    if ([subcomponent isKindOfClass:[eeuiSidePanelItemComponent class]]) {
        if (_subViews.count == 0) {
            [_subViews addObject:subcomponent];
        } else {
            [_subViews insertObject:subcomponent atIndex:index];
        }
        _pageComHeight += view.frame.size.height;

        [super insertSubview:subcomponent atIndex:index];

        [self loadComponentView];
    } else {
        if (index <= _subViews.count) {
            [super insertSubview:subcomponent atIndex:index - _subViews.count];
            CGRect frame = view.frame;
            frame.origin.y = frame.origin.y - _pageComHeight;
            frame.size.height = 400;
            view.frame = frame;
        }
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
    } else if ([key isEqualToString:@"width"]) {
        _width = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"scrollbar"]) {
        _scrollbar = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"backgroundColor"]) {
        _backgroundColor = [WXConvert NSString:value];
    }
}

#pragma mark action
- (void)itemPanClick:(UITapGestureRecognizer*)panRecognizer
{
    NSInteger index = panRecognizer.view.tag - SideItemComponentTag;
    if (index < _subViews.count) {
        eeuiSidePanelItemComponent *cmp = _subViews[index];
        NSString *name = [NSString stringWithFormat:@"%@", cmp.name];
        NSDictionary *data = @{@"name":name, @"position":@(index)};
        [self fireEvent:@"itemClick" params:data];
    }
}

- (void)itemLongClick:(UILongPressGestureRecognizer*)longRecognizer
{
    NSInteger index = longRecognizer.view.tag - SideItemComponentTag;
    if (index < _subViews.count) {
        eeuiSidePanelItemComponent *cmp = _subViews[index];
        NSString *name = [NSString stringWithFormat:@"%@", cmp.name];
        NSDictionary *data = @{@"name":name, @"position":@(index)};
        [self fireEvent:@"itemLongClick" params:data];
    }
}

- (void)showPanelView
{
    __weak typeof(eeuiSidePanelComponent) *ws = self;

    if (_showPanel) {
        self.bgView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            ws.sideScrollView.hidden = NO;
            CGRect frame = ws.sideScrollView.frame;
            frame.origin.x = 0;
            ws.sideScrollView.frame = frame;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            ws.sideScrollView.hidden = YES;
            CGRect frame = ws.sideScrollView.frame;
            frame.origin.x = -ws.width;
            ws.sideScrollView.frame = frame;
            ws.bgView.hidden = YES;
        }];
    }
}

#pragma mark methods

- (void)menuShow
{
    _showPanel = YES;
    [self showPanelView];
    [self fireEvent:@"switchListener" params:@{@"show":@(_showPanel)}];
}
- (void)menuHide
{
    _showPanel = NO;
    [self showPanelView];
    [self fireEvent:@"switchListener" params:@{@"show":@(_showPanel)}];
}
- (void)menuToggle
{
    _showPanel = !_showPanel;
    [self showPanelView];
    [self fireEvent:@"switchListener" params:@{@"show":@(_showPanel)}];
}
- (BOOL)getMenuShow
{
    return _showPanel;
}
- (void)setMenuWidth:(NSInteger)menuWidth
{
    _width = SCALE(menuWidth);
    [self loadSideScrollView];
}
- (void)setMenuScrollbar:(BOOL)menuScrollbar
{
    _scrollbar = menuScrollbar;
    [self loadSideScrollView];
}
- (void)setMenuBackgroundColor:(NSString*)menuBackgroundColor
{
    _backgroundColor = menuBackgroundColor;
    [self loadSideScrollView];
}


@end
