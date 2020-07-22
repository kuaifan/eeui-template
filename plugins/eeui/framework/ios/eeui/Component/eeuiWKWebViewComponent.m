//
//  eeuiWKWebViewComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiWKWebViewComponent.h"
#import "DeviceUtil.h"
#import "YHWebViewProgressView.h"
#import "eeuiStorageManager.h"
#import "JSCallCommon.h"

@interface eeuiWKWebView : WKWebView
@end

@implementation eeuiWKWebView


@end

@interface eeuiWKWebViewComponent() <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *customUserAgent;
@property (nonatomic, assign) CGFloat webContentHeight;
@property (nonatomic, assign) BOOL isShowProgress;
@property (nonatomic, assign) BOOL isScrollEnabled;
@property (nonatomic, assign) BOOL isEnableApi;
@property (nonatomic, assign) BOOL isHeightChanged;
@property (nonatomic, assign) BOOL isReceiveMessage;
@property (nonatomic, assign) BOOL isTransparency;
@property (nonatomic, strong) JSCallCommon* JSCall;
@property (strong, nonatomic) YHWebViewProgressView *progressView;

@property (nonatomic, assign) BOOL isRemoveObserver;

@end

@implementation eeuiWKWebViewComponent

WX_EXPORT_METHOD(@selector(setContent:))
WX_EXPORT_METHOD(@selector(setUrl:))
WX_EXPORT_METHOD(@selector(setJavaScript:))
WX_EXPORT_METHOD(@selector(setProgressbarVisibility:))
WX_EXPORT_METHOD(@selector(setScrollEnabled:))
WX_EXPORT_METHOD(@selector(canGoBack:))
WX_EXPORT_METHOD(@selector(goBack:))
WX_EXPORT_METHOD(@selector(canGoForward:))
WX_EXPORT_METHOD(@selector(goForward:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _url = @"";
        _content = @"";
        _userAgent = @"";
        _customUserAgent = @"";
        _isShowProgress = YES;
        _isScrollEnabled = YES;
        _isEnableApi = YES;
        _isTransparency = NO;
        _isHeightChanged = [events containsObject:@"heightChanged"];
        _isReceiveMessage = [events containsObject:@"receiveMessage"];

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
    }
    return self;
}

- (WKWebView*)loadView
{
    //设置userAgent
    __block NSString *originalUserAgent = nil;
    if (_customUserAgent.length > 0) {
        originalUserAgent = _customUserAgent;
    }else{
        eeuiStorageManager *storage = [eeuiStorageManager sharedIntstance];
        originalUserAgent = [storage getCachesString:@"__system:originalUserAgent" defaultVal:@""];
        if (![originalUserAgent containsString:@";ios_kuaifan_eeui/"]) {
            WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                if (!error) {
                    NSString *versionName = (NSString*)[[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleShortVersionString"];
                    originalUserAgent = [NSString stringWithFormat:@"%@;ios_kuaifan_eeui/%@", result, versionName];
                    if (_userAgent.length > 0) {
                        originalUserAgent = [NSString stringWithFormat:@"%@/%@", originalUserAgent, _userAgent];
                    }
                    [storage setCachesString:@"__system:originalUserAgent" value:originalUserAgent expired:0];
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:originalUserAgent, @"UserAgent", nil];
                    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
                }
            }];
        }
        if (_userAgent.length > 0) {
            originalUserAgent = [NSString stringWithFormat:@"%@/%@", originalUserAgent, _userAgent];
        }
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:originalUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    //初始化浏览器对象
    return [[eeuiWKWebView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;

    self.progressView = [[YHWebViewProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 2)];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.progressView.hidden = !_isShowProgress;
    [self.progressView useWkWebView:webView];
    [self.view addSubview:self.progressView];

    if (_isTransparency) {
        webView.opaque = NO;
        webView.backgroundColor = [UIColor clearColor];
    }

    ((UIScrollView *)[webView.subviews objectAtIndex:0]).scrollEnabled = _isScrollEnabled;

    webView.UIDelegate = self;
    webView.navigationDelegate  = self;

    if (self.JSCall == nil) {
        self.JSCall = [[JSCallCommon alloc] init];
    }

    if (_url.length > 0) {
        if (![_url hasPrefix:@"http://"] && ![_url hasPrefix:@"https://"]) {
            _url = [NSString stringWithFormat:@"http://%@", _url];
        }
        NSURL *url = [NSURL URLWithString:_url];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }

    if (_content.length > 0) {
        [self setContent:_content];
    }

    [self fireEvent:@"ready" params:nil];

    if (_isHeightChanged) {
        [webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    [webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) viewWillUnload
{
    [super viewWillUnload];
    if (self.JSCall != nil) {
        [self.JSCall viewDidUnload];
        self.JSCall = nil;
    }
    [self removeObserver];
}

- (void) dealloc
{
    [self removeObserver];
}

- (void) removeObserver
{
    if (_isRemoveObserver != YES) {
        _isRemoveObserver = YES;
        eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
        if (_isHeightChanged) {
            [webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
        }
        [webView removeObserver:self forKeyPath:@"URL" context:nil];
        [webView removeObserver:self forKeyPath:@"title" context:nil];
        [self.progressView outWkWebView:webView];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    eeuiWKWebView *webView = (eeuiWKWebView*) self.view;
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat webViewHeight = webView.scrollView.contentSize.height;
        CGFloat contentHeight = 750 * 1.0 / [UIScreen mainScreen].bounds.size.width * webViewHeight;
        if (contentHeight != _webContentHeight) {
            _webContentHeight = contentHeight;
            [self fireEvent:@"heightChanged" params:@{@"height":@(contentHeight)}];
        }
    }else if ([keyPath isEqualToString:@"URL"]) {
        NSString *url = webView.URL.absoluteString;
        [self fireEvent:@"stateChanged" params:@{@"status":@"url", @"title":@"", @"url":(url==nil?@"":url), @"errCode":@"", @"errMsg":@"", @"errUrl":@""}];
    }else if ([keyPath isEqualToString:@"title"]) {
        NSString *title = webView.title;
        [self fireEvent:@"stateChanged" params:@{@"status":@"title", @"title":(title==nil?@"":title), @"url":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@""}];
    }
}

- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
}

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"content"]) {
        _content = [WXConvert NSString:value];
        if (isUpdate) {
            [self setContent:_content];
        }
    } else if ([key isEqualToString:@"url"]) {
        _url = [WXConvert NSString:value];
        if (isUpdate) {
            [self setUrl:_url];
        }
    } else if ([key isEqualToString:@"progressbarVisibility"]) {
        _isShowProgress = [WXConvert BOOL:value];
        if (isUpdate) {
            [self setProgressbarVisibility:_isShowProgress];
        }
    } else if ([key isEqualToString:@"scrollEnabled"]) {
        _isScrollEnabled = [WXConvert BOOL:value];
        if (isUpdate) {
            [self setScrollEnabled:_isScrollEnabled];
        }
    } else if ([key isEqualToString:@"enableApi"]) {
        _isEnableApi = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"userAgent"]) {
        _userAgent = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"customUserAgent"]) {
        _customUserAgent = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"transparency"]) {
        _isTransparency = [WXConvert BOOL:value];
        if (isUpdate) {
            [self setTransparency:_isTransparency];
        }
    }
}

//开始加载网页
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self fireEvent:@"stateChanged" params:@{@"status":@"start", @"title":@"", @"url":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@""}];
}

//网页加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:( WKNavigation *)navigation
{
    [self fireEvent:@"stateChanged" params:@{@"status":@"success", @"title":@"", @"url":@"", @"errCode":@"", @"errMsg":@"", @"errUrl":@""}];
    if (self.JSCall != nil) {
        [self.JSCall setJSCallAll:self webView:webView];
        [self.JSCall addRequireModule:webView];
    }
}

//网页加载错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error) {
        NSString *code = [NSString stringWithFormat:@"%ld", (long)error.code];
        NSString *msg = [NSString stringWithFormat:@"%@", error.description];
        [self fireEvent:@"stateChanged" params:@{@"status":@"error", @"title":@"", @"url":@"", @"errCode":code, @"errMsg":msg, @"errUrl":_url}];
    }
}

// 新窗口打开
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)response decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)action decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (action.navigationType == WKNavigationTypeLinkActivated) {

    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    if (_isEnableApi == YES && self.JSCall != nil && [self.JSCall isJSCall:prompt]) {
        completionHandler([self.JSCall onJSCall:webView JSText:prompt]);
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) { }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [[DeviceUtil getTopviewControler] presentViewController:alertController animated:YES completion:nil];
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [[DeviceUtil getTopviewControler] presentViewController:alertController animated:YES completion:nil];
}

// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [[DeviceUtil getTopviewControler] presentViewController:alertController animated:YES completion:nil];
}

//设置浏览器内容
- (void)setContent:(NSString*)content
{
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
    if (![content containsString:@"</html>"] && ![content containsString:@"</HTML>"]) {
        NSString *html = @"<html><header><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no'><style type='text/css'>{commonStyle}</style></header><body>{content}</body></html>";
        html = [html stringByReplacingOccurrencesOfString:@"{commonStyle}" withString:[DeviceUtil webCommonStyle]];
        content = [html stringByReplacingOccurrencesOfString:@"{content}" withString:content];
    }
    [webView loadHTMLString:content baseURL:nil];
}

//设置浏览器地址
- (void)setUrl:(NSString*)urlStr
{
    eeuiWKWebView *webView = (eeuiWKWebView*) self.view;
    _url = urlStr;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

//设置JavaScript
- (void)setJavaScript:(NSString*)script
{
    eeuiWKWebView *webView = (eeuiWKWebView*) self.view;
    NSString *javaScript = [@";(function(){?})();" stringByReplacingOccurrencesOfString:@"?" withString:script];
    [webView evaluateJavaScript:javaScript completionHandler:nil];
}

//是否显示进度条
- (void)setProgressbarVisibility:(BOOL)var
{
    _isShowProgress = var;
    if (_isShowProgress == NO) {
        [self.progressView setProgress:1.0f];
    }
    self.progressView.hidden = !_isShowProgress;
}

//设置是否透明背景
- (void)setTransparency:(BOOL)var
{
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
    if (var) {
        webView.opaque = NO;
        webView.backgroundColor = [UIColor clearColor];
    }else{
        webView.opaque = YES;
        webView.backgroundColor = [UIColor whiteColor];
    }
}

//设置是否允许滚动
- (void)setScrollEnabled:(BOOL)var
{
    _isScrollEnabled = var;
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
    ((UIScrollView *)[webView.subviews objectAtIndex:0]).scrollEnabled = var;
}

//是否可以后退
- (void)canGoBack:(WXModuleKeepAliveCallback)callback
{
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
    callback(@(webView.canGoBack), NO);
}

//后退并返回是否后退成功
- (void)goBack:(WXModuleKeepAliveCallback)callback
{
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;

    if (webView.canGoBack) {
        [webView goBack];
    }
    callback(@(webView.canGoBack), NO);
}

//是否可以前进
- (void)canGoForward:(WXModuleKeepAliveCallback)callback
{
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
    callback(@(webView.canGoForward), NO);
}

//前进并返回是否前进成功
- (void)goForward:(WXModuleKeepAliveCallback)callback
{
    eeuiWKWebView *webView = (eeuiWKWebView*)self.view;
    if (webView.canGoForward) {
        [webView goForward];
    }
    callback(@(webView.canGoForward), NO);
}

//网页向组件发送参数
- (void)sendMessage:(id) message
{
    if (_isReceiveMessage) {
        [self fireEvent:@"receiveMessage" params:@{@"message": message}];
    }
}


@end
