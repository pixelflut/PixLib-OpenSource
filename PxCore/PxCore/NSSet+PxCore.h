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
//  NSSet+PxCore.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

@class PxPair<FirstType, SecondType>;

/**
 * Most of the methods found here are similar to methods in Ruby Class [Enumerable](http://www.ruby-doc.org/core-1.9.3/Enumerable.html)
 */
@interface NSSet<ObjectType> (PxCore)

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains any elements.
 @return YES if count > 0, otherwise NO.
 */
- (BOOL)isNotBlank;

#pragma mark - Aggregating Items
/** @name Aggregating Items */

/** Invokes block once for each element in the receiver. Creates a new set containing the values returned by the block.
 
 Raises an Exception if _block_ returns nil. Use collect:skipNil: to avoid this pitfall if appropriate.
 @param block The block to call on each element in the receiver.
 @return Set containing the values returned by each block call
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil**.
 @see collect:skipNil:
 */
- (NSMutableSet *)collect:(id (^)(ObjectType obj))block;

/** Invokes block once for each element in the receiver. Creates a new set containing the values returned by the block.
 @param block The block to call on each element in the receiver.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @return Set containing the values returned by each block call
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil** and _skipNil_ is **false**.
 @see collect:
 */
- (NSMutableSet *)collect:(id (^)(ObjectType obj))block skipNil:(BOOL)skipNil;

/** Returns a **NSMutableDictionary**, which keys are evaluated result from the block, and values are **NSMutableSets** of elements in the receiver corresponding to the key.
 @param block The block to call on each elements in the receiver.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @return The Dictionary containing the grouped values.
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil** and _skipNil_ is not **true**.
 */
- (NSMutableDictionary *)groupBy:(id<NSCopying> (^)(ObjectType obj))block skipNil:(BOOL)skipNil;

/** Returns two sets, the first containing the elements in the receiver for which the _block_ evaluates to **true**, the second containing the rest.
 @param block The block to call on each elements in the receiver.
 @return two sets stored in a PxPair.
 */
- (PxPair<NSSet<ObjectType> *, NSSet<ObjectType>*> *)partition:(BOOL (^)(ObjectType obj))block;

/** Returns an set containing all elements in the receiver for which block returns **false**.
 @param block The block to call on each elements in the receiver.
 @return Set containing the elements for which _block_ returns **false**.
 @see selectAll:
 */
- (NSMutableSet<ObjectType> *)reject:(BOOL (^)(ObjectType obj))block;

/** Returns an set containing all elements in the receiver for which block returns **true**.
 @param block The block to call on each elements in the receiver.
 @return Set containing the elements for which _block_ returns **true**.
 @see selectAll:
 */
- (NSMutableSet<ObjectType> *)selectAll:(BOOL (^)(ObjectType obj))block;


#pragma mark - Iterating Items
/** @name Iterating Items */

/** Calls _block_ on each element in the receiver.
 @param block The block called on each element.
 @return self
 */
- (instancetype)each:(void (^)(ObjectType obj))block;


#pragma mark - Searching Items
/** @name Searching Items */

/** Searches for the first item in the receiver the block returns **true**.
 @param block The block to call on the elements in _self_
 @return The first item _block_ returns **true**
 @see include:
 */
- (ObjectType)find:(BOOL (^)(ObjectType obj))block;

/** Check either or not the receiver contains an object for which the block evals **true**.
 @param block The block to call on the elements in the Set
 @return Boolean either or not _self_ contains an object meeting the conditions of _block_
 @see find:
 */
- (BOOL)include:(BOOL (^)(ObjectType obj))block;

/** Returns the element in the receiver which the block evals as max value.
 @param block The block to compare the current max-value element with the next element
 @return The element which the block evals as max.
 @see min:
 @see minMax:
 */
- (ObjectType)max:(NSComparisonResult (^)(ObjectType a, ObjectType b))block;

/** Returns the element in the receiver which the block evals as min-value.
 @param block The block to compare the current min-value element with the next element
 @return The element which the block evals as min.
 @see max:
 @see minMax:
 */
- (ObjectType)min:(NSComparisonResult (^)(ObjectType a, ObjectType b))block;

/** Returns the elements in the receiver which the block evals as min-value and max-value.
 @param block The block to compare the current min(max)-value element with the next element
 @return The elements which the block evals as min and max.
 @see max:
 @see min:
 */
- (PxPair<ObjectType, ObjectType> *)minMax:(NSComparisonResult (^)(ObjectType a, ObjectType b))block;

#pragma mark - Counting Items
/** @name Counting Items */

/** Calls _block_ on each element in the receiver, counts the number of times _block_ returns **true**.
 @param block The block called on each element.
 @return The number of elements in self for which the _block_ evals **true**.
 @see sum:
 */
- (NSUInteger)count:(BOOL (^)(ObjectType obj))block;

/** Calls _block_ on each element in the receiver, sums the values returned by _block_.
 @param block The block called on each element.
 @return The sum.
 @see count:
 */
- (double)sum:(double (^)(ObjectType obj))block;

#pragma mark - Ordering Items
/** @name Ordering and reorganizing Items */

/** Returns a new array created by sorting self.
 @param block The block to determine the sort-order.
 @return The sorted Array.
 */
- (NSMutableArray *)sort:(NSComparisonResult (^)(ObjectType a, ObjectType b))block;


@end
