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
//  PxHTTPImageCache.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxHTTPImageCache.h"
#import "PxCore.h"

@interface PxHTTPImageCache ()
@property(nonatomic, assign) NSInteger memoryCacheSize;
@property(nonatomic, strong) NSMutableDictionary *dataCache;
@property(nonatomic, strong) NSMutableArray *fifoCache;

- (UIImage *)imageForKey:(NSString *)key;
- (void)storeImage:(UIImage *)img forKey:(NSString *)key;


@end

@implementation PxHTTPImageCache

- (id)init {
	return [self initWithMemcacheSize:50];
}

- (id)initWithMemcacheSize:(NSInteger)size {
	if ((self = [super init])) {
		_memoryCacheSize = size;
		_dataCache = [[NSMutableDictionary alloc] initWithCapacity:size];
		_fifoCache = [[NSMutableArray alloc] initWithCapacity:size];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemcacheOnLowMemory:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

#pragma mark - Path and Key Handling
- (NSString *)cacheSubDir {
    return @"images";
}

- (NSString *)keyForURL:(NSURL *)url {
    return [[url absoluteString] stringByAddingMD5Encoding];
}

#pragma mark - Low Memory Handling
- (void)clearMemcacheOnLowMemory:(NSNotification *)notification {
	[_dataCache removeAllObjects];
	[_fifoCache removeAllObjects];
}

#pragma mark - Storage Access
- (UIImage *)imageForURL:(NSURL *)url interval:(NSTimeInterval)interval scale:(PxImageScale)scale {
    if (![[url absoluteString] isNotBlank]) {
        return nil;
    }
    
	NSString *key = [self keyForURL:url];
	UIImage *result = [self imageForKey:key];
    
    if (result == nil) {
        NSDate *creationDate;
        NSString *savePath;
        if (interval == MAXFLOAT) {
            savePath = [self pathForURL:url header:nil creationDate:nil];
        } else {
            savePath = [self pathForURL:url header:nil creationDate:&creationDate];
        }
        
        if (savePath) {
            NSTimeInterval inter = [[NSDate date] timeIntervalSinceDate:creationDate];
            if((creationDate != nil && inter < interval) || interval == MAXFLOAT) {
                result = [[UIImage alloc] initWithContentsOfFile:savePath];
                if (scale == PxImageScaleRetina) {
                    result = [[UIImage alloc] initWithCGImage:[result CGImage] scale:2.0 orientation:UIImageOrientationUp];
                }
                if (result != nil) {
                    [self storeImage:result forKey:key];
                }
            }
        }
    }
	return result;
}

- (UIImage *)imageForURLString:(NSString *)urlString interval:(NSTimeInterval)interval scale:(PxImageScale)scale {
    return [self imageForURL:[NSURL URLWithString:urlString] interval:interval scale:scale];
}

- (UIImage *)imageForKey:(NSString *)key {
	id result = nil;
	if (_memoryCacheSize > 0 ) {
		PxPair *tmp = [_dataCache objectForKey:key];
		if (tmp != nil) {
			// move the Image to the front of the cache again
			NSInteger oldIndex = [(NSNumber*)[tmp first] intValue];
			[tmp setFirst:[NSNumber numberWithInt:[_fifoCache count]-1]];
			[_fifoCache removeObjectAtIndex:oldIndex];
			[_fifoCache addObject:key];
			result = [tmp second];
		}
	}
	return result;
}

- (void)storeImage:(UIImage*)img forKey:(NSString*)key {
	if ( _memoryCacheSize > 0 ) {
		if ([_fifoCache count] == _memoryCacheSize) {
			[_dataCache removeObjectForKey:[_fifoCache objectAtIndex:0]];
			[_fifoCache removeObjectAtIndex:0];
		}
		[_fifoCache addObject:key];
		[_dataCache setValue:[PxPair pairWithFirst:[NSNumber numberWithInt:[_fifoCache count]-1] second:img] forKey:key];
	}
}

- (void)storeImage:(UIImage *)img forURL:(NSURL *)url header:(NSDictionary *)header {
    [self storeImage:img forURL:url header:header useJPG:NO];
}

- (void)storeImage:(UIImage *)img forURL:(NSURL *)url header:(NSDictionary *)header useJPG:(BOOL)useJPG {
    NSData *imageData;
    if (useJPG) {
        imageData = UIImageJPEGRepresentation(img, 1);
    } else {
        imageData = UIImagePNGRepresentation(img);
    }
    [super storeData:imageData forURL:url header:header];
    [self storeImage:img forKey:[self keyForURL:url]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
