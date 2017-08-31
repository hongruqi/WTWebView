//
//  WTWebViewJSBridge.h
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import <Foundation/Foundation.h>
@import WebKit;

@class WTWebView, WTWebViewController;

@interface WTWebViewJSBridge : NSObject<WKScriptMessageHandler>

+ (void)registerHybridActionWithName:(NSString *)actionName actionClass:(Class)actionClass;
+ (BOOL)checkActionExistsWithName:(NSString *)actionName;
- (instancetype)initWithWebView:(WTWebView *)webView viewController:(WTWebViewController *)viewController;

@end
