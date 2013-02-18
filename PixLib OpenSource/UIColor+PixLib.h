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
//  UIColor+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>

/**
 * PixLib Category for UIColor
 */
@interface UIColor (PixLib)

#pragma mark - Debuging the UI
/** @name Debuging the UI */

/** Returns a magenta color with alpha **0.6**.
 @return Magenta color with alpha **0.6**.
 @see randomDebugColor
 */
+ (UIColor *)debugColor;

/** Returns a random color with alpha **0.6**.
 @return Random color with alpha **0.6**.
 @see debugColor
 */
+ (UIColor *)randomDebugColor;


#pragma mark - Working with Hex-Colors
/** @name Working with Hex-Colors */

/** Returns a color with the given hex-value converted to RGB.
 @param hex The hex-value of the color.
 @param alpha The alpha-value of the color.
 @return The Color in RGB-space.
 @see colorWithHex:
 */
+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha;

/** Returns a color with the given hex-value converted to RGB.
 @param hex The hex-value of the color.
 @return The Color in RGB-space.
 @see colorWithHex:alpha:
 */
+ (UIColor *)colorWithHex:(NSUInteger)hex;


#pragma mark - Working with Pattern Colors
/** @name Working with Pattern Colors */

/** Creates and returns a color object using the specified image.
 
 The parameter _phaseShift_ does not change the pattern phase of a context.
 @param image The image to use when creating the pattern color.
 @param phaseShift A pattern phase, specified in user space.
 @return The pattern color.
 */
+ (UIColor *)colorWithPatternImage:(UIImage *)image phaseShift:(CGPoint)phaseShift;


#pragma mark - Getting Color Informations
/** @name Getting Color Informations */

/** Returns a string with the hex-representation of the receiver.
 @return A string with the hex-representation of the receiver.
 */
- (NSString *)hexString;

/** Returns an integer with the hex-notation of the receiver.
 @return An integer with the hex-notation of the receiver.
 */
- (int)hexValue;

/** Fills a buffer with the RGBA values of the receiver.
 
 The buffer must be large enough to hold at least 4 float values.
 @param buffer The buffer to store the RGBA values.
 */
- (void)getRGBA:(CGFloat *)buffer;


@end