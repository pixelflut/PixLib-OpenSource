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
//  NSDate+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "PxXMLHelper.h"

#define SECONDS_PER_MINUTE 60.0
#define SECONDS_PER_HOUR 3600.0
#define SECONDS_PER_DAY 86400.0
#define SECONDS_PER_MONTH 2592000.0
#define SECONDS_PER_YEAR 31536000

typedef struct {
    NSInteger year; NSInteger month; NSInteger day; NSInteger hour; NSInteger minute; NSInteger second;
} PxDateOptions;

/**
 * Adds convinient methods for initializing, setting and accessing NSDate
 */
@interface NSDate (PixLib) <PxXMLAttribute>

#pragma mark - Creating Dates
/** @name Creating Dates */

/** Returns a new NSDate with the components set to the given values. Default date is 0000-01-01 00:00:00
 @param block Option block to specify the values for each component.
 @return The newly created date.
 */
+ (NSDate *)dateWithOptions:(void (^)(PxDateOptions *options))block;


#pragma mark - Creating Dates
/** @name Calculating Dates */

/** Returns a new NSDate with the components set to the given values.
 @param block Option block to specify the values for each component.
 @return The newly created date.
 */
- (NSDate *)dateWithOptions:(void (^)(PxDateOptions *options))block;

/** Returns a new NSDate with all time components set to zero.
 @return The newly created date.
 */
- (NSDate *)dateAtBeginningOfDay;

/** Returns a new NSDate with each given value added to the respective component.
 @param block Option block to specify the values for each component.
 @return The newly created date.
 */
- (NSDate *)advance:(void (^)(PxDateOptions *options))block;

#pragma mark - Representing Dates as Strings
/** @name Representing Dates as Strings */

/** Returns a String representating the receiver in a given format.
 @param format The date format for the receiver.
 @return A string representation of self formatted using the _format_ settings.
 */
- (NSString *)stringWithFormat:(NSString *)format;

/** Returns a String representating the receiver in a given style.
 @param style The date style for the receiver.
 @return A string representation of self formatted using the _style_ settings.
 */
- (NSString *)stringWithStyle:(NSDateFormatterStyle)style;

/** Returns a String representating the receiver in a given style.
 @param dateStyle The date style for the receiver.
 @param timeStyle The time style for the receiver.
 @return A string representation of self formatted using the _style_ settings.
 */
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

/** Returns a String representating the distance between the receiver and the current time in a human readable way.
 @return A string.
 @see distanceOfTimeInWords:
 */
- (NSString *)distanceOfTimeInWords;

/** Returns a String representating the distance between the receiver and a given date in a human readable way.
 @param date The reference date.
 @return A string.
 @see distanceOfTimeInWords
 */
- (NSString *)distanceOfTimeInWords:(NSDate *)date;

#pragma mark - Getting Date Components
/** @name Getting Date Components */

/** Returns the number of years between the receiver and the current time.
 @return Number of years.
 */
- (NSInteger)yearsFromNow;

/** Returns the number of days between the receiver and the current time.
 @param annualy If **true** the distance is not creater than the number of days in one year.
 @return Number of days.
 @see daysFromNowAnnually
 @see daysFromNow
 */
- (NSInteger)daysFromNow:(Boolean)annualy;

/** Returns the number of days between the receiver and the current time. The year component is ignored.
 @return Number of days.
 @see daysFromNow:
 @see daysFromNow
 */
- (NSInteger)daysFromNowAnnually;

/** Returns the number of days between the receiver and the current time.
 @return Number of days.
 @see daysFromNow:
 @see daysFromNowAnnually
 */
- (NSInteger)daysFromNow;

/** Returns the year component of the receiver.
 @return The year.
 @see month
 @see day
 @see hour
 @see minute
 @see second
 */
- (NSInteger)year;

/** Returns the month component of the receiver.
 @return The month.
 @see year
 @see day
 @see hour
 @see minute
 @see second
 */
- (NSInteger)month;

/** Returns the day component of the receiver.
 @return The day.
 @see year
 @see month
 @see hour
 @see minute
 @see second
 */
- (NSInteger)day;

/** Returns the hour component of the receiver.
 @return The hour.
 @see year
 @see month
 @see day
 @see minute
 @see second
 */
- (NSInteger)hour;

/** Returns the minute component of the receiver.
 @return The minute.
 @see year
 @see month
 @see day
 @see hour
 @see second
 */
- (NSInteger)minute;

/** Returns the second component of the receiver.
 @return The second.
 @see year
 @see month
 @see day
 @see hour
 @see minute
 */
- (NSInteger)second;

#pragma mark - Comparing Dates
/** @name Comparing Dates */

/** Returns either or not the receiver is Today 
 @return Yes if the receiver is Today
 */
- (BOOL)isToday;

@end
