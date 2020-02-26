//
//  eeuiAlertManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiAlertManager.h"
#import "DeviceUtil.h"
#import "UIAlertController+HLTapDismiss.h"

#define AlertTag 700

@interface eeuiAlertManager ()

@property (nonatomic, strong) NSMutableArray *inputTextFieldList;
@property (nonatomic, strong) NSMutableArray *inputTextLengthList;

@end

@implementation eeuiAlertManager

+ (eeuiAlertManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.inputTextFieldList = [NSMutableArray arrayWithCapacity:3];
        self.inputTextLengthList = [NSMutableArray arrayWithCapacity:3];
    }

    return self;
}

#pragma mark alert
- (void)alert:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *title = @"";
    NSString *message = @"";
    NSString *button = @"确定";
    BOOL cancelable = YES;
    if ([params isKindOfClass:[NSDictionary class]]) {
        title = params[@"title"] ? [WXConvert NSString:params[@"title"]] : @"";
        message = params[@"message"] ? [WXConvert NSString:params[@"message"]] : @"";
        button = params[@"button"] ? [WXConvert NSString:params[@"button"]] : @"确定";
        cancelable = params[@"cancelable"] ? [WXConvert BOOL:params[@"cancelable"]] : YES;
    }else{
        title = [WXConvert NSString:params];
    }

    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (callback != nil) {
            callback(nil, NO);
        }
    }];
    [alertCtrl addAction:confirmAction];
    [[DeviceUtil getTopviewControler] presentViewController:alertCtrl animated:YES completion:cancelable ? (^{
        [alertCtrl alertTapDismiss];
    }) : nil];
}

#pragma mark confirm
- (void)confirm:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *title = @"";
    NSString *message = @"";
    BOOL cancelable = YES;
    NSArray *buttons = @[@"取消", @"确定"];
    if ([params isKindOfClass:[NSDictionary class]]) {
        title = params[@"title"] ? [WXConvert NSString:params[@"title"]] : @"";
        message = params[@"message"] ? [WXConvert NSString:params[@"message"]] : @"";
        cancelable = params[@"cancelable"] ? [WXConvert BOOL:params[@"cancelable"]] : YES;
        if (params[@"buttons"]) buttons = params[@"buttons"];
    }else{
        title = [WXConvert NSString:params];
    }

    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    for (int i = 0; i < buttons.count; i++) {
        id value = buttons[i];
        NSString *title = @"";
        NSString *type = @"";
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)value;
            title = dic[@"title"];
            type = dic[@"type"];

            if ([type isEqualToString:@"positive"]) {
                style = UIAlertActionStyleDestructive;
            } else if ([type isEqualToString:@"negative"]) {
                style = UIAlertActionStyleCancel;
            } else if ([type isEqualToString:@"neutral"]) {
                style = UIAlertActionStyleDefault;
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            title = value;
        }

        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
            if (callback != nil) {
                NSDictionary *res = @{@"status":@"click", @"position":@(i), @"title":title};
                callback(res, YES);
            }

            if (callback != nil) {
                NSDictionary *res1 = @{@"status":@"cancel", @"position":@(i), @"title":title};
                callback(res1, NO);
            }
        }];
        [alertCtrl addAction:action];
        if (callback != nil) {
            NSDictionary *res2 = @{@"status":@"show", @"position":@(i), @"title":title};
            callback(res2, YES);
        }
    }

    [[DeviceUtil getTopviewControler] presentViewController:alertCtrl animated:YES completion:cancelable ? (^{
        [alertCtrl alertTapDismiss];
    }) : nil];
}

#pragma mark input
- (void)input:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *title = @"";
    NSString *message = @"";
    BOOL cancelable = YES;
    NSArray *buttons = @[@"取消", @"确定"];
    NSArray *inputs = @[@{@"type":@"text"}];
    if ([params isKindOfClass:[NSDictionary class]]) {
        title = params[@"title"] ? [WXConvert NSString:params[@"title"]] : @"";
        message = params[@"message"] ? [WXConvert NSString:params[@"message"]] : @"";
        cancelable = params[@"cancelable"] ? [WXConvert BOOL:params[@"cancelable"]] : YES;
        if (params[@"buttons"]) buttons = params[@"buttons"];
        if (params[@"inputs"]) inputs = params[@"inputs"];
    }else{
        title = [WXConvert NSString:params];
    }

    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    //输入框
    BOOL isNewInput = NO;
    if (inputs.count == 0) {
        isNewInput = YES;
    }
    __weak typeof(self) ws = self;

    for (int i = 0; i < inputs.count; i++) {
        NSDictionary *dic = inputs[i];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *type = dic[@"type"] ? [WXConvert NSString:dic[@"type"]] : @"text";
            NSString *value = dic[@"value"] ? [WXConvert NSString:dic[@"value"]] : @"";
            NSString *placeholder = dic[@"placeholder"] ? [WXConvert NSString:dic[@"placeholder"]] : @"";
            NSString *textColor = dic[@"textColor"] ? [WXConvert NSString:dic[@"textColor"]] : @"";
            NSString *backgroundColor = dic[@"backgroundColor"] ? [WXConvert NSString:dic[@"backgroundColor"]] : @"";
            NSInteger textSize = dic[@"textSize"] ? [WXConvert NSInteger:dic[@"textSize"]] : 0;
#warning ssss ios没有这两个参数
            NSInteger ems = dic[@"ems"] ? [WXConvert NSInteger:dic[@"ems"]] : 0;
            NSInteger lines = dic[@"lines"] ? [WXConvert NSInteger:dic[@"lines"]] : 0;
            BOOL singleLine = dic[@"singleLine"] ? [WXConvert BOOL:dic[@"singleLine"]] : YES;
            BOOL autoFocus = dic[@"autoFocus"] ? [WXConvert BOOL:dic[@"autoFocus"]] : NO;

            if (dic[@"maxLength"]) {
                [_inputTextLengthList addObject:dic[@"maxLength"]];
            }

            [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField *textField){
                textField.text = value;
                textField.keyboardType = [self keyboardType:type];
                textField.placeholder = placeholder;
                if (textSize > 0) {
                    textField.font = [UIFont systemFontOfSize:textSize];
                }
                if (textColor.length > 0) {
                    textField.textColor = [WXConvert UIColor:textColor];
                }
                if (backgroundColor.length > 0) {
                    textField.backgroundColor = [WXConvert UIColor:backgroundColor];
                }
                if (autoFocus) {
                    [textField becomeFirstResponder];
                }

                textField.delegate = self;
                textField.tag = AlertTag + i;
                [ws.inputTextFieldList addObject:textField];
            }];
        } else {
            isNewInput = YES;
            break;
        }
    }

    if (isNewInput) {
        [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [ws.inputTextFieldList addObject:textField];
        }];
    }

    //按钮
    for (int i = 0; i < buttons.count; i++) {
        id value = buttons[i];
        NSString *title = @"";
        NSString *type = @"";
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)value;
            title = dic[@"title"];
            type = dic[@"type"];

            if ([type isEqualToString:@"positive"]) {
                style = UIAlertActionStyleDestructive;
            } else if ([type isEqualToString:@"positive"]) {
                style = UIAlertActionStyleCancel;
            } else if ([type isEqualToString:@"positive"]) {
                style = UIAlertActionStyleDefault;
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            title = value;
        }

        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:ws.inputTextFieldList.count];
            for (UITextField *tf in ws.inputTextFieldList) {
                [data addObject:tf.text];
            }

            if (callback != nil) {
                NSDictionary *res = @{@"status":@"click", @"data":data, @"position":@(i), @"title":title};
                callback(res, NO);
            }

            [ws.inputTextFieldList removeAllObjects];
            [ws.inputTextLengthList removeAllObjects];
        }];
        [alertCtrl addAction:action];

        if (callback != nil) {
            NSDictionary *res2 = @{@"status":@"show", @"data":@[], @"position":@(i), @"title":title};
            callback(res2, YES);
        }
    }

    [[DeviceUtil getTopviewControler] presentViewController:alertCtrl animated:YES completion:cancelable ? (^{
        [alertCtrl alertTapDismiss];
    }) : nil];
}

- (UIKeyboardType)keyboardType:(NSString*)name
{
#warning ssss 完善datePickerView 选择时间
    if ([name isEqualToString:@"email"]) {
        return UIKeyboardTypeEmailAddress;
    } else if ([name isEqualToString:@"passnumber"] || [name isEqualToString:@"password"]) {
        return UIKeyboardTypeASCIICapable;
    } else if ([name isEqualToString:@"tel"]) {
        return UIKeyboardTypePhonePad;
    } else if ([name isEqualToString:@"url"]) {
        return UIKeyboardTypeURL;
    } else if ([name isEqualToString:@"number"]) {
        return UIKeyboardTypeNumberPad;
    }

    return UIKeyboardTypeDefault;
}

#pragma mark textFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger index = textField.tag - AlertTag;
    NSInteger maxLength = 0;
    if (index < _inputTextLengthList.count) {
        maxLength = [_inputTextLengthList[index] integerValue];
    }

    if (maxLength > 0 && range.location + range.length + string.length > maxLength) {
        return NO;
    }

    return YES;
}

@end
