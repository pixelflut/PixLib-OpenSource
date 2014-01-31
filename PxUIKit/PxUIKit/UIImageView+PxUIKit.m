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
//  UIImageView+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIImageView+PxUIKit.h"
#import <PxCore/PxCore.h>
#import "PxUIKitImageSupport.h"

@implementation UIImageView (PxUIKit)

- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {
	self = [self initWithImage:image];
	if(self) {
		[self setContentMode:contentMode];
	}
	return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage contentMode:(UIViewContentMode)contentMode {
	self = [self initWithImage:image highlightedImage:highlightedImage];
	if(self) {
		[self setContentMode:contentMode];
	}
	return self;
}

- (id)initWithImageName:(NSString *)imageName image:(UIImage* (^)(UIImage *image))imageBlock highlightedImage:(UIImage* (^)(UIImage *image))highlightedImageblock {
	return [self initWithImageName:imageName image:imageBlock highlightedImage:highlightedImageblock contentMode:UIViewContentModeTopLeft];
}

- (id)initWithImageName:(NSString *)imageName image:(UIImage* (^)(UIImage *image))imageBlock highlightedImage:(UIImage* (^)(UIImage *image))highlightedImageblock contentMode:(UIViewContentMode)contentMode {
	UIImage *image = [UIImage imageNamed:imageName];
	return [self initWithImage:imageBlock(image) highlightedImage:highlightedImageblock(image) contentMode:contentMode];
}

- (void)setAnimatedImagesWithContentsOfGIFFile:(NSString *)filePath {
    if (!filePath) {
        return;
    }
    NSURL *imageURL = [NSURL fileURLWithPath:filePath];
    if (imageURL) {
        CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
        if (imageSourceRef) {
            NSUInteger count = CGImageSourceGetCount(imageSourceRef);
            NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:count];
            for (int i = 0; i<count; i++) {
                CGImageRef img = CGImageSourceCreateImageAtIndex(imageSourceRef, i, NULL);
                if (img) {
                    [imageArray addObject:[[UIImage alloc] initWithCGImage:img]];
                    CGImageRelease(img);
                }
                
                NSDictionary *sourceDict = (__bridge_transfer NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
                NSDictionary *gifDict = [sourceDict valueForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
                
                int gifDelayTime = [gifDict[(__bridge NSString *)kCGImagePropertyGIFDelayTime] intValue];
                float duration = (count*gifDelayTime*100.0);
                
                [self setAnimationRepeatCount:[gifDict[(__bridge NSString *)kCGImagePropertyGIFLoopCount] intValue]];
                [self setAnimationDuration:duration];
                [self setAnimationImages:imageArray];
            }
            CFRelease(imageSourceRef);
        }
    }
}

@end
