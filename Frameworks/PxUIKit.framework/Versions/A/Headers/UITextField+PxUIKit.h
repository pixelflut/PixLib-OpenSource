//
//  UITextField+PxUIKit.h
//  PxUIKit
//
//  Created by Tobias Kreß on 13.06.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (PxUIKit)

/** Returns the color for the placeholders first character
 @return The color of the placeholders first character.
 */
- (UIColor *)placeholderColor;

/** Sets the color for the placeholder.
 @param placeholderColor The color for the placeholder.
 */
- (void)setPlaceholderColor:(UIColor *)placeholderColor;

@end
