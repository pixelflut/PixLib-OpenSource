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
//  PxRotatingScreen.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxRotatingScreen.h"
#import <QuartzCore/QuartzCore.h>
#import "PxCore.h"

@interface PxRotatingScreen ()
@property(nonatomic, strong) UIView *contentView;

@end

@implementation PxRotatingScreen

- (UIInterfaceOrientation)orientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (UIWindow *)keyWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

- (id)init {
    self = [super initWithFrame:CGRectFromSize(self.keyWindow.frame.size)];
    if (self) {
        [self.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [super addSubview:_contentView];
        [_contentView setAutoresizesSubviews:YES];
        [self rotate:self.orientation];
    }
    return self;
}

- (void)rotate:(UIInterfaceOrientation)orientation {
    CGSize windowSize = self.keyWindow.frame.size;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            [self.layer setBounds:CGRectFromSize(windowSize)];
            self.layer.transform = CATransform3DIdentity;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self.layer setBounds:CGRectMake(0, 0, windowSize.height, windowSize.width)];
            self.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self.layer setBounds:CGRectMake(0, 0, windowSize.height, windowSize.width)];
            self.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self.layer setBounds:CGRectFromSize(windowSize)];
            self.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            break;
        default:
            break;
    }
    [_contentView setFrame:[self contentFrameOpen:orientation]];
}

- (CGRect)contentFrameOpen:(UIInterfaceOrientation)orientation {
    CGSize size = self.keyWindow.frame.size;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return CGRectMake(0, 0, size.width, size.height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(0, 0, size.width, size.height);
            break;
        default:
            return CGRectMake(0, 0, size.height, size.width);
            break;
    }
}

- (void)addSubview:(UIView *)view {
    [_contentView addSubview:view];
}

- (CGRect)frame {
    return self.contentView.frame;
}

#pragma mark Orientation
- (void)orientationWillChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[[notification userInfo] valueForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    [self rotate:orientation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
