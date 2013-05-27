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
//  PxPickerContainer.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxPickerContainer.h"
#import <QuartzCore/QuartzCore.h>
#import "PxCore.h"

NSString *const PxPickerFrameBeginKey = @"frameBegin";
NSString *const PxPickerFrameEndKey = @"frameEnd";
NSString *const PxPickerAnimationDurationKey = @"animationDuration";
NSString *const PxPickerAnimationCurveKey = @"animationCurve";

#define SHOW_ANIMATE_SPEED 0.25
#define HIDE_ANIMATE_SPEED 0.25

#define SHOW_ANIMATE_CURVE UIViewAnimationCurveEaseInOut
#define HIDE_ANIMATE_CURVE UIViewAnimationCurveEaseInOut

@interface PxPickerContainerView : UIView

@end

@interface PxPickerContainer ()
@property (nonatomic, assign, getter = isVisible) BOOL visible;
@property (nonatomic, assign) BOOL shouldHide;
@property (nonatomic, assign) BOOL shouldShow;

- (UIWindow *)keyWindow;

- (CGRect)openFrame:(UIInterfaceOrientation)orientation;
- (CGRect)closeFrame:(UIInterfaceOrientation)orientation;
- (void)orientationWillChange:(NSNotification *)notification;
- (void)orientationDidChange:(NSNotification *)notification;

- (void)__finish;
- (void)__cancel;

- (void)__show;
- (void)__hide;

- (NSString *)__willShowNotificationName;
- (NSString *)__didShowNotificationName;
- (NSString *)__willHideNotificationName;
- (NSString *)__didHideNotificationName;

- (void)__willShow;
- (void)__didShow;

- (void)__willHide;
- (void)__didHide;

@end

@implementation PxPickerContainer
@synthesize visible     = _visible;
@synthesize shouldHide  = _shouldHide;
@synthesize shouldShow  = _shouldShow;
@synthesize contentView = _contentView;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

        _contentView = [[PxPickerContainerView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        [_contentView setBackgroundColor:[UIColor greenColor]];
        
        [self rotate:self.orientation];
        _visible = NO;
        [self setAlpha:0.0];
    }
    return self;
}

- (void)__doShow {
    _shouldHide = NO;
    UIWindow *w = self.keyWindow;
    if (!_visible && _shouldShow) {
        [self setAlpha:1.0];
        
        CGRect startRect = [self containerFrameClose:self.orientation];
        CGRect endRect = [self containerFrameOpen:self.orientation];
        
        CGRect startNotFrame = [self closeFrame:self.orientation];
        CGRect endNotFrame = [self openFrame:self.orientation];
        
		[self __willShow];
        [[NSNotificationCenter defaultCenter] postNotificationName:[self __willShowNotificationName]
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [NSValue valueWithCGRect:startNotFrame],
                                                                    PxPickerFrameBeginKey,
                                                                    [NSValue valueWithCGRect:endNotFrame],
                                                                    PxPickerFrameEndKey,
                                                                    [NSNumber numberWithFloat:SHOW_ANIMATE_SPEED],
                                                                    PxPickerAnimationDurationKey,
                                                                    [NSNumber numberWithInt:SHOW_ANIMATE_CURVE],
                                                                    PxPickerAnimationCurveKey,
                                                                    nil]];
        
        if (![self window]) {
            [_contentView setFrame:startRect];
            [w addSubview:self];
        }
        
        [UIView animateWithDuration:HIDE_ANIMATE_SPEED delay:0 options:HIDE_ANIMATE_CURVE<<16 animations:^{
            [_contentView setFrame:endRect];
        } completion:^(BOOL finished) {
            [self __didShow];
            [[NSNotificationCenter defaultCenter] postNotificationName:[self __didShowNotificationName]
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        [NSValue valueWithCGRect:startNotFrame],
                                                                        PxPickerFrameBeginKey,
                                                                        [NSValue valueWithCGRect:endNotFrame],
                                                                        PxPickerFrameEndKey,
                                                                        [NSNumber numberWithFloat:SHOW_ANIMATE_SPEED],
                                                                        PxPickerAnimationDurationKey,
                                                                        [NSNumber numberWithInt:SHOW_ANIMATE_CURVE],
                                                                        PxPickerAnimationCurveKey,
                                                                        nil]];
            
            _visible = YES;
        }];
    }
    [w bringSubviewToFront:self];
}

- (void)cancelShow {
    if (_shouldShow) {
        _shouldShow = NO;
        [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(__doShow) target:self argument:nil];
    }
}

- (void)__show {
    [self cancelHide];
    if (!_shouldShow) {
        _shouldShow = YES;
        [[NSRunLoop currentRunLoop] performSelector:@selector(__doShow) target:self argument:nil order:1 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
}

- (void)__doHide {
    _shouldShow = NO;
    if (_visible && _shouldHide) {
        CGRect endRect = [self containerFrameClose:self.orientation];
        CGRect startRect = [self containerFrameOpen:self.orientation];;
        [_contentView setFrame:startRect];
        
        CGRect startNotFrame = [self openFrame:self.orientation];
        CGRect endNotFrame = [self closeFrame:self.orientation];
        
        [self __willHide];
        [[NSNotificationCenter defaultCenter] postNotificationName:[self __willHideNotificationName]
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [NSValue valueWithCGRect:startNotFrame],
                                                                    PxPickerFrameBeginKey,
                                                                    [NSValue valueWithCGRect:endNotFrame],
                                                                    PxPickerFrameEndKey,
                                                                    [NSNumber numberWithFloat:HIDE_ANIMATE_SPEED],
                                                                    PxPickerAnimationDurationKey,
                                                                    [NSNumber numberWithInt:HIDE_ANIMATE_CURVE],
                                                                    PxPickerAnimationCurveKey,
                                                                    nil]];
        
        [UIView animateWithDuration:HIDE_ANIMATE_SPEED delay:0 options:HIDE_ANIMATE_CURVE<<16 animations:^{
            [_contentView setFrame:endRect];
        } completion:^(BOOL finished) {
            [self __didHide];
            [[NSNotificationCenter defaultCenter] postNotificationName:[self __didHideNotificationName]
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        [NSValue valueWithCGRect:startNotFrame],
                                                                        PxPickerFrameBeginKey,
                                                                        [NSValue valueWithCGRect:endNotFrame],
                                                                        PxPickerFrameEndKey,
                                                                        [NSNumber numberWithFloat:HIDE_ANIMATE_SPEED],
                                                                        PxPickerAnimationDurationKey,
                                                                        [NSNumber numberWithInt:HIDE_ANIMATE_CURVE],
                                                                        PxPickerAnimationCurveKey,
                                                                        nil]];
            
            _visible = NO;
            [self setAlpha:0.0];
        }];
    }
}

- (void)cancelHide {
    if (_shouldHide) {
        _shouldHide = NO;
        [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(__doHide) target:self argument:nil];
    }
}

- (void)__hide {
    [self cancelShow];
    if (!_shouldHide) {
        _shouldHide = YES;
        [[NSRunLoop currentRunLoop] performSelector:@selector(__doHide) target:self argument:nil order:2 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
}

- (void)cancel {
    if (_visible) {
        [self __cancel];
        [self __hide];
    }
}

- (void)done {
    if (_visible) {
        [self __finish];
        [self __hide];
    }
}

#pragma mark - Stubs 

- (NSString *)__willShowNotificationName {
    [NSException raise:@"Not Implementated Exception" format:@"<%@> You have to implement - (NSString *)__willShowNotificationName in Subclass", self.class];
    return nil;
}

- (NSString *)__didShowNotificationName {
    [NSException raise:@"Not Implementated Exception" format:@"<%@> You have to implement - (NSString *)__didShowNotificationName in Subclass", self.class];
    return nil;
}

- (NSString *)__willHideNotificationName {
    [NSException raise:@"Not Implementated Exception" format:@"<%@> You have to implement - (NSString *)__willHideNotificationName in Subclass", self.class];
    return nil;
}

- (NSString *)__didHideNotificationName {
    [NSException raise:@"Not Implementated Exception" format:@"<%@> You have to implement - (NSString *)__didHideNotificationName in Subclass", self.class];
    return nil;
}

- (void)__willShow {}
- (void)__didShow {}

- (void)__willHide {}
- (void)__didHide {}

- (void)__finish {}
- (void)__cancel {}

#pragma mark - Helper

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(_contentView.frame, point)) {
        return [_contentView hitTest:[self convertPoint:point toView:_contentView] withEvent:event];
    }
    return nil;
}

#pragma mark - Orientationchange

- (CGRect)containerFrameOpen:(UIInterfaceOrientation)orientation {
    CGSize size = self.keyWindow.frame.size;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return CGRectMake(0, size.height-216, size.width, 216);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(0, size.height-216, size.width, 216);
            break;
        default:
            return CGRectMake(0, size.width-162, size.height, 162);
            break;
    }
}

- (CGRect)containerFrameClose:(UIInterfaceOrientation)orientation {
    CGSize size = self.keyWindow.frame.size;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return CGRectMake(0, size.height, size.width, 216);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(0, size.height, size.width, 216);
            break;
        default:
            return CGRectMake(0, size.width, size.height, 162);
            break;
    }
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
    if (_visible) {
        [_contentView setFrame:[self containerFrameOpen:orientation]];
    }else {
        [_contentView setFrame:[self containerFrameClose:orientation]];
    }
}

- (void)orientationWillChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[[notification userInfo] valueForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    if (_visible) {
        [self postRotationNotifications:orientation];
    }
    
    [self rotate:orientation];
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (_visible) {
        UIInterfaceOrientation orientation = self.orientation;
        CGRect showNotFrameStart    = [self closeFrame:orientation];
        CGRect showNotFrameEnd      = [self openFrame:orientation];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[self __didShowNotificationName]
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [NSValue valueWithCGRect:showNotFrameStart],
                                                                    PxPickerFrameBeginKey,
                                                                    [NSValue valueWithCGRect:showNotFrameEnd],
                                                                    PxPickerFrameEndKey,
                                                                    nil]];
    }
}

#pragma mark - Notification Frames

- (CGRect)openFrame:(UIInterfaceOrientation)orientation {
    CGSize windowSize = self.keyWindow.frame.size;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:// 1
            return CGRectMake(0, windowSize.height-216, windowSize.width, 216);
            break;
        case UIInterfaceOrientationLandscapeLeft:// 3
            return CGRectMake(windowSize.width-162, 0, 162, windowSize.height);
            break;
        case UIInterfaceOrientationLandscapeRight:// 4
            return CGRectMake(0, 0, 162, windowSize.height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:// 2
            return CGRectMake(0, 0, windowSize.width, 216);
            break;
    }
    return CGRectNull;
}

- (CGRect)closeFrame:(UIInterfaceOrientation)orientation {
    CGSize windowSize = self.keyWindow.frame.size;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:// 1
            return CGRectMake(0, windowSize.height, windowSize.width, 216);
            break;
        case UIInterfaceOrientationLandscapeLeft:// 3
            return CGRectMake(windowSize.width, 0, 162, windowSize.height);
            break;
        case UIInterfaceOrientationLandscapeRight:// 4
            return CGRectMake(-162, 0, 162, windowSize.height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:// 2
            return CGRectMake(0, -216, windowSize.width, 216);
            break;
    }
}

- (void)postRotationNotifications:(UIInterfaceOrientation)orientation {
    CGRect hideNotFrameStart    = [self openFrame:self.orientation];
    CGRect hideNotFrameEnd      = [self closeFrame:self.orientation];
    [[NSNotificationCenter defaultCenter] postNotificationName:[self __willHideNotificationName]
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSValue valueWithCGRect:hideNotFrameStart],
                                                                PxPickerFrameBeginKey,
                                                                [NSValue valueWithCGRect:hideNotFrameEnd],
                                                                PxPickerFrameEndKey,
                                                                nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[self __didHideNotificationName]
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSValue valueWithCGRect:hideNotFrameStart],
                                                                PxPickerFrameBeginKey,
                                                                [NSValue valueWithCGRect:hideNotFrameEnd],
                                                                PxPickerFrameEndKey,
                                                                nil]];
    
    CGRect showNotFrameStart    = [self closeFrame:orientation];
    CGRect showNotFrameEnd      = [self openFrame:orientation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[self __willShowNotificationName]
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSValue valueWithCGRect:showNotFrameStart],
                                                                PxPickerFrameBeginKey,
                                                                [NSValue valueWithCGRect:showNotFrameEnd],
                                                                PxPickerFrameEndKey,
                                                                nil]];
}

#pragma mark - Memory Cleanup
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
}

@end


@implementation PxPickerContainerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect frame = self.frame;
    [[self subviews] each:^(id obj) {
        [obj setFrame:CGRectCenter(CGRectFromSize(frame.size), CGRectFromSize(CGSizeMake(600, frame.size.height)))];
    }];
}

@end