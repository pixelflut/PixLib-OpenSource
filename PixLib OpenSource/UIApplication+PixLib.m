//
//  UIApplication+PixLib.m
//  PixLib-OpenSource
//
//  Created by Jonathan Cichon on 12.08.13.
//  Copyright (c) 2013 pixelflut GmbH. All rights reserved.
//

#import "UIApplication+PixLib.h"

@implementation UIApplication (PixLib)

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
