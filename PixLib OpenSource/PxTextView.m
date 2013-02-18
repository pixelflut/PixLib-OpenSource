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
//  PxTextView.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxTextView.h"

#define _APPLE_PLACEHOLDER_COLOR [UIColor colorWithWhite:0.7 alpha:1]

@interface PxTextView ()
@property(nonatomic, strong) UIColor *_textColor;
@property(nonatomic, strong) UIFont *_font;
@property(nonatomic, assign) BOOL placeholderVisible;

@end

@implementation PxTextView
@synthesize placeholderColor = _placeholderColor;

- (void)addObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewShouldBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewShouldEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)removeObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hasText {
	return !_placeholderVisible && [super hasText];
}

- (void)setPlaceholder:(NSString *)placeholder {
	if(placeholder != _placeholder) {
		_placeholder = placeholder;
		
		if(!self.text || [self.text isEqualToString:@""]) {
			[self shouldSetPlaceholderStyling:YES];
		}
		
		if(_placeholder && ![_placeholder isEqualToString:@""]) {
			[self addObservers];
		} else {
			[self removeObservers];
		}
	}
}

- (UIColor *)placeholderColor {
	return _placeholderColor ? _placeholderColor : _APPLE_PLACEHOLDER_COLOR;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
	if(placeholderColor != _placeholderColor) {
		_placeholderColor = placeholderColor;
		
		[self shouldSetPlaceholderStyling:YES];
	}
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
	if(placeholderFont != _placeholderFont) {
		_placeholderFont = placeholderFont;
		
		[self shouldSetPlaceholderStyling:YES];
	}
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];

	if(!_placeholderVisible) {
		__font = self.font;
	}
}

- (void)setTextColor:(UIColor *)textColor {
	[super setTextColor:textColor];
	
	if(!_placeholderVisible) {
		__textColor = self.textColor;
	}
}

- (void)shouldSetPlaceholderStyling:(BOOL)set {
	if(!set || (self.text && ![self.text isEqualToString:@""] && !_placeholderVisible)) {
		_placeholderVisible = NO;
		[self setTextColor:__textColor];
		[self setFont:__font];
	} else {
		_placeholderVisible = YES;
		[self setText:_placeholder];
		[self setTextColor:self.placeholderColor];
		[self setFont:_placeholderFont];
	}
}

- (void)textViewShouldBeginEditing:(NSNotification *)notification {
	if(_placeholderVisible) {
		[self setText:@""];
	}
	[self shouldSetPlaceholderStyling:NO];
}

- (void)textViewShouldEndEditing:(NSNotification *)notification {
	[self shouldSetPlaceholderStyling:YES];
}

@end
