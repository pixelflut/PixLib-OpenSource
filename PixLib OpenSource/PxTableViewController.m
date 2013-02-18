//
//  PxTableViewController.m
//  PixLib
//
//  Created by Jonathan Cichon on 16.11.11.
//  Copyright (c) 2011 pixelflut GmbH. All rights reserved.
//

#import "PxTableViewController.h"
#import "PxCore.h"
#import "PxTableViewCell.h"
#import <objc/runtime.h>

@implementation PxTableViewController
@synthesize data            = _data;
@synthesize table           = _table;

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
    [self.table reloadData];
}

- (void)loadTable {
    _table = [[[self.class tableViewClass] alloc] initWithFrame:CGRectFromSize(self.view.frame.size) style:[[self class] tableViewStyle]];
    [_table setDefaultResizingMask];
    [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_table setSectional:[[self class] sectional]];
    [_table setPxDataSource:self];
    [_table setDelegate:self];
    [self.view addSubview:_table];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_table setDelegate:nil];
    [_table setPxDataSource:nil];
    _table = nil;
}

- (void)setData:(NSArray *)data {
    [self setData:data reload:YES];
}

- (void)setData:(NSArray *)data reload:(BOOL)reload {
    if (data != _data) {
        _data = data;
        if (reload) {
            [self.table reloadData];
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
    return [self.table heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(PxDataTableView *)tableView didUpdateData:(NSArray *)data {
    [self setData:data reload:NO];
}

@end
