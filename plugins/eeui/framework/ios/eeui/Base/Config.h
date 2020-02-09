//
//  Config.h
//  eeuiProject
//
//  Created by 高一 on 2018/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Config : NSObject

+ (NSMutableDictionary *) get;
+ (void) clear;
+ (NSString *) getString:(NSString*)key defaultVal:(NSString *)defaultVal;
+ (NSMutableDictionary *) getObject:(NSString*)key;
+ (id) getRawValue:(NSString*)key;
+ (void) getHomeUrl:(void(^)(NSString* path))callback;
+ (NSString *) getHomeParams:(NSString*)key defaultVal:(NSString *)defaultVal;
+ (NSString *) verifyFile:(NSString*)originalUrl;
+ (NSMutableArray*) verifyData;
+ (BOOL) verifyIsUpdate;
+ (void) setCustomConfig:(NSString*)key value:(id)value;
+ (NSMutableDictionary *) getCustomConfig;
+ (void) clearCustomConfig;
+ (void) clearCache;

+ (NSString *) getResourcePath:(NSString*)name;
+ (NSString *) getSandPath:(NSString*)name;
+ (NSInteger) getLocalVersion;
+ (NSString*)getLocalVersionName;
+ (BOOL) isFileExists:(NSString*)path;
+ (BOOL) isFile:(NSString*)path;
+ (BOOL) isDir:(NSString*)path;
+ (NSString *) getyyyMMddHHmmss;
+ (NSString *) MD5ForLower32Bate:(NSString *)str;
+ (NSString *) getMiddle:(NSString *)string start:(nullable NSString *)startString to:(nullable NSString *)endString;

@end

NS_ASSUME_NONNULL_END

