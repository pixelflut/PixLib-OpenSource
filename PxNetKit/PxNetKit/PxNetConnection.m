//
//  PxNetConnection.m
//  PxNetKit
//
//  Created by Jonathan Cichon on 11.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxNetConnection.h"
#import <PxCore/PxCore.h>
#import "PxNetService.h"

@interface PxNetConnection ()
@property (nonatomic, assign) PxNetConnectionState state;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) long long expectedByteCount;
@property (nonatomic, assign) long long currentByteCount;


@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSString *lastModifiedResponse;

@property (nonatomic, assign) BOOL acceptRanges;

@property (nonatomic, assign) NSInteger options;

@property (nonatomic, assign) BOOL storeIsReady;
@property (nonatomic, strong) NSString *tmpFilePath;
@property (nonatomic, strong) NSFileHandle *tmpFile;
@property (nonatomic, strong) NSMutableData *inMemoryStore;

@property (nonatomic, assign) BOOL finilazed;

- (BOOL)shouldKeepConnection;
- (BOOL)shouldFileStore;
- (BOOL)shouldMemoryStore;
- (BOOL)isPausable;

- (void)cleanConnection;
- (void)resumeConnection;
- (void)pauseConnection;

- (void)cleanStorage;
- (NSString*)tmpFilePath;

@end

@implementation PxNetConnection

- (id)initWithRequest:(PxNetRequest *)request delegate:(id<PxNetConnectionDelegate>)d {
    self = [super init];
    if (self) {
        _URLString = [[request.request URL] absoluteString];
        
        NSMutableURLRequest *tmp = [request.request mutableCopy];
        [tmp setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        _request = tmp;
        
        _delegate = d;
        
        _options = 0;
        if (request.noCache) {
            _options = _options | PxNetOptionRAM;
        } else {
            _options = _options | PxNetOptionDisk;
        }
        
        _state = PxNetConnectionStatePending;
        _acceptRanges = NO;
    }
    return self;
}

#pragma mark - Options

- (BOOL)shouldKeepConnection {
    return [self shouldFileStore];
}

- (BOOL)canQueue {
    return !(_options & PxNetOptionNoCache);
}

- (BOOL)isPausable {
    return self.lastModifiedResponse != nil && self.acceptRanges;
}

#pragma mark - Connection LifeCycle
- (void)startRequest:(NSURLRequest *)request {
    if (self.state != PxNetConnectionStateRunning) {
        self.state = PxNetConnectionStateRunning;
        NSOperationQueue *queue;
        if ([self.delegate respondsToSelector:@selector(queueForConnection:)]) {
            queue = [self.delegate queueForConnection:self];
        }
        
        if (queue) {
            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [self.connection setDelegateQueue:queue];
            [self.connection start];
        } else {
            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
}

- (void)cleanConnection {
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.connection cancel];
    self.connection = nil;
}

- (void)startConnection {
    if (self.state == PxNetConnectionStatePending) {
        [self startRequest:self.request];
    }
}

- (void)resumeConnection {
    if (self.state == PxNetConnectionStatePaused) {
        
        NSMutableURLRequest *request = [self.request mutableCopy];
        
        if (self.lastModifiedResponse && self.currentByteCount > 0 && self.expectedByteCount != NSURLResponseUnknownLength && self.acceptRanges) {
            [request setValue:self.lastModifiedResponse forHTTPHeaderField:PxHTTPHeaderIfRange];
            [request setValue:[NSString stringWithFormat:@"bytes=%lld-%lld", self.currentByteCount, self.expectedByteCount-1] forHTTPHeaderField:PxHTTPHeaderRange];
        }
        [self startRequest:request];
    }
}

- (void)pauseConnection {
    if ([self isPausable] && self.state == PxNetConnectionStateRunning) {
        self.state = PxNetConnectionStatePaused;
        if ([self shouldFileStore] && self.tmpFile ) {
            self.inMemoryStore = nil;
        }else if ([self shouldMemoryStore] && self.inMemoryStore) {
            _options = _options | PxNetOptionDisk;
            self.tmpFile = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
            if (!self.tmpFile) {
                PxError(@"<PxNetConnection> Could not Create filehandler for writing at path:\n\t\t%@", [self tmpFilePath]);
            }else {
                [self.tmpFile writeData:self.inMemoryStore];
            }
            self.inMemoryStore = nil;
        }
        [self cleanConnection];
    }
}

- (void)stopConnection {
    if (self.state == PxNetConnectionStateRunning) {
        self.state = PxNetConnectionStatePending;
        [self cleanConnection];
        [self cleanStorage];
    }
}

- (void)startOrResumeConnection {
    if (self.state != PxNetConnectionStateRunning) {
        if (self.state == PxNetConnectionStatePending) {
            [self startConnection];
        }else if(self.state == PxNetConnectionStatePaused) {
            [self resumeConnection];
        }else {
            // Nothing todo or Something went wrong for now?
            PxError(@"<PxNetConnection> Wrong state in startOrResumeConnection: %d", self.state);
        }
    }
}

- (void)stopOrPauseConnection {
    if (self.state == PxNetConnectionStateRunning) {
        if ([self isPausable]) {
            [self pauseConnection];
        }else {
            [self stopConnection];
        }
    }
}

#pragma mark - Response Handling

- (void)setResponse:(NSHTTPURLResponse *)r {
    if (r != _response) {
        if ([r isKindOfClass:[NSHTTPURLResponse class]]) {
            _response = (NSHTTPURLResponse*)r;
            
            NSHTTPURLResponse* httpResponse = _response;
            NSDictionary *header = [httpResponse allHeaderFields];
            self.lastModifiedResponse = [header valueForKey:@"Last-Modified"];
            
            // not an If-Range Response
            if ([httpResponse statusCode] != 206) {
                self.acceptRanges = [[header valueForKey:@"Accept-Ranges"] isEqualToString:@"bytes"];
                self.expectedByteCount = [r expectedContentLength];
                [self cleanStorage];
            }
        } else if (r == nil) {
            _response = nil;
            [self cleanConnection];
        } else {
            PxError(@"<PxNetConnection> Unsupported Response-Class in setResponse: %@", NSStringFromClass([r class]));
            _response = nil;
            [self cleanConnection];
            [self cleanStorage];
            [self.delegate connection:self didStop:YES];
        }
    }
}

#pragma mark - Data Storage
- (NSString *)tmpFilePath {
    if (_tmpFilePath == nil) {
        _tmpFilePath = [NSString stringWithFormat:@"%@%@", PxTempDirectory(), [[NSUUID UUID] UUIDString]];
        [[NSFileManager defaultManager] createFileAtPath:_tmpFilePath contents:[NSData data] attributes:nil];
    }
    return _tmpFilePath;
}

- (BOOL)shouldMemoryStore {
    return (_options & PxNetOptionRAM);
}

- (BOOL)shouldFileStore {
    return (_options & PxNetOptionDisk);
}

- (void)initStorage {
    [self cleanStorage];
    self.currentByteCount = 0;
    if ([self shouldFileStore]) {
        self.tmpFile = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
        if (!self.tmpFile) {
            PxError(@"<PxNetConnection> Could not Create filehandler for writing at path:\n\t\t%@", [self tmpFilePath]);
        }
    }
    if ([self shouldMemoryStore]) {
        long long length;
        if (self.expectedByteCount != NSURLResponseUnknownLength) {
            length = self.expectedByteCount;
        }else {
            length = 1024;
        }
        self.inMemoryStore = [[NSMutableData alloc] initWithCapacity:(NSUInteger)length];
    }
    self.storeIsReady = YES;
}

- (void)appendData:(NSData*)data {
    self.currentByteCount += [data length];
    if ([self shouldFileStore] && self.tmpFile) {
        [self.tmpFile writeData:data];
    }
    if ([self shouldMemoryStore] && self.inMemoryStore) {
        [self.inMemoryStore appendData:data];
    }
}

- (void)cleanStorage {
    self.tmpFilePath = nil;
    self.tmpFile = nil;
    self.inMemoryStore = nil;
    self.storeIsReady = NO;
}

#pragma mark - Data Access

- (id)rawData {
    if ([self shouldMemoryStore] && self.inMemoryStore) {
        return self.inMemoryStore;
    }else if([self shouldFileStore] && self.tmpFile) {
        return [NSData dataWithContentsOfFile:[self tmpFilePath]];
    }
    return nil;
}

- (NSString*)filePath {
    if ([self shouldFileStore]) {
        if (!self.tmpFile) {
            self.tmpFile = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
            if (!self.tmpFile) {
                PxError(@"<PxNetConnection> Could not Create filehandler for writing at path:\n\t\t%@", [self tmpFilePath]);
            }else {
                [self.tmpFile writeData:self.inMemoryStore];
            }
        }
        return [self tmpFilePath];
    }
    return nil;
}

- (NSDictionary *)httpHeader {
    if (self.response) {
        return [self.response allHeaderFields];
    }
    return nil;
}

- (NSString *)storeInCache:(PxNetCache *)cache {
    if (!self.finilazed) {
        [cache storeDataFromFile:self.tmpFilePath forURL:[NSURL URLWithString:[self URLString]] header:[self httpHeader]];
        self.finilazed = YES;
    }
    return [cache pathForURL:[NSURL URLWithString:[self URLString]] header:nil creationDate:nil];
}

- (BOOL)isFinilazed {
    return self.finilazed;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    self.expectedByteCount = totalBytesExpectedToWrite;
    self.currentByteCount = totalBytesWritten;
}


- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data {
	if( ![self storeIsReady] ) {
        [self initStorage];
	}
    [self appendData:data];
}


- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
    PxError(@"<PxNetConnection> connection:didFailWithError:\n\t\t%@", error);
    self.statusCode = 906;
    self.state = PxNetConnectionStateFailed;
    [self.delegate connection:self didCompleteWithStatus:self.statusCode];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)c {
    // hack to set progress to 100%
    if (self.currentByteCount == 0) {
        self.currentByteCount = 1;
    }
    self.expectedByteCount = self.currentByteCount;
    self.statusCode = [self.response statusCode];
    self.state = PxNetConnectionStateFinished;
    [self.delegate connection:self didCompleteWithStatus:self.statusCode];
}


- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSHTTPURLResponse *)r {
	[self setResponse:r];
}


#pragma mark - Memory managment
- (void)dealloc {
    [self cleanConnection];
    [self cleanStorage];
}

@end
