//
//  PxTableViewController.h
//  PixLib
//
//  Created by Jonathan Cichon on 16.11.11.
//  Copyright (c) 2011 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxViewController.h"
#import "PxDataTableView.h"

@interface PxTableViewController : PxViewController <PxDataTableDelegate, PxDataTableDataSource>
@property(nonatomic, strong) NSArray *data;
@property(nonatomic, strong) PxDataTableView *table;

+ (BOOL)dynamicHeight;
+ (BOOL)alternating;
+ (BOOL)sectional;
+ (UITableViewStyle)tableViewStyle;
+ (Class)tableViewClass;

- (void)setData:(NSArray *)data reload:(BOOL)reload;

@end
