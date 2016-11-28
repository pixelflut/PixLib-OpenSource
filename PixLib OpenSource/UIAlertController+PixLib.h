//
//  UIAlertController+PixLib.h
//  PixLib-OpenSource
//
//  Created by Jonathan Cichon on 27.11.16.
//  Copyright © 2016 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (PixLib)

- (UIAlertAction *)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler;

@end
