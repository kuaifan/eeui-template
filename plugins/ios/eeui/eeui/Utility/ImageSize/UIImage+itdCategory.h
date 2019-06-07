//
//  UIImage+UIImage_itdCategory.h
//  ImageSizeTest
//
//  Created by TX-009 on 15/6/18.
//  Copyright (c) 2015年 TX-009. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImageSizeBlock)(CGSize size);

@interface UIImage (itdCategory)

+ (void)itd_sizeOfImageWithUrlStr:(NSString *)imgUrlStr sizeGetDo:(ImageSizeBlock)doBlock;

@end
