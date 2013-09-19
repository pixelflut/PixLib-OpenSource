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
//  PxTextField.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxTextField.h"
#import "PxSupport.h"

@implementation PxTextField

#warning check calculations and check if draw...InRect is necessary in addition to ...RectForBounds

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	CGRect rect = bounds;
	rect.origin.x += _insets.left;
	rect.origin.y += _insets.top;
	rect.size.width -= _insets.left + _insets.right;
	rect.size.height -= _insets.top + _insets.bottom;
	rect = CGRectIntersection(bounds, rect);
	rect.origin.y += (PxDeviceIsScale2() ? 0.5 : 0);
	return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	bounds.origin.y -= (PxDeviceIsScale2() ? 0.5 : 0);
	return [self textRectForBounds:bounds];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
	[[self.attributedPlaceholder attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil] setFill];
	float width = [self.placeholder sizeWithFont:self.font minFontSize:self.minimumFontSize actualFontSize:nil forWidth:rect.size.width lineBreakMode:NSLineBreakByTruncatingTail].width;
	switch(self.textAlignment) {
		case NSTextAlignmentRight:
			rect.origin.x += rect.size.width-width;
			break;
		case NSTextAlignmentCenter:
			rect.origin.x += (rect.size.width-width)/2;
			break;
		default:
			break;
	}
	[self.placeholder drawAtPoint:rect.origin forWidth:rect.size.width withFont:self.font minFontSize:self.minimumFontSize actualFontSize:nil lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:self.baselineAdjustment];
}

- (void)drawTextInRect:(CGRect)rect {
	[self.textColor setFill];
	float width = [self.text sizeWithFont:self.font minFontSize:self.minimumFontSize actualFontSize:nil forWidth:rect.size.width lineBreakMode:NSLineBreakByTruncatingTail].width;
	switch(self.textAlignment) {
		case NSTextAlignmentRight:
			rect.origin.x += rect.size.width-width;
			break;
		case NSTextAlignmentCenter:
			rect.origin.x += (rect.size.width-width)/2;
			break;
		default:
			break;
	}
	[self.text drawAtPoint:rect.origin forWidth:rect.size.width withFont:self.font minFontSize:self.minimumFontSize actualFontSize:nil lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:self.baselineAdjustment];
}

@end
