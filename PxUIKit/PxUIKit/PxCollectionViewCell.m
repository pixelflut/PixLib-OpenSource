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
//  PxCollectionViewCell.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 31.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxCollectionViewCell.h"

@interface PxCollectionViewCell ()
@property (nonatomic, assign) BOOL didBuildUI;

- (void)setCellPosition:(PxCellPosition)position;

@end

@implementation PxCollectionViewCell

- (void)setData:(id)data {
    [self setData:data setUI:YES];
}

- (void)setData:(id)data setUI:(BOOL)setUI {
    if (data != _data) {
        _data = data;
        if(setUI) {
            [self setUI];
        }
    }
}

- (void)setCellPosition:(PxCellPosition)position {
    if (_cellPosition == position) {
        _cellPosition = position;
        if (_didBuildUI) {
            [self setUI];
        }
    }
    if (!_didBuildUI) {
        _didBuildUI = YES;
        [self buildUI];
    }
}

- (BOOL)hasPosition:(PxCellPosition)position {
    return (_cellPosition & position || _cellPosition == position);
}

- (void)didBeginInteractiveMovement {
    
}

- (void)didEndInteractiveMovement {
    
}

@end
