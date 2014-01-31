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
//  PxRemoteImageService.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxRemoteImageService.h"
#import "PxImageStorage.h"

dispatch_queue_t getSerialWorkQueue();

typedef void (^CompletionHandler)();

@interface PxRemoteImageService () <NSURLSessionDelegate>
@property (nonatomic, strong) PxImageStorage *imageStorage;
@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) NSMutableDictionary *completionBlockDictionary;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSMutableDictionary *runningTasks;

- (void)addCompletionBlock:(void (^)(NSString *filePath, NSURL *originalURL))completionBlock forTaskIdentifier:(NSString *)identifier;
- (NSArray *)completionBlocksForTaskIdentifier:(NSString *)identifier;

- (void)addRunningTask:(NSURLSessionDownloadTask *)task;
- (void)removeFromRunningTasks:(NSURLSessionDownloadTask *)task;

- (BOOL)isTaskRunningForURL:(NSURL *)imageURL;
- (NSString *)taskIdentifierForURL:(NSURL *)imageURL;

- (void)cleanupTask:(NSURLSessionDownloadTask *)task;

@end

@implementation PxRemoteImageService

PxSingletonImp(defaultService)

- (id)init {
    self = [super init];
    if (self) {
        self.imageStorage = [[PxImageStorage alloc] initWithCacheDir:[PxCacheDirectory() stringByAppendingPathComponent:@"pxRemoteImageService"] keepInMemory:NO];
        
        self.completionBlockDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        self.runningTasks = [NSMutableDictionary dictionaryWithCapacity:0];
        NSURLSessionConfiguration *configObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        configObject.URLCache = nil;
        configObject.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        self.downloadQueue = [[NSOperationQueue alloc] init];
        self.downloadSession = [NSURLSession sessionWithConfiguration:configObject delegate:self delegateQueue:self.downloadQueue];
        
        getSerialWorkQueue();
    }
    return self;
}

- (void)fetchLocalImagePathForURL:(NSURL *)imageURL completionBlock:(void (^)(NSString *filePath, NSURL *originalURL))completionBlock {
    dispatch_async(getSerialWorkQueue(), ^{
        NSString *filePath = [self.imageStorage imagePathForIdentifier:[PxImageStorage identifierForURL:imageURL]];
        if (filePath) {
            completionBlock(filePath, imageURL);
        } else {
            NSString *taskIdentifier = [self taskIdentifierForURL:imageURL];
            [self addCompletionBlock:completionBlock forTaskIdentifier:taskIdentifier];
            
            if (![self isTaskRunningForURL:imageURL]) {
                NSURLSessionDownloadTask *downLoadTask = [self.downloadSession downloadTaskWithURL:imageURL];
                [downLoadTask setTaskDescription:taskIdentifier];
                [self addRunningTask:downLoadTask];
                [downLoadTask resume];
            }
        }
    });
}

#pragma mark - Delegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [self.imageStorage storeImageFromLocalURL:location withIdentifier:[PxImageStorage identifierForURL:[[downloadTask originalRequest] URL]]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(getSerialWorkQueue(), ^{
        NSArray *completionBlocks = [self completionBlocksForTaskIdentifier:[task taskDescription]];
        [self cleanupTask:task];
        
        [self.downloadQueue addOperationWithBlock:^{
            NSURL *originalURL = [[task originalRequest] URL];
            NSString *filePath = [self.imageStorage imagePathForIdentifier:[PxImageStorage identifierForURL:originalURL]];
            for (id obj in completionBlocks) {
                if (obj) {
                    void (^ completionBlock)(NSString *filePath, NSURL *originalURL) = obj;
                    completionBlock(filePath, originalURL);
                }
            }
        }];
    });
}

#pragma mark - Helpers
- (NSString *)taskIdentifierForURL:(NSURL *)imageURL {
    return [imageURL absoluteString];
}

- (BOOL)isTaskRunningForURL:(NSURL *)imageURL {
    return [self.runningTasks valueForKey:[self taskIdentifierForURL:imageURL]] != nil;
}

- (void)addRunningTask:(NSURLSessionDownloadTask *)task {
    [self.runningTasks setValue:task forKey:[task taskDescription]];
}

- (void)removeFromRunningTasks:(NSURLSessionDownloadTask *)task {
    [self.runningTasks setValue:nil forKey:[task taskDescription]];
}

- (void)addCompletionBlock:(void (^)(NSString *filePath, NSURL *originalURL))completionBlock forTaskIdentifier:(NSString *)identifier {
    NSMutableArray *blocks = [self.completionBlockDictionary valueForKey:identifier];
    if (!blocks) {
        blocks = [[NSMutableArray alloc] init];
        [self.completionBlockDictionary setValue:blocks forKey:identifier];
    }
    [blocks addObject:completionBlock];
}

- (NSArray *)completionBlocksForTaskIdentifier:(NSString *)identifier {
    return [self.completionBlockDictionary valueForKey:identifier];
}

- (void)cleanupTask:(NSURLSessionDownloadTask *)task {
    [self removeFromRunningTasks:task];
    [self.completionBlockDictionary setValue:nil forKey:[task taskDescription]];
}

@end

dispatch_queue_t serialQueue;
dispatch_queue_t getSerialWorkQueue() {
    if (!serialQueue) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            serialQueue = dispatch_queue_create("net.pixelflut.remoteImageService", NULL);
        });
    }
    return serialQueue;
}
