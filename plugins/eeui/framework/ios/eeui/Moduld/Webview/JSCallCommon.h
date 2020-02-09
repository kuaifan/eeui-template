//
//  JSCallCommon.h
//  eeuiProject
//
//  Created by 高一 on 2019/1/5.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSCallCommon : NSObject

@property (nonatomic, strong) NSMutableDictionary *AllClass;
@property (nonatomic, strong) NSMutableDictionary *AllInit;

- (void) viewDidUnload;
- (BOOL) isJSCall:(NSString*)JSText;
- (id) onJSCall:(WKWebView*)webView JSText:(NSString*)JSText;
- (void) setJSCallAssign:(WKWebView*)webView name:(NSString*)name bridge:(id)bridge;
- (void) addRequireModule:(WKWebView*)webView;
- (void) setJSCallAll:(id)webBridge webView:(WKWebView*)webView;

+ (NSString*) dictionaryToJson:(NSDictionary *)dic;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (void) WXCall2JSCall:(WKWebView*)webView identify:(NSString*)identify index:(int)index result:(id)result keepAlive:(BOOL) keepAlive;
+ (BOOL) isBoolNumber:(NSNumber *)num;

@end

NS_ASSUME_NONNULL_END
