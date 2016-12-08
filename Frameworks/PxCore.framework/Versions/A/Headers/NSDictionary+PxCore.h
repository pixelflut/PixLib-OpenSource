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
//  NSDictionary+PxCore.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

@class PxPair<FirstType, SecondType>;

/**
 * Most of the methods found here are similar to methods in Ruby Classes [Hash](http://www.ruby-doc.org/core-1.9.3/Hash.html) and [Enumerable](http://www.ruby-doc.org/core-1.9.3/Enumerable.html)
 */
@interface NSDictionary<KeyType, ValueType> (PxCore)

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains any elements.
 @return YES if count > 0, otherwise NO.
 */
- (BOOL)isNotBlank;

#pragma mark - Aggregating Items
/** @name Aggregating Items */

/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 
 Raises an Exception if _block_ returns nil. Use collect:skipNil: to avoid this pitfall if appropriate.
 @param block The block to call on each element in self.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil**.
 @see collect:skipNil:
 */
- (NSMutableArray *)collect:(id (^)(KeyType key, ValueType value))block;

/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 @param block The block to call on each element in self.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil** and _skipNil_ is not **true**.
 @see collect:
 */
- (NSMutableArray *)collect:(id (^)(KeyType key, ValueType value))block skipNil:(BOOL)skipNil;

/** Invokes block once for each element of self. Creates a new Dictionary with the same keys containing the coresponding values returned by the block.
 @param block The block to call on each elements in the Array.
 @return Dictionary with the same keys containing the coresponding values returned by the block.
 @warning Raises an NSInvalidArgumentException if the _block_ returns **nil**
 */
- (NSMutableDictionary<KeyType, id> *)map:(id (^)(KeyType key, ValueType value))block;

/** Returns a new Dictionary containing all elements of the receiver for which block returns **false**.
 @param block The block to call on each elements in self.
 @return Dictionary containing the elements for which _block_ returns **false**
 @see selectAll:
 */
- (NSMutableDictionary<KeyType, ValueType> *)reject:(BOOL (^)(KeyType key, ValueType value))block;

/** Returns a new Dictionary containing all elements of the receiver for which block returns **true**.
 @param block The block to call on each elements in self.
 @return Dictionary containing the elements for which _block_ returns **true**
 @see reject:
 */
- (NSMutableDictionary<KeyType, ValueType> *)selectAll:(BOOL (^)(KeyType key, ValueType value))block;


#pragma mark - Iterating Items
/** @name Iterating Items */

/** Calls _block_ on each element of self.
 @param block The block called on each element.
 @return self
 */
- (NSDictionary *)eachPair:(void (^)(KeyType key, ValueType value))block;


#pragma mark - Accessing Items
/** @name Accessing Items */

/** Returns the value associated with a given key and this key in a PxPair.
 @param key The key for which to return the corresponding value.
 @return The Pair associated with _key_, or **nil** if no value is associated with _key_.
 */
- (PxPair<KeyType, ValueType> *)pairForKey:(NSString *)key;


#pragma mark - Searching Items
/** @name Searching Items */

/** Searches for the first element in the receiver the block returns **true**.
 @param block The block to call on the elements in _self_
 @return The first item _block_ returns **true**
 @see include:
 */
- (PxPair<KeyType, ValueType> *)find:(BOOL (^)(KeyType key, ValueType value))block;

/** Returns either or not the receiver contains an element for which the block evals **true**.
 @param block The block to call on the elements in self
 @return Boolean either or not _self_ contains an Element meeting the conditions of _block_
 @see find:
 */
- (BOOL)include:(BOOL (^)(KeyType key, ValueType value))block;


#pragma mark - Working with Query-Strings (Get Parameters)
/** @name Working with Query-Strings (Get Parameters) */

/** Returns a String representating the receiver suitable for Query-Strings.
 @return The Query-String.
 @see stringForQuery:
 */
- (NSString *)stringForQuery;

/** Returns a String representating the receiver suitable for Query-Strings.
 @param sorted If **true** the keys are ordered ascending.
 @return The Query-String.
 @see stringForQuery
 */
- (NSString *)stringForQuery:(BOOL)sorted;

@end
