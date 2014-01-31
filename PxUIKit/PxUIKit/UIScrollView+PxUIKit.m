//
//  UIScrollView+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIScrollView+PxUIKit.h"
#import <PxCore/PxCore.h>

@implementation UIScrollView (PxUIKit)

- (CGFloat)verticalScrollPercentage {
    CGFloat value = self.contentOffset.y + self.contentInset.top;
    CGFloat baseMax = (self.contentSize.height + self.contentInset.top + self.contentInset.bottom - self.frame.size.height);
    return value/baseMax;
}

- (CGFloat)horizontalScrollPercentage {
    CGFloat value = self.contentOffset.x + self.contentInset.left;
    CGFloat baseMax = (self.contentSize.width + self.contentInset.left + self.contentInset.right - self.frame.size.width);
    return value/baseMax;
}

- (void)setVerticalScrollPercentage:(CGFloat)percentage {
    [self setVerticalScrollPercentage:percentage animated:NO];
}

- (void)setHorizontalScrollPercentage:(CGFloat)percentage {
    [self setHorizontalScrollPercentage:percentage animated:NO];
}

- (void)setVerticalScrollPercentage:(CGFloat)percentage animated:(BOOL)animated {
    CGFloat y = lerp(percentage, 0, self.contentSize.height + self.contentInset.top - self.frame.size.height)-self.contentInset.top;
    [self setContentOffset:CGPointMake(self.contentOffset.x, y) animated:animated];
}

- (void)setHorizontalScrollPercentage:(CGFloat)percentage animated:(BOOL)animated {
    CGFloat x = lerp(percentage, 0, self.contentSize.width + self.contentInset.left - self.frame.size.width)-self.contentInset.left;
    [self setContentOffset:CGPointMake(x, self.contentOffset.y) animated:animated];
}





- (CGFloat)verticalScrollPercentagePlain {
    CGFloat value = self.contentOffset.y;
    CGFloat baseMax = (self.contentSize.height - self.frame.size.height);
    return value/baseMax;
}

- (CGFloat)horizontalScrollPercentagePlain {
    CGFloat value = self.contentOffset.x;
    CGFloat baseMax = (self.contentSize.width - self.frame.size.width);
    return value/baseMax;
}

- (void)setVerticalScrollPercentagePlain:(CGFloat)percentage {
    [self setVerticalScrollPercentagePlain:percentage animated:NO];
}

- (void)setHorizontalScrollPercentagePlain:(CGFloat)percentage {
    [self setHorizontalScrollPercentagePlain:percentage animated:NO];
}

- (void)setVerticalScrollPercentagePlain:(CGFloat)percentage animated:(BOOL)animated {
    CGFloat y = 0;
    if (self.contentSize.height > self.frame.size.height) {
        y = lerp(percentage, 0, self.contentSize.height - self.frame.size.height);
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, y) animated:animated];
}

- (void)setHorizontalScrollPercentagePlain:(CGFloat)percentage animated:(BOOL)animated {
    CGFloat x = 0;
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
