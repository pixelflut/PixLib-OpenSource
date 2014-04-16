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
//  PxAsyncParseService.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxAsyncParseService.h"
#import "PxCXMLParser.h"
#import "PxJSONParser.h"
#import "PxXMLParser.h"

@implementation PxAsyncParseService

+ (int)parseObject:(id)object type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos error:(NSError**)error {
    
    if ([object isKindOfClass:[NSString class]]) {
        [self parseString:object type:type delegate:delegate userInfos:userInfos];
    } else if([object isKindOfClass:[NSURL class]]) {
        [self parseFile:object type:type delegate:delegate userInfos:userInfos];
    } else if([object isKindOfClass:[NSData class]]) {
        [self parseData:object type:type delegate:delegate userInfos:userInfos];
    } else if(object != nil && error) {
        *error = [NSError errorWithDomain:@"PxAsyncParseServiceError" code:1 userInfo:nil];
        return 1;
    } else if(object == nil) {
        [self parseString:object type:PxContentTypeNone delegate:delegate userInfos:userInfos];
    }
    return 0;
}

+ (void)parseFile:(NSURL *)fileUrl type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos {
    
    NSString __block *_path = [fileUrl path];
    id<PxAsyncParserDelegate> __weak _delegate = delegate;
    id __block _userInfos = userInfos;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_delegate) {
            @autoreleasepool {
                id __block result = nil;
                if (type == PxContentTypeCXML) {
                    result = [PxCXMLParser parseFile:_path mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else if (type == PxContentTypeJSON) {
                    result = [PxJSONParser parseFile:_path mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else if (type == PxContentTypeNone) {
                    result = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_path]];
                } else if (type == PxContentTypePlain) {
                    result = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_path] encoding:NSUTF8StringEncoding error:nil];
                } else if (type == PxContentTypeXML) {
                    result = [PxXMLParser parseFile:_path mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else {
                    result = nil;
                }
                
                [_delegate asyncParsingDidFinish:result userInfos:_userInfos];
                
                // clean retain
                _path = nil;
                _userInfos = nil;
                result = nil;
            }
        }else {
            // clean retain
            _path = nil;
            _userInfos = nil;
        }
    });
}

+ (void)parseData:(NSData *)data type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos {
    
    NSData __block *_data = data;
    id<PxAsyncParserDelegate> __weak _delegate = delegate;
    id __block _userInfos = userInfos;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_delegate) {
            @autoreleasepool {                
                id __block result = nil;
                if (type == PxContentTypeCXML) {
                    result = [PxCXMLParser parseData:_data mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else if (type == PxContentTypeJSON) {
                    result = [PxJSONParser parseData:_data mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                }else if (type == PxContentTypeNone) {
                    result = _data;
                }else if (type == PxContentTypePlain) {
                    result = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
                } else if (type == PxContentTypeXML) {
                    result = [PxXMLParser parseData:_data mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                }else {
                    result = nil;
                }
                
                [_delegate asyncParsingDidFinish:result userInfos:_userInfos];
                
                // clean retain
                _data = nil;
                _userInfos = nil;
                result = nil;
            }
        }else {
            // clean retain
            _data = nil;
            _userInfos = nil;
        }
    });
}

+ (void)parseString:(NSString *)data type:(PxContentType)type delegate:(id<PxAsyncParserDelegate>)delegate userInfos:(id)userInfos {
    
    NSString __block *_data = data;
    id<PxAsyncParserDelegate> __weak _delegate = delegate;
    id __block _userInfos = userInfos;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_delegate) {
            @autoreleasepool {
                id __block result = nil;
                if (type == PxContentTypeCXML) {
                    result = [PxCXMLParser parseString:_data mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else if (type == PxContentTypeJSON) {
                    result = [PxJSONParser parseString:_data mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else if (type == PxContentTypeNone) {
                    result = [_data dataUsingEncoding:NSUTF8StringEncoding];
                } else if (type == PxContentTypePlain) {
                    result = data;
                } else if (type == PxContentTypeXML) {
                    result = [PxXMLParser parseString:_data mapping:[_delegate mappingForAsyncParsing:_userInfos]];
                } else {
                    result = nil;
                }
                
                [_delegate asyncParsingDidFinish:result userInfos:_userInfos];
                
                // clean retain
                _data = nil;
                _userInfos = nil;
                result = nil;
            }
        }else {
            // clean retain
            _data = nil;
            _userInfos = nil;
        }
    });
}

@end
