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
//  PxRuntimeHelper.m
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxRuntimeHelper.h"

Class property_getReturnClass(objc_property_t property, BOOL *isPrimitive) {
    const char *attributes = property_getAttributes(property);
    unsigned char *c = ((unsigned char *)attributes+1);
    if (*c == '@') {
        *isPrimitive = NO;
        c++;
        if (*c == '"') {
            CFMutableDataRef buffer = CFDataCreateMutable(NULL, 0);
            int i = 0;
            while (*(++c) != '"' ) {
                CFDataAppendBytes(buffer, c, 1);
                i++;
            }
            NSString *klass = [[NSString alloc] initWithBytes:CFDataGetBytePtr(buffer) length:i encoding:NSUTF8StringEncoding];
            CFRelease(buffer);
            return NSClassFromString(klass);
        }
    } else {
        if (isPrimitive) {*isPrimitive = YES;}
    }
    return nil;
}
