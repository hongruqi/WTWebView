//
//  WTWebViewController.m
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import "WTWebViewController.h"
#import "WTNavigationBar.h"
#import "UIView+WTExtend.h"

@interface WTWebViewController ()<UIScrollViewDelegate, WTWebViewDelegate>
{
    NSURL *_loadingURL;
    NSURL *_homeURL;
}

@property (nonatomic, assign) BOOL enablePageJump; // 允许跳转标识
@property (nonatomic, assign) BOOL webViewDidFinishLoad;
@property (nonatomic, assign) BOOL showCloseButton;
@property (nonatomic, assign) BOOL showLeftButton;
@property (nonatomic, assign) BOOL defautlRefresh; //默认是否使用下拉刷新
@property (nonatomic, strong) WTNavigationBar *navigationBar;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, copy) NSString *currentURLPrefix;
@property (nonatomic, strong) NSMutableArray<id<WTWebViewControllerDelegate>> *delegates;

@end

@implementation WTWebViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _homeURL = URL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.titleLabel.text = _webPageTitle;
    
    if (!self.hideRightButton) {
        [self.navigationBar setBarRightButtonItem:self selector:@selector(shareAction:) imageKey:@"ic_c2c_share"];
    }
    
    if (!self.hideCloseButton) {
        [self.navigationBar setBarCloseTextButtonItem:self selector:@selector(popViewController) title:@"关闭"];
        self.navigationBar.closeButton.titleLabel.textColor = [UIColor redColor];
        [self.navigationBar.closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.titleLabel.textColor = [UIColor blackColor];
    CGFloat ww = self.view.width;
    CGFloat wh = self.view.viewHeight;
    
    CGFloat statusBarHeight = 20;
    
    CGRect frame;
    
    if (self.isTabbar) {
        self.navigationBar.hidden = YES;
        frame = CGRectMake(0, statusBarHeight, ww, wh-statusBarHeight-self.tabbarHeigt);
    } else if (self.hasBottomBar) {
        frame = CGRectMake(0, self.navigationBar.height, ww, wh-self.navigationBar.height-self.tabbarHeigt);
    } else {
        frame = CGRectMake(0, self.navigationBar.height, ww, wh-self.navigationBar.height);
    }

    self.webView = [[WTWebView alloc] initWithFrame:frame];

    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    _progressView = [[UIView alloc] init];
    if (self.isTabbar) {
        _progressView.frame = CGRectMake(0, statusBarHeight, 0, 3);
    }else {
        _progressView.frame = CGRectMake(0, self.navigationBar.height, 0, 3);
    }
    _progressView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_progressView];
    
    // Do any additional setup after loading the view.
    if (_homeURL) {
        [self openURL:_homeURL];
    }
    
    [self.view bringSubviewToFront:self.navigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    // 使用黑色的返回
    if ([self.navigationController.viewControllers count] > 1) {
        // 多于一级的时候，再创建返回按钮
        [self.navigationBar setBarLeftButtonItem:self selector:@selector(popToPreviousViewController) imageKey:@"navigationbar_btn_back"];
    }
    
    if (self.showCloseButton) {
        [self.navigationBar setBarCloseTextButtonItem:self selector:@selector(closeButtonTouched) title:@"关闭"];
    }
    
    if (self.showLeftButton) {
        [self addModalCloseButton];
    }
    
}

- (void)addModalCloseButton {
    [self.navigationBar setBarLeftButtonItem:self
                                    selector:@selector(closeWebView)
                                    imageKey:@"navigationbar_btn_close"];
}


- (void)closeWebView {
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)shareAction:(id) params {
}

- (void)addDelegate:(id<WTWebViewControllerDelegate>)delegate
{
    if (!self.delegates) {
        self.delegates = @[].mutableCopy;
    }
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<WTWebViewControllerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}
- (void)popToPreviousViewController
{
//    __block BOOL shouldClose = YES;
//    [self.delegates bk_each:^(id<WTWebViewControllerDelegate> delegate) {
//        if ([delegate respondsToSelector:@selector(webViewControllerShouldClose:)]) {
//            if (![delegate webViewControllerShouldClose:self]) {
//                shouldClose = NO;
//            }
//        }
//    }];
//    if (!shouldClose) {
//        return;
//    }
    
    if (self.webView.canGoBack) {
        [self.webView goBack];
        self.navigationBar.closeButton.hidden = NO;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openURL:(NSURL*)URL {
    [self.webView loadURL:URL];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(WTWebView *)webView
{
    self.webViewDidFinishLoad = YES;
    self.webPageTitle = [self getWebTitle];
    if (self.webPageTitle.length) {
        self.navigationBar.titleLabel.text = self.webPageTitle;
    }
    
    _loadingURL = self.webView.URL;
    _enablePageJump = YES;

}

- (void)webview:(WTWebView *)webView didChangeProgress:(double)progress
{
    if (progress == 0.0) {
        _progressView.viewWidth = 0;
        [UIView animateWithDuration:0.27 animations:^{
            _progressView.alpha = 1.0;
        }];
    }
    if (progress == 1.0) {
        [UIView animateWithDuration:0.27 delay:0 options:0 animations:^{
            _progressView.alpha = 0.0;
        } completion:nil];
    }
    
    _progressView.viewWidth = progress * self.view.viewWidth;
}

- (NSString *)getWebTitle
{
    return self.webView.title ?: self.webPageTitle;
}

- (WTNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[WTNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    }
    
    return _navigationBar;
}

@end
