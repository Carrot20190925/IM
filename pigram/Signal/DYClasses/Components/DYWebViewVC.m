//
//  DYWebViewVC.m
//  ID贷
//
//  Created by apple on 2019/6/22.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "DYWebViewVC.h"
#import <WebKit/WebKit.h>
@interface DYWebViewVC ()

@property (nonatomic,strong) WKWebView *webView;


@end

@implementation DYWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    // Do any additional setup after loading the view.
}




- (WKWebView *)webView {
    
    if (!_webView) {
        _webView = [WKWebView new];
        
    }
    return _webView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
