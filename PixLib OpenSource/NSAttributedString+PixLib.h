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
//  NSAttributedString+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Adds convinient methods for drawing NSAttributedStrings in bezierpaths
 */
@interface NSAttributedString (PixLib)

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains any characters.
 @return YES if length > 0, otherwise NO.
 */
- (BOOL)isNotBlank;


#pragma mark - Computing Metrics for Drawing Strings
/** @name Computing Metrics for Drawing Strings */

/** Returns the height required to draw the string in a rectangle with a given width.
 @param width The width of the rectangle the string should be drawn in.
 @return The minimum height required to draw the entire content of self.
 */
- (CGFloat)heightForWidth:(CGFloat)width;

/** Returns the height required to draw the string in a path.
 @param path The path the string should be drawn in.
 @return The minimum height required to draw the entire content of self.
 */
- (CGFloat)heightForPath:(CGPathRef)path;


#pragma mark - Drawing Strings in a Given Area
/** @name Drawing Strings in a Given Area */

/** Draws the string inside the specified bounding path in the current graphics context.
 @param path The path the string should be drawn in.
 @param storeLines Either or not the lines and its bounding rects should be returned
 @return Array containing elements of type _PxPair_. The first value is of type _CTLineRef_ the second a _NSValue_ with the bounding rect
 */
- (NSArray *)drawInPath:(CGPathRef)path returnLines:(BOOL)storeLines;


@end
