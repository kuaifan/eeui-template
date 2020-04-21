//
//  eeuiBlurComponent.h
//

#import "WXComponent.h"
#import <WeexSDK/WXEventModuleProtocol.h>
#import <WeexSDK/WXModuleProtocol.h>
#import "BlurEffectWithAmount.h"


NS_ASSUME_NONNULL_BEGIN

@interface eeuiBlurComponent : WXComponent <WXModuleProtocol>

@property(strong, nonatomic) NSString *mType;
@property(nonatomic, assign) NSInteger mAmount;

@end

NS_ASSUME_NONNULL_END
