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
//  NSObject+PxCore.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>


#define PxSingleton(__singletonGetter__) + (instancetype)__singletonGetter__;
#define PxSingletonImp(__singletonGetter__) + (instancetype)__singletonGetter__ {\
    static id singletonInstance = nil; \
    if (!singletonInstance) {\
        static dispatch_once_t onceToken;\
        dispatch_once(&onceToken, ^{\
            singletonInstance = [[super allocWithZone:NULL] init];\
        });\
    }\
    return singletonInstance;\
}\
+ (id)allocWithZone:(NSZone *)zone {\
    return [self __singletonGetter__];\
}\
- (id)copyWithZone:(NSZone *)zone {\
    return self;\
}

/**
 * PxCore Category for NSData
 */
@interface NSObject (PxCore)

#pragma mark - Testing Class Behavior
/** @name Testing Class Behavior */

/** Returns a Boolean value that indicates whether the receiver implements or inherits a method that can respond to a specified message.
 @param aSelector A selector that identifies a message.
 @return **YES** if the receiver implements or inherits a method that can respond to aSelector, otherwise **NO**.
 @see classPerformSelector:withObject:
 */
+ (BOOL)classRespondsToSelector:(SEL)aSelector;


#pragma mark - Sending Messages to Classes
/** @name Sending Messages to Classes */


/** Sends a specified message to the receiver and returns the result of the message.
 @param aSelector A selector identifying the message to send. If _aSelector_ is **NULL**, an NSInvalidArgumentException is raised.
 @return An object that is the result of the message.
 @see classPerformSelector:withObject:
 @see classPerformSelector:withObject:withObject:
 */
+ (id)classPerformSelector:(SEL)aSelector;

/** Sends a specified message to the receiver and returns the result of the message.
 @param aSelector A selector identifying the message to send. If _aSelector_ is **NULL**, an NSInvalidArgumentException is raised.
 @param anObject An object that is the sole argument of the message.
 @return An object that is the result of the message.
 @see classPerformSelector:
 @see classPerformSelector:withObject:withObject:
 */
+ (id)classPerformSelector:(SEL)aSelector withObject:(id)anObject;

/** Sends a specified message to the receiver and returns the result of the message.
 @param aSelector A selector identifying the message to send. If _aSelector_ is **NULL**, an NSInvalidArgumentException is raised.
 @param anObject An object that is the first argument of the message.
 @param anotherObject An object that is the second argument of the message.
 @return An object that is the result of the message.
 @see classPerformSelector:
 @see classPerformSelector:withObject:
 */
+ (id)classPerformSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject;


#pragma mark - Describing Classes
/** @name Describing Classes */

/** Prints the Methods, Ivars, Properties and Protocols of the receiver.
 */
+ (void)printImplementation;


#pragma mark - Comparing Objects
/** @name Comparing Objects */

/** Returns an NSComparisonResult value that indicates whether the receiver is greater than, equal to, or less than a given object.
 
 The default implementation compares the [NSObject hash] values. Subclasses should overwrite this Method with meaningfull implementations.
 @param object The object to compare the receiver with.
 @param context Userdefined context to alter the result.
 @return NSOrderedAscending if the hash of object is greater than the receivers, NSOrderedSame if they’re equal, and NSOrderedDescending if the hash of object is less than the receivers.
 */
- (NSComparisonResult)compare:(id)object context:(void *)context;


#pragma mark - Testing Object Contents
/** @name Testing Object Contents */

/** Returns either or not the receiver has an value.
 
 The default implementation always returns **YES**. Subclasses should overwrite this Method with meaningfull implementation. For example NSArray returns **YES** if count > 0, otherwise **NO**.
 @return **YES** if the receiver implements has a value, otherwise **NO**.
 */
- (BOOL)isNotBlank;


#pragma mark - Accessing Runtime Properties
/** @name Accessing Runtime Properties */

/** Sets an object using objc_setAssociatedObject to the receiver.
 
 Use this method to store additional properties to objects when compile-time properties will not suffice, for example in categories. 
 @param object The object to set.
 @param name The name of the runtime-property.
 @see runtimeProperty:
 */
- (void)setRuntimeProperty:(id)object name:(NSString *)name;

/** Gets an object using objc_getAssociatedObject from the receiver.
 @param propertyName The name of the runtime-property.
 @see setRuntimeProperty:name:
 */
- (id)runtimeProperty:(NSString *)propertyName;


- (void)setPxProperty:(id)value name:(NSString *)name NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
- (id)pxProperty:(NSString *)property NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);

@end
