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
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxLocalize.h"

@implementation PxLocalize {
	NSString *language;
}

#pragma mark - Singleton Handling
static PxLocalize *_sharedLocalSystem = nil;

+ (PxLocalize *)sharedLocalSystem {
    if (!_sharedLocalSystem) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedLocalSystem = [[super allocWithZone:NULL] init];
        });
    }
    return _sharedLocalSystem;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedLocalSystem];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Logic
static NSBundle *bundle = nil;

- (id)init {
    self = [super init];
    if (self) {
		bundle = [NSBundle mainBundle];
	}
    return self;
}

// Gets the current localized string as in NSLocalizedString.
//
// example calls:
// PXLocalizedString(@"Text to localize",@"Alternative text, in case hte other is not find");
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment {
	return [bundle localizedStringForKey:key value:comment table:nil];
}


- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment table:(NSString *)tableName {
    return [bundle localizedStringForKey:key value:comment table:tableName];
}


// Sets the desired language of the ones you have.
// example calls:
// PxLocalizeSetLanguage(@"Italian");
// PxLocalizeSetLanguage(@"German");
// PxLocalizeSetLanguage(@"Spanish");
//
// If this function is not called it will use the default OS language.
// If the language does not exists y returns the default OS language.
- (void)setLanguage:(NSString *)l {
	NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj" ];
	
	if (path == nil) {
        //in case the language does not exists
		[self resetLocalization];
    }else{
        bundle = [NSBundle bundleWithPath:path];
    }
}

// Just gets the current setted up language.
// returns "es","fr",...
//
// example call:
// NSString * currentL = PxLocalizeGetLanguage;
- (NSString *)getLanguage {
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	NSString *preferredLang = [languages objectAtIndex:0];
    
	return preferredLang;
}

// Resets the localization system, so it uses the OS default language.
//
// example call:
// PxLocalizeReset;
- (void)resetLocalization {
	bundle = [NSBundle mainBundle];
}

@end
