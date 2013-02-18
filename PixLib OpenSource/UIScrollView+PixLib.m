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
//  UIScrollView+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "UIScrollView+PixLib.h"
#import "PxCore.h"

@implementation UIScrollView (PixLib)

- (float)verticalScrollPercentage {
    float value = self.contentOffset.y + self.contentInset.top;
    float baseMax = (self.contentSize.height + self.contentInset.top + self.contentInset.bottom - self.frame.size.height);
    return value/baseMax;
}

- (float)horizontalScrollPercentage {
    float value = self.contentOffset.x + self.contentInset.left;
    float baseMax = (self.contentSize.width + self.contentInset.left + self.contentInset.right - self.frame.size.width);
    return value/baseMax;
}

- (void)setVerticalScrollPercentage:(float)percentage {
    [self setVerticalScrollPercentage:percentage animated:NO];
}

- (void)setHorizontalScrollPercentage:(float)percentage {
    [self setHorizontalScrollPercentage:percentage animated:NO];
}

- (void)setVerticalScrollPercentage:(float)percentage animated:(BOOL)animated {
    float y = lerp(percentage, 0, self.contentSize.height + self.contentInset.top - self.frame.size.height)-self.contentInset.top;
    [self setContentOffset:CGPointMake(self.contentOffset.x, y) animated:animated];
}

- (void)setHorizontalScrollPercentage:(float)percentage animated:(BOOL)animated {
    float x = lerp(percentage, 0, self.contentSize.width + self.contentInset.left - self.frame.size.width)-self.contentInset.left;
    [self setContentOffset:CGPointMake(x, self.contentOffset.y) animated:animated];
}





- (float)verticalScrollPercentagePlain {
    float value = self.contentOffset.y;
    float baseMax = (self.contentSize.height - self.frame.size.height);
    return value/baseMax;
}

- (float)horizontalScrollPercentagePlain {
    float value = self.contentOffset.x;
    float baseMax = (self.contentSize.width - self.frame.size.width);
    return value/baseMax;
}

- (void)setVerticalScrollPercentagePlain:(float)percentage {
    [self setVerticalScrollPercentagePlain:percentage animated:NO];
}

- (void)setHorizontalScrollPercentagePlain:(float)percentage {
    [self setHorizontalScrollPercentagePlain:percentage animated:NO];
}

- (void)setVerticalScrollPercentagePlain:(float)percentage animated:(BOOL)animated {
    float y = 0;
    if (self.contentSize.height > self.frame.size.height) {
        y = lerp(percentage, 0, self.contentSize.height - self.frame.size.height);
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, y) animated:animated];
}

- (void)setHorizontalScrollPercentagePlain:(float)percentage animated:(BOOL)animated {
    float x = 0;
    if (self.contentSize.height > self.frame.size.height) {
        x = lerp(percentage, 0, self.contentSize.width - self.frame.size.width);
    }
    [self setContentOffset:CGPointMake(x, self.contentOffset.y) animated:animated];
}


#pragma mark - Apple Public Header but Private Ivar access
- (CGPoint)pagingTargetOffset {
    if (self.pagingEnabled) {
        CGPoint *p = (CGPoint *)(pointerToInstanceVariable(self, "_pageDecelerationTarget"));
        if (p) {
            return *p;
        }
        return CGPointZero;
    }
    return CGPointZero;
}

@end
