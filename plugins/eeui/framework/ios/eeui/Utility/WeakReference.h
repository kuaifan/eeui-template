//
//  WeakReference.h
//  eeui
//
//  Created by hikobe on 2021/3/22.
//

#import <Foundation/Foundation.h>

//定义一个block,变量WeakReference 该block的返回类型为id 参数为void
typedef id (^WeakReference)(void);

// 创建一个该类型的变量makeWeakReference，WeakReference直接作为makeWeakReference函数的返回值(封装)
WeakReference makeWeakReference(id object);

// ref作为weakReferenceNonretainedObjectValue参数(解封)
id weakReferenceNonretainedObjectValue(WeakReference ref);
