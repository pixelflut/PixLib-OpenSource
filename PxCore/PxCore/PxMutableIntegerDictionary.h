//
//  PxMutableIntegerDictionary.h
//  PxCore-OpenSource
//
//  Created by Jonathan Cichon on 01.07.13.
//  Copyright (c) 2013 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxPair.h"

@interface PxMutableIntegerDictionary : NSObject

- (NSUInteger)count;
- (void)setObject:(id)object forKey:(NSInteger)key;
- (id)objectForKey:(NSInteger)key;

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
- (NSMutableArray *)collect:(id (^)(NSInteger key, id value))block;

/** Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 @param block The block to call on each element in self.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil** and _skipNil_ is not **true**.
 @see collect:
 */
- (NSMutableArray *)collect:(id (^)(NSInteger key, id value))block skipNil:(BOOL)skipNil;


#pragma mark - Iterating Items
/** @name Iterating Items */

/** Calls _block_ on each element of self.
 @param block The block called on each element.
 @return self
 */
- (PxMutableIntegerDictionary *)eachPair:(void (^)(NSInteger key, id value))block;


#pragma mark - Accessing Items
/** @name Accessing Items */

/** Returns the value associated with a given key and this key in a PxPair.
 @param key The key for which to return the corresponding value.
 @return The Pair associated with _key_, or **nil** if no value is associated with _key_.
 */
- (PxPair *)pairForKey:(NSInteger)key;


#pragma mark - Searching Items
/** @name Searching Items */

/** Searches for the first element in the receiver the block returns **true**.
 @param block The block to call on the elements in _self_
 @return The first item _block_ returns **true**
 @see include:
 */
- (id)find:(BOOL (^)(NSInteger key, id value))block;

/** Returns either or not the receiver contains an element for which the block evals **true**.
 @param block The block to call on the elements in self
 @return Boolean either or not _self_ contains an Element meeting the conditions of _block_
 @see find:
 */
- (BOOL)include:(BOOL (^)(NSInteger key, id value))block;

@end
