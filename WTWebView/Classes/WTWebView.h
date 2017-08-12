//
//  WTWebView.h
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import <UIKit/UIKit.h>
@import JavaScriptCore;

static NSString *BridgeName = @"WebViewJavascriptBridge";

typedef NS_ENUM(NSInteger, WTFrame) {
    WTFrameUnKnown,
    WTFrameMainFrame,
    WTFrameIFrame
};

@protocol WTWebViewJavascriptBridge <JSExport>

- (void)postMessage:(id)message;

@end

@protocol WTWebViewDelegate;

@interface WTWebView : UIView

@property (nonatomic, weak) id <WTWebViewDelegate> delegate;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly, strong) NSURL *URL;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, copy) NSString *title;


- (instancetype)initWithFrame:(CGRect)frame;

- (void)loadURL:(NSURL *)URL;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;
- (void)evaluateJavaScript:(NSString *)javaScriptString;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError * error))completionHandler;
- (UIImage *)screenshot;
- (void)callJSFunc:(NSString *)func withArgs:(NSArray *)args;
- (NSString *)javaScriptStringEncodeValue:(NSString *)value;

@end

@protocol WTWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(WTWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType frame:(WTFrame)frame;
- (void)webViewDidStartLoad:(WTWebView *)webView;
- (void)webViewDidFinishLoad:(WTWebView *)webView;
- (void)webView:(WTWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)webview:(WTWebView *)webView didChangeProgress:(double)progress;
- (void)webview:(WTWebView *)webView didChangeTitle:(NSString *)title;

@end
