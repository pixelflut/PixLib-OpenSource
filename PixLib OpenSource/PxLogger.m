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
//  PxLogger.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxLogger.h"

@interface PxLogger ()
@property(nonatomic, assign) PxLogLevel logLevel;
@property(nonatomic, strong) NSArray *silenceFiles;
+ (PxLogger *)defaultLogger;
@end

@implementation PxLogger

+ (void)setLogLevel:(PxLogLevel)logLevel {
    [[self defaultLogger] setLogLevel:logLevel];
}

+ (PxLogLevel)logLevel {
    return [[self defaultLogger] logLevel];
}

+ (void)setSilenceFiles:(NSArray *)silenceFiles {
    [[self defaultLogger] setSilenceFiles:silenceFiles];
}

+ (NSArray *)silenceFiles {
    return [[self defaultLogger] silenceFiles];
}

#pragma mark - Singleton Handling
static PxLogger* sharedLogger = nil;
+ (PxLogger *)defaultLogger {
    if (!sharedLogger) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedLogger = [[super allocWithZone:NULL] init];
        });
    }
    return sharedLogger;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultLogger];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

#pragma mark - C Functions

static inline void PxReportv(BOOL doLog, char const *file, int line, NSString *prefix, NSString *fmt, va_list argList) {
    if (doLog) {
        NSString *fileNameWithExtension = [[NSString stringWithFormat:@"%s", file] lastPathComponent];
        
        if ([PxLogger silenceFiles]) {
            NSString *fileName = [fileNameWithExtension stringByDeletingPathExtension];
            for (NSString *except in [PxLogger silenceFiles]) {
                if ([except isEqualToString:fileName]) {
                    return;
                }
            }
        }
        
        NSString *print = [[[NSString alloc] initWithFormat:[[NSString alloc] initWithFormat:@"%@ <%@ [%d]> %@\n", prefix, fileNameWithExtension, line, fmt] arguments:argList] stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
        vprintf([print cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
}

void PxReport(PxLogLevel logLevel, char const *file, int line, NSString *prefix, NSString *fmt, ...) {
    BOOL doLog = (logLevel <= [PxLogger logLevel]);
    va_list ap;
	va_start(ap, fmt);
    PxReportv(doLog, file, line, prefix, fmt, ap);
	va_end(ap);
}