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
#import "WTHybridAction.h"

static NSMutableDictionary *actionClasses;
static NSString *const WTHybridActionCallback = @"WebViewJavascriptBridge_actionDidFinish";

@interface WTWebViewJSBridge()<WTWebViewJavascriptBridge>

@property (nonatomic, weak) WTWebView *webView;
@property (nonatomic, weak) WTWebViewController *viewController;
@property (nonatomic, strong) NSMutableArray<id<WTHybridAction>> *actions;

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

+ (void)registerHybridActionWithName:(NSString *)actionName actionClass:(Class)actionClass
{
    if (!actionClasses) {
        actionClasses = @{}.mutableCopy;
    }
    
    actionClasses[actionName] = actionClass;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:BridgeName]) {
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            [self postMessage:message.body];
        }
    }
}

+ (BOOL)checkActionExistsWithName:(NSString *)actionName
{
    return actionClasses[actionName] != nil;
}

- (void)postMessage:(id)message
{
    if (!self.webView || !self.viewController) {
        return;
    }
    
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *messageDict = message;
        NSUInteger mId = [messageDict[@"id"] integerValue];
        NSString *target = messageDict[@"target"];
        if (!target || ![target isKindOfClass:[NSString class]]) {
            return;
        }
        NSDictionary *params = messageDict[@"data"];
        if (params && ![params isKindOfClass:[NSDictionary class]]) {
            return;
        }
        Class actionClass = actionClasses[target];
        if (!actionClass) {
            return;
        }
        id<WTHybridAction> action = [[actionClass alloc] init];
        if (!action) {
            return;
        }
        
        [self.actions addObject:action];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf || !weakSelf.webView || !weakSelf.viewController) {
                return ;
            }
            [action doActionWithParams:params webView:self.webView viewController:self.viewController callback:^(NSError *error, id result) {
                if (error) {
                    NSDictionary *errDict = @{@"code": @(error.code)};
                    [weakSelf _actionDidFinishWithMessageId:@(mId) error:errDict result:nil];
                } else {
                    [self _actionDidFinishWithMessageId:@(mId) error:nil result:result];
                }
                if (![action respondsToSelector:@selector(reusable)] || ![action reusable]) {
                    [self.actions removeObject:action];
                }
            }];
        });
    }
    
}

- (void)_actionDidFinishWithMessageId:(id)mId error:(id)error result:(id)result
{
    NSArray *args = @[mId, (error ?: [NSNull null]), (result ?: [NSNull null])];
    [self.webView callJSFunc:WTHybridActionCallback withArgs:args];
}

@end
