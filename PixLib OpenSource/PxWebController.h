//
//  PxWebController.h
//  PixLib
//
//  Created by Jonathan Cichon on 25.01.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import "PxViewController.h"

@interface PxWebController : PxViewController <UIWebViewDelegate>
@property(nonatomic, strong, readonly) UIWebView *webView;
@property(nonatomic, strong) NSString *urlString;

- (id)initWithURL:(NSString*)urlString title:(NSString*)title;
- (id)initWithURL:(NSString*)urlString;

@end
