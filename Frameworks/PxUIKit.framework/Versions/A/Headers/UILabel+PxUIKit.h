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
//  UILabel+PxUIKit.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxUIKitSupport.h"

/**
 * PxUIKit Category for UILabel
 */
@interface UILabel (PxUIKit)

#pragma mark - Initializing Labels
/** @name Initializing Labels */

/** Returns an label initialized with the specified font and linebreak settings.
 @param frame The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
 @param fontConfig The font and linebreak settings to use.
 @return An initialized label object.
 */
- (id)initWithFrame:(CGRect)frame fontConfig:(PxFontConfig)fontConfig;

/** Returns the font and linebreak settings of the receiver.
 @return The font and linebreak settings of the receiver.
 */
- (PxFontConfig)fontConfig;


#pragma mark - Calculating Content Metrics
/** @name Calculating Content Metrics */

/** Returns the height the receiver needs if its text were rendered complete and constrained to the receivers width.
 This method returns a fractional height; to use a returned height to size views, you must raise its value to the nearest higher integer using the ceil function.
 @return The height the receiver needs if its text were rendered complete and constrained to the receivers width.
 @see heightToFitWidth:
 @see widthToFit
 @see widthToFitHeight:
 */
- (CGFloat)heightToFit;

/** Returns the height the receiver needs if its text were rendered complete and constrained to the specified width.
 This method returns a fractional height; to use a returned height to size views, you must raise its value to the nearest higher integer using the ceil function.
 @param width The maximum acceptable width for the label.
 @return The height the receiver needs if its text were rendered complete and constrained to the specified width.
 @see heightToFit
 @see widthToFit
 @see widthToFitHeight:
 */
- (CGFloat)heightToFitWidth:(CGFloat)width;

/** Returns the width the receiver needs if its text were rendered complete and constrained to the receivers height.
 This method returns a fractional height; to use a returned height to size views, you must raise its value to the nearest higher integer using the ceil function.
 @return The width the receiver needs if its text were rendered complete and constrained to the receivers height.
 @see heightToFit
 @see heightToFitWidth:
 @see widthToFitHeight:
 */
- (CGFloat)widthToFit;

/** Returns the width the receiver needs if its text were rendered complete and constrained to the specified height.
 This method returns a fractional height; to use a returned height to size views, you must raise its value to the nearest higher integer using the ceil function.
 @param height The maximum acceptable width for the label.
 @return The width the receiver needs if its text were rendered complete and constrained to the specified height.
 @see heightToFit
 @see heightToFitWidth:
 @see widthToFit
 */
- (CGFloat)widthToFitHeight:(CGFloat)height;

/** Sets the height of the receiver constrained to the receivers width so its text can be completly rendered
 @see setHeightToFitWidth:
 @see setWidthToFit
 @see setWidthToFitHeight:
 */
- (void)setHeightToFit;

/** Sets the height of the receiver constrained to the specified width so its text can be completly rendered
 @param width The width for the label.
 @see setHeightToFit
 @see setWidthToFit
 @see setWidthToFitHeight:
 */
- (void)setHeightToFitWidth:(CGFloat)width;

/** Sets the width of the receiver constrained to the receivers height so its text can be completly rendered
 @see setHeightToFit
 @see setHeightToFitWidth:
 @see setWidthToFit
 */
- (void)setWidthToFit;

/** Sets the width of the receiver constrained to the specified height so its text can be completly rendered
 @param height The height for the label.
 @see setHeightToFit
 @see setHeightToFitWidth:
 @see setWidthToFit
 */
- (void)setWidthToFitHeight:(CGFloat)height;

/** Sets the size of the receiver so its text can be completly rendered, if possible, in one line.
 
 If the resulting width is greater than _maxWidth_, the size is constrained to _maxWidth_ and the height is altered so the receivers text can be completly rendered.
 @param maxWidth The maximum acceptable width for the label.
 */
- (void)sizeToFitWithMaxWidth:(int)maxWidth;

@end
