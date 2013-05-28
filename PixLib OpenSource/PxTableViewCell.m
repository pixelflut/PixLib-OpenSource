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
//  PxTableViewCell.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxTableViewCell.h"

@implementation PxTableViewCell
@synthesize table = _table;
@synthesize delegate = _delegate;
@synthesize data = _data;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.table = tableView;
        [self buildUI];
    }
    return self;
}

+ (CGFloat)cellHeightWithData:(id)data reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView {
    [NSException raise:@"Not Implemented Error" format:@"<%@> You have to implement the Method +cellHeightWithData:reuseIdentifier:tableView: in Subclasses", [self class]];
    return 0;
}

- (void)buildUI {
    [NSException raise:@"Not Implemented Error" format:@"<%@> You have to implement the Method - (void)buildUI in Subclasses", [self class]];
}

- (void)setUI {
    [NSException raise:@"Not Implemented Error" format:@"<%@> You have to implement the Method - (void)setUI in Subclasses", [self class]];
}

- (void)setData:(id)data {
	[self setData:data setUI:YES];
}

- (void)setData:(id)data setUI:(BOOL)setUI {
    if (_data != data) {
        _data = data;
    }
    if(setUI) [self setUI];
}

- (PxCellPosition)cellPosition {
    return [self.reuseIdentifier intValue];
}

- (BOOL)hasPosition:(PxCellPosition)position {
    return hasPosition(self.reuseIdentifier, position);
}

@end
