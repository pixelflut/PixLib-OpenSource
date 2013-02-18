//
//  PxHTTPCache.h
//  PixLib
//
//  Created by Jonathan Cichon on 12.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PxHTTPHeaderMimeType;
extern NSString *const PxHTTPHeaderIfModified;
extern NSString *const PxHTTPHeaderLastModified;
extern NSString *const PxHTTPHeaderIfRange;
extern NSString *const PxHTTPHeaderRange;

@interface PxHTTPCache : NSObject
@property(nonatomic, assign) BOOL shouldClearAutomatic;
@property(nonatomic, assign) NSUInteger automaticClearInterval;

- (NSString *)cacheSubDir;

- (void)clear;
- (void)clearFilesForURL:(NSURL *)url;
- (void)clearFilesOlderThan:(NSDate *)date;

- (NSString *)pathForURL:(NSURL *)url header:(NSDictionary **)header creationDate:(NSDate **)creationDate;

- (void)storeData:(NSData *)data forURL:(NSURL *)url header:(NSDictionary *)header;
- (void)storeDataFromFile:(NSString *)filePath forURL:(NSURL *)url header:(NSDictionary *)header;

@end
