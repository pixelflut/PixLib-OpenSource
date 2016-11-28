//
//  NSCalendar+PixLib.m
//  PixLib-OpenSource
//
//  Created by Jonathan Cichon on 01.07.13.
//  Copyright (c) 2013 pixelflut GmbH. All rights reserved.
//

#import "NSCalendar+PixLib.h"

static NSString *__calendarKey__ = @"__pxSharedCalendar__";

@implementation NSCalendar (PixLib)

+ (id)sharedCalendar {
    NSThread *thread = [NSThread currentThread];
    NSCalendar *calendar = [[thread threadDictionary] valueForKey:__calendarKey__];
    if (!calendar) {
        calendar = [self currentCalendar];
        [[thread threadDictionary] setValue:calendar forKey:__calendarKey__];
    }
    return calendar;
}

+ (id)gregorianCalendar {
    NSThread *thread = [NSThread currentThread];
    NSCalendar *calendar = [[thread threadDictionary] valueForKey:__calendarKey__];
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [[thread threadDictionary] setValue:calendar forKey:__calendarKey__];
    }
    return calendar;
}

@end
