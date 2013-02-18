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
//  UIImageView+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>

/**
 * PixLib Category for UIImageView
 */
@interface UIImageView (PixLib)

#pragma mark - Initializing ImageViews
/** @name Initializing ImageViews */

/** Returns an image view initialized with the specified image and content mode.
 @param image The initial image to display in the image view.
 @param contentMode A flag used to determine how a view lays out its content.
 @return An initialized image view object.
 */
- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode;

/** Returns an image view initialized with the specified regular and highlighted images as well as a content mode.
 @param image The initial image to display in the image view.
 @param highlightedImage The image to display if the image view is highlighted.
 @param contentMode A flag used to determine how a view lays out its content.
 @return An initialized image view object.
 */
- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage contentMode:(UIViewContentMode)contentMode;


- (id)initWithImageName:(NSString *)imageName image:(UIImage* (^)(UIImage *image))imageBlock highlightedImage:(UIImage* (^)(UIImage *image))highlightedImageblock;
- (id)initWithImageName:(NSString *)imageName image:(UIImage* (^)(UIImage *image))imageBlock highlightedImage:(UIImage* (^)(UIImage *image))highlightedImageblock contentMode:(UIViewContentMode)contentMode;


#pragma mark - Working with GIF-Animations
/** @name Working with GIF-Animations */

/** sets the animationsImages, animationRepeatCount and animationDuration of the receiver according to a given animated GIF file.
 @param filePath The file path to a GIF image file.
 */
- (void)setAnimatedImagesWithContentsOfGIFFile:(NSString *)filePath;

@end
