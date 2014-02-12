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
//  PxNetService.h
//  PxNetKit
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxNetRequest.h"
#import "PxNetResult.h"
#import "PxNetCache.h"
#import "PxNetConnection.h"
#import <PxMarkupKit/PxMarkupKit.h>


// TODO: implement noCache options etc.
// The first PxRemoteOptionDisk can not combined with PxRemoteOptionRAM and PxRemoteOptionNoCache
typedef enum {
    PxNetOptionDisk    = 1<<0,   // Data will be stored in the Filesystem. Only way to add new cache-entries
    PxNetOptionRAM     = 1<<1,   // Data should be keept in Memory rather than be stored in the Filesystem. Result will not be cached, but if a cached value is available, the cached Value will be returned
    PxNetOptionNoCache = 1<<2,   // Should not be read from cache, no matter what
    PxNetOptionParse   = 1<<3    // Result should be parsed
} PxNetOption;

typedef enum {
    PxHTTPStatusCodeCache = 304,
	PxHTTPStatusCodeCacheRequestFailed = 313
} PxHTTPStatusCode;

typedef void (^PxNetResultBlock)(BOOL success, NSUInteger status, PxNetResult *result);
typedef void (^PxNetMultiResultBlock)(BOOL success, NSUInteger status, NSDictionary *results);

@interface PxNetService : NSObject <PxNetConnectionDelegate, PxAsyncParserDelegate>

- (void)fetchDataWithRequests:(NSArray *)requests background:(BOOL)background completion:(PxNetMultiResultBlock)completion;

- (void)fetchDataWithRequest:(PxNetRequest *)request background:(BOOL)background completion:(PxNetResultBlock)completion;

@end

@interface PxNetService (SubclassingHooks)
- (Class)cacheClass;
- (NSDictionary *)orMapping;
- (NSMutableURLRequest *)requestForURLString:(NSString *)URLString;
- (void)setUserAgent:(NSMutableURLRequest *)request;

@end
