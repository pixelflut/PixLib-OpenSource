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
//  NSString+PixLib.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "PxUIkitSupport.h"
#import "PxXMLHelper.h"

/**
 * PixLib Category for NSString
 */
@interface NSString (PixLib) <PxXMLAttribute>

#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Checks either or not the receiver contains any characters.
 @return YES if length > 0, otherwise NO.
 */
- (BOOL)isNotBlank;

#pragma mark - Identifying and Comparing Strings
/** @name Identifying and Comparing Strings */

/** Returns an NSComparisonResult value that indicates whether the receiver is greater than, equal to, or less than a given string.
 @param string The object to compare the receiver with.
 @param context Userdefined context to alter the result.
 @return NSOrderedAscending if the string is greater than the receiver, NSOrderedSame if they’re equal, and NSOrderedDescending if the string is less than the receiver.
 */
- (NSComparisonResult)compare:(NSString *)string context:(void *)context;

/** Returns the receiver if [NSString(PixLib) isNotBlank] is **true**, otherwise **nil**.
 @return self if [NSString(PixLib) isNotBlank] is **true**, otherwise **nil**.
 */
- (NSString *)validString;

/** Returns **YES** if the receiver is a valid Email, **NO** otherwise.
 @return **YES** if the receiver is a valid Email, **NO** otherwise.
 */
- (BOOL)isValidEmail;


#pragma mark - Computing Metrics for Drawing Strings
/** @name Computing Metrics for Drawing Strings */

/** Returns the height of the string if it were rendered and constrained to the specified width and font informations.
 @param width The maximum acceptable width for the string. This value is used to calculate where line breaks and wrapping would occur.
 @param config The font and Linebreak informations to use for rendering the string.
 */
- (float)heightForWidth:(float)width config:(PxFontConfig)config;

#pragma mark - Misc
/** @name Misc */

/** Returns a camelcased representation of the receiver.
 @param upperCaseFirstLetter Provide **YES** if the first letter should be converted to uppercase, **NO** to keep its original case.
 @return The camelcased representation of the receiver.
 */
- (NSString *)stringByCamelizeString:(BOOL)upperCaseFirstLetter;

/** Returns a new string with all non ascii alphanumeric letters replaced with underscores.
 @param compact Provide **YES** to strip leading and trailing underscores and replace consecutive underscores with one underscore.
 @return The new string.
 */
- (NSString *)stringByApplyingKFC:(BOOL)compact;

/** Returns a new string with UTF-8 soft hyphen inserted at appropriate places. The hyphen dicts must be included in the project.
 @param locale The locale to choose the hyphen dict for.
 @return The hyphenated string.
 */
- (NSString *)stringByHyphenatingWithLocale:(NSLocale *)locale;

#pragma mark - Encrypting Strings
/** @name Encrypting Strings */

/** Returns a new string by MD5 encoding the receiver.
 @return The MD5 encoded representation of the receiver.
 @see stringByAddingSHA1Encoding
 @see stringByAddingSHA256Encoding
 @see stringByAddingSHA1HMACEncoding:
 */
- (NSString *)stringByAddingMD5Encoding;

/** Returns a new string by SHA1 encoding the receiver.
 @return The SHA1 encoded representation of the receiver.
 @see stringByAddingMD5Encoding
 @see stringByAddingSHA256Encoding
 @see stringByAddingSHA1HMACEncoding:
 */
- (NSString *)stringByAddingSHA1Encoding;

/** Returns a new string by SHA1HMAC encoding the receiver.
 @param secret String to use as secrete to encode the receiver.
 @return The SHA1HMAC encoded representation of the receiver.
 @see stringByAddingMD5Encoding
 @see stringByAddingSHA1Encoding
 @see stringByAddingSHA256Encoding
 */
- (NSString *)stringByAddingSHA1HMACEncoding:(NSString *)secret;

/** Returns a new string by SHA256 encoding the receiver.
 @return The SHA256 encoded representation of the receiver.
 @see stringByAddingMD5Encoding
 @see stringByAddingSHA1Encoding
 @see stringByAddingSHA1HMACEncoding:
 */
- (NSString *)stringByAddingSHA256Encoding;

#pragma mark - Working with URLs
/** @name Working with URLs */

/** Returns a representation of the receiver suitable for URLs.
 
 The Following Characters will be percentage escaped: '!', '*', '\'', '\\', '"', '(', ')', ';', ':', '@', '&', '=', '+', '$', ',', '/', '?', '%', '#', '[', ']', '%', ' '
 @return A representation of the receiver suitable for URLs.
 */
- (NSString *)stringByAddingURLEncoding;

/** Returns a dictionary with the parsed query-parameters. Values are strings with removed percentage escapes.
 @return The parsed query-parameters.
 */
- (NSMutableDictionary *)dictionaryFromQueryString;

#pragma mark - Working with UUIDs
/** @name Working with UUIDs */

/** Returns a new UUID-string.
 @return The UUID-string.
 */
+ (NSString *)UUID;

@end
