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
//  PxImageStorage.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxImageStorage : NSObject
@property (nonatomic, strong, readonly) NSString *cacheDir;
@property (nonatomic, assign, readonly) BOOL keepInMemory;

- (id)initWithCacheDir:(NSString *)cacheDir
          keepInMemory:(BOOL)keepInMemory;


+ (NSString *)identifierForURL:(NSURL *)url;

/*
 Getting and Setting Images from Memory
 */
- (UIImage *)imageForIdentifier:(NSString *)identifier;
- (void)storeImage:(UIImage *)image withIdentifier:(NSString *)identifier;


/*
 Getting and Setting Images from File
 */
- (NSString *)imagePathForIdentifier:(NSString *)identifier;
- (void)storeImageFromLocalURL:(NSURL *)fileURL withIdentifier:(NSString *)identifier;
- (void)storeImageFromLocalURL:(NSURL *)fileURL withIdentifier:(NSString *)identifier copy:(BOOL)copy;

/*
 Removing Images and Clearing Cache
 */
- (void)removeImageForIdentifier:(NSString *)identifier;
- (void)clearCache;

@end
