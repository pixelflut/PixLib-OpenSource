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
//  PxAttributedLabel.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "PxHTMLParser.h"
#import "NSAttributedString+PixLib.h"
#import "NSMutableAttributedString+PixLib.h"
#import "PxUIkitSupport.h"

@protocol PxAttributedLabelLinkDelegate;

@interface PxAttributedLabel : UIView {
#pragma mark - Draw Area
    CGPathRef _drawArea;
    CGPathRef _customDrawArea;
    
#pragma mark - Link Handle
    NSArray *_lines;
    UITapGestureRecognizer *_linkRecognizer;
}
@property(nonatomic, readonly, strong) NSAttributedString *attributedString;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) CTTextAlignment textAlignment;

@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIFont *boldFont;
@property(nonatomic, strong) UIFont *italicFont;
@property(nonatomic, strong) UIFont *italicBoldFont;
@property(nonatomic, strong) UIFont *linkFont;

@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIColor *boldTextColor;
@property(nonatomic, strong) UIColor *italicTextColor;
@property(nonatomic, strong) UIColor *italicBoldTextColor;
@property(nonatomic, strong) UIColor *linkTextColor;

@property(nonatomic, assign) CGSize shadowOffset;
@property(nonatomic, strong) UIColor *shadowColor;
@property(nonatomic, assign) CGFloat lineSpacing;
@property(nonatomic, assign) CGFloat lineHeight;
@property(nonatomic, strong) PxHTMLStyleBlock styleBlock;
@property(nonatomic, readonly, assign) BOOL needsParsing;
@property(nonatomic, weak) id<PxAttributedLabelLinkDelegate> linkDelegate;

- (CGFloat)setHeightForWidth:(CGFloat)width;
- (CGFloat)setHeightToFit;

//- (void)setWidthForHeight:(float)height;
//- (void)setWidthToFit;

- (void)setCustomDrawArea:(CGPathRef)path;

- (void)setNeedsParsing;

@end


@protocol PxAttributedLabelLinkDelegate <NSObject>

- (void)attributedLabel:(PxAttributedLabel *)label didClickLink:(NSDictionary *)attributes;

@end