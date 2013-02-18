//
//  PxCaller.h
//  PixLib
//
//  Created by Jonathan Cichon on 13.03.12.
//  Copyright (c) 2012 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

// The first PxRemoteOptionDisk can not combined with PxRemoteOptionRAM and PxRemoteOptionNoCache
typedef enum {
    PxRemoteOptionDisk    = 1<<0,   // Data will be stored in the Filesystem. Only way to add new cache-entries
    PxRemoteOptionRAM     = 1<<1,   // Data should be keept in Memory rather than be stored in the Filesystem. Result will not be cached, but if a cached value is available, the cached Value will be returned
    PxRemoteOptionNoCache = 1<<2,   // Should not be read from cache, no matter what
    PxRemoteOptionParse   = 1<<3    // Result should be parsed
} PxRemoteOption;

@interface PxCaller : NSObject;
@property(nonatomic, strong) id target;
@property(nonatomic, assign) SEL action;
@property(nonatomic, strong) id userInfo;
@property(nonatomic, assign) Class expectedClass;
@property(nonatomic, assign) unsigned int options;

+ (id)callerWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo options:(unsigned int)options;
- (id)initWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo options:(unsigned int)options;

- (BOOL)canQueue;

@end
