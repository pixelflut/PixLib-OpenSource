//
//  PxResult.h
//  PixLib
//
//  Created by Jonathan Cichon on 13.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxCaller.h"

@interface PxResult : NSObject
@property(nonatomic, readonly, strong) PxCaller *caller;
@property(nonatomic, assign) int status;
@property(nonatomic, strong) id returnObject;
@property(nonatomic, strong) NSString *filePath;

- (id)initWithCaller:(PxCaller *)caller;

- (BOOL)isSuccess;
- (BOOL)isExpected;

@end
