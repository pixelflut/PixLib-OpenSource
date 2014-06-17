//
//  UIControl+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 17.06.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIControl+PxUIKit.h"
#import <PxCore/PxCore.h>

static NSString *__pxHitInsetsKey = @"__pxHitInsets";
static NSString *__pxMinimumHitSizeKey = @"__pxMinimumHitSize";;
static NSString *__pxAdjustsHitSizeToMinimumKey = @"__pxAdjustsHitSizeToMinimum";;

@implementation UIControl (PxUIKit)

- (void)setHitInsets:(UIEdgeInsets)hitInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(hitInsets, UIEdgeInsetsZero)) {
        [self setRuntimeProperty:[NSValue valueWithUIEdgeInsets:hitInsets] name:__pxHitInsetsKey];
    } else {
        [self setRuntimeProperty:nil name:__pxHitInsetsKey];
    }
}

- (UIEdgeInsets)hitInsets {
    NSValue *value = [self runtimeProperty:__pxHitInsetsKey];
    if (value) {
        return [value UIEdgeInsetsValue];
    }
    return UIEdgeInsetsZero;
}

- (void)setMinimumHitSize:(CGSize)minimumHitSize {
    if (!CGSizeEqualToSize(minimumHitSize, CGSizeZero)) {
        [self setAdjustsHitSizeToMinimum:YES];
        [self setRuntimeProperty:[NSValue valueWithCGSize:minimumHitSize] name:__pxMinimumHitSizeKey];
    } else {
        [self setAdjustsHitSizeToMinimum:NO];
        [self setRuntimeProperty:nil name:__pxMinimumHitSizeKey];
    }
}

- (CGSize)minimumHitSize {
    NSValue *value = [self runtimeProperty:__pxMinimumHitSizeKey];
    if (value) {
        return [value CGSizeValue];
    }
    return CGSizeZero;
}

- (void)setAdjustsHitSizeToMinimum:(BOOL)adjustsHitSizeToMinimum {
    if (adjustsHitSizeToMinimum) {
        [self setRuntimeProperty:[NSNumber numberWithBool:adjustsHitSizeToMinimum] name:__pxAdjustsHitSizeToMinimumKey];
    } else {
        [self setRuntimeProperty:nil name:__pxAdjustsHitSizeToMinimumKey];
    }
}

- (BOOL)adjustsHitSizeToMinimum {
    NSNumber *value = [self runtimeProperty:__pxAdjustsHitSizeToMinimumKey];
    if (value) {
        return [value boolValue];
    }
    return NO;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = UIEdgeInsetsInsetRect(CGRectFromSize(self.frame.size), self.hitInsets);
    
    if(self.adjustsHitSizeToMinimum) {
        CGSize size = self.minimumHitSize;
    	if(size.width > rect.size.width) {
    		rect.origin.x -= (size.width - rect.size.width) / 2;
    		rect.size.width = size.width;
    	}
    	if(size.height > rect.size.height) {
    		rect.origin.y -= (size.height - rect.size.height) / 2;
    		rect.size.height = size.height;
    	}
    }
    
    if(CGRectContainsPoint(rect, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end
