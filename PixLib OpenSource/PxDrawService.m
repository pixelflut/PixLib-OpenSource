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
//  PixLib-OpenSource
//
//  Created by Jonathan Cichon on 21.02.13.
//

#import "PxDrawService.h"
#import "PxHTTPImageCache.h"
#import "PxCore.h"

@interface PxLayerWrapper : NSObject
@property(nonatomic, assign) CGLayerRef layer;
- (id)initWithLayer:(CGLayerRef)layer;
@end

@interface PxDrawService ()
@property(nonatomic, strong) PxHTTPImageCache *imageCache;
@property(nonatomic, strong) NSMutableDictionary *layerCache;

- (NSString *)internalIdentifier:(NSString *)reuseId size:(CGSize)size;
- (CGLayerRef)layerFromCache:(NSString *)reuseId;
- (void)storeLayer:(CGLayerRef)layer withIdentifier:(NSString *)identifier;

@end

@implementation PxDrawService

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemcacheOnLowMemory:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

#pragma mark - Public Methods
- (UIImage *)imageWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier drawingBlock:(void (^)(CGContextRef))drawBlock {
    CGSize actualSize = CGSizeMake((int)size.width, (int)size.height);
    UIImage *img;
    NSString *internalIdentifier;
    
    if (!reuseIdentifier) {
        internalIdentifier = [self internalIdentifier:reuseIdentifier size:actualSize];
        img = [self.imageCache imageForURLString:internalIdentifier interval:INT_MAX scale:PxDeviceScale()];
    }
    
    if (!img && drawBlock) {
        PxBeginImageContext(actualSize);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        drawBlock(ctx);
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (internalIdentifier) {
            [self.imageCache storeImage:img forURL:[NSURL URLWithString:internalIdentifier] header:nil];
        }
    }
    return img;
}

- (CGLayerRef)layerWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier drawingBlock:(void (^)(CGContextRef))drawBlock {
    CGSize actualSize = CGSizeMake((int)size.width, (int)size.height);
    CGLayerRef layer;
    NSString *internalIdentifier = [self internalIdentifier:reuseIdentifier size:actualSize];
    layer = [self layerFromCache:internalIdentifier];
    
    if (!layer && drawBlock) {
        PxBeginImageContext(actualSize);
        float scale = PxDeviceScale();
        CGSize layerSize = CGSizeMake(actualSize.width * scale, actualSize.height * scale);
        
        layer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), layerSize, NULL);
        CGContextRef ctx = CGLayerGetContext(layer);
        
        CGContextScaleCTM(ctx, scale, scale);
        
        drawBlock(ctx);
        
        UIGraphicsEndImageContext();
        
        [self storeLayer:layer withIdentifier:internalIdentifier];
        CGLayerRelease(layer);
    }
    return layer;
}

- (void)drawBlock:(void (^)(CGContextRef))drawBlock {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    drawBlock(ctx);
}

#pragma mark - Private Methods

- (NSString *)internalIdentifier:(NSString *)reuseId size:(CGSize)size {
    return [NSString stringWithFormat:@"%@_%d_%d", reuseId, (int)size.width, (int)size.height];
}

- (NSMutableDictionary *)layerCache {
    if (!_layerCache) {
        _layerCache = [[NSMutableDictionary alloc] init];
    }
    return _layerCache;
}

- (void)storeLayer:(CGLayerRef)layer withIdentifier:(NSString *)identifier {
    [self.layerCache setValue:[[PxLayerWrapper alloc] initWithLayer:layer] forKey:identifier];
}

- (CGLayerRef)layerFromCache:(NSString *)reuseId {
    PxLayerWrapper *wrapper = [self.layerCache valueForKey:reuseId];
    return [wrapper layer];
}

- (PxHTTPImageCache *)imageCache {
    if (!_imageCache) {
        _imageCache = [[PxHTTPImageCache alloc] init];
    }
    return _imageCache;
}

- (void)clearMemcacheOnLowMemory {
    self.layerCache = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation PxLayerWrapper

- (id)initWithLayer:(CGLayerRef)layer {
    self = [super init];
    if (self) {
        self.layer = layer;
    }
    return self;
}

- (void)setLayer:(CGLayerRef)layer {
    if (_layer != layer) {
        if (_layer) {
            CGLayerRelease(_layer);
            _layer = nil;
        }
        if (layer) {
            _layer = CGLayerRetain(layer);
        }
    }
}

- (void)dealloc {
    self.layer = nil;
}

@end
