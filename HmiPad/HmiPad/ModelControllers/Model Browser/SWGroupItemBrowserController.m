//
//  SWPageBrowserController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWGroupItemBrowserController.h"
#import "SWGroupItem.h"
#import "SWItem.h"

//#import "SWDocument.h"
#import "SWDocumentModel.h"

#import "SWItemCell.h"
#import "SWTableSectionHeaderView.h"
#import "SWTableViewMessage.h"

#import "SWNavBarTitleView.h"

#import "SWObjectBroswerController.h"
#import "SWModelManager.h"
//#import "SWConfigurationController.h"

//#import "SWPage.h"
//#import "SWModelBrowserProtocols.h"
#import "SWAddObjectViewController.h"

#import "SWObjectDescription.h"
#import "SWPropertyDescriptor.h"

//#import "SWFloatingPopoverManager.h"
#import "SWColor.h"

#import "SWPasteboardTypes.h"
#import "SWAlertCenter.h"

//typedef enum {
//    ActionSheetTypeEmpty = 0,
//    ActionSheetTypeSelection = 1 << 0,
//    ActionSheetTypePaste     = 1 << 1,
//    ActionSheetTypeGroup     = 1 << 2,
//    ActionSheetTypeUngroup   = 1 << 3,
//} ActionSheetType;


typedef enum {
    ActionNone = 0,
    ActionCopy = 1,
    ActionTotalActions,
} Action;
// ^-- Atencio no canviar l'ordre

enum Sections
{
    SectionGroup = 0,
    SectionItems,
    SectionsCount
};

@interface SWGroupItemBrowserController() <GroupItemObserver, DocumentModelObserver, UIActionSheetDelegate, SWAddObjectViewControllerDelegate>
@end

@implementation SWGroupItemBrowserController
{
    UIActionSheet *_actionSheet;
    NSArray *_actionSheetTitles;
    SWNavBarTitleView *_titleView;
    SWModelManager *_modelManager;
    BOOL _isPageSectionHidden;
    NSInteger _itemCount;
}



#pragma mark protocol SWModelBrowserViewController

//@synthesize browsingStyle = _browsingStyle;
//@synthesize delegate = _delegate;
@synthesize identifiyingObject = _identifiyingObject;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[SWGroupItem class]], @"objecte erroni per controlador" );
    self = [self initWithGroupItem:object];
    if ( self )
    {
        _identifiyingObject = identifyingObject;
    }
    return self;
}

- (id)identifiyingObject
{
    return _identifiyingObject;
}

#pragma mark controller lifecycle

@synthesize groupItem = _groupItem;

- (id)initWithGroupItem:(SWGroupItem *)groupItem
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _groupItem = groupItem;
        if ( _identifiyingObject == nil ) _identifiyingObject = groupItem;
        _browsingStyle = SWModelBrowsingStyleManagement;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:groupItem.docModel];
        //self.title = NSLocalizedString(@"Page",nil);
        
        self.title = groupItem.identifier;
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"Group Objects", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithGroupItem:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        UINavigationItem *navItem = self.navigationItem;
        if (navItem.rightBarButtonItem == self.editButtonItem)
            navItem.rightBarButtonItem = nil;
    }
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    NSString *message = _browsingStyle == SWModelBrowsingStyleManagement ?
        @"PageBrowserFooter" : @"PageBrowserFooter2";
    [messageView setMessage:NSLocalizedString(message, nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Items", nil)];
    
    UITableView *table = self.tableView;
    
    [table setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [table setTableFooterView:messageView];
    
    //[_groupItem addGroupItemObserver:self];
    [_groupItem addObjectObserver:self];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
//        SWDocumentModel *docModel = _groupItem.docModel;
//        [table setAllowsMultipleSelection:docModel.allowsMultipleSelection];
//        [docModel addObserver:self];
        [table setAllowsMultipleSelection:YES];
    }
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        //[self.navigationController setToolbarHidden:NO animated:NO];
        
        [self _establishPageSectionAnimated:animated];
        
        NSIndexSet *indexes = _groupItem.selectedItemIndexes;
        [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:YES animated:NO];
        
        [nc addObserver:self selector:@selector(revalidateToolbarButtons) name:kPasteboardContentDidChangeNotification object:nil];
    }
    
    if ( _browsingStyle == SWModelBrowsingStyleSeeker )
    {
        [nc addObserver:self selector:@selector(modelManagerDidChangeAcceptedTypesNotification:) name:SWModelManagerDidChangeAcceptedTypesNotification object:nil];
        
        [self.tableView reloadData];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:nil object:nil];
}

- (void)modelManagerDidChangeAcceptedTypesNotification:(NSNotification*)note
{
    [self setGroupItem:_groupItem];
}

- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
    
//    if ( _browsingStyle == SWModelBrowsingStyleManagement )
//        [_groupItem.docModel removeObserver:self];
    
//    [_groupItem removeGroupItemObserver:self];
    [_groupItem removeObjectObserver:self];
}

#pragma mark - Properties

- (void)setGroupItem:(SWGroupItem *)groupItem
{
    _groupItem = groupItem;
    
    if (self.isViewLoaded)
        [self.tableView reloadData];
}



#pragma mark - Overriden Methods

- (void)add:(id)sender
{
//    [self _dismissPopViewsAnimated:NO];
//    
//    SWAddObjectViewController *aovc = [[SWAddObjectViewController alloc] initWithDocument:_page.docModel allowedObjectTypes:SWObjectTypeVisibleItem];
//    aovc.contentSizeForViewInPopover = CGSizeMake(320, 320);
//    aovc.delegate = self;
//    //aovc.title = NSLocalizedString(@"Add", nil);
//    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:aovc];
//    
//    _popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
//    [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)configure:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    //SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_page.docModel];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        SWObject *modelObject = nil;
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        if ( section == SectionGroup )
            modelObject = _groupItem;
        
        else if ( section == SectionItems)
            modelObject = [_groupItem.items objectAtIndex:(_itemCount-1)-row];
        
        //[_modelManager presentModelConfiguratorForObject:modelObject animated:NO presentingControllerKey:nil];
        [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:modelObject animated:IS_IPHONE];
    }
}


- (void)action:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    
    _actionSheetTitles = @[
        @"",
        NSLocalizedString(@"Copy",nil),
    ];
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *anyIndexPath = nil;
    NSInteger section = NSNotFound;
    if ( indexPaths.count > 0)
    {
        anyIndexPath = indexPaths[0];
        section = anyIndexPath.section;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    }
    
    if ( section == SectionItems )
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionCopy]];
    }

//    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeItemList]])
//    {
//        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionPaste]];
//    }
//    
//    if ( section == SectionItems )
//    {
//        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionDuplicate]];
//        if ( indexPaths.count > 1 )
//        {
//            [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionGroup]];
//        }
//        else if ( indexPaths.count == 1 )
//        {
//            SWItem *modelObject = [_page.items objectAtIndex:(_itemCount-1)-anyIndexPath.row];
//            if ( modelObject.isGroupItem )
//            {
//                [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionUngroup]];
//            }
//        }
//    }
 
    [_actionSheet showFromBarButtonItem:sender animated:YES];
}



- (void)trash:(id)sender
{
//    [self _dismissPopViewsAnimated:NO];
//    
//    NSArray *selection = [self.tableView indexPathsForSelectedRows];
//    
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    
//    for (NSIndexPath *indexPath in selection)
//        [indexSet addIndex:(_itemCount-1)-indexPath.row];    // <--- Sabem que el trash nomes pot apareixer per items de la seccio SectionItems
//    
//    [_page removeItemsAtIndexes:indexSet];
}


- (BOOL)validateAddButton
{
    return NO;
}


//- (BOOL)validateConfigureButton
//{    
//    return YES;
//}


- (BOOL)validateActionButton
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *indexPath = indexPaths.lastObject;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    
    BOOL enabled = ( indexPath && indexPath.section == SectionItems );
    
    enabled = enabled || [[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeItemList]] ;
    
    return enabled;
}


- (BOOL)validateTrashButton
{
    return NO;

//    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
//    NSIndexPath *indexPath = indexPaths.lastObject;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
//    return (indexPath.section == SectionItems );
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        NSIndexSet *indexes = _groupItem.selectedItemIndexes;
        if ( editing )
        {
            // el table view ho deselecciona tot al canviar l'estat de edicio, fem correspondre la vista amb el model
            [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:NO animated:NO];
        }
        else
        {
            // si marxem del mode edit ho deseleccionem tot
            [_groupItem deselectItemsAtIndexes:indexes];
        }
        [self _establishPageSectionAnimated:animated];
    }
}

- (void)setEditing:(BOOL)editing Vanimated:(BOOL)animated
{
    NSIndexSet *indexSet = nil;
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        if ( editing )
        {
            indexSet = [self indexSetForItemsInSelectedRowsWithSection:SectionItems];
        }
    
        [super setEditing:editing animated:animated];   // <-- Super

        if ( editing )
        {
            // el table view ho deselecciona tot al canviar l'estat de edicio, ho tornem a recuperar
            [self markItemsInSection:SectionItems atIndexes:indexSet scrollToVisible:NO animated:NO];
        }
        else
        {
            // si marxem del mode edit quedara tot deseleccionat
        }
        [self _establishPageSectionAnimated:animated];
    }
    else
    {
        [super setEditing:editing animated:animated];
    }
}



#pragma mark - Private Methods



- (void)_establishPageSectionAnimated:(BOOL)animated
{
    BOOL editing = self.editing;
    BOOL changed = editing != _isPageSectionHidden;
    
    if ( !changed )
        return;
    
    _isPageSectionHidden = editing;
    
    UITableView *tableView = self.tableView;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:SectionGroup];
    UITableViewRowAnimation animationKind = (animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone);
    [tableView reloadSections:indexSet withRowAnimation:animationKind];
}




- (void)_dismissPopViewsAnimated:(BOOL)animated
{
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:animated];
    _actionSheet = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SectionGroup )
    {
        if ( !_isPageSectionHidden )
            return 1;
    }
    else if (section == SectionItems)
    {
        _itemCount = _groupItem.items.count;
        return _itemCount;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *PageCellIdentifier = @"GroupItemCell";
    static NSString *ItemCellIdentifier = @"ItemCell";
    
    NSString *identifier = nil;
    
    if (section == SectionGroup)
        identifier = PageCellIdentifier;
    else if (section == SectionItems)
        identifier = ItemCellIdentifier;
    
    SWObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        if (identifier == PageCellIdentifier)
        {
            SWObjectCell *groupItemCell = [[SWObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PageCellIdentifier];
            groupItemCell.groupDetailType = SWObjectCellGroupDetailTypeValueCount;
            cell = groupItemCell;
        }
        else if (identifier == ItemCellIdentifier)
            cell = [[SWItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ItemCellIdentifier];
    }
        
    SWObjectCell *objCell = (id)cell;
    objCell.acceptedTypes = _modelManager.currentAcceptedTypes;

    SWObject *modelObject = nil;
    
    if (section == SectionGroup)
    {
        modelObject = _groupItem;
    }
    else if (section == SectionItems)
    {
        modelObject = [_groupItem.items objectAtIndex:(_itemCount-1)-row];
    }
    
    SWModelBrowserCellAccessoryType accessoryType = SWModelBrowserCellAccessoryTypeDisclosureIndicator;
    if ( _browsingStyle==SWModelBrowsingStyleManagement)
    {
        accessoryType = SWModelBrowserCellAccessoryTypeGearIndicator;
        if ( section == SectionItems && [modelObject isGroupItem] )
            accessoryType = SWModelBrowserCellAccessoryTypeGroupDisclosureIndicator;
    }
    
    
    objCell.accessory = accessoryType;
    objCell.modelObject = modelObject;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SectionGroup)
	{
        return nil;
    }
	else if (section == SectionItems)
	{        
        SWTableSectionHeaderView *tvh = [[SWTableSectionHeaderView alloc] init];
        tvh.title = NSLocalizedString(@"ITEMS",nil);
        
        return tvh;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SectionGroup)
        return 0;
	else if (section == SectionItems)
        return 30;
    
    return 0;
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    if ( section == SectionItems )
//        title = NSLocalizedString(@"ITEMS",nil);
//    return title;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionGroup)
        return NO;
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
    
//    if (indexPath.section == SectionGroup)
//        return NO;
//    
//    return YES;
}

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    _isMoving = YES;
//    
//    //NSLog( @"moveRowAtIndexPath section,row: %d,%d", destinationIndexPath.section, destinationIndexPath.row );
//    [_page moveItemAtPosition:(_itemCount-1)-sourceIndexPath.row toPosition:(_itemCount-1)-destinationIndexPath.row];
//    _isMoving = NO;
//}

//- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//    //NSLog( @"proposedDestinationIndexPath section,row: %d,%d", proposedDestinationIndexPath.section, proposedDestinationIndexPath.row );
//    if (proposedDestinationIndexPath.section == SectionGroup)
//        return sourceIndexPath;
//    
//    return proposedDestinationIndexPath;
//}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
    
    [(SWObjectCell*)cell beginObservingModel];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(SWObjectCell*)cell endObservingModel];
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//   // [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    
//    SWObject *modelObject = nil;
//        
//    if (section == SectionGroup) modelObject = _page;
//    else if (section == SectionItems) modelObject = [_page.items objectAtIndex:(_itemCount-1)-row];
//    
//    if (_browsingStyle == SWModelBrowsingStyleManagement)
//    {
//        if ( section == SectionGroup )
//        {
//            // deseleccionem els items en el model
//            [_groupItem deselectItemsAtIndexes:_page.selectedItemIndexes];
//        
//            // marquem la seleccio de pagina
//            [self markItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0] scrollToVisible:YES animated:YES];
//        }
//    
//        else if ( section == SectionItems )
//        {
//            // desmarquem la possible seleccio de pagina
//            [self unmarkItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0]];
//    
//            // seleccionem el item en el model
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
//            [_page selectItemsAtIndexes:indexSet];
//            
//            if ( modelObject.isGroupItem )
//            {
//                SWGroupItemBrowserController *obc = [[SWGroupItemBrowserController alloc]
//                    initWithObject:modelObject classIdentifierObject:[modelObject class]];
//                
//                obc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
//                obc.delegate = _delegate;
//                obc.browsingStyle = _browsingStyle;
//                
//                [self.navigationController pushViewController:obc animated:YES];
//            }
//        }
//    }
//    
//    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
//    {
//        SWObjectBroswerController *obc = [[SWObjectBroswerController alloc] initWithModelObject:modelObject];
//        obc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
//        
//        //obc.acceptedTypes = _acceptedTypes;
//        obc.delegate = _delegate;
//        obc.browsingStyle = _browsingStyle;
//        
//        [self.navigationController pushViewController:obc animated:YES];
//    }
//}


//- (void)tableView:(UITableView *)tableView VdidSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    
//    SWObject *modelObject = nil;
//    
//    if (section == SectionGroup) modelObject = _groupItem;
//    else if (section == SectionItems) modelObject = [_groupItem.groupedItems objectAtIndex:(_itemCount-1)-row];
//    
//    SWEditableTableViewController *pushController = nil;
//
//    if (_browsingStyle == SWModelBrowsingStyleManagement)
//    {
//        if ( section == SectionGroup )
//        {
//            // desmarquem la possible seleccio de tags
//            NSIndexSet *indexSet = [self indexSetForItemsInSelectedRowsWithSection:SectionItems];
//            [self unmarkItemsInSection:SectionItems atIndexes:indexSet];
//        }
//        else if ( section == SectionItems )
//        {
//            // desmarquem la possible seleccio de groupItem
//            [self unmarkItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0]];
//            
//            if ( !self.isEditing && [modelObject isKindOfClass:[SWGroupItem class]] )
//            {
//                SWGroupItemBrowserController *obc = [[SWGroupItemBrowserController alloc] initWithGroupItem:(id)modelObject];
//                pushController = obc;
//
////
////                obc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
////                obc.delegate = _delegate;
////                obc.browsingStyle = _browsingStyle;
////                
////                [self.navigationController pushViewController:obc animated:YES];
//            }
//        }
//        
//        [self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
//    }
//    
//    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
//    {
//        if ( section == SectionItems && [modelObject isKindOfClass:[SWGroupItem class]] )
//        {
//            SWGroupItemBrowserController *obc = [[SWGroupItemBrowserController alloc] initWithGroupItem:(id)modelObject];
//            pushController = obc;
//        }
//        else
//        {
//            SWObjectBroswerController *obc = [[SWObjectBroswerController alloc] initWithModelObject:modelObject];
//            pushController = obc;
//            
////            obc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
////        
////            //obc.acceptedTypes = _acceptedTypes;
////            obc.delegate = _delegate;
////            obc.browsingStyle = _browsingStyle;
////        
////            [self.navigationController pushViewController:obc animated:YES];
//        }
//    }
//    
//    if ( pushController )
//    {
//        //pushController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
//        pushController.preferredContentSize = self.preferredContentSize;
//        
//            //obc.acceptedTypes = _acceptedTypes;
//        pushController.delegate = _delegate;
//        pushController.browsingStyle = _browsingStyle;
//        
//        [self.navigationController pushViewController:pushController animated:YES];
//    }
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    SWObject *modelObject = nil;
    
    if (section == SectionGroup) modelObject = _groupItem;
    else if (section == SectionItems) modelObject = [_groupItem.items objectAtIndex:(_itemCount-1)-row];
    
    SWEditableTableViewController *pushController = nil;
    

    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        if ( section == SectionGroup )
        {
            // deseleccionem els items en el model
            [_groupItem deselectItemsAtIndexes:_groupItem.selectedItemIndexes];
        
            // marquem la seleccio de grup
            [self markItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0] scrollToVisible:YES animated:YES];
        }
        else if ( section == SectionItems )
        {
            if ( self.isEditing )
            {
                // selectionem el item en el model
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
                [_groupItem selectItemsAtIndexes:indexSet];
            }
            else
            {
                // desmarquem la possible seleccio de groupItem
                [self unmarkItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0]];
            
                // deseleccionem si cal els items en el model
                if ( !_groupItem.docModel.allowsMultipleSelection )
                    [_groupItem deselectItemsAtIndexes:_groupItem.selectedItemIndexes];
            
                // selectionem el item en el model
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
                [_groupItem selectItemsAtIndexes:indexSet];
            
                if ( [modelObject isKindOfClass:[SWGroupItem class]] )
                {
                    SWGroupItemBrowserController *obc = [[SWGroupItemBrowserController alloc] initWithGroupItem:(id)modelObject];
                    pushController = obc;
                }
            }
        }
    }
    
    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        if ( section == SectionItems && [modelObject isKindOfClass:[SWGroupItem class]] )
        {
            SWGroupItemBrowserController *obc = [[SWGroupItemBrowserController alloc] initWithGroupItem:(id)modelObject];
            pushController = obc;
        }
        else
        {
            SWObjectBroswerController *obc = [[SWObjectBroswerController alloc] initWithModelObject:modelObject];
            pushController = obc;
        }
    }
    
    if ( pushController )
    {
        //pushController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        pushController.preferredContentSize = self.preferredContentSize;
        
            //obc.acceptedTypes = _acceptedTypes;
        pushController.delegate = _delegate;
        pushController.browsingStyle = _browsingStyle;
        
        [self.navigationController pushViewController:pushController animated:YES];
    }
}


- (void)tableView:(UITableView *)tableView VdidDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
    
        // desmarquem la seleccio
        [self unmarkItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
    
        if ( section == SectionGroup )
        {
            // desmarquem la possible seleccio de pagina
            [self unmarkItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    
        else if ( section == SectionItems )
        {
            // deseleccionem els items en el model
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
            [_groupItem deselectItemsAtIndexes:indexSet];
        }
    }
}


#pragma mark - Table Selection


- (NSIndexSet*)_reversedIndexSet:(NSIndexSet*)indexes
{
    NSMutableIndexSet *reversedIndexset = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [reversedIndexset addIndex:(_itemCount-1)-idx];
    }];

    return reversedIndexset;
}

- (void)markItemsInSection:(NSInteger)section atIndexes:(NSIndexSet*)indexes scrollToVisible:(BOOL)scroll animated:(BOOL)animated
{
    if ( section == SectionItems )
        indexes = [self _reversedIndexSet:indexes];

    [super markItemsInSection:section atIndexes:indexes scrollToVisible:scroll animated:animated];
}


- (void)unmarkItemsInSection:(NSInteger)section atIndexes:(NSIndexSet *)indexes
{
    if ( section == SectionItems )
        indexes = [self _reversedIndexSet:indexes];
    
    [super unmarkItemsInSection:section atIndexes:indexes];
}




//#pragma mark - DocumentModel Observer

//- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel*)docModel
//{
//    UITableView *table = self.tableView;
//    [table setAllowsMultipleSelection:docModel.allowsMultipleSelection];
//    // ^-- quan passem a single selection es deselecciona tot en la taula, hem fet que el comportament del model sigui compatible amb aixo
//    // ^-- en mode edit admetem multiple seleccio en la taula (i el model) encara que estem en single selection
//}


#pragma mark - SWGroupItem Observer<SWObjectObserver>

- (void)identifierDidChangeForObject:(SWObject *)object
{
    self.title = object.identifier;
    _titleView.mainLabel.text = self.title;
    [_titleView sizeToFit];
}


- (void)willRemoveObject:(SWObject *)object
{
    [self removeFromContainerController];
}



#pragma mark - SWGroupItem Observer<SWGroupObserver>

- (void)group:(id<SWGroup>)groupItem didSelectItemsAtIndexes:(NSIndexSet *)indexes
{
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        [self unmarkItemsInSection:SectionGroup atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:YES animated:YES];
    }
}


- (void)group:(id<SWGroup>)groupItem didDeselectItemsAtIndexes:(NSIndexSet *)indexes
{
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        [self unmarkItemsInSection:SectionItems atIndexes:indexes];
    }
}


#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Action action = ActionNone;
 
    if ( buttonIndex != actionSheet.cancelButtonIndex )
    {
        NSString *actionTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSInteger actionIndex = [_actionSheetTitles indexOfObject:actionTitle];
    
        if ( actionIndex != NSNotFound )
            action = actionIndex;
    }
    
    _actionSheetTitles = nil;
    
    if ( action == ActionNone )
        return;

    NSArray *tableViewSelection = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *selection = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in tableViewSelection)
    {
        if ( indexPath.section == SectionItems )
            [selection addIndex:(_itemCount-1)-indexPath.row];
    }
    
    NSData *data = nil;
    
    // copy
    if ( action == ActionCopy /*|| action == ActionDuplicate*/ )
    {
        NSArray *objects= [_groupItem.items objectsAtIndexes:selection];
        data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
                                        forKey:kSymbolicCodingCollectionKey
                                        version:SWVersion];
    }
    
    // copy
    if ( action == ActionCopy )
    {
        [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:kPasteboardTypeItemList];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
    }
    
//    // paste
//    if ( action == ActionPaste )
//    {
//        data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:kPasteboardTypeItemList];
//    }
//    
//    // paste, duplicate
//    if ( action == ActionPaste || action == ActionDuplicate )
//    {
//    
//        NSError *error = nil;
//        NSArray *objects = [SymbolicUnarchiver unarchivedObjectsWithData:data
//                                    forKey:kSymbolicCodingCollectionKey
//                                    builder:_page.builder
//                                    parentObject:_page
//                                    version:SWVersion
//                                    outError:&error];
//
//        if ( objects == nil )
//        {
//            // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
//            //NSString *errorStr = [error localizedDescription];
//            NSString *errorStr = NSLocalizedString( @"PasteErrorDescription", nil );
//            NSString *title = NSLocalizedString( @"PasteError", nil );
//            [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
//        }
//        else
//        {
//            [_page insertItems:objects atIndexes:nil];
//        }
//    }
//    
//    // group
//    if ( action == ActionGroup )
//    {
//        [_page insertNewGroupItemForItemsAtIndexes:selection];
//    }
//    
//    // ungroup
//    if ( action == ActionUngroup )
//    {
//        [_page removeGroupItemAtIndex:selection.firstIndex];
//    }
    
    _actionSheet = nil;
}






//#pragma mark - Add Object View Controller
//
//- (void)didFinishSelectionInAddObjectViewController:(SWAddObjectViewController *)controller
//{
//    [self _dismissPopViewsAnimated:YES];
//}
//
//- (NSInteger)addObjectViewControllerPageIndexToInsertItems:(SWAddObjectViewController *)controller
//{
//    return _page.documentPageIndex;
//}

@end
