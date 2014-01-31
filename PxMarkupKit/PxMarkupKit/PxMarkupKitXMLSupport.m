//
//  PxMarkupKitXMLSupport.m
//  PxMarkupKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxMarkupKitXMLSupport.h"


#define ADD_ESCAPE_SEQUENCE(__BUFFER__, __SEQ__) __BUFFER__[b++] = '&';for (int j=0; j<sizeof(__SEQ__)/sizeof(__SEQ__[0]); j++) {__BUFFER__[b++] = __SEQ__[j];}; __BUFFER__[b++] = ';';
#define COMP_ESCAPE_SEQUENCE(__BUFFER__, __SEQ__) compareEscapeSequence(__BUFFER__, __SEQ__, sizeof(__SEQ__)/sizeof(__SEQ__[0]))
#define MEM_PAGE_SIZE 1024
#define MAX_SEQ_LENGTH 5

char __newLine[3] = {'#', 'x', 'A'};
char __quot[4] = {'q', 'u', 'o', 't'};
char __amp[3] = {'a', 'm', 'p'};
char __apos[4] = {'a', 'p', 'o', 's'};
char __lt[2] = {'l', 't'};
char __gt[2] = {'g', 't'};
char __Auml[4] = {'A', 'u', 'm', 'l'};
char __Ouml[4] = {'O', 'u', 'm', 'l'};
char __Uuml[4] = {'U', 'u', 'm', 'l'};
char __sz[5] = {'s', 'z', 'l', 'i', 'g'};
char __auml[4] = {'a', 'u', 'm', 'l'};
char __ouml[4] = {'o', 'u', 'm', 'l'};
char __uuml[4] = {'u', 'u', 'm', 'l'};


static inline BOOL compareEscapeSequence(unichar *buffer, char *seq, int seqLen) {
    BOOL isSeq = YES; for (int x=0; x<seqLen; x++) {if(seq[x] != buffer[x]) {isSeq = NO; break;}}
    return isSeq;
}

NSString *xmlEscapedString(NSString *string);
NSString *xmlUnescapedString(NSString *string);

NSString *PxXMLEscape(id<PxMarkupAttribute> object) {
    NSString *input = [object stringForMarkupAttribute];
    if (input) {
        NSString *ret = xmlEscapedString(input);
        return ret;
    }
    return nil;
}

NSString *PxXMLUnescape(NSString *string) {
    if (string) {
        return xmlUnescapedString(string);
    }
    return nil;
}

NSString *xmlEscapedString(NSString *string) {
    NSUInteger length = [string length];
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:length];
    
    unichar buffer[MEM_PAGE_SIZE*(MAX_SEQ_LENGTH+2)];
    for (int page = 0; page<length; page += MEM_PAGE_SIZE) {
        int b = 0;
        int i;
        for (i=page; i<MIN(length,MEM_PAGE_SIZE+page); i++) {
            unichar c = [string characterAtIndex:i];
            switch (c) {
                case 10: // \n
                    ADD_ESCAPE_SEQUENCE(buffer, __newLine);
                    break;
                case 34: // "
                    ADD_ESCAPE_SEQUENCE(buffer, __quot);
                    break;
                case 38: // &
                    ADD_ESCAPE_SEQUENCE(buffer, __amp);
                    break;
                case 39: // '
                    ADD_ESCAPE_SEQUENCE(buffer, __apos);
                    break;
                case 60: // <
                    ADD_ESCAPE_SEQUENCE(buffer, __lt);
                    break;
                case 62: // >
                    ADD_ESCAPE_SEQUENCE(buffer, __gt);
                    break;
                case 196: // Ä
                    ADD_ESCAPE_SEQUENCE(buffer, __Auml);
                    break;
                case 214: // Ö
                    ADD_ESCAPE_SEQUENCE(buffer, __Ouml);
                    break;
                case 220: // Ü
                    ADD_ESCAPE_SEQUENCE(buffer, __Uuml);
                    break;
                case 223: // ß
                    ADD_ESCAPE_SEQUENCE(buffer, __sz);
                    break;
                case 228: // ä
                    ADD_ESCAPE_SEQUENCE(buffer, __auml);
                    break;
                case 246: // ö
                    ADD_ESCAPE_SEQUENCE(buffer, __ouml);
                    break;
                case 252: // ü
                    ADD_ESCAPE_SEQUENCE(buffer, __uuml);
                    break;
                default:
                    buffer[b++] = c;
                    break;
            }
        }
        [outputString appendString:[[NSString alloc] initWithCharacters:buffer length:b]];
    }
    return outputString;
}

NSString *xmlUnescapedString(NSString *string) {
    NSUInteger length = [string length];
    unichar *retBuffer = malloc(length*sizeof(unichar));
    unichar seqBuffer[MAX_SEQ_LENGTH];
    memset(seqBuffer, 0, MAX_SEQ_LENGTH);
    
    int b=0;
    for (int i = 0; i<length; i++) {
        unichar c = [string characterAtIndex:i];
        if (c == '&') {
            i++;
            int j = 0;
            while (i<length && j<MAX_SEQ_LENGTH && (seqBuffer[j] = [string characterAtIndex:i]) != ';') {j++;i++;}
            
            if (COMP_ESCAPE_SEQUENCE(seqBuffer, __newLine)) {
                retBuffer[b++] = '\n';
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __quot)) {
                retBuffer[b++] = '"';
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __amp)) {
                retBuffer[b++] = '&';
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __apos)) {
                retBuffer[b++] = '\'';
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __lt)) {
                retBuffer[b++] = '<';
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __gt)) {
                retBuffer[b++] = '>';
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __Auml)) {
                retBuffer[b++] = 196;
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __Ouml)) {
                retBuffer[b++] = 214;
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __Uuml)) {
                retBuffer[b++] = 220;
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __sz)) {
                retBuffer[b++] = 223;
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __auml)) {
                retBuffer[b++] = 228;
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __ouml)) {
                retBuffer[b++] = 246;
            }else if(COMP_ESCAPE_SEQUENCE(seqBuffer, __uuml)) {
                retBuffer[b++] = 252;
            }
        }else {
            retBuffer[b++] = c;
        }
    }
    NSString *outputString = [NSString stringWithCharacters:retBuffer length:b];
    free(retBuffer);
    return outputString;
}
