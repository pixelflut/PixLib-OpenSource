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
//  PxImageStorage.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxImageStorage.h"
#import <PxCore/PxCore.h>
#import "PxUIKitSupport.h"

@interface PxImageStorage ()
@property (nonatomic, strong) NSCache *inMemoryCache;

@end

@implementation PxImageStorage

+ (NSString *)identifierForURL:(NSURL *)url {
    return [[url absoluteString] stringByAddingMD5Encoding];
}

- (id)initWithCacheDir:(NSString *)cacheDir keepInMemory:(BOOL)keepInMemory {
    self = [super init];
    if (self) {
        _keepInMemory = keepInMemory;
        _cacheDir = cacheDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir]) {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:Nil error:&error];
            if (error) {
                self = nil;
                PxError(@"%@", error);
                return nil;
            }
        }
        if (keepInMemory) {
            self.inMemoryCache = [[NSCache alloc] init];
        }
    }
    return self;
}


/*
 Getting and Setting Images from Memory
 */
- (UIImage *)imageForIdentifier:(NSString *)identifier {
    UIImage *img = [self.inMemoryCache objectForKey:identifier];
    if (!img) {
        NSString *filePath = [self imagePathForIdentifier:identifier];
        if (filePath) {
            img = [[UIImage alloc] initWithContentsOfFile:filePath];
            if (PxDeviceScale() != 1.0) {
                img = [[UIImage alloc] initWithCGImage:[img CGImage] scale:PxDeviceScale() orientation:UIImageOrientationUp];
            }
            if (self.keepInMemory) {
                [self.inMemoryCache setObject:img forKey:identifier];
            }
        }
    }
    return img;
}

- (void)storeImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    [UIImagePNGRepresentation(image) writeToFile:[self filePath:identifier] atomically:YES];
    if (self.keepInMemory) {
        [self.inMemoryCache setObject:image forKey:identifier];
    }
}


/*
 Getting and Setting Images from File
 */
- (NSString *)imagePathForIdentifier:(NSString *)identifier {
    return [self filePath:identifier];
}

- (void)storeImageFromLocalURL:(NSURL *)fileURL withIdentifier:(NSString *)identifier {
    [self storeImageFromLocalURL:fileURL withIdentifier:identifier copy:NO];
}

- (void)storeImageFromLocalURL:(NSURL *)fileURL withIdentifier:(NSString *)identifier copy:(BOOL)copy {
    NSString *filePath = [self filePath:identifier];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            PxError(@"%@", error);
        }
    }
    if (copy) {
        [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:[NSURL fileURLWithPath:filePath] error:&error];
    } else {
        [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:filePath] error:&error];
    }
    
    if (error) {
        PxError(@"%@", error);
    }
}

#pragma mark - private

- (NSString *)filePath:(NSString *)identifier {
    return [[self cacheDir] stringByAppendingPathComponent:identifier];
}

@end
