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
//  PxTableViewController.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxTableViewController.h"
#import "PxCore.h"
#import "PxTableViewCell.h"
#import <objc/runtime.h>

@implementation PxTableViewController

+ (void)initialize {
    if ([[self class] dynamicHeight] && ![[self class] instancesRespondToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        Method __template__ = class_getInstanceMethod([self class], @selector(__template__tableView:heightForRowAtIndexPath:));
        IMP __imp__ = method_getImplementation(__template__);
        class_addMethod([self class], @selector(tableView:heightForRowAtIndexPath:), __imp__, method_getTypeEncoding(__template__));
    }
}

+ (BOOL)alternating {
    return NO;
}

+ (BOOL)sectional {
    return NO;
}

+ (BOOL)dynamicHeight {
    return NO;
}

+ (Class)tableViewClass {
    return [PxDataTableView class];
}

+ (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}

- (void)loadView {
    [self loadStdView];
    [self loadTable];
}

- (void)updateView {
    [self.tableView reloadData];
}

- (void)loadTable {
    _tableView = [[[self.class tableViewClass] alloc] initWithFrame:CGRectFromSize(self.view.frame.size) style:[[self class] tableViewStyle]];
    [_tableView setDefaultResizingMask];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setSectional:[[self class] sectional]];
    [_tableView setPxDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_tableView setDelegate:nil];
    [_tableView setPxDataSource:nil];
    _tableView = nil;
}

- (void)setData:(NSArray *)data {
    [self setData:data reload:YES];
}

- (void)setData:(NSArray *)data reload:(BOOL)reload {
    if (data != _data) {
        _data = data;
        if (reload) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Table Handling
- (Class)tableView:(PxDataTableView *)tableView classForCellatIndexPath:(NSIndexPath *)indexPath {
    [NSException raise:@"Not Implemented Error" format:@"<%@> You have to implement the Method - (Class)tableView:(PxDataTableView *)tableView classForCellatIndexPath:(NSIndexPath *)indexPath in Subclasses", [self class]];
    return nil;
}

- (NSArray *)dataForTableView:(PxDataTableView *)tableView {
    return self.data;
}

- (CGFloat)__template__tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(PxDataTableView *)tableView didUpdateData:(NSArray *)data {
    [self setData:data reload:NO];
}

@end
