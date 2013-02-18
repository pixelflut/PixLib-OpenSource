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
//  PxControl.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxControl.h"
#import "PxCore.h"

@implementation PxControl

@synthesize hitInsets = _hitInsets;
@synthesize minimumHitSize = _minimumHitSize;
@synthesize adjustsHitSizeToMinimum = _adjustsHitSizeToMinimum;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		_adjustsHitSizeToMinimum = YES;
	}
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(!self.isHidden && self.userInteractionEnabled && self.alpha > 0 && self.enabled) {
		CGRect rect = UIEdgeInsetsInsetRect(CGRectFromSize(self.frame.size), _hitInsets);
		
		if(_adjustsHitSizeToMinimum) {
			if(_minimumHitSize.width > rect.size.width) {
				rect.origin.x -= (_minimumHitSize.width - rect.size.width) / 2;
				rect.size.width = _minimumHitSize.width;
			}
			if(_minimumHitSize.height > rect.size.height) {
				rect.origin.y -= (_minimumHitSize.height - rect.size.height) / 2;
				rect.size.height = _minimumHitSize.height;
			}
		}
		
		if(CGRectContainsPoint(rect, point)) {
			return self;
		}
	}
	
	return [super hitTest:point withEvent:event];
}

@end
