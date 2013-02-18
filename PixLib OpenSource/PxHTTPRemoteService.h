//
//  PxHTTPRemoteService.h
//  PixLib
//
//  Created by Jonathan Cichon on 12.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
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
