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
//  PxLabel.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxLabel.h"
#import "PxCore.h"

@implementation PxLabel

- (id)initWithFrame:(CGRect)frame labelConfig:(PxLabelConfig)labelConfig {
	self = [super initWithFrame:frame fontConfig:labelConfig.fontConfig];
	if(self) {
		self.insets = labelConfig.insets;
	}
	return self;
}

- (PxLabelConfig)labelConfig {
	return PxLabelConfigMake([self fontConfig], self.insets);
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    size.width += self.insets.left + self.insets.right;
    size.height += self.insets.top + self.insets.bottom;
    return size;
}

- (void)sizeToFit {
    [super sizeToFit];
    
    CGSize selfSize = self.size;
    selfSize.width += self.insets.left + self.insets.right;
    selfSize.height += self.insets.top + self.insets.bottom;
    [self setSize:selfSize];
}

- (float)heightToFitWidth:(float)width {
	return [super heightToFitWidth:MAX(0, width-self.insets.left-self.insets.right)] + self.insets.top + self.insets.bottom;
}

- (float)widthToFitHeight:(float)height {
	return [super widthToFitHeight:MAX(0, height-self.insets.top-self.insets.bottom)] + self.insets.left + self.insets.right;
}

- (void)setText:(NSString *)text {
	[super setText:text];
	
	if(_widthToFit && _heightToFit) {
		[self sizeToFit];
	} else if (_widthToFit) {
		[self setWidthToFit];
	} else if (_heightToFit) {
		[self setHeightToFit];
	}
}

@end
