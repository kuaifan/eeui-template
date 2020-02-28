//
//  eeuiCachesManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiCachesManager.h"

@implementation eeuiCachesManager

+ (eeuiCachesManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)getCacheSizeDir:(WXModuleKeepAliveCallback)callback
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileCachePath = [NSString stringWithFormat:@"%@/Caches", path];

//    NSInteger  sizes = [[[NSFileManager defaultManager] attributesOfItemAtPath:fieldPaths error:nil] fileSize];
//    if (callback) {
//        callback(@{@"size":@(sizes)}, NO);
//    }

    //获取到该缓存目录下的所有子文件（只是文件名并不是路径，后面要拼接）
    NSArray * subFilePath = [[NSFileManager defaultManager] subpathsAtPath:fileCachePath];

    //先定义一个缓存目录总大小的变量
    NSInteger fileTotalSize = 0;

    for (NSString * fileName in subFilePath)
    {
        //拼接文件全路径（注意：是文件）
        NSString * filePath = [fileCachePath stringByAppendingPathComponent:fileName];

        //获取文件属性
        NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];

        //根据文件属性判断是否是文件夹（如果是文件夹就跳过文件夹，不将文件夹大小累加到文件总大小）
        if ([fileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]) continue;

        //获取单个文件大小,并累加到总大小
        fileTotalSize += [fileAttributes[NSFileSize] integerValue];
    }

    if (callback) {
        callback(@{@"size":@(fileTotalSize)}, NO);
    }
}

- (void)clearCacheDir:(WXModuleKeepAliveCallback)callback
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fieldPaths = [NSString stringWithFormat:@"%@/Caches", path];
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fieldPaths error:nil];

    NSString *filePath = nil;
    NSError *error = nil;
    NSInteger success = 0, fail = 0;
    for (NSString *subPath in subPathArr)
    {
        filePath = [fieldPaths stringByAppendingPathComponent:subPath];

        //删除子文件夹
        BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!isSuccess) {
            fail++;
        } else {
            success++;
        }
    }

    if (callback) {
        callback(@{@"success":@(success), @"error":@(fail)}, NO);
    }
}

- (void)getCacheSizeFiles:(WXModuleKeepAliveCallback)callback
{
    [self getCacheSizeDir:callback];
}

- (void)clearCacheFiles:(WXModuleKeepAliveCallback)callback
{
    [self clearCacheDir:callback];
}

- (void)getCacheSizeDbs:(WXModuleKeepAliveCallback)callback
{
    [self getCacheSizeDir:callback];
}

- (void)clearCacheDbs:(WXModuleKeepAliveCallback)callback
{
    [self clearCacheDir:callback];
}


@end
