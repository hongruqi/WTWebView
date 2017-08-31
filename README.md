# WTWebView

[![CI Status](http://img.shields.io/travis/lbrsilva-allin/WTWebView.svg?style=flat)](https://travis-ci.org/lbrsilva-allin/WTWebView)
[![Version](https://img.shields.io/cocoapods/v/WTWebView.svg?style=flat)](http://cocoapods.org/pods/WTWebView)
[![License](https://img.shields.io/cocoapods/l/WTWebView.svg?style=flat)](http://cocoapods.org/pods/WTWebView)
[![Platform](https://img.shields.io/cocoapods/p/WTWebView.svg?style=flat)](http://cocoapods.org/pods/WTWebView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WTWebView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "WTWebView"
```

## Author

lbrsilva-allin, hongru.qi@quvideo.com

## License

WTWebView is available under the MIT license. See the LICENSE file for more info.
##前言
WKWebView是在Apple的WWDC 2014发布，将原有UIWebViewDelegate与UIWebView重构成了14类与3个协议。
WKWebView，在iOS8和OS X 10.10开始支持，是为了解决UIWebView加载速度慢、占用内存大的问题。
在使用UIWebView加载网页的时候，会出现内存会无限增长，内存泄漏的问题。
WebKit中WKWebView控件的特性与使用方法，很好的解决了UIWebView存在的内存、加载速度等诸多问题。

## 一、WKWebView 特性

- 占用更少的内存
- Safari相同的JavaScript引擎
- 支持了更多的HTML5特性；
- 支持手势返回
- 滚动刷新率可达到60fps，堪比native

##webkit
![WebKit.png](http://upload-images.jianshu.io/upload_images/901318-ed61ead50e44c08d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
##OC与JS交互
WKWebview提供了API实现js交互 不需要借助JavaScriptCore或者webJavaScriptBridge。
###WKWebView
WKWebView对象显示交互式Web内容，例如针对应用内浏览器。 您可以使用WKWebView类将Web内容嵌入到您的应用程序中。 只需要创建一个WKWebView对象，并向其发送加载Web内容的请求。
**API**

初始化

```ObjC
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
```
常用方法

```ObjC
- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request;
- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (nullable WKNavigation *)goBack;
- (nullable WKNavigation *)goForward;
// Reloads the current page.
- (nullable WKNavigation *)reload;
- (nullable WKNavigation *)reloadFromOrigin;
```

###WKNavigtionDelegate

```ObjC
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

```

###WKUIDelegate

```ObjC
//1.创建一个新的WebVeiw
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
//2.WebVeiw关闭（9.0中的新方法）
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0);
//3.显示一个JS的Alert（与JS交互）
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
//4.弹出一个输入框（与JS交互的）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler;
//5.显示一个确认框（JS的）
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;
```

### JS调用OC
使用WKUserContentController实现js=>native交互。简单的说就是先注册约定好的方法，然后再调用。
**流程图：**

```flow
op=>operation: 配置环境
op1=>operation: 注册方法
op->op1
```

**代码：**

```ObjC
//配置环境，使用WKWebViewConfiguration
WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
configuration.allowsInlineMediaPlayback = YES;
WKUserContentController *userContentController = [[WKUserContentController alloc] init];
configuration.userContentController = userContentController;
//注册方法
／*
self.hybrid 是WTWebViewJSBridge类实例，处理js调用native方法
BridgeName js 方法名
*／
[userContentController addScriptMessageHandler:self.hybrid name:BridgeName];

```
**JS回调处理**

```ObjC
//WTWebViewJSBridge.m
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:BridgeName]) {
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            [self postMessage:message.body];
        }
    }
}
```  

###OC调用JS
这个简单多了，直接用WKWebview，evaluateJavaScript方法进行调用
```ObjC
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (self.webkit) {
        [self.webkit evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}
```



