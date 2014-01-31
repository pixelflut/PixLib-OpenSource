//
//  UIApplication+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIApplication+PxUIKit.h"

@implementation UIApplication (PxUIKit)

- (NSString *)applicationName {
    NSDictionary *di = [[NSBundle mainBundle] infoDictionary];
    return [di valueForKey:@"CFBundleExecutable"];
}

- (NSString *)applicationVersion {
    NSDictionary *di = [[NSBundle mainBundle] infoDictionary];
    
    NSString *applicationVersion = [di valueForKey:@"CFBundleShortVersionString"];
    if (!applicationVersion) {
        applicationVersion = [di valueForKey:@"CFBundleVersion"];
    }
    return applicationVersion;
}

@end
