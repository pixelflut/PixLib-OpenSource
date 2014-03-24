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
//  PxDrawService.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxDrawService.h"
#import "PxUIKitSupport.h"
#import "PxImageStorage.h"

@interface PxDrawService ()
@property (nonatomic, strong) PxImageStorage *imageCache;

- (NSString *)internalIdentifier:(NSString *)reuseId size:(CGSize)size;

- (UIImage *)imageFromCache:(NSString *)identifier;
- (void)storeImage:(UIImage *)image identifier:(NSString *)identifier;

@end

@implementation PxDrawService

PxSingletonImp(defaultService)

- (id)init {
    self = [super init];
    if (self) {
        self.imageCache = [[PxImageStorage alloc] initWithCacheDir:[PxCacheDirectory() stringByAppendingPathComponent:@"pxDrawService"] keepInMemory:YES];
    }
    return self;
}

- (UIImage *)imageWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier drawingBlock:(void (^)(CGContextRef ctx))drawBlock {
    return [self imageWithSize:size reuseIdentifier:reuseIdentifier drawingBlock:drawBlock opaque:NO];
}

- (UIImage *)imageWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier drawingBlock:(void (^)(CGContextRef ctx))drawBlock opaque:(BOOL)opaque {
    CGSize actualSize = CGSizeMake(CGFloatNormalizeForDevice(size.width), CGFloatNormalizeForDevice(size.height));
    UIImage *img;
    NSString *internalIdentifier;
    
    if (!TARGET_IPHONE_SIMULATOR && [reuseIdentifier isNotBlank]) {
        internalIdentifier = [self internalIdentifier:reuseIdentifier size:actualSize];
        img = [self imageFromCache:internalIdentifier];
    }
    
    if (!img && drawBlock) {
        UIGraphicsBeginImageContextWithOptions(actualSize, opaque, PxDeviceScale());
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        drawBlock(ctx);
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (internalIdentifier && img) {
            [self storeImage:img identifier:internalIdentifier];
        }
    }
    return img;
}

- (void)drawBlock:(void (^)(CGContextRef ctx))drawBlock {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    drawBlock(ctx);
}

- (void)clearCache {
    [self.imageCache clearCache];
}

- (void)removeImageWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier {
    if ([reuseIdentifier isNotBlank]) {
        CGSize actualSize = CGSizeMake(CGFloatNormalizeForDevice(size.width), CGFloatNormalizeForDevice(size.height));
        [self.imageCache removeImageForIdentifier:[self internalIdentifier:reuseIdentifier size:actualSize]];
    }
}

#pragma mark - Private
- (NSString *)internalIdentifier:(NSString *)reuseId size:(CGSize)size {
    return [reuseId stringByAppendingFormat:@"_%f_%f", size.width, size.height];
}

- (UIImage *)imageFromCache:(NSString *)identifier {
    if ([identifier isNotBlank]) {
        return [self.imageCache imageForIdentifier:identifier];
    }
    return nil;
}

- (void)storeImage:(UIImage *)image identifier:(NSString *)identifier {
    if ([identifier isNotBlank]) {
        [self.imageCache storeImage:image withIdentifier:identifier];
    }
}

@end
