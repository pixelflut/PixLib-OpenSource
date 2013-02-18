//
//  PxViewController.m
//  PixLib
//
//  Created by Jonathan Cichon on 16.11.11.
//  Copyright (c) 2011 pixelflut GmbH. All rights reserved.
//

#import "PxViewController.h"
#import "PxCore.h"

@implementation PxViewController

- (UIView*)loadStdView {
    CGRect frame;
    if (self.wantsFullScreenLayout) {
        frame = [[UIScreen mainScreen] bounds];
    }else {
        frame = CGRectFromSize([[UIScreen mainScreen] applicationFrame].size);
    }
    UIView *v = [[UIView alloc] initWithFrame:frame];
	[v setAutoresizesSubviews:YES];
    [v setDefaultResizingMask];
	[self setView:v];
	
    return v;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)updateView {}
- (void)reloadData {}

@end
