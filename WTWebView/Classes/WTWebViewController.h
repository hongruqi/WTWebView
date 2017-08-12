//
//  WTWebViewController.h
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import <UIKit/UIKit.h>
#import "WTWebView.h"

@protocol WTWebViewControllerDelegate;

@interface WTWebViewController : UIViewController

@property (nonatomic, assign) BOOL isLoginCallBack;
@property (nonatomic, assign) BOOL loginSuccessRefreshView;//defalut yes
@property (nonatomic, copy)   NSString* webPageTitle;
@property (nonatomic, strong) NSURL *homeURL;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, assign) CGFloat scrollOffSet;
@property (nonatomic, assign) BOOL isTabbar;
@property (nonatomic, assign) CGFloat tabbarHeigt;
@property (nonatomic, assign) BOOL hasBottomBar;
@property (nonatomic, strong) WTWebView *webView;
//每次链接打开一个新的webview页面标志,默认false
@property (nonatomic, assign) BOOL openNewWebView;

/**
 *  是否隐藏导航栏右侧按钮
 */
@property (nonatomic, assign) BOOL hideRightButton;
@property (nonatomic, assign) BOOL hideCloseButton;


- (instancetype)initWithURL:(NSURL*)URL;

/**
 * Navigate to the given URL.
 */
- (void)openURL:(NSURL*)URL;

- (void)reloadHomeUrl;

- (NSString *)getWebTitle;
- (void)addDelegate:(id<WTWebViewControllerDelegate>)delegate;
- (void)removeDelegate:(id<WTWebViewControllerDelegate>)delegate;


@end

@protocol WTWebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerDidAppear:(WTWebViewController *)webViewController;
- (BOOL)webViewControllerShouldClose:(WTWebViewController *)webViewController;

@end
