//
//  PxCaller.m
//  PixLib
//
//  Created by Jonathan Cichon on 13.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
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
