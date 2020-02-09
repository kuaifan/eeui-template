//
//  IpUtil.h
//  Pods
//
//  Created by 高一 on 2019/7/23.
//

#import <Foundation/Foundation.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

NS_ASSUME_NONNULL_BEGIN

@interface IpUtil : NSObject

+ (NSString *)getNetworkIPAddress;
+ (NSMutableArray *)getLocalIPAddressIPv4Lists;
+ (BOOL)isValidatIP:(NSString *)ipAddress;

@end

NS_ASSUME_NONNULL_END
