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
//  PxUIkitSupport.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//


#import <UIKit/UIKit.h>

#ifndef PixLib_PxUIkitSupport_h
#define PixLib_PxUIkitSupport_h

typedef struct {
    __unsafe_unretained UIFont *font;
    float minimumScaleFactor;
    NSLineBreakMode lineBreakMode;
    BOOL adjustsFontSizeToFitWidth;
    int numberOfLines;
	float amountOfKerning;
} PxFontConfig;

#warning add amountOfKerning to PxFontConfigMake
static inline PxFontConfig
PxFontConfigMake(UIFont *font, float minimumScaleFactor, NSLineBreakMode lineBreakMode, BOOL adjustsFontSizeToFitWidth, int numberOfLines) {
    PxFontConfig config;
    config.font = font;
    config.minimumScaleFactor = minimumScaleFactor;
    config.lineBreakMode = lineBreakMode;
    config.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
    config.numberOfLines = numberOfLines;
    return config;
}

// Statusbar
#define STATUS_BAR_STYLE_BLACK_TRANSLUCENT_OPACITY 0.6
#define STATUS_BAR_STYLE_BLACK_TRANSLUCENT_FONT_OPACITY 0.75
#define STATUS_BAR_ANIMATION_FADE_IN_DURATION 0.35
#define STATUS_BAR_ANIMATION_FADE_OUT_DURATION 0.35

#endif
