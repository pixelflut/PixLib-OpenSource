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
//  PxCXMLParser.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxCXMLParser.h"
#import "PxCore.h"
#import "PxSupport.h"
#import "PxXMLHelper.h"


#define GETC_UNLOCKED_SAVE(__var__, __file__) if ((__var__ = getc_unlocked(__file__)) == (unsigned char)EOF){ PxError(@"CXML Syntax Error: Unexpected End Of File!");}

#define CLEAN_FILE_BEFORE_RETURN funlockfile(file);fclose(file);CFRelease(stack);CFRelease(parentStack);

#define CLEAN_STRING_BEFORE_RETURN free(bytes);CFRelease(stack);CFRelease(parentStack);

#define CLEAN_DATA_BEFORE_RETURN CFRelease(stack);CFRelease(parentStack);

static inline id startElement(NSString *tag, NSString *type, CFDictionaryRef mapping);
static inline id startAdvancedElement(NSString *tag, NSString *type, NSDictionary *attributes, id parent, CFDictionaryRef mapping);
static inline BOOL checkXML(unichar *buffer, int *position);
static inline BOOL checkXMLFile(FILE *file);
static inline void endTag(CFMutableArrayRef stack, CFMutableArrayRef parentStack, id *ret, NSString **nextTag, NSString **nextType, NSDictionary **nextAttributes, id *parent, id *current, CFDictionaryRef map);
static inline BOOL checkEndTag(CFMutableArrayRef stack, id *ret, id *current);
static inline void checkParent(CFMutableArrayRef stack, CFMutableArrayRef parentStack, id *parent, id *current);

static inline id startElement(NSString *tag, NSString *type, CFDictionaryRef mapping) {
    if ([type isEqualToString:@"array"]) {
        return [NSMutableArray array];
    } else if(mapping){
        Class klass = (__bridge Class)CFDictionaryGetValue(mapping, (__bridge const void*)tag);
        if (klass) {
            return [[klass alloc] init];
        }
    }
    return [NSMutableDictionary dictionary];
}

static inline id startAdvancedElement(NSString *tag, NSString *type, NSDictionary *attributes, id parent, CFDictionaryRef mapping) {
    if ([type isEqualToString:@"array"]) {
        return [NSMutableArray array];
    } else if(mapping){
        Class klass = (__bridge Class)CFDictionaryGetValue(mapping, (__bridge const void*)tag);
        if (klass) {
            
            if ([klass conformsToProtocol:NSProtocolFromString(@"PxXMLMapping")]) {
                return [klass objectForXMLAttributes:attributes parentObject:parent];
            }
            
            id element = [[klass alloc] init];
            [element setValuesForKeysWithDictionary:attributes];
            return element;
        }
    }
    return [NSMutableDictionary dictionaryWithDictionary:attributes];
}

static inline BOOL checkXML(unichar *buffer, int *position) {
    NSString *xmlHead   = XML_VERSION_HEAD;
    NSString *xmlHead2  = XML_VERSION_HEAD_2;
    int i = 0;
    for (; i<[xmlHead length]; i++) {
        if (buffer[i] != [xmlHead characterAtIndex:i] && buffer[i] != [xmlHead2 characterAtIndex:i]) {
            return NO;
        }
    }
    *position = i;
    return YES;
}

static inline BOOL checkXMLc(char *buffer, int *position) {
    NSString *xmlHead   = XML_VERSION_HEAD;
    NSString *xmlHead2  = XML_VERSION_HEAD_2;
    int i = 0;
    for (; i<[xmlHead length]; i++) {
        if (buffer[i] != [xmlHead characterAtIndex:i] && buffer[i] != [xmlHead2 characterAtIndex:i]) {
            return NO;
        }
    }
    *position = i;
    return YES;
}

static inline BOOL checkXMLFile(FILE *file) {
    NSString *xmlHead   = XML_VERSION_HEAD;
    NSString *xmlHead2  = XML_VERSION_HEAD_2;
    unichar c;
    for (int i = 0; i<[xmlHead length]; i++) {
        c = fgetc(file);
        if (c != [xmlHead characterAtIndex:i] && c != [xmlHead2 characterAtIndex:i]) {
            return NO;
        }
    }
    return YES;
}

static inline void endTag(CFMutableArrayRef stack, CFMutableArrayRef parentStack, id *ret, NSString **nextTag, NSString **nextType, NSDictionary **nextAttributes, id *parent, id *current, CFDictionaryRef map) {
    if (*nextTag) {
        id value = startAdvancedElement(*nextTag, *nextType, *nextAttributes, *parent, map);
        if (*current) {
            if ([*current isKindOfClass:[NSArray class]]) {
                [*current addObject:value];
            }else {
                [*current setValue:value forKey:*nextTag];
            }
            *current = value;
        }else {
            *current = value;
            *ret = *current;
        }
        if ([value conformsToProtocol:NSProtocolFromString(@"PxXMLMapping")]) {
            *parent = value;
            CFArrayAppendValue(parentStack, (__bridge const void*)value);
        }
        CFArrayAppendValue(stack, (__bridge const void*)value);
        *nextTag = nil;
        *nextType = nil;
        *nextAttributes = nil;
    }
}

static inline BOOL checkEndTag(CFMutableArrayRef stack, id *ret, id *current) {
    CFIndex count = CFArrayGetCount(stack);
    if (count==1) {
        return YES;
    }else if(count == 0){
        PxError(@"CXML Syntax Error durring Tag-Parsing: Empty tag?");
        *ret = nil;
        return YES;
    }else {
        CFArrayRemoveValueAtIndex(stack, count-1);
        *current = (__bridge id)CFArrayGetValueAtIndex(stack, count-2);
        return NO;
    }
}

static inline void checkParent(CFMutableArrayRef stack, CFMutableArrayRef parentStack, id *parent, id *current) {
    if (*current == *parent) {
        CFIndex parentCount = CFArrayGetCount(parentStack);
        if(parentCount >= 2) {
            *parent = (__bridge id)CFArrayGetValueAtIndex(parentStack, parentCount-2);
            CFArrayRemoveValueAtIndex(parentStack, parentCount-1);
        }else {
            parent = nil;
            CFArrayRemoveAllValues(parentStack);
        }
    }
}


#pragma mark - Implementation

@implementation PxCXMLParser

+ (id)parseFile:(NSString*)path mapping:(NSDictionary *)mapping {
    if (!path) {
        return nil;
    }
    
    FILE *file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (file == NULL) {
        return nil;
    }
    
    flockfile(file);
    
    if (file == NULL) {
        return nil;
    }
    
    CFMutableArrayRef stack = CFArrayCreateMutable(NULL, 128, NULL);
    id current = nil;

    CFMutableArrayRef parentStack = CFArrayCreateMutable(NULL, 128, NULL);
    id parent = nil;
    
    id ret = nil;
    CFDictionaryRef map = (__bridge CFDictionaryRef)mapping;
    
    unsigned char character;
    
    unsigned char type[] = {'t', 'y', 'p', 'e'};
        
    NSString *nextTag = nil;
    NSString *nextType = nil;
    NSMutableDictionary *nextAttributes = nil;
    
    if(!checkXMLFile(file)) {
        PxError(@"CXML Syntax Error durring XML-Check: Invalid XML-Header?");
        CLEAN_FILE_BEFORE_RETURN
        return nil;
    }
    
    while ( (character=getc_unlocked(file)) != (unsigned char)EOF) {
        
        if (character == '<') {// start or end an Object
            GETC_UNLOCKED_SAVE(character,file);
            
            if (character == '/') { // end an Object. Dont even care for correct syntax... only support valid xmls
                checkParent(stack, parentStack, &parent, &current);
                
                if (checkEndTag(stack, &ret, &current)) {
                    CLEAN_FILE_BEFORE_RETURN
                    return ret;
                }
                
                while ((character = getc_unlocked(file)) !='>' && character != (unsigned char)EOF) {} // file/buffer overflow!
                
            }else {// start an Object, get the tag-name first
                unsigned char c = character;
                int j=0;
                

                CFMutableDataRef tagName = CFDataCreateMutable(NULL, 0);
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    CFDataAppendBytes(tagName, &c, 1);
                    GETC_UNLOCKED_SAVE(c, file);
                }
                nextTag = [[NSString alloc] initWithBytes:CFDataGetBytePtr(tagName) length:j encoding:NSUTF8StringEncoding];
                CFRelease(tagName);
                
                // get type attribute. This MUST be the first attribute for performance issues
                {
                    fpos_t pos; 
                    fgetpos(file, &pos);
                    
                    j = 0;
                    BOOL t = YES;
                    
                    for (; j<4; j++) {
                        GETC_UNLOCKED_SAVE(c,file);
                        if (c != type[j]) {
                            t=NO;
                        }
                    }

                    if (t) {
                        // Skip starting Quote
                        fseek(file, 1, SEEK_CUR);
                        if (getc_unlocked(file) != '"') {//syntax Error
                            PxError(@"CXML Syntax Error durring Type-Parsing: Missing Value");
                            CLEAN_FILE_BEFORE_RETURN
                            return nil;
                        }
                        
                        int k=0;
                        GETC_UNLOCKED_SAVE(c, file);
                        
                        CFMutableDataRef attrValue = CFDataCreateMutable(NULL, 0);
                        for (; c != '"'; k++) {
                            CFDataAppendBytes(attrValue, &c, 1);
                            GETC_UNLOCKED_SAVE(c, file);
                        }
                        nextType = [[NSString alloc] initWithBytes:CFDataGetBytePtr(attrValue) length:k encoding:NSUTF8StringEncoding];
                        CFRelease(attrValue);

                    }
                    fsetpos(file, &pos);
                }
            }
        }else if(character == '/') {// end an Inline-Object.
            endTag(stack, parentStack, &ret, &nextTag, &nextType, &nextAttributes, &parent, &current, map);
            checkParent(stack, parentStack, &parent, &current);
            if (checkEndTag(stack, &ret, &current)) {
                CLEAN_FILE_BEFORE_RETURN
                return ret;
            }
        }else if(character == '>') {//tag ended
            endTag(stack, parentStack, &ret, &nextTag, &nextType, &nextAttributes, &parent, &current, map);
        }else if(character == ' ' || character == '\n' || character == '\t') {//whitespace consumed. Nothing to do right now
            
        }else {
            if (!nextTag) {
                PxError(@"CXML Syntax Error durring Attribute-Parsing: No Working Object");
                CLEAN_FILE_BEFORE_RETURN
                return nil;
            }
            
            int j=0;
            unsigned char c = character;
            
            CFMutableDataRef attrName = CFDataCreateMutable(NULL, 0);
            for (; c != '='; j++) {
                CFDataAppendBytes(attrName, &c, 1);
                GETC_UNLOCKED_SAVE(c, file);
            }
            
            NSString *attr = [[NSString alloc] initWithBytes:CFDataGetBytePtr(attrName) length:j encoding:NSUTF8StringEncoding];
            CFRelease(attrName);
            
            // Skip starting Quote

            if (getc_unlocked(file) != '"') {//syntax Error
                PxError(@"CXML Syntax Error durring Attribute-Parsing: Missing Value");
                CLEAN_FILE_BEFORE_RETURN
                return nil;
            }
            GETC_UNLOCKED_SAVE(c, file);
            
            j=0;
            
            
            CFMutableDataRef attrValue = CFDataCreateMutable(NULL, 0);
            for (; c != '"'; j++) {
                CFDataAppendBytes(attrValue, &c, 1);
                GETC_UNLOCKED_SAVE(c, file);
            }
            
            if (!nextAttributes) {
                nextAttributes = [[NSMutableDictionary alloc] init];
            }
            
            NSString *value = [[NSString alloc] initWithBytes:CFDataGetBytePtr(attrValue) length:j encoding:NSUTF8StringEncoding];
            [nextAttributes setValue:PxXMLUnescape(value) forKey:attr];// could be impreved with char-array
            CFRelease(attrValue);
        }
    }
    
    CLEAN_FILE_BEFORE_RETURN
    return ret;
}

+ (id)parseData:(NSData*)data mapping:(NSDictionary*)mapping {
    if (!data) {
        return nil;
    }
    
    CFMutableArrayRef stack = CFArrayCreateMutable(NULL, 128, NULL);
    id current = nil;
    
    CFMutableArrayRef parentStack = CFArrayCreateMutable(NULL, 128, NULL);
    id parent = nil;
    
    id ret = nil;
    CFDictionaryRef map = (__bridge CFDictionaryRef)mapping;
    
    unsigned char character;
    
    NSUInteger length = [data length];
    char *bytes = (char *)[data bytes];
    char type[] = {'t', 'y', 'p', 'e'};
    
    NSString *nextTag = nil;
    NSString *nextType = nil;
    NSMutableDictionary *nextAttributes = nil;
    
    int i = 0;
    if(!checkXMLc(bytes, &i)) {
        PxError(@"CXML Syntax Error durring XML-Check: Invalid XML-Header?");
        CLEAN_DATA_BEFORE_RETURN
        return nil;
    }
    
    for (; i<length; i++) {
        character = bytes[i];
        if (character == '<') {// start or end an Object
            i++;
            
            if (bytes[i] == '/') { // end an Object. Dont even care for correct syntax... only support valid xmls
                
                checkParent(stack, parentStack, &parent, &current);
                if (checkEndTag(stack, &ret, &current)) {
                    CLEAN_DATA_BEFORE_RETURN
                    return ret;
                }

                for(;bytes[i] != '>';i++) {}
            }else {// start an Object, get the tag-name first
                if (nextTag) {
                    PxError(@"CXML Syntax Error durring Tag-Parsing: New tag inside existing tag?");
                    CLEAN_DATA_BEFORE_RETURN
                    return nil;
                }
                
                unsigned char c = bytes[i];
                int j=0;
                
                CFMutableDataRef tagName = CFDataCreateMutable(NULL, 0);
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    CFDataAppendBytes(tagName, &c, 1);
                    i++; c = bytes[i];
                }
                
                nextTag = [[NSString alloc] initWithBytes:CFDataGetBytePtr(tagName) length:j encoding:NSUTF8StringEncoding];
                CFRelease(tagName);
                
                // get type attribute. This MUST be the first attribute for performance issues
                {
                    j = 0;
                    BOOL t = YES;
                    
                    for (; j<4; j++) {
                        if (bytes[i+1+j] != type[j]) {
                            t=NO;
                        }
                    }
                    if (t) {
                        // Skip starting Quote
                        j++;
                        if (bytes[i+1+j] != '"') {//syntax Error
                            PxError(@"CXML Syntax Error durring Type-Parsing: Missing Value");
                            CLEAN_DATA_BEFORE_RETURN
                            return nil;
                        }
                        j++;
                        
                        int k=0;
                        
                        CFMutableDataRef attrValue = CFDataCreateMutable(NULL, 0);
                        for (; bytes[i+1+j+k] != '"'; k++) {
                            unsigned char c = bytes[i+1+j+k];
                            CFDataAppendBytes(attrValue, &c, 0);
                        }
                        nextType = [[NSString alloc] initWithBytes:CFDataGetBytePtr(attrValue) length:k encoding:NSUTF8StringEncoding]; // Improvement: Dont use NSString
                        CFRelease(attrValue);
                    }
                }
            }
        }else if(character == '/') {// end an Inline-Object.
            endTag(stack, parentStack, &ret, &nextTag, &nextType, &nextAttributes, &parent, &current, map);
            checkParent(stack, parentStack, &parent, &current);
            if (checkEndTag(stack, &ret, &current)) {
                CLEAN_DATA_BEFORE_RETURN
                return ret;
            }
        }else if(character == '>') {//tag ended
            endTag(stack, parentStack, &ret, &nextTag, &nextType, &nextAttributes, &parent, &current, map);
        }else if(character == ' ' || character == '\n' || character == '\t'){ //whitespace consumed. Nothing to do right now
            
        }else {
            if (!nextTag) {
                PxError(@"CXML Syntax Error durring Attribute-Parsing: No Working Object");
                CLEAN_DATA_BEFORE_RETURN
                return nil;
            }
            
            int j=0;
            
            CFMutableDataRef attrName = CFDataCreateMutable(NULL, 0);
            for (; bytes[i] != '='; j++, i++) {
                unsigned char c = bytes[i];
                CFDataAppendBytes(attrName, &c, 0);
            }
            
            NSString *attr = [[NSString alloc] initWithBytes:CFDataGetBytePtr(attrName) length:j encoding:NSUTF8StringEncoding];
            CFRelease(attrName);
            
            // Skip starting Quote
            i++;
            if (bytes[i] != '"') {//syntax Error
                PxError(@"CXML Syntax Error durring Attribute-Parsing: Missing Value");
                CLEAN_DATA_BEFORE_RETURN
                return nil;
            }
            i++;
            
            j=0;
            
            CFMutableDataRef attrValue = CFDataCreateMutable(NULL, 0);
            for (; bytes[i] != '"'; j++, i++) {
                unsigned char c = bytes[i];
                CFDataAppendBytes(attrValue, &c, 0);
            }
            
            if (!nextAttributes) {
                nextAttributes = [[NSMutableDictionary alloc] init];
            }
            
            NSString *value = [[NSString alloc] initWithBytes:CFDataGetBytePtr(attrValue) length:j encoding:NSUTF8StringEncoding];
            [nextAttributes setValue:PxXMLUnescape(value) forKey:attr];
            CFRelease(attrValue);
        }
    }
    CLEAN_DATA_BEFORE_RETURN
    return ret;
}

+ (id)parseString:(NSString*)data mapping:(NSDictionary*)mapping {    
    if (!data) {
        return nil;
    }
    
    CFMutableArrayRef stack = CFArrayCreateMutable(NULL, 128, NULL);
    id current = nil;
    
    CFMutableArrayRef parentStack = CFArrayCreateMutable(NULL, 128, NULL);
    id parent = nil;
    
    id ret = nil;
    CFDictionaryRef map = (__bridge CFDictionaryRef)mapping;
    
    NSUInteger length = [data length];
    
    unichar *bytes = (unichar *)malloc(data.length*sizeof(unichar));
    [data getCharacters:bytes range:NSMakeRange(0, data.length)];
    unichar character;
    
    char type[] = {'t', 'y', 'p', 'e'};
    
    NSString *nextTag = nil;
    NSString *nextType = nil;
    NSMutableDictionary *nextAttributes = nil;
    
    int i = 0;
    if(!checkXML(bytes, &i)) {
        PxError(@"CXML Syntax Error durring XML-Check: Invalid XML-Header?");
        CLEAN_STRING_BEFORE_RETURN
        return nil;
    }
    
    for (; i<length; i++) {
        character = bytes[i];
        if (character == '<') {// start or end an Object
            i++;
            
            if (bytes[i] == '/') { // end an Object. Dont even care for correct syntax... only support valid xmls
                checkParent(stack, parentStack, &parent, &current);
                if (checkEndTag(stack, &ret, &current)) {
                    CLEAN_STRING_BEFORE_RETURN
                    return ret;
                }
                for(;bytes[i] != '>';i++) {}
            }else {// start an Object, get the tag-name first
                if (nextTag) {
                    PxError(@"CXML Syntax Error durring Tag-Parsing: New tag inside existing tag?");
                    CLEAN_STRING_BEFORE_RETURN
                    return nil;
                }
                
                unichar c = bytes[i];
                int j=0;
                                
                CFMutableStringRef tagName = CFStringCreateMutable(NULL, 0);
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    CFStringAppendCharacters(tagName, &c, 1);
                    i++; c = bytes[i];
                }
                nextTag = CFBridgingRelease(tagName);
                
                // get type attribute. This MUST be the first attribute for performance issues
                {
                    j = 0;
                    BOOL t = YES;
                    
                    for (; j<4; j++) {
                        if (bytes[i+1+j] != type[j]) {
                            t=NO;
                        }
                    }
                    if (t) {
                        // Skip starting Quote
                        j++;
                        if (bytes[i+1+j] != '"') {//syntax Error
                            PxError(@"CXML Syntax Error durring Type-Parsing: Missing Value");
                            CLEAN_STRING_BEFORE_RETURN
                            return nil;
                        }
                        j++;
                        
                        int k=0;
                        
                        CFMutableStringRef attrValue = CFStringCreateMutable(NULL, 0);
                        for (; bytes[i+1+j+k] != '"'; k++) {
                            CFStringAppendCharacters(attrValue, &bytes[i+1+j+k], 1);
                        }
                        nextType = CFBridgingRelease(attrValue);
                    }
                }
            }
        }else if(character == '/') {// end an Inline-Object.
            endTag(stack, parentStack, &ret, &nextTag, &nextType, &nextAttributes, &parent, &current, map);
            checkParent(stack, parentStack, &parent, &current);
            if (checkEndTag(stack, &ret, &current)) {
                CLEAN_STRING_BEFORE_RETURN
                return ret;
            }
        }else if(character == '>') {//tag ended
            endTag(stack, parentStack, &ret, &nextTag, &nextType, &nextAttributes, &parent, &current, map);
        }else if(character == ' ' || character == '\n' || character == '\t'){ //whitespace consumed. Nothing to do right now
            
        }else {
            if (!nextTag) {
                PxError(@"CXML Syntax Error durring Attribute-Parsing: No Working Object");
                CLEAN_STRING_BEFORE_RETURN
                return nil;
            }
            
            int j=0;
            CFMutableStringRef attrName = CFStringCreateMutable(NULL, 0);
            
            for (; bytes[i] != '='; j++, i++) {
                CFStringAppendCharacters(attrName, &bytes[i], 1);
            }
            
            NSString *attr = CFBridgingRelease(attrName);
            
            // Skip starting Quote
            i++;
            if (bytes[i] != '"') {//syntax Error
                PxError(@"CXML Syntax Error durring Attribute-Parsing: Missing Value");
                CLEAN_STRING_BEFORE_RETURN
                return nil;
            }
            i++;
            
            j=0;
            CFMutableStringRef attrValue = CFStringCreateMutable(NULL, 0);
            
            for (; bytes[i] != '"'; j++, i++) {
                CFStringAppendCharacters(attrValue, &bytes[i], 1);
            }
            
            if (!nextAttributes) {
                nextAttributes = [[NSMutableDictionary alloc] init];
            }
            
            NSString *value = CFBridgingRelease(attrValue);
            [nextAttributes setValue:PxXMLUnescape(value) forKey:attr];
        }
    }
    CLEAN_STRING_BEFORE_RETURN
    return ret;
}

@end
