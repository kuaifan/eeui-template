//
//  eeuiRippleComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiRippleComponent.h"
#import "ZYCRippleButton.h"

@interface eeuiRippleComponent ()

@property (nonatomic, strong) ZYCRippleButton *rippleButton;
@property (nonatomic, assign) BOOL isRemoveObserver;

@end

@implementation eeuiRippleComponent


- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    [self loadRippleView];

    [self fireEvent:@"ready" params:nil];
}

- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    [super insertSubview:subcomponent atIndex:index];
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
        [self loadRippleView];
    }
}

- (void) loadRippleView
{
    CGRect frame = self.view.frame;
    if (_rippleButton == nil) {
        __weak __typeof(self)weakSelf = self;
        _rippleButton = [[ZYCRippleButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _rippleButton.rippleLineWidth = 1;
        _rippleButton.rippleColor = [UIColor darkGrayColor];
        _rippleButton.backgroundColor = [UIColor clearColor];
        _rippleButton.rippleBlock = ^(void){
            [weakSelf fireEvent:@"click" params:nil];
            [weakSelf fireEvent:@"itemClick" params:nil];
        };
        [self.view addSubview:_rippleButton];
    }else{
        _rippleButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
}

@end
