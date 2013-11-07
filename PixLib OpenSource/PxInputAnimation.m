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
//  PxInputAnimation.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxInputAnimation.h"
#import "PxUIkit.h"

@implementation PxInputAnimation

- (id)initWithStartFrame:(CGRect)startFrame endFrame:(CGRect)endFrame duration:(CGFloat)duration curve:(UIViewAnimationCurve)curve name:(NSString *)name {
    self = [super init];
    if (self) {
        _startFrame = startFrame;
        _endFrame = endFrame;
        _duration = duration;
        _curve = curve;
        _name = name;
    }
    return self;
}

- (id)initWithPickerNotification:(NSNotification *)not {
    return [self initWithStartFrame:[(NSValue*)[[not userInfo] valueForKey:PxPickerFrameBeginKey] CGRectValue] endFrame:[(NSValue*)[[not userInfo] valueForKey:PxPickerFrameEndKey] CGRectValue] duration:[[[not userInfo] valueForKey:PxPickerAnimationDurationKey] floatValue] curve:[[[not userInfo] valueForKey:PxPickerAnimationCurveKey] intValue] name:not.name];
}

- (id)initWithKeyboardNotification:(NSNotification *)not {
    return [self initWithStartFrame:[(NSValue*)[[not userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] endFrame:[(NSValue*)[[not userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] duration:[[[not userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] curve:[[[not userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] name:not.name];
}

- (BOOL)willShow {
    return CGRectContainsRect([[UIApplication sharedApplication] keyWindow].frame, _endFrame);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nstartFrame: %@\nendFrame: %@\nduration: %f\ncurve: %ld\nname: %@", [super description], NSStringFromCGRect(_startFrame), NSStringFromCGRect(_endFrame), _duration, (long)_curve, _name];
}

@end
