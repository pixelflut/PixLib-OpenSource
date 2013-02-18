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
//  NSDate+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSDate+PixLib.h"
#import "PxCore.h"

@implementation NSDate (PixLib)


+ (NSDate *)dateWithOptions:(void (^)(PxDateOptions *options))block {
    PxDateOptions opts = {0,1,1,0,0,0};
    block(&opts);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:opts.year];
	[comps setMonth:opts.month];
	[comps setDay:opts.day];
	[comps setHour:opts.hour];
	[comps setMinute:opts.minute];
	[comps setSecond:opts.second];

	NSDate *ret = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return ret;
}

- (NSDate *)dateWithOptions:(void (^)(PxDateOptions *options))block {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:self];
    
    PxDateOptions opts = {components.year, components.month, components.day, components.hour, components.minute, components.second};
    block(&opts);
    [components setYear:opts.year];
	[components setMonth:opts.month];
	[components setDay:opts.day];
	[components setHour:opts.hour];
	[components setMinute:opts.minute];
	[components setSecond:opts.second];
    
    return [gregorian dateFromComponents:components];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	return [formatter stringFromDate:self];
}

- (NSString *)stringWithStyle:(NSDateFormatterStyle)style {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:style];
	return [formatter stringFromDate:self];
}

- (NSString *)distanceOfTimeInWords {
	return [self distanceOfTimeInWords:[NSDate date]];
}

- (NSString *)distanceOfTimeInWords:(NSDate *)date {
	NSString *Ago = NSLocalizedString(@"ago", @"Denotes past dates");
	NSString *FromNow = NSLocalizedString(@"from now", @"Denotes future dates");
	NSString *LessThan = NSLocalizedString(@"Less than", @"Indicates a less-than number");
	NSString *About = NSLocalizedString(@"About", @"Indicates an approximate number");
	NSString *Over = NSLocalizedString(@"Over", @"Indicates an exceeding number");
	NSString *Almost = NSLocalizedString(@"Almost", @"Indicates an approaching number");
//	NSString *Second = NSLocalizedString(@"second", @"One second in time");
	NSString *Seconds = NSLocalizedString(@"seconds", @"More than one second in time");
	NSString *Minute = NSLocalizedString(@"minute", @"One minute in time");
	NSString *Minutes = NSLocalizedString(@"minutes", @"More than one minute in time");
	NSString *Hour = NSLocalizedString(@"hour", @"One hour in time");
	NSString *Hours = NSLocalizedString(@"hours", @"More than one hour in time");
	NSString *Day = NSLocalizedString(@"day", @"One day in time");
	NSString *Days = NSLocalizedString(@"days", @"More than one day in time");
	NSString *Month = NSLocalizedString(@"month", @"One month in time");
	NSString *Months = NSLocalizedString(@"months", @"More than one month in time");
	NSString *Year = NSLocalizedString(@"year", @"One year in time");
	NSString *Years = NSLocalizedString(@"years", @"More than one year in time");
	
	NSTimeInterval since = [self timeIntervalSinceDate:date];
	NSString *direction = since <= 0.0 ? Ago : FromNow;
	since = fabs(since);
	
	int seconds = (int)since;
	int minutes = (int)round(since / SECONDS_PER_MINUTE);
	int hours = (int)round(since / SECONDS_PER_HOUR);
	int days = (int)round(since / SECONDS_PER_DAY);
	int months = (int)round(since / SECONDS_PER_MONTH);
	int years = (int)floor(since / SECONDS_PER_YEAR);
	int offset = (int)round(floor((float)years / 4.0) * 1440.0);
	int remainder = (minutes - offset) % 525600;
	
	int number;
	NSString *measure;
	NSString *modifier = @"";
	
	switch (minutes) {
		case 0 ... 1:
			measure = Seconds;
			switch (seconds) {
				case 0 ... 4:
					number = 5;
					modifier = LessThan;
					break;
				case 5 ... 9:
					number = 10;
					modifier = LessThan;
					break;
				case 10 ... 19:
					number = 20;
					modifier = LessThan;
					break;
				case 20 ... 39:
					number = 30;
					modifier = About;
					break;
				case 40 ... 59:
					number = 1;
					measure = Minute;
					modifier = LessThan;
					break;
				default:
					number = 1;
					measure = Minute;
					modifier = About;
					break;
			}
			break;
		case 2 ... 44:
			number = minutes;
			measure = Minutes;
			break;
		case 45 ... 89:
			number = 1;
			measure = Hour;
			modifier = About;
			break;
		case 90 ... 1439:
			number = hours;
			measure = Hours;
			modifier = About;
			break;
		case 1440 ... 2529:
			number = 1;
			measure = Day;
			break;
		case 2530 ... 43199:
			number = days;
			measure = Days;
			break;
		case 43200 ... 86399:
			number = 1;
			measure = Month;
			modifier = About;
			break;
		case 86400 ... 525599:
			number = months;
			measure = Months;
			break;
		default:
			number = years;
			measure = number == 1 ? Year : Years;
			if (remainder < 131400) {
				modifier = About;
			} else if (remainder < 394200) {
				modifier = Over;
			} else {
				++number;
				measure = Years;
				modifier = Almost;
			}
			break;
	}
	if ([modifier length] > 0) {
		modifier = [modifier stringByAppendingString:@" "];
	}
	return [NSString stringWithFormat:@"%@%d %@ %@", modifier, number, measure, direction];
}

- (NSString*)stringForXMLAttribute {
    return [NSString stringWithFormat:@"%d", (int)[self timeIntervalSince1970]];
}

- (NSDate *)dateAtBeginningOfDay {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *components = [cal components:flags fromDate:self];
	
    return [NSDate dateWithOptions:^(PxDateOptions *options) {
        options->year = components.year;
        options->month = components.month;
        options->day = components.day;
    }];
}

- (NSInteger)yearsFromNow {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger flag = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	
	NSDateComponents *from = [cal components:flag fromDate:self];
	NSDateComponents *to = [cal components:flag fromDate:[NSDate date]];
	
	if([to month] > [from month] || ([to month] == [from month] && [to day] >= [from day])) {
		return ([to year] - [from year]);
	}else{
		return ([to year] - [from year]) - 1;
	}
}

- (NSInteger)daysFromNow:(Boolean)annualy {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger flag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *cur = [cal components:flag fromDate:[NSDate date]];
	NSDateComponents *to = [cal components:flag fromDate:self];
	
    if( annualy == YES ) {
        if([cur month] >= [to month] && [cur day] > [to day]) {
            [to setYear:[cur year] + 1];
        }else{
            [to setYear:[cur year]];
        }
    }
	
	NSTimeInterval interval = [[cal dateFromComponents:to] timeIntervalSinceDate:[cal dateFromComponents:cur]];
	return (interval / 86400);
}

- (NSInteger)daysFromNowAnnually {
	return [self daysFromNow:YES];
}

- (NSInteger)daysFromNow {
	return [self daysFromNow:NO];
}

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self] year];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self] month];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self] day];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:self] hour];
}

- (NSInteger)minute {
    return [[[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:self] minute];
}

- (NSInteger)second {
    return [[[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:self] minute];
}

- (NSDate *)advance:(void (^)(PxDateOptions *options))block {
    PxDateOptions opts = {0,0,0,0,0,0};
    block(&opts);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
	NSDateComponents *from = [gregorian components:NSUIntegerMax fromDate:self];
    NSDateComponents *to = [[NSDateComponents alloc] init];
    
    [to setYear:[from year] + opts.year];
    [to setMonth:[from month] + opts.month];
    [to setDay:[from day] + opts.day];
	[to setHour:[from hour] + opts.hour];
    [to setMinute:[from minute] + opts.minute];
    [to setSecond:[from second] + opts.second];
    
    return [gregorian dateFromComponents:to];
}

- (BOOL)isToday {
	return [[self dateAtBeginningOfDay] isEqualToDate:[[NSDate date] dateAtBeginningOfDay]];
}

@end
