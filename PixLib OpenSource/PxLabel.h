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
//  PxLabel.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>
#import "PxUIkitSupport.h"

typedef struct {
	PxFontConfig fontConfig;
	UIEdgeInsets insets;
} PxLabelConfig;

static inline PxLabelConfig
PxLabelConfigMake(PxFontConfig fontConfig, UIEdgeInsets insets) {
    PxLabelConfig config;
	config.fontConfig = fontConfig;
	config.insets = insets;
    return config;
}

@interface PxLabel : UILabel {
	BOOL _widthToFit;
	BOOL _heightToFit;
}

@property(nonatomic, assign) UIEdgeInsets insets;

#pragma mark - Initializing Labels
/** @name Initializing Labels */

/** Returns an label initialized with the specified label settings.
 @param frame The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
 @param labelConfig The label settings to use.
 @return An initialized label object.
 */
- (id)initWithFrame:(CGRect)frame labelConfig:(PxLabelConfig)labelConfig;

/** Returns the label settings of the receiver.
 @return The label settings of the receiver.
 */
- (PxLabelConfig)labelConfig;


@end