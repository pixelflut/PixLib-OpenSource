//
//  PxCollectionReusableView.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 05.03.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxCollectionReusableView.h"


@interface PxCollectionReusableView ()
@property (nonatomic, assign) BOOL didBuildUI;

- (void)setCellPosition:(PxCellPosition)position;

@end

@implementation PxCollectionReusableView

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

@end
