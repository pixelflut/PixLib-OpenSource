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
//  NSNumber+PxCore.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

#define NR(__COUNT__) [NSNumber numberWithInteger:__COUNT__]
#define NRF(__COUNT__) [NSNumber numberWithFloat:__COUNT__]

/**
 * Adds convinient methods for iterating numbers and time-calculations. The time-calculations are similar to those found in the famous ruby-gem active-support.
 */
@interface NSNumber (PxCore)

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receivers boolValue evals **true**.
 @return YES if boolValue evals **true**, otherwise NO.
 */
- (BOOL)isNotBlank;

#pragma mark - Iterating Items
/** @name Iterating Items */

/** Invokes block ABS(n) times with n = self.intValue. Creates an array containing the values returned by the block.
 
 If n = self.intValue is negative, the block counts down until n is reached.
 @param block The block to call on each element in self.
 @return Array containing the values returned by each block call.
 @warning Raises an NSInvalidArgumentException if _block_ returns **nil**.
 @see [NSArray(PxCore) collectWithIndex:]
 */
- (NSMutableArray*)times:(id (^)(int nr))block;

#pragma mark - getting Dates
/** @name Creating Dates */

/** Returns a date with self.intValue seconds ago.
 @return The newly created date.
 */
- (NSDate *)ago;

/** Returns a date with self.intValue seconds in the future.
 @return The newly created date.
 */
- (NSDate *)since;

#pragma mark - getting TimeIntervals
/** @name Creating Dates */

/** Alias for years.
 @see years
 */
- (NSNumber *)year;

/** Returns the timeinterval n-years in seconds with n = self.intValue.
 @return The newly created number.
 */
- (NSNumber *)years;

/** Alias for months.
 @see months
 */
- (NSNumber *)month;

/** Returns the timeinterval n-months in seconds with n = self.intValue.
 @return The newly created number.
 */
- (NSNumber *)months;

/** Alias for days.
 @see days
 */
- (NSNumber *)day;

/** Returns the timeinterval n-days in seconds with n = self.intValue.
 @return The newly created number.
 */
- (NSNumber *)days;

/** Alias for hours.
 @see hours
 */
- (NSNumber *)hour;

/** Returns the timeinterval n-hours in seconds with n = self.intValue.
 @return The newly created number.
 */
- (NSNumber *)hours;

/** Alias for minutes.
 @see minutes
 */
- (NSNumber *)minute;

/** Returns the timeinterval n-minutes in seconds with n = self.intValue.
 @return The newly created number.
 */
- (NSNumber *)minutes;

/** Alias for seconds.
 @see seconds
 */
- (NSNumber *)second;

/** Returns the timeinterval n-seconds with n = self.intValue.
 @return The newly created number.
 */
- (NSNumber *)seconds;

@end
