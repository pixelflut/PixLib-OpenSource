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
//  UIImage+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>

/**
 * PixLib Category for UIImage
 */
@interface UIImage (PixLib)

#pragma mark - Working with Retina and Non-Retina Devices
/** @name Working with Retina and Non-Retina Devices */

/** Returns the file URL to an image depending on the scale of the current Device.
 @param imageName The name of the image.
 @return The file URL to the image, or **nil** if no suitable image was found.
 */
+ (NSURL *)urlForImageName:(NSString *)imageName;


#pragma mark - Accessing Image informations without Loading the Image
/** @name Accessing Image informations without Loading the Image */

/** Returns the size of an image without loading the whole image into memory. 
 
 The result is cached.
 @param imageName The name of the image.
 @return The size of the image, or **CGSizeZero** if no suitable image was found.
 */
+ (CGSize)sizeForImageName:(NSString *)imageName;


#pragma mark - Drawing Images
/** @name Drawing Images */

/** Draws the receiver centered in the given area.
 
 The image is scaled to fit in _rect_ without changing the aspect ratio. Areas not covered by the image are left untouched. This is the same as calling [UIImage(PixLib) drawInRect:contentMode:] with contentMode **UIViewContentModeScaleAspectFit**.
 @param rect The area the image is drawn in.
 @see drawCropInRect:
 @see drawExtendInRect:blendMode:alpha:
 @see drawInRect:contentMode:
 */
- (void)drawExtendInRect:(CGRect)rect;

/** Draws the receiver centered in the given area.
 
 The image is scaled to fill _rect_ without changing the aspect ratio. Parts of the image outside _rect_ are clipped. This is the same as calling [UIImage(PixLib) drawInRect:contentMode:] with contentMode **UIViewContentModeScaleAspectFill**.
 @param rect The area the image is drawn in.
 @see drawExtendInRect:
 @see drawCropInRect:blendMode:alpha:
 @see drawInRect:contentMode:
 */
- (void)drawCropInRect:(CGRect)rect;

/** Draws the receiver centered in the given area.
 
 The image is scaled to fit in _rect_ without changing the aspect ratio. Areas not covered by the image are left untouched.
 @param rect The area the image is drawn in.
 @param blendMode The blend mode to use when compositing the image.
 @param alpha The desired opacity of the image, specified as a value between 0.0 and 1.0. A value of 0.0 renders the image totally transparent while 1.0 renders it fully opaque. Values larger than 1.0 are interpreted as 1.0.
 @see drawExtendInRect:
 */
- (void)drawExtendInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(float)alpha;

/** Draws the receiver centered in the given area.
 
 The image is scaled to fill _rect_ without changing the aspect ratio. Parts of the image outside _rect_ are clipped.
 @param rect The area the image is drawn in.
 @param blendMode The blend mode to use when compositing the image.
 @param alpha The desired opacity of the image, specified as a value between 0.0 and 1.0. A value of 0.0 renders the image totally transparent while 1.0 renders it fully opaque. Values larger than 1.0 are interpreted as 1.0.
 @see drawCropInRect:
 */
- (void)drawCropInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(float)alpha;

/** Draws the receiver in the given area according to contentmode _mode_.
 @param rect The area the image is drawn in.
 @param mode The content mode to position the receiver in _rect_.
 @see drawInRect:contentMode:blendMode:alpha:
 */
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)mode;

/** Draws the receiver in the given area according to content mode _mode_.
 @param rect The area the image is drawn in.
 @param mode The content mode to position the receiver in _rect_.
 @param blendMode The blend mode to use when compositing the image.
 @param alpha The desired opacity of the image, specified as a value between 0.0 and 1.0. A value of 0.0 renders the image totally transparent while 1.0 renders it fully opaque. Values larger than 1.0 are interpreted as 1.0.
 @see drawInRect:contentMode:
 */
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)mode blendMode:(CGBlendMode)blendMode alpha:(float)alpha;


#pragma mark - Creating Image Versions
/** @name Creating Image Versions */

/** Returns a new image from an area of the receiver.
 @param rect The part of the receiver which should be used to create the new image.
 @return The new image.
 */
- (UIImage *)imageCropedInRect:(CGRect)rect;

/** Returns a new image by scaling the receiver to fit _size_. Aspect ratio will not be preserved.
 @param size The desired image size.
 @return The new image.
 */
- (UIImage *)imageWithSize:(CGSize)size;

/** Returns a new image by scaling the receiver to fit _size_. Aspect ratio and position according to content mode _mode_.
 @param size The desired image size.
 @param mode The content mode to position and scale the receiver.
 @return The new image.
 */
- (UIImage *)imageWithSize:(CGSize)size contentMode:(UIViewContentMode)mode;

#pragma mark - Tinting Images
/** @name Tinting Images */

/** Creates a image by using _maskImage_ as a clipping mask and _tintColor_ as fill color.
 @param maskImage The image to clip the context to.
 @param tintColor The color to fill the context with.
 @return The created image.
 @see imageWithMaskImage:tintColor:shadowOffset:shadowBlur:shadowColor:
 @see imageWithMaskImage:tintColor:shadowOffset:shadowBlur:shadowColor:center:
 */
+ (UIImage *)imageWithMaskImage:(UIImage *)maskImage tintColor:(UIColor *)tintColor;

/** Creates a image by using _maskImage_ as a clipping mask and _tintColor_ as fill color.
 @param maskImage The image to clip the context to.
 @param tintColor The color to fill the context with.
 @param shadowOffset The offset of the shadow.
 @param shadowBlur The blur of the shadow.
 @param shadowColor The color of the shadow.
 @return The created image.
 @see imageWithMaskImage:tintColor:
 @see imageWithMaskImage:tintColor:shadowOffset:shadowBlur:shadowColor:center:
 */
+ (UIImage *)imageWithMaskImage:(UIImage *)maskImage tintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor;

/** Creates a image by using _maskImage_ as a clipping mask and _tintColor_ as fill color.
 @param maskImage The image to clip the context to.
 @param tintColor The color to fill the context with.
 @param shadowOffset The offset of the shadow.
 @param shadowBlur The blur of the shadow.
 @param shadowColor The color of the shadow.
 @param center If **YES** the result-image is centered together with the shadow.
 @return The created image.
 @see imageWithMaskImage:tintColor:
 @see imageWithMaskImage:tintColor:shadowOffset:shadowBlur:shadowColor:
 */
+ (UIImage *)imageWithMaskImage:(UIImage *)maskImage tintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor center:(BOOL)center;


- (UIImage *)imageWithTintColor:(UIColor *)tintColor NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
- (UIImage *)imageWithTintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
- (UIImage *)imageWithTintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor center:(BOOL)center NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);

@end
