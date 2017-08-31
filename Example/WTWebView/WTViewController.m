//
//  WTViewController.m
//  WTWebView
//
//  Created by lbrsilva-allin on 08/11/2017.
//  Copyright (c) 2017 lbrsilva-allin. All rights reserved.
//

#import "WTViewController.h"
#import "WTWebViewController.h"

@interface WTViewController ()

@property (nonatomic, strong) UIButton *openWebView;

@end

@implementation WTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.openWebView = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2, 100, 50)];
    [self.openWebView setTitle:@"OpenWebVC" forState:UIControlStateNormal];
    [self.openWebView setBackgroundColor:[UIColor blackColor]];
    [self.openWebView setTintColor:[UIColor blueColor]];
    [self.openWebView addTarget:self action:@selector(openWebVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openWebView];

}

- (void)openWebVC
{
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    WTWebViewController *webVC = [[WTWebViewController alloc] initWithURL:url];
    webVC.hideRightButton = NO;
    webVC.webPageTitle = @"qihr";
    [webVC setHideCloseButton:NO];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
