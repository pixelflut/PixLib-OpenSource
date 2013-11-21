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
//  NSFileManager+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSFileManager+PixLib.h"

NSString * PxHomeDirectory() {
    static NSString *homeDir = nil;
    if (!homeDir) {
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSUserDirectory inDomains:NSUserDomainMask];
        if ([urls count] > 0) {
            homeDir = [[urls objectAtIndex:0] path];
        }
    }
    return homeDir;
}

NSString * PxDocumentDirectory() {
    static NSString *docDir = nil;
    if (!docDir) {
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        if ([urls count] > 0) {
            docDir = [[urls objectAtIndex:0] path];
        }
    }
    return docDir;
}

NSString * PxCacheDirectory() {
    static NSString *cacheDir = nil;
    if (!cacheDir) {
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        if ([urls count] > 0) {
            cacheDir = [[urls objectAtIndex:0] path];
        }
    }
    return cacheDir;
}

NSString * PxTempDirectory() {
    static NSString *tempDir = nil;
    if (!tempDir) {
        tempDir = NSTemporaryDirectory();
    }
    return tempDir;
}

@implementation NSFileManager (PixLib)

- (unsigned long long int)sizeOfDirectoryAtPath:(NSString *)directoryPath {
    NSArray *filesArray = [self subpathsOfDirectoryAtPath:directoryPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[directoryPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

@end
