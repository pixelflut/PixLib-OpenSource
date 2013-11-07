/*
 * Copyright (c) 2013 pixelflut GmbH, http://pixelflut.net
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 */

//
//  NSAttributedString+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSAttributedString+PixLib.h"
#import "PxCore.h"
#import <CoreText/CoreText.h>

@interface NSAttributedString (hidden)

- (CTFrameRef)cfframeForPath:(CGPathRef)p;

@end

@implementation NSAttributedString (PixLib)

- (BOOL)isNotBlank {
    return [self length] > 0;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, width, 99999));
    CGFloat h = [self heightForPath:path];
    CGPathRelease(path);
    return h;
}

- (CGFloat)heightForPath:(CGPathRef)path {
    CGFloat height = 0;
    CTFrameRef frame =  [self cfframeForPath:path];
    if (frame != NULL) {
        NSArray* lines = (__bridge NSArray*)CTFrameGetLines(frame);
        
        NSUInteger l = [lines count];
        if (l > 1) {
            CGPoint origins[l];
            
            CTFrameGetLineOrigins(frame, CFRangeMake(0, l), origins);
            
            CGFloat yFirst = origins[0].y;
            CGFloat yLast = origins[l-1].y;
            
            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds((__bridge CTLineRef)[lines objectAtIndex:l-1], &ascent, &descent, &leading);
            
            height = ceilf((ascent+descent+leading)*1.3) + yFirst-yLast;
        } else {
            if (l==1) {
                CGFloat ascent, descent, leading;
                CTLineGetTypographicBounds((__bridge CTLineRef)[lines objectAtIndex:0], &ascent, &descent, &leading);
                height = ceilf(ascent+descent+leading)*1.3;
            }
        }
        CFRelease(frame);
    }
    return height;
}

// returns LineRects
- (NSArray *)drawInPath:(CGPathRef)path returnLines:(BOOL)storeLines {
    CGRect rect = CGPathGetBoundingBox(path);
    
    NSArray *_lines = nil;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(c);
    CTFrameRef frame =  [self cfframeForPath:path];
    
    CGContextTranslateCTM( c, rect.origin.x, rect.origin.y );
    CGContextScaleCTM( c, 1.0f, -1.0f );
    CGContextTranslateCTM( c, rect.origin.x, - ( rect.origin.y + rect.size.height ));
    
//    CTFrameDraw(frame, c);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    for (int i=0; i<CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGPoint origin;
        CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin);
        CGContextSetTextPosition(c, (int)origin.x, (int)origin.y);

        //handle text hyphenation
        CFRange cfStringRange = CTLineGetStringRange(line);
        NSRange stringRange = NSMakeRange(cfStringRange.location, cfStringRange.length);
        static const unichar softHypen = 0x00AD;
        unichar lastChar = [self.string characterAtIndex:stringRange.location + stringRange.length-1];
        
        if(softHypen == lastChar) {
            NSMutableAttributedString* lineAttrString = [[self attributedSubstringFromRange:stringRange] mutableCopy];
            NSRange replaceRange = NSMakeRange(stringRange.length-1, 1);
            [lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];

            // TODO: Use width of the path at this position instead!
            CGRect bounds = CTLineGetImageBounds(line, c);
            CTLineRef hyphenLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)lineAttrString);
            CTLineRef justifiedLine = CTLineCreateJustifiedLine(hyphenLine, 1.0, bounds.size.width);
            
            CTLineDraw(justifiedLine, c);
            CFRelease(justifiedLine);
            CFRelease(hyphenLine);
        } else {
            CTLineDraw(line, c);
        }
    }
    
    // TODO: Maybe support precalculated link boundaries
    if (storeLines) {
        CGRect contextBounds = CGContextGetClipBoundingBox(c);
        _lines = [(__bridge NSArray*)lines collectWithIndex:^id(id obj, unsigned int index) {
            CGPoint origin;
            CTFrameGetLineOrigins(frame, CFRangeMake(index, 1), &origin);
            CGRect bounds = CTLineGetImageBounds((__bridge CTLineRef)obj, c);
            bounds.origin.x = origin.x;
            bounds.origin.y = origin.y - contextBounds.origin.y;
            return [PxPair pairWithFirst:obj second:[NSValue valueWithCGRect:bounds]];
        }];
    }
    
    CFRelease(frame);
    CGContextRestoreGState(c);
    
    return _lines;
}

#pragma mark - Private

- (CTFrameRef)cfframeForPath:(CGPathRef)p {
    // hack to avoid bugs width different behavior in iOS <4.3 and >4.3
	CGMutablePathRef path = CGPathCreateMutable();
    CGRect r = CGPathGetBoundingBox(p);
    
    CGAffineTransform t = CGAffineTransformIdentity;

    t = CGAffineTransformTranslate(t, r.origin.x, r.origin.y);
    t = CGAffineTransformScale(t, 1, -1);
    t = CGAffineTransformTranslate(t, r.origin.x, - ( r.origin.y + r.size.height ));
    CGPathAddPath(path, &t, p);
    
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathCloseSubpath(path);
    // hack end
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	
	CFRelease(framesetter);
    CGPathRelease(path);
	return frame;
}

@end
