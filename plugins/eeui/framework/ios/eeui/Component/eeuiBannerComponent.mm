//
//  eeuiBannerComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiBannerComponent.h"
#import "eeuiIndicatorComponent.h"
#import "WXUtility.h"
#import "NSTimer+eeui.h"
#import "DeviceUtil.h"

#define IndicatorTag 100

typedef NS_ENUM(NSInteger, Direction) {
    DirectionNone = 1 << 0,
    DirectionLeft = 1 << 1,
    DirectionRight = 1 << 2
};

@class eeuiRecycleSliderView;
@class eeuiIndicatorView;

@protocol eeuiRecycleSliderViewDelegate <UIScrollViewDelegate>

- (void)recycleSliderView:(eeuiRecycleSliderView *)recycleSliderView didScroll:(UIScrollView *)scrollView;
- (void)recycleSliderView:(eeuiRecycleSliderView *)recycleSliderView didScrollToItemAtIndex:(NSInteger)index;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end


@interface eeuiRecycleSliderView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) eeuiIndicatorView *indicator;
@property (nonatomic, weak) id<eeuiRecycleSliderViewDelegate> delegate;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, assign) Direction direction;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger nextIndex;
@property (nonatomic, assign) CGRect currentItemFrame;
@property (nonatomic, assign) CGRect nextItemFrame;
@property (nonatomic, assign) BOOL infinite;

@property (nonatomic, strong) UIView *eeuiIndicator;//指示器
@property (nonatomic, assign) NSInteger autoPlayDuration;
@property (nonatomic, assign) NSInteger scrollDuration;
@property (nonatomic, assign) BOOL indicatorShow;
@property (nonatomic, assign) NSInteger indicatorShape;
@property (nonatomic, assign) NSInteger indicatorPosition;
@property (nonatomic, assign) NSInteger indicatorMargin;
@property (nonatomic, assign) NSInteger indicatorSpace;
@property (nonatomic, strong) NSString *selectedIndicatorColor;
@property (nonatomic, strong) NSString *unSelectedIndicatorColor;
@property (nonatomic, assign) NSInteger indicatorWidth;
@property (nonatomic, assign) NSInteger indicatorHeight;

- (void)insertItemView:(UIView *)view atIndex:(NSInteger)index;
- (void)removeItemView:(UIView *)view;

@end


@implementation eeuiRecycleSliderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndex = 0;
        _itemViews = [[NSMutableArray alloc] init];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        [self addSubview:_scrollView];

        _eeuiIndicator = [[UIView alloc] init];
        [self addSubview:_eeuiIndicator];
    }
    return self;
}

- (void)dealloc
{
    if (_scrollView) {
        _scrollView.delegate = nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resetAllViewsFrame];
}

- (void)accessibilityDecrement
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.wx_component performSelector:NSSelectorFromString(@"resumeAutoPlay:") withObject:@(false)];
#pragma clang diagnostic pop

    [self nextPage];
}

- (void)accessibilityIncrement
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.wx_component performSelector:NSSelectorFromString(@"resumeAutoPlay:") withObject:@(false)];
#pragma clang diagnostic pop

    [self lastPage];
}

- (void)accessibilityElementDidLoseFocus
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.wx_component performSelector:NSSelectorFromString(@"resumeAutoPlay:") withObject:@(true)];
#pragma clang diagnostic pop
}

#pragma mark Private Methods
- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (UIView *)getItemAtIndex:(NSInteger)index
{
    if (self.itemViews.count > index) {
        return [self.itemViews objectAtIndex:index];
    }else{
        return nil;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex >= _itemViews.count || currentIndex < 0) {
        currentIndex = 0;
    }
    NSInteger oldIndex = _currentIndex;
    _currentIndex = currentIndex;
    if (_infinite) {
        if (_direction == DirectionRight) {
            self.nextItemFrame = CGRectMake(0, 0, self.width, self.height);
            self.nextIndex = self.currentIndex - 1;
            if (self.nextIndex < 0)
            {
                self.nextIndex = _itemViews.count - 1;
            }
        }else if (_direction == DirectionLeft) {
            self.nextItemFrame = CGRectMake(self.width * 2, 0, self.width, self.height);
            self.nextIndex = _itemViews.count?(self.currentIndex + 1) % _itemViews.count:0;
        }else {
            self.nextIndex = _itemViews.count?(self.currentIndex + 1) % _itemViews.count:0;
        }
        [self resetAllViewsFrame];
    } else {
//        [UIView animateWithDuration:_scrollDuration/1000.0f animations:^{
            [_scrollView setContentOffset:CGPointMake(_currentIndex * self.width, 0) animated:YES];
//        }];
    }
    [self resetIndicatorPoint];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recycleSliderView:didScrollToItemAtIndex:)]) {
        if (oldIndex != _currentIndex) {
            [self.delegate recycleSliderView:self didScrollToItemAtIndex:_currentIndex];
        }
    }
}

- (void)resetIndicatorPoint
{
    for (int i = 0; i < self.itemViews.count; i++) {
        UIButton *btn =(UIButton*)[self viewWithTag:IndicatorTag + i];
        btn.selected = _currentIndex == i ? YES : NO;
    }

    [self.indicator setPointCount:self.itemViews.count];
    [self.indicator setCurrentPoint:_currentIndex];
}

- (void)loadeeuiIndicator
{
    //指示器
    for (UIView *oldView in _eeuiIndicator.subviews) {
        [oldView removeFromSuperview];
    }

    _eeuiIndicator.hidden = !_indicatorShow;

    for (int i = 0; i < _itemViews.count; i ++) {
        UIButton *indView = [UIButton buttonWithType:UIButtonTypeCustom];
        indView.frame = CGRectMake((_indicatorSpace + _indicatorWidth) * i, 0, _indicatorWidth, _indicatorHeight);
        [indView setBackgroundImage:[self imageWithColor:[WXConvert UIColor:_unSelectedIndicatorColor]] forState:UIControlStateNormal];
        [indView setBackgroundImage:[self imageWithColor:[WXConvert UIColor:_selectedIndicatorColor]] forState:UIControlStateSelected];

        if (i == 0) {
            indView.selected = YES;
        } else {
            indView.selected = NO;
        }

        if (_indicatorShape == 1) {
            indView.layer.cornerRadius = _indicatorHeight/2;
            indView.layer.masksToBounds = YES;
        }

        indView.tag = IndicatorTag + i;
        [_eeuiIndicator addSubview:indView];
    }

    CGFloat indWidth = _itemViews.count * _indicatorWidth + _indicatorSpace * (_itemViews.count - 1);

    //设置指示器位置：0: 中下、1: 右下、2: 左下、3: 中上、4: 右上、5: 左上
    CGFloat x = 0, y = 0;
    switch (_indicatorPosition) {
        case 0:
            x = (self.frame.size.width - indWidth)/2;
            y = self.frame.size.height - _indicatorHeight - _indicatorMargin;
            break;
        case 1:
            x = self.frame.size.width - indWidth - _indicatorMargin;
            y = self.frame.size.height - _indicatorHeight - _indicatorMargin;
            break;
        case 2:
            x = _indicatorMargin;
            y = self.frame.size.height - _indicatorHeight - _indicatorMargin;
            break;
        case 3:
            x = (self.frame.size.width - indWidth)/2;
            y = _indicatorMargin;
            break;
        case 4:
            x = self.frame.size.width - indWidth - _indicatorMargin;
            y = _indicatorMargin;
            break;
        case 5:
            x = _indicatorMargin;
            y = _indicatorMargin;
            break;

        default:
            break;
    }

    _eeuiIndicator.frame = CGRectMake(x, y, indWidth, _indicatorHeight);
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


#pragma mark  Scroll & Frames
- (void)setDirection:(Direction)direction {
    if (_direction == direction) return;
    _direction = direction;
    if (_direction == DirectionNone) return;
    if (_direction == DirectionRight) {
        self.nextItemFrame = CGRectMake(0, 0, self.width, self.height);
        self.nextIndex = self.currentIndex - 1;
        if (self.nextIndex < 0)
        {
            self.nextIndex = _itemViews.count - 1;
        }
        UIView *view = [self getItemAtIndex:_nextIndex];
        if (view) {
            view.frame = _nextItemFrame;
        }
    }else if (_direction == DirectionLeft){
        self.nextItemFrame = CGRectMake(self.width * 2, 0, self.width, self.height);
        self.nextIndex = _itemViews.count?(self.currentIndex + 1) % _itemViews.count:0;
        UIView *view = [self getItemAtIndex:_nextIndex];
        if (view) {
            view.frame = _nextItemFrame;
        }
    }
}

- (void)resetAllViewsFrame
{
    if (_infinite && _itemViews.count > 1) {
        self.scrollView.frame = CGRectMake(0, 0, self.width, self.height);
        self.scrollView.contentOffset = CGPointMake(self.width, 0);
        if (self.itemViews.count > 1) {
            self.scrollView.contentSize = CGSizeMake(self.width * 3, 0);
        } else {
            self.scrollView.contentSize = CGSizeZero;
        }
        _currentItemFrame = CGRectMake(self.width, 0, self.width, self.height);
        for (int i = 0; i < self.itemViews.count; i++) {
            UIView *view = [self.itemViews objectAtIndex:i];
            if (i != self.currentIndex) {
                view.frame = CGRectMake(self.frame.size.width * 3, 0, self.width, self.height);;
            }
        }
        [self getItemAtIndex:_currentIndex].frame = _currentItemFrame;
        if (_itemViews.count == 2) {
            _nextItemFrame = CGRectMake(self.width * 2, 0, self.width, self.height);
            [self getItemAtIndex:_nextIndex].frame = _nextItemFrame;
        }
    } else {
        self.scrollView.frame = self.bounds;
        self.scrollView.contentSize = CGSizeMake(self.width * _itemViews.count, self.height);
        self.scrollView.contentOffset = CGPointMake(_currentIndex * self.width, 0);
        for (int i = 0; i < _itemViews.count; i ++) {
            UIView *view = [_itemViews objectAtIndex:i];
            view.frame = CGRectMake(i * self.width, 0, self.width, self.height);
        }
        [self.scrollView setContentOffset:CGPointMake(_currentIndex * self.width, 0) animated:NO];
    }
    [self resetIndicatorPoint];
}

- (void)nextPage {
    if (_itemViews.count > 1) {
        if (_infinite) {
//            [UIView animateWithDuration:_scrollDuration/1000.0f animations:^{
                [self.scrollView setContentOffset:CGPointMake(self.width * 2, 0) animated:YES];
//            }];
        } else {
            // the currentindex will be set at the end of animation
            NSInteger nextIndex = self.currentIndex + 1;
            if(nextIndex < _itemViews.count) {
//                [UIView animateWithDuration:_scrollDuration/1000.0f animations:^{
                    [self.scrollView setContentOffset:CGPointMake(nextIndex * self.width, 0) animated:YES];
//                }];
            }
        }
    }
}

- (void)lastPage
{

    NSInteger lastIndex = [self currentIndex]-1;
    if (_itemViews.count > 1) {
        if (_infinite) {
            if (lastIndex < 0) {
                lastIndex = [_itemViews count]-1;
            }
        }
        [self setCurrentIndex:lastIndex];
    }
}

- (void)resetScrollView
{
    if (self.scrollView.contentOffset.x / self.width == 1.0)
    {
        return;
    }
    [self setCurrentIndex:self.nextIndex];
    self.scrollView.contentOffset = CGPointMake(self.width, 0);
}

#pragma mark Public Methods

- (void)setIndicator:(eeuiIndicatorView *)indicator
{
    _indicator = indicator;
    [_indicator setPointCount:self.itemViews.count];
    [_indicator setCurrentPoint:_currentIndex];
}

- (void)insertItemView:(UIView *)view atIndex:(NSInteger)index
{
    if (![self.itemViews containsObject:view]) {
        view.tag = self.itemViews.count;
        if (index < 0) {
            [self.itemViews addObject:view];
        } else {
            [self.itemViews insertObject:view atIndex:index];
        }
    }

    if (![self.scrollView.subviews containsObject:view]) {
        if (index < 0) {
            [self.scrollView addSubview:view];
        } else {
            [self.scrollView insertSubview:view atIndex:index];
        }
    }
    [self layoutSubviews];

    [self loadeeuiIndicator];

    [self setCurrentIndex:_currentIndex];
}

- (void)removeItemView:(UIView *)view
{
    if ([self.itemViews containsObject:view]) {
        [self.itemViews removeObject:view];
    }

    if ([self.scrollView.subviews containsObject:view]) {
        [view removeFromSuperview];
    }
    [self layoutSubviews];
    [self setCurrentIndex:_currentIndex];
}

#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_infinite) {
        CGFloat offX = scrollView.contentOffset.x;
        self.direction = offX > self.width ? DirectionLeft : offX < self.width ? DirectionRight : DirectionNone;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recycleSliderView:didScroll:)]) {
        [self.delegate recycleSliderView:self didScroll:self.scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:self.scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:self.scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_infinite) {
        [self resetScrollView];
    } else {
        NSInteger index = _scrollView.contentOffset.x / self.width;
        [self setCurrentIndex:index];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_infinite) {
        [self resetScrollView];
    } else {
        NSInteger index = _scrollView.contentOffset.x / self.width;
        [self setCurrentIndex:index];
    }
}

@end


@interface eeuiBannerComponent () <eeuiRecycleSliderViewDelegate,eeuiIndicatorComponentDelegate>

@property (nonatomic, strong) eeuiRecycleSliderView *recycleSliderView;
@property (nonatomic, strong) NSTimer *autoTimer;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL  autoPlay;
@property (nonatomic, assign) NSInteger interval;//自动滚动时长
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat lastOffsetXRatio;
@property (nonatomic, assign) CGFloat offsetXAccuracy;
@property (nonatomic, assign) BOOL  sliderChangeEvent;
@property (nonatomic, assign) BOOL  sliderScrollEvent;
@property (nonatomic, assign) BOOL  sliderScrollStartEvent;
@property (nonatomic, assign) BOOL  sliderScrollEndEvent;
@property (nonatomic, assign) BOOL  sliderStartEventFired;
@property (nonatomic, strong) NSMutableArray *childrenView;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, assign) BOOL infinite;//是否循环

//@property (nonatomic, assign) NSInteger autoPlayDuration;
@property (nonatomic, assign) NSInteger kscrollDuration;
@property (nonatomic, assign) BOOL kindicatorShow;
@property (nonatomic, assign) NSInteger kindicatorShape;
@property (nonatomic, assign) NSInteger kindicatorPosition;
@property (nonatomic, assign) NSInteger kindicatorMargin;
@property (nonatomic, assign) NSInteger kindicatorSpace;
@property (nonatomic, strong) NSString *kselectedIndicatorColor;
@property (nonatomic, strong) NSString *kunSelectedIndicatorColor;
@property (nonatomic, assign) NSInteger kindicatorWidth;
@property (nonatomic, assign) NSInteger kindicatorHeight;

@end

@implementation eeuiBannerComponent

WX_EXPORT_METHOD(@selector(startAutoPlay))
WX_EXPORT_METHOD(@selector(stopAutoPlay))
WX_EXPORT_METHOD(@selector(setAutoPlayDuration:))
WX_EXPORT_METHOD(@selector(setScrollDuration:))
WX_EXPORT_METHOD(@selector(setIndicatorShow:))
WX_EXPORT_METHOD(@selector(setIndicatorShape:))
WX_EXPORT_METHOD(@selector(setIndicatorPosition:))
WX_EXPORT_METHOD(@selector(setIndicatorMargin:))
WX_EXPORT_METHOD(@selector(setIndicatorSpace:))
WX_EXPORT_METHOD(@selector(setSelectedIndicatorColor:))
WX_EXPORT_METHOD(@selector(setUnSelectedIndicatorColor:))
WX_EXPORT_METHOD(@selector(setIndicatorWidth:))
WX_EXPORT_METHOD(@selector(setIndicatorHeight:))

- (void) dealloc
{
    [self _stopAutoPlayTimer];
}

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {

        _sliderChangeEvent = NO;
        _sliderScrollEvent = NO;
        _childrenView = [NSMutableArray new];
        _lastOffsetXRatio = 0;

        _autoPlay = attributes[@"autoPlay"] ? [WXConvert BOOL:attributes[@"autoPlay"]] : YES;

//        _interval = [DeviceUtil integerAttributes:attributes key:@"autoPlayDuration" defaultValue:6000];

        if (attributes[@"index"]) {
            _index = [WXConvert NSInteger:attributes[@"index"]];
        }
        _scrollable = attributes[@"scrollable"] ? [WXConvert BOOL:attributes[@"scrollable"]] : YES;
        _offsetXAccuracy =  attributes[@"offsetXAccuracy"] ?[WXConvert CGFloat:attributes[@"offsetXAccuracy"]] : 0;

        _infinite = attributes[@"infinite"] ? [WXConvert BOOL:attributes[@"infinite"]] : YES;
//        self.flexCssNode->setFlexDirection(WeexCore::kFlexDirectionRow,NO);

//        if (attributes[@"autoPlayDuration"]) {
//            _autoPlayDuration = [attributes[@"autoPlayDuration"] integerValue];
//        } else {
//            _autoPlayDuration = 6000;
//        }

        _interval = 6000;
        _kscrollDuration = 900;
        _kindicatorShow = YES;
        _kindicatorShape = 1;
        _kindicatorPosition = 0;
        _kindicatorMargin = SCALE(16);
        _kindicatorSpace = SCALE(6);
        _kselectedIndicatorColor = @"#3EB4FF";
        _kunSelectedIndicatorColor = @"#E0E0E0";
        _kindicatorWidth = SCALE(12);
        _kindicatorHeight = SCALE(12);

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
/*
        _kscrollDuration = [DeviceUtil integerAttributes:attributes key:@"scrollDuration" defaultValue:900];

        _kindicatorShow = [DeviceUtil boolAttributes:attributes key:@"indicatorShow" defaultValue:YES];

        _kindicatorShape = [DeviceUtil integerAttributes:attributes key:@"indicatorShape" defaultValue:1];

        _kindicatorPosition = [DeviceUtil integerAttributes:attributes key:@"indicatorPosition" defaultValue:0];

        _kindicatorMargin = SCALE([DeviceUtil integerAttributes:attributes key:@"indicatorMargin" defaultValue:16]);

        _kindicatorSpace = SCALE([DeviceUtil integerAttributes:attributes key:@"indicatorSpace" defaultValue:6]);

        _kselectedIndicatorColor =  [DeviceUtil stringAttributes:attributes key:@"selectedIndicatorColor" defaultValue:@"#3EB4FF"];

        _kunSelectedIndicatorColor =  [DeviceUtil stringAttributes:attributes key:@"unSelectedIndicatorColor" defaultValue:@"#99ffff"];

        _kindicatorWidth = SCALE([DeviceUtil integerAttributes:attributes key:@"indicatorWidth" defaultValue:12]);

        _kindicatorHeight = SCALE([DeviceUtil integerAttributes:attributes key:@"indicatorHeight" defaultValue:12]);
*/
    }
    return self;
}

- (UIView *)loadView
{
    return [[eeuiRecycleSliderView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _recycleSliderView = (eeuiRecycleSliderView *)self.view;
    _recycleSliderView.delegate = self;
    _recycleSliderView.scrollView.pagingEnabled = YES;
    _recycleSliderView.exclusiveTouch = YES;
    _recycleSliderView.scrollView.scrollEnabled = _scrollable;
    _recycleSliderView.infinite = _infinite;
    UIAccessibilityTraits traits = UIAccessibilityTraitAdjustable;
    if (_autoPlay) {
        traits |= UIAccessibilityTraitUpdatesFrequently;
        [self _startAutoPlayTimer];
    } else {
        [self _stopAutoPlayTimer];
    }
    _recycleSliderView.accessibilityTraits = traits;


    // 单击的 Recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick)];
    tap.numberOfTapsRequired = 1;
    [_recycleSliderView.scrollView addGestureRecognizer:tap];

    //长按
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongClick)];
    longPressGr.minimumPressDuration = 1.0;
    [_recycleSliderView.scrollView addGestureRecognizer:longPressGr];

    // 如果长按确定偵測失败才會触发单击
    [tap requireGestureRecognizerToFail:longPressGr];


    _recycleSliderView.autoPlayDuration = _interval;
    _recycleSliderView.scrollDuration = _kscrollDuration;
    _recycleSliderView.indicatorShow = _kindicatorShow;
    _recycleSliderView.indicatorShape = _kindicatorShape;
    _recycleSliderView.indicatorPosition = _kindicatorPosition;
    _recycleSliderView.indicatorMargin = _kindicatorMargin;
    _recycleSliderView.indicatorSpace = _kindicatorSpace;
    _recycleSliderView.selectedIndicatorColor = _kselectedIndicatorColor;
    _recycleSliderView.unSelectedIndicatorColor = _kunSelectedIndicatorColor;
    _recycleSliderView.indicatorWidth = _kindicatorWidth;
    _recycleSliderView.indicatorHeight = _kindicatorHeight;

    [self fireEvent:@"ready" params:nil];

}

- (void)layoutDidFinish
{
    _recycleSliderView.currentIndex = _index;
}

- (void)viewDidUnload
{
    [_childrenView removeAllObjects];
}

- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
//    if (subcomponent->_positionType == WXPositionTypeFixed) {
//        [self.weexInstance.rootView addSubview:subcomponent.view];
//        return;
//    }
//
//    // use _lazyCreateView to forbid component like cell's view creating
//    if(_lazyCreateView) {
//        subcomponent->_lazyCreateView = YES;
//    }
//
//    if (!subcomponent->_lazyCreateView || (self->_lazyCreateView && [self isViewLoaded])) {
        UIView *view = subcomponent.view;

        if(index < 0) {
            [self.childrenView addObject:view];
        }
        else {
            [self.childrenView insertObject:view atIndex:index];
        }

        eeuiRecycleSliderView *recycleSliderView = (eeuiRecycleSliderView *)self.view;
//        if ([view isKindOfClass:[eeuiIndicatorView class]]) {
//            ((eeuiIndicatorComponent *)subcomponent).delegate = self;
//            [recycleSliderView addSubview:view];
//            [self setIndicatorView:(eeuiIndicatorView *)view];
//            return;
//        }

        subcomponent.isViewFrameSyncWithCalculated = NO;

        if (index == -1) {
            [recycleSliderView insertItemView:view atIndex:index];
        } else {
            NSInteger offset = 0;
            for (int i = 0; i < [self.childrenView count]; ++i) {
                if (index == i) break;

                if ([self.childrenView[i] isKindOfClass:[eeuiIndicatorView class]]) {
                    offset++;
                }
            }
            [recycleSliderView insertItemView:view atIndex:index - offset];

            // check if should apply current contentOffset
            // in case inserting subviews after layoutDidFinish
            if (index-offset == _index && _index>0) {
                recycleSliderView.currentIndex = _index;
            }
        }
        [recycleSliderView layoutSubviews];
//    }
}

- (void)willRemoveSubview:(WXComponent *)component
{
    UIView *view = component.view;

    if(self.childrenView && [self.childrenView containsObject:view]) {
        [self.childrenView removeObject:view];
    }

    eeuiRecycleSliderView *recycleSliderView = (eeuiRecycleSliderView *)self.view;
    [recycleSliderView removeItemView:view];
    [recycleSliderView setCurrentIndex:0];
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
    if ([eventName isEqualToString:@"change"]) {
        _sliderChangeEvent = YES;
    }
    if ([eventName isEqualToString:@"scroll"]) {
        _sliderScrollEvent = YES;
    }
}

- (void)removeEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"change"]) {
        _sliderChangeEvent = NO;
    }
    if ([eventName isEqualToString:@"scroll"]) {
        _sliderScrollEvent = NO;
    }
}

- (void)itemClick
{
    [self fireEvent:@"itemClick" params:@{@"position":@(_currentIndex)}];
}

- (void)itemLongClick
{
    [self fireEvent:@"itemLongClick" params:@{@"position":@(_currentIndex)}];
}

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"autoPlayDuration"]) {
        _interval = [WXConvert NSInteger:value];
        if (isUpdate) {
            [self _stopAutoPlayTimer];

            if (_autoPlay) {
                [self _startAutoPlayTimer];
            }
        }
    }  else if ([key isEqualToString:@"scrollDuration"]) {
        _kscrollDuration = [WXConvert NSInteger:value];
        if (isUpdate) {
            self.recycleSliderView.scrollDuration = _kscrollDuration;
        }
    }  else if ([key isEqualToString:@"indicatorShow"]) {
        _kindicatorShow = [WXConvert BOOL:value];
        if (isUpdate) {
            self.recycleSliderView.indicatorShow = _kindicatorShow;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"indicatorShape"]) {
        _kindicatorShape = [WXConvert NSInteger:value];
        if (isUpdate) {
            self.recycleSliderView.indicatorSpace = _kindicatorShape;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"indicatorPosition"]) {
        _kindicatorPosition = [WXConvert NSInteger:value];
        if (isUpdate) {
            self.recycleSliderView.indicatorPosition = _kindicatorPosition;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"indicatorMargin"]) {
        _kindicatorMargin = SCALE([WXConvert NSInteger:value]);
        if (isUpdate) {
            self.recycleSliderView.indicatorMargin = _kindicatorMargin;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"indicatorSpace"]) {
        _kindicatorSpace = SCALE([WXConvert NSInteger:value]);
        if (isUpdate) {
            self.recycleSliderView.indicatorSpace = _kindicatorSpace;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"selectedIndicatorColor"]) {
        _kselectedIndicatorColor = [WXConvert NSString:value];
        if (isUpdate) {
            self.recycleSliderView.selectedIndicatorColor = _kselectedIndicatorColor;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"unSelectedIndicatorColor"]) {
        _kunSelectedIndicatorColor = [WXConvert NSString:value];
        if (isUpdate) {
            self.recycleSliderView.unSelectedIndicatorColor = _kunSelectedIndicatorColor;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"indicatorWidth"]) {
        _kindicatorWidth = SCALE([WXConvert NSInteger:value]);
        if (isUpdate) {
            self.recycleSliderView.indicatorWidth = _kindicatorWidth;
            [self.recycleSliderView loadeeuiIndicator];
        }
    } else if ([key isEqualToString:@"indicatorHeight"]) {
        _kindicatorHeight = SCALE([WXConvert NSInteger:value]);
        if (isUpdate) {
            self.recycleSliderView.indicatorHeight = _kindicatorHeight;
            [self.recycleSliderView loadeeuiIndicator];
        }
    }
}

#pragma mark eeuiIndicatorComponentDelegate Methods

-(void)setIndicatorView:(eeuiIndicatorView *)indicatorView
{
    NSAssert(_recycleSliderView, @"");
    [_recycleSliderView setIndicator:indicatorView];
}

- (void)resumeAutoPlay:(id)resume
{
    if (_autoPlay) {
        if ([resume boolValue]) {
            [self _startAutoPlayTimer];
        } else {
            [self _stopAutoPlayTimer];
        }
    }
}


- (void)startAutoPlay
{
    [self _startAutoPlayTimer];
}

- (void)stopAutoPlay
{
    [self _stopAutoPlayTimer];
}

- (void)setAutoPlayDuration:(id)value
{
    _interval = [WXConvert NSInteger:value];
    [self _stopAutoPlayTimer];

    if (_autoPlay) {
        [self _startAutoPlayTimer];
    }
}

- (void)setScrollDuration:(NSInteger)scrollDuration
{
    _kindicatorShow = scrollDuration;
    self.recycleSliderView.indicatorShow = _kindicatorShow;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorShow:(BOOL)indicatorShow
{
    _kindicatorShow = indicatorShow;
    self.recycleSliderView.indicatorShow = _kindicatorShow;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorShape:(NSInteger)indicatorShape
{
    _kindicatorShape = indicatorShape;
    self.recycleSliderView.indicatorSpace = _kindicatorShape;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorPosition:(NSInteger)indicatorPosition
{
    _kindicatorPosition = indicatorPosition;
    self.recycleSliderView.indicatorPosition = _kindicatorPosition;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorMargin:(NSInteger)indicatorMargin
{
    _kindicatorMargin = SCALE(indicatorMargin);
    self.recycleSliderView.indicatorMargin = _kindicatorMargin;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorSpace:(NSInteger)indicatorSpace
{
    _kindicatorSpace = SCALE(indicatorSpace);
    self.recycleSliderView.indicatorSpace = _kindicatorSpace;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setSelectedIndicatorColor:(NSString*)selectedIndicatorColor
{
    _kselectedIndicatorColor = selectedIndicatorColor;
    self.recycleSliderView.selectedIndicatorColor = _kselectedIndicatorColor;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setUnSelectedIndicatorColor:(NSString*)unSelectedIndicatorColor
{
    _kunSelectedIndicatorColor = unSelectedIndicatorColor;
    self.recycleSliderView.unSelectedIndicatorColor = _kunSelectedIndicatorColor;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorWidth:(NSInteger)indicatorWidth
{
    _kindicatorWidth = SCALE(indicatorWidth);
    self.recycleSliderView.indicatorWidth = _kindicatorWidth;
    [self.recycleSliderView loadeeuiIndicator];
}
- (void)setIndicatorHeight:(NSInteger)indicatorHeight
{
    _kindicatorHeight = SCALE(indicatorHeight);
    self.recycleSliderView.indicatorHeight = _kindicatorHeight;
    [self.recycleSliderView loadeeuiIndicator];
}

#pragma mark Private Methods

- (void)_startAutoPlayTimer
{
    if (!self.autoTimer || ![self.autoTimer isValid]) {
        __weak __typeof__(self) weakSelf = self;
        self.autoTimer = [NSTimer wx_scheduledTimerWithTimeInterval:_interval/1000.0f block:^() {
            [weakSelf _autoPlayOnTimer];
        } repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.autoTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)_stopAutoPlayTimer
{
    if (self.autoTimer && [self.autoTimer isValid]) {
        [self.autoTimer invalidate];
        self.autoTimer = nil;
    }
}

- (void)_autoPlayOnTimer
{
    if (!_infinite && (_currentIndex == _recycleSliderView.itemViews.count - 1)) {
        [self _stopAutoPlayTimer];
    }else {
        [self.recycleSliderView nextPage];
    }
}

#pragma mark ScrollView Delegate

- (void)recycleSliderView:(eeuiRecycleSliderView *)recycleSliderView didScroll:(UIScrollView *)scrollView
{
    if (_sliderScrollEvent) {
        CGFloat width = scrollView.frame.size.width;
        CGFloat XDeviation = 0;
        if (_infinite) {
            XDeviation = - (scrollView.contentOffset.x - width);
        } else {
            XDeviation = - (scrollView.contentOffset.x - width * _currentIndex);
        }
        CGFloat offsetXRatio = (XDeviation / width);
        if (fabs(offsetXRatio - _lastOffsetXRatio) >= _offsetXAccuracy) {
            _lastOffsetXRatio = offsetXRatio;
            [self fireEvent:@"scroll" params:@{@"offsetXRatio":[NSNumber numberWithFloat:offsetXRatio]} domChanges:nil];
        }
    }
}

- (void)recycleSliderView:(eeuiRecycleSliderView *)recycleSliderView didScrollToItemAtIndex:(NSInteger)index
{

    if (_sliderChangeEvent) {
        [self fireEvent:@"change" params:@{@"index":@(index)} domChanges:@{@"attrs": @{@"index": @(index)}}];
    }
    self.currentIndex = index;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _stopAutoPlayTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_autoPlay) {
        [self _startAutoPlayTimer];
    }
}

@end
