//
//  YHWebViewProgress.m
//  YohoExplorerDemo
//
//  Created by gaoqiang xu on 3/25/15.
//  Copyright (c) 2015 gaoqiang xu. All rights reserved.
//

#import "YHWebViewProgress.h"

NSString *completeRPCURLPath = @"/yhwebviewprogressproxy/complete";

static const float YHWebViewProgressInitialValue = 0.7f;
static const float YHWebViewProgressInteractiveValue = 0.9f;
static const float YHWebViewProgressFinalProgressValue = 0.9f;

@interface YHWebViewProgress ()
@property (nonatomic) NSUInteger loadingCount;
@property (nonatomic) NSUInteger maxLoadCount;
@property (strong, nonatomic) NSURL *currentURL;
@property (nonatomic) BOOL interactive;

@property (nonatomic) float progress;

@end

@implementation YHWebViewProgress

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    
    return self;
}

- (void)dealloc
{
    
}

- (void)startProgress
{
    if (self.progress < YHWebViewProgressInitialValue) {
        [self setProgress:YHWebViewProgressInitialValue];
    }
}

- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = self.interactive?YHWebViewProgressFinalProgressValue:YHWebViewProgressInteractiveValue;
    float remainPercent = (float)self.loadingCount/self.maxLoadCount;
    float increment = (maxProgress-progress) * remainPercent;
    progress += increment;
    progress = fminf(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.f];
}

- (void)setProgress:(float)progress
{
    if (progress > _progress || progress == 0) {
        _progress = progress;
        
        if (self.progressView) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

- (void)reset
{
    self.maxLoadCount = self.loadingCount = 0;
    self.interactive = NO;
    [self setProgress:0.f];
}

- (BOOL)checkIfRPCURL:(NSURLRequest *)request
{
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return YES;
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL ret = YES;
    
    if (self.webViewProxy) {
        if ([self checkIfRPCURL:request]) {
            return NO;
        }
        
        if ([self.webViewProxy respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            ret = [self.webViewProxy webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
        self.currentURL = request.URL;
        [self reset];
    }
    
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewProxy webViewDidStartLoad:webView];
    }
    
    self.loadingCount++;
    
    self.maxLoadCount = fmax(self.loadingCount, self.loadingCount);
    
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewProxy webViewDidFinishLoad:webView];
    }
    
    self.loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = interactive;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);",
                                       webView.request.mainDocumentURL.scheme,
                                       webView.request.mainDocumentURL.host,
                                       completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = self.currentURL && [self.currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewProxy webView:webView didFailLoadWithError:error];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

#pragma mark - Method Forwarding
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    if ([self.webViewProxy respondsToSelector:aSelector]) {
        return YES;
    }
    
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if (self.webViewProxy && [self.webViewProxy respondsToSelector:aSelector]) {
            return [(NSObject *)self.webViewProxy methodSignatureForSelector:aSelector];
        }
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.webViewProxy];
    }
}

@end
