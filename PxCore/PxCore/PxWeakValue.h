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
//  PxWeakValue.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "NSObject+PxCore.h"

/**
 * Use this class to store weak-references where you have not the option to set the reference weak, for example in arrays.
 */
@interface PxWeakValue<ObjectType> : NSObject
@property(nonatomic, weak) ObjectType value;

#pragma mark - Creating a WeakValue
/** @name Creating a WeakValue */

/** Creates and returns a weakValue with the given _value_.
 @param value The value.
 @return A weakValue with the given _value_.
 */
+ (instancetype)weakValueWithValue:(ObjectType)value;


#pragma mark - Initializing a WeakValue
/** @name Initializing a WeakValue */

/** Initializes a newly allocated weakValue by assigning the given _value_.
 @param value The value.
 @return A weakValue initialized by assigning the given _value_.
 */
- (instancetype)initWithValue:(ObjectType)value;

#pragma mark - Comparing WeakValues
/** @name Comparing WeakValues */

/** Compares the receiving weakValue to another weakValue.
 
 Two weakValue have equal contents if _value_ satisfys the isEqual: test.
 @param otherValue A weakValue.
 @return **YES** if the _value_ of otherValue are equal to the contents of the receiving weakValue, otherwise **NO**.
 */
- (BOOL)isEqualToValue:(PxWeakValue<ObjectType> *)otherValue;


- (NSComparisonResult)compare:(id)anObject context:(void *)context;

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains a value.
 @return **YES** if _value_ is not **nil**, otherwise **NO**.
 */
- (BOOL)isNotBlank;

@end
