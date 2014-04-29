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
//  NSMutableAttributedString+PxUIKit.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

typedef struct {
    CTTextAlignment alignment;
    CGFloat lineSpacing;
    CGFloat lineHeight;
    CGFloat firstLineIndent;
    CGFloat topParagraphScpacing;
} PxParagraphStyleOptions;

/**
 * Adds convinient methods for setting various attributes of NSMutableAttributedStrings
 */
@interface NSMutableAttributedString (PxUIKit)

#pragma mark - Changing Attributes in specific ranges
/** @name Changing Attributes */

/** set the font of the string in a given range.
 @param fontName The name of the desired font.
 @param size The size of the desired font.
 @param range The range of characters the font should apply to.
 @see setFontWithName:size:
 @see setFontWithUIFont:range:
 @see setFontWithUIFont:
 */
- (void)setFontWithName:(NSString *)fontName size:(CGFloat)size range:(NSRange)range;

/** set the font of the string.
 @param fontName The name of the desired font.
 @param size The size of the desired font.
 @see setFontWithName:size:range:
 @see setFontWithUIFont:range:
 @see setFontWithUIFont:
 */
- (void)setFontWithName:(NSString *)fontName size:(CGFloat)size;

/** set the font of the string in a given range.
 @param font The desired font.
 @param range The range of characters the font should apply to.
 @see setFontWithName:size:
 @see setFontWithName:size:range:
 @see setFontWithUIFont:
 */
- (void)setFontWithUIFont:(UIFont *)font range:(NSRange)range;

/** set the font of the string.
 @param font The desired font.
 @see setFontWithName:size:
 @see setFontWithName:size:range:
 @see setFontWithUIFont:range:
 */
- (void)setFontWithUIFont:(UIFont *)font;

/** set the fill color of the string in a given range.
 @param color The desired color.
 @param range The range of characters the color should apply to.
 @see setTextColor:
 @see setStrokeColor:width:range:
 @see setStrokeColor:width:
 @see setStrokeColor:range:
 @see setStrokeColor:
 */
- (void)setTextColor:(CGColorRef)color range:(NSRange)range;

/** set the fill color of the string in a given range.
 @param color The desired color.
 @see setTextColor:range:
 @see setStrokeColor:width:range:
 @see setStrokeColor:width:
 @see setStrokeColor:range:
 @see setStrokeColor:
 */
- (void)setTextColor:(CGColorRef)color;

/** set the stroke color of the string in a given range.
 @param color The desired color.
 @param width The stroke-width.
 @param range The range of characters the color should apply to.
 @see setTextColor:range:
 @see setTextColor:
 @see setStrokeColor:width:
 @see setStrokeColor:range:
 @see setStrokeColor:
 */
- (void)setStrokeColor:(CGColorRef)color width:(CGFloat)width range:(NSRange)range;

/** set the stroke color of the string.
 @param color The desired color.
 @param width The stroke-width.
 @see setTextColor:range:
 @see setTextColor:
 @see setStrokeColor:width:range:
 @see setStrokeColor:range:
 @see setStrokeColor:
 */
- (void)setStrokeColor:(CGColorRef)color width:(CGFloat)width;

/** set the stroke color of the string in a given range.
 @param color The desired color.
 @param range The range of characters the color should apply to.
 @see setTextColor:range:
 @see setTextColor:
 @see setStrokeColor:width:range:
 @see setStrokeColor:width:
 @see setStrokeColor:
 */
- (void)setStrokeColor:(CGColorRef)color range:(NSRange)range;

/** set the stroke color of the string.
 @param color The desired color.
 @see setTextColor:range:
 @see setTextColor:
 @see setStrokeColor:width:range:
 @see setStrokeColor:width:
 @see setStrokeColor:range:
 */
- (void)setStrokeColor:(CGColorRef)color;

/** set the stroke-width of the string in a given range.
 @param width The stroke-width.
 @param range The range of characters the stroke-width should apply to.
 @see setStrokeColor:width:range:
 @see setStrokeColor:width:
 @see setStrokeWidth:
 */
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range;

/** set the stroke-width of the string.
 @param width The stroke-width.
 @see setStrokeColor:width:range:
 @see setStrokeColor:width:
 @see setStrokeWidth:range:
 */
- (void)setStrokeWidth:(CGFloat)width;

/** style the underline of the string in a given range.
 @param style The underlineStyle.
 @param color the color of the underline.
 @param range The range of characters the underline styling should apply to.
 @see setUnderlineStyle:color:
 @see setUnderlineStyle:range:
 @see setUnderlineStyle:
 */
- (void)setUnderlineStyle:(CTUnderlineStyle)style color:(CGColorRef)color range:(NSRange)range;

/** style the underline of the string.
 @param style The underlineStyle.
 @param color the color of the underline.
 @see setUnderlineStyle:color:range:
 @see setUnderlineStyle:range:
 @see setUnderlineStyle:
 */
- (void)setUnderlineStyle:(CTUnderlineStyle)style color:(CGColorRef)color;

/** style the underline of the string in a given range.
 @param style The underlineStyle.
 @param range The range of characters the underline styling should apply to.
 @see setUnderlineStyle:color:range:
 @see setUnderlineStyle:color:
 @see setUnderlineStyle:
 */
- (void)setUnderlineStyle:(CTUnderlineStyle)style range:(NSRange)range;

/** style the underline of the string.
 @param style The underlineStyle.
 @see setUnderlineStyle:color:range:
 @see setUnderlineStyle:color:
 @see setUnderlineStyle:range:
 */
- (void)setUnderlineStyle:(CTUnderlineStyle)style;

/** style the kerning of the string in a given range.
 @param amountToKern The amount of kerning (a positive kern indicates a shift farther away from and a negative kern indicates a shift closer to the characters in range).
 @param range The range of characters the kerning should apply to.
 @see setKerning:
 */
- (void)setKerning:(float)amountToKern range:(NSRange)range;

/** style the kerning of the string in a given range.
 @param amountToKern The amount of kerning (a positive kern indicates a shift farther away from and a negative kern indicates a shift closer to the characters in range).
 @see setKerning:range:
 */
- (void)setKerning:(float)amountToKern;

#pragma mark - Changing Paragraph Attributes
/** @name Changing Attributes */

/** set paragraph stylings of the string.
 @param optionBlock The block to configure the paragraph styling.
 @param range The range of characters the kerning should apply to.
 @see setParagraphStyle:
 */
- (void)setParagraphStyle:(void (^)(PxParagraphStyleOptions *options))optionBlock range:(NSRange)range;

/** set paragraph stylings of the string.
 @param optionBlock The block to configure the paragraph styling.
 @see setParagraphStyle:range:
 */
- (void)setParagraphStyle:(void (^)(PxParagraphStyleOptions *options))optionBlock;

@end
