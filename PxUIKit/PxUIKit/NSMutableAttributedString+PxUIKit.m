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
//  NSMutableAttributedString+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "NSMutableAttributedString+PxUIKit.h"
#import <PxCore/PxCore.h>
#import "PxUIKitSupport.h"

/*
 NSTextAlignmentLeft = 0,
 NSTextAlignmentCenter = 1,
 NSTextAlignmentRight = 2,
 <=>
 kCTLeftTextAlignment = 0,
 kCTRightTextAlignment = 1,
 kCTCenterTextAlignment = 2,
 */

#define PxDefaultParagraphOptions {kCTTextAlignmentLeft, 0.0, 0.0, 0.0, 0.0}

@implementation NSMutableAttributedString (PxUIKit)

#pragma mark - Font
- (void)setFontWithName:(NSString *)font size:(CGFloat)size range:(NSRange)range {
    if (PxOSAvailable(__IPHONE_6_0)) {
        UIFont *_font = [UIFont fontWithName:font size:size];
        [self addAttribute:(__bridge NSString*)kCTFontAttributeName value:_font range:range];
    } else {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font, size, NULL);
        [self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:range];
        CFRelease(fontRef);
    }
}

- (void)setFontWithName:(NSString *)font size:(CGFloat)size {
    [self setFontWithName:font size:size range:NSMakeRange(0, self.length)];
}

- (void)setFontWithUIFont:(UIFont *)font range:(NSRange)range {
    [self setFontWithName:font.fontName size:font.pointSize range:range];
}

- (void)setFontWithUIFont:(UIFont *)font {
    [self setFontWithUIFont:font range:NSMakeRange(0, self.length)];
}


#pragma mark - Color
- (void)setTextColor:(CGColorRef)color range:(NSRange)range {
    [self addAttribute:(__bridge NSString*)kCTForegroundColorAttributeName value:(__bridge id)color range:range];
}

- (void)setTextColor:(CGColorRef)color {
    [self setTextColor:color range:NSMakeRange(0, self.length)];
}

- (void)setStrokeColor:(CGColorRef)color width:(CGFloat)width range:(NSRange)range {
    [self setStrokeColor:color range:range];
    [self setStrokeWidth:width range:range];
}

- (void)setStrokeColor:(CGColorRef)color width:(CGFloat)width {
    [self setStrokeColor:color width:width range:NSMakeRange(0, self.length)];
}

- (void)setStrokeColor:(CGColorRef)color range:(NSRange)range {
    [self addAttribute:(__bridge NSString*)kCTStrokeColorAttributeName value:(__bridge id)color range:range];
}

- (void)setStrokeColor:(CGColorRef)color {
    [self setStrokeColor:color range:NSMakeRange(0, self.length)];
}

- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range {
    [self addAttribute:(__bridge NSString*)kCTStrokeWidthAttributeName value:[NSNumber numberWithFloat:width] range:range];
}

- (void)setStrokeWidth:(CGFloat)width {
    [self setStrokeWidth:width range:NSMakeRange(0, self.length)];
}

#pragma mark - Underline
- (void)setUnderlineStyle:(CTUnderlineStyle)style color:(CGColorRef)color range:(NSRange)range {
    [self setUnderlineStyle:style range:range];
    [self addAttribute:(__bridge NSString*)kCTUnderlineColorAttributeName value:(__bridge id)color range:range];
}

- (void)setUnderlineStyle:(CTUnderlineStyle)style color:(CGColorRef)color {
    [self setUnderlineStyle:style color:color range:NSMakeRange(0, self.length)];
}

- (void)setUnderlineStyle:(CTUnderlineStyle)style range:(NSRange)range {
    [self addAttribute:(__bridge NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}

- (void)setUnderlineStyle:(CTUnderlineStyle)style {
    [self setUnderlineStyle:style range:NSMakeRange(0, self.length)];
}

#pragma mark - Letter spacing
- (void)setKerning:(float)amountToKern range:(NSRange)range {
	[self addAttribute:(__bridge NSString*)kCTKernAttributeName value:[NSNumber numberWithFloat:amountToKern] range:range];
}

- (void)setKerning:(float)amountToKern {
	[self setKerning:amountToKern range:NSMakeRange(0, self.length)];
}

#pragma mark - ParagraphStyle
- (void)setParagraphStyle:(void (^)(PxParagraphStyleOptions *options))optionBlock range:(NSRange)range {
    PxParagraphStyleOptions opts = PxDefaultParagraphOptions;
    optionBlock(&opts);
    int n = 0;
    CTParagraphStyleSetting styleSettings[7];
    {
        // Alignment
        styleSettings[n].spec = kCTParagraphStyleSpecifierAlignment;
        styleSettings[n].value = &(opts.alignment);
        styleSettings[n].valueSize = sizeof(CTTextAlignment);
        n++;
    }
    
    {
        // Line Spacing
        float min = 0;
        float max = CGFLOAT_MAX;
        styleSettings[n].spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
        styleSettings[n].value = &(opts.lineSpacing);
        styleSettings[n].valueSize = sizeof(CGFloat);
        n++;
        styleSettings[n].spec = kCTParagraphStyleSpecifierMinimumLineHeight;
        styleSettings[n].value = &min;
        styleSettings[n].valueSize = sizeof(CGFloat);
        n++;
        styleSettings[n].spec = kCTParagraphStyleSpecifierMaximumLineHeight;
        styleSettings[n].value = &max;
        styleSettings[n].valueSize = sizeof(CGFloat);
        n++;
    }
    
    {
        // Line Height
        styleSettings[n].spec = kCTParagraphStyleSpecifierLineHeightMultiple;
        styleSettings[n].value = &(opts.lineHeight);
        styleSettings[n].valueSize = sizeof(CGFloat);
        n++;
    }
    
    {
        // first Line Indent
        styleSettings[n].spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
        styleSettings[n].value = &(opts.firstLineIndent);
        styleSettings[n].valueSize = sizeof(CGFloat);
        n++;
    }
    
    {
        // Top Paragraph Spacing
        styleSettings[n].spec = kCTParagraphStyleSpecifierParagraphSpacingBefore;
        styleSettings[n].value = &(opts.topParagraphScpacing);
        styleSettings[n].valueSize = sizeof(CGFloat);
        n++;
    }
    
    CTParagraphStyleRef paragraph = CTParagraphStyleCreate(styleSettings, 7);
    [self addAttribute:(__bridge NSString*)kCTParagraphStyleAttributeName value:(__bridge id)paragraph range:range];
    CFRelease(paragraph);
}

- (void)setParagraphStyle:(void (^)(PxParagraphStyleOptions *options))optionBlock {
    [self setParagraphStyle:optionBlock range:NSMakeRange(0, self.length)];
}

@end
