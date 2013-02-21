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
//  PxHTTPConnection.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import "PxCaller.h"
#import "PxHTTPCache.h"

typedef enum {
    PxHTTPConnectionStatePending     = 0,
    PxHTTPConnectionStateRunning     = 1,
    PxHTTPConnectionStatePaused      = 2,
    PxHTTPConnectionStateFinished    = 3,
    PxHTTPConnectionStateFailed      = 4
} PxHTTPConnectionState;

@protocol PxHTTPConnectionDelegate;

@interface PxHTTPConnection : NSObject {
@private
    NSURLConnection*    _connection;
    NSURLRequest*       _request;
    NSHTTPURLResponse*  _response;
    NSString*           _lastModifiedResponse;
    
    BOOL                _acceptRanges;

    NSMutableArray*     _caller;
    int                 _options;
    
    // Storage
    BOOL                _storeIsReady;
    NSString*           _tmpFilePath;
    NSFileHandle*       _tmpFile;
    
    NSMutableData*      _inMemoryStore;
    
    BOOL                _finilazed;
}
@property(nonatomic, weak) id<PxHTTPConnectionDelegate> delegate;
@property(nonatomic, readonly) PxHTTPConnectionState state;
@property(nonatomic, readonly) int statusCode;
@property(nonatomic, readonly) long long expectedByteCount;
@property(nonatomic, readonly) long long currentByteCount;
@property(nonatomic, readonly, strong) NSString *URLString;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<PxHTTPConnectionDelegate>)d;

// Void Caller Chain
- (void)addCaller:(PxCaller*)c;
// removes all entries from the caller-list with the given target
- (void)removeCallersWithTarget:(id)target;
- (NSArray *)caller;

- (BOOL)canQueue;

// Connection Lifecycle
- (void)startConnection;
- (void)stopConnection;
- (void)stopOrPauseConnection;
- (void)startOrResumeConnection;

- (id)rawData;
- (NSString*)filePath;
- (NSDictionary *)httpHeader;

- (NSString *)storeInCache:(PxHTTPCache *)cache;
- (BOOL)isFinilazed;

@end

@protocol PxHTTPConnectionDelegate <NSObject>

- (void)connection:(PxHTTPConnection *)c didCompleteWithStatus:(int)status;
- (void)connection:(PxHTTPConnection *)c didStop:(BOOL)connectionCleaned;

@end