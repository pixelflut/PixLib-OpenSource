//
//  UIControl+PxUIKit.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 17.06.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (PxUIKit)
@property (nonatomic, assign) UIEdgeInsets hitInsets;
@property (nonatomic, assign) CGSize minimumHitSize;

@end
