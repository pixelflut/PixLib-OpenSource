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
//  PxHTTPRemoteService.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxHTTPRemoteService.h"
#import "PxCore.h"
#import "PxLocalizationKit.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface PxHTTPRemoteService (hidden)

- (PxHTTPConnection *)enqueueRequest:(NSMutableURLRequest *)request caller:(PxCaller *)caller;
- (PxPair *)partitionedCallers:(NSArray *)callerArray filePath:(NSString *)file status:(NSInteger)status;
- (void)evalFile:(NSString *)file header:(NSDictionary *)header forCallers:(NSArray *)callerArray status:(NSInteger)status;
- (void)evalData:(NSData *)data header:(NSDictionary *)header forCallers:(NSArray *)callerArray status:(NSInteger)status;
- (void)evalConnenctionQueue;
- (void)showNetworkActivity;
- (void)hideNetworkActivity;
- (void)sendResult:(PxResult *)result;

- (void)handleSuccess:(PxHTTPConnection *)connection;
- (void)handleAlert:(PxHTTPConnection *)connection;
- (void)handleFailure:(PxHTTPConnection *)connection;

@end

@implementation PxHTTPRemoteService
@synthesize connectionQueue             = _connectionQueue;
@synthesize cache                       = _cache;
@synthesize activeConnections           = _activeConnections;
@synthesize maxSynchronouseConnections  = _maxSynchronouseConnections;

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[[self httpCacheClass] alloc] init];
        _connectionQueue = [[NSMutableArray alloc] init];
        _activeConnections = 0;
        _maxSynchronouseConnections = 10;
    }
    return self;
}

#pragma mark - Default implementations -

- (Class)httpCacheClass {
    return [PxHTTPCache class];
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

- (PxHTTPConnection *)pushRequest:(NSMutableURLRequest *)request interval:(NSTimeInterval)interval caller:(PxCaller *)caller {
    if (![NSURLConnection canHandleRequest:request]) {
        return nil;
    }

    if ([caller canQueue] && interval > 0) {
        NSDate *creationDate = nil;
        NSDictionary *header = nil;
        NSString *filePath = [[self cache] pathForURL:[request URL] header:&header creationDate:&creationDate];
        if (creationDate && [[NSDate date] timeIntervalSinceDate:creationDate] < interval) {
            PxDebug(@"cache: %@", [request URL]);
            
            [self evalFile:filePath header:header forCallers:[NSArray arrayWithObject:caller] status:200];
            return nil;
        }else if(header) {
            NSString *modifiedSince = [header valueForKey:PxHTTPHeaderIfModified];
            if (modifiedSince) {
                [request setValue:modifiedSince forHTTPHeaderField:PxHTTPHeaderIfModified];
            }
        }
    }
    PxDebug(@"call: %@", [request URL]);
    return [self enqueueRequest:request caller:caller];
}

//- (PxResult *)resultForRequest:(NSMutableURLRequest *)request initialFile:(NSString *)file interval:(NSTimeInterval)interval caller:(PxCaller *)caller {
//    NSDate *creationDate = nil;
//    NSDictionary *header = nil;
//    NSString *filePath = [[self cache] pathForURL:[request URL] header:&header creationDate:&creationDate];
//    id result = nil;
//    if (creationDate && [[NSDate date] timeIntervalSinceDate:creationDate] < interval) {
//        result = [PxParseService parseFile:[NSURL fileURLWithPath:filePath isDirectory:NO] type:PxContentTypeFromNSString([header valueForKey:PxHTTPHeaderMimeType]) mapping:[self orMapping]];
//    }
//    if (!result) {
//        if (request) {
//            [self enqueueRequest:request caller:caller];
//        }
//        if (creationDate) {
//            result = [PxParseService parseFile:[NSURL fileURLWithPath:filePath isDirectory:NO] type:PxContentTypeFromNSString([header valueForKey:PxHTTPHeaderMimeType]) mapping:[self orMapping]];
//        }
//        if (!result && file) {
//            result = [PxParseService parseFile:[NSURL fileURLWithPath:file isDirectory:NO] type:PxContentTypeFromNSString([file pathExtension]) mapping:[self orMapping]];
//        }
//    }
//    if ([caller expectedClass] && ![result isKindOfClass:[caller expectedClass]]) {
//        return nil;
//    }
//    return result;
//}


#pragma mark PxHTTPConnectionDelegate

- (void)connection:(PxHTTPConnection *)c didStop:(BOOL)connectionCleaned {
    [self hideNetworkActivity];
    // Dont know ...
}

- (void)connection:(PxHTTPConnection *)c didCompleteWithStatus:(NSInteger)status {
    [self hideNetworkActivity];
    
    [_connectionQueue deleteIf:^BOOL(id obj) {
        return obj == c;
    }];
    
	if( status < 400 ) {
		[self handleSuccess:c];
	} else if( status == PxHTTPStatusCodeAlert) {
		[self handleAlert:c];
	} else {
		[self handleFailure:c];
	}
    
    [self evalConnenctionQueue];
}


#pragma mark PxAsyncParserDelegate

- (void)asyncParsingDidFinish:(id)data userInfos:(PxPair *)userInfos {
    NSArray *results = [userInfos first];
    PxHTTPConnection *connection = [userInfos second];
    
    
//    NSLog(@"Before Cache: %@ %d", [connection URLString], [[NSFileManager defaultManager] fileExistsAtPath:[(PxResult *)[results firstObject] filePath]]);
    NSString *cachefilePath;
    if (connection && [connection filePath]) {
        cachefilePath = [connection storeInCache:_cache];
    }
    
    [results each:^(PxResult *result) {
        [result setReturnObject:data];
        if (cachefilePath) {
            [result setFilePath:cachefilePath];
        }
        [self sendResult:result];
    }];
    
//    NSLog(@"After Cache: %@ %d", [connection URLString], [[NSFileManager defaultManager] fileExistsAtPath:[(PxResult *)[results firstObject] filePath]]);
}

- (NSDictionary *)mappingForAsyncParsing:(id)userInfos {
    return [self orMapping];
}

#pragma mark - Private Methods -
- (void)sendResult:(PxResult *)result {
    void (*action)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
    action(result.caller.target, result.caller.action, result);
    
    if ([result.caller.target respondsToSelector:@selector(remoteService:didFinishConnection:)]) {
        [result.caller.target remoteService:self didFinishConnection:result];
    }
}


- (PxPair *)partitionedCallers:(NSArray *)callerArray filePath:(NSString *)file status:(NSInteger)status {
    return [[callerArray collect:^id(PxCaller *caller) {
        if ([caller target] && [caller action]) {
            PxResult *result = [[PxResult alloc] initWithCaller:caller];
            [result setFilePath:file];
            [result setStatus:status];
            return result;
        }
        return nil;
    } skipNil:YES] partition:^BOOL(PxResult *result) { 
        return result.caller.options & PxRemoteOptionParse;
    }];
}

- (void)evalFile:(NSString *)file header:(NSDictionary *)header forCallers:(NSArray *)callerArray status:(NSInteger)status {
    PxPair *parseAndNotParse = [self partitionedCallers:callerArray filePath:file status:status];
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

#pragma mark Network indicator
- (void)showNetworkActivity {
//	if( _activeConnections == 0 ) {
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//	}
//	++_activeConnections;
}

- (void)hideNetworkActivity {
//	if( _activeConnections > 0 ) {--_activeConnections;}
//	if( _activeConnections <= 0 ) {
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//	}
}

#pragma mark ConnectionQueue

- (PxHTTPConnection *)enqueueRequest:(NSMutableURLRequest *)request caller:(PxCaller *)caller {
    NSString *_id = [[request URL] absoluteString];
    PxHTTPConnection *availableConnection = nil;
    if ([caller canQueue]) {
        availableConnection = [_connectionQueue find:^BOOL(PxHTTPConnection *connection) {
            return [[connection URLString] isEqualToString:_id] && ![connection canQueue];
        }];
    }
    
    if (!availableConnection) {
        availableConnection = [[PxHTTPConnection alloc] initWithRequest:request delegate:self];
        [self showNetworkActivity];
        [_connectionQueue addObject:availableConnection];
    }
    
    [availableConnection addCaller:caller];
    
    [self evalConnenctionQueue];
    
    if ([[caller target] respondsToSelector:@selector(remoteService:didEnqueueCaller:inConnection:)]) {
        [[caller target] remoteService:self didEnqueueCaller:caller inConnection:availableConnection];
    }
    return availableConnection;
}

- (void)evalConnenctionQueue {
    [_connectionQueue eachWithIndex:^(PxHTTPConnection *connection, unsigned int index) {
        if (index < _maxSynchronouseConnections) {
            [connection startOrResumeConnection];
        }else {
            [connection stopOrPauseConnection];
        }
    }];
}

#pragma mark Connection finished

- (void)handleSuccess:(PxHTTPConnection *)connection {
    NSDictionary *header = [connection httpHeader];
    NSArray *callerArray = [connection caller];
    NSString *filePath = [connection filePath];
    id parseInput = nil;
    NSInteger status = [connection statusCode];
    NSError *error = nil;
    
    
    if ([filePath isNotBlank]) {
        parseInput = [NSURL fileURLWithPath:filePath isDirectory:NO];
    }else {
        parseInput = [connection rawData];
    }
    
    PxPair *parseAndNotParse = [self partitionedCallers:callerArray filePath:filePath status:status];
    
    
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

- (void)handleAlert:(PxHTTPConnection *)connection {
    NSDictionary *header = [connection httpHeader];
    NSArray *callerArray = [connection caller];
    NSString *filePath = [connection filePath];
    id parseInput = nil;
    NSError *error = nil;
    
    
    if ([filePath isNotBlank]) {
        parseInput = [NSURL fileURLWithPath:filePath isDirectory:NO];
    }else {
        parseInput = [connection rawData];
    }
    
    id result = [PxParseService parseObject:parseInput type:PxContentTypeFromNSString([header valueForKey:PxHTTPHeaderMimeType]) mapping:nil error:&error];
    if (error) {
        PxError(@"handleAlert");
        error = nil;
    }
    NSString *title = nil;
    NSString *msg = nil;
    if ([result isKindOfClass:[NSDictionary class]]) {
        msg     = [result valueForKey:@"msg"];
        title   = [result valueForKey:@"title"];
    }else if([result isKindOfClass:[NSString class]]) {
        msg     = result;
        title   = T(@"Error");
    }
    msg     = msg ? msg : T(@"Server Error");
    title   = title ? title : T(@"Error");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    
    [callerArray each:^(PxCaller *caller) {
        if ([[caller target] respondsToSelector:@selector(remoteService:didFinishConnection:)]) {
            PxResult *result = [[PxResult alloc] initWithCaller:caller];
            [result setStatus:[connection statusCode]];
            [caller.target remoteService:self didFinishConnection:result];
        }
    }];
}

- (void)handleFailure:(PxHTTPConnection *)connection {
    NSInteger status = [connection statusCode];
    NSArray *callerArray = [connection caller];
    
    PxPair *cacheAndNoCache = [callerArray partition:^BOOL(PxCaller *caller) {
        return !(caller.options & PxRemoteOptionNoCache);
    }];
    
    // TODO: a little bit nicer!
    if ([[cacheAndNoCache first] count] > 0) {
        NSDate *creationDate = nil;
        NSDictionary *header = nil;
        NSURL *url = [NSURL URLWithString:[connection URLString]];
        NSString *filePath = [[self cache] pathForURL:url header:&header creationDate:&creationDate];
        if (creationDate && [[NSDate date] timeIntervalSinceDate:creationDate] < INT_MAX) {
            [self evalFile:filePath header:header forCallers:[cacheAndNoCache first] status:PxHTTPStatusCodeCache];
        } else {
            [(NSArray *)[cacheAndNoCache first] each:^(PxCaller *caller) {
                PxResult *result = [[PxResult alloc] initWithCaller:caller];
                [result setStatus:status];
                [self sendResult:result];
            }];
        }
    }
    
    [[cacheAndNoCache second] each:^(PxCaller *caller) {
        PxResult *result = [[PxResult alloc] initWithCaller:caller];
        [result setStatus:status];
        [self sendResult:result];
    }];
}

@end
