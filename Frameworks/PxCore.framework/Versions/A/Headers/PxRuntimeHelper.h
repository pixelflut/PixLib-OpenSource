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
//  PxRuntimeHelper.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

/**
 Returns the concrete class of a property. 
 
 If the return-type is primitive or _id_ **nil** is returned. If the return-type is primitive, the isPrimitive parameter is set to **YES**.
 */
Class property_getReturnClass(objc_property_t property, BOOL *isPrimitive);

#pragma mark - ARC Fuckup Helpers
static inline unsigned char *pointerFromObject(void *object) {
    return (unsigned char *)object;
}

static inline void *pointerToInstanceVariable(id object, char *variableName) {
    Ivar instanceVar = class_getInstanceVariable([object class], variableName);
    if (!instanceVar) {
        return nil;
    }
    return (size_t *)(__bridge void *)object + ivar_getOffset(instanceVar);
}