//
//  NSString+BHURLHelper.m
//  BHDemo
//
//  Created by QiaoBaHui on 2018/9/24.
//  Copyright © 2018年 QiaoBaHui. All rights reserved.
//

#import "NSString+BHURLHelper.h"

@implementation NSString (BHURLHelper)

- (NSString *)addParameters:(NSDictionary *)parameters {
	NSMutableArray *parts = [NSMutableArray array];

	for (NSString *key in [parameters allKeys]) {
		NSString *part = [NSString stringWithFormat:@"%@=%@", key, [parameters valueForKey:key]];
		[parts addObject: part];
	}

	NSString *parametersString= [parts componentsJoinedByString:@"&"];

	NSString *addSuffixString = @"";
	if ([[self parseURLParameters] count] > 0) {
		addSuffixString = [NSString stringWithFormat:@"%@%@", @"&", parametersString]; // 原链接已经存在参数, 则用"&"直接拼接参数;
	} else {
		addSuffixString = [NSString stringWithFormat:@"%@%@", @"?", parametersString]; // 原链接不存在参数, 则先添加"?", 再拼接参数;
	}

	return [self stringByAppendingString:addSuffixString];
}

- (NSString *)deleteParameterOfKey:(NSString *)key; {
	NSString *finalString = [NSString string];

	if ([self containsString:key]) {
		NSMutableString *mutStr = [NSMutableString stringWithString:self];
		NSArray *strArray = [mutStr componentsSeparatedByString:key];

		NSMutableString *firstStr = [strArray objectAtIndex:0];
		NSMutableString *lastStr = [strArray lastObject];

		NSRange characterRange = [lastStr rangeOfString:@"&"];

		if (characterRange.location != NSNotFound) {
			NSArray *lastArray = [lastStr componentsSeparatedByString:@"&"];
			NSMutableArray *mutArray = [NSMutableArray arrayWithArray:lastArray];
			[mutArray removeObjectAtIndex:0];

			NSString *modifiedStr = [mutArray componentsJoinedByString:@"&"];
			finalString = [[strArray objectAtIndex:0]stringByAppendingString:modifiedStr];
		} else {
			finalString = [firstStr substringToIndex:[firstStr length] - 1];
		}
	} else {
		finalString = self;
	}

	return finalString;
}

- (NSString *)modifyParameterOfKey:(NSString *)key toValue:(NSString *)toValue {
	NSDictionary *parameters = [self parseURLParameters];

	if (parameters.count > 0 && [parameters.allKeys containsObject:key]) {
		[parameters setValue:toValue forKey:key];
	}

	NSString *urlString = self;
	for (NSString *key in parameters.allKeys) {
		urlString =	[urlString deleteParameterOfKey:key];
	}

	return [urlString addParameters:parameters];
}

- (NSMutableDictionary *)parseURLParameters {
	NSRange range = [self rangeOfString:@"?"];
	if (range.location == NSNotFound) return nil;

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

	NSString *parametersString = [self substringFromIndex:range.location + 1];
	if ([parametersString containsString:@"&"]) {
		NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];

		for (NSString *keyValuePair in urlComponents) {
			NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
			NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
			NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

			if (key == nil || value == nil) {
				continue;
			}

			id existValue = [parameters valueForKey:key];
			if (existValue != nil) {
				if ([existValue isKindOfClass:[NSArray class]]) {
					NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
					[items addObject:value];
					[parameters setValue:items forKey:key];
				} else {
					[parameters setValue:@[existValue, value] forKey:key];
				}
			} else {
				[parameters setValue:value forKey:key];
			}
		}
	} else {
		NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
		if (pairComponents.count == 1) {
			return nil;
		}

		NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
		NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

		if (key == nil || value == nil) {
			return nil;
		}
		[parameters setValue:value forKey:key];
	}

	return parameters;
}

@end
