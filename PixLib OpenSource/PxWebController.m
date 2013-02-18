//
//  PxWebController.m
//  PixLib
//
//  Created by Jonathan Cichon on 25.01.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import "PxWebController.h"
#import "PxCore.h"

@interface PxWebController ()
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation PxWebController

- (id)initWithURL:(NSString*)url title:(NSString*)t {
#warning check for super/self init in groceryliest/firstyears
    self = [super init];
    if (self) {
        _urlString = url;
        [self setTitle:t];
    }
    return self;
}

- (id)initWithURL:(NSString*)url {
    return [self initWithURL:url title:nil];
}

- (void)loadView {
    UIView *rootView = [super loadStdView];
    _webView = [[UIWebView alloc] initWithFrame:CGRectFromSize(rootView.frame.size)];
    [_webView setDefaultResizingMask];
    [_webView setDelegate:self];
    [rootView addSubview:_webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView loadRequest:[NSMutableURLRequest requestWithUrlString:_urlString]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_webView setDelegate:nil];
    _webView = nil;
}

#pragma mark - getter/setter

- (UIWebView*)webView {
    return _webView;
}

- (void)setUrlString:(NSString *)u {
    if (_urlString != u) {
        _urlString = u;
        [_webView loadRequest:[NSMutableURLRequest requestWithUrlString:_urlString]];
    }
}

#pragma mark - Dealloc cleanup
- (void)dealloc {
    [_webView setDelegate:nil];
}

@end
