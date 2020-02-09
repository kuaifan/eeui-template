//
//  UIImage+UIImage_itdCategory.m
//  ImageSizeTest
//
//  Created by TX-009 on 15/6/18.
//  Copyright (c) 2015年 TX-009. All rights reserved.
//

#import "UIImage+itdCategory.h"

NSString *const kPngRangeValue = @"bytes=16-23";
NSString *const kJpgRangeValue = @"bytes=0-209";
NSString *const kGifRangeValue = @"bytes=6-9";

@implementation UIImage (itdCategory)

+ (void)itd_sizeOfImageWithUrlStr:(NSString *)imgUrlStr sizeGetDo:(ImageSizeBlock)doBlock
{
    NSString *extensionStr = [[imgUrlStr pathExtension] lowercaseString];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (doBlock) {
            CGSize imgSize = CGSizeZero;
            if ([extensionStr isEqualToString:@"png"]) {
                imgSize = [UIImage size_downloadPNGImageWithUrlString:imgUrlStr];
            }else if ([extensionStr isEqualToString:@"gif"]){
                imgSize = [UIImage size_downloadGIFImageWithUrlString:imgUrlStr];
            }else{
                imgSize = [UIImage size_downloadJPGImageWithUrlString:imgUrlStr];
            }
            if (CGSizeEqualToSize(CGSizeZero, imgSize)) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrlStr]];
                UIImage *image = [UIImage imageWithData:data];
                imgSize = image.size;
            }
            doBlock(imgSize);
        }
    });
}

+ (CGSize)size_downloadJPGImageWithUrlString:(NSString *)urlString{
    NSString *URLString = urlString;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:kJpgRangeValue forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (data == nil || [data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

+ (CGSize)size_downloadPNGImageWithUrlString:(NSString *)urlString{
    NSString *URLString = urlString;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:kPngRangeValue forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(data && data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

+ (CGSize)size_downloadGIFImageWithUrlString:(NSString *)urlString{
    NSString *URLString = urlString;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:kGifRangeValue forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data && data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(1, 1)];
        [data getBytes:&w2 range:NSMakeRange(0, 1)];
        short w = (w1 << 8) + w2;
        
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(3, 1)];
        [data getBytes:&h2 range:NSMakeRange(2, 1)];
        short h = (h1 << 8) + h2;
        
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

@end
