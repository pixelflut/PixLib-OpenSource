//
//  PxNetConnection.h
//  PxNetKit
//
//  Created by Jonathan Cichon on 11.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxNetCache.h"
#import "PxNetRequest.h"

typedef enum {
    PxNetConnectionStatePending     = 0,
    PxNetConnectionStateRunning     = 1,
    PxNetConnectionStatePaused      = 2,
    PxNetConnectionStateFinished    = 3,
    PxNetConnectionStateFailed      = 4
} PxNetConnectionState;

@protocol PxNetConnectionDelegate;

@interface PxNetConnection : NSObject
@property (nonatomic, weak, readonly) id<PxNetConnectionDelegate> delegate;
@property (nonatomic, assign, readonly) PxNetConnectionState state;
@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, assign, readonly) long long expectedByteCount;
@property (nonatomic, assign, readonly) long long currentByteCount;
@property (nonatomic, strong, readonly) NSString *URLString;

- (instancetype)initWithRequest:(PxNetRequest *)request delegate:(id<PxNetConnectionDelegate>)d;

- (BOOL)canQueue;
//- (void)startConnection;
//- (void)stopConnection;
- (void)stopOrPauseConnection;
- (void)startOrResumeConnection;

- (id)rawData;
- (NSString *)filePath;
- (NSDictionary *)httpHeader;

- (NSString *)storeInCache:(PxNetCache *)cache;
- (BOOL)isFinilazed;

@end

@protocol PxNetConnectionDelegate <NSObject>

- (void)connection:(PxNetConnection *)c didCompleteWithStatus:(NSInteger)status;
- (void)connection:(PxNetConnection *)c didStop:(BOOL)connectionCleaned;

@optional
- (NSOperationQueue *)queueForConnection:(PxNetConnection *)connection;

@end
