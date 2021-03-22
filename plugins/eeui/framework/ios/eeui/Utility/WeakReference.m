//
//  WeakReference.m
//  eeui
//
//  Created by hikobe on 2021/3/22.
//

#import "WeakReference.h"

WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    //这里之所以return后跟了一个block，就是因为WeakReference本身作为了makeWeakReference的返回值，WeakReference是个block，他的返回值类型为id，所以里面return weakref
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(WeakReference ref) {
//利用三目运算符，block在没有任何值的时候，直接赋值nil，有值时返回ref()，即返回block块中的对象
    return ref ? ref() : nil;
}
