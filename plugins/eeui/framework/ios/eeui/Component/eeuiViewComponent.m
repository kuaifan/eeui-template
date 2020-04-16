//
//  eeuiViewComponent.m
//  Pods
//

#import "eeuiViewComponent.h"
#import "WXSDKInstance.h"

@interface eeuiViewComponent ()
@end

@implementation eeuiViewComponent

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addObserver:self forKeyPath:@"frame" options:0 context:nil];
    //
    [self fireEvent:@"ready" params:nil];
    //
    CGRect newFrame = self.view.frame;
    [self fireResize:newFrame.size.width height:newFrame.size.height];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        if ([object valueForKeyPath:keyPath] != [NSNull null]) {
            CGRect newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            [self fireResize:newFrame.size.width height:newFrame.size.height];
        }
    }
}

- (void)fireResize:(CGFloat)width height:(CGFloat)height {
    if (_layerWidth != width || _layerHeight != height) {
        _layerWidth = width;
        _layerHeight = height;
        CGFloat scaleFactor = self.weexInstance.pixelScaleFactor;
        [self fireEvent:@"resize" params:@{
                @"width": @(_layerWidth / scaleFactor),
                @"height": @(_layerHeight / scaleFactor),
        }];
    }
}

@end
