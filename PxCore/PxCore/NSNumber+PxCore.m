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
//  NSNumber+PxCore.m
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSNumber+PxCore.h"
#import "PxCore.h"

@implementation NSNumber (PxCore)

- (NSComparisonResult)compare:(id)object context:(void *)context {
    return [self compare:object];
}

- (NSMutableArray *)times:(id (^)(int nr))block {
    int end = [self intValue];
    NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:ABS(end)];
    if (end > 0) {
        for (int i = 0; i<end; i++) {
            [retVal addObject:block(i)];
        }
    }else {
        for (int i = 0; i>end; i--) {
            [retVal addObject:block(i)];
        }
    }
    return retVal;
}

- (BOOL)isNotBlank {
    return [self boolValue];
}


#pragma mark - Time Calculations
- (NSDate *)ago {
    return [NSDate dateWithTimeIntervalSinceNow:- [self intValue]];
}

- (NSNumber *)day {
    return [self days];
}

- (NSNumber *)days {
    return NR([self intValue] * (int)SECONDS_PER_DAY);
}

- (NSNumber *)hour {
    return [self hours];
}

- (NSNumber *)hours {
    return NR([self intValue] * (int)SECONDS_PER_HOUR);
}

- (NSNumber *)minute {
    return [self minutes];
}

- (NSNumber *)minutes {
    return NR([self intValue] * (int)SECONDS_PER_MINUTE);
}

- (NSNumber *)month {
    return [self months];
}

- (NSNumber *)months {
    return NR([self intValue] * (int)SECONDS_PER_MONTH);
}

- (NSNumber *)second {
    return [self seconds];
}

- (NSNumber *)seconds {
    return self;
}

- (NSDate *)since {
    return [NSDate dateWithTimeIntervalSinceNow:[self intValue]];;
}

- (NSNumber *)year {
    return [self years];
}

- (NSNumber *)years {
    return NR([self intValue] * (int)SECONDS_PER_YEAR);
}

@end
