//
//  UIAlertController+PixLib.m
//  PixLib-OpenSource
//
//  Created by Jonathan Cichon on 27.11.16.
//  Copyright © 2016 pixelflut GmbH. All rights reserved.
//

#import "UIAlertController+PixLib.h"

@implementation UIAlertController (PixLib)

- (UIAlertAction *)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:handler];
    [self addAction:action];
    return action;
}

@end
