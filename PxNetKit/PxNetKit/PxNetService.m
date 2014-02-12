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
//  PxNetService.m
//  PxNetKit
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxNetService.h"
#import <PxCore/PxCore.h>

dispatch_queue_t getSerialWorkQueue__netService();

@interface PxNetRequest ()
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, strong) PxNetResult *result;

@end

@interface PxNetResult ()
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) id returnObject;
@property (nonatomic, strong) NSString *filePath;

@end

@interface PxNetUserInfo : NSObject
@property (nonatomic, copy) PxNetResultBlock singleResultBlock;
@property (nonatomic, copy) PxNetMultiResultBlock multiResultBlock;
@property (nonatomic, strong, readonly) NSArray *requests;
@property (nonatomic, assign, readonly) BOOL isSingle;

- (id)initWithResultBlock:(PxNetResultBlock)resultBlock request:(PxNetRequest *)request;
- (id)initWithResultBlock:(PxNetMultiResultBlock)resultBlock requests:(NSArray *)requests;

- (BOOL)isFinished;

- (void)callResultBlocks:(BOOL)success status:(NSInteger)status;

@end

@interface PxNetRequestWrapper : NSObject
@property (nonatomic, strong) PxNetUserInfo *userInfo;
@property (nonatomic, strong) PxNetRequest *currentRequest;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, strong) PxNetResult *result;

- (id)initWithInfos:(PxNetUserInfo *)infos request:(PxNetRequest *)request background:(BOOL)background;

@end

@interface PxNetConnectionQueueEntry : NSObject
@property (nonatomic, strong, readonly) PxNetConnection *connection;
@property (nonatomic, strong) NSArray *requestWrappers;

- (id)initWithConnection:(PxNetConnection *)connection;
- (void)addRequestWrapper:(PxNetRequestWrapper *)requestWrapper;

@end

@interface PxNetService ()
@property (nonatomic, strong) PxNetCache *cache;
@property (nonatomic, strong) NSMutableArray *connectionQueue;
@property (nonatomic, assign) NSInteger activeConnections;
@property (nonatomic, assign) NSInteger maxSynchronouseConnections;

- (void)enqueueRequest:(PxNetRequestWrapper *)requestWrapper;

- (PxPair *)partitionedRequests:(NSArray *)requestWrappers filePath:(NSString *)file status:(NSInteger)status;

- (void)evalFile:(NSString *)file header:(NSDictionary *)header forRequests:(NSArray *)requestWrappers status:(NSInteger)status;

- (void)evalConnenctionQueue;
- (void)handleSuccess:(PxNetConnectionQueueEntry *)entry;
- (void)handleFailure:(PxNetConnectionQueueEntry *)entry;

//- (void)showNetworkActivity;
//- (void)hideNetworkActivity;
- (void)finischRequest:(PxNetRequestWrapper *)wrapper;

@end

@implementation PxNetService

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[[[self class] cacheClass] alloc] initWithCacheDir:[PxCacheDirectory() stringByAppendingPathComponent:@"pxNetService"]];
        _connectionQueue = [[NSMutableArray alloc] init];
        _activeConnections = 0;
        _maxSynchronouseConnections = 20;
    }
    return self;
}

#pragma mark - Default implementations -

- (Class)httpCacheClass {
    return [PxNetCache class];
}

- (NSDictionary *)orMapping {
    return nil;
}

- (NSMutableURLRequest *)requestForURLString:(NSString *)URLString {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrlString:URLString];
    [self setUserAgent:request];
    return request;
}

- (void)setUserAgent:(NSMutableURLRequest *)request {}

#pragma mark - Public Methods -

- (void)fetchDataWithRequests:(NSArray *)requests background:(BOOL)background completion:(PxNetMultiResultBlock)completion {
    
    dispatch_async(getSerialWorkQueue__netService(), ^{
        if ([requests find:^BOOL(PxNetRequest *request) {
            return ![NSURLConnection canHandleRequest:request.request];
        }]) {
            if (!background) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, 400, nil);
                });
            } else {
                completion(NO, 400, nil);
            }
            return;
        }
        
        PxNetUserInfo *info = [[PxNetUserInfo alloc] initWithResultBlock:completion requests:requests];
        [self fetchRequests:info background:background];
    });
}

- (void)fetchDataWithRequest:(PxNetRequest *)request background:(BOOL)background completion:(PxNetResultBlock)completion {
    
    dispatch_async(getSerialWorkQueue__netService(), ^{
        if (![NSURLConnection canHandleRequest:request.request]) {
            if (!background) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, 400, nil);
                });
            } else {
                completion(NO, 400, nil);
            }
            return;
        }
        
        PxNetUserInfo *info = [[PxNetUserInfo alloc] initWithResultBlock:completion request:request];
        [self fetchRequests:info background:background];
    });
}

- (void)fetchRequests:(PxNetUserInfo *)userInfo background:(BOOL)background {
    [[userInfo requests] each:^(PxNetRequest *request) {
        PxNetRequestWrapper *wrapper = [[PxNetRequestWrapper alloc] initWithInfos:userInfo request:request background:background];
        
        NSTimeInterval interval = request.cacheInterval;
        if ([request canQueue] && interval > 0) {
            NSDate *creationDate = nil;
            NSDictionary *header = nil;
            NSString *filePath = [[self cache] pathForURL:[request.request URL] header:&header creationDate:&creationDate];
            if (creationDate && [[NSDate date] timeIntervalSinceDate:creationDate] < interval) {
                PxDebug(@"cache hit: %@", [request.request URL]);
                [self evalFile:filePath header:header forRequests:@[wrapper] status:PxHTTPStatusCodeCache];
                return;
            } else if (header) {
                NSString *modifiedSince = [header valueForKey:PxHTTPHeaderIfModified];
                if (modifiedSince) {
                    [request setValue:modifiedSince forKey:PxHTTPHeaderIfModified];
                }
            }
        }
        PxDebug(@"url Call: %@", [request.request URL]);
        [self enqueueRequest:wrapper];
    }];
}

#pragma mark PxHTTPConnectionDelegate

- (void)connection:(PxNetConnection *)c didStop:(BOOL)connectionCleaned {
    // Dont know ...
}

- (void)connection:(PxNetConnection *)c didCompleteWithStatus:(NSInteger)status {
    dispatch_async(getSerialWorkQueue__netService(), ^{
        
        NSUInteger index = [_connectionQueue index:^BOOL(PxNetConnectionQueueEntry *entry) {
            return entry.connection == c;
        }];
        if (index != NSNotFound) {
            PxNetConnectionQueueEntry *entry = [_connectionQueue objectAtIndex:index];
            [_connectionQueue removeObjectAtIndex:index];
            if( status < 400 ) {
                [self handleSuccess:entry];
            } else {
                [self handleFailure:entry];
            }
        }
        [self evalConnenctionQueue];
    });
}

#pragma mark PxAsyncParserDelegate

- (void)asyncParsingDidFinish:(id)data userInfos:(PxPair *)userInfos {
    NSArray *requestWrappers = [userInfos first];
    PxNetConnection *connection = [userInfos second];
    
    NSString *cachefilePath;
    if (connection && [connection filePath]) {
        cachefilePath = [connection storeInCache:self.cache];
    }
    
    [requestWrappers each:^(PxNetRequestWrapper *wrapper) {
        [wrapper.result setReturnObject:data];
        if (cachefilePath) {
            [wrapper.result setFilePath:cachefilePath];
        }
        [self finischRequest:wrapper];
    }];
}

- (NSDictionary *)mappingForAsyncParsing:(id)userInfos {
    return [self orMapping];
}

#pragma mark - Private Methods -
- (void)finischRequest:(PxNetRequestWrapper *)wrapper {
    
    PxNetRequest *currentRequest = wrapper.currentRequest;
    [currentRequest setFinished:YES];
    [currentRequest setResult:wrapper.result];
    
    NSInteger status = wrapper.result.status;
    
    BOOL success = currentRequest.expectedClass ? [wrapper.result.returnObject isKindOfClass:currentRequest.expectedClass] && wrapper.result.isSuccess : wrapper.result.isSuccess;
    
    PxNetUserInfo *info = wrapper.userInfo;
    if (info.isFinished) {
        if (!wrapper.background) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [info callResultBlocks:success status:status];
            });
        } else {
            [info callResultBlocks:success status:status];
        }
    }
}

- (PxPair *)partitionedRequests:(NSArray *)requestWrappers filePath:(NSString *)file status:(NSInteger)status {
    return [requestWrappers partition:^BOOL(PxNetRequestWrapper *wrapper) {
        PxNetResult *result = [[PxNetResult alloc] initWithStatus:status returnObject:nil filePath:file];
        [wrapper setResult:result];
        return wrapper.currentRequest.parseData;
    }];
}

- (void)evalFile:(NSString *)file header:(NSDictionary *)header forRequests:(NSArray *)requestWrappers status:(NSInteger)status {
    PxPair *parseAndNotParse = [self partitionedRequests:requestWrappers filePath:file status:status];
    NSURL *fileURL = [NSURL fileURLWithPath:file isDirectory:NO];
    
    [PxAsyncParseService parseFile:fileURL
                              type:PxContentTypeFromNSString([header valueForKey:PxHTTPHeaderMimeType])
                          delegate:self
                         userInfos:[PxPair pairWithFirst:[parseAndNotParse first] second:nil]];
    
    // a little bit hacky but so i dont need to implement a small amount of code twice and still get nice asynchronouse behavior
    [PxAsyncParseService parseFile:fileURL
                              type:PxContentTypeNone
                          delegate:self
                         userInfos:[PxPair pairWithFirst:[parseAndNotParse second] second:nil]];
}

#pragma mark ConnectionQueue

- (void)enqueueRequest:(PxNetRequestWrapper *)requestWrapper {
    NSString *_id = [[requestWrapper.currentRequest.request URL] absoluteString];
    PxNetConnectionQueueEntry *availableConnection = nil;
    if ([requestWrapper.currentRequest canQueue]) {
        availableConnection = [_connectionQueue find:^BOOL(PxNetConnectionQueueEntry *entry) {
            return [[entry.connection URLString] isEqualToString:_id] && ![entry.connection canQueue];
        }];
    }
    
    if (!availableConnection) {
        availableConnection = [[PxNetConnectionQueueEntry alloc] initWithConnection:[[PxNetConnection alloc] initWithRequest:requestWrapper.currentRequest delegate:self]];
        [_connectionQueue addObject:availableConnection];
    }
    [availableConnection addRequestWrapper:requestWrapper];
    
    [self evalConnenctionQueue];
}

- (void)evalConnenctionQueue {
    [_connectionQueue eachWithIndex:^(PxNetConnectionQueueEntry *entry, NSUInteger index) {
        if (index < self.maxSynchronouseConnections) {
            [entry.connection startOrResumeConnection];
        }else {
            [entry.connection stopOrPauseConnection];
        }
    }];
}

#pragma mark Connection finished

- (void)handleSuccess:(PxNetConnectionQueueEntry *)entry {
    PxNetConnection *connection = entry.connection;
    NSArray *requestWrappers = entry.requestWrappers;
    
    NSDictionary *header = [connection httpHeader];
    
    NSString *filePath = [connection filePath];
    id parseInput = nil;
    NSInteger status = [connection statusCode];
    NSError *error = nil;
    
    
    if ([filePath isNotBlank]) {
        parseInput = [NSURL fileURLWithPath:filePath isDirectory:NO];
    }else {
        parseInput = [connection rawData];
    }
    
    PxPair *parseAndNotParse = [self partitionedRequests:requestWrappers filePath:filePath status:status];
    
    
    [PxAsyncParseService parseObject:parseInput
                                type:PxContentTypeFromNSString([header valueForKey:PxHTTPHeaderMimeType])
                            delegate:self
                           userInfos:[PxPair pairWithFirst:[parseAndNotParse first] second:connection]
                               error:&error];
    if (error) {
        PxError(@"handleSuccess 1");
        error = nil;
    }
    
    [PxAsyncParseService parseObject:parseInput
                                type:PxContentTypeNone
                            delegate:self
                           userInfos:[PxPair pairWithFirst:[parseAndNotParse second] second:connection]
                               error:&error];
    
    if (error) {
        PxError(@"handleSuccess 2");
        error = nil;
    }
}

- (void)handleFailure:(PxNetConnectionQueueEntry *)entry {
    PxNetConnection *connection = entry.connection;
    NSArray *requestWrappers = entry.requestWrappers;
    
    NSInteger status = [connection statusCode];
    
    PxPair *cacheAndNoCache = [requestWrappers partition:^BOOL(PxNetRequestWrapper *wrapper) {
        return !wrapper.currentRequest.noCache;
    }];
    
    void (^noCacheBlock)(id obj) = ^(PxNetRequestWrapper *wrapper) {
        [wrapper setResult:[[PxNetResult alloc] initWithStatus:status returnObject:nil filePath:nil]];
        [self finischRequest:wrapper];
    };
    
    if ([[cacheAndNoCache first] count] > 0) {
        NSDate *creationDate = nil;
        NSDictionary *header = nil;
        NSURL *url = [NSURL URLWithString:[connection URLString]];
        NSString *filePath = [[self cache] pathForURL:url header:&header creationDate:&creationDate];
        if (creationDate && [[NSDate date] timeIntervalSinceDate:creationDate] < INT_MAX) {
            [self evalFile:filePath header:header forRequests:[cacheAndNoCache first] status:PxHTTPStatusCodeCacheRequestFailed];
        } else {
            [(NSArray *)[cacheAndNoCache first] each:noCacheBlock];
        }
    }
    
    [[cacheAndNoCache second] each:noCacheBlock];
}

@end

@implementation PxNetUserInfo

- (id)initWithResultBlock:(PxNetResultBlock)resultBlock request:(PxNetRequest *)request {
    self = [super init];
    if (self) {
        self.singleResultBlock = resultBlock;
        _requests = @[request];
        _isSingle = YES;
    }
    return self;
}

- (id)initWithResultBlock:(PxNetMultiResultBlock)resultBlock requests:(NSArray *)requests {
    self = [super init];
    if (self) {
        self.multiResultBlock = resultBlock;
        _requests = requests;
        _isSingle = NO;
    }
    return self;
}

- (BOOL)isFinished {
    return ![self.requests find:^BOOL(PxNetRequest *request) {
        return ![request finished];
    }];
}

- (void)callResultBlocks:(BOOL)success status:(NSInteger)status {
    id returnObject;
    if (self.isSingle) {
        returnObject = [(PxNetRequest *)[self.requests firstObject] result];
        if (self.singleResultBlock) {
            self.singleResultBlock(success, status, returnObject);
        }
    } else {
        returnObject = [self.requests inject:[NSMutableDictionary dictionary] block:^id(NSMutableDictionary *memo, PxNetRequest *obj) {
            [memo setValue:obj.result forKey:obj.identifier];
            return memo;
        }];
        if (self.multiResultBlock) {
            self.multiResultBlock(success, status, returnObject);
        }
    }
}

@end


@implementation PxNetRequestWrapper : NSObject

- (id)initWithInfos:(PxNetUserInfo *)infos request:(PxNetRequest *)request background:(BOOL)background {
    self = [super init];
    if (self) {
        self.userInfo = infos;
        self.currentRequest = request;
        self.background = background;
    }
    return self;
}

@end


@implementation PxNetConnectionQueueEntry

- (id)initWithConnection:(PxNetConnection *)connection {
    self = [super init];
    if (self) {
        self.requestWrappers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addRequestWrapper:(PxNetRequestWrapper *)requestWrapper {
    [(NSMutableArray *)self.requestWrappers addObject:requestWrapper];
}

@end
