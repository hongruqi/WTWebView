//
//  WTWebView.m
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import "WTWebView.h"
@import WebKit;
#import "WTWebViewJSBridge.h"
#import "UIView+WTExtend.h"

@interface WTWebView()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webkit;
@property (nonatomic, strong) WTWebViewJSBridge *hybrid;
@property (nonatomic, strong) NSURL *loadingURL;
@property (nonatomic, strong) JSContext *jsContext;

// 记录首次加载耗时
@property (nonatomic, strong) NSDate *startLoadingDate;
@property (nonatomic, assign) BOOL firstLoadTimeLogged;
@property (nonatomic, assign) BOOL hybridEnabled;

@end


@implementation WTWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#ifdef DEBUG
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
#endif
//        [self updateUserAgent];
        [self createWebKit];
        [self addSubview:self.webkit];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"WTWebView dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _jsContext[BridgeName] = nil;
    [_webkit.configuration.userContentController removeScriptMessageHandlerForName:BridgeName];
    [_webkit removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webkit removeObserver:self forKeyPath:@"title"];
    _webkit.scrollView.delegate = nil;
}

#pragma mark - public methods
- (void)loadURL:(NSURL *)URL
{
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadRequest:(NSURLRequest *)request
{
    self.loadingURL = request.URL;
    NSMutableURLRequest *mRequest = [request isKindOfClass:[NSMutableURLRequest class]] ? request : [request mutableCopy];
    [mRequest setValue:@"Sat, 29 Oct 1994 19:43:31 GMT" forHTTPHeaderField:@"If-Modified-Since"];
    request = mRequest;
    
    if (self.webkit) {
        NSLog(@"---- load request %@", request.URL);
        [self.webkit loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if (self.webkit) {
        [self.webkit loadHTMLString:string baseURL:baseURL];
    }
}

- (void)reload
{
    if (self.webkit) {
        [self.webkit reload];
    }
}

- (void)stopLoading
{
    if (self.webkit) {
        [self.webkit stopLoading];
    }
}

- (void)goBack
{
    if (self.webkit) {
        [self.webkit goBack];
    }
}

- (void)goForward
{
    if (self.webkit) {
        [self.webkit goForward];
    }
}

- (BOOL)canGoBack
{
    return self.webkit.canGoBack;
}

- (NSString *)title
{
    return self.webkit.title;
}

- (UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (WKWebView *)createWebKit
{
    if(_webkit == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = YES;
        _webkit = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
        _webkit.UIDelegate = self;
        _webkit.navigationDelegate = self;
        _webkit.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [_webkit addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_webkit addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return _webkit;
}

#pragma mark - JS
- (void)evaluateJavaScript:(NSString *)javaScriptString
{
    [self evaluateJavaScript:javaScriptString completionHandler:nil];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (self.webkit) {
        [self.webkit evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

- (void)callJSFunc:(NSString *)funcName withArgs:(NSArray *)args
{
    NSMutableString *js = funcName.mutableCopy;
    [js appendString:@"("];
    NSMutableArray *values = @[].mutableCopy;
    [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = @"";
        if ([obj isKindOfClass:[NSString class]]) {
            value = [self javaScriptStringEncodeValue:obj];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            value = [NSString stringWithFormat:@"%@", obj];
        } else if ([obj isKindOfClass:[NSArray class]] ||
                   [obj isKindOfClass:[NSDictionary class]]) {
            value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
        } else if ([obj isKindOfClass:[NSNull class]]) {
            value = @"null";
        }
        [values addObject:value];
    }];
    [js appendString:[values componentsJoinedByString:@","]];
    [js appendString:@")"];
    [self evaluateJavaScript:js completionHandler:nil];
}

- (NSString *)javaScriptStringEncodeValue:(NSString *)value
{
    NSMutableString *result = value.mutableCopy;
    [result replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\r" withString:@"\\r" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\f" withString:@"\\f" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\u2028" withString:@"\\u2028" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\u2029" withString:@"\\u2029" options:0 range:NSMakeRange(0, result.length)];
    return [NSString stringWithFormat:@"\"%@\"", result];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webkit) {
            if ([self.delegate respondsToSelector:@selector(webview:didChangeProgress:)]) {
                [self.delegate webview:self didChangeProgress:self.webkit.estimatedProgress];
            }
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webkit) {
            if ([self.delegate respondsToSelector:@selector(webview:didChangeTitle:)]) {
                [self.delegate webview:self didChangeTitle:self.webkit.title];
            }
        }
    }
}

# pragma mark - webkit delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL allow = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:frame:)]) {
        allow = [self.delegate webView:self shouldStartLoadWithRequest:navigationAction.request navigationType:(UIWebViewNavigationType)navigationAction.navigationType frame:navigationAction.sourceFrame.isMainFrame ? WTFrameMainFrame : WTFrameIFrame];
    }
    if (allow) {
        if (navigationAction.sourceFrame.isMainFrame) {
//            [self _webkitWillLoadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self logWebViewLoadStartWithURL:webView.URL];
    
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.hybrid) {
        self.jsContext[BridgeName] = self.hybrid;
    }
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
    
    [self logWebViewLoadFinishWithURL:webView.request.URL];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
    
    [self logWebViewLoadFinishWithURL:webView.URL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSString *title = message;
    if (message.length > 6) {
        title = @"提示";
    } else {
        message = nil;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSString *title = message;
    if (message.length > 6) {
        title = @"提示";
    } else {
        message = nil;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(NO);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    NSString *title = prompt;
    if (prompt.length > 6) {
        title = @"提示";
    } else {
        prompt = nil;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:prompt
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *alertTextField;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
        alertTextField = textField;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(nil);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(alertTextField.text);
                                                      }]];
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark - time log

- (void)applicationDidEnterBackground
{
    // disable time log after app entered background
    self.firstLoadTimeLogged = YES;
}

- (void)logWebViewLoadStartWithURL:(NSURL *)url
{
    if (self.firstLoadTimeLogged) {
        return;
    }
    
    self.startLoadingDate = [NSDate date];
}

- (void)logWebViewLoadFinishWithURL:(NSURL *)url
{
    if (self.firstLoadTimeLogged) {
        return;
    }
    
    self.firstLoadTimeLogged = YES;
    
    NSTimeInterval elapsed = -[self.startLoadingDate timeIntervalSinceNow];
    
    NSLog(@"h5_performance: load:%@,url:%@,", @((NSInteger)(elapsed * 1000)), url.absoluteString);
    
}



@end
