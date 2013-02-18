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
//  PxCellDeleteLayer.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxCellDeleteLayer.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "PxCore.h"

@interface PxCellDeleteLayer ()
@property(nonatomic, readonly, strong) id target;
@property(nonatomic, readonly, assign) SEL action;

@end

@implementation PxCellDeleteLayer

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(!self.isHidden && self.userInteractionEnabled && self.alpha > 0) {
		CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		if (CGRectContainsPoint([self convertRect:_cell.pxDeleteView.frame fromView:_cell], point)) {
			return [_cell.pxDeleteView hitTest:[_cell.pxDeleteView convertPoint:point fromView:self] withEvent:event];
		}
		if (_ignoreCurrentCellTouch && CGRectContainsPoint(_cell.frame, point)) {
			return nil;
		}
		return (CGRectContainsPoint(frame, point)) ? self : nil;
	} else {
		return nil;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    objc_msgSend(_target, _action, self);
}

- (void)setTarget:(id)target action:(SEL)action {
    if (target != _target) {
        _target = target;
    }
    if (action != _action) {
        _action = action;
    }
}

@end
