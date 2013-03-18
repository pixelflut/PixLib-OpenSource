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
//  PxInputAnimation.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>

/**
 Wrapps the informations from keyboard (or picker) show/hide notifications to get access in an object-oriented way.
 */
@interface PxInputAnimation : NSObject
@property (nonatomic, assign) CGRect startFrame;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) UIViewAnimationCurve curve;
@property (nonatomic, strong) NSString *name;

- (id)initWithStartFrame:(CGRect)startFrame endFrame:(CGRect)endFrame duration:(CGFloat)duration curve:(UIViewAnimationCurve)curve name:(NSString *)name;
- (id)initWithPickerNotification:(NSNotification *)notification;
- (id)initWithKeyboardNotification:(NSNotification *)notification;

- (BOOL)willShow;

@end
