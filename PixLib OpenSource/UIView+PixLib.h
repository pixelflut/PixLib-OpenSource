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
//  UIView+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>

#define PxAddView(superView, Class, frame) [superView addView:[[Class alloc] initWithFrame:frame]]

/**
 * PixLib Category for UIView
 */
@interface UIView (PixLib)

- (void)buildUI;
- (void)setUI;

- (CGPoint)extents;
- (CGPoint)origin;
- (CGSize)size;

- (void)setOrigin:(CGPoint)origin;
- (void)setX:(float)x;
- (void)setY:(float)y;
- (void)setSize:(CGSize)size;
- (void)setWidth:(float)width;
- (void)setHeight:(float)height;
- (void)removeSubviews;
- (void)setDefaultResizingMask;
- (void)drawInContext:(CGContextRef)c;

- (UIImageView *)addImage:(UIImage *)image position:(CGPoint)point;
- (UIImageView *)addImageWithName:(NSString *)imageName position:(CGPoint)point;

- (id)addView:(UIView *)view;

- (UIView *)searchSubviews:(BOOL (^)(UIView *obj))block;

@end
