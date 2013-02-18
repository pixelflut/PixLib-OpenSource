//
//  PxHTTPCache.m
//  PixLib
//
//  Created by Jonathan Cichon on 12.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import "PxHTTPCache.h"
#import "PxCore.h"

NSString *const PxHTTPHeaderMimeType = @"Content-Type";
NSString *const PxHTTPHeaderIfModified = @"If-Modified-Since";
NSString *const PxHTTPHeaderLastModified = @"Last-Modified";
NSString *const PxHTTPHeaderIfRange = @"If-Range";
NSString *const PxHTTPHeaderRange = @"Range";

@interface PxHTTPCache ()
@property(nonatomic, strong) NSString *cacheDir;

- (NSString *)cacheDir;
- (NSString *)fileName:(NSURL *)url;
- (NSString *)filePath:(NSURL *)url;
- (NSString *)headerPath:(NSString *)filePath;

@end

@implementation PxHTTPCache

- (NSString *)cacheSubDir {
    return @"files";
}

#pragma mark - File access helper

- (NSString *)cacheDir {
    if (!_cacheDir) {
        _cacheDir = [PxCacheDirectory() stringByAppendingPathComponent:[self cacheSubDir]];
        [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return _cacheDir;
}

- (NSString *)fileName:(NSURL *)url {
    return [[[url absoluteString] stringByAddingSHA256Encoding] stringByAppendingPathExtension:[[url relativePath] pathExtension]];
}

- (NSString *)filePath:(NSURL *)url {
    return [[self cacheDir] stringByAppendingPathComponent:[self fileName:url]];
}

- (NSString *)headerPath:(NSString *)filePath {
    return [filePath stringByAppendingString:@"_header.plist"];
}

#pragma mark - Cache maintanance

- (void)setShouldClearAutomatic:(BOOL)shouldClearAutomatic {
    if (shouldClearAutomatic != _shouldClearAutomatic) {
        _shouldClearAutomatic = shouldClearAutomatic;
        if (_shouldClearAutomatic) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAutomaticClear) name:UIApplicationWillTerminateNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
        }
    }
}

- (void)doAutomaticClear {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-_automaticClearInterval];
    [self clearFilesOlderThan:date];
}

- (void)clear {
    NSString *path = [self cacheDir];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString *trash = [NSString stringWithFormat: @"%@/%@_%d", PxTempDirectory(), [self cacheSubDir], arc4random()];
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:trash error:NULL];
    }
}

- (void)clearFilesForURL:(NSURL *)url {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self filePath:url];
    NSString *headerPath = [self headerPath:filePath];
    if ([fm fileExistsAtPath:filePath]) {
        [fm removeItemAtPath:filePath error:NULL];
    }
    if ([fm fileExistsAtPath:headerPath]) {
        [fm removeItemAtPath:headerPath error:NULL];
    }
}

- (void)clearFilesOlderThan:(NSDate *)date {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [self cacheDir];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSDate *creationDate;
        [url getResourceValue:&creationDate forKey:NSURLCreationDateKey error:&error];
        if (!error) {
            if ([creationDate timeIntervalSinceDate:date] < 0) {
                [fm removeItemAtURL:url error:&error];
                if (error) {
                    PxError(@"%@", error);
                }
            }
        } else {
            PxError(@"%@", error);
        }
    }
}


#pragma mark - Cache access

- (NSString *)pathForURL:(NSURL *)url header:(NSDictionary **)header creationDate:(NSDate **)creationDate {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self filePath:url];
    if ([fm fileExistsAtPath:filePath]) {
        if (header != nil) {
            NSString *headerPath = [self headerPath:filePath];
            if ([fm fileExistsAtPath:headerPath]) {
                *header = [NSDictionary dictionaryWithContentsOfFile:headerPath];
            }
        }
        if (creationDate != nil) {
            NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            *creationDate = [dict fileCreationDate];
        }
        return filePath;
    }
    return nil;
}


#pragma mark - Cache storage

- (void)storeData:(NSData *)data forURL:(NSURL *)url header:(NSDictionary *)header {
    NSString *filePath = [self filePath:url];
    [data writeToFile:filePath atomically:YES];
    
	if (header != nil) {
		[header writeToFile:[self headerPath:filePath] atomically:YES];
	}
}

- (void)storeDataFromFile:(NSString *)filePath forURL:(NSURL *)url header:(NSDictionary *)header {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *destinationPath   = [self filePath:url];
    
    NSError *error = nil;
    if ([fm fileExistsAtPath:destinationPath]) {
        [fm removeItemAtPath:destinationPath error:&error];
        if (error) {
            PxError(@"storeDataFromFile remove old File:\nfilePath: %@\nurl: %@\nheader: %@\nerror: %@", filePath, url, header, error);
        }
    }
    error = nil;
    
    [fm moveItemAtPath:filePath toPath:destinationPath error:&error];
    if (error && [error code] != 512) {
        PxError(@"storeDataFromFile:\nfilePath: %@\nurl: %@\nheader: %@\nerror: %@", filePath, url, header, error);
    }
    
    if (header != nil) {
        [header writeToFile:[self headerPath:destinationPath] atomically:YES];
    }
}
@end
