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
//  PxActionButtonConfig.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxActionButtonConfig.h"
#import <PxCore/PxCore.h>

@interface PxActionButtonConfigStore : NSObject
@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) NSUInteger index;
@property(nonatomic, strong) PxActionButtonConfigBlock block;
@property(nonatomic, assign) PxActionButtonType type;

- (id)initWithTitle:(NSString *)title index:(NSUInteger)index block:(PxActionButtonConfigBlock)block type:(PxActionButtonType)type;
- (void)execute;

@end

@interface PxActionButtonConfig ()
@property(nonatomic, strong) NSMutableDictionary *buttonConfigs;
@property(nonatomic, assign) NSUInteger buttonCount;
@property(nonatomic, assign) NSUInteger visibleButtonCount;

@end

@implementation PxActionButtonConfig

- (void)addButtonTitle:(NSString *)title block:(PxActionButtonConfigBlock)block type:(PxActionButtonType)type {
    if (title && block) {
        self.buttonConfigs[NR(_visibleButtonCount)] = [[PxActionButtonConfigStore alloc] initWithTitle:title index:_buttonCount block:block type:type];
        _visibleButtonCount++;
    }
    _buttonCount++;
}

- (void)addButtonTitle:(NSString *)title block:(PxActionButtonConfigBlock)block {
    [self addButtonTitle:title block:block type:PxActionButtonTypeDefault];
}

- (void)setSpecialButton:(NSString *)title block:(PxActionButtonConfigBlock)block type:(PxActionButtonType)type {
    if (![self.buttonConfigs include:^BOOL(id key, PxActionButtonConfigStore *value) {return value.type == type;}]) {
        [self addButtonTitle:title block:block type:type];
    }else {
        PxError(@"<PxActionButtonConfig> allready assigned Button of type: %d", type);
    }
}

- (void)setCancelButton:(NSString *)title block:(PxActionButtonConfigBlock)block {
    [self setSpecialButton:title block:block type:PxActionButtonTypeCancel];
}

- (void)setDestructiveButton:(NSString *)title block:(PxActionButtonConfigBlock)block {
    if ([self cancelIndex] != NSNotFound) {
        PxError(@"<PxActionButtonConfig> setDestructiveButton: setting the destructive button after the cancel button leads to bugs in the GUI");
    }else {
        [self setSpecialButton:title block:block type:PxActionButtonTypeDestroy];
    }
}

- (void)executeButtonAtIndex:(NSUInteger)index {
    PxActionButtonConfigStore *config = self.buttonConfigs[NR(index)];
    if (!config) {
        PxError(@"<PxActionButtonConfig> executeButtonAtIndex: object not found at index: %ld", (long)index);
    }else {
        [config execute];
    }
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    PxActionButtonConfigStore *config = self.buttonConfigs[NR(index)];
    if (!config) {
        PxError(@"<PxActionButtonConfig> titleAtIndex: object not found at index: %ld", (long)index);
    }else {
        return [config title];
    }
    return nil;
}

- (NSInteger)indexOfTitle:(NSString *)title {
    NSNumber *num = [[self.buttonConfigs find:^BOOL(id key, PxActionButtonConfigStore *conf) {
        return [[conf title] isEqualToString:title];
    }] first];
    if (num) {
        return [num intValue];
    }
    return NSNotFound;
}

- (NSInteger)specialIndex:(PxActionButtonType)type {
    NSNumber *num = [[self.buttonConfigs find:^BOOL(id key, PxActionButtonConfigStore *conf) {
        return [conf type] == type;
    }] first];
    if (num) {
        return [num intValue];
    }
    return NSNotFound;
}

- (NSUInteger)cancelIndex {
    return [self specialIndex:PxActionButtonTypeCancel];
}

- (NSUInteger)destructiveIndex {
    return [self specialIndex:PxActionButtonTypeDestroy];
}

- (void)setObject:(id)block forKeyedSubscript:(NSString *)title {
    [self addButtonTitle:title block:block];
}

- (NSMutableDictionary *)buttonConfigs {
    if (!_buttonConfigs) {
        _buttonConfigs = [[NSMutableDictionary alloc] init];
    }
    return _buttonConfigs;
}

- (void)reorderButtons {
    NSInteger d = [self destructiveIndex];
    NSInteger c = [self cancelIndex];
    if (d != NSNotFound || (c != NSNotFound && c>-1 && c<_visibleButtonCount-1)) {
        NSMutableArray *orderedButtonTitles = [NR(_visibleButtonCount) times:^id(int nr) {
            return [self titleAtIndex:nr];
        }];
        if (d>0) {
            NSString *destTitle = [orderedButtonTitles objectAtIndex:d];
            [orderedButtonTitles removeObjectAtIndex:d];
            [orderedButtonTitles insertObject:destTitle atIndex:0];
        }
        if ((c != NSNotFound && c>-1 && c<_visibleButtonCount-1)) {
            NSString *cnclTitle = [orderedButtonTitles objectAtIndex:c];
            [orderedButtonTitles removeObjectAtIndex:c];
            [orderedButtonTitles addObject:cnclTitle];
        }
        
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[orderedButtonTitles count]];
        [orderedButtonTitles eachWithIndex:^(NSString *title, NSUInteger index) {
            PxPair *c = [self.buttonConfigs find:^BOOL(id key, PxActionButtonConfigStore *conf) {
                return [conf.title isEqualToString:title];
            }];
            dict[NR(index)] = [c second];
        }];
        _buttonConfigs = dict;
    }
}

@end

@implementation PxActionButtonConfigStore

- (id)initWithTitle:(NSString *)title index:(NSUInteger)index block:(PxActionButtonConfigBlock)block type:(PxActionButtonType)type {
    self = [super init];
    if (self) {
        _title = title;
        _index = index;
        _block = block;
        _type  = type;
    }
    return self;
}

- (void)execute {
    if (_block) {
        _block();
    }
}

@end