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
//  PxSwitch.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxControl.h"

@protocol PxSwitchAppearance;

@interface PxSwitch : UIControl
@property (nonatomic, strong) UIView<PxSwitchAppearance> *thumbView;
@property (nonatomic, strong) UIView<PxSwitchAppearance> *leftView;
@property (nonatomic, strong) UIView<PxSwitchAppearance> *rightView;
@property (nonatomic, strong) UIView<PxSwitchAppearance> *backgroundView;
@property (nonatomic, assign, getter = isOn) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

#pragma mark - Subclassing
- (void)buildUI;

@end

@protocol PxSwitchAppearance <NSObject>

- (void)pxSwitchChangeAppearance:(CGRect)thumbFrame valueFrame:(CGRect)valueFrame percentage:(float)percentage;

@optional

- (void)pxSwitchIsHighlighted:(BOOL)highlighted;

@end
