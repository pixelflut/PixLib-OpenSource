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
//  PxLogger.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>

typedef enum {
    PxLogLevelNone = 0,
    PxLogLevelError = 1,
    PxLogLevelWarn = 2,
    PxLogLevelInfo = 3,
    PxLogLevelDebug = 4,
    PxLogLevelLog = 5
} PxLogLevel;

/**
 * The **PxLogger** class enables you to manipulate the logging behavior of your Application.
 * Use the Macros 'PxError()', 'PxWarn()', 'PxInfo()', 'PxDebug()' and 'NSLog()' for logging.
 */
@interface PxLogger : NSObject

#pragma mark - Configurate Logging Behavior
/** @name Configurate Logging Behavior */

/** Sets the log level of the Application.
 @param logLevel The log level to be used by the Application.
 */
+ (void)setLogLevel:(PxLogLevel)logLevel;

/** Get the current log level of the Application.
 @return The log level to be used by the Application.
 */
+ (PxLogLevel)logLevel;

/** Use to disable logging in specified files.
 
 The specified file names are expected to be without extensions.
 @param silenceFiles Array of file names, for which logging should be disabled.
 */
+ (void)setSilenceFiles:(NSArray *)silenceFiles;

/** Get the current files for wich logging is disabled.
 @return Array of file names, for which logging is be disabled.
 */
+ (NSArray *)silenceFiles;

+ (void)debugRuntime:(NSString *)msg repeatCount:(unsigned int)repeatCount block:(void (^)(void))debugBlock;

@end

void PxReport(PxLogLevel logLevel, char const *file, int line, NSString *prefix, NSString *fmt, ...) NS_FORMAT_FUNCTION(5,6);

/** Logging Errors */
#define PxError(...) PxReport(PxLogLevelError, __FILE__, __LINE__, @"[ERROR]", __VA_ARGS__)

/** Logging Warnings */
#define PxWarn(...) PxReport(PxLogLevelWarn, __FILE__, __LINE__, @"[WARNING]", __VA_ARGS__)

/** Logging Infos */
#define PxInfo(...) PxReport(PxLogLevelInfo, __FILE__, __LINE__, @"[INFO]", __VA_ARGS__)

#ifdef DEBUG
/** Logging Debug Infos */
#define PxDebug(...) PxReport(PxLogLevelDebug, __FILE__, __LINE__, @"[DEBUG]", __VA_ARGS__)

/** Logging Infos */
#define NSLog(...) PxReport(PxLogLevelLog, __FILE__, __LINE__, @"", __VA_ARGS__)
#else
/** Logging Debug Infos */
#define PxDebug(...)

/** Logging Infos */
#define NSLog(...)
#endif

#define PxAssert(condition, ...) do { if(!(condition)){PxError(__VA_ARGS__);}}while(0)