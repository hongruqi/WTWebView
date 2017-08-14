//
//  WTWebViewJSBridge.m
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import "WTWebViewJSBridge.h"
#import "WTWebView.h"
#import "WTWebViewController.h"


@interface WTWebViewJSBridge()<WTWebViewJavascriptBridge>

@property (nonatomic, weak) WTWebView *webView;
@property (nonatomic, weak) WTWebViewController *viewController;

@end

@implementation WTWebViewJSBridge

- (instancetype)initWithWebView:(WTWebView *)webView viewController:(WTWebViewController *)viewController
{
    self = [super init];
    if (self) {
        self.webView = webView;
        self.viewController = viewController;
    }
    return self;
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:BridgeName]) {
        if ([message.body isKindOfClass:[NSDictionary class]]) {
//            [self postMessage:message.body];
        }
    }
}
@end
