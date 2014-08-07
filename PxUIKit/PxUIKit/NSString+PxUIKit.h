//
//  NSString+PxUIKit.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxUIKitSupport.h"

/**
 * PxUIKit Category for NSString
 */
@interface NSString (PxUIKit)

#pragma mark - Computing Metrics for Drawing Strings
/** @name Computing Metrics for Drawing Strings */

/** Returns the height of the string if it were rendered and constrained to the specified width and font informations.
 This method returns a fractional height; to use a returned height to size views, you must raise its value to the nearest higher integer using the ceil function.
 @param width The maximum acceptable width for the string. This value is used to calculate where line breaks and wrapping would occur.
 @param config The font and Linebreak informations to use for rendering the string.
 */
- (CGFloat)heightForWidth:(CGFloat)width config:(PxFontConfig)config;

@end
