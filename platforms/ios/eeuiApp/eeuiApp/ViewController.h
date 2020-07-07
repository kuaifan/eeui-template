//
//  ViewController.h
//  eeuiApp
//
//  Created by 高一 on 2018/8/15.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void) loadUrl:(NSString*) url forceRefresh:(BOOL) forceRefresh;

- (BOOL) isReady;

- (void) clickWelcome;

- (BOOL) isBugBtnClick;

- (void) setBugBtnClick;

@end

