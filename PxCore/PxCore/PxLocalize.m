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
//  PxLocalize.m
//  PxCore
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxLocalize.h"

@interface PxLocalize ()
@property(nonatomic, strong) NSString *language;
@property(nonatomic, strong) NSString *mainLanguage;
@property(nonatomic, strong) NSBundle *mainLanguageBundle;

@end

@implementation PxLocalize

#pragma mark - Singleton Handling
PxSingletonImp(sharedLocalSystem)

#pragma mark - Logic
static NSBundle *bundle = nil;

- (id)init {
    self = [super init];
    if (self) {
        _mainLanguage = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDevelopmentRegion"];
        if (_mainLanguage) {
            NSString *path = [[NSBundle mainBundle] pathForResource:_mainLanguage ofType:@"lproj" ];
            _mainLanguageBundle = [NSBundle bundleWithPath:path];
        }
        if (!_mainLanguageBundle) {
            _mainLanguageBundle = [NSBundle mainBundle];
        }
        
		[self resetLocalization];
	}
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment {
    return [self localizedStringForKey:key value:comment table:nil];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment table:(NSString *)tableName {
    NSString *value = [bundle localizedStringForKey:key value:comment table:tableName];
    
    // use Localizable.strings table as fallback
    if ([value isEqualToString:key] && tableName) {
        value = [bundle localizedStringForKey:key value:comment table:nil];
    }
    
    // use main language as fallback
    if ([value isEqualToString:key] && ![self.language isEqualToString:self.mainLanguage]) {
        value = [self.mainLanguageBundle localizedStringForKey:key value:value table:tableName];
    }
    
    // use main language and Localizeable.strings table as fallback
    if ([value isEqualToString:key] && tableName) {
        value = [self.mainLanguageBundle localizedStringForKey:key value:value table:nil];
    }
    
    return value;
}

- (void)setLanguage:(NSString *)l {
	NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj" ];
	if (path == nil) {
		bundle = _mainLanguageBundle;
        _language = self.mainLanguage;
    }else{
        bundle = [NSBundle bundleWithPath:path];
        _language = l;
    }
}

- (NSString *)getLanguage {
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	return [languages firstObject];
}

- (void)resetLocalization {
	[self setLanguage:[self getLanguage]];
}

@end
