//
//  SWTableViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/22/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

/*
#import "SWTableViewController.h"

static NSString *addSourceCellIdentifier = @"addSourceCellIdentifier";

@implementation SWTableViewController
@synthesize insertCellText = _insertCellText;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _insertCellText = @"Add";
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _insertCellText = @"Add";
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _editing = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                                                           target:self 
                                                                                           action:@selector(edit:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Main Methods

- (IBAction)edit:(id)sender
{
    _editing = !self.tableView.editing;
    
    BOOL _customEditing = NO;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.reuseIdentifier isEqualToString:addSourceCellIdentifier]) {
        _customEditing = YES;
    }
    
    if (!_customEditing != _editing)
        return;
    
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    
    if (_editing) {
        // Not Editing ===> Editing
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                              target:self 
                                                                              action:@selector(edit:)];
        
    
        [self.navigationItem setRightBarButtonItem:done animated:YES];
        
    } else {
        // Editing ===> Not Editing
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                              target:self 
                                                                              action:@selector(edit:)];
        [self.navigationItem setRightBarButtonItem:edit animated:YES];
    }
    
    [self.tableView setEditing:_editing animated:YES];
}

- (NSInteger)_numberOfSectionsInTableView:(UITableView *)tableView
{
    // Subclasses must override this method
    return 2;
}

- (NSInteger)_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Subclasses must override this method
    return 3;
}

- (UITableViewCell*)_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addSourceCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addSourceCellIdentifier];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)_tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)_tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method
    return YES;
}

- (void)_tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Subclasses must override this method
}

// Delegate

- (void)_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method
}

- (NSIndexPath*)_tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method
    return indexPath;
}

- (BOOL)_tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method
    return YES;
}

- (void)_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses must override this method
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = [self _numberOfSectionsInTableView:tableView];
    
    if (_editing)
        sections++;
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (_editing) {
        if (section == 0)
            rows = 1;
        else 
            rows = [self _tableView:tableView numberOfRowsInSection:(section-1)];
    } else {
        rows = [self _tableView:tableView numberOfRowsInSection:section];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *addSourceCellIdentifier = @"addSourceCellIdentifier";
    
    UITableViewCell *cell = nil;
    
    if (_editing) {
        
        if (indexPath.section == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:addSourceCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addSourceCellIdentifier];
                cell.textLabel.text = _insertCellText;
            }
            return cell;
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            cell = [self _tableView:tableView cellForRowAtIndexPath:_indexPath];
        }
    } else {
        cell = [self _tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle style;
    
    if (_editing) {
        if (indexPath.section == 0) {
            style = UITableViewCellEditingStyleInsert;
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            style = [self _tableView:tableView editingStyleForRowAtIndexPath:_indexPath];
        }
    } else {
        style = [self _tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    
    return style;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit;
    
    if (_editing) {
        if (indexPath.section == 0) {
            canEdit = YES;
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            canEdit = [self _tableView:tableView canEditRowAtIndexPath:_indexPath];
        }
    } else {
        canEdit = [self _tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_editing) {
        if (indexPath.section == 0) {
            [self _tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:nil];
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            [self _tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:_indexPath];
        }
    } else {
        [self _tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }

}

// Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_editing) {
        if (indexPath.section == 0) {
            [self _tableView:tableView didSelectRowAtIndexPath:nil];
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            [self _tableView:tableView didSelectRowAtIndexPath:_indexPath];
        }
    } else {
        [self _tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *returnIndexPath = nil;
    
    if (_editing) {
        if (indexPath.section == 0) {
            returnIndexPath = nil;
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            returnIndexPath = [self _tableView:tableView willSelectRowAtIndexPath:_indexPath];
        }
    } else {
        returnIndexPath = [self _tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    
    return returnIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldIndent;
    
    if (_editing) {
        if (indexPath.section == 0) {
            shouldIndent = YES;
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            shouldIndent = [self _tableView:tableView shouldIndentWhileEditingRowAtIndexPath:_indexPath];
        }
    } else {
        shouldIndent = [self _tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    
    return shouldIndent;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_editing) {
        if (indexPath.section == 0) {
            [self _tableView:tableView willDisplayCell:cell forRowAtIndexPath:nil];
        } else {
            NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            [self _tableView:tableView willDisplayCell:cell forRowAtIndexPath:_indexPath];
        }
    } else {
        [self _tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

@end


@implementation UITableView (SWTableViewController)

- (NSIndexPath*)_indexPathForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = nil;
    
    NSIndexPath *realIndexPath = [self indexPathForCell:cell];
    
    BOOL _editing = self.editing;
    
    if (_editing) {
        indexPath = [NSIndexPath indexPathForRow:realIndexPath.row inSection:realIndexPath.section-1];
    } else {
        indexPath = realIndexPath;
    }
    
    return indexPath;
}

- (void)_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    BOOL _editing = self.editing;
    
    if (_editing) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
        [self selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    } else {
        [self selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    }
}


- (void)_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    BOOL _editing = self.editing;
    
    if (_editing) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
        [self deselectRowAtIndexPath:indexPath animated:animated];
    } else {
        [self deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void)_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    BOOL _editing = NO;
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.reuseIdentifier isEqualToString:addSourceCellIdentifier]) {
        _editing = YES;
    }
    
    if (!_editing) {
        [self insertSections:sections withRowAnimation:animation];
        return;
    }
    
    NSMutableIndexSet *_sections = [NSMutableIndexSet indexSet];
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [_sections addIndex:idx+1];
    }];
    
    [self insertSections:_sections withRowAnimation:animation];
}

- (void)_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    BOOL _editing = NO;
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.reuseIdentifier isEqualToString:addSourceCellIdentifier]) {
        _editing = YES;
    }
    
    if (!_editing) {
        [self deleteSections:sections withRowAnimation:animation];
        return;
    }
    
    NSMutableIndexSet *_sections = [NSMutableIndexSet indexSet];
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [_sections addIndex:idx+1];
    }];
    
    [self deleteSections:_sections withRowAnimation:animation];
}

- (void)_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    BOOL _editing = NO;
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.reuseIdentifier isEqualToString:addSourceCellIdentifier]) {
        _editing = YES;
    }
    
    if (!_editing) {
        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        return;
    } 
    
    NSMutableArray *_indexPaths = [NSMutableArray array];
    for (NSIndexPath *ip in indexPaths) {
        NSIndexPath *_ip = [NSIndexPath indexPathForRow:ip.row inSection:ip.section+1];
        [_indexPaths addObject:_ip];
    }
    
    [self insertRowsAtIndexPaths:_indexPaths withRowAnimation:animation];
}

- (void)_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    BOOL _editing = NO;
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.reuseIdentifier isEqualToString:addSourceCellIdentifier]) {
        _editing = YES;
    }
    
    if (!_editing) {
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        return;
    } 
    
    NSMutableArray *_indexPaths = [NSMutableArray array];
    for (NSIndexPath *ip in indexPaths) {
        NSIndexPath *_ip = [NSIndexPath indexPathForRow:ip.row inSection:ip.section+1];
        [_indexPaths addObject:_ip];
    }
    
    [self deleteRowsAtIndexPaths:_indexPaths withRowAnimation:animation];
}
@end
*/