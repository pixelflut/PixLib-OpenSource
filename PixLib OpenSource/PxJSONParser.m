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
//  PxJSONParser.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxJSONParser.h"
#import "PxCore.h"

id objectForJSON(id serializedObject, NSString *tag, NSDictionary *mapping);

@interface PxJSONParser ()
+ (id)mapJSON:(id)serializedObject mapping:(NSDictionary *)mapping;
@end

@implementation PxJSONParser

+ (id)parseFile:(NSString*)path mapping:(NSDictionary *)mapping {
    NSError *error;
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:path];
    id serializedObject = [NSJSONSerialization JSONObjectWithStream:stream options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        PxError(@"%@", error);
    }
    return [self mapJSON:serializedObject mapping:mapping];
}

+ (id)parseData:(NSData*)data mapping:(NSDictionary *)mapping {
    NSError *error;
    id serializedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        PxError(@"%@", error);
    }
    return [self mapJSON:serializedObject mapping:mapping];
}

+ (id)parseString:(NSString*)data mapping:(NSDictionary *)mapping {
    NSError *error;
    id serializedObject = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        PxError(@"%@", error);
    }
    return [self mapJSON:serializedObject mapping:mapping];
}

+ (id)mapJSON:(id)serializedObject mapping:(NSDictionary *)mapping {
    // add Possible user-defined mapping
    // Problem: root-tag is missing
    // Solution: Add root-Tag userinfo
    return serializedObject;
}

@end
