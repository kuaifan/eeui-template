//
//  Cloud.h
//  eeuiProject
//
//  Created by 高一 on 2018/9/27.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickWelcome)(void);

@interface Cloud : NSObject

+ (NSInteger) welcome:(nullable UIView *) view click:(nullable ClickWelcome) click;
+ (void) welcomeClose;
+ (void) appData;
+ (NSMutableDictionary *) getAppInfo;
+ (void) saveWelcomeImage:(NSString*)url wait:(NSInteger)wait;
+ (void) checkUpdateLists:(NSMutableArray*)lists number:(NSInteger)number isReboot:(BOOL)isReboot;
+ (void) reboot;
+ (void) clearUpdate;

@end

NS_ASSUME_NONNULL_END
