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
//  PxAlertView.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>
#import "PxActionButtonConfig.h"

#define Alert(s) [[[UIAlertView alloc] initWithTitle:nil message:s delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];

@interface PxAlertView : UIAlertView <UIAlertViewDelegate>
@property(nonatomic, readonly, strong) id userInfo;

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle userInfo:(id)info block:(void (^)(BOOL confirm, id info))block;
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle userInfo:(id)userInfo block:(void (^)(int  buttonIndex, id info))block otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (id)initWithTitle:(NSString *)title message:(NSString *)message block:(void (^)(PxActionButtonConfig *buttonConfig))block;

@end
