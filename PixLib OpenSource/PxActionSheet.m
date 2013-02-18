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
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxActionSheet.h"
#import "PxCore.h"

@interface PxActionSheet ()
@property(nonatomic, readonly, strong) NSMutableDictionary *styleDictionary;
@property(nonatomic, readonly, strong) NSSet *disabledButtons;
@property(nonatomic, readonly, strong) id userInfo;
@property(nonatomic, readonly, strong) void (^actionBlock)(int buttonIndex, id userInfo);
@property(nonatomic, readonly, strong) PxActionButtonConfig *config;

@end

@implementation PxActionSheet

- (id)initWithTitle:(NSString *)title block:(void (^)(int buttonIndex, id userInfo))block userInfo:(id)userInfo cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self) {
		int i = 0;
		
		if (destructiveButtonTitle) {
            [self addButtonWithTitle:destructiveButtonTitle];
            [self setDestructiveButtonIndex:i];
			++i;
        }
		
        va_list ap;
        
        va_start(ap, otherButtonTitles);
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

- (id)initWithTitle:(NSString *)title block:(void (^)(PxActionButtonConfig *buttonConfig))block {
    self = [super init];
    if (self) {
        [self setTitle:title];
        
        _config = [[PxActionButtonConfig alloc] init];
        block(_config);
        [_config reorderButtons];
        
        int d = [_config destructiveIndex];
        int c = [_config cancelIndex];
        
        for (int i = 0; i<_config.visibleButtonCount; i++) {
            NSString *title = [_config titleAtIndex:i];
            [self addButtonWithTitle:title];
            i == d ? [self setDestructiveButtonIndex:i] : nil;
            i == c ? [self setCancelButtonIndex:i] : nil;
        }
        
        [self setDelegate:self];
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_actionBlock) {
        _actionBlock(buttonIndex, _userInfo);
    }else if(_config) {
        [_config executeButtonAtIndex:buttonIndex];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([_disabledButtons count] > 0 || [_styleDictionary count] > 0) {
        __block int btnIndex = 0;
        [[self subviews] each:^(UIView *view) {
            if([NSStringFromClass([view class]) isEqualToString:@"UIAlertButton"]) {
                if ([_disabledButtons containsObject:[NSIndexPath indexPathWithIndex:btnIndex]]) {
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
		[(NSMutableSet *)_disabledButtons removeObject:[NSIndexPath indexPathWithIndex:index]];
	} else {
		[(NSMutableSet *)_disabledButtons addObject:[NSIndexPath indexPathWithIndex:index]];
	}
    [self setNeedsLayout];
}


@end
