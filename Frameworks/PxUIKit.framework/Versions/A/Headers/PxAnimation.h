//
//  PxAnimation.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 26.03.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxAnimation : NSObject

+ (PxAnimation *)pxAnimatePercentDriven:(NSTimeInterval)duration
                                  curve:(CAMediaTimingFunction *)curve
                             animations:(void (^)(void))animations
                             completion:(void (^)(BOOL finished))completion;


+ (PxAnimation *)pxAnimatePercentDriven:(NSTimeInterval)duration
                                  curve:(CAMediaTimingFunction *)curve
                   numberOfOscilattions:(NSUInteger)numberOfOscilattions
                       overBounceFactor:(CGFloat)overBounceFactor
                             animations:(void (^)(void))animations
                             completion:(void (^)(BOOL finished))completion;

+ (void)pxAddPercentAnimations:(void (^)(NSTimeInterval percent))animations;

- (void)cancelAnimation;

@end
