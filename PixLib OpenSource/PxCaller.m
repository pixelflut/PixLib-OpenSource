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
//  PxCaller.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxCaller.h"

@implementation PxCaller
@synthesize target = _target;
@synthesize action = _action;
@synthesize userInfo = _userInfo;
@synthesize expectedClass = _expectedClass;
@synthesize options = _options;


+ (id)callerWithTarget:(id)t action:(SEL)a userInfo:(id)u options:(unsigned int)o {
    return [[[self class] alloc] initWithTarget:t action:a userInfo:u options:o];
}

- (id)initWithTarget:(id)t action:(SEL)a userInfo:(id)u options:(unsigned int)o {
    if ((self = [super init])) {
		[self setTarget:t];
		[self setAction:a];
		[self setUserInfo:u];
        [self setOptions:o];
	}
	return self;
}

- (void)setOptions:(unsigned int)options {
    if (_options != options) {
        _options = options;
        if((_options & PxRemoteOptionRAM ) && ((_options & PxRemoteOptionNoCache) || (_options & PxRemoteOptionDisk))){
            [NSException raise:@"Invalid Caller options" format:@"%d", options]; 
        }
    }
}

- (BOOL)canQueue {
    return !(_options & PxRemoteOptionNoCache);
}

@end
