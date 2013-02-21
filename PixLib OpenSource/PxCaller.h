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
//  PxCaller.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

// The first PxRemoteOptionDisk can not combined with PxRemoteOptionRAM and PxRemoteOptionNoCache
typedef enum {
    PxRemoteOptionDisk    = 1<<0,   // Data will be stored in the Filesystem. Only way to add new cache-entries
    PxRemoteOptionRAM     = 1<<1,   // Data should be keept in Memory rather than be stored in the Filesystem. Result will not be cached, but if a cached value is available, the cached Value will be returned
    PxRemoteOptionNoCache = 1<<2,   // Should not be read from cache, no matter what
    PxRemoteOptionParse   = 1<<3    // Result should be parsed
} PxRemoteOption;

@interface PxCaller : NSObject;
@property(nonatomic, strong) id target;
@property(nonatomic, assign) SEL action;
@property(nonatomic, strong) id userInfo;
@property(nonatomic, assign) Class expectedClass;
@property(nonatomic, assign) unsigned int options;

+ (id)callerWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo options:(unsigned int)options;
- (id)initWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo options:(unsigned int)options;

- (BOOL)canQueue;

@end
