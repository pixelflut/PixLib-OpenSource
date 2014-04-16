//
//  PxMarkupKitXMLSupport.h
//  PxMarkupKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxMarkupKitMapping.h"

extern NSString *kPxMarkupXMLVersionHead1;
extern NSString *kPxMarkupXMLVersionHead2;

extern NSString *kPxMarkupTagKey;
extern NSString *kPxMarkupCXMLRootKey;

NSString *PxXMLEscape(id<PxMarkupAttribute> object);
NSString *PxXMLUnescape(NSString *string);