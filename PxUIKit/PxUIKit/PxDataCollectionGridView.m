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
//  PxDataCollectionGridView.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxDataCollectionGridView.h"
#import <PxCore/PxCore.h>
#import "PxCollectionViewCell.h"

#define SELECTOR_COUNT 1
typedef struct {
    SEL selector;
    BOOL exist;
} SELInfo;

@interface PxDataCollectionGridView () <UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) BOOL dynamicSize;
@property (nonatomic, assign) BOOL dynamicIdentifier;
@property (nonatomic, assign) SELInfo *selectorLookUp;

- (NSMutableArray *)removeEntriesFromData:(NSArray *)entries;
- (NSMutableArray *)sectionalRemoveEntriesFromData:(NSArray *)entries;
- (NSMutableArray *)plainRemoveEntriesFromData:(NSArray *)entries;

- (NSIndexSet *)removeEmptySectionsFromData;
- (NSIndexSet *)sectionalRemoveEmptySectionsFromData;
- (NSIndexSet *)plainRemoveEmptySectionsFromData;

@end

@implementation PxDataCollectionGridView

- (id)initWithFrame:(CGRect)frame {
    PxCollectionViewGridLayout *gridLayout = [[PxCollectionViewGridLayout alloc] init];
    return [self initWithFrame:frame collectionViewLayout:gridLayout];
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PxCollectionViewGridLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _selectorLookUp = malloc(sizeof(SELInfo)*SELECTOR_COUNT);
        
        _selectorLookUp[0].selector = @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:);
        _selectorLookUp[0].exist    = NO;
    }
    return self;
}

- (void)reloadData {
	if (!_dynamicSize && self.delegate) {
		Class klass = [self.delegate collectionView:self classForCellAtIndexPath:nil];
		[(PxCollectionViewGridLayout *)self.collectionViewLayout setItemSize:[klass cellSizeWithData:nil reuseIdentifier:nil collectionView:self]];
        [self.collectionViewLayout invalidateLayout];
	}
    self.data = [self.pxDataSource dataForCollectionView:self];
    [super reloadData];
}

- (void)setSectional:(BOOL)sectional {
    if (sectional != _sectional) {
        _sectional = sectional;
        [self reloadData];
    }
}

- (void)setAlternating:(BOOL)alternating {
    if (alternating != _alternating) {
        _alternating = alternating;
        [super reloadData];
    }
}

- (void)setOneDimensional:(BOOL)oneDimensional {
    if (oneDimensional != _oneDimensional) {
        _oneDimensional = oneDimensional;
        [super reloadData];
    }
}

#pragma mark - Shared Collection Handling
- (NSString*)identifierForCellInTableStyleAtIndexPath:(NSIndexPath *)indexPath {
    int cellPosition = PxCellPositionMiddle;
    NSInteger rowCount = [self numberOfItemsInSection:indexPath.section];
	NSInteger sectionCount = [self numberOfSections];
	
	if(indexPath.row == rowCount-1 && indexPath.section == sectionCount-1) {cellPosition |= PxCellPositionLast;}
    if(indexPath.row == rowCount-1 && indexPath.row == 0) {cellPosition |= PxCellPositionSingle;}
    if(indexPath.row == 0 && indexPath.section == 0) {cellPosition |= PxCellPositionFirst;}
    if(indexPath.row == rowCount-1){cellPosition |= PxCellPositionBottom;}
    if(indexPath.row == 0) {cellPosition |= PxCellPositionTop;}
    
    NSString *identifier = [NSString stringWithFormat:@"%d_%@", cellPosition, NSStringFromClass([self.delegate collectionView:self classForCellAtIndexPath:indexPath])];
    
    if (self.alternating) {
        return [identifier stringByAppendingFormat:@"_%d", (int32_t)indexPath.row%2];
    }
    
    if (_dynamicIdentifier) {
        identifier = [self.pxDataSource collectionView:self identfierForCellAtIndexPath:indexPath identifier:identifier];
    }
    
    return identifier;
}

- (NSString *)identifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.oneDimensional || _dynamicIdentifier) {
        return [self identifierForCellInTableStyleAtIndexPath:indexPath];
    }
    return @"default";
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dynamicSize) {
        Class klass = [self.delegate collectionView:self classForCellAtIndexPath:indexPath];
        return [klass cellSizeWithData:[self dataForItemAtIndexPath:indexPath] reuseIdentifier:[self identifierForCellAtIndexPath:indexPath] collectionView:self];
    }else {
        return [(PxCollectionViewGridLayout *)self.collectionViewLayout itemSize];
    }
}

- (NSInteger)numberOfItemsInSection:(NSUInteger)section useData:(BOOL)useData {
    if (useData) {
        return [self collectionView:self numberOfItemsInSection:section];
    }
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class klass = [self.delegate collectionView:self classForCellAtIndexPath:indexPath];
    [self registerClass:klass forCellWithReuseIdentifier:[self identifierForCellAtIndexPath:indexPath]];
    
    PxCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:[self identifierForCellAtIndexPath:indexPath] forIndexPath:indexPath];
	[cell setCollectionView:self];
	[cell setDelegate:self.delegate];
    [cell setData:[self dataForItemAtIndexPath:indexPath]];
    return cell;
}

- (void)removeEntriesFromCollection:(NSArray *)entries {
    NSMutableArray *indexPaths = [self removeEntriesFromData:entries];
    NSIndexSet *indexSet = [self removeEmptySectionsFromData];
    
    [indexPaths deleteIf:^BOOL(NSIndexPath *path) {
        return [indexSet containsIndex:path.section];
    }];
    
    if ([self.pxDataSource respondsToSelector:@selector(collectionView:didUpdateData:)]) {
        [self.pxDataSource collectionView:self didUpdateData:self.data];
    }
    
    if ([indexPaths count] > 0 || [indexSet count] > 0) {
        [self performBatchUpdates:^{
            if ([indexSet count] > 0) {
                [self deleteSections:indexSet];
            }
            if ([indexPaths count] > 0) {
                [self deleteItemsAtIndexPaths:indexPaths];
            }
        } completion:^(BOOL finished) {
            if ([self.pxDataSource respondsToSelector:@selector(collectionViewDidStartDeleteAnimation:)]) {
                [self.pxDataSource collectionViewDidStartDeleteAnimation:self];
            }
            
        }];
    }
}

#pragma mark - Plain/Sectional Switches
- (id)dataForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        if (self.sectional) {
            return [self sectionalDataForItemAtIndexPath:indexPath];
        }else {
            return [self plainDataForItemAtIndexPath:indexPath];
        }
    }
    return nil;
}

- (id)dataForSection:(NSUInteger)section {
    if (self.sectional) {
        return [(PxPair *)[self.data objectAtIndex:section] first];
    } else {
        return nil;
    }
}

- (NSIndexPath *)indexPathForItem:(id)item {
    if (self.sectional) {
        return [self sectionalIndexPathForItem:item];
    }else {
        return [self plainIndexPathForItem:item];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.sectional) {
        return [self sectionalNumberOfSectionsInCollectionView:collectionView];
    }else {
        return [self plainNumberOfSectionsInTCollectionView:collectionView];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.sectional) {
        return [self sectionalCollectionView:collectionView numberOfItemsInSection:section];
    }else {
        return [self plainCollectionView:collectionView numberOfItemsInSection:section];
    }
}

- (NSMutableArray *)removeEntriesFromData:(NSArray *)entries {
    if (self.sectional) {
        return [self sectionalRemoveEntriesFromData:entries];
    }else {
        return [self plainRemoveEntriesFromData:entries];
    }
}

- (NSIndexSet *)removeEmptySectionsFromData {
    if (self.sectional) {
        return [self sectionalRemoveEmptySectionsFromData];
    }else {
        return [self plainRemoveEmptySectionsFromData];
    }
}

#pragma mark - Plain Collection Handling
- (id)plainDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.data objectAtIndex:indexPath.row];
}

- (NSIndexPath *)plainIndexPathForItem:(id)item {
    return [NSIndexPath indexPathForRow:[self.data index:^BOOL(id obj) {
        return obj == item;
    }] inSection:0];
}

- (NSInteger)plainNumberOfSectionsInTCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)plainCollectionView:(UICollectionView *)tableView numberOfItemsInSection:(NSInteger)section {
	return [self.data count];
}

- (NSMutableArray *)plainRemoveEntriesFromData:(NSArray *)entries {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[entries count]];
    NSMutableArray *lookUp = [entries mutableCopy];
    self.data = [self.data collectWithIndex:^id(id obj, NSUInteger index) {
        if ([lookUp include:^BOOL(id obj2) {
            return obj2 == obj;
        }]) {
            [lookUp removeObject:obj];
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            return nil;
        }
        return obj;
    } skipNil:YES];
    return indexPaths;
}

- (NSIndexSet *)plainRemoveEmptySectionsFromData {
    if ([self.data count] == 0) {
        return [NSIndexSet indexSetWithIndex:0];
    }
    return nil;
}

#pragma mark - Sectional Table Handling
- (id)sectionalDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[(PxPair*)[self.data objectAtIndex:indexPath.section] second] objectAtIndex:indexPath.row];
}

- (NSIndexPath *)sectionalIndexPathForItem:(id)item {
    for (int section = 0; section<[self.data count]; section++) {
        PxPair *pair = [self.data objectAtIndex:section];
        for (int row = 0; row < [pair.second count]; row++) {
            if ([pair.second objectAtIndex:row] == item) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

- (NSUInteger)sectionalCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[(PxPair*)[self.data objectAtIndex:section] second] count];
}

- (NSUInteger)sectionalNumberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.data count];
}

- (NSMutableArray *)sectionalRemoveEntriesFromData:(NSArray *)entries {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *lookUp = [entries mutableCopy];
    
    for (int i = 0; i < [self.data count]; i++) {
        PxPair *pair = [self.data objectAtIndex:i];
        [pair setSecond:[(NSArray*)[pair second] collectWithIndex:^id(id obj, NSUInteger index) {
            if ([lookUp include:^BOOL(id obj2) {
                return obj2 == obj;
            }]) {
                [lookUp removeObject:obj];
                [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:i]];
                return nil;
            }
            return obj;
        } skipNil:YES]];
    }
    return indexPaths;
}

- (NSIndexSet *)sectionalRemoveEmptySectionsFromData {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [self setData:[self.data collectWithIndex:^id(PxPair *pair, NSUInteger section) {
        if ([[pair second] count] > 0) {
            return pair;
        }else {
            [indexSet addIndex:section];
            return nil;
        }
    } skipNil:YES]];
    return indexSet;
}

#pragma mark - Message forwarding
- (id)forwardingTargetForSelector:(SEL)aSelector {
    for (int i=0; i<SELECTOR_COUNT; i++) {
        if (_selectorLookUp[i].exist && sel_isEqual(aSelector, _selectorLookUp[i].selector)) {
            return self.pxDataSource;
        }
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    for (int i=0; i<SELECTOR_COUNT && _selectorLookUp; i++) {
        if (_selectorLookUp[i].exist && sel_isEqual(aSelector, _selectorLookUp[i].selector)) {
            return YES;
        }
    }
    return [super respondsToSelector:aSelector];
}

#pragma mark - Interface Overwrite
- (void)setPxDataSource:(id<PxDataCollectionGridViewDataSource>)dataSource {
    id old = _pxDataSource;
    if (dataSource != _pxDataSource) {
        _pxDataSource = dataSource;
        _dynamicIdentifier = [dataSource respondsToSelector:@selector(collectionView:identfierForCellAtIndexPath:identifier:)];
        for (int i=0; i<SELECTOR_COUNT; i++) {
            _selectorLookUp[i].exist = [dataSource respondsToSelector:_selectorLookUp[i].selector];
        }
        
        if (old) {
            [super setDataSource:nil];
        }
        [super setDataSource:self];
        [self reloadData];
    }
}

- (id<PxDataCollectionGridViewDelegate>)delegate {
    return (id<PxDataCollectionGridViewDelegate>)[super delegate];
}

- (void)setDelegate:(id<PxDataCollectionGridViewDelegate>)delegate {
    if (delegate) {
        _dynamicSize = [delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)];
        if (!_dynamicSize && delegate) {
            Class klass = [delegate collectionView:self classForCellAtIndexPath:nil];
            [(PxCollectionViewGridLayout *)self.collectionViewLayout setItemSize:[klass cellSizeWithData:nil reuseIdentifier:nil collectionView:self]];
            [self.collectionViewLayout invalidateLayout];
        }
    }
    [super setDelegate:delegate];
    if (delegate) {
        [self reloadData];
    }
}

#pragma mark - Memory Cleanup
- (void)dealloc {
    free(_selectorLookUp);
}

@end
