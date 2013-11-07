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
//  PxPicker.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxPicker.h"
#import "PxCore.h"


NSString *const PxPickerWillShowNotification = @"PxPickerWillShow";
NSString *const PxPickerDidShowNotification = @"PxPickerDidShow";
NSString *const PxPickerWillHideNotification = @"PxPickerWillHide";
NSString *const PxPickerDidHideNotification = @"PxPickerDidHide";


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

@interface PxPicker (hidden)

- (void)showInWindow:(UIWindow*)window;
- (void)hide;
- (void)done;
- (void)cancel;

@end

@implementation PxPicker
@synthesize picker = _picker;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

+ (PxPicker *)instance {
    static PxPicker *_instance = nil;
    if (_instance == nil) {
        _instance = [[PxPicker alloc] init];
    }
    return _instance;
}

+ (void)showWithDelegate:(id<PxPickerDelegate>)delegate dataSource:(id<PxPickerDataSource>)dataSource {
    PxPicker *picker = [self instance];
    [picker setDelegate:delegate];
    [picker setDataSource:dataSource];
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
        _picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [_picker setOrigin:CGPointMake(0, self.frame.size.height-_picker.frame.size.height)];
		[_picker setShowsSelectionIndicator:YES];
        [self.contentView addSubview:_picker];
    }
    return self;
}

- (void)setDelegate:(id<PxPickerDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        if (!_delegate) {
            [self __hide];
        }
        [_picker setDelegate:delegate];
    }
}

- (void)setDataSource:(id<PxPickerDataSource>)dataSource {
    if (dataSource != _dataSource) {
		_dataSource = dataSource;
        [_picker setDataSource:dataSource];
    }
	
	if([_dataSource respondsToSelector:@selector(pickerView:startIndexForComponent:)]) {
		[NR([_picker numberOfComponents]) times:^id(int component) {
			NSInteger row = [_dataSource pickerView:_picker startIndexForComponent:component];
			[_picker selectRow:row inComponent:component animated:YES];
			if(_delegate) {
				[_delegate pickerView:_picker didSelectRow:row inComponent:component];
			}
			return @"";
		}];
	}
}

- (void)__cancel {
    [self setDelegate:nil];
    [self setDataSource:nil];
}

#pragma mark - Callbacks
- (NSString *)__willShowNotificationName {
    return PxPickerWillShowNotification;
}

- (NSString *)__didShowNotificationName {
    return PxPickerDidShowNotification;
}

- (NSString *)__willHideNotificationName {
    return PxPickerWillHideNotification;
}

- (NSString *)__didHideNotificationName {
    return PxPickerDidHideNotification;
}

- (void)__didHide {
    [self setDelegate:nil];
    [self setDataSource:nil];
}

@end