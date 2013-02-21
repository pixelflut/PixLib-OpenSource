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
//  PxHTTPCache.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

extern NSString *const PxHTTPHeaderMimeType;
extern NSString *const PxHTTPHeaderIfModified;
extern NSString *const PxHTTPHeaderLastModified;
extern NSString *const PxHTTPHeaderIfRange;
extern NSString *const PxHTTPHeaderRange;

@interface PxHTTPCache : NSObject
@property(nonatomic, assign) BOOL shouldClearAutomatic;
@property(nonatomic, assign) NSUInteger automaticClearInterval;

- (NSString *)cacheSubDir;

- (void)clear;
- (void)clearFilesForURL:(NSURL *)url;
- (void)clearFilesOlderThan:(NSDate *)date;

- (NSString *)pathForURL:(NSURL *)url header:(NSDictionary **)header creationDate:(NSDate **)creationDate;

- (void)storeData:(NSData *)data forURL:(NSURL *)url header:(NSDictionary *)header;
- (void)storeDataFromFile:(NSString *)filePath forURL:(NSURL *)url header:(NSDictionary *)header;

@end
