//
//  NSCalendar+PxCore.h
//  PxCore-OpenSource
//
//  Created by Jonathan Cichon on 01.07.13.
//  Copyright (c) 2013 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (PxCore)

+ (instancetype)sharedCalendar;
+ (instancetype)gregorianCalendar;

@end
