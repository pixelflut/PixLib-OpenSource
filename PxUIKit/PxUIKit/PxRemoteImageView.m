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
//  PxRemoteImageView.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxRemoteImageView.h"
#import "UIView+PxUIKit.h"
#import "UIImage+PxUIKit.h"
#import "PxUIkitSupport.h"
#import "PxImageStorage.h"
#import "PxRemoteImageService.h"

@interface CallbackProxy : NSObject
@property (nonatomic, weak) PxRemoteImageView *imageView;
@property (nonatomic, copy) void (^completion)(BOOL completed, NSURL *originalURL, PxRemoteImageView *imageView);

- (id)initWithImageView:(PxRemoteImageView *)imageView block:(void (^)(BOOL completed, NSURL *originalURL, PxRemoteImageView *imageView))completionBlock;

- (void)callBlock:(BOOL)completed url:(NSURL *)url;

@end


@interface PxRemoteImageView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, weak) UIImage *image;

@end

@implementation PxRemoteImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBgImageView:PxAddView(self, UIImageView, CGRectFromSize(frame.size))];
        [self.bgImageView setDefaultResizingMask];
        
        [self setImageView:PxAddView(self, UIImageView, CGRectFromSize(frame.size))];
        [self.imageView setAlpha:0];
        [self.imageView setDefaultResizingMask];
    }
    return self;
}

- (UIImage *)currentImage {
    return self.imageView.image;
}

- (void)loadImageFromURLWithString:(NSString *)urlString {
    [self loadImageFromURLWithString:urlString completion:nil];
}

- (void)loadImageFromURLWithString:(NSString *)urlString completion:(void (^)(BOOL completed, NSURL *originalURL, PxRemoteImageView *imageView))completionBlock {
    NSURL *url = [NSURL URLWithString:urlString];
    if (![self.currentURL isEqualToString:[url absoluteString]]) {
        [self setCurrentURL:[url absoluteString]];
        
        Class selfClass = [self class];
        PxImageStorage *storage = [selfClass _previewImageStorage];
        
        [self.imageView setImage:[storage imageForIdentifier:[[storage class] identifierForURL:url]]];
        [self setImageVisible:self.imageView.image != nil];
        
        CallbackProxy *callBackProxy = [[CallbackProxy alloc] initWithImageView:self block:completionBlock];
        
        [[PxRemoteImageService defaultService] fetchLocalImagePathForURL:[NSURL URLWithString:urlString]
                                                         completionBlock:^(NSString *filePath, NSURL *originalURL) {
                                                             if ([callBackProxy.imageView.currentURL isEqualToString:[originalURL absoluteString]]) {
                                                                 if (filePath) {
                                                                     NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                                                                     UIImage *img = [[UIImage alloc] initWithData:imageData scale:PxDeviceScale()];
                                                                     
                                                                     if (storage) {
                                                                         CGSize previewSize = CGSizeMake((int)(img.size.width/[selfClass previewImageScale]), (int)(img.size.height/[selfClass previewImageScale]));
                                                                         if (!CGSizeEqualToSize(previewSize, CGSizeZero)) {
                                                                             UIGraphicsBeginImageContextWithOptions(previewSize, YES, 1);
                                                                             
                                                                             [img drawInRect:CGRectFromSize(previewSize) contentMode:UIViewContentModeScaleAspectFill];
                                                                             UIImage *preview = UIGraphicsGetImageFromCurrentImageContext();
                                                                             
                                                                             UIGraphicsEndImageContext();
                                                                             [storage storeImage:preview withIdentifier:[[storage class] identifierForURL:originalURL]];
                                                                         }
                                                                     }
                                                                     
                                                                     
                                                                     UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.width, img.size.height), YES, PxDeviceScale());
                                                                     
                                                                     [img drawInRect:CGRectFromSize(img.size)];
                                                                     img = UIGraphicsGetImageFromCurrentImageContext();
                                                                     
                                                                     UIGraphicsEndImageContext();
                                                                     
                                                                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                         if ([callBackProxy.imageView.currentURL isEqualToString:[originalURL absoluteString]]) {
                                                                             [callBackProxy.imageView setImage:img];
                                                                             [callBackProxy callBlock:YES url:originalURL];
                                                                         } else {
                                                                             [callBackProxy callBlock:NO url:originalURL];
                                                                         }
                                                                     }];
                                                                 } else {
                                                                     UIImage *errorImage = callBackProxy.imageView.errorImage;
                                                                     if (errorImage) {
                                                                         [callBackProxy.imageView.bgImageView setImage:errorImage];
                                                                         [callBackProxy.imageView setImageVisible:NO];
                                                                     }
                                                                 }
                                                             } else {
                                                                 [callBackProxy callBlock:NO url:originalURL];
                                                             }
                                                         }];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self.imageView setContentMode:contentMode];
    [self.bgImageView setContentMode:contentMode];
}

- (void)setDefaultImage:(UIImage *)img {
    if (_defaultImage != img) {
        _defaultImage = img;
        [_bgImageView setImage:_defaultImage];
		if (_image == nil) {
            [self setImageVisible:NO];
		}
    }
}

#pragma mark - Private
- (void)setImageVisible:(BOOL)visible {
    UIView *fromView;
    UIView *toView;
    
    if (visible) {
        fromView = _bgImageView;
        toView = _imageView;
    } else {
        fromView = _imageView;
        toView = _bgImageView;
    }
    
    void (^changeBlock)(void) = ^() {
        [fromView setAlpha:0];
        [toView setAlpha:1];
    };
    
    if (false) {
        [UIView animateWithDuration:0.2 animations:changeBlock];
    }else {
        changeBlock();
    }
    
    if ([self respondsToSelector:@selector(drawRect:)]) {
        [self setNeedsDisplay];
    }
}

- (void)setImage:(UIImage *)i {
    UIImage *img = i;
    if (img != _image) {
        _image = img;
        [_imageView setImage:_image];
        [self setImageVisible:YES];
    }
}
         

- (void)setCurrentURL:(NSString *)currentURL {
    if (_currentURL != currentURL) {
        _currentURL = currentURL;
        
        if(!_currentURL) {
           [self setImageVisible:NO];
        }
    }
}

static NSMutableDictionary *__previewStorages;
+ (void)initialize {
    if ([self classRespondsToSelector:@selector(previewImageScale)] && [self classRespondsToSelector:@selector(previewImageStorage)] && [self previewImageScale] > 1) {
        if (!__previewStorages) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                __previewStorages = [[NSMutableDictionary alloc] init];
            });
        }
        [__previewStorages setValue:[[self class] previewImageStorage] forKey:NSStringFromClass(self)];
    }
}

+ (PxImageStorage *)_previewImageStorage {
    return [__previewStorages valueForKey:NSStringFromClass(self)];
}

@end


@implementation CallbackProxy

- (id)initWithImageView:(PxRemoteImageView *)imageView block:(void (^)(BOOL completed, NSURL *originalURL, PxRemoteImageView *imageView))completionBlock {
    self = [super init];
    if (self) {
        self.imageView = imageView;
        self.completion = completionBlock;
    }
    return self;
}

- (void)callBlock:(BOOL)completed url:(NSURL *)url {
    if (self.completion) {
        self.completion(completed, url, self.imageView);
    }
}

@end