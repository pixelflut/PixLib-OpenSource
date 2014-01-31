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
//  PxDataCollectionGridView.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxCollectionView.h"
#import "PxCollectionViewGridLayout.h"

@protocol PxDataCollectionGridViewDelegate;
@protocol PxDataCollectionGridViewDataSource;



@interface PxDataCollectionGridView : PxCollectionView
@property (nonatomic, assign) BOOL oneDimensional;
@property (nonatomic, assign) BOOL alternating;
@property (nonatomic, assign) BOOL sectional;
@property (nonatomic, weak) id<PxDataCollectionGridViewDataSource> pxDataSource;
@property (nonatomic, assign) id<PxDataCollectionGridViewDelegate> delegate;
@property (nonatomic, assign) id<UICollectionViewDataSource> dataSource OBJC2_UNAVAILABLE;

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PxCollectionViewGridLayout *)layout;

- (NSString *)identifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (id)dataForItemAtIndexPath:(NSIndexPath *)indexPath;
- (id)dataForSection:(NSUInteger)section;

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(id)item;
- (NSInteger)numberOfItemsInSection:(NSUInteger)section useData:(BOOL)useData;

- (void)removeEntriesFromCollection:(NSArray *)entries;

@end

@protocol PxDataCollectionGridViewDelegate <UICollectionViewDelegateFlowLayout>
- (Class)collectionView:(PxDataCollectionGridView *)collectionView classForCellAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol PxDataCollectionGridViewDataSource <NSObject>
- (NSArray *)dataForCollectionView:(PxDataCollectionGridView *)collectionView;

@optional
- (NSString *)collectionView:(PxDataCollectionGridView *)collectionView identfierForCellAtIndexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier;

- (void)collectionView:(PxDataCollectionGridView *)collectionView didUpdateData:(NSArray *)data;
- (void)collectionViewDidStartDeleteAnimation:(PxDataCollectionGridView *)collectionView;

#pragma mark - UICollectionViewDataSource forwarding
- (UICollectionReusableView *)collectionView:(PxDataCollectionGridView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end