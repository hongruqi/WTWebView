//
//  WTHybridAction.h
//  WTWebView
//
//  Created by walter on 29/08/2017.
//

#import <Foundation/Foundation.h>

@class WTWebView;
@class WTWebViewController;

@protocol WTHybridAction <NSObject>

- (void)doActionWithParams:(NSDictionary *)params
                   webView:(WTWebView *)webView
            viewController:(WTWebViewController *)viewController
                  callback:(void(^)(NSError *error, id result))callback;
- (BOOL)reusable;
@end
