//
//  eeuiGridComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiGridComponent.h"
#import "DeviceUtil.h"

#define kItemViewTag 1000
#define kIndicatorViewTag 2000
#define kDividerViewTag 3000

@interface eeuiGridComponent() <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, assign) CGFloat kdividerWidth;
@property (nonatomic, assign) NSInteger kindicatorShape;
@property (nonatomic, assign) NSInteger kindicatorSpace;
@property (nonatomic, assign) NSInteger kindicatorWidth;
@property (nonatomic, assign) NSInteger kindicatorHeight;

@property (nonatomic, strong) NSString *kdividerColor;
@property (nonatomic, strong) NSString *kselectedIndicatorColor;
@property (nonatomic, strong) NSString *kunSelectedIndicatorColor;

@property (nonatomic, assign) BOOL kdivider;
@property (nonatomic, assign) BOOL kindicatorShow;

@property (nonatomic, strong) NSMutableArray *subViews;

@property (nonatomic, strong) WXSDKInstance *navInstance;
@property (nonatomic, strong) UIScrollView *gridView;
@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation eeuiGridComponent

WX_EXPORT_METHOD(@selector(setRowSize:))
WX_EXPORT_METHOD(@selector(setColumnsSize:))
WX_EXPORT_METHOD(@selector(setDivider:))
WX_EXPORT_METHOD(@selector(setDividerColor:))
WX_EXPORT_METHOD(@selector(setDividerWidth:))
WX_EXPORT_METHOD(@selector(setCurrentIndex:))
WX_EXPORT_METHOD_SYNC(@selector(getCurrentIndex))
WX_EXPORT_METHOD(@selector(setIndicatorShow:))
WX_EXPORT_METHOD(@selector(setIndicatorShape:))
WX_EXPORT_METHOD(@selector(setIndicatorSpace:))
WX_EXPORT_METHOD(@selector(setSelectedIndicatorColor:))
WX_EXPORT_METHOD(@selector(setUnSelectedIndicatorColor:))
WX_EXPORT_METHOD(@selector(setIndicatorWidth:))
WX_EXPORT_METHOD(@selector(setIndicatorHeight:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {

        _kdividerColor = @"#E8E8E8";
        _kselectedIndicatorColor = @"#3EB4FF";
        _kunSelectedIndicatorColor = @"#E0E0E0";
        _row = 3;
        _columns = 3;
        _kdividerWidth = SCALE(1);
        _kindicatorShape = 1;
        _kindicatorSpace = SCALE(12);
        _kindicatorWidth = SCALE(12);
        _kindicatorHeight = SCALE(12);
        _kdivider = YES;
        _kindicatorShow = YES;

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }

        _navInstance = weexInstance;
        _currentIndex = 0;
        _subViews = [NSMutableArray arrayWithCapacity:5];

    }

    return self;
}

- (void)viewDidLoad
{
    self.gridView = [[UIScrollView alloc] init];
    self.gridView.pagingEnabled = YES;
    self.gridView.showsHorizontalScrollIndicator = NO;
    self.gridView.delegate = self;
    [self.view addSubview:self.gridView];

    self.indicatorView = [[UIView alloc] init];
    [self.view addSubview:self.indicatorView];
}

- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }

    [self loadComponentView];
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }

    [self loadComponentView];
}

- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    if (_subViews.count == 0) {
        [_subViews addObject:subcomponent.view];
    } else {
        [_subViews insertObject:subcomponent.view atIndex:index];
    }

    [self loadComponentView];
}

- (void)loadComponentView
{
    CGFloat bottomHeight = 8 + _kindicatorHeight;
    _gridView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - bottomHeight);

    CGFloat itemWidth = _gridView.frame.size.width/_columns;
    CGFloat itemHeight = _gridView.frame.size.height/_row;
    NSInteger page = _subViews.count / (_columns * _row) + (_subViews.count % (_columns * _row) > 0 ? 1 : 0);

    for (int i = 0; i < _subViews.count; i++) {
        UIView *itemView = _subViews[i];
        itemView.frame = CGRectMake(i/(_columns * _row) * _gridView.frame.size.width + i % _columns * itemWidth, i % (_columns * _row)/_columns * itemHeight, itemWidth, itemHeight);

        if (![_gridView.subviews containsObject:itemView]) {
            if (i == 0) {
                [_gridView addSubview:itemView];
            } else {
                [_gridView insertSubview:itemView atIndex:i];
            }
        }

        itemView.tag = kItemViewTag + i;

        //添加手势
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemPanClick:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [itemView addGestureRecognizer:tapRecognizer];

        //长按
        UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongClick:)];
        longRecognizer.minimumPressDuration = 1.0;
        [itemView addGestureRecognizer:longRecognizer];

        // 如果长按确定偵測失败才會触发单击
        [tapRecognizer requireGestureRecognizerToFail:longRecognizer];

    }

    [_gridView setContentSize:CGSizeMake(page * _gridView.frame.size.width, 0)];

    [self loadDividerView];

    [self loadIndicatorView];
}

- (void)loadDividerView
{
    if (_kdivider) {
        CGFloat itemWidth = _gridView.frame.size.width/_columns;
        CGFloat itemHeight = _gridView.frame.size.height/_row;
        NSInteger page = _subViews.count / (_columns * _row) + (_subViews.count % (_columns * _row) > 0 ? 1 : 0);

        for (int i = 1; i < _row; i++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, i*itemHeight, _gridView.frame.size.width * page, _kdividerWidth)];
            lineView.backgroundColor = [WXConvert UIColor:_kdividerColor];
            lineView.tag = kDividerViewTag + i;
            [_gridView addSubview:lineView];
        }

        for (int i = 0; i < page; i++) {
            for (int j = 0; j < _columns - 1; j++) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((j + 1)*itemWidth + _gridView.frame.size.width * i, 0, _kdividerWidth, _gridView.frame.size.height)];
                lineView.backgroundColor = [WXConvert UIColor:_kdividerColor];
                lineView.tag = kDividerViewTag + i*100 + j;
                [_gridView addSubview:lineView];
            }
        }
    } else {
        for (UIView *lineView in _gridView.subviews) {
            if (lineView.tag >= kDividerViewTag) {
                [lineView removeFromSuperview];
            }
        }
    }
}

- (void)loadIndicatorView
{
    if (_kindicatorShow) {
        _indicatorView.hidden = NO;

        for (UIView *oldView in _indicatorView.subviews) {
            [oldView removeFromSuperview];
        }
        NSInteger page = _subViews.count / (_columns * _row) + (_subViews.count % (_columns * _row) > 0 ? 1 : 0);

        for (int i = 0; i < page; i++) {
            UIButton *indBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            indBtn.frame = CGRectMake((_kindicatorSpace + _kindicatorWidth) * i, 0, _kindicatorWidth, _kindicatorHeight);
            [indBtn setBackgroundImage:[self imageWithColor:[WXConvert UIColor:_kunSelectedIndicatorColor]] forState:UIControlStateNormal];
            [indBtn setBackgroundImage:[self imageWithColor:[WXConvert UIColor:_kselectedIndicatorColor]] forState:UIControlStateSelected];
            indBtn.tag = kIndicatorViewTag + i;
            [_indicatorView addSubview:indBtn];

            if (_kindicatorShape) {
                indBtn.layer.cornerRadius = _kindicatorHeight * 1.0 / 2;
                indBtn.layer.masksToBounds = YES;
            }

            if (i == _currentIndex) {
                indBtn.selected = YES;
            } else {
                indBtn.selected = NO;
            }
        }

        CGFloat width = (_kindicatorSpace + _kindicatorWidth) * page - _kindicatorSpace;
        CGFloat height = _kindicatorHeight;
        _indicatorView.frame = CGRectMake((self.view.frame.size.width - width)/2, _gridView.frame.size.height + 8, width, height);
    } else {
        _indicatorView.hidden = YES;
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

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"row"]) {
        _row = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"columns"]) {
        _columns = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"divider"]) {
        _kdivider = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"dividerColor"]) {
        _kdividerColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"dividerWidth"]) {
       _kdividerWidth = SCALE([WXConvert CGFloat:value]);
    } else if ([key isEqualToString:@"indicatorShow"]) {
        _kindicatorShow = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"indicatorShape"]) {
        _kindicatorShape = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"indicatorSpace"]) {
        _kindicatorSpace = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"selectedIndicatorColor"]) {
        _kselectedIndicatorColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"unSelectedIndicatorColor"]) {
        _kunSelectedIndicatorColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"indicatorWidth"]) {
        _kindicatorWidth = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"indicatorHeight"]) {
        _kindicatorHeight = SCALE([WXConvert NSInteger:value]);
    }
}
#pragma mark action
- (void)itemPanClick:(UITapGestureRecognizer*)panRecognizer
{
    NSInteger index = panRecognizer.view.tag - kItemViewTag;
    NSInteger page = index / (_columns * _row);
    NSInteger position = index % (_columns * _row);
    NSDictionary *data = @{@"page":@(page), @"position":@(position), @"index":@(index)};
    [self fireEvent:@"itemClick" params:data];

    EELog(@"%@", data);
}

- (void)itemLongClick:(UILongPressGestureRecognizer*)longRecognizer
{
    NSInteger index = longRecognizer.view.tag - kItemViewTag;
    NSInteger page = index / (_columns * _row);
    NSInteger position = index % (_columns * _row);
    NSDictionary *data = @{@"page":@(page), @"position":@(position), @"index":@(index)};
    [self fireEvent:@"itemLongClick" params:data];
}


#pragma mark delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;

    NSInteger page = _subViews.count / (_columns * _row) + (_subViews.count % (_columns * _row) > 0 ? 1 : 0);
    for (int i = 0; i < page; i++) {
        UIButton *btn = (UIButton*)[_indicatorView viewWithTag:kIndicatorViewTag + i];
        if (i == _currentIndex) {
            btn.selected = YES;
        } else {
            btn.selected = NO;
        }
    }
}

#pragma mark methods

- (void)setRowSize:(NSInteger)row
{
    _row = row;
    [self loadComponentView];
}

- (void)setColumnsSize:(NSInteger)columns
{
    _columns = columns;
    [self loadComponentView];
}

- (void)setDivider:(BOOL)divider
{
    _kdivider = divider;
    [self loadIndicatorView];
}

- (void)setDividerColor:(NSString*)color
{
    _kdividerColor = color;
    [self loadDividerView];
}

- (void)setDividerWidth:(CGFloat)width
{
    _kdividerWidth = SCALE(width);
    [self loadDividerView];
}

- (void)setCurrentIndex:(NSInteger)index
{
    [_gridView setContentOffset:CGPointMake(index * _gridView.frame.size.width, 0)];
}

- (NSInteger)getCurrentIndex
{
    return _currentIndex;
}

- (void)setIndicatorShow:(BOOL)indicatorShow
{
    _kindicatorShow = indicatorShow;
    [self loadIndicatorView];
}

- (void)setIndicatorShape:(NSInteger)indicatorShape
{
    _kindicatorShape = SCALE(indicatorShape);
    [self loadIndicatorView];
}

- (void)setIndicatorSpace:(NSInteger)indicatorSpace
{
    _kindicatorSpace = indicatorSpace;
    [self loadIndicatorView];
}

- (void)setSelectedIndicatorColor:(NSString*)selectedIndicatorColor
{
    _kselectedIndicatorColor = selectedIndicatorColor;
    [self loadIndicatorView];
}

- (void)setUnSelectedIndicatorColor:(NSString*)unSelectedIndicatorColor
{
    _kunSelectedIndicatorColor = unSelectedIndicatorColor;
    [self loadIndicatorView];
}

- (void)setIndicatorWidth:(NSInteger)indicatorWidth
{
    _kindicatorWidth = SCALE(indicatorWidth);
    [self loadIndicatorView];
}

- (void)setIndicatorHeight:(NSInteger)indicatorHeight
{
    _kindicatorHeight = SCALE(indicatorHeight);
    [self loadIndicatorView];
}

@end
