//
//  PxCollectionReusableView.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 05.03.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxCollectionReusableView.h"

@implementation PxCollectionReusableView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		[self buildUI];
	}
	return self;
}

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

- (PxCellPosition)cellPosition {
    return [self.reuseIdentifier intValue];
}

- (BOOL)hasPosition:(PxCellPosition)position {
    NSInteger identifier = [self.reuseIdentifier integerValue];
    return (identifier & position || identifier == position);
}

@end
