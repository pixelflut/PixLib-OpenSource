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
//  PxTableViewController.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <UIKit/UIKit.h>
#import "PxViewController.h"
#import "PxDataTableView.h"

/**
 The PxTableViewController class creates a controller object that manages a table view. It is intendet to be subclassed, and most of its behavior can be changed by overwritting certain methods.
 */
@interface PxTableViewController : PxViewController <PxDataTableDelegate, PxDataTableDataSource>

#pragma mark - Properties
/** @name Properties */

/** The data the receiver should present.
 
 If _sectional_ is **false**, each element from the array is represented by one cell. 
 
 If _sectional_ is **true**, each element from the array is represented by one section. The receiver expects the array to contain elements of type PxPair with [first]([PxPair first]) used as an userinfo for handling section headers, [second]([PxPair second]) has to be an array with elements to represent the cells of the section.
 
 Assigning a new array to this propertie automatically reloads the table.
 @see sectional
 */
@property(nonatomic, strong) NSArray *data;

/** Returns the table view managed by the controller object. */
@property(nonatomic, readonly, strong) PxDataTableView *tableView;

#pragma mark - Configurate Table Appeareance
/** @name Configurate Table Appeareance */

/** Returns either or not the table contains cells with different heights.
 
 The default implementation returns **NO**. Subclasses should overwrite this method to get different behavior. **YES** should only used when needed, as dynamic cell heights can have a huge impact on the performance when the table contains a large amount of rows.
 @return Either or not the table contains cells with different heights.
 */
+ (BOOL)dynamicHeight;

/** Returns either or not the reuseidentifier for cells should contain a alternating flag.
 
 The default implementation returns **NO**. Subclasses should overwrite this method to get different behavior.
 @return Either or not the reuseidentifier for cells should contain a alternating flag.
 */
+ (BOOL)alternating;

/** Returns either or not the table can have more than one sections.
 
 The default implementation returns **NO**. Subclasses should overwrite this method to get different behavior. Sectional and non-sectional tables expect different data-layouts.
 @return Either or not the table can have more than one sections.
 @see setData:
 */
+ (BOOL)sectional;

/** Returns the style for the table.
 
 The default implementation returns **UITableViewStylePlain**. Subclasses should overwrite this method to get different behavior.
 @return The style for the table.
 */
+ (UITableViewStyle)tableViewStyle;

/** Returns the class for the table.
 
 The default implementation returns **[PxDataTableView class]**. Subclasses should overwrite this method to get different behavior.
 @return The style for the table.
 */
+ (Class)tableViewClass;

#pragma mark - Providing Data
/** @name Providing Data */

/** Setting the property data.
 @param reload If **YES** the tableView is automatically reloaded, otherwise only data is set and the tableView is not reloaded.
 @see setData:
 */
- (void)setData:(NSArray *)data reload:(BOOL)reload;

#pragma mark - PxDataTableDelegate
/** @name PxDataTableDelegate */

/** Needs to be overwritten by sublcasses. The default implementation raises an Exception. */
- (Class)tableView:(PxDataTableView *)tableView classForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
