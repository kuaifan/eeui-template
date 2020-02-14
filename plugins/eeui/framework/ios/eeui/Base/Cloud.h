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

+ (NSString*) getUrl:(NSString*) act;
+ (NSInteger) welcome:(nullable UIView *) view click:(nullable ClickWelcome) click;
+ (void) welcomeClose;
+ (void) appData:(BOOL)client_mode;
+ (NSMutableDictionary *) getAppInfo;
+ (void) saveWelcomeImage:(NSString*)url wait:(NSInteger)wait;
+ (void) checkUpdateLists:(NSMutableArray*)lists number:(NSInteger)number;
+ (void) checkVersionUpdate:(NSMutableDictionary*)jsonData;
+ (NSDictionary *) getUpdateVersionData;
+ (void) reboot;
+ (void) clearUpdate;

@end

NS_ASSUME_NONNULL_END
