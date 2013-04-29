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
//  PxDataTableView.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxTableView.h"

@protocol PxDataTableDelegate;
@protocol PxDataTableDataSource;

@interface PxDataTableView : PxTableView
@property (nonatomic, assign) BOOL alternating;
@property (nonatomic, assign) BOOL sectional;
@property (nonatomic, weak) id<PxDataTableDataSource> pxDataSource;
@property (nonatomic, assign) id<PxDataTableDelegate> delegate;
@property (nonatomic, assign) id<UITableViewDataSource> dataSource OBJC2_UNAVAILABLE;

- (NSString *)identifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (id)dataForCellAtIndexPath:(NSIndexPath *)indexPath;
- (id)dataForSection:(unsigned int)section;
- (float)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(id)item;
- (unsigned int)numberOfRowsInSection:(unsigned int)section useData:(BOOL)useData;

- (void)removeEntriesFromTable:(NSArray *)entries;

@end


@protocol PxDataTableDelegate <UITableViewDelegate>
- (Class)tableView:(PxDataTableView *)tableView classForCellAtIndexPath:(NSIndexPath *)indexPath;
@end


@protocol PxDataTableDataSource <NSObject>
- (NSArray *)dataForTableView:(PxDataTableView *)tableView;

@optional
- (NSString *)tableView:(PxDataTableView *)tableView identfierForCellAtIndexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier;

- (void)tableView:(PxDataTableView *)tableView didUpdateData:(NSArray *)data;
- (void)tableViewDidStartDeleteAnimation:(PxDataTableView *)tableView;

#pragma mark - UITableViewDataSource forwarding
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end