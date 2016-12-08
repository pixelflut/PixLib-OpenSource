//
//  UIAlertController+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 01.12.16.
//  Copyright © 2016 pixelflut GmbH. All rights reserved.
//

#import "UIAlertController+PxUIKit.h"

@implementation UIAlertController (PxUIKit)

- (UIAlertAction *)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:handler];
    [self addAction:action];
    return action;
}

@end
