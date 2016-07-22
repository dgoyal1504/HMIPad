//
//  SWTableViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/22/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

//***************************************************************//
//***************************************************************//
//**                                                           **//
//**                    !!!!  WARNING  !!!!                    **//
//** This class is not finished yet. Be careful when using it. **//
//**                                                           **//
//***************************************************************//
//***************************************************************//


/*
@interface SWTableViewController : UITableViewController {
    BOOL _editing;
}

- (IBAction)edit:(id)sender;

@property (nonatomic, strong) NSString *insertCellText;

// -- Subclasses must override these methods -- //

// Data Source Protocol
- (NSInteger)_numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell*)_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)_tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)_tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)_tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

// Delegate Protocol
- (NSIndexPath*)_tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)_tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UITableView (SWTableViewController)

// Accessing Cells and Sections
- (NSIndexPath*)_indexPathForCell:(UITableViewCell *)cell;

// Managing Selections
- (void)_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

// Inserting, Deleting, and Moving Rows and Sections
- (void)_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

// -------- NOT DONE YET --------- //

// Configuring a Table View
- (NSInteger)_numberOfSections;
- (NSInteger)_numberOfRowsInSection:(NSInteger)section;

// Accessing Cells and Sections
- (UITableViewCell *)_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)_indexPathForRowAtPoint:(CGPoint)point;
- (NSArray*)_indexPathsForRowsInRect:(CGRect)rect;
- (NSArray*)_visibleCells;
- (NSArray*)_indexPathsForVisibleRows;

// Scrolling the Table View
- (void)_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)_scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Managing Selections
- (NSIndexPath*)indexPathForSelectedRow;
- (NSArray*)_indexPathsForSelectedRows;

// Inserting, Deleting, and Moving Rows and Sections
- (void)_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)_moveSection:(NSInteger)section toSection:(NSInteger)newSection;

// Managing the Editing of Table Cells
- (void)_setEditing:(BOOL)editing;
- (void)_setEditing:(BOOL)editing animated:(BOOL)animated;

// Reloading the Table View
//- (void)_reloadData;
- (void)_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_reloadSectionIndexTitles;

// Accessing Drawing Areas of the Table View
- (CGRect)_rectForSection:(NSInteger)section;
- (CGRect)_rectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)_rectForFooterInSection:(NSInteger)section;
- (CGRect)_rectForHeaderInSection:(NSInteger)section;

// Registering Nib Objects for Cell Reuse
//- (void)_registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

@end
 
 */
