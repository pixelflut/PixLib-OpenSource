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
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

/**
 * Use **PxPair** if you have to store a single key-value pair.
 */
@interface PxPair : NSObject <NSCoding>

/** The first element of the pair */
@property(nonatomic, strong) id first;

/** The second element of the pair */
@property(nonatomic, strong) id second;

#pragma mark - Creating a Pair
/** @name Creating a Pair */

/** Creates and returns a pair containing given objects.
 @param first The first object.
 @param second The second object.
 @return A pair containing the given objects.
 */
+ (id)pairWithFirst:(id)first second:(id)second;


#pragma mark - Initializing a Pair
/** @name Initializing a Pair */

/** Initializes a newly allocated pair by storing the given objects.
 @param first The first object.
 @param second The second object.
 @return A pair initialized to include the objects _first_ and _second_.
 */
- (id)initWithFirst:(id)first second:(id)second;


#pragma mark - Comparing Pairs
/** @name Comparing Pairs */

/** Compares the receiving pair to another pair.
 
 Two pairs have equal contents if _first_ and _second_ satisfy the isEqual: test.
 @param otherPair A Pair.
 @return YES if the contents of otherPair are equal to the contents of the receiving pair, otherwise NO.
 */
- (BOOL)isEqualToPair:(PxPair *)otherPair;


#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains any elements.
 @return **YES** if either _first_ or _second_ is not **nil**, otherwise **NO**.
 */
- (BOOL)isNotBlank;


#pragma mark - Modern Objective-C Accessor

- (void)setObject:(id)anObject forKeyedSubscript:(NSString *)title;
- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
