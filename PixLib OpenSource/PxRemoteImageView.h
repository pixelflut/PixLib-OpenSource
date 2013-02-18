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
//  PxRemoteImageView.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>
#import "PxHTTPRemoteService.h"

@protocol PxRemoteImageViewDelegate;

@interface PxRemoteImageView : UIView
@property(nonatomic, strong) UIImage *defaultImage;
@property(nonatomic, strong) UIImage *errorImage;
@property(nonatomic, assign) NSInteger cacheInterval;
@property(nonatomic, weak) id<PxRemoteImageViewDelegate> delegate;

+ (id)remoteService;
+ (PxHTTPConnection *)preloadImageFromUrl:(NSString *)urlStr completionBlock:(void (^)(PxResult *result))completionBlock;

- (id)initWithDefaultImage:(UIImage *)img;
- (id)initWithSmallUrl:(NSString *)small bigUrl:(NSString *)big;
- (void)setImageWithSmallUrl:(NSString *)small bigUrl:(NSString *)big;

- (UIImage *)currentImage;

#pragma mark - Callbacks for Subclasses
- (void)willLoadRemoteImage;

@end

@protocol PxRemoteImageViewDelegate <NSObject>
@optional
- (void)imageView:(PxRemoteImageView *)imageView willLoadImageWithUrlString:(NSString*)urlStr;
- (void)imageView:(PxRemoteImageView *)imageView didLoad:(BOOL)success;
- (void)imageView:(PxRemoteImageView *)imageView didLoadOriginalImage:(UIImage *)image;
@end