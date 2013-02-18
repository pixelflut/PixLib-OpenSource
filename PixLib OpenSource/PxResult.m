//
//  PxResult.m
//  PixLib
//
//  Created by Jonathan Cichon on 13.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import "PxResult.h"

@implementation PxResult
@synthesize caller = _caller;
@synthesize status = _status;
@synthesize returnObject = _returnObject;
@synthesize filePath = _filePath;

- (id)initWithCaller:(PxCaller *)caller {
    self = [super init];
    if (self) {
        _caller = caller;
    }
    return self;
}

- (BOOL)isSuccess {
    return (_status < 400);
}

- (BOOL)isExpected {
    return ([self isSuccess] && [_caller expectedClass] && [_returnObject isKindOfClass:[_caller expectedClass]]);
}

@end
