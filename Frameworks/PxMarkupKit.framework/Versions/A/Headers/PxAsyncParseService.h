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
//  PxAsyncParseService.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "PxMarkupKitSupport.h"

@protocol PxAsyncParserDelegate;

@interface PxAsyncParseService : NSObject

+ (int)parseObject:(id)object type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos error:(NSError**)error;

+ (void)parseFile:(NSURL *)fileUrl type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos;
+ (void)parseData:(NSData *)data type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos;

+ (void)parseString:(NSString *)data type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos;

@end

@protocol PxAsyncParserDelegate <NSObject>

- (NSDictionary*)mappingForAsyncParsing:(id)userInfos;
- (void)asyncParsingDidFinish:(id)data userInfos:(id)userInfos;

@end