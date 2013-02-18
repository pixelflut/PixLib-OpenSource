//
//  PxHTTPConnection.h
//  PixLib
//
//  Created by Jonathan Cichon on 18.01.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
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