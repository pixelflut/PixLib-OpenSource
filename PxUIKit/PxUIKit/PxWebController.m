/*
 * Copyright (c) 2013 pixelflut GmbH, http://pixelflut.net
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 */

//
//  PxWebController.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxWebController.h"
#import <PxCore/PxCore.h>
#import "PxUIKitSupport.h"
#import "UIView+PxUIKit.h"

@interface PxWebController ()
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation PxWebController

- (instancetype)initWithURL:(NSString*)url title:(NSString*)t {
    self = [super init];
    if (self) {
        _urlString = url;
        [self setTitle:t];
    }
    return self;
}

- (instancetype)initWithURL:(NSString*)url {
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
- (UIWebView *)webView {
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
