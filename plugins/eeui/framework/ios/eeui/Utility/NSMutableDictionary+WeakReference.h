//
//  NSMutableDictionary+WeakReference.h
//  eeui
//
//  Created by hikobe on 2021/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (WeakReference)
- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey;

- (void)weak_setObjectWithDictionary:(NSDictionary *)dic;

- (id)weak_getObjectForKey:(NSString *)key;
@end

@interface NSDictionary (WeakReference)
- (id)weak_getObjectForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
