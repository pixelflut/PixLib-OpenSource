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
//  UIView+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIView+PxUIKit.h"
#import <QuartzCore/QuartzCore.h>
#import <PxCore/PxCore.h>
#import "PxUIKitSupport.h"

@implementation UIView (PxUIKit)

- (void)buildUI {}

- (void)setUI {}

- (CGPoint)extents {
    CGSize size = self.frame.size;
    CGPoint origin = self.frame.origin;
    return CGPointMake(origin.x+size.width, origin.y+size.height);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin {
    CGSize size = self.frame.size;
    [self setFrame:CGRectMake(origin.x, origin.y, size.width, size.height)];
}

- (void)setX:(float)x {
    CGRect frame = self.frame;
	frame.origin.x = x;
    [self setFrame:frame];
}

- (void)setY:(float)y {
    CGRect frame = self.frame;
	frame.origin.y = y;
    [self setFrame:frame];
}

- (void)setSize:(CGSize)size {
    CGPoint origin = self.frame.origin;
    [self setFrame:CGRectMake(origin.x, origin.y, size.width, size.height)];
}

- (void)setWidth:(float)width {
    CGRect frame = self.frame;
	frame.size.width = width;
    [self setFrame:frame];
}

- (void)setHeight:(float)height {
    CGRect frame = self.frame;
	frame.size.height = height;
    [self setFrame:frame];
}

- (void)removeSubviews {
    NSArray *subviews = [self subviews];
    for( UIView *v in subviews ) {
		[v removeFromSuperview];
	}
}

- (void)setDefaultResizingMask {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (void)drawInContext:(CGContextRef)c {
    CGContextTranslateCTM(c, self.frame.origin.x, self.frame.origin.y);
    [self.layer renderInContext:c];
    CGContextTranslateCTM(c, - self.frame.origin.x, - self.frame.origin.y);
}

- (UIImageView *)addImage:(UIImage *)image position:(CGPoint)point {
    UIImageView *img = [[UIImageView alloc] initWithImage:image];
    [img setOrigin:point];
    [self addSubview:img];
    return img;
}

- (UIImageView *)addImageWithName:(NSString *)imageName position:(CGPoint)point {
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [img setOrigin:point];
    [self addSubview:img];
    return img;
}

- (id)addView:(UIView *)view {
    [self addSubview:view];
    return view;
}

- (UIView *)searchSubviews:(BOOL (^)(UIView *obj))block {
    for (UIView *view in self.subviews) {
        if (block(view)) {
            return view;
        } else {
            UIView *v = [view searchSubviews:block];
            if (v) {
                return v;
            }
        }
    }
    return nil;
}

- (CGRect)normalizedFrame {
	return CGRectNormalizeForDevice(self.frame);
}

- (void)normalizeFrame {
	[self setFrame:[self normalizedFrame]];
}

#pragma mark - Animations
+ (void)pxAnimateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    if (duration != 0) {
        [self animateWithDuration:duration animations:animations];
    } else {
        if (animations) {
            animations();
        }
    }
}

+ (void)pxAnimateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    if (duration != 0) {
        [self animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)pxAnimateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    if (duration != 0 || delay != 0) {
        [self animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)pxAnimateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (duration != 0 || delay != 0) {
        [self animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}



@end
