//
//  eeuiBlurComponent.m
//

#import "eeuiBlurComponent.h"
#import "DeviceUtil.h"

@interface eeuiBlurComponent()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property(nonatomic, strong, nullable) BlurEffectWithAmount *blurEffect;
@property (nonatomic, strong) UIView *mView;

@end

@implementation eeuiBlurComponent
@synthesize weexInstance;


- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        self.weexInstance = weexInstance;

        _mType = @"light";
        _mAmount = 30;

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
    }
    return self;
}

- (void)viewDidLoad {
    CGRect make = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _blurEffectView = [[UIVisualEffectView alloc] initWithFrame:make];
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self updateBlurView];
    [self.view addSubview:_blurEffectView];

    _mView = [[UIControl alloc] initWithFrame:make];
    [self.view addSubview:_mView];

    [_mView sendSubviewToBack:_blurEffectView];
    [self fireEvent:@"ready" params:nil];
}


- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index {
    UIView *view = subcomponent.view;
    [_mView addSubview:view];
}

- (void)updateStyles:(NSDictionary *)styles {
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes {
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
}


#pragma mark data

- (void)dataKey:(NSString *)key value:(id)value isUpdate:(BOOL)isUpdate {
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        NSArray *array = [value allKeys];
        for (NSString *k in array) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"type"]) {
        _mType = [WXConvert NSString:value];
        if (isUpdate) {
            [self setType:_mType];
        }
    } else if ([key isEqualToString:@"radius"]) {
        _mAmount = [WXConvert NSInteger:value];
        if (_mAmount > 100) _mAmount = 100;
        if (_mAmount < 0) _mAmount = 0;
        if (isUpdate) {
            [self setAmount:_mAmount];
        }
    }
}

- (UIBlurEffectStyle)blurEffectStyle {
    if ([_mType isEqual:@"light"]) return UIBlurEffectStyleLight;
    if ([_mType isEqual:@"dark"]) return UIBlurEffectStyleDark;
    return UIBlurEffectStyleLight;
}

- (void)updateBlurView {
    _blurEffect = [BlurEffectWithAmount effectWithStyle:[self blurEffectStyle] andBlurAmount:[NSNumber numberWithInteger:(NSInteger) (_mAmount * 0.25)]];
    _blurEffectView.effect = self.blurEffect;
}

- (void)setType:(NSString *)type {
    _mType = type;
    [self updateBlurView];
}

- (void)setAmount:(NSInteger)radius {
    _mAmount = radius;
    [self updateBlurView];
}

@end
