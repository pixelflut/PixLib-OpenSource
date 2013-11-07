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
//  PxRange.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

#define RANGE(__LOC__, __LEN__) [PxRange rangeWithNSRange:NSMakeRange(__LOC__, __LEN__)]

#define NSRangeMake(location, length) NSMakeRange(location, length)

/**
 * Object oriented wrapper for _NSRange_.
 */
@interface PxRange : NSObject {
@public
    NSRange range;
}

/** The wrapped range struct */
@property(nonatomic, assign) NSRange range;

#pragma mark - Creating a Range
/** @name Creating a Range */

/** Creates and returns a range with the given _NSRange_.
 @param range The range.
 @return A range with the given _NSRange_.
 */
+ (PxRange *)rangeWithNSRange:(NSRange)range;


#pragma mark - Initializing a Range
/** @name Initializing a Range */

/** Initializes a newly allocated range by assigning the given _NSRange_.
 @param range The range.
 @return A range initialized by assigning the given _NSRange_.
 */
- (id)initWithNSRange:(NSRange)range;


#pragma mark - Iterating Content
/** @name Iterating Content */

/** Invokes block once for each element of the receiver. Creates a new array containing the values returned by the block.
 
 Raises an Exception if _block_ returns nil. Use collect:skipNil: to avoid this pitfall if appropriate.
 @param block The block to call on each element in the receiver.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil**.
 @see collect:skipNil:
 */
- (NSMutableArray *)collect:(id (^)(NSInteger nr))block;

/** Invokes block once for each element of the receiver. Creates a new array containing the values returned by the block.
 @param block The block to call on each element in the receiver.
 @param skipNil Boolean either or not nil-Values should be ignored.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil**, and _skipNil_ is **false**.
 @see collect:
 */
- (NSMutableArray *)collect:(id (^)(NSInteger nr))block skipNil:(BOOL)skipNil;

/** Invokes block once for each element of the receiver. Returns the receiver.
 @param block The block to call on each element in self.
 @return The receiver.
 @see collect:
 */
- (PxRange *)eachIndex:(void (^)(NSInteger nr))block;

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains a valid range.
 @return **YES** if the length of the range != 0, otherwise **NO**.
 */
- (BOOL)isNotBlank;

@end
