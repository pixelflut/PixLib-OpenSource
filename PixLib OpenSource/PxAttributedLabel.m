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
//  PxAttributedLabel.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxAttributedLabel.h"
#import "PxCore.h"

@interface PxAttributedLabel ()
@property (nonatomic, assign) CGSize frameSize;
- (void)parseText;

- (CGPathRef)currentDrawArea;
- (void)clearCustomDrawArea;
- (void)setCustomDrawArea:(CGPathRef)path;
- (void)clearDrawArea;
- (void)setDrawArea:(CGPathRef)path;
- (void)setDefaultDrawArea:(int)w;

@end

@implementation PxAttributedLabel
@synthesize text                = _text;
@synthesize attributedString    = _attributedString;
@synthesize needsParsing        = _needsParsing;
@synthesize linkDelegate        = _linkDelegate;

@synthesize font                = _font;
@synthesize boldFont            = _boldFont;
@synthesize italicFont          = _italicFont;
@synthesize italicBoldFont      = _italicBoldFont;
@synthesize linkFont            = _linkFont;

@synthesize textColor           = _textColor;
@synthesize boldTextColor       = _boldTextColor;
@synthesize italicTextColor     = _italicTextColor;
@synthesize italicBoldTextColor = _italicBoldTextColor;
@synthesize linkTextColor       = _linkTextColor;

@synthesize textAlignment       = _textAlignment;
@synthesize shadowOffset        = _shadowOffset;
@synthesize shadowColor         = _shadowColor;
@synthesize lineSpacing         = _lineSpacing;
@synthesize styleBlock          = _styleBlock;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (text != _text) {
        _text = text;
        [self setNeedsParsing];
    }
}

#pragma mark - Style Properties

#pragma mark Font
- (void)setFont:(UIFont *)font {
    if (font != _font) {
        _font = font;
        [self setNeedsParsing];
    }
}

- (void)setBoldFont:(UIFont *)boldFont {
    if (boldFont != _boldFont) {
        _boldFont = boldFont;
        [self setNeedsParsing];
    }
}

- (void)setItalicFont:(UIFont *)italicFont {
    if (italicFont != _italicFont) {
        _italicFont = italicFont;
        [self setNeedsParsing];
    }
}

- (void)setItalicBoldFont:(UIFont *)italicBoldFont {
    if (italicBoldFont != _italicBoldFont) {
        _italicBoldFont = italicBoldFont;
        [self setNeedsParsing];
    }
}

- (void)setLinkFont:(UIFont *)linkFont {
    if (linkFont != _linkFont) {
        _linkFont = linkFont;
        [self setNeedsParsing];
    }
}

#pragma mark Color
- (void)setTextColor:(UIColor *)textColor {
    if (textColor != _textColor) {
        _textColor = textColor;
        [self setNeedsParsing];
    }
}

- (void)setBoldTextColor:(UIColor *)boldTextColor {
    if (boldTextColor != _boldTextColor) {
        _boldTextColor = boldTextColor;
        [self setNeedsParsing];
    }
}

- (void)setItalicTextColor:(UIColor *)italicTextColor {
    if (italicTextColor != _italicTextColor) {
        _italicTextColor = italicTextColor;
        [self setNeedsParsing];
    }
}

- (void)setItalicBoldTextColor:(UIColor *)italicBoldTextColor {
    if (italicBoldTextColor != _italicBoldTextColor) {
        _italicBoldTextColor = italicBoldTextColor;
        [self setNeedsParsing];
    }
}

- (void)setLinkTextColor:(UIColor *)linkTextColor {
    if (linkTextColor != _linkTextColor) {
        _linkTextColor = linkTextColor;
        [self setNeedsParsing];
    }
}

#pragma mark Additional
- (void)setTextAlignment:(CTTextAlignment)textAlignment {
    if (textAlignment != _textAlignment) {
        _textAlignment = textAlignment;
        [self setNeedsParsing];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (shadowColor != _shadowColor) {
        _shadowColor = shadowColor;
        [self setNeedsDisplay];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if (lineSpacing != _lineSpacing) {
        _lineSpacing = lineSpacing;
        [self setNeedsParsing];
    }
}

- (void)setLineHeight:(CGFloat)lineHeight {
    if (lineHeight != _lineHeight) {
        _lineHeight = lineHeight;
        [self setNeedsParsing];
    }
}

- (void)setStyleBlock:(PxHTMLStyleBlock)styleBlock {
    if (styleBlock != _styleBlock) {
        _styleBlock = styleBlock;
        [self setNeedsParsing];
    }
}

#pragma mark - Drawing

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(_frameSize, self.frame.size)) {
        _frameSize = self.frame.size;
        [self clearDrawArea];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [self parseText];
    if (_attributedString) {
        _lines = nil;
        CGPathRef path = [self currentDrawArea];
        
        if (path == NULL) {
            [self setDefaultDrawArea:self.frame.size.width];
            path = [self currentDrawArea];
        }
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetShadowWithColor(c, [self shadowOffset], 3, [[self shadowColor] CGColor]);
        
        _lines = [_attributedString drawInPath:path returnLines:_linkDelegate!=nil];
    }
}

#pragma mark - DrawArea

- (CGPathRef)currentDrawArea {
    if (_customDrawArea) {
        return _customDrawArea;
    }else {
        return _drawArea;
    }
}

- (void)clearCustomDrawArea {
    if (_customDrawArea) {
        CGPathRelease(_customDrawArea);
        _customDrawArea = NULL;
    }
}

- (void)setCustomDrawArea:(CGPathRef)path {
    if (path != _customDrawArea) {
        if (_customDrawArea != NULL) {
            CGPathRelease(_customDrawArea);
        }
        
        _customDrawArea = CGPathRetain(path);
        [self setNeedsDisplay];
    }
}

- (void)clearDrawArea {
    if (_drawArea) {
        CGPathRelease(_drawArea);
        _drawArea = NULL;
    }
}

- (void)setDrawArea:(CGPathRef)path {
    if (path != _drawArea) {
        if (_drawArea != NULL) {
            CGPathRelease(_drawArea);
        }
        
        _drawArea = CGPathRetain(path);
        [self setNeedsDisplay];
    }
}

- (void)setDefaultDrawArea:(int)w {
    [self parseText];
    int h = 99999;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, w, h));
    
    [self setDrawArea:path];
    CGPathRelease(path);
}

#pragma mark - Size
- (int)heightForWidth:(int)w {
	CGPathRef path = NULL;
    if (_customDrawArea) {
        path = CGPathRetain([self currentDrawArea]);
    }
    
    if (path == NULL) {
        [self setDefaultDrawArea:w];
        path = CGPathRetain([self currentDrawArea]);
    }else {
        [self parseText];
    }
    
    int h = [[self attributedString] heightForPath:path];
    CGPathRelease(path);
	
	return h;
}

- (CGFloat)setHeightForWidth:(CGFloat)w {
    float h = [self heightForWidth:w];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, w, h)];
    [self setNeedsDisplay];
    return h;
}

- (CGFloat)setHeightToFit {
    return [self setHeightForWidth:self.frame.size.width];
}

#pragma mark - Parsing
- (void)setNeedsParsing {
    if( !_needsParsing && [_text isNotBlank]) {
        _needsParsing = YES;
        [[NSRunLoop currentRunLoop] performSelector:@selector(parseText) target:self argument:nil order:0 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
}

- (void)parseText {
    if (_needsParsing && [_text isNotBlank]) {
        [self clearDrawArea];
        
        if (_styleBlock) {
            _attributedString = [PxHTMLParser attributedStringWithString:_text userInfos:self styleBlock:_styleBlock];
        }else {
            _attributedString = [PxHTMLParser attributedStringWithString:_text userInfos:self styleBlock:^(NSMutableAttributedString *string, int activeStyles, NSRange range, NSString *tagname, NSDictionary *tagAttributes, id userInfos) {
                if (activeStyles == PxHTMLStyleNone) {
                    if (self.font) {
                        [string setFontWithUIFont:self.font];
                    }
                    if (self.textColor) {
                        [string setTextColor:[self.textColor CGColor]];
                    }
                    
                    [string setParagraphStyle:^(PxParagraphStyleOptions *options) {
                        options->alignment = self.textAlignment;
                        options->lineHeight = self.lineHeight;
                        options->lineSpacing = self.lineSpacing;
                    }];
                    
                }else {
                    if (activeStyles & PxHTMLStyleLink) {
                        [string addAttribute:@"link" value:tagAttributes range:range];
                        if (self.linkTextColor) {
                            [string setTextColor:[self.linkTextColor CGColor] range:range];
                        }
                        if (self.linkFont) {
                            [string setFontWithUIFont:self.linkFont range:range];
                        }
                    }else if (activeStyles & PxHTMLStyleBold && !(activeStyles & PxHTMLStyleItalic)) {
                        if (self.boldTextColor) {
                            [string setTextColor:[self.boldTextColor CGColor] range:range];
                        }
                        if (self.boldFont) {
                            [string setFontWithUIFont:self.boldFont range:range];
                        }
                    }else if (activeStyles & PxHTMLStyleItalic && !(activeStyles & PxHTMLStyleBold)) {
                        if (self.italicTextColor) {
                            [string setTextColor:[self.italicTextColor CGColor] range:range];
                        }
                        if (self.italicFont) {
                            [string setFontWithUIFont:self.italicFont range:range];
                        }
                    }else {
                        if (self.italicBoldTextColor) {
                            [string setTextColor:[self.italicBoldTextColor CGColor] range:range];
                        }
                        if (self.italicBoldFont) {
                            [string setFontWithUIFont:self.italicBoldFont range:range];
                        }
                    }
                }
            }];
        }

        _needsParsing = NO;
        [self setNeedsDisplay];
    }
}

#pragma mark - Link Handle

- (void)setLinkDelegate:(id<PxAttributedLabelLinkDelegate>)linkDelegate {
    if (linkDelegate) {
        if (!_linkRecognizer) {
            _linkRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [self addGestureRecognizer:_linkRecognizer];
            [self setNeedsParsing];
        }
    }else {
        if (_linkRecognizer) {
            [self removeGestureRecognizer:_linkRecognizer];
            _linkRecognizer = nil;
        }
    }
    _linkDelegate = linkDelegate;
}

- (void)tapGesture:(UITapGestureRecognizer*)gest {
    CGPoint point = [gest locationInView:self];
    __block CGPoint translatedPoint = point;
    
    [_lines each:^(PxPair *linePair) {
        CGRect lineRect = [(NSValue*)[linePair second] CGRectValue];
        CGRect tmp = lineRect;
        lineRect.origin.y = self.frame.size.height - (lineRect.origin.y+lineRect.size.height);
        
        CGRect clickRect = CGRectMake(lineRect.origin.x-10, lineRect.origin.y-20, lineRect.size.width+20, lineRect.size.height+40);
        
        if (CGRectContainsPoint(clickRect, point)) {
            translatedPoint.y = tmp.origin.y+2;
            translatedPoint.x = translatedPoint.x - lineRect.origin.x;
            
            CTLineRef line = (__bridge CTLineRef)linePair.first;
            
            CFIndex index = CTLineGetStringIndexForPosition(line, translatedPoint);
            
            if (index !=  kCFNotFound && index < [_attributedString length]) {
                id ret = [_attributedString attribute:@"link" atIndex:index effectiveRange:NULL];
                if (ret) {
                    [_linkDelegate attributedLabel:self didClickLink:ret];
                    return;
                }
            }
        }
    }];
}


#pragma mark - Memory managment
- (void)dealloc {
    [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
    [self clearDrawArea];
    [self clearCustomDrawArea];
}

@end
