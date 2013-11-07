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
//  NSArray+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "PxPair.h"

/**
 * Most of the methods found here are similar to methods in Ruby Classes [Array](http://www.ruby-doc.org/core-1.9.3/Array.html) and [Enumerable](http://www.ruby-doc.org/core-1.9.3/Enumerable.html)
 */
@interface NSArray (PixLib)

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains any elements.
 @return YES if count > 0, otherwise NO.
 */
- (BOOL)isNotBlank;

#pragma mark - Aggregating Items
/** @name Aggregating Items */

/** Invokes block once for each element of self. Creates a new array for each consecutive elements returning **true**.
 @param block The block to call on each element in self
 @return Array containing arrays of consecutive elements.
 */
- (NSMutableArray *)cluster:(BOOL (^)(id obj))block;

/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 
 Raises an Exception if _block_ returns nil. Use collect:skipNil: to avoid this pitfall if appropriate.
 @param block The block to call on each element in self
 @return Array containing the values returned by each block call
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil**.
 @see collect:skipNil:
 @see collectWithIndex:
 @see collectWithIndex:skipNil:
 @see collectWithIndex:skipNil:flatten:
 */
- (NSMutableArray *)collect:(id (^)(id obj))block;


/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 @param block The block to call on each elements in the Array.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil** and _skipNil_ is not **true**.
 @see collect:
 @see collectWithIndex:
 @see collectWithIndex:skipNil:
 @see collectWithIndex:skipNil:flatten:
 */
- (NSMutableArray *)collect:(id (^)(id obj))block skipNil:(BOOL)skipNil;


/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 
 Raises an Exception if _block_ returns nil. Use collectWithIndex:skipNil: to avoid this pitfall if appropriate.
 @param block The block to call on each elements in the Array
 @return Array containing the values returned by each block call
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil**
 @see collect:
 @see collect:skipNil:
 @see collectWithIndex:skipNil:
 @see collectWithIndex:skipNil:flatten:
 */
- (NSMutableArray *)collectWithIndex:(id (^)(id obj, unsigned int index))block;


/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 @param block The block to call on each elements in the Array
 @param skipNil Boolean either or not nil-Values should be ignored
 @return Array containing the values returned by each block call
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil** and _skipNil_ is not **true**
 @see collect:
 @see collect:skipNil:
 @see collectWithIndex:
 @see collectWithIndex:skipNil:flatten:
 */
- (NSMutableArray *)collectWithIndex:(id (^)(id obj, unsigned int index))block skipNil:(BOOL)skipNil;


/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 @param block The block to call on each elements in the Array
 @param skipNil Boolean either or not nil-Values should be ignored
 @param flatten Boolean either or not the result should be flatten down to an 1-Dimensional Array
 @return Array containing the values returned by each block call
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil** and _skipNil_ is not **true**
 @see collect:
 @see collect:skipNil:
 @see collectWithIndex:
 @see collectWithIndex:skipNil:
 */
- (NSMutableArray *)collectWithIndex:(id (^)(id obj, unsigned int index))block skipNil:(BOOL)skipNil flatten:(BOOL)flatten;

/** Invokes block on each element of self until the block returns **false**. Creates a new array containing the remaining items 
 @param block The block to call on the elements in the Array
 @return Array containing the remaining values
 @see take:
 */
- (NSMutableArray *)drop:(BOOL (^)(id obj, unsigned int index))block;

/** Invokes block once for each element of self. Creates a Dictionary containing the values returned by the block as keys for the elements.
 @param block The block to call on each elements in the Array
 @return Dictionary containing the values returned by the block as keys for the elements
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil**
 @see indexBy:skipNil:
 */
- (NSMutableDictionary *)indexBy:(id<NSCopying> (^)(id obj))block;

/** Invokes block once for each element of self. Creates a Dictionary containing the values returned by the block as keys for the elements.
 @param block The block to call on each elements in the Array
 @param skipNil Boolean either or not nil-Values should be ignored
 @return Dictionary containing the values returned by the block as keys for the elements
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil** and _skipNil_ is not **true**
 @see indexBy:
 */
- (NSMutableDictionary *)indexBy:(id<NSCopying> (^)(id obj))block skipNil:(BOOL)skipNil;

/** Invokes block once for each element of self. The returnvalue of the previous element is given to the current element as parameter _memo_.
 @param initial The _memo_ for the first element
 @param block The block to call on each elements in the Array
 @return The returnvalue of the last element
 */
- (id)inject:(id)initial block:(id (^)(id memo, id obj))block;

/** Returns a **NSMutableDictionary**, which keys are evaluated result from the block, and values are **NSMutableArrays** of elements in self corresponding to the key.
 @param block The block to call on each elements in the Array
 @param skipNil Boolean either or not nil-Values should be ignored
 @return The Dictionary containing the grouped values
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil** and _skipNil_ is not **true**
 */
- (NSMutableDictionary *)groupBy:(id<NSCopying> (^)(id obj))block skipNil:(BOOL)skipNil;

/** Returns _pageSize_-length arrays containing the elements of self. The last array might be smaller than _pageSize_.
 @param pageSize Number of elements stored in one array
 @return The **pages**
 */
- (NSMutableArray *)paginate:(int)pageSize;

/** Returns two arrays, the first containing the elements of self for which the _block_ evaluates to **true**, the second containing the rest.
 @param block The block to call on each elements in the Array
 @return two arrays
 */
- (PxPair *)partition:(BOOL (^)(id obj))block;

/** Returns an array containing all elements of self for which block returns **false**.
 @param block The block to call on each elements in the Array
 @return Array containing the elements for which _block_ returns **false**
 @see selectAll:
 @see selectExpectOrdered:
 */
- (NSMutableArray *)reject:(BOOL (^)(id obj))block;

/** Returns an array containing all elements of self in an random order.
 @return Array containing the elements in random order
 */
- (NSMutableArray *)random;

/** Returns an array containing all elements of self for which block returns **true**.
 @param block The block to call on each elements in the Array
 @return Array containing the elements for which _block_ returns **true**
 @see reject:
 @see selectExpectOrdered:
 */
- (NSMutableArray *)selectAll:(BOOL (^)(id obj))block;

/** Returns an array containing all elements of self for which block returns **true**. If stop evals **true**, the enumaration stops and the current result is returned. This is espacialy helpfull if a range of elements in an ordered Array should be selected.
 @param block The block to call on each elements in the Array.
 @return Array containing the elements for which _block_ returns **true**
 @see reject:
 @see selectAll:
 */
- (NSMutableArray *)selectExpectOrdered:(BOOL (^)(id obj, BOOL *stop))block;

/** Invokes block on each element of self until the block returns **false**.
 @param block The block to call on the elements in the Array
 @return Array containing the values until _block_ returned **false**
 @see drop:
 */
- (NSMutableArray*)take:(BOOL (^)(id obj, NSUInteger index))block;


#pragma mark - Searching Items
/** @name Searching Items */

/** Searches for the first item the block returns **true**.
 @param block The block to call on the elements in _self_
 @return The first item _block_ returns **true**
 @see index:
 @see include:
 */
- (id)find:(BOOL (^)(id obj))block;

/** Check either or not the Array contains an Object.
 @param block The block to call on the elements in the Array
 @return Boolean either or not _self_ contains an Object meeting the conditions of _block_
 @see index:
 @see find:
 */
- (BOOL)include:(BOOL (^)(id obj))block;

/** Searches for the index of the first item the block returns **true**.
 @param block The block to call on the elements in _self_
 @return The index of the first item _block_ returns **true**
 @see find:
 @see include:
 */
- (NSUInteger)index:(BOOL (^)(id obj))block;

/** Returns the element in self which the block evals as max value.
 @param block The block to compare the current max-value element with the next element
 @return The element which the block evals as max.
 @see min:
 @see minMax:
 */
- (id)max:(NSComparisonResult (^)(id a, id b))block;

/** Returns the element in self which the block evals as min-value.
 @param block The block to compare the current min-value element with the next element
 @return The element which the block evals as min.
 @see max:
 @see minMax:
 */
- (id)min:(NSComparisonResult (^)(id a, id b))block;

/** Returns the elements in self which the block evals as min-value and max-value.
 @param block The block to compare the current min(max)-value element with the next element
 @return The elements which the block evals as min and max.
 @see max:
 @see min:
 */
- (PxPair *)minMax:(NSComparisonResult (^)(id a, id b))block;

#pragma mark - Iterating Items
/** @name Iterating Items */

/** Iterates the given block for each array of consecutive <n> elements. If self _count_ is smaller than _number_ the block is called once with self.
 @param number The number of elements provided to _block_
 @param block The block called on each element-array.
 @return self
 @see each:
 @see eachWithIndex:
 @see eachSlice:block:
 */
- (NSArray *)eachCons:(unsigned int)number block:(void (^)(NSArray *objs))block;

/** Iterates the given block for each slice of <n> elements.
 @param number The number of elements provided to _block_
 @param block The block called on each element-array.
 @return self
 @see each:
 @see eachWithIndex:
 @see eachCons:block:
 */
- (NSArray *)eachSlice:(unsigned int)number block:(void (^)(NSArray *objs))block;

/** Calls _block_ on each element of self.
 @param block The block called on each element.
 @return self
 @see eachWithIndex:
 @see eachCons:block:
 @see eachSlice:block:
 */
- (NSArray *)each:(void (^)(id obj))block;

/** Calls _block_ on each element of self, also providing the index of the element in self.
 @param block The block called on each element.
 @return self
 @see each:
 @see eachCons:block:
 @see eachSlice:block:
 */
- (NSArray *)eachWithIndex:(void (^)(id obj, unsigned int index))block;

#pragma mark - Counting Items
/** @name Counting Items */

/** Calls _block_ on each element of self, counts the number of times _block_ returns **true**.
 @param block The block called on each element.
 @return The number of elements in self for which the _block_ evals **true**.
 @see sum:
 */
- (unsigned int)count:(BOOL (^)(id obj))block;

/** Calls _block_ on each element of self, sums the values returned by _block_.
 @param block The block called on each element.
 @return The sum.
 @see count:
 */
- (float)sum:(float (^)(id obj))block;

#pragma mark - Accessing Items
/** @name Accessing Items */

/** Accessing the first Object of self
 @return The object located at index _0_ or **nil** if self is empty.
 */
- (id)firstObject;

/** Returns the object located at _index_
 @param index Index of the Object
 @param handleBounds Either or not an NSRangeException should be trown or **nil** should be returnd instead
 @return The object located at _index_ or **nil**
 @warning If _index_ is beyond the end of the array (that is, if _index_ is greater than or equal to the value returned by **count**) and _handleBounds_ is **false**, an NSRangeException is raised.
 */
- (id)objectAtIndex:(unsigned int)index handleBounds:(BOOL)handleBounds;


#pragma mark - Ordering and reorganizing Items
/** @name Ordering and reorganizing Items */

/** Returns a new array that is n-dimensions lower than self (recursively). That is, for every element that is an array, extract its elements into the new array. The level argument determines the level of recursion to flatten.
 @param level The number of recursions to flatten. Provide **-1** to get a 1-Dimensional Array.
 @return The flattened Array.
 */
- (NSMutableArray *)flatten:(int)level;

/** Returns a new array created by sorting self.
 @param block The block to determine the sort-order.
 @return The sorted Array.
 */
- (NSMutableArray *)sort:(NSComparisonResult (^)(id a, id b))block;

/** Returns a new array by removing duplicate values in self. If a block is given, it will use the return value of the block for comparison. 
 @return Array with removed duplicates.
 @see uniq:
 */
- (NSMutableArray *)uniq;

/** Returns a new array by removing duplicate values in self. The return value of the block will be used for comparison.
 @param block The block to compare elements.
 @return Array with removed duplicates
 @see uniq
 */
- (NSMutableArray *)uniq:(id<NSCopying> (^)(id obj))block;

@end
