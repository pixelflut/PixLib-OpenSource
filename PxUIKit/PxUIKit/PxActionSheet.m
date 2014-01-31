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
//  PxActionSheet.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxActionSheet.h"
#import <PxCore/PxCore.h>

@interface PxActionSheet ()
@property (nonatomic, strong, readonly) NSMutableSet *disabledButtons;
@property (nonatomic, strong, readonly) id userInfo;
@property (nonatomic, strong, readonly, readonly) PxActionButtonConfig *config;

@end

@implementation PxActionSheet

- (id)initWithTitle:(NSString *)title block:(void (^)(PxActionButtonConfig *buttonConfig))block {
    self = [super init];
    if (self) {
        [self setTitle:title];
        
        _config = [[PxActionButtonConfig alloc] init];
        block(_config);
        [self.config reorderButtons];
        
        NSInteger d = [self.config destructiveIndex];
        NSInteger c = [self.config cancelIndex];
        
        for (int i = 0; i<self.config.visibleButtonCount; i++) {
            NSString *title = [self.config titleAtIndex:i];
            [self addButtonWithTitle:title];
            i == d ? [self setDestructiveButtonIndex:i] : nil;
            i == c ? [self setCancelButtonIndex:i] : nil;
        }
        
        [self setDelegate:self];
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.config executeButtonAtIndex:buttonIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.disabledButtons count] > 0) {
        __block int btnIndex = 0;
        [[self subviews] each:^(UIView *view) {
            if([NSStringFromClass([view class]) isEqualToString:@"UIAlertButton"]) {
                if ([self.disabledButtons containsObject:[NSIndexPath indexPathWithIndex:btnIndex]]) {
                    [(UIControl *)view setEnabled:NO];
                }
                btnIndex++;
            }
        }];
    }
}

- (void)setButtonAtIndex:(int)index enabled:(BOOL)enabled {
    if (_disabledButtons == nil) {
        _disabledButtons = [[NSMutableSet alloc] init];
    }
	if(enabled) {
		[self.disabledButtons removeObject:[NSIndexPath indexPathWithIndex:index]];
	} else {
		[self.disabledButtons addObject:[NSIndexPath indexPathWithIndex:index]];
	}
    [self setNeedsLayout];
}

@end
