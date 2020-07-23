//
//  eeuiTabbarComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiTabbarComponent.h"
#import "DeviceUtil.h"
#import "UIImage+TBCityIconFont.h"
#import "TriangleIndicatorView.h"
#import "eeuiViewController.h"
#import "eeuiNewPageManager.h"
#import "eeuiTabbarPageComponent.h"
#import "MJRefresh.h"
#import "SDWebImageDownloader.h"
#import "UIButton+WebCache.h"
#import "SGEasyButton.h"
#import "FDFullscreenScrollView.h"
#import "Config.h"

#define TabItemBtnTag 1000
#define TabItemMessageTag 2000
#define TabItemDotTag 3000
#define TabBgScrollTag 4000

#define iPhoneXSeries (([[UIApplication sharedApplication] statusBarFrame].size.height == 44.0f) ? (YES):(NO))

@interface eeuiTabbarComponent() <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *ktabType;
@property (nonatomic, strong) NSString *ktabBackgroundColor;
@property (nonatomic, strong) NSString *indicatorColor;
@property (nonatomic, strong) NSString *underlineColor;
@property (nonatomic, strong) NSString *dividerColor;
@property (nonatomic, strong) NSString *textSelectColor;
@property (nonatomic, strong) NSString *textUnselectColor;

@property (nonatomic, assign) CGFloat ktabHeight;
@property (nonatomic, assign) CGFloat tabPadding;
@property (nonatomic, assign) CGFloat tabWidth;
@property (nonatomic, assign) NSInteger indicatorStyle;
@property (nonatomic, assign) NSInteger indicatorGravity;
@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, assign) CGFloat indicatorWidth;
@property (nonatomic, assign) CGFloat indicatorCornerRadius;
@property (nonatomic, assign) NSInteger indicatorAnimDuration;
@property (nonatomic, assign) NSInteger underlineGravity;
@property (nonatomic, assign) CGFloat underlineHeight;
@property (nonatomic, assign) CGFloat dividerWidth;
@property (nonatomic, assign) CGFloat dividerPadding;
@property (nonatomic, assign) NSInteger textBold;
@property (nonatomic, assign) NSInteger textSize;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger iconGravity;
@property (nonatomic, assign) CGFloat iconWidth;
@property (nonatomic, assign) CGFloat iconHeight;
@property (nonatomic, assign) CGFloat iconMargin;

@property (nonatomic, assign) NSInteger ksideLine;

@property (nonatomic, assign) BOOL tabPageAnimated;
@property (nonatomic, assign) BOOL tabSpaceEqual;
@property (nonatomic, assign) BOOL tabSlideSwitch;
@property (nonatomic, assign) BOOL indicatorAnimEnable;
@property (nonatomic, assign) BOOL indicatorBounceEnable;
@property (nonatomic, assign) BOOL iconVisible;
@property (nonatomic, assign) BOOL isExistIconVisible;//辅助初始化
@property (nonatomic, assign) BOOL isPreload;//预先加载

@property (nonatomic, strong) UIScrollView *tabView;
@property (nonatomic, strong) FDFullscreenScrollView *bodyView;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, strong) NSMutableArray *subComps;
@property (nonatomic, strong) NSMutableArray *tabPages;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger lastSelectedIndex;//上次被选中的标签

@property (nonatomic, strong) WXSDKInstance *tabInstance;
@property (nonatomic, strong) NSMutableArray *tabNameList;
@property (nonatomic, strong) NSMutableArray *childPageList;
@property (nonatomic, strong) NSMutableArray *childComponentList;
@property (nonatomic, strong) NSMutableDictionary *lifeTabPages;
@property (nonatomic, assign) CGFloat calculatedHeight;

@property (nonatomic, assign) BOOL isRemoveObserver;

@end

@implementation eeuiTabbarComponent

WX_EXPORT_METHOD_SYNC(@selector(getTabPosition:))
WX_EXPORT_METHOD_SYNC(@selector(getTabName:))
WX_EXPORT_METHOD(@selector(showMsg:num:))
WX_EXPORT_METHOD(@selector(showDot:))
WX_EXPORT_METHOD(@selector(hideMsg:))
WX_EXPORT_METHOD(@selector(removePageAt:))
WX_EXPORT_METHOD(@selector(setCurrentItem:))
WX_EXPORT_METHOD(@selector(goUrl:url:))
WX_EXPORT_METHOD(@selector(reload:))
WX_EXPORT_METHOD(@selector(setTabType:))
WX_EXPORT_METHOD(@selector(setTabHeight:))
WX_EXPORT_METHOD(@selector(setTabBackgroundColor:))
WX_EXPORT_METHOD(@selector(setTabTextsize:))
WX_EXPORT_METHOD(@selector(setTabTextBold:))
WX_EXPORT_METHOD(@selector(setTabTextUnselectColor:))
WX_EXPORT_METHOD(@selector(setTabTextSelectColor:))
WX_EXPORT_METHOD(@selector(setTabIconVisible:))
WX_EXPORT_METHOD(@selector(setTabIconWidth:))
WX_EXPORT_METHOD(@selector(setTabIconHeight:))
WX_EXPORT_METHOD(@selector(setSideline:))
WX_EXPORT_METHOD(@selector(setTabPageAnimated:))
WX_EXPORT_METHOD(@selector(setTabSlideSwitch:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _tabPages = [NSMutableArray arrayWithCapacity:5];

        _selectedIndex = 0;
        _lastSelectedIndex = 0;

        _tabInstance = weexInstance;

        _ktabType = @"bottom";
        _indicatorColor = @"#FFFFFF";
        _underlineColor = @"#FFFFFF";
        _dividerColor = @"#FFFFFF";
        _ktabHeight = SCALEFLOAT(100);
        _tabPadding = 0;
        _tabWidth = 0;
        _indicatorStyle = 0;
        _indicatorGravity = 0;
        _indicatorHeight = SCALEFLOAT(4);
        _indicatorWidth = SCALEFLOAT(20);
        _indicatorCornerRadius = SCALEFLOAT(2);
        _indicatorAnimDuration = 300;
        _underlineGravity = 0;
        _underlineHeight = 0;
        _dividerWidth = 0;
        _dividerPadding = SCALEFLOAT(12);
        _textBold = 0;
        _textSize = FONT(26);
        _iconGravity = 1;
        _iconWidth = 0;
        _iconHeight = 0;
        _iconMargin = SCALEFLOAT(10);
        _ksideLine = 1;
        _tabPageAnimated = YES;
        _tabSlideSwitch = YES;
        _tabSpaceEqual = YES;
        _indicatorAnimEnable = YES;
        _indicatorBounceEnable = YES;
        _isPreload = NO;

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        if (!_ktabBackgroundColor) {
            if ([_ktabType isEqualToString:@"bottom"]) {
                _ktabBackgroundColor = @"#ffffff";
            } else {
                _ktabBackgroundColor = @"#3EB4FF";
            }
        }

        if (!_textSelectColor) {
            if ([_ktabType isEqualToString:@"bottom"]) {
                _textSelectColor = @"#2C97DE";
            } else {
                _textSelectColor = @"#ffffff";
            }
        }

        if (!_textUnselectColor) {
            if ([_ktabType isEqualToString:@"bottom"]) {
                _textUnselectColor = @"#333333";
            } else {
                _textUnselectColor = @"#eeeeee";
            }
        }

        if (!_isExistIconVisible) {
            if ([_ktabType isEqualToString:@"bottom"]) {
                _iconVisible = YES;
            } else {
                _iconVisible = NO;
            }
        }

        if ([_ktabType isEqualToString:@"slidingTop"]) {
            _iconVisible = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    self.subComps = [NSMutableArray arrayWithCapacity:5];
    self.childPageList = [NSMutableArray arrayWithCapacity:5];
    self.childComponentList = [NSMutableArray arrayWithCapacity:5];
    self.lifeTabPages = [NSMutableDictionary dictionaryWithCapacity:5];

    self.bodyView = [[FDFullscreenScrollView alloc] init];
    self.bodyView.scrollEnabled = _tabSlideSwitch;
    self.bodyView.pagingEnabled = YES;
    self.bodyView.showsHorizontalScrollIndicator = NO;
    self.bodyView.bounces = NO;
    self.bodyView.delegate = self;
    [self.view addSubview:self.bodyView];

    if (@available(iOS 11.0, *)) {
        self.bodyView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    //tab
    self.tabView = [[UIScrollView alloc] init];
    self.tabView.showsVerticalScrollIndicator = FALSE;
    self.tabView.showsHorizontalScrollIndicator = FALSE;

    [self.view addSubview:self.tabView];

    [self loadTabView];

    //indicator
    [self initIndicatorView];

    //下划线
    self.underLineView = [[UIView alloc] init];
    [self.view addSubview:self.underLineView];
    [self loadUnderLineView];

    //添加子视图
    if (_tabPages.count > 0) {
        if (_isPreload) {
            for (int i = 0; i < _tabPages.count; i++) {
                [self loadTabPagesView:i];
            }
        } else {
            [self loadTabPagesView:_selectedIndex];
        }
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
    for (id key in _lifeTabPages) {
        eeuiViewController *vc = [_lifeTabPages objectForKey:key];
        if (vc) {
            vc.isTabbarChildSelected = YES;
            [vc lifeCycleEvent:LifeCycleDestroy];
        }
        [vc removeFromParentViewController];
    }
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
        [self loadTabView];

        [self loadSelectedView];

        [self loadUnderLineView];
    }
}

- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }

    [self loadTabView];
    [self initIndicatorView];

    [self loadSelectedView];

    [self loadUnderLineView];
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }

    [self loadTabView];
    [self initIndicatorView];

    [self loadSelectedView];

    [self loadUnderLineView];
}


- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    if ([subcomponent isKindOfClass:[eeuiTabbarPageComponent class]]) {
        if (self.subComps.count == 0 || _isPreload) {
            [self.subComps addObject:subcomponent];
            [self performSelector:@selector(loadComponentID:) withObject:@(index) afterDelay:0.1];
        } else {
            [self.subComps insertObject:subcomponent atIndex:(NSUInteger) index];
        }
    }

    [self loadTabView];
    [self initIndicatorView];
}


#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        NSArray *keys = [value allKeys];
        for (NSString *k in keys) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"tabPages"]) {
        _tabPages = [NSMutableArray arrayWithArray:value];
    } else if ([key isEqualToString:@"tabType"]) {
        _ktabType = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"tabBackgroundColor"]) {
        _ktabBackgroundColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"indicatorColor"]) {
        _indicatorColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"underlineColor"]) {
        _underlineColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"dividerColor"]) {
        _dividerColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"textSelectColor"]) {
        _textSelectColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"textUnselectColor"]) {
        _textUnselectColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"tabHeight"]) {
        _ktabHeight = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"tabPadding"]) {
        _tabPadding = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"tabWidth"]) {
        _tabWidth = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"tabPageAnimated"]) {
        _tabPageAnimated = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"tabSlideSwitch"]) {
        [self setTabSlideSwitch:[WXConvert BOOL:value]];
    } else if ([key isEqualToString:@"indicatorStyle"]) {
        _indicatorStyle = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"indicatorGravity"]) {
        _indicatorGravity = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"indicatorHeight"]) {
        _indicatorHeight = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"indicatorWidth"]) {
        _indicatorWidth = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"indicatorCornerRadius"]) {
        _indicatorCornerRadius = SCALEFLOAT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"indicatorAnimDuration"]) {
        _indicatorAnimDuration = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"underlineGravity"]) {
        _underlineGravity = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"underlineHeight"]) {
        _underlineHeight = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"dividerWidth"]) {
        _dividerWidth = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"dividerPadding"]) {
        _dividerPadding = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"textBold"]) {
        _textBold = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"textSize"]) {
        _textSize = FONT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"fontSize"]) {
        _textSize = FONT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"iconGravity"]) {
        _iconGravity = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"iconWidth"]) {
        _iconWidth = SCALEFLOAT([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"iconHeight"]) {
        _iconHeight = SCALEFLOAT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"iconMargin"]) {
        _iconMargin = SCALEFLOAT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"sideLine"]) {
        _ksideLine = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"tabSpaceEqual"]) {
        _tabSpaceEqual = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"indicatorAnimEnable"]) {
        _indicatorAnimEnable = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"indicatorBounceEnable"]) {
        _indicatorBounceEnable = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"iconVisible"]) {
        _iconVisible = [WXConvert BOOL:value];
        if (!isUpdate) {
            _isExistIconVisible = YES;
        }
    } else if ([key isEqualToString:@"preload"]) {
        _isPreload = [WXConvert BOOL:value];
    }
}

#pragma mark view

- (void)loadTabView
{
    if ([_ktabType isEqualToString:@"bottom"]) {
        self.bodyView.frame = CGRectMake(0, 0, self.calculatedFrame.size.width, self.calculatedFrame.size.height - _ktabHeight);
        self.tabView.frame = CGRectMake(0, self.calculatedFrame.size.height - _ktabHeight, self.calculatedFrame.size.width, _ktabHeight);
    } else {
        self.bodyView.frame = CGRectMake(0, _ktabHeight, self.calculatedFrame.size.width, self.calculatedFrame.size.height - _ktabHeight);
        self.tabView.frame = CGRectMake(0, 0, self.calculatedFrame.size.width, _ktabHeight);
    }

    self.tabView.backgroundColor = [WXConvert UIColor:_ktabBackgroundColor];

    //判断数据源,优先tabPages
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:5];

    if (self.tabPages.count > 0) {
        [dataList addObjectsFromArray:self.tabPages];
    }

    if (self.subComps.count > 0) {
        [dataList addObjectsFromArray:self.subComps];
    }

    if (dataList.count > 0) {
        [self.bodyView setContentSize:CGSizeMake(self.bodyView.frame.size.width * dataList.count, 0)];
        self.tabNameList = [NSMutableArray arrayWithCapacity:5];

        for (UIView *oldView in self.tabView.subviews) {
            [oldView removeFromSuperview];
        }

        CGFloat allWidth = _tabPadding;
        for (int i = 0; i < dataList.count; i++) {
            id data = dataList[i];

            NSString *tabName = @"";
            NSString *title = @"";
            NSInteger message = 0;
            NSString *unSelectedIcon =  @"";
            NSString *selectedIcon =  @"";
            BOOL dot = NO;

            if ([data isKindOfClass:[eeuiTabbarPageComponent class]]) {
                eeuiTabbarPageComponent *cmp = (eeuiTabbarPageComponent*)data;
                tabName = cmp.tabName;
                title = cmp.title;
                message = cmp.message;
                dot = cmp.dot;
                unSelectedIcon = cmp.unSelectedIcon;
                selectedIcon = cmp.selectedIcon;
            } else if ([data isKindOfClass:[NSDictionary class]]) {
                tabName = data[@"tabName"] ? [WXConvert NSString:data[@"tabName"]] : @"";
                title = data[@"title"] ? [WXConvert NSString:data[@"title"]] : @"";
                message = data[@"message"] ? [WXConvert NSInteger:data[@"message"]] : 0;
                dot = data[@"dot"] ? [WXConvert BOOL:data[@"dot"]] : NO;
                unSelectedIcon = data[@"unSelectedIcon"] ? [WXConvert NSString:data[@"unSelectedIcon"]] : @"";
                selectedIcon = data[@"selectedIcon"] ? [WXConvert NSString:data[@"selectedIcon"]] : @"";
            }
            if ([selectedIcon isEqual: @""]) {
                if ([unSelectedIcon isEqual: @""]) {
                    selectedIcon = @"tb-home-fill-light";
                }else{
                    selectedIcon = unSelectedIcon;
                }
            }else if ([unSelectedIcon isEqual: @""]) {
                if ([selectedIcon isEqual: @""]) {
                    unSelectedIcon = @"tb-home-light";
                }else{
                    unSelectedIcon = selectedIcon;
                }
            }

            NSDictionary *nameData = @{@"tabName":tabName, @"position":@(i)};
            if (self.tabNameList.count == 0) {
                [self.tabNameList addObject:nameData];
            } else {
                [self.tabNameList insertObject:nameData atIndex:i];
            }

            CGFloat tabWidth = 0;
            CGFloat iconWidth = 0;
            CGFloat iconHeight = 0;
            CGFloat iconMargin = 0;
            CGFloat titleWidth = 0;
            if (_iconVisible) {
                iconWidth = _iconWidth ? _iconWidth : SCALEFLOAT(40);
                iconHeight = _iconHeight ? _iconHeight : SCALEFLOAT(40);
                iconMargin = _iconMargin;
            }
            titleWidth = [title boundingRectWithSize:CGSizeMake(1000,30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_textSize]}context:nil].size.width + 12 + _tabPadding * 2;

            if (_tabWidth > 0) {
                tabWidth = _tabWidth;
            } else {
                if ([_ktabType isEqualToString:@"slidingTop"]) {
                    tabWidth = titleWidth + 10;
                } else {
                    tabWidth = (self.calculatedFrame.size.width - _tabPadding*2) / dataList.count;
                }
            }

            CGRect btnRect = CGRectMake(allWidth, 0, tabWidth, _ktabHeight);
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = btnRect;
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:[WXConvert UIColor:_textUnselectColor] forState:UIControlStateNormal];
            [btn setTitleColor:[WXConvert UIColor:_textSelectColor] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(tabbarClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = TabItemBtnTag + i;
            [self.tabView addSubview:btn];

            allWidth += tabWidth;

            if ([selectedIcon isEqual: @""]) {
                if ([unSelectedIcon isEqual: @""]) {
                    selectedIcon = @"tb-home-fill-light";
                }else{
                    selectedIcon = unSelectedIcon;
                }
            }else if ([unSelectedIcon isEqual: @""]) {
                if ([selectedIcon isEqual: @""]) {
                    unSelectedIcon = @"tb-home-light";
                }else{
                    unSelectedIcon = selectedIcon;
                }
            }

            //图片
            if (![self isFontIcon:unSelectedIcon]) {
                [btn setImage:[DeviceUtil imageResize:nil andResizeTo:CGSizeMake(iconWidth, iconHeight) icon:nil] forState:UIControlStateNormal];
                NSString *tmpIcon = [Config verifyFile:[DeviceUtil rewriteUrl:unSelectedIcon mInstance:_tabInstance]];
                [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:tmpIcon] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image) {
                        WXPerformBlockOnMainThread(^{
                            [btn setImage:[DeviceUtil imageResize:image andResizeTo:CGSizeMake(iconWidth, iconHeight) icon:tmpIcon] forState:UIControlStateNormal];
                            if (self->_iconVisible == NO) {
                                [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:0];
                            } else if (self->_iconGravity) {
                                [btn SG_imagePositionStyle:(SGImagePositionStyleTop) spacing:iconMargin];
                            } else {
                                [btn SG_imagePositionStyle:(SGImagePositionStyleBottom) spacing:iconMargin];
                            }
                        });
                    }
                }];
            } else {
                [btn setImage:[DeviceUtil imageResize:[DeviceUtil getIconText:unSelectedIcon font:0 color:@"#242424"] andResizeTo:CGSizeMake(iconWidth, iconHeight) icon:unSelectedIcon] forState:UIControlStateNormal];
            }

            if (![self isFontIcon:selectedIcon]) {
                NSString *tmpIcon = [Config verifyFile:[DeviceUtil rewriteUrl:selectedIcon mInstance:_tabInstance]];
                [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:tmpIcon] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image) {
                        WXPerformBlockOnMainThread(^{
                            [btn setImage:[DeviceUtil imageResize:image andResizeTo:CGSizeMake(iconWidth, iconHeight) icon:tmpIcon] forState:UIControlStateSelected];
                            if (self->_iconVisible == NO) {
                                [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:0];
                            } else if (self->_iconGravity) {
                                [btn SG_imagePositionStyle:(SGImagePositionStyleTop) spacing:iconMargin];
                            } else {
                                [btn SG_imagePositionStyle:(SGImagePositionStyleBottom) spacing:iconMargin];
                            }
                        });
                    }
                }];
            } else {
                [btn setImage:[DeviceUtil imageResize:[DeviceUtil getIconText:selectedIcon font:0 color:_textSelectColor] andResizeTo:CGSizeMake(iconWidth, iconHeight) icon:selectedIcon] forState:UIControlStateSelected];
            }

            //字体加粗
            if (_textBold == 2) {
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:_textSize];
            } else {
                btn.titleLabel.font = [UIFont systemFontOfSize:_textSize];
            }

            //当前选中item
            if (i == _selectedIndex) {
                btn.selected = YES;

                if (_textBold == 1) {
                    btn.titleLabel.font = [UIFont boldSystemFontOfSize:_textSize];
                }

                if (_indicatorStyle == 2) {
                    btn.backgroundColor = [WXConvert UIColor:_indicatorColor];
                }
            }

            //上下图片文字
            if (_iconVisible == NO) {
                [btn SG_imagePositionStyle:(SGImagePositionStyleDefault) spacing:0];
            } else if (_iconGravity) {
                [btn SG_imagePositionStyle:(SGImagePositionStyleTop) spacing:iconMargin];
            } else {
                [btn SG_imagePositionStyle:(SGImagePositionStyleBottom) spacing:iconMargin];
            }

            //分割线
            if (i + 1 != dataList.count) {
                UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(btn.frame.origin.x + btn.frame.size.width - _dividerWidth/2, _dividerPadding, _dividerWidth, _ktabHeight - _dividerPadding*2)];
                dividerView.backgroundColor = [WXConvert UIColor:_dividerColor];
                [self.tabView addSubview:dividerView];
            }

            CGFloat labW = MAX(btn.imageView.frame.size.width + 10, titleWidth);
            if (_iconVisible == YES && _iconGravity == 1 && btn.imageView.frame.size.width > 0) {
                labW = btn.imageView.frame.size.width + 5;
            }
            //消息数量
            NSInteger labWitdh = message >= 100 ? 25 : message >= 10 ? 20 : 15;
            CGRect labRect = CGRectMake((tabWidth + labW) / 2 - 5, 3, labWitdh, 15);
            if ([_ktabType isEqualToString:@"slidingTop"]) {
                labRect.origin.x -= 5;
                labRect.origin.y += 5;
            }
            UILabel *msgLab = [[UILabel alloc] initWithFrame:labRect];
            msgLab.backgroundColor = [UIColor redColor];
            msgLab.font = [UIFont systemFontOfSize:10.f];
            msgLab.textAlignment = NSTextAlignmentCenter;
            msgLab.textColor = [UIColor whiteColor];
            msgLab.adjustsFontSizeToFitWidth = YES;
            msgLab.text = message > 99 ? @"99+" : [NSString stringWithFormat:@"%ld", (long)message];
            msgLab.layer.cornerRadius = 7.5f;
            msgLab.layer.masksToBounds = YES;
            msgLab.tag = TabItemMessageTag + i;
            msgLab.hidden = message == 0 ? YES : NO;
            [btn addSubview:msgLab];

            //未读红点
            CGRect dotRect = CGRectMake((tabWidth + labW) / 2 - 5, 3, 6, 6);
            if ([_ktabType isEqualToString:@"slidingTop"]) {
                dotRect.origin.x -= 5;
                dotRect.origin.y += 5;
            }
            UIView *dotView = [[UIView alloc] initWithFrame:dotRect];
            dotView.backgroundColor = [UIColor redColor];
            dotView.layer.cornerRadius = 3;
            dotView.layer.masksToBounds = YES;
            dotView.tag = TabItemDotTag + i;
            dotView.hidden = !dot;
            [btn addSubview:dotView];
        }

        allWidth += _tabPadding;
        [_tabView setContentSize:CGSizeMake(allWidth, 0)];
    }

    if (_calculatedHeight != self.calculatedFrame.size.height) {
        _calculatedHeight = self.calculatedFrame.size.height;
        for (int i = 0; i < _tabNameList.count; i++) {
            UIScrollView *scoView = (UIScrollView*)[self.bodyView viewWithTag:TabBgScrollTag + i];
            scoView.frame = CGRectMake(i * self.bodyView.frame.size.width, 0, self.bodyView.frame.size.width, self.bodyView.frame.size.height);
        }
    }
}

- (BOOL)isFontIcon:(NSString*)var
{
    if (var == nil) {
        return NO;
    }
    NSString *val = [var lowercaseString];
    if ([val containsString:@"//"] || [val hasPrefix:@"data:"] || [val hasSuffix:@".png"] || [val hasSuffix:@".jpg"] || [val hasSuffix:@".jpeg"] || [val hasSuffix:@".gif"]) {
        return NO;
    }else{
        return YES;
    }
}

- (void)initIndicatorView
{
    if (self.indicatorView != nil) {
        [self.indicatorView removeFromSuperview];
    }
    if (self->_indicatorStyle == 0) {
        self.indicatorView =  [[UIView alloc] init];
        [self.tabView addSubview:self.indicatorView];
        [self loadIndicatorView];
    } else if (self->_indicatorStyle == 1) {
        self.indicatorView =  [[TriangleIndicatorView alloc] init];
        [self.tabView addSubview:self.indicatorView];
        [self loadIndicatorView];
    }
}

- (void)loadIndicatorView
{
    UIButton *btn = (UIButton*)[self.tabView viewWithTag:TabItemBtnTag + _selectedIndex];

    self.indicatorView.frame = CGRectMake( btn.frame.origin.x + (btn.frame.size.width - _indicatorWidth)/2, _ktabHeight - _indicatorHeight, _indicatorWidth, _indicatorHeight);

    self.indicatorView.layer.cornerRadius = _indicatorCornerRadius;
    self.indicatorView.layer.masksToBounds = YES;

    if (_indicatorStyle == 1) {
        [(TriangleIndicatorView*)_indicatorView loadColor:[WXConvert UIColor:_indicatorColor]];
        _indicatorView.backgroundColor = [UIColor clearColor];
    } else {
        self.indicatorView.backgroundColor = [WXConvert UIColor:_indicatorColor];
    }
}

- (void)reloadIndicator
{
    NSDictionary *data = @{@"position":@(_selectedIndex)};
    [self fireEvent:@"pageSelected" params:data];
    [self fireEvent:@"pageScrollStateChanged" params:@{@"state":@""}];

    for (int i = 0; i < self.tabPages.count + self.subComps.count; i++) {
        UIButton *btn = [_tabView viewWithTag:TabItemBtnTag + i];
        if (i == _selectedIndex) {
            btn.selected = YES;
            if (_indicatorStyle == 2) {
                btn.backgroundColor = [WXConvert UIColor:_indicatorColor];
            } else {
                [self moveIndicatorView];
            }

            //item跟随page滚动
            if (_tabView.contentOffset.x + _tabView.frame.size.width < btn.frame.origin.x + btn.frame.size.width) {
                [_tabView setContentOffset:CGPointMake(btn.frame.origin.x + btn.frame.size.width - _tabView.frame.size.width, 0) animated:YES];
            } else if (_tabView.contentOffset.x > btn.frame.origin.x) {
                [_tabView setContentOffset:CGPointMake(btn.frame.origin.x, 0) animated:YES];
            }
        } else {
            btn.selected = NO;
            if (_indicatorStyle == 2) {
                btn.backgroundColor = [UIColor clearColor];
            }
        }

        if (_textBold == 1 && i == _selectedIndex) {
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:_textSize];
        } else {
            btn.titleLabel.font = [UIFont systemFontOfSize:_textSize];
        }
    }
}

- (void)moveIndicatorView
{
    //移动tab显示器
    UIButton *btn = (UIButton*)[self.tabView viewWithTag:TabItemBtnTag + _selectedIndex];

    CGRect frame = _indicatorView.frame;
    CGRect oldFrame = _indicatorView.frame;
    frame.origin.x = btn.frame.origin.x + (btn.frame.size.width - _indicatorWidth)/2;

    if (_indicatorAnimEnable) {
        __weak typeof(self) ws = self;
        if (_indicatorBounceEnable) {
            //回弹效果
            [UIView animateWithDuration:_indicatorAnimDuration*1.0/1000 animations:^{
                CGRect nFrame = oldFrame;
                if (oldFrame.origin.x > frame.origin.x) {
                    nFrame.origin.x = frame.origin.x - 5;//左回弹
                } else {
                    nFrame.origin.x = frame.origin.x + 5;//右回弹
                }
                ws.indicatorView.frame = nFrame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    ws.indicatorView.frame = frame;
                }];
            }];
        } else {
            [UIView animateWithDuration:_indicatorAnimDuration*1.0/1000 animations:^{
                ws.indicatorView.frame = frame;
            }];
        }
    } else {
        _indicatorView.frame = frame;
    }
}

- (void)loadUnderLineView
{
    CGFloat y = 0;
    CGFloat lineHeight = _underlineHeight ? _underlineHeight : 0;
    if (_underlineGravity == 0) {
        //下方
        y = self.tabView.frame.origin.y + _ktabHeight - lineHeight;
    } else {
        y = self.tabView.frame.origin.y;
    }

    self.underLineView.frame = CGRectMake(0, y, _tabView.frame.size.width, lineHeight);
    self.underLineView.backgroundColor = [WXConvert UIColor:_underlineColor];
}

- (void)loadTabPagesView:(NSInteger) index
{
    if (index < _tabPages.count) {
        NSDictionary *dic = self.tabPages[index];
        NSString *tabName = dic[@"tabName"] ? [WXConvert NSString:dic[@"tabName"]] : [NSString stringWithFormat:@"TabPage-%d", (arc4random() % 100) + 1000];
        NSString *title = dic[@"title"] ? [WXConvert NSString:dic[@"title"]] : @"New Page";
        NSString *url = dic[@"url"] ? [WXConvert NSString:dic[@"url"]] : @"";
        NSInteger cache = dic[@"cache"] ? [WXConvert NSInteger:dic[@"cache"]] : 0;
        BOOL loading = dic[@"loading"] ? [WXConvert BOOL:dic[@"loading"]] : YES;
        NSString *statusBarColor = dic[@"statusBarColor"];
        id params = dic[@"params"];

        //添加滚动视图
        UIScrollView *scoView = [[UIScrollView alloc] initWithFrame:CGRectMake(index * self.bodyView.frame.size.width, 0, self.bodyView.frame.size.width, self.bodyView.frame.size.height)];
        scoView.tag = TabBgScrollTag + index;
        [self.bodyView addSubview:scoView];

        if (@available(iOS 11.0, *)) {
            scoView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        NSString *tempName = [NSString stringWithFormat: @"%@:%d", tabName, arc4random() % 100000];

        eeuiViewController *vc = [[eeuiViewController alloc] init];
        vc.url = [DeviceUtil rewriteUrl:[DeviceUtil suffixUrl:@"app" url:url] mInstance:_tabInstance];
        vc.cache = cache;
        vc.params = params;
        vc.loading = loading;
        vc.isChildSubview = YES;
        vc.parentFrameCGRect = scoView.frame;
        vc.pageName = tabName;
        vc.title = title;

#if DEBUG
        vc.statusBlock = ^(NSString *status) {
            if ([status isEqualToString:@"destroy"]) {
                [eeuiNewPageManager removeTabViewDebug:tempName];
            }
        };
        __weak __typeof(vc)weakVC = vc;
        [eeuiNewPageManager setTabViewDebug:tempName callback:^(id result, BOOL keepAlive) {
            NSString *resUrl = [WXConvert NSString:result];
            if ([[DeviceUtil realUrl:[weakVC url]] hasPrefix:resUrl]) {
                [weakVC refreshPage];
            }
        }];
#endif

        [_tabInstance.viewController addChildViewController:vc];
        [scoView addSubview:vc.view];

        CGRect frame;
        UIEdgeInsets safeArea = UIEdgeInsetsZero;

        if (@available(iOS 11.0, *)) {
            safeArea = self.view.safeAreaInsets;
        }
        safeArea.top = iPhoneXSeries ? 44 : 20;

        if (statusBarColor) {
            frame = CGRectMake(0, safeArea.top, scoView.frame.size.width, scoView.frame.size.height - safeArea.top - safeArea.bottom);

            UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scoView.frame.size.width, safeArea.top)];
            statusView.backgroundColor = [WXConvert UIColor:statusBarColor];
            [scoView addSubview:statusView];
        } else {
            frame = CGRectMake(0, 0, scoView.frame.size.width, scoView.frame.size.height - safeArea.bottom);
        }
        vc.view.frame = frame;

        //标记已加载过该视图
        [_childPageList addObject:dic];

        vc.isTabbarChildSelected = index == _selectedIndex ? YES: NO;
        vc.isTabbarChildView = YES;
        [_lifeTabPages setObject:vc forKey:[NSString stringWithFormat:@"%ld", (long)index]];
    }
}

- (void)loadComponentView:(NSInteger) index
{
    if (index - _tabPages.count < _subComps.count) {
        //添加滚动视图
        UIScrollView *scoView = [[UIScrollView alloc] initWithFrame:CGRectMake(index * self.bodyView.frame.size.width, 0, self.bodyView.frame.size.width, self.bodyView.frame.size.height)];
        scoView.tag = TabBgScrollTag + index;
        [self.bodyView addSubview:scoView];

        eeuiTabbarPageComponent *com = self.subComps[index - _tabPages.count];
        UIView *view = com.view;
        CGRect frame = view.frame;
        frame.origin = CGPointMake(0, 0);
        //        frame.size = scoView.frame.size;
        view.frame = frame;
        [scoView addSubview:view];

        scoView.contentSize = CGSizeMake(0, com.calculatedFrame.size.height);

        //下拉刷新
        if (com.isRefreshListener) {
            scoView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [com setRefreshListener:scoView.mj_header];
            }];
        }

        //标记已加载该组件
        [_childComponentList addObject:com];
    }
}

- (void)loadComponentID:(id) index
{
    [self loadComponentView:[WXConvert NSInteger:index]];
}

//处理滚动或点击到当前页面再加载
- (void)loadSelectedView
{
    //判断数据源,优先子组件
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:5];

    if (_tabPages.count > 0) {
        [dataList addObjectsFromArray:_tabPages];
    }

    if (_subComps.count > 0) {
        [dataList addObjectsFromArray:_subComps];
    }

    if (dataList.count > 0 && _selectedIndex < dataList.count) {
        id data = dataList[_selectedIndex];
        if ([data isKindOfClass:[eeuiTabbarPageComponent class]]) {
            if (![_childComponentList containsObject:data]) {
                [self loadComponentView:_selectedIndex];
            }
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            if (![_childPageList containsObject:data]) {
                [self loadTabPagesView:_selectedIndex];
            }
        }
    }
}

//处理生命周期，只处理tabPages
- (void)lifeCycleEvent
{
    //重现
    if (_selectedIndex < _tabPages.count) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)_selectedIndex];
        eeuiViewController *vc = _lifeTabPages[key];
        if (vc) {
            vc.isTabbarChildSelected = YES;
            [vc lifeCycleEvent:LifeCycleResume];
        }
    }

    //消失
    if (_lastSelectedIndex < _tabPages.count) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)_lastSelectedIndex];
        eeuiViewController *vc = _lifeTabPages[key];
        if (vc) {
            vc.isTabbarChildSelected = NO;
            [vc lifeCycleEvent:LifeCyclePause];
        }
    }
}

#pragma mark action
- (void)tabbarClick:(UIButton*)sender
{
    if (_selectedIndex == sender.tag - TabItemBtnTag) {
        [self fireEvent:@"tabReselect" params:@{@"position":@(_selectedIndex)}];
        return;
    }

    _lastSelectedIndex = _selectedIndex;
    _selectedIndex = sender.tag - TabItemBtnTag;

    [self fireEvent:@"tabSelect" params:@{@"position":@(_selectedIndex)}];

    [self reloadIndicator];

    [self lifeCycleEvent];
    [self loadSelectedView];

    [self.bodyView setContentOffset:CGPointMake(_selectedIndex * self.bodyView.frame.size.width, 0) animated:_tabPageAnimated];
}

#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _bodyView || scrollView == _tabView) {
        NSDictionary *data = @{@"position":@(_selectedIndex), @"positionOffset":@"", @"positionOffsetPixels":@""};
        [self fireEvent:@"pageScrolled" params:data];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.bodyView) {
        if (_selectedIndex != scrollView.contentOffset.x / scrollView.frame.size.width) {
            _lastSelectedIndex = _selectedIndex;
            _selectedIndex = scrollView.contentOffset.x / scrollView.frame.size.width;

            [self reloadIndicator];

            [self lifeCycleEvent];
            [self loadSelectedView];
        }
    }
}

#pragma mark methods
- (NSInteger)getTabPosition:(NSString*)name
{
    NSInteger index = 0;
    for (int i = 0; i < _subComps.count + _tabPages.count; i++) {
        UIButton *btn = (UIButton*)[self.tabView viewWithTag:TabItemBtnTag + i];
        if ([btn.titleLabel.text isEqualToString:name]) {
            index = i;
            break;
        }
    }
    return index;
}
- (NSString*)getTabName:(NSInteger)index
{
    if (index < self.tabNameList.count) {
        NSDictionary *dic = self.tabNameList[index];
        if (dic) {
            return dic[@"tabName"];
        }
    }
    return @"";
}
- (void)showMsg:(NSString*)tabName num:(NSInteger)num
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                NSInteger labWitdh = num >= 100 ? 25 : num >= 10 ? 20 : 15;
                UILabel *msgLab = (UILabel*)[_tabView viewWithTag:TabItemMessageTag + i];
                msgLab.frame = CGRectMake(msgLab.frame.origin.x, msgLab.frame.origin.y, labWitdh, msgLab.frame.size.height);
                msgLab.text = num > 99 ? @"99+" : [NSString stringWithFormat:@"%ld", (long)num];
                msgLab.hidden = NO;
                break;
            }
        }
    }
}
- (void)showDot:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UIView *view = [_tabView viewWithTag:TabItemDotTag + i];
                view.hidden = NO;
                break;
            }
        }
    }
}

- (void)hideMsg:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UIView *view = [_tabView viewWithTag:TabItemDotTag + i];
                UILabel *msgLab = (UILabel*)[_tabView viewWithTag:TabItemMessageTag + i];

                view.hidden = YES;
                msgLab.hidden = YES;
                break;
            }
        }
    }
}

- (void)removePageAt:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                if (i < _tabPages.count) {
                    [_tabPages removeObjectAtIndex:i];
                    [self loadTabPagesView:i];
                } else if (i < _tabPages.count + _subComps.count ){
                    [_subComps removeObjectAtIndex:i - _tabPages.count];
                    [self loadComponentView:i];
                }
                [self loadTabView];
                break;
            }
        }
    }
}

- (void)setCurrentItem:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                if (_selectedIndex != i) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = i;
                    [self.bodyView setContentOffset:CGPointMake(_selectedIndex * self.bodyView.frame.size.width, 0) animated:_tabPageAnimated];
                    [self reloadIndicator];
                    [self lifeCycleEvent];
                    [self loadSelectedView];
                }
                break;
            }
        }
    }
}

- (void)goUrl:(NSString*)tabName url:(NSString*)url
{
    for (id key in _lifeTabPages) {
        eeuiViewController *vc = [_lifeTabPages objectForKey:key];
        if (vc && [vc.pageName isEqualToString:tabName]) {
            [vc setHomeUrl:[DeviceUtil rewriteUrl:[DeviceUtil suffixUrl:@"app" url:url] mInstance:_tabInstance] refresh:NO];
            [vc refreshPage];
        }
    }
    for (NSUInteger i = 0; i < _tabPages.count; i++) {
        NSMutableDictionary *data = ((NSDictionary *) _tabPages[i]).mutableCopy;
        if (data != nil && [data[@"tabName"] isEqualToString:tabName]) {
            data[@"url"] = url;
            _tabPages[i] = data;
        }
    }
}

- (void)reload:(NSString*)tabName
{
    for (id key in _lifeTabPages) {
        eeuiViewController *vc = [_lifeTabPages objectForKey:key];
        if (vc && [vc.pageName isEqualToString:tabName]) {
            [vc refreshPage];
        }
    }
}

- (void)setTabType:(NSString*)tabType
{
    _ktabType = tabType;
    [self loadTabView];
}

- (void)setTabHeight:(NSInteger)tabHeight
{
    _ktabHeight = SCALEFLOAT(tabHeight);
    [self loadTabView];
}

- (void)setTabBackgroundColor:(NSString*)tabBackgroundColor
{
    _ktabBackgroundColor = tabBackgroundColor;
    [self loadTabView];
}

- (void)setTabTextsize:(NSInteger)size
{
    _textSize = FONT(size);
    [self loadTabView];
}

- (void)setTabTextBold:(NSInteger)textBold
{
    _textBold = textBold;
    [self loadTabView];
}

- (void)setTabTextUnselectColor:(NSString*)textUnselectColor
{
    _textUnselectColor = textUnselectColor;
    [self loadTabView];
}

- (void)setTabTextSelectColor:(NSString*)textSelectColor
{
    _textSelectColor = textSelectColor;
    [self loadTabView];
}

- (void)setTabIconVisible:(BOOL)iconVisible
{
    _iconVisible = iconVisible;
    [self loadTabView];
}

- (void)setTabIconWidth:(NSInteger)iconWidth
{
    _iconWidth = SCALEFLOAT(iconWidth);
    [self loadTabView];
}
- (void)setTabIconHeight:(NSInteger)iconHeight
{
    _iconHeight = SCALEFLOAT(iconHeight);
    [self loadTabView];
}
- (void)setSideline:(NSInteger)sideLine
{
    _ksideLine = sideLine;
    [self loadTabView];
}
- (void)setTabPageAnimated:(BOOL)isAnimated
{
    _tabPageAnimated = isAnimated;
}
- (void)setTabSlideSwitch:(BOOL)slideSwitch
{
    _tabSlideSwitch = slideSwitch;
    if (_bodyView != nil) {
        _bodyView.scrollEnabled = slideSwitch;
    }
}
@end
