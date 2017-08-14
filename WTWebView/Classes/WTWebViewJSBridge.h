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

+ (void)registerHybridToolWithName:(NSString *)tooName toolClass:(Class)toolClass;
+ (BOOL)checkToolExistsWithName:(NSString *)toolName;
- (instancetype)initWithWebView:(WTWebView *)webView viewController:(WTWebViewController *)viewController;

@end
