//
//  NSString+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "NSString+PxUIKit.h"

@implementation NSString (PxUIKit)

- (CGFloat)heightForWidth:(CGFloat)width config:(PxFontConfig)config {
    CGSize size = CGSizeMake(width, INT_MAX);
    CGFloat height;
    CGFloat multiLineHeight;
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (config.font) {
        fontAttributes[NSFontAttributeName] = config.font;
    }
    
    if (config.lineBreakMode) {
        paragraph.lineBreakMode = config.lineBreakMode;
        
        fontAttributes[NSParagraphStyleAttributeName] = paragraph;
    }
    
    if (config.adjustsFontSizeToFitWidth) {
        context.minimumScaleFactor = config.minimumScaleFactor;
    }
    
    height = [self boundingRectWithSize:size options:0 attributes:fontAttributes context:context].size.height;
    
    if (config.numberOfLines != 1) {
        if (
            paragraph.lineBreakMode == NSLineBreakByTruncatingHead ||
            paragraph.lineBreakMode == NSLineBreakByTruncatingMiddle ||
            paragraph.lineBreakMode == NSLineBreakByTruncatingTail
            ) {
            paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        }
        
        multiLineHeight = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:context].size.height;
        
        if (config.numberOfLines == 0) {
            height = multiLineHeight;
        } else {
            height *= config.numberOfLines;
        }
        
        height = MIN(height, multiLineHeight);
    }
    
    return height;
}

@end
