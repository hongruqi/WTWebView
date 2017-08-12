//
//  NSBundle+WTWebView.m
//  WTWebView
//
//  Created by walter on 11/08/2017.
//

#import "NSBundle+WTWebView.h"
#import "WTWebView.h"

@implementation NSBundle (WTWebView)

+ (NSBundle *)wt_webViewBundle {
    return [self bundleWithURL:[self wt_webViewBundleURL]];
}

+ (NSURL *)wt_webViewBundleURL {
    NSBundle *bundle = [NSBundle bundleForClass:[WTWebView class]];
    return [bundle URLForResource:@"WTWebView" withExtension:@"bundle"];
}

@end
