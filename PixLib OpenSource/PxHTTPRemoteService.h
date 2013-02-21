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
//  PxHTTPRemoteService.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "PxHTTPConnection.h"
#import "PxHTTPCache.h"
#import "PxCaller.h"
#import "PxResult.h"
#import "PxMarkupKit.h"

typedef enum {
	PxHTTPStatusCodeCache = 313,
	PxHTTPStatusCodeAlert = 572
} PxHTTPStatusCode;

@protocol PxHTTPRemoteServiceDelegate;

@interface PxHTTPRemoteService : NSObject <PxHTTPConnectionDelegate, PxAsyncParserDelegate>
@property (nonatomic, readonly, strong) NSMutableArray *connectionQueue;
@property (nonatomic, readonly, strong) PxHTTPCache *cache;
@property (nonatomic, readonly, assign) int activeConnections;
@property (nonatomic, assign) unsigned int maxSynchronouseConnections;

#pragma mark - Retrieving remote data
- (PxHTTPConnection *)pushRequest:(NSMutableURLRequest *)request interval:(NSTimeInterval)interval caller:(PxCaller *)caller;
//- (PxResult *)resultForRequest:(NSMutableURLRequest *)request initialFile:(NSString *)file interval:(NSTimeInterval)interval caller:(PxCaller *)caller;

#pragma mark - Methods for subclassing
- (Class)httpCacheClass;
- (NSDictionary *)orMapping;
- (NSMutableURLRequest *)requestForURLString:(NSString *)URLString;
- (void)setUserAgent:(NSMutableURLRequest *)request;

@end

@protocol PxHTTPRemoteServiceDelegate <NSObject>
@optional
- (void)remoteService:(PxHTTPRemoteService *)service didEnqueueCaller:(PxCaller *)caller inConnection:(PxHTTPConnection *)connection;
- (void)remoteService:(PxHTTPRemoteService *)service didFinishConnection:(PxResult *)result;
@end
