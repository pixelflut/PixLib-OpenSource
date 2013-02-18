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
//  PxDatePicker.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxDatePicker.h"
#import "PxCore.h"

NSString *const PxDatePickerWillShowNotification = @"PxDatePickerWillShow";
NSString *const PxDatePickerDidShowNotification = @"PxDatePickerDidShow";
NSString *const PxDatePickerWillHideNotification = @"PxDatePickerWillHide";
NSString *const PxDatePickerDidHideNotification = @"PxDatePickerDidHide";

@interface PxPickerContainer (hidden)

- (void)__finish;
- (void)__cancel;

- (void)__show;
- (void)__hide;

- (NSString *)__willShowNotificationName;
- (NSString *)__didShowNotificationName;
- (NSString *)__willHideNotificationName;
- (NSString *)__didHideNotificationName;

- (void)__willShow;
- (void)__didShow;

- (void)__willHide;
- (void)__didHide;

@end

@interface PxDatePicker ()
@property (nonatomic, strong) UIDatePicker *datePicker;

- (void)changedDate:(UIDatePicker *)datePicker;

@end

@implementation PxDatePicker
@synthesize datePicker = _datePicker;
@synthesize delegate = _delegate;

+ (PxDatePicker*)instance {
    static PxDatePicker *_instance = nil;
    if (_instance == nil) {
        _instance = [[PxDatePicker alloc] init];
    }
    return _instance;
}

+ (void)showWithDelegate:(id<PxDatePickerDelegate>)delegate {
    PxDatePicker *picker = [self instance];
    [picker setDelegate:delegate];
    [picker __show];
}

+ (void)close:(BOOL)done {
    if (done) {
        [[self instance] done];
    }else {
        [[self instance] cancel];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
		[_datePicker addTarget:self action:@selector(changedDate:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_datePicker];
    }
    return self;
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode {
	[_datePicker setDatePickerMode:datePickerMode];
}

- (void)__cancel {
    if ([_delegate respondsToSelector:@selector(datePickerDidCancel:)]) {
        [_delegate datePickerDidCancel:self];
    }
    [self setDelegate:nil];
}

- (void)__finish {
    [_delegate datePicker:self didFinishWithDate:_datePicker.date];
}

- (void)changedDate:(UIDatePicker *)datePicker {
	[_delegate datePicker:self changedDate:_datePicker.date];
}

- (void)setDelegate:(id<PxDatePickerDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        if (!_delegate) {
            [self __hide];
        }else {
            if ([_delegate respondsToSelector:@selector(startValueForDatePicker:)]) {
                NSDate *date = [_delegate startValueForDatePicker:self];
                if ([date isKindOfClass:[NSDate class]]) {
                    [_datePicker setDate:date animated:YES];
                }else {
                    [_datePicker setDate:[NSDate date] animated:YES];
                }
            }else {
                [_datePicker setDate:[NSDate date] animated:YES];
            }
        }
    }
}

#pragma mark - Callbacks
- (NSString *)__willShowNotificationName {
    return PxDatePickerWillShowNotification;
}

- (NSString *)__didShowNotificationName {
    return PxDatePickerDidShowNotification;
}

- (NSString *)__willHideNotificationName {
    return PxDatePickerWillHideNotification;
}

- (NSString *)__didHideNotificationName {
    return PxDatePickerDidHideNotification;
}

- (void)__willShow {
    if ([_delegate respondsToSelector:@selector(datePicker:willShowWithDate:)]) {
        [_delegate datePicker:self willShowWithDate:_datePicker.date];
    }
}

- (void)__didHide {
    [self setDelegate:nil];
}

@end
