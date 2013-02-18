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

#define GETC_UNLOCKED_SAVE(__var__, __file__) if ((__var__ = getc_unlocked(__file__)) == EOF){ PxError(@"%s (Line %d)\nCXML Syntax Error: Unexpected End Of File!", __FILE__, __LINE__);} 

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
    int count = CFArrayGetCount(stack);
    if (count==1) {
        return YES;
    }else if(count == 0){
        PxError(@"%s (Line %d)\nCXML Syntax Error durring Tag-Parsing: Empty tag?", __FILE__, __LINE__);
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
        int parentCount = CFArrayGetCount(parentStack);
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
    
    char type[] = {'t', 'y', 'p', 'e'};
    char tagName[256];
    char attrName[256];
    char attrValue[2048];
    
    NSString *nextTag = nil;
    NSString *nextType = nil;
    NSMutableDictionary *nextAttributes = nil;
    
    if(!checkXMLFile(file)) {
        PxError(@"%s (Line %d)\nCXML Syntax Error durring XML-Check: Invalid XML-Header?", __FILE__, __LINE__);
        CLEAN_FILE_BEFORE_RETURN
        return nil;
    }
    
    while ( (character=getc_unlocked(file)) != EOF) {
        
        if (character == '<') {// start or end an Object
            GETC_UNLOCKED_SAVE(character,file);
            
            if (character == '/') { // end an Object. Dont even care for correct syntax... only support valid xmls
                checkParent(stack, parentStack, &parent, &current);
                
                if (checkEndTag(stack, &ret, &current)) {
                    CLEAN_FILE_BEFORE_RETURN
                    return ret;
                }
                
                while ((character = getc_unlocked(file)) !='>' && character != EOF) {} // file/buffer overflow!
                
            }else {// start an Object, get the tag-name first
                unichar c = character;
                int j=0;
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    tagName[j] = c;
                    GETC_UNLOCKED_SAVE(c, file);
                }
                
                nextTag = [[NSString alloc] initWithBytes:tagName length:j encoding:NSUTF8StringEncoding];
                
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
                            PxError(@"%s (Line %d)\nCXML Syntax Error durring Type-Parsing: Missing Value", __FILE__, __LINE__);
                            CLEAN_FILE_BEFORE_RETURN
                            return nil;
                        }
                        
                        int k=0;
                        GETC_UNLOCKED_SAVE(c, file);
                        for (; c != '"'; k++) {
                            attrValue[k] = c;
                            GETC_UNLOCKED_SAVE(c, file);
                        }
                        nextType = [[NSString alloc] initWithBytes:attrValue length:k encoding:NSUTF8StringEncoding];
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
                PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: No Working Object", __FILE__, __LINE__);
                CLEAN_FILE_BEFORE_RETURN
                return nil;
            }
            
            int j=0;
            unichar c = character;
            for (; c != '='; j++) {
                attrName[j] = c;
                GETC_UNLOCKED_SAVE(c, file);
            }
            
            NSString *attr = [[NSString alloc] initWithBytes:attrName length:j encoding:NSUTF8StringEncoding];
            
            // Skip starting Quote

            if (getc_unlocked(file) != '"') {//syntax Error
                PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: Missing Value", __FILE__, __LINE__);
                CLEAN_FILE_BEFORE_RETURN
                return nil;
            }
            GETC_UNLOCKED_SAVE(c, file);
            
            j=0;
            for (; c != '"'; j++) {
                attrValue[j] = c;
                GETC_UNLOCKED_SAVE(c, file);
            }
            
            if (!nextAttributes) {
                nextAttributes = [[NSMutableDictionary alloc] init];
            }
            
            NSString *value = [[NSString alloc] initWithBytes:attrValue length:j encoding:NSUTF8StringEncoding];
            [nextAttributes setValue:PxXMLUnescape(value) forKey:attr];// could be impreved with char-array
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
    
    int length = [data length];
    char *bytes = (char *)[data bytes];
    char type[] = {'t', 'y', 'p', 'e'};
    char tagName[256];
    char attrName[256];
    char attrValue[2048];
    
    NSString *nextTag = nil;
    NSString *nextType = nil;
    NSMutableDictionary *nextAttributes = nil;
    
    int i = 0;
    if(!checkXMLc(bytes, &i)) {
        PxError(@"%s (Line %d)\nCXML Syntax Error durring XML-Check: Invalid XML-Header?", __FILE__, __LINE__);
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
                    PxError(@"%s (Line %d)\nCXML Syntax Error durring Tag-Parsing: New tag inside existing tag?", __FILE__, __LINE__);
                    CLEAN_DATA_BEFORE_RETURN
                    return nil;
                }
                
                unichar c = bytes[i];
                int j=0;
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    tagName[j] = c;
                    i++; c = bytes[i];
                }
                
                nextTag = [[NSString alloc] initWithBytes:tagName length:j encoding:NSUTF8StringEncoding];
                
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
                            PxError(@"%s (Line %d)\nCXML Syntax Error durring Type-Parsing: Missing Value", __FILE__, __LINE__);
                            CLEAN_DATA_BEFORE_RETURN
                            return nil;
                        }
                        j++;
                        
                        int k=0;
                        for (; bytes[i+1+j+k] != '"'; k++) {
                            attrValue[k] = bytes[i+1+j+k];
                        }
                        nextType = [[NSString alloc] initWithBytes:attrValue length:k encoding:NSUTF8StringEncoding]; // Improvement: Dont use NSString
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
                PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: No Working Object", __FILE__, __LINE__);
                CLEAN_DATA_BEFORE_RETURN
                return nil;
            }
            
            int j=0;
            for (; bytes[i] != '='; j++, i++) {
                attrName[j] = bytes[i];
            }
            
            NSString *attr = [[NSString alloc] initWithBytes:attrName length:j encoding:NSUTF8StringEncoding];
            
            // Skip starting Quote
            i++;
            if (bytes[i] != '"') {//syntax Error
                PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: Missing Value", __FILE__, __LINE__);
                CLEAN_DATA_BEFORE_RETURN
                return nil;
            }
            i++;
            
            j=0;
            for (; bytes[i] != '"'; j++, i++) {
                attrValue[j] = bytes[i];
            }
            
            if (!nextAttributes) {
                nextAttributes = [[NSMutableDictionary alloc] init];
            }
            
            NSString *value = [[NSString alloc] initWithBytes:attrValue length:j encoding:NSUTF8StringEncoding];
            [nextAttributes setValue:PxXMLUnescape(value) forKey:attr];
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
    
    int length = [data length];
    
    unichar *bytes = malloc(data.length*sizeof(unichar));
    [data getCharacters:bytes range:NSMakeRange(0, data.length)];
    unichar character;
    
    char type[] = {'t', 'y', 'p', 'e'};
    unichar tagName[256];
    unichar attrName[256];
    unichar attrValue[2048];
    
    NSString *nextTag = nil;
    NSString *nextType = nil;
    NSMutableDictionary *nextAttributes = nil;
    
    int i = 0;
    if(!checkXML(bytes, &i)) {
        PxError(@"%s (Line %d)\nCXML Syntax Error durring XML-Check: Invalid XML-Header?", __FILE__, __LINE__);
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
                    PxError(@"%s (Line %d)\nCXML Syntax Error durring Tag-Parsing: New tag inside existing tag?", __FILE__, __LINE__);
                    CLEAN_STRING_BEFORE_RETURN
                    return nil;
                }
                
                unichar c = bytes[i];
                int j=0;
                for (; c != ' ' && c != '>' && c != '/'; j++) {
                    tagName[j] = c;
                    i++; c = bytes[i];
                }
                
                nextTag = [NSString stringWithCharacters:tagName length:j];
                
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
                            PxError(@"%s (Line %d)\nCXML Syntax Error durring Type-Parsing: Missing Value", __FILE__, __LINE__);
                            CLEAN_STRING_BEFORE_RETURN
                            return nil;
                        }
                        j++;
                        
                        int k=0;
                        for (; bytes[i+1+j+k] != '"'; k++) {
                            attrValue[k] = bytes[i+1+j+k];
                        }
                        nextType = [NSString stringWithCharacters:attrValue length:k]; // Improvement: Dont use NSString
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
                PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: No Working Object", __FILE__, __LINE__);
                CLEAN_STRING_BEFORE_RETURN
                return nil;
            }
            
            int j=0;
            for (; bytes[i] != '='; j++, i++) {
                attrName[j] = bytes[i];
            }
            NSString *attr = [NSString stringWithCharacters:attrName length:j];
            
            // Skip starting Quote
            i++;
            if (bytes[i] != '"') {//syntax Error
                PxError(@"%s (Line %d)\nCXML Syntax Error durring Attribute-Parsing: Missing Value", __FILE__, __LINE__);
                CLEAN_STRING_BEFORE_RETURN
                return nil;
            }
            i++;
            
            j=0;
            for (; bytes[i] != '"'; j++, i++) {
                attrValue[j] = bytes[i];
            }
            
            if (!nextAttributes) {
                nextAttributes = [[NSMutableDictionary alloc] init];
            }
            
            NSString *value = [NSString stringWithCharacters:attrValue length:j];
            [nextAttributes setValue:PxXMLUnescape(value) forKey:attr];
        }
    }
    CLEAN_STRING_BEFORE_RETURN
    return ret;
}

@end
