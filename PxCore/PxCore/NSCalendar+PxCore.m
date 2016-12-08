//
//  NSCalendar+PxCore.m
//  PxCore-OpenSource
//
//  Created by Jonathan Cichon on 01.07.13.
//  Copyright (c) 2013 pixelflut GmbH. All rights reserved.
//

#import "NSCalendar+PxCore.h"

static NSString *__calendarKey__ = @"__pxSharedCalendar__";

@implementation NSCalendar (PxCore)

+ (instancetype)sharedCalendar {
    NSThread *thread = [NSThread currentThread];
    NSCalendar *calendar = [[thread threadDictionary] valueForKey:__calendarKey__];
    if (!calendar) {
        calendar = [self currentCalendar];
        [[thread threadDictionary] setValue:calendar forKey:__calendarKey__];
    }
    return calendar;
}

+ (instancetype)gregorianCalendar {
    NSThread *thread = [NSThread currentThread];
    NSCalendar *calendar = [[thread threadDictionary] valueForKey:__calendarKey__];
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [[thread threadDictionary] setValue:calendar forKey:__calendarKey__];
    }
    return calendar;
}

@end
