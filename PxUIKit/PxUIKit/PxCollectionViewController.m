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
//  PxCollectionViewController.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxCollectionViewController.h"
#import <PxCore/PxCore.h>
#import "PxCollectionViewCell.h"
#import <objc/runtime.h>
#import "PxUIKitSupport.h"
#import "UIView+PxUIKit.h"

@interface PxCollectionViewController ()

@end

@implementation PxCollectionViewController

+ (void)initialize {
    if ([[self class] dynamicSize] && ![[self class] instancesRespondToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        Method __template__ = class_getInstanceMethod([self class], @selector(__template__collectionView:layout:sizeForItemAtIndexPath:));
        IMP __imp__ = method_getImplementation(__template__);
        class_addMethod([self class], @selector(collectionView:layout:sizeForItemAtIndexPath:), __imp__, method_getTypeEncoding(__template__));
    }
    
    if ([[self class] dynamicHeaderSize] && ![[self class] instancesRespondToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        Method __template__ = class_getInstanceMethod([self class], @selector(__template__collectionView:layout:referenceSizeForHeaderInSection:));
        IMP __imp__ = method_getImplementation(__template__);
        class_addMethod([self class], @selector(collectionView:layout:referenceSizeForHeaderInSection:), __imp__, method_getTypeEncoding(__template__));
    }
    
    if ([[self class] dynamicFooterSize] && ![[self class] instancesRespondToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        Method __template__ = class_getInstanceMethod([self class], @selector(__template__collectionView:layout:referenceSizeForFooterInSection:));
        IMP __imp__ = method_getImplementation(__template__);
        class_addMethod([self class], @selector(collectionView:layout:referenceSizeForFooterInSection:), __imp__, method_getTypeEncoding(__template__));
    }
}

#pragma mark - Configurate Collection Appeareance
+ (BOOL)dynamicSize {
    return NO;
}

+ (BOOL)dynamicHeaderSize {
    return NO;
}

+ (BOOL)dynamicFooterSize {
    return NO;
}

+ (BOOL)sectional {
    return NO;
}

+ (BOOL)draggable {
    return NO;
}

+ (BOOL)alternating {
    return NO;
}

+ (BOOL)oneDimensional {
    return NO;
}

+ (PxCollectionViewGridLayout *)collectionViewLayout {
    return [[PxCollectionViewGridLayout alloc] init];
}

+ (Class)collectionViewClass {
    return [PxDataCollectionGridView class];
}

#pragma mark - View loading
- (void)loadView {
    [self loadStdView];
    [self loadCollection];
}

- (void)updateView {
    [self.collectionView reloadData];
}

- (void)loadCollection {
    _collectionView = [[[self.class collectionViewClass] alloc] initWithFrame:CGRectFromSize(self.view.size) collectionViewLayout:[[self class] collectionViewLayout]];
    [_collectionView setDefaultResizingMask];
    [_collectionView setSectional:[[self class] sectional]];
    [_collectionView setAlternating:[[self class] alternating]];
    [_collectionView setOneDimensional:[[self class] oneDimensional]];
    [_collectionView setPxDataSource:self];
    [_collectionView setDelegate:self];
    [self.view addSubview:_collectionView];
}

#pragma mark - Providing Data
- (void)setData:(NSArray *)data {
    [self setData:data reload:YES];
}

- (void)setData:(NSArray *)data reload:(BOOL)reload {
    if (data != _data) {
        _data = data;
        if (reload) {
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - PxDataCollectionGridViewDelegate
- (Class)collectionView:(PxDataCollectionGridView *)collectionView classForCellAtIndexPath:(NSIndexPath *)indexPath {
    [NSException raise:@"Not Implemented Error" format:@"<%@> You have to implement the Method - (Class)collectionView:(PxDataCollectionGridView *)collectionView classForCellAtIndexPath:(NSIndexPath *)indexPath in Subclasses", [self class]];
    return nil;
}

- (CGSize)__template__collectionView:(PxDataCollectionGridView *)collectionView layout:(PxCollectionViewGridLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)path {
    return [self.collectionView sizeForItemAtIndexPath:path];
}

- (CGSize)__template__collectionView:(PxDataCollectionGridView *)collectionView layout:(PxCollectionViewGridLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section {
    return [self.collectionView sizeForHeaderAtSection:section];
}

- (CGSize)__template__collectionView:(PxDataCollectionGridView *)collectionView layout:(PxCollectionViewGridLayout *)layout referenceSizeForFooterInSection:(NSInteger)section {
    return [self.collectionView sizeForFooterAtSection:section];
}

- (NSArray *)dataForCollectionView:(PxDataCollectionGridView *)collectionView {
    return self.data;
}

- (void)collectionView:(PxDataCollectionGridView *)collectionView didUpdateData:(NSArray *)data {
    [self setData:data reload:NO];
}

@end
