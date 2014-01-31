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
//  PxParseService.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxParseService.h"
#import "PxCXMLParser.h"
#import "PxJSONParser.h"
#import "PxXMLParser.h"

@implementation PxParseService

+ (id)parseObject:(id)object type:(PxContentType)type mapping:(NSDictionary *)mapping error:(NSError**)error {
    if ([object isKindOfClass:[NSString class]]) {
        return [self parseString:object type:type mapping:mapping];
    } else if ([object isKindOfClass:[NSURL class]]) {
        return [self parseFile:object type:type mapping:mapping];
    } else if ([object isKindOfClass:[NSData class]]) {
        return [self parseData:object type:type mapping:mapping];
    } else if (object != nil && error) {
        *error = [NSError errorWithDomain:@"PxParseServiceError" code:1 userInfo:nil];
    }
    return nil;
}

+ (id)parseFile:(NSURL *)fileUrl type:(PxContentType)type mapping:(NSDictionary *)mapping {
    switch (type) {
        case PxContentTypeNone:
            return [NSData dataWithContentsOfURL:fileUrl];
            break;
        case PxContentTypeCXML:
            return [PxCXMLParser parseFile:[fileUrl path] mapping:mapping];
            break;
        case PxContentTypeJSON:
            return [PxJSONParser parseFile:[fileUrl path] mapping:mapping];
            break;
        case PxContentTypeXML:
            return [PxXMLParser parseFile:[fileUrl path] mapping:mapping];
            break;
        case PxContentTypePlain:
            return [[NSString alloc] initWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
            break;
        default:
            return nil;
            break;
    }
}

+ (id)parseData:(NSData *)data type:(PxContentType)type mapping:(NSDictionary *)mapping {
    switch (type) {
        case PxContentTypeNone:
            return data;
            break;
        case PxContentTypeCXML:
            return [PxCXMLParser parseData:data mapping:mapping];
            break;
        case PxContentTypeJSON:
            return [PxJSONParser parseData:data mapping:mapping];
            break;
        case PxContentTypeXML:
            return [PxXMLParser parseData:data mapping:mapping];
            break;
        case PxContentTypePlain:
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            break;
        default:
            return nil;
            break;
    }
}

+ (id)parseString:(NSString *)data type:(PxContentType)type mapping:(NSDictionary *)mapping {
    switch (type) {
        case PxContentTypeNone:
            return data;
            break;
        case PxContentTypeCXML:
            return [PxCXMLParser parseString:data mapping:mapping];
            break;
        case PxContentTypeJSON:
            return [PxJSONParser parseString:data mapping:mapping];
            break;
        case PxContentTypeXML:
            return [PxXMLParser parseString:data mapping:mapping];
            break;
        case PxContentTypePlain:
            return data;
            break;
        default:
            return nil;
            break;
    }
}

@end
