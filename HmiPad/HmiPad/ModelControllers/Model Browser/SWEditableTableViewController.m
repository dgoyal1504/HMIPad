//
//  SWEditableTableViewController.m
//  HmiPad
//
//  Created by Joan Martin on 8/21/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWEditableTableViewController.h"
#import "SWKeyboardListener.h"

#import "SWRevealController.h"

@interface SWEditableTableViewController ()
{
    BOOL _presentToolbarWhenAppearing;
}



@end

@implementation SWEditableTableViewController
{
    UIBarButtonItem *_addBarButtonItem;
    UIBarButtonItem *_configureBarButtonItem;
    UIBarButtonItem *_actionBarButtonItem; 
    UIBarButtonItem *_trashBarButtonItem;
    
}


#pragma mark protocol SWModelBrowserViewController

//@synthesize browsingStyle = _browsingStyle;
//@synthesize delegate = _delegate;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject;
{
    return self;  // override in subclases
}

- (id)identifiyingObject
{
    return nil;   // overrride in subclases
}

#pragma mark controller lifecycle


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        _presentToolbarWhenAppearing = NO;
    }
    return self;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self revalidateToolbarButtons];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITableView *table = self.tableView;
    table.allowsMultipleSelection = NO;
    table.allowsMultipleSelectionDuringEditing = YES;
    
    if ( _presentToolbarWhenAppearing )
    {
        _addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        _configureBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"740-gear-toolbar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(configure:)];
        
        //_configureBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-25.png"] style:UIBarButtonItemStylePlain target:self action:@selector(configure:)];
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
        _trashBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trash:)];
    
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
        self.toolbarItems = [NSArray arrayWithObjects:_addBarButtonItem, flexible, _configureBarButtonItem, flexible, _actionBarButtonItem, flexible, _trashBarButtonItem, nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self beginAdjustingInsetsForKeyboard];
    
    BOOL hidden = !_presentToolbarWhenAppearing;
    [self.navigationController setToolbarHidden:hidden animated:NO];
    
    [self revalidateToolbarButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    //[self.navigationController setToolbarHidden:!self.editing animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self endAdjustingInsetsForKeyboard];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Public Methods

- (void)add:(id)sender
{
    // Override in subclasses
}

- (void)configure:(id)sender
{
    // Override in subclasses
}

- (void)action:(id)sender
{
    // Override in subclasses
}

- (void)trash:(id)sender
{
    // Override in subclasses
}


- (BOOL)validateAddButton
{
    // Override in subclass
    return YES;
}


- (BOOL)validateConfigureButton
{
    // Override in subclass
    return YES;
}

- (BOOL)validateActionButton
{
    // Override in subclass
    return YES;
}

- (BOOL)validateTrashButton
{
    // Override in subclass
    return YES;
}

//- (void)revalidateToolbarButtons
//{
//    [self _currentSelectionDidChange:[self.tableView indexPathsForSelectedRows]];
//}

- (void)revalidateToolbarButtons
{
    if ( _presentToolbarWhenAppearing )
        [self _performToolbarButtonsValidation];
}


- (void)setBrowsingStyle:(SWModelBrowsingStyle)browsingStyle
{
    _browsingStyle = browsingStyle;
    _presentToolbarWhenAppearing = (browsingStyle == SWModelBrowsingStyleManagement);
    
    UINavigationItem *navItem = self.navigationItem;   // evitem cridades redundants
    UIBarButtonItem *editButton = self.editButtonItem;
    
    if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        if (navItem.rightBarButtonItem == editButton)
            navItem.rightBarButtonItem = nil;
    }
    else
        navItem.rightBarButtonItem = editButton;
}



- (void)removeFromContainerController
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSInteger selfIndex = [viewControllers indexOfObjectIdenticalTo:self];
    
    if (selfIndex > 0)
    {
        NSInteger previousIndex = selfIndex - 1;
        UINavigationController *previousController = [viewControllers objectAtIndex:previousIndex];
        [self.navigationController popToViewController:previousController animated:YES];
    }
    else // es el de baix de tot (index 0) i per tant nomes queda eliminar-lo del reveal controller
    {
        SWRevealViewController *revealController = [self revealViewController];
        [revealController setFrontViewPosition:FrontViewPositionRightMostRemoved animated:YES];
        [revealController setFrontViewController:nil];
    }
}





- (void)willRemoveObject:(SWObject *)object
{
//    SWDocumentModel *docModel = _modelObject.docModel;
//    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:docModel];
//    
//    //[manager dismissModelConfiguratorForObject:_configuringObject animated:YES];
//    [manager removeModelConfiguratorForObject:_modelObject animated:YES];
//    
//    SWRevealController *revealController = (id)[self revealViewController];
//    UIViewController *topViewController = [revealController topViewController];
//    if ( topViewController == self )
//        [revealController setFrontViewPosition:FrontViewPositionRightMostRemoved animated:YES];
}


#pragma mark - Private Methods


- (BOOL)_validateSingleSection
{
    NSArray *selection = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *lastIndexPath = selection.lastObject;
    if ( lastIndexPath == nil )
        return YES;     // <-- atencio considerem valid si no hi ha res seleccionat
        
    NSInteger section = lastIndexPath.section;
    for ( NSIndexPath *indexPath in selection )
    {
        if ( indexPath.section != section )
            return NO;
    }
    
    return YES;
}


- (BOOL)_validateHasSelectedRows
{
    NSArray *selection = [self.tableView indexPathsForSelectedRows];
    return selection.count > 0;
}


- (void)_performToolbarButtonsValidation
{
    BOOL isSingleSection = [self _validateSingleSection];
    BOOL hasSelectedRows = [self _validateHasSelectedRows];
    BOOL isEditing = self.tableView.editing;

    _addBarButtonItem.enabled = isSingleSection && [self validateAddButton];
    _actionBarButtonItem.enabled = isSingleSection && [self validateActionButton];
    _configureBarButtonItem.enabled = (isSingleSection && hasSelectedRows) && [self validateConfigureButton];
    _trashBarButtonItem.enabled = (isSingleSection && hasSelectedRows && isEditing) && [self validateTrashButton];
}


//- (void)_currentSelectionDidChange:(NSArray*)selection
//{
//    NSInteger selectionCount = selection.count;
//    
//    BOOL hasSelection = selectionCount > 0;
//    BOOL isEditing = self.tableView.editing;
//    
//    _addBarButtonItem.enabled = [self validateAddButton];
//    _configureBarButtonItem.enabled = hasSelection;
//    
//    if (hasSelection)
//        _actionBarButtonItem.enabled = YES;
//    else
//        _actionBarButtonItem.enabled = [self validateActionButton];
//    
//    _trashBarButtonItem.enabled = isEditing && hasSelection;
//}




#pragma mark - Table Selection


- (NSMutableIndexSet*)indexSetForItemsInSelectedRowsWithSection:(NSInteger)aSection
{
    UITableView *tableView = self.tableView;
    NSArray *indexPaths = [tableView indexPathsForSelectedRows];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for ( NSIndexPath *indexPath in indexPaths )
    {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        if ( section == aSection )
            [indexSet addIndex:row];
    }
    return indexSet;
}


- (void)markItemsInSection:(NSInteger)section atIndexes:(NSIndexSet*)indexes scrollToVisible:(BOOL)scroll animated:(BOOL)animated
{
    __block NSIndexPath *indexPath = nil;
    UITableView *table = self.tableView;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        NSInteger row = idx;
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
    
    if ( scroll )
        [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
    
    [self revalidateToolbarButtons];
}


- (void)unmarkItemsInSection:(NSInteger)section atIndexes:(NSIndexSet *)indexes
{
    UITableView *table = self.tableView;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        NSInteger row = idx;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [table deselectRowAtIndexPath:indexPath animated:NO];
    }];
    
    [self revalidateToolbarButtons];
}




#pragma mark - UITableViewDelegate

/* ELIMINAR !! */

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //if (tableView.editing)
//    //    [self _currentSelectionDidChange:[tableView indexPathsForSelectedRows]];
//}
//
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //if (tableView.editing)
//    //    [self _currentSelectionDidChange:[tableView indexPathsForSelectedRows]];
//}

@end
