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
//  PxDatePicker.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxPickerContainer.h"

UIKIT_EXTERN NSString *const PxDatePickerWillShowNotification;
UIKIT_EXTERN NSString *const PxDatePickerDidShowNotification;
UIKIT_EXTERN NSString *const PxDatePickerWillHideNotification;
UIKIT_EXTERN NSString *const PxDatePickerDidHideNotification;

@protocol PxDatePickerDelegate;

@interface PxDatePicker : PxPickerContainer 
@property(weak, nonatomic) id<PxDatePickerDelegate> delegate;
#pragma mark - UIDatePicker property forwarding
@property(nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, assign) NSTimeInterval countDownDuration;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, assign) UIDatePickerMode datePickerMode;
@property(nonatomic, strong) NSLocale *locale;
@property(nonatomic, strong) NSDate *maximumDate;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, assign) NSInteger minuteInterval;
@property(nonatomic, strong) NSTimeZone *timeZone;

+ (void)showWithDelegate:(id<PxDatePickerDelegate>)delegate;
+ (void)close:(BOOL)done;

#pragma mark - UIDatePicker instance method forwarding
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end

@protocol PxDatePickerDelegate <NSObject>

- (void)datePicker:(PxDatePicker *)picker didFinishWithDate:(NSDate*)date;
- (void)datePicker:(PxDatePicker *)picker changedDate:(NSDate*)date;

@optional
- (void)datePicker:(PxDatePicker *)picker willShowWithDate:(NSDate*)date;
- (void)datePickerDidCancel:(PxDatePicker*)picker;
- (NSDate*)startValueForDatePicker:(PxDatePicker*)picker;

@end
