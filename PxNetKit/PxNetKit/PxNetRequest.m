//
//  PxNetRequest.m
//  PxNetKit
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxNetRequest.h"

NSString *kNetRequestIdentifierKey = @"identifier";
NSString *kNetRequestClassKey = @"class";
NSString *kNetRequestURLRequestKey = @"urlRequest";
NSString *kNetRequestParseDataKey = @"parseData";
NSString *kNetRequestCacheIntervalKey = @"cacheInterval";

@interface PxNetRequest ()
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) Class expectedClass;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL parseData;
@property (nonatomic, assign) NSTimeInterval cacheInterval;
@property (nonatomic, strong) PxNetResult *result;

@end


@implementation PxNetRequest

+ (instancetype)requestWithConfiguration:(NSDictionary *)configurationDictionary {
    PxNetRequest *request = [[self alloc] init];
    request.identifier = configurationDictionary[kNetRequestIdentifierKey];
    request.expectedClass = NSClassFromString(configurationDictionary[kNetRequestClassKey]);
    request.request = configurationDictionary[kNetRequestURLRequestKey];
    request.parseData = [configurationDictionary[kNetRequestParseDataKey] boolValue];
    request.cacheInterval = [configurationDictionary[kNetRequestCacheIntervalKey] doubleValue];
    if (!request.identifier) {
        request.identifier = [[NSUUID UUID] UUIDString];
    }
    return request;
}

@end
