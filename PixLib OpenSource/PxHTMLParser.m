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
//  PxHTMLParser.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxHTMLParser.h"
#import "PxCore.h"
#import "PxXMLHelper.h"

@interface PxTagData : NSObject {
@public
    NSRange range;
    int emphasis;
}
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSDictionary *attributes;
@property(nonatomic, assign) NSRange range;
@property(nonatomic, assign) int emphasis;
@end

@implementation PxTagData
@synthesize name, attributes, range, emphasis;

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p name:%@ attributes:%@ range:%@>", [self class], self, self.name, self.attributes, NSStringFromRange(range)];
}

- (void)setName:(NSString *)n {
    if (n != name) {
        name = n;
        if ([n isEqualToString:@"i"]) {
            emphasis = PxHTMLStyleItalic;
        }else if ([n isEqualToString:@"b"]) {
            emphasis = PxHTMLStyleBold;
        }else if ([n isEqualToString:@"a"]) {
            emphasis = PxHTMLStyleLink;
        }else {
            emphasis = PxHTMLStyleNone;
        }
    }
}

@end


@interface PxHTMLParser (hidden)
+ (void)addAttributes:(NSMutableAttributedString *)string styleBlock:(PxHTMLStyleBlock)block tags:(NSArray *)tags userInfos:(id)userInfos;
@end


#define CLEAN_STRING_BEFORE_RETURN free(buffer);

@implementation PxHTMLParser

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)input userInfos:(id)userInfos styleBlock:(PxHTMLStyleBlock)block {
    
    NSMutableArray *finishedTagStack = [[NSMutableArray alloc] init];
    NSMutableArray *tagStack = [[NSMutableArray alloc] init];
    
    unichar *buffer = malloc(sizeof(unichar)*[input length]);
    int bIndex = 0;
    
    unichar tagName[256];
    unichar attrName[256];
    unichar attrValue[2048];
    
    NSMutableDictionary *tagAttributes = nil;
    
    for (int i=0; i<[input length]; i++) { // handle tag
        unichar character = [input characterAtIndex:i];
        if (character == '<') {
            
            i++;            
            unichar c = [input characterAtIndex:i];
            if (c == '/') {
                PxTagData *lastTag = [tagStack lastObject];
                lastTag->range.length = (bIndex - lastTag.range.location);
                [finishedTagStack addObject:lastTag];
                [tagStack removeLastObject];
                c = [input characterAtIndex:i];
                while (c != '>') {
                    i++; c = [input characterAtIndex:i];
                }
            }else {
                int j=0;
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    tagName[j] = c;
                    i++; c = [input characterAtIndex:i];
                }
                
                if (c == ' ') {
                    i++; c = [input characterAtIndex:i];
                    while (c != '/' && c != '>' && c != '<') {
                        int j=0; // Skip whitespaces
                        for (; c == ' '; j++) {
                            i++; c = [input characterAtIndex:i];
                        }
                        
                        j=0;
                        for (; c != '='; j++) {
                            attrName[j] = c;
                            i++; c = [input characterAtIndex:i];
                        }
                        NSString *attr = [NSString stringWithCharacters:attrName length:j];
                        
                        // Skip starting Quote
                        i++;
                        if ([input characterAtIndex:i] != '"') {//syntax Error
                            PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: Missing Value", __FILE__, __LINE__);
                            CLEAN_STRING_BEFORE_RETURN
                            return nil;
                        }
                        i++;
                        
                        j=0;
                        c = [input characterAtIndex:i];
                        for (; c != '"'; j++) {
                            attrValue[j] = c;
                            i++; c = [input characterAtIndex:i];
                        }
                        
                        if (!tagAttributes) {
                            tagAttributes = [[NSMutableDictionary alloc] init];
                        }
                        
                        NSString *value = [NSString stringWithCharacters:attrValue length:j];
                        [tagAttributes setValue:PxXMLUnescape(value) forKey:attr];
                        
                        i++; c = [input characterAtIndex:i];
                    }
                }
                if (c == '/') {
                    if ([[[NSString alloc] initWithCharacters:tagName length:j] isEqual:@"br"]) {
                        buffer[bIndex++] = '\n';
                    }
                }else {
                    PxTagData *tag = [[PxTagData alloc] init];
                    [tag setName:[[NSString alloc] initWithCharacters:tagName length:j]];
                    [tag setAttributes:tagAttributes];
                    [tag setRange:NSMakeRange(bIndex, 0)];
                    
                    [tagStack addObject:tag];
                }
            }
        }else if (character == '>') { // end tag
        }else {
            buffer[bIndex++] = character;
        }
    }
    
    NSMutableAttributedString *retValue = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithCharacters:buffer length:bIndex] attributes:nil];
    if (block) {
        [self addAttributes:retValue styleBlock:block tags:finishedTagStack userInfos:userInfos];
    }
    
    free(buffer);
    return retValue;
}

+ (void)addAttributes:(NSMutableAttributedString *)string styleBlock:(PxHTMLStyleBlock)block tags:(NSArray *)tags userInfos:(id)userInfos {
    [tags inject:[NSMutableArray array] block:^id(NSMutableArray *memo, PxTagData *tag) {
        PxTagData *lastTag = [memo lastObject];
        while (lastTag) {
            if (lastTag->range.location+lastTag->range.length >= tag->range.location) {
                tag->emphasis = tag->emphasis | lastTag->emphasis;
                break;
            }else {
                [memo removeLastObject];
                lastTag = [memo lastObject];
            }
        }
        [memo addObject:tag];
        return memo;
    }];
    
    block(string, PxHTMLStyleNone, NSMakeRange(0, string.length), nil, nil, userInfos);
    
    [tags each:^(PxTagData *tag) {
        block(string, tag->emphasis, tag->range, tag.name, tag.attributes, userInfos);
    }];
}


@end
