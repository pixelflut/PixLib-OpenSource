//
//  UIAlertController+PxUIKit.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 01.12.16.
//  Copyright © 2016 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (PxUIKit)

- (UIAlertAction *)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler;

@end
