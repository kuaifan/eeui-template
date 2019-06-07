//
//  scanViewController.h
//  CCNScan
//
//  Created by zcc on 16/4/14.
//  Copyright © 2016年 CCN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface scanViewController : UIViewController

@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) BOOL successClose;

@property (nonatomic, copy) void (^scanerBlock)(NSDictionary*);

@end
