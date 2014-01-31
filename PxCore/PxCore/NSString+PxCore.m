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
//  NSString+PxCore.m
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSString+PxCore.h"
#import "PxCore.h"
#import "hyphen.h"
#import <CommonCrypto/CommonDigest.h>

unichar __legalURLEscapeChars[] = { '!', '*', '\'', '\\', '"', '(', ')', ';', ':', '@', '&', '=', '+', '$', ',', '/', '?', '%', '#', '[', ']', '%', ' '};

@implementation NSString (PxCore)

- (NSComparisonResult)compare:(id)object context:(void *)context {
    return [self compare:object];
}

- (NSMutableDictionary*)dictionaryFromQueryString {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [[self componentsSeparatedByString:@"&"] each:^void(NSString *param) {
        NSArray *tmp = [param componentsSeparatedByString:@"="];
        if ([tmp count] != 2) {PxError(@"dictionaryFromQueryString: missformated queryString");}
        [dict setValue:[[tmp objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[tmp objectAtIndex:0]];
    }];
    return dict;
}

- (NSString *)eachCharacter:(void (^)(unichar character))block {
    for (int i = 0; i<[self length]; i++) {
        block([self characterAtIndex:i]);
    }
    return self;
}

- (NSString *)eachCharacterWithIndex:(void (^)(unichar character, NSUInteger index))block {
    for (int i = 0; i<[self length]; i++) {
        block([self characterAtIndex:i], i);
    }
    return self;
}

- (BOOL)isNotBlank {
    return ([self length] > 0);
}

- (BOOL)isValidEmail {
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (NSString *)stringByAddingMD5Encoding {
    if ([self isNotBlank]) {
        const char *cStr = [self UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
        return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    }
    return nil;
}

- (NSString *)stringByAddingSHA1Encoding {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
			result[16], result[17], result[18], result[19]];
}

- (NSString *)stringByAddingSHA1HMACEncoding:(NSString *)secret {
    const uint8_t *result = [[NSData dataBySHA1HMACEncodingData:[self dataUsingEncoding:NSASCIIStringEncoding] keyData:[secret dataUsingEncoding:NSASCIIStringEncoding]] bytes];
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
			result[16], result[17], result[18], result[19]];
}

- (NSString *)stringByAddingSHA256Encoding  {
    if ([self isNotBlank]) {
        const char *cStr = [self UTF8String];
        unsigned char result[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256( cStr, (CC_LONG)strlen(cStr), result );
        return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
                result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23],
                result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]];
    }
    return nil;
}

- (NSString*)stringByAddingURLEncoding {
    CFStringRef ignore = CFStringCreateWithCharacters(NULL, __legalURLEscapeChars, sizeof(__legalURLEscapeChars)/sizeof(__legalURLEscapeChars[0]));
    CFStringRef input = (__bridge CFStringRef)self;
    CFStringRef s = CFURLCreateStringByAddingPercentEscapes(NULL, input, NULL, ignore, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    CFRelease(ignore);
    return [NSString stringWithString:(__bridge_transfer NSString*)s];
}

- (NSString *)stringByApplyingKFC:(BOOL)compact {
    const char *constStr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSUInteger len = strlen(constStr);
    char *buffer = malloc(len+1);
    int n = 0;
    BOOL doublicate = NO;
    for (int i=0; i<len; i++) {
        if( constStr[i] < '0' || (constStr[i] < 'A' && constStr[i] > '9') || (constStr[i] < 'a' && constStr[i] > 'Z') || constStr[i] > 'z' ) {
            if (!doublicate || !compact) {
                if (!compact || i>0) {
                    buffer[n] = '_'; n++;
                }
                doublicate = YES;
            }
		} else {
            doublicate = NO;
			buffer[n] = constStr[i]; n++;
		}
    }
    if (compact) {
        while (n > 0 && buffer[n-1] == '_') {
            n--;
        }
    }
    return [[NSString alloc] initWithBytesNoCopy:buffer length:n encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

- (NSString *)stringByCamelizeString:(BOOL)upperCaseFirstLetter {
    return [[[self componentsSeparatedByString:@"_"] collectWithIndex:^id(id obj, NSUInteger index) {
        if ((upperCaseFirstLetter && index == 0) || index > 0) {
            return [obj capitalizedString];
        }
        return obj;
    }] componentsJoinedByString:@""];
}

- (NSString *)stringByHyphenatingWithLocale:(NSLocale *)locale {
    static HyphenDict* dict = NULL;
    static NSString* localeIdentifier = nil;
    static NSBundle* bundle = nil;
    
    ////////////////////////////////////////////////////////////////////////////
    // Setup.
    //
    // Establish that we got all the information we need: the bundle with
    // dictionaries, the locale and the loaded dictionary.  Cache dictionary and
    // save the language code used to retrieve it.
    //
    
    // Try to guess the locale from the string, if not given.
    CFStringRef language;
    if (locale == nil
        && (language = CFStringTokenizerCopyBestStringLanguage((CFStringRef)self, CFRangeMake(0, [self length]))))
    {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:(__bridge NSString*)language];
        CFRelease(language);
    }
    
    if (locale == nil) {
        return self;
    } // else
    
    if (![localeIdentifier isEqualToString:[locale localeIdentifier]]
        && dict != NULL)
    {
        hnj_hyphen_free(dict);
        dict = NULL;
    }
    
    localeIdentifier = [locale localeIdentifier];
    
    if (bundle == nil) {
        NSString* bundlePath = [[[NSBundle mainBundle] resourcePath]
                                stringByAppendingPathComponent:
                                @"Hyphenate.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    if (dict == NULL) {
        dict = hnj_hyphen_load([[bundle pathForResource:
                                 [NSString stringWithFormat:@"hyph_%@",
                                  localeIdentifier]
                                                 ofType:@"dic"]
                                UTF8String]);
    }
    
    if (dict == NULL) {
        return self;
    } // else
    
    ////////////////////////////////////////////////////////////////////////////
    // The works.
    //
    // No turning back now.  We traverse the string using a tokenizer and pass
    // every word we find into the hyphenation function.  Non-used tokens and
    // hyphenated words will be appended to the result string.
    //
    
    NSMutableString* result = [NSMutableString stringWithCapacity:
                               [self length] * 1.2];
    
    // Varibles used for tokenizing
    CFStringTokenizerRef tokenizer;
    CFStringTokenizerTokenType tokenType;
    CFRange tokenRange;
    NSString* token;
    
    // Varibles used for hyphenation
    char* hyphens;
    char** rep;
    int* pos;
    int* cut;
    int wordLength;
    int i;
    
    tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault,
                                        (CFStringRef)self,
                                        CFRangeMake(0, [self length]),
                                        kCFStringTokenizerUnitWordBoundary,
                                        (CFLocaleRef)locale);
    
    while ((tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer))
           != kCFStringTokenizerTokenNone)
    {
        tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        token = [self substringWithRange:
                 NSMakeRange(tokenRange.location, tokenRange.length)];
        
        if (tokenType & kCFStringTokenizerTokenHasNonLettersMask) {
            [result appendString:token];
        } else {
            char const* tokenChars = [[token lowercaseString] UTF8String];
            wordLength = (int)strlen(tokenChars);
            // This is the buffer size the algorithm needs.
            hyphens = (char*)malloc(wordLength + 5); // +5, see hypen.h
            rep = NULL; // Will be allocated by the algorithm
            pos = NULL; // Idem
            cut = NULL; // Idem
            
            // rep, pos and cut are not currently used, but the simpler
            // hyphenation function is deprecated.
            hnj_hyphen_hyphenate2(dict, tokenChars, wordLength, hyphens,
                                  NULL, &rep, &pos, &cut);
            
            NSUInteger loc = 0;
            NSUInteger len = 0;
            for (i = 0; i < wordLength; i++) {
                if (hyphens[i] & 1) {
                    len = i - loc + 1;
                    [result appendString: [token substringWithRange:NSMakeRange(loc, len)]];
                    [result appendString:@"­"]; // NOTE: UTF-8 soft hyphen!
                    loc = loc + len;
                }
            }
            if (loc < [token length]) {
                [result appendString: [token substringWithRange:NSMakeRange(loc, [token length] - loc)]];
            }
            
            // Clean up
            free(hyphens);
            if (rep) {
                for (i = 0; i < wordLength; i++) {
                    if (rep[i]) free(rep[i]);
                }
                free(rep);
                free(pos);
                free(cut);
            }
        }
    }
    
    CFRelease(tokenizer);
    
    return result;
}

- (NSString *)validString {
    if ([self isNotBlank]) {
        return self;
    }
    return nil;
}

#pragma mark - Class Methods

+ (NSString *)UUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef s = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
    return [NSString stringWithString:(__bridge_transfer NSString*)s];
}

@end