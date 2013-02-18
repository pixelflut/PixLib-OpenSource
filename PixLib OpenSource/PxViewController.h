//
//  PxViewController.h
//  PixLib
//
//  Created by Jonathan Cichon on 16.11.11.
//  Copyright (c) 2011 pixelflut GmbH. All rights reserved.
//

#import "PxSuperViewController.h"

@interface PxViewController : PxSuperViewController

- (UIView*)loadStdView;
- (void)updateView;
- (void)reloadData;

@end
