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
//  PxPair.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

/**
 * Use **PxPair** if you have to store a single key-value pair.
 */
@interface PxPair : NSObject <NSCoding>
@property(nonatomic, strong) id first;
@property(nonatomic, strong) id second;

+ (id)pairWithFirst:(id)first second:(id)second;
- (id)initWithFirst:(id)first second:(id)second;

- (BOOL)isEqualToPair:(PxPair *)object;

- (BOOL)isNotBlank;

#pragma mark - Key/Value alias
+ (id)pairWithKey:(id)key value:(id)value;
- (id)initWithKey:(id)key value:(id)value;

- (void)setKey:(id)key;
- (void)setValue:(id)value;
- (id)key;
- (id)value;

#pragma mark - Modern Objective-C Accessor
- (void)setObject:(id)anObject forKeyedSubscript:(NSString *)title;
- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
