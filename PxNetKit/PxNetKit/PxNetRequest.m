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
//  PxNetRequest.m
//  PxNetKit
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxNetRequest.h"

NSString *kPxNetRequestIdentifierKey = @"identifier";
NSString *kPxNetRequestClassKey = @"class";
NSString *kPxNetRequestURLRequestKey = @"urlRequest";
NSString *kPxNetRequestParseDataKey = @"parseData";
NSString *kPxNetRequestNoCacheKey = @"noCache";
NSString *kPxNetRequestCacheIntervalKey = @"cacheInterval";

@interface PxNetRequest ()
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) Class expectedClass;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL parseData;
@property (nonatomic, assign) BOOL noCache;
@property (nonatomic, assign) NSTimeInterval cacheInterval;
@property (nonatomic, strong) PxNetResult *result;

@end


@implementation PxNetRequest

+ (instancetype)requestWithConfiguration:(NSDictionary *)configurationDictionary {
    PxNetRequest *request = [[self alloc] init];
    request.identifier = configurationDictionary[kPxNetRequestIdentifierKey];
    request.expectedClass = NSClassFromString(configurationDictionary[kPxNetRequestClassKey]);
    request.request = configurationDictionary[kPxNetRequestURLRequestKey];
    request.parseData = [configurationDictionary[kPxNetRequestParseDataKey] boolValue];
    request.noCache = [configurationDictionary[kPxNetRequestNoCacheKey] boolValue];
    if (request.noCache) {
        request.cacheInterval = 0;
    } else {
        request.cacheInterval = [configurationDictionary[kPxNetRequestCacheIntervalKey] doubleValue];
    }
    
    if (!request.identifier) {
        request.identifier = [[NSUUID UUID] UUIDString];
    }
    return request;
}

- (BOOL)canQueue {
    return !self.noCache;
}

@end
