//
//  PxMarkupKitMapping.h
//  PxMarkupKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PxMarkupAttribute <NSObject>

- (NSString *)stringForMarkupAttribute;

@end


@protocol PxMarkupMapping <NSObject>

+ (id)objectForMarkupAttributes:(NSDictionary *)attributes parentObject:(id<PxMarkupMapping>)parent;

@end
