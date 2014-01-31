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
//  PxWeakValue.m
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxWeakValue.h"

@implementation PxWeakValue

+ (id)weakValueWithValue:(id)value {
    return [[self alloc] initWithValue:value];
}

- (id)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (NSComparisonResult)compare:(id)anObject context:(void *)context {
    if ([anObject isKindOfClass:[self class]]) {
        return [_value compare:[(PxWeakValue *)anObject value] context:context];
    }
    return [_value compare:anObject context:context];
}

- (BOOL)isEqualToValue:(PxWeakValue *)anObject {
    return [[(PxWeakValue *)anObject value] isEqual:self.value];
}

- (BOOL)isNotBlank {
    return _value != nil;
}

@end
