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
//  PxXMLHelper.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

@protocol PxXMLAttribute <NSObject>

- (NSString *)stringForXMLAttribute;

@end

@protocol PxXMLMapping <NSObject>

+ (id)objectForXMLAttributes:(NSDictionary *)attributes parentObject:(id<PxXMLMapping>)parent;

@end

typedef enum {
    PxContentTypeNone   = 0,
    PxContentTypeCXML   = 1,
    PxContentTypeJSON   = 2,
    PxContentTypeXML    = 3,
    PxContentTypePlain  = 4
} PxContentType;

#define XML_VERSION_HEAD @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
#define XML_VERSION_HEAD_2 @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

NSString *PxXMLEscape(id<PxXMLAttribute> object);
NSString *PxXMLUnescape(NSString *string);

static inline PxContentType PxContentTypeFromNSString(NSString *string) {
    if ([string isEqualToString:@"text/cxml"]) {
        return PxContentTypeCXML;
    } else if ([string isEqualToString:@"cxml"]) {
        return PxContentTypeCXML;
    } else if ([string isEqualToString:@"text/json"]) {
        return PxContentTypeJSON;
    } else if ([string isEqualToString:@"text/plain"]) {
        return PxContentTypePlain;
    } else if ([string isEqualToString:@"text/xml"]) {
        return PxContentTypeXML;
    }
    return PxContentTypeNone;
}

