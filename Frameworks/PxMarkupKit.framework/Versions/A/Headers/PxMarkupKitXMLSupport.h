//
//  PxMarkupKitXMLSupport.h
//  PxMarkupKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxMarkupKitMapping.h"

#define XML_VERSION_HEAD @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
#define XML_VERSION_HEAD_2 @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

NSString *PxXMLEscape(id<PxMarkupAttribute> object);
NSString *PxXMLUnescape(NSString *string);