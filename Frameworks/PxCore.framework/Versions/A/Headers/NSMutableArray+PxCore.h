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
//  NSMutableArray+PxCore.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

/**
 * Most of the methods found here are similar to methods in Ruby Classes [Array](http://www.ruby-doc.org/core-1.9.3/Array.html) and [Enumerable](http://www.ruby-doc.org/core-1.9.3/Enumerable.html)
 */
@interface NSMutableArray<ObjectType> (PxCore)

#pragma mark - Adding Objects
/** @name Adding Objects */

/** Inserts a given object at the end of the array.
 @param obj The object to add to the end of the array's content.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @warning Raises an NSInvalidArgumentException if _obj_ is **nil** and _skipNil_ is not **true**
 */
- (void)addObject:(ObjectType)obj skipNil:(BOOL)skipNil;


#pragma mark - Removing Objects
/** @name Removing Objects */

/** Deletes every element from the receiver for which block evaluates to true.
 @param block The block to determine if a element should be removed.
 @return self.
 */
- (NSMutableArray<ObjectType> *)deleteIf:(BOOL (^)(ObjectType obj))block;


#pragma mark - Rearranging Content
/** @name Rearranging Content */

/** Sorts the array using the comparison method specified by a given Block.
 @param block The block to determine the sort-order.
 @return self.
 */
- (NSMutableArray<ObjectType> *)sort:(NSComparisonResult (^)(ObjectType a, ObjectType b))block;

@end
