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
//  PxRange.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxRange.h"
#import "PxCore.h"

@implementation PxRange
@synthesize range;

+ (id)rangeWithNSRange:(NSRange)range {
    return [[[self class] alloc] initWithNSRange:range];
}

- (id)initWithNSRange:(NSRange)r {
    self = [super init];
    if (self) {
        range = r;
    }
    return self;
}

- (NSMutableArray*)collect:(id (^)(int index))block {
    return [self collect:block skipNil:NO];
}

- (NSMutableArray*)collect:(id (^)(int index))block skipNil:(BOOL)skipNil {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:range.length];
    int start = range.location;
    int end = range.location+range.length;
    
    for (int i = 0; i<ABS(end-start); i++) {
        int index = start + (ABS(end-start)/(end-start))*i;
        [array addObject:block(index) skipNil:skipNil];
    }
    return array;
}

- (BOOL)isNotBlank {
    return self.range.length > 0;
}

@end
