//
//  NSString+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "NSString+PxUIKit.h"

@implementation NSString (PxUIKit)

- (float)heightForWidth:(float)width config:(PxFontConfig)config {
    if(config.adjustsFontSizeToFitWidth) {
        return [self sizeWithFont:config.font minFontSize:config.minimumScaleFactor actualFontSize:nil forWidth:width lineBreakMode:config.lineBreakMode].height;
    } else {
        if (config.numberOfLines == 1) {
            return [self sizeWithFont:config.font forWidth:width lineBreakMode:config.lineBreakMode].height;
        } else {
            float h1 = [self sizeWithFont:config.font constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:config.lineBreakMode].height;
            if (config.numberOfLines == 0) {
                return h1;
            }
            float h2 = [self sizeWithFont:config.font].height * config.numberOfLines;
            return MIN(h1, h2);
        }
    }
    return 0;
}

@end
