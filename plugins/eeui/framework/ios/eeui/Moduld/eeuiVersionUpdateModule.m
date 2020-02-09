//
//  eeuiVersionUpdateModule.m
//  Pods
//
//  Created by 高一 on 2019/12/15.
//

#import "eeuiVersionUpdateModule.h"
#import "eeuiNewPageManager.h"
#import "eeuiViewController.h"
#import "Cloud.h"

@implementation eeuiVersionUpdateModule

@synthesize weexInstance;

WX_EXPORT_METHOD_SYNC(@selector(getTitle))
WX_EXPORT_METHOD_SYNC(@selector(getContent))
WX_EXPORT_METHOD_SYNC(@selector(canCancel))
WX_EXPORT_METHOD(@selector(closeUpdate))
WX_EXPORT_METHOD(@selector(startUpdate))

- (NSString*)getTitle
{
    NSDictionary *data = [Cloud getUpdateVersionData];
    return [WXConvert NSString:data[@"title"]];
}

- (NSString*)getContent
{
    NSDictionary *data = [Cloud getUpdateVersionData];
    return [WXConvert NSString:data[@"content"]];
}

- (BOOL)canCancel
{
    NSDictionary *data = [Cloud getUpdateVersionData];
    return [WXConvert BOOL:data[@"canCancel"]];
}

- (void)closeUpdate
{
    NSDictionary *viewData = [[eeuiNewPageManager sharedIntstance] getViewData];
    for (NSString *pageName in viewData) {
        id view = [viewData objectForKey:pageName];
        if ([view isKindOfClass:[eeuiViewController class]]) {
            eeuiViewController *vc = (eeuiViewController*)view;
            [vc hideFixedVersionUpdate];
        }
    }
}

- (void)startUpdate
{
    NSDictionary *data = [Cloud getUpdateVersionData];
    NSString *url = data[@"url"];
    if (url == nil) {
        return;
    }
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        [[eeuiNewPageManager sharedIntstance] openWeb:url];
    }
}

@end
