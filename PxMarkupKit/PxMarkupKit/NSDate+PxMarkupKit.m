//
//  NSDate+PxMarkupKit.m
//  PxMarkupKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "NSDate+PxMarkupKit.h"

@implementation NSDate (PxMarkupKit)

- (NSString*)stringForMarkupAttribute {
    return [NSString stringWithFormat:@"%d", (int)[self timeIntervalSince1970]];
}

@end
