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
//  PxHTTPConnection.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxHTTPConnection.h"
#import "PxCore.h"

@interface PxHTTPConnection (hidden)

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

@implementation PxHTTPConnection
@synthesize delegate=_delegate, state=_state, statusCode=_statusCode, expectedByteCount=_expectedByteCount, currentByteCount= _currentByteCount, URLString= _URLString;


- (id)initWithRequest:(NSURLRequest *)request delegate:(id<PxHTTPConnectionDelegate>)d {
    self = [super init];
    if (self) {
        _URLString = [[request URL] absoluteString];
        
        NSMutableURLRequest *tmp = [request mutableCopy];
        [tmp setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        _request = tmp;
        
        [self setDelegate:d];
        
        _caller = [[NSMutableArray alloc] init];
        _state = PxHTTPConnectionStatePending;
        _acceptRanges = NO;
    }
    return self;
}

#pragma mark - Caller Pool
- (void)addCaller:(PxCaller*)c {
    if ([_caller count] == 0) {
        _options = c.options;
    }else {
        if ([self canQueue]) {
            _options = _options|c.options;
        }else {
            [NSException raise:@"Invalid Use" format:@"<PxHTTPConnection> Multiple callers added to Connection with option PxRemoteOptionNoCache"];
        }
    }
    [_caller addObject:c];
}

- (void)removeCallersWithTarget:(id)target {
    [_caller deleteIf:^BOOL(PxCaller *caller) {
        return [caller target] == target;
    }];
    
    if ([_caller count] == 0 && ![self shouldKeepConnection]) {
        [self cleanConnection];
        [self cleanStorage];
        [_delegate connection:self didStop:YES];
    }
}

- (BOOL)shouldKeepConnection {
    return [self shouldFileStore];
}

- (BOOL)canQueue {
    return !(_options & PxRemoteOptionNoCache);
}

#pragma mark - Connection LifeCycle
- (void)cleanConnection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [_connection cancel];
    _connection = nil;
    _response = nil;
}

- (BOOL)isPausable {
    return _lastModifiedResponse != nil && _acceptRanges;
}

- (void)startConnection {
    if (_state == PxHTTPConnectionStatePending) {
        _state = PxHTTPConnectionStateRunning;
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)resumeConnection {
    if (_state == PxHTTPConnectionStatePaused) {
        _state = PxHTTPConnectionStateRunning;
        
        NSMutableURLRequest *request = [_request mutableCopy];
        
        if (_lastModifiedResponse && _currentByteCount > 0 && _expectedByteCount != NSURLResponseUnknownLength && _acceptRanges) {
            [request setValue:_lastModifiedResponse forHTTPHeaderField:PxHTTPHeaderIfRange];
            [request setValue:[NSString stringWithFormat:@"bytes=%lld-%lld", _currentByteCount, _expectedByteCount-1] forHTTPHeaderField:PxHTTPHeaderRange];
        }
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)pauseConnection {
    if ([self isPausable] && _state == PxHTTPConnectionStateRunning) {
        _state = PxHTTPConnectionStatePaused;
        if ([self shouldFileStore] && _tmpFile ) {
            _inMemoryStore = nil;
        }else if ([self shouldMemoryStore] && _inMemoryStore) {
            _options = _options|PxRemoteOptionDisk;
            _tmpFile = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
            if (!_tmpFile) {
                PxError(@"<PxHTTPConnection> Could not Create filehandler for writing at path:\n\t\t%@", [self tmpFilePath]);
            }else {
                [_tmpFile writeData:_inMemoryStore];
            }
            _inMemoryStore = nil;
        }
        [self cleanConnection];
    }
}

- (void)stopConnection {
    if (_state == PxHTTPConnectionStateRunning) {
        _state = PxHTTPConnectionStatePending;
        [self cleanConnection];
        [self cleanStorage];
    }
}

- (void)startOrResumeConnection {
    if (_state != PxHTTPConnectionStateRunning) {
        if (_state == PxHTTPConnectionStatePending) {
            [self startConnection];
        }else if(_state == PxHTTPConnectionStatePaused) {
            [self resumeConnection];
        }else {
            // Nothing todo or Something went wrong for now?
            PxError(@"<PxHTTPConnection> Wrong state in startOrResumeConnection: %d", _state);
        }
    }
}

- (void)stopOrPauseConnection {
    if (_state == PxHTTPConnectionStateRunning) {
        if ([self isPausable]) {
            [self pauseConnection];
        }else {
            [self stopConnection];
        }
    }
}

#pragma mark - Response Handling

- (void)setResponse:(NSURLResponse *)r {
    if (r != _response) {
        if ([r isKindOfClass:[NSHTTPURLResponse class]]) {
            _response = (NSHTTPURLResponse*)r;

            NSHTTPURLResponse* httpResponse = _response;
            NSDictionary *header = [httpResponse allHeaderFields];
            _lastModifiedResponse = [header valueForKey:@"Last-Modified"];
            
            // not an If-Range Response
            if ([httpResponse statusCode] != 206) {
                _acceptRanges = [[header valueForKey:@"Accept-Ranges"] isEqualToString:@"bytes"];
                _expectedByteCount = [r expectedContentLength];
                [self cleanStorage];
            }
        }else {
            PxError(@"<PxHTTPConnection> Unsupported Response-Class in setResponse: %@", NSStringFromClass([r class]));
            _response = nil;
            [self cleanConnection];
            [self cleanStorage];
            [_delegate connection:self didStop:YES];
        }
    }
}

#pragma mark - Data Storage
- (NSString*)tmpFilePath {
    if (_tmpFilePath == nil) {
        _tmpFilePath = [NSString stringWithFormat:@"%@%@", PxTempDirectory(), [NSString UUID]];
        [[NSFileManager defaultManager] createFileAtPath:_tmpFilePath contents:[NSData data] attributes:nil];
    }
    return _tmpFilePath;
}

- (BOOL)shouldMemoryStore {
    return (_options & PxRemoteOptionRAM);
}

- (BOOL)shouldFileStore {
    return (_options & PxRemoteOptionDisk);
}

- (BOOL)storageReady {
    return _storeIsReady;
}

- (void)initStorage {
    [self cleanStorage];
    _currentByteCount = 0;
    if ([self shouldFileStore]) {
        _tmpFile = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
        if (!_tmpFile) {
            PxError(@"<PxHTTPConnection> Could not Create filehandler for writing at path:\n\t\t%@", [self tmpFilePath]);
        }
    }
    if ([self shouldMemoryStore]) {
        NSInteger length;
        if (_expectedByteCount != NSURLResponseUnknownLength) {
            length = _expectedByteCount;
        }else {
            length = 1024;
        }
        _inMemoryStore = [[NSMutableData alloc] initWithCapacity:length];
    }
    _storeIsReady = YES;
}

- (void)appendData:(NSData*)data {
    _currentByteCount += [data length];
    if ([self shouldFileStore] && _tmpFile) {
        [_tmpFile writeData:data];
    }
    if ([self shouldMemoryStore] && _inMemoryStore) {
        [_inMemoryStore appendData:data];
    }
}

- (void)cleanStorage {
    _tmpFilePath = nil;
    _tmpFile = nil;
    _inMemoryStore = nil;
    _storeIsReady = NO;
}

#pragma mark - Data Access

- (id)rawData {
    if ([self shouldMemoryStore] && _inMemoryStore) {
        return _inMemoryStore;
    }else if([self shouldFileStore] && _tmpFile) {
        return [NSData dataWithContentsOfFile:[self tmpFilePath]];
    }
    return nil;
}

- (NSString*)filePath {
    if ([self shouldFileStore]) {
        if (!_tmpFile) {
            _tmpFile = [NSFileHandle fileHandleForWritingAtPath:[self tmpFilePath]];
            if (!_tmpFile) {
                PxError(@"<PxHTTPConnection> Could not Create filehandler for writing at path:\n\t\t%@", [self tmpFilePath]);
            }else {
                [_tmpFile writeData:_inMemoryStore];
            }
        }
        return [self tmpFilePath];
    }
    return nil;
}

- (NSDictionary *)httpHeader {
    if (_response) {
        return [_response allHeaderFields];
    }
    return nil;
}

- (NSArray *)caller {
    return [NSArray arrayWithArray:_caller];
}

- (NSString *)storeInCache:(PxHTTPCache *)cache {
    if (!_finilazed) {
        [cache storeDataFromFile:_tmpFilePath forURL:[NSURL URLWithString:[self URLString]] header:[self httpHeader]];
        _finilazed = YES;
    }
    return [cache pathForURL:[NSURL URLWithString:[self URLString]] header:nil creationDate:nil];
}

- (BOOL)isFinilazed {
    return _finilazed;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    _expectedByteCount = totalBytesExpectedToWrite;
    _currentByteCount = totalBytesWritten;
}


- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data {
	if( ![self storageReady] ) {
        [self initStorage];
	}
    [self appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _statusCode = 504;
    _state = PxHTTPConnectionStateFailed;
    [_delegate connection:self didCompleteWithStatus:_statusCode];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)c {
    // hack to set progress to 100%
    if (_currentByteCount == 0) {
        _currentByteCount = 1;
    }
    _expectedByteCount = _currentByteCount;
    _statusCode = [_response statusCode];
    _state = PxHTTPConnectionStateFinished;
    [_delegate connection:self didCompleteWithStatus:_statusCode];
}


- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)r {
	[self setResponse:r];
}

#pragma mark - Memory managment
- (void)dealloc {
    [self cleanConnection];
    [self cleanStorage];
}

@end
