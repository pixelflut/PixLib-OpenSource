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
//  UILabel+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UILabel+PxUIKit.h"
#import <PxCore/PxCore.h>
#import "NSString+PxUIKit.h"
#import "UIView+PxUIKit.h"

@implementation UILabel (PxUIKit)

- (id)initWithFrame:(CGRect)frame fontConfig:(PxFontConfig)fontConfig {
    self = [self initWithFrame:frame];
    if (self) {
        self.font = fontConfig.font;
        
        if ([self respondsToSelector:@selector(minimumScaleFactor)]) {
            self.minimumScaleFactor = fontConfig.minimumScaleFactor;
        } else if([self respondsToSelector:@selector(minimumFontSize)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self setMinimumFontSize:fontConfig.minimumScaleFactor/self.font.pointSize];
#pragma clang diagnostic pop
        }
        
        self.lineBreakMode = fontConfig.lineBreakMode;
        self.adjustsFontSizeToFitWidth = fontConfig.adjustsFontSizeToFitWidth;
        self.numberOfLines = fontConfig.numberOfLines;
    }
    return self;
}

- (PxFontConfig)fontConfig {
    if ([self respondsToSelector:@selector(minimumScaleFactor)]) {
        return PxFontConfigMake(self.font, self.minimumScaleFactor, self.lineBreakMode, self.adjustsFontSizeToFitWidth, self.numberOfLines, 1);
    } else if([self respondsToSelector:@selector(minimumFontSize)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return PxFontConfigMake(self.font, self.minimumFontSize/self.font.pointSize, self.lineBreakMode, self.adjustsFontSizeToFitWidth, self.numberOfLines, 1);
#pragma clang diagnostic pop
    }
    return PxFontConfigMake(self.font, 0.0, self.lineBreakMode, self.adjustsFontSizeToFitWidth, self.numberOfLines, 1);
}

- (CGFloat)heightToFitWidth:(CGFloat)width {
    return [self.text heightForWidth:width config:self.fontConfig];
}

- (CGFloat)heightToFit {
	return [self heightToFitWidth:self.frame.size.width];
}

- (void)setHeightToFitWidth:(CGFloat)width {
    [self setSize:CGSizeMake(width, CGFloatCeilForDevice([self heightToFitWidth:width]))];
}

- (void)setHeightToFit {
    [self setHeightToFitWidth:self.frame.size.width];
}

- (CGFloat)widthToFitHeight:(CGFloat)height {
    CGSize size = CGSizeMake(INT_MAX, height);
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    
    if (self.font) {
        fontAttributes[NSFontAttributeName] = self.font;
    }
    
    return [self.text boundingRectWithSize:size options:0 attributes:fontAttributes context:nil].size.width;
}

- (CGFloat)widthToFit {
	return [self widthToFitHeight:self.frame.size.height];
}

- (void)setWidthToFitHeight:(CGFloat)height {
    [self setSize:CGSizeMake(CGFloatCeilForDevice([self widthToFitHeight:height]), height)];
}

- (void)setWidthToFit {
    [self setWidthToFitHeight:self.frame.size.height];
}

- (void)sizeToFit {
	CGFloat width = [self widthToFit];
	[self setSize:CGSizeMake(width, [self heightToFitWidth:width])];
}

- (void)sizeToFitWithMaxWidth:(int)maxWidth {
	[self sizeToFit];
    
	if(self.frame.size.width > maxWidth) {
		[self setHeightToFitWidth:maxWidth];
	}
}

@end
