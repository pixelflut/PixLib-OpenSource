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
//  PxTableView.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxTableView.h"
#import "PxCellDeleteLayer.h"

@interface PxTableView ()
@property (nonatomic, strong) PxCellDeleteLayer *deleteLayer;

@end

@implementation PxTableView
@synthesize deleteLayer = _deleteLayer;

@synthesize locked = _locked;
@synthesize shouldLockTable = _shouldLockTable;
@synthesize shouldLockTableWithoutCurrentCell = _shouldLockTableWithoutCurrentCell;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:style];
	if(self) {
		_shouldLockTable = YES;
	}
	return self;
}

- (void)removeDeleteLayer {
	_locked = NO;
    [_deleteLayer removeFromSuperview];
    [_deleteLayer setCell:nil];
}

- (void)lockTable:(PxTableViewCell<PxEditableCell> *)cell {
	if(_shouldLockTable) {
		if (!_deleteLayer) {
			_deleteLayer = [[PxCellDeleteLayer alloc] initWithFrame:self.frame];
			[_deleteLayer setTarget:self action:@selector(shouldHideDelete:)];
		}
		_locked = YES;
		[_deleteLayer setCell:cell];
		[_deleteLayer setIgnoreCurrentCellTouch:_shouldLockTableWithoutCurrentCell];
		[[self superview] insertSubview:_deleteLayer aboveSubview:self];
	}
}

- (void)shouldHideDelete:(PxCellDeleteLayer *)layer {
    [layer.cell hideDelete];
    [self removeDeleteLayer];
}

- (void)reloadData {
    [self removeDeleteLayer];
    [super reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self removeDeleteLayer];
    [super setEditing:editing animated:animated];
}

@end
