//
//  UITextField+PxUIKit.m
//  PxUIKit
//
//  Created by Tobias Kreß on 13.06.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UITextField+PxUIKit.h"
#import <PxCore/PxCore.h>

static NSString *__pxPlaceHolderAttributeKey = @"__placeHolderAttributeKey";

@implementation UITextField (PxUIKit)

- (UIColor *)placeholderColor {
    UIColor *clr = [self runtimeProperty:__pxPlaceHolderAttributeKey];
    if (!clr) {
        clr = [self.attributedPlaceholder attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
    }
    return clr;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    [self setRuntimeProperty:placeholderColor name:__pxPlaceHolderAttributeKey];
    if (placeholderColor) {
        __weak UITextField *weakSelf = self;
        [self addPxObserver:self forKeyPath:@"placeholder" options:NSKeyValueObservingOptionNew block:^(id object, NSDictionary *change) {
            [weakSelf _pxUpdatePlaceholderColor];
        }];
    } else {
        [self removePxObserver:self];
    }
    [self _pxUpdatePlaceholderColor];
}

- (void)_pxUpdatePlaceholderColor {
    if (self.placeholder) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: [self placeholderColor]}];
    }
}

@end
