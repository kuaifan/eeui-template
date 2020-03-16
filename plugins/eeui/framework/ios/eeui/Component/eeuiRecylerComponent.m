

#import "eeuiRecylerComponent.h"
#import "MJRefresh.h"
#import "DeviceUtil.h"
#import "WXComponent_internal.h"
#import "WXSDKInstance_private.h"
#import "WXMultiColumnLayout.h"
#import "WXAssert.h"
#import "WXConvert.h"
#import "WXUtility.h"
#import "WXMonitor.h"
#import "NSObject+WXSwizzle.h"
#import "WXComponent+Events.h"
#import "eeuiScrollHeaderComponent.h"

#define kCellTag 1000

static NSString * const cellID = @"cellID";

@interface eeuiRecylerComponent() <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *pullTipsDefault;
@property (nonatomic, strong) NSString *pullTipsLoad;
@property (nonatomic, strong) NSString *pullTipsNo;
@property (nonatomic, strong) NSString *pullTipsIdle;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) BOOL refreshAuto;
@property (nonatomic, assign) BOOL pullTips;
@property (nonatomic, assign) BOOL itemDefaultAnimator;
@property (nonatomic, assign) BOOL scrollBarEnabled;
@property (nonatomic, assign) BOOL scrollEnabled;

@property (nonatomic, strong) NSMutableArray *subViews;
@property (nonatomic, strong) WXSDKInstance *tableInstance;

@property (nonatomic, assign) NSInteger lastVisibleItem;//最后显示的数据是第几条

@property (nonatomic, assign) BOOL isRefreshListener;
@property (nonatomic, assign) BOOL isPullLoadListener;

@property (nonatomic, assign) BOOL isTapGestureRecognizer;
@property (nonatomic, assign) BOOL isLongPressGestureRecognizer;

@property (nonatomic, assign) CGFloat scrolledY;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation eeuiRecylerComponent

WX_EXPORT_METHOD(@selector(setRefreshing:))
WX_EXPORT_METHOD(@selector(refreshed))
WX_EXPORT_METHOD(@selector(refreshEnabled:))
WX_EXPORT_METHOD(@selector(setHasMore:))
WX_EXPORT_METHOD(@selector(pullloaded))
WX_EXPORT_METHOD(@selector(itemDefaultAnimator:))
WX_EXPORT_METHOD(@selector(scrollBarEnabled:))
WX_EXPORT_METHOD(@selector(scrollToPosition:))
WX_EXPORT_METHOD(@selector(smoothScrollToPosition:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {

        _pullTipsDefault =  @"正在加载数据...";
        _pullTipsLoad = @"正在加载更多...";
        _pullTipsNo = @"没有更多数据了";
        _pullTipsIdle = @"点击或上拉加载更多";
        _refreshAuto = NO;
        _pullTips = YES;
        _itemDefaultAnimator = NO;
        _scrollBarEnabled = NO;
        _scrollEnabled = YES;
        _row = 1;

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        self.subViews = [NSMutableArray arrayWithCapacity:5];
        self.lastVisibleItem = 0;
        self.scrolledY = 0;

        _isRefreshListener = [events containsObject:@"refreshListener"];
        _isPullLoadListener = [events containsObject:@"pullLoadListener"];

    }

    return self;
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (UIView*)loadView
{
    return [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionView = (UICollectionView*)self.view;
    _collectionView.delegate = self;
    _collectionView.clipsToBounds = YES;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    //collectionView.bounces = NO;
    _collectionView.scrollEnabled = _scrollEnabled;
    _collectionView.showsVerticalScrollIndicator = _scrollBarEnabled;

    #ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    #endif

    __weak typeof(self) ws = self;
    if (_isRefreshListener) {
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSDictionary *data = @{@"realLastPosition":@(ws.subViews.count), @"lastVisibleItem":@(ws.lastVisibleItem)};
            [ws fireEvent:@"refreshListener" params:data];
        }];
        if (_refreshAuto) {
            [_collectionView.mj_header beginRefreshing];
        }
    }

    if (_isPullLoadListener) {
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            NSDictionary *data = @{@"realLastPosition":@(ws.subViews.count), @"lastVisibleItem":@(ws.lastVisibleItem)};
            [ws fireEvent:@"pullLoadListener" params:data];
        }];
        [footer setTitle:_pullTipsDefault forState:MJRefreshStatePulling];
        [footer setTitle:_pullTipsLoad forState:MJRefreshStateRefreshing];
        [footer setTitle:_pullTipsNo forState:MJRefreshStateNoMoreData];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        _collectionView.mj_footer = footer;
        _collectionView.mj_footer.hidden = !_pullTips;
    }

    [self fireEvent:@"ready" params:nil];
}

- (void)viewWillUnload
{
    [super viewWillUnload];

    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
    [super updateStyles:styles];
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
    [super updateAttributes:attributes];
}

- (void)addEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"itemClick"]) {
        _isTapGestureRecognizer = YES;
    } else if ([eventName isEqualToString:@"itemLongClick"]) {
        _isLongPressGestureRecognizer = YES;
    }
    [super addEvent:eventName];
}

- (void)removeEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"itemClick"]) {
        _isTapGestureRecognizer = NO;
    } else if ([eventName isEqualToString:@"itemLongClick"]) {
        _isLongPressGestureRecognizer = NO;
    }
    [super removeEvent:eventName];
}

- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        if (!isUpdate) {
            for (NSString *k in [value allKeys]) {
                [self dataKey:k value:value[k] isUpdate:isUpdate];
            }
        }
    } else if ([key isEqualToString:@"pullTipsDefault"]) {
        _pullTipsDefault = [WXConvert NSString:value];
        if (isUpdate) {
            MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)_collectionView.mj_footer;
            [footer setTitle:_pullTipsDefault forState:MJRefreshStatePulling];
        }
    } else if ([key isEqualToString:@"pullTipsLoad"]) {
        _pullTipsLoad = [WXConvert NSString:value];
        if (isUpdate) {
            MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)_collectionView.mj_footer;
            [footer setTitle:_pullTipsLoad forState:MJRefreshStateRefreshing];
        }
    } else if ([key isEqualToString:@"pullTipsNo"]) {
        _pullTipsNo = [WXConvert NSString:value];
        if (isUpdate) {
            MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)_collectionView.mj_footer;
            [footer setTitle:_pullTipsNo forState:MJRefreshStateNoMoreData];
        }
    } else if ([key isEqualToString:@"refreshAuto"]) {
        _refreshAuto = [WXConvert BOOL:value];
        if (isUpdate) {
            if (_refreshAuto) {
                [_collectionView.mj_header beginRefreshing];
            } else {
                [_collectionView.mj_header endRefreshing];
            }
        }
    }  else if ([key isEqualToString:@"itemDefaultAnimator"]) {
        _itemDefaultAnimator = [WXConvert BOOL:value];
        if (isUpdate) {
            [self itemDefaultAnimator:_itemDefaultAnimator];
        }
    }  else if ([key isEqualToString:@"scrollBarEnabled"]) {
        _scrollBarEnabled = [WXConvert BOOL:value];
        if (isUpdate) {
            [self scrollBarEnabled:_scrollBarEnabled];
        }
    } else if ([key isEqualToString:@"pullTips"]) {
        _pullTips = [WXConvert BOOL:value];
        if (isUpdate) {
            _collectionView.mj_footer.hidden = !_pullTips;
        }
    } else if ([key isEqualToString:@"scrollEnabled"]) {
        _scrollEnabled = [WXConvert BOOL:value];
        if (isUpdate) {
            _collectionView.scrollEnabled = _scrollEnabled;
        }
    } else if ([key isEqualToString:@"row"]) {
        _row = [WXConvert NSInteger:value];
        if (isUpdate) {
            [_collectionView reloadData];
        }
    }
}

- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    if (![_subViews containsObject:subcomponent]) {
        if (_subViews.count == 0) {
            [_subViews addObject:subcomponent];
        } else {
            [_subViews insertObject:subcomponent atIndex:index];
        }
    }

    subcomponent.view.tag = kCellTag + index;
    
    if ([subcomponent isKindOfClass:[eeuiScrollHeaderComponent class]]) {
        if (_headerView == nil) {
            [_view.superview addSubview:_headerView = [[UIView alloc] init]];
        }else{
            [_view bringSubviewToFront:_headerView];
        }
    }

    //添加手势
    UITapGestureRecognizer *tapRecognizer = nil;
    UILongPressGestureRecognizer * longRecognizer = nil;

    //点击
    if (_isTapGestureRecognizer) {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemPanClick:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [subcomponent.view addGestureRecognizer:tapRecognizer];
    }

    //长按
    if (_isLongPressGestureRecognizer) {
        longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongClick:)];
        longRecognizer.minimumPressDuration = 1.0;
        [subcomponent.view addGestureRecognizer:longRecognizer];
    }

    // 如果长按确定偵測失败才會触发单击
    if (_isTapGestureRecognizer && _isLongPressGestureRecognizer) {
        [tapRecognizer requireGestureRecognizerToFail:longRecognizer];
    }

    [super insertSubview:subcomponent atIndex:index];
}

- (void)willRemoveSubview:(WXComponent *)component;
{
    if ([_subViews containsObject:component]) {
        [_subViews removeObject:component];
    }
    [super willRemoveSubview:component];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_headerView != nil) {
        //添加到header
        for (WXView *view in scrollView.subviews) {
            if ([[view wx_component] isKindOfClass:[eeuiScrollHeaderComponent class]]) {
                if (scrollView.contentOffset.y >= view.frame.origin.y) {
                    eeuiScrollHeaderComponent *tempComponent = (eeuiScrollHeaderComponent *)[view wx_component];
                    tempComponent.bx = view.frame.origin.x;
                    tempComponent.by = view.frame.origin.y;
                    [view setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
                    [view removeFromSuperview];
                    [_headerView addSubview:view];
                    [_headerView setFrame:CGRectMake(_view.frame.origin.x, _view.frame.origin.y, _view.frame.size.width, view.frame.size.height)];
                    [tempComponent stateCallback:@"float"];
                }
            }
        }
        //从header删除
        for (WXView *view in _headerView.subviews) {
            if ([[view wx_component] isKindOfClass:[eeuiScrollHeaderComponent class]]) {
                eeuiScrollHeaderComponent *tempComponent = (eeuiScrollHeaderComponent *)[view wx_component];
                if (scrollView.contentOffset.y < tempComponent.by) {
                    [view setFrame:CGRectMake(tempComponent.bx, tempComponent.by, view.frame.size.width, view.frame.size.height)];
                    [view removeFromSuperview];
                    [scrollView addSubview:view];
                    [tempComponent stateCallback:@"static"];
                }
            }
        }
        //更新header状态
        NSInteger count = [_headerView.subviews count];
        NSInteger index = 0;
        for (WXView *view in _headerView.subviews) {
            if (index >= count - 1) {
                [(eeuiScrollHeaderComponent *)[view wx_component] stateCallback:@"float"];
            }else{
                [(eeuiScrollHeaderComponent *)[view wx_component] stateCallback:@"static"];
            }
            index++;
        }
    }
    NSDictionary *res = @{@"x":@(0), @"y":@(scrollView.contentOffset.y*ScreeScale), @"dx":@(0), @"dy":@((scrollView.contentOffset.y - _scrolledY)*ScreeScale)};
    [self fireEvent:@"scrolled" params:res];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [super scrollViewDidEndScrollingAnimation:scrollView];

    _scrolledY = scrollView.contentOffset.y;

    [self fireEvent:@"scrollStateChanged" params:@{@"x":@(0), @"y":@(scrollView.contentOffset.y*ScreeScale), @"newState":@(1)}];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _scrolledY = scrollView.contentOffset.y;

    [self fireEvent:@"scrollStateChanged" params:@{@"x":@(0), @"y":@(scrollView.contentOffset.y*ScreeScale), @"newState":@(1)}];
}

- (void)itemPanClick:(UITapGestureRecognizer*)panRecognizer
{
    NSInteger index = panRecognizer.view.tag - kCellTag;
    [self fireEvent:@"itemClick" params:@{@"position":@(index)}];
}

- (void)itemLongClick:(UILongPressGestureRecognizer*)longRecognizer
{
    NSInteger index = longRecognizer.view.tag - kCellTag;
    [self fireEvent:@"itemLongClick" params:@{@"position":@(index)}];
}

- (void)setRefreshing:(id)refreshing
{
    if ([WXConvert BOOL:refreshing]) {
        [_collectionView.mj_header beginRefreshing];
    } else {
        [_collectionView.mj_header endRefreshing];
    }
}

- (void)refreshed
{
    [_collectionView.mj_header endRefreshing];
}

- (void)refreshEnabled:(id)isEnabled
{
    if ([WXConvert BOOL:isEnabled]) {
        _collectionView.mj_header.hidden = NO;
    } else {
        _collectionView.mj_header.hidden = YES;
    }
}

- (void)setHasMore:(id)hasMore
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.collectionView.mj_footer endRefreshing];
        weakSelf.collectionView.mj_footer.hidden = ![WXConvert BOOL:hasMore];
        MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)weakSelf.collectionView.mj_footer;
        [footer setTitle:hasMore ? weakSelf.pullTipsIdle : @"" forState:MJRefreshStateIdle];
    });
}

- (void)pullloaded
{
    [_collectionView.mj_footer endRefreshing];
}

// eeui ios 无
- (void)itemDefaultAnimator:(bool)animator
{
    _itemDefaultAnimator = animator;
}

- (void)scrollBarEnabled:(bool)enabled
{
    _scrollBarEnabled = enabled;
    _collectionView.showsVerticalScrollIndicator = _scrollBarEnabled;
}

- (void)scrollToPosition:(NSInteger)position
{
    [self performSelector:@selector(scrollCollectionView:) withObject:@{@"position":@(position), @"animated":@(NO)} afterDelay:0.1];
}

- (void)smoothScrollToPosition:(NSInteger)position
{
    [self performSelector:@selector(scrollCollectionView:) withObject:@{@"position":@(position), @"animated":@(YES)} afterDelay:0.1];
}

- (void)scrollCollectionView:(NSDictionary*)dic
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollCollectionView:) object:nil];

    if (dic) {
        NSInteger position = [WXConvert NSInteger:dic[@"position"]];
        BOOL animated = [WXConvert BOOL:dic[@"animated"]];

        WXComponent *toComponent;
        switch (position) {
            case -1:
                toComponent = [_subViews lastObject];
                break;
           case 0:
                toComponent = [_subViews firstObject];
                break;
            default:
                if (position < _subViews.count) {
                    toComponent = [_subViews objectAtIndex:position];
                }else{
                    toComponent = [_subViews lastObject];
                }
                break;
        }

        id<WXScrollerProtocol> scrollerComponent = toComponent.ancestorScroller;
        if (!scrollerComponent) {
            return;
        }
        
        @try{
            if ([toComponent isKindOfClass:[eeuiScrollHeaderComponent class]]) {
                eeuiScrollHeaderComponent *tempComponent = (eeuiScrollHeaderComponent *)toComponent;
                if (tempComponent.bx != -1 && tempComponent.by != -1) {
                    [_collectionView setContentOffset:CGPointMake(tempComponent.bx, tempComponent.by) animated:animated];
                    return;
                }
            }
            [scrollerComponent scrollToComponent:toComponent withOffset:0 animated:animated];

            _scrolledY = scrollerComponent.contentOffset.y;
        }@catch (NSException *exception) {
            EELog(@"NSException = %@", exception);
        }
    }
}

@end
