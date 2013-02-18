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
//  PxAlertView.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxAlertView.h"

@interface PxAlertView ()
@property(nonatomic, strong) void (^confirmBlock)(BOOL confirm, id userInfo);
@property(nonatomic, strong) void (^actionBlock)(int index, id userInfo);
@property(nonatomic, strong) PxActionButtonConfig *config;

@end

@implementation PxAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle userInfo:(id)info block:(void (^)(BOOL, id))block {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    if (self) {
        _confirmBlock = block;
        _userInfo = info;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle userInfo:(id)userInfo block:(void (^)(int, id))block otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
		va_list ap;
        va_start(ap, otherButtonTitles);
        int i = 0;
        for (NSString *title = otherButtonTitles; title != nil; title = va_arg(ap, NSString*)){
            [self addButtonWithTitle:title];
            i++;
        }
        va_end(ap);
        
        if (cancelButtonTitle) {
            [self addButtonWithTitle:cancelButtonTitle];
            [self setCancelButtonIndex:i];
        }
        
        _actionBlock = block;
        _userInfo = userInfo;
        [self setDelegate:self];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message block:(void (^)(PxActionButtonConfig *buttonConfig))block {
    self = [super init];
    if (self) {
        [self setTitle:title];
        [self setMessage:message];
        
        _config = [[PxActionButtonConfig alloc] init];
        block(_config);
        [_config reorderButtons];
        
        int c = [_config cancelIndex];
        
        for (int i = 0; i<_config.visibleButtonCount; i++) {
            NSString *title = [_config titleAtIndex:i];
            [self addButtonWithTitle:title];
            i == c ? [self setCancelButtonIndex:i] : nil;
        }
        
        [self setDelegate:self];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(_confirmBlock) {
		_confirmBlock(buttonIndex==1, _userInfo);
	} else if(_actionBlock) {
		_actionBlock(buttonIndex, _userInfo);
	} else if(_config) {
        [_config executeButtonAtIndex:buttonIndex];
    }
}

@end
