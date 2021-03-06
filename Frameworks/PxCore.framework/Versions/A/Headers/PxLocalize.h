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
//  PxLocalize.h
//  PxCore
//
//  Created by Jonathan Cichon on 10.02.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxCoreSupport.h"
#import "NSObject+PxCore.h"

#define PxLocalizedString(__key__) [[PxLocalize sharedLocalSystem] localizedStringForKey:(__key__) value:nil]

#define PxLocalizedStringWithComment(__key__, __comment__) [[PxLocalize sharedLocalSystem] localizedStringForKey:(__key__) value:(__comment__)]

#define PxLocalizedStringFromTable(__key__, __table__) [[PxLocalize sharedLocalSystem] localizedStringForKey:(__key__) value:nil table:(__table__)]

#define PxLocalizedStringFromTableWithComment(__key__, __table__, __comment__) [[PxLocalize sharedLocalSystem] localizedStringForKey:(__key__) value:(__comment__) table:(__table__)]

#define PxLocalizeSetLanguage(language) [[PxLocalize sharedLocalSystem] setLanguage:(language)]

#define PxLocalizeGetLanguage [[PxLocalize sharedLocalSystem] getLanguage]

#define PxLocalizeReset [[PxLocalize sharedLocalSystem] resetLocalization]

#define T(s) PxLocalizedString(s)
#define TC(s, c) PxLocalizedStringWithComment(s, c)
#define TT(s, t) PxLocalizedStringFromTable(s, t)
#define TTC(s, t, c) PxLocalizedStringFromTableWithComment(s, t, c)

/**
 * Use this class for convinient access to apples localization strings.
 * Support for on-the-fly language change without the need of restarting the application.
 */
@interface PxLocalize : NSObject

PxSingleton(sharedLocalSystem)

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment table:(NSString *)tableName;

- (void)setLanguage:(NSString *)language;

- (NSString *)getLanguage;

- (void)resetLocalization;

@end