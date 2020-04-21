#import <UIKit/UIKit.h>

@interface BlurEffectWithAmount : UIBlurEffect
@property(nonatomic, strong) NSNumber *blurAmount;

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style andBlurAmount:(NSNumber *)blurAmount;
- (void)setBlurAmount:(NSNumber *)blurAmount;
@end
