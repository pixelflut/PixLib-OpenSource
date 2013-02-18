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
//  PxTableViewCell.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>

typedef enum {
    PxCellPositionMiddle    = 0,
    PxCellPositionTop       = 1<<0,
    PxCellPositionBottom    = 1<<1,
    PxCellPositionFirst     = 1<<3,
    PxCellPositionLast      = 1<<4,
    PxCellPositionSingle    = 1<<5,
} PxCellPosition;

#define hasPosition(__identifier__, __position__) ([__identifier__ intValue] & __position__)

@interface PxTableViewCell : UITableViewCell
@property(nonatomic, weak) UITableView *table;
@property(nonatomic, assign) id delegate;
@property(nonatomic, strong) id data;

+ (CGFloat)cellHeightWithData:(id)data reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView;
- (void)buildUI;
- (void)setUI;

- (void)setData:(id)data setUI:(BOOL)setUI;

- (PxCellPosition)cellPosition;
- (BOOL)hasPosition:(PxCellPosition)position;

@end