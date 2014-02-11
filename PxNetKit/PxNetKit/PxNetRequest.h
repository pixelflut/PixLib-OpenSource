//
//  PxNetRequest.h
//  PxNetKit
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxNetResult.h"

extern NSString *kNetRequestIdentifierKey;
extern NSString *kNetRequestClassKey;
extern NSString *kNetRequestURLRequestKey;
extern NSString *kNetRequestParseDataKey;
extern NSString *kNetRequestCacheIntervalKey;

@interface PxNetRequest : NSObject
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) Class expectedClass;
@property (nonatomic, strong, readonly) NSMutableURLRequest *request;
@property (nonatomic, assign, readonly) BOOL finished;
@property (nonatomic, assign, readonly) BOOL parseData;
@property (nonatomic, assign, readonly) NSTimeInterval cacheInterval;
@property (nonatomic, strong, readonly) PxNetResult *result;

+ (instancetype)requestWithConfiguration:(NSDictionary *)configurationDictionary;

@end
