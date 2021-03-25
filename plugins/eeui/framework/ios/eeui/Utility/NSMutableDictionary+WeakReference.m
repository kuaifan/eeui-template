//
//  NSMutableDictionary+WeakReference.m
//  eeui
//
//  Created by hikobe on 2021/3/22.
//

#import "NSMutableDictionary+WeakReference.h"
#import "WeakReference.h"
@implementation NSMutableDictionary (WeakReference)
- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeWeakReference(anObject) forKey:aKey];
}

- (void)weak_setObjectWithDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        [self setObject:makeWeakReference(dictionary[key]) forKey:key];
    }
}

- (id)weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}
@end
@implementation NSDictionary (WeakReference)
- (id)weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}
@end
