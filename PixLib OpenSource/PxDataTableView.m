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
//  PxDataTableView.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxDataTableView.h"
#import "PxCore.h"
#import "PxUIkit.h"

#define SELECTOR_COUNT 8
typedef struct {
    SEL selector;
    BOOL exist;
} SELInfo;

@interface PxDataTableView () <UITableViewDataSource>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) BOOL dynamicHeight;
@property (nonatomic, assign) BOOL dynamicIdentifier;
@property (nonatomic, assign) SELInfo *selectorLookUp;

@end

@implementation PxDataTableView
@synthesize alternating         = _alternating;
@synthesize sectional           = _sectional;
@synthesize pxDataSource        = _pxDataSource;
@synthesize data                = _data;
@synthesize dynamicHeight       = _dynamicHeight;
@synthesize dynamicIdentifier   = _dynamicIdentifier;
@synthesize selectorLookUp      = _selectorLookUp;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        _selectorLookUp = malloc(sizeof(SELInfo)*SELECTOR_COUNT);
        
        _selectorLookUp[0].selector = @selector(tableView:titleForHeaderInSection:);
        _selectorLookUp[0].exist    = NO;
        
        _selectorLookUp[1].selector = @selector(tableView:titleForFooterInSection:);
        _selectorLookUp[1].exist    = NO;
        
        _selectorLookUp[2].selector = @selector(tableView:canEditRowAtIndexPath:);
        _selectorLookUp[2].exist    = NO;
        
        _selectorLookUp[3].selector = @selector(tableView:canMoveRowAtIndexPath:);
        _selectorLookUp[3].exist    = NO;
        
        _selectorLookUp[4].selector = @selector(sectionIndexTitlesForTableView:);
        _selectorLookUp[4].exist    = NO;
        
        _selectorLookUp[5].selector = @selector(tableView:sectionForSectionIndexTitle:atIndex:);
        _selectorLookUp[5].exist    = NO;
        
        _selectorLookUp[6].selector = @selector(tableView:commitEditingStyle:forRowAtIndexPath:);
        _selectorLookUp[6].exist    = NO;
        
        _selectorLookUp[7].selector = @selector(tableView:moveRowAtIndexPath:toIndexPath:);
        _selectorLookUp[7].exist    = NO;
        
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (void)reloadData {
	if (!_dynamicHeight) {
		Class klass = [self.delegate tableView:self classForCellatIndexPath:nil];
		self.rowHeight = [klass cellHeightWithData:0 reuseIdentifier:nil tableView:self];
	}
    self.data = [self.pxDataSource dataForTableView:self];
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

#pragma mark - Shared Table Handling
- (NSString*)identifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    int cellPosition = PxCellPositionMiddle;
    int rowCount = [self tableView:nil numberOfRowsInSection:indexPath.section];
	int sectionCount = [self numberOfSectionsInTableView:nil];
	
	if(indexPath.row == rowCount-1 && indexPath.section == sectionCount-1) {cellPosition |= PxCellPositionLast;}
    if(indexPath.row == rowCount-1 && indexPath.row == 0) {cellPosition |= PxCellPositionSingle;}
    if(indexPath.row == 0 && indexPath.section == 0) {cellPosition |= PxCellPositionFirst;}
    if(indexPath.row == rowCount-1){cellPosition |= PxCellPositionBottom;}
    if(indexPath.row == 0) {cellPosition |= PxCellPositionTop;}
    
    NSString *identifier = [NSString stringWithFormat:@"%d_%@", cellPosition, NSStringFromClass([self.delegate tableView:self classForCellatIndexPath:indexPath])];
    
    if (self.alternating) {
        return [identifier stringByAppendingFormat:@"_%d", indexPath.row%2];
    }
    
    if (_dynamicIdentifier) {
        identifier = [self.pxDataSource tableView:self identfierForCellAtIndexPath:indexPath identifier:identifier];
    }
    
    return identifier;
}

- (float)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dynamicHeight) {
        Class klass = [self.delegate tableView:self classForCellatIndexPath:indexPath];
        return [klass cellHeightWithData:[self dataForCellAtIndexPath:indexPath] reuseIdentifier:[self identifierForCellAtIndexPath:indexPath] tableView:self];
    }else {
        return self.rowHeight;
    }
}

- (unsigned int)numberOfRowsInSection:(unsigned int)section useData:(BOOL)useData {
    if (useData) {
        return [self tableView:self numberOfRowsInSection:section];
    }
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierForCellAtIndexPath:indexPath];
    PxTableViewCell *cell = (PxTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
	if (cell == nil) {
        Class klass = [self.delegate tableView:self classForCellatIndexPath:indexPath];
        cell = [[klass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier tableView:tableView];
        [cell setDelegate:self.delegate];
	}
	[cell setData:[self dataForCellAtIndexPath:indexPath]];
	return cell;
}

- (void)removeEntriesFromTable:(NSArray *)entries {
    NSMutableArray *indexPaths = [self removeEntriesFromData:entries];
    NSIndexSet *indexSet = [self removeEmptySectionsFromData];
    
    [indexPaths deleteIf:^BOOL(NSIndexPath *path) {
        return [indexSet containsIndex:path.section];
    }];
    
    if ([self.pxDataSource respondsToSelector:@selector(tableView:didUpdateData:)]) {
        [self.pxDataSource tableView:self didUpdateData:self.data];
    }
    
    if ([indexPaths count] > 0 || [indexSet count] > 0) {
        [self beginUpdates];
    
        if ([indexSet count] > 0) {
            [self deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
        if ([indexPaths count] > 0) {
            [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [self endUpdates];
        if ([self.pxDataSource respondsToSelector:@selector(tableViewDidStartDeleteAnimation:)]) {
            [self.pxDataSource tableViewDidStartDeleteAnimation:self];
        }
    }
}

#pragma mark - Plain/Sectional Switches
- (id)dataForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        if (self.sectional) {
            return [self sectionalDataForCellAtIndexPath:indexPath];
        }else {
            return [self plainDataForCellAtIndexPath:indexPath];
        }
    }
    return nil;
}

- (id)dataForSection:(unsigned int)section {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sectional) {
        return [self sectionalNumberOfSectionsInTableView:tableView];
    }else {
        return [self plainNumberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectional) {
        return [self sectionalTableView:tableView numberOfRowsInSection:section];
    }else {
        return [self plainTableView:tableView numberOfRowsInSection:section];
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

#pragma mark - Plain Table Handling
- (id)plainDataForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.data objectAtIndex:indexPath.row];
}

- (NSIndexPath *)plainIndexPathForItem:(id)item {
    return [NSIndexPath indexPathForRow:[self.data index:^BOOL(id obj) {
        return obj == item;
    }] inSection:0];
}

- (NSInteger)plainNumberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)plainTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.data count];
}

- (NSMutableArray *)plainRemoveEntriesFromData:(NSArray *)entries {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[entries count]];
    NSMutableArray *lookUp = [entries mutableCopy];
    self.data = [self.data collectWithIndex:^id(id obj, unsigned int index) {
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
- (id)sectionalDataForCellAtIndexPath:(NSIndexPath *)indexPath {
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

- (int)sectionalTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[(PxPair*)[self.data objectAtIndex:section] second] count];
}

- (int)sectionalNumberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data count];
}

- (NSMutableArray *)sectionalRemoveEntriesFromData:(NSArray *)entries {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *lookUp = [entries mutableCopy];
    
    for (int i = 0; i < [self.data count]; i++) {
        PxPair *pair = [self.data objectAtIndex:i];
        [pair setSecond:[(NSArray*)[pair second] collectWithIndex:^id(id obj, unsigned int index) {
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
    [self setData:[self.data collectWithIndex:^id(PxPair *pair, unsigned int section) {
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
- (void)setPxDataSource:(id<PxDataTableDataSource>)dataSource {
    id old = _pxDataSource;
    if (dataSource != _pxDataSource) {
        _pxDataSource = dataSource;
        _dynamicIdentifier = [dataSource respondsToSelector:@selector(tableView:identfierForCellAtIndexPath:identifier:)];
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

- (id<PxDataTableDelegate>)delegate {
    return (id<PxDataTableDelegate>)[super delegate];
}

- (void)setDelegate:(id<PxDataTableDelegate>)delegate {
    if (delegate) {
        _dynamicHeight = [delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
        if (!_dynamicHeight) {
            Class klass = [delegate tableView:self classForCellatIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            self.rowHeight = [klass cellHeightWithData:0 reuseIdentifier:nil tableView:self];
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
