//
//  SWPageBrowserController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPageBrowserController.h"
#import "SWPage.h"
#import "SWItem.h"
#import "SWGroupItem.h"

//#import "SWDocument.h"
#import "SWDocumentModel.h"

#import "SWPageCell.h"
#import "SWItemCell.h"
#import "SWTableSectionHeaderView.h"
#import "SWTableViewMessage.h"

#import "SWNavBarTitleView.h"

#import "SWObjectBroswerController.h"
#import "SWGroupItemBrowserController.h"
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


typedef enum {
    ActionSheetTypeEmpty = 0,
    ActionSheetTypeSelection = 1 << 0,
    ActionSheetTypePaste     = 1 << 1,
    ActionSheetTypeGroup     = 1 << 2,
    ActionSheetTypeUngroup   = 1 << 3,
} ActionSheetType;

typedef enum {
    ActionNone = 0,
    ActionCopy = 1,
    ActionPaste = 2,
    ActionDuplicate = 3,
    ActionGroup = 4,
    ActionUngroup = 5,
    ActionTotalActions = 6,
} Action;
// ^-- Atencio no canviar l'ordre

enum Sections
{
    SectionPage = 0,
    SectionItems,
    SectionsCount
};

@interface SWPageBrowserController() <PageObserver, DocumentModelObserver, UIActionSheetDelegate, SWAddObjectViewControllerDelegate>
@end

@implementation SWPageBrowserController
{
    UIActionSheet *_actionSheet;
    NSArray *_actionSheetTitles;
    SWNavBarTitleView *_titleView;
    SWModelManager *_modelManager;
    BOOL _isPageSectionHidden;
    
    UIPopoverController *_popover;
    NSInteger _itemCount;
}



#pragma mark protocol SWModelBrowserViewController

//@synthesize browsingStyle = _browsingStyle;
//@synthesize delegate = _delegate;
@synthesize identifiyingObject = _identifiyingObject;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[SWPage class]], @"objecte erroni per controlador" );
    self = [self initWithPage:object];
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

@synthesize page = _page;

- (id)initWithPage:(SWPage*)page
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _page = page;
        if ( _identifiyingObject == nil ) _identifiyingObject = page;
        _browsingStyle = SWModelBrowsingStyleManagement;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_page.docModel];
        //self.title = NSLocalizedString(@"Page",nil);
        
        self.title = page.identifier;
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"Page Objects", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithPage:nil];
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
    
//    [_page addPageObserver:self];
    [_page addObjectObserver:self];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
//        SWDocumentModel *docModel = _page.docModel;
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
        
//        NSIndexSet *indexes = _page.selectedItemIndexes;
//        [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:YES animated:NO];
        
        [nc addObserver:self selector:@selector(revalidateToolbarButtons) name:kPasteboardContentDidChangeNotification object:nil];
    }
    
    if ( _browsingStyle == SWModelBrowsingStyleSeeker )
    {
        [nc addObserver:self selector:@selector(modelManagerDidChangeAcceptedTypesNotification:) name:SWModelManagerDidChangeAcceptedTypesNotification object:nil];
        
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSIndexSet *indexes = _page.selectedItemIndexes;
    [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:YES animated:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:nil object:nil];
}

- (void)modelManagerDidChangeAcceptedTypesNotification:(NSNotification*)note
{
    [self setPage:_page];
}

- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
    
//    if ( _browsingStyle == SWModelBrowsingStyleManagement )
//        [_page.docModel removeObserver:self];
    
    //[_page removePageObserver:self];
    [_page removeObjectObserver:self];
}

#pragma mark - Properties

- (void)setPage:(SWPage *)page
{
    _page = page;
    
    if (self.isViewLoaded)
        [self.tableView reloadData];
}

//- (void)setBrowsingStyle:(SWModelBrowsingStyle)browsingStyle
//{
//    _browsingStyle = browsingStyle;
//    _presentToolbarWhenAppearing = (browsingStyle == SWModelBrowsingStyleManagement);
//    
//    UINavigationItem *navItem = self.navigationItem;   // evitem cridades redundants
//    UIBarButtonItem *editButton = self.editButtonItem;
//    
//    if (_browsingStyle == SWModelBrowsingStyleSeeker)
//    {
//        if (navItem.rightBarButtonItem == editButton)
//            navItem.rightBarButtonItem = nil;
//    }
//    else
//        navItem.rightBarButtonItem = editButton;
//}

#pragma mark - Overriden Methods

- (void)add:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    SWAddObjectViewController *aovc = [[SWAddObjectViewController alloc] initWithDocument:_page.docModel allowedObjectTypes:SWObjectTypeVisibleItem];
    //aovc.contentSizeForViewInPopover = CGSizeMake(320, 320);
    aovc.preferredContentSize = CGSizeMake(320, 320);
    aovc.delegate = self;
    //aovc.title = NSLocalizedString(@"Add", nil);
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:aovc];
    
    if ( IS_IPHONE )
    {
        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:nvc animated:YES completion:^
        {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                target:self action:@selector(_dismisPresentedController:)];
            [aovc.navigationItem setLeftBarButtonItem:buttonItem];
        }];
    }
    else
    {
        _popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
        [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)_dismisPresentedController:(id)sender
{
    UIViewController *presented = [self presentedViewController];
    [presented dismissViewControllerAnimated:YES completion:nil];
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
        
        if ( section == SectionPage )
            modelObject = _page;
        
        else if ( section == SectionItems)
            modelObject = [_page.items objectAtIndex:(_itemCount-1)-row];
        
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
        NSLocalizedString(@"Paste", nil),
        NSLocalizedString(@"Duplicate",nil),
        NSLocalizedString(@"Group",nil),
        NSLocalizedString(@"UnGroup",nil),
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

    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeItemList]])
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionPaste]];
    }
    
    if ( section == SectionItems )
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionDuplicate]];
        if ( indexPaths.count > 1 )
        {
            [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionGroup]];
        }
        else if ( indexPaths.count == 1 )
        {
            SWItem *modelObject = [_page.items objectAtIndex:(_itemCount-1)-anyIndexPath.row];
            if ( modelObject.isGroupItem )
            {
                [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionUngroup]];
            }
        }
    }
 
    [_actionSheet showFromBarButtonItem:sender animated:YES];
}



//- (void)actionVV:(id)sender
//{
//    [self _dismissPopViewsAnimated:NO];
//    
//    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                               delegate:self
//                                      cancelButtonTitle:nil
//                                 destructiveButtonTitle:nil
//                                      otherButtonTitles:nil];
//    
//    _actionSheet.tag = ActionSheetTypeEmpty;
//    
//    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
//    
//    if ( indexPaths.count > 0)
//    {
//        NSIndexPath *anyIndexPath = indexPaths[0];  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
//        if ( anyIndexPath.section == SectionItems )
//        {
//            [_actionSheet addButtonWithTitle:NSLocalizedString(@"Duplicate",nil)];
//            [_actionSheet addButtonWithTitle:NSLocalizedString(@"Copy",nil)];
//            _actionSheet.tag |= ActionSheetTypeSelection;
//            
//            if ( indexPaths.count > 1 )
//            {
//                [_actionSheet addButtonWithTitle:NSLocalizedString(@"Group",nil)];
//                _actionSheet.tag |= ActionSheetTypeGroup;
//            }
//            else if ( indexPaths.count == 1 )
//            {
//                SWItem *modelObject = [_page.items objectAtIndex:(_itemCount-1)-anyIndexPath.row];
//                if ( modelObject.isGroupItem )
//                {
//                    [_actionSheet addButtonWithTitle:NSLocalizedString(@"UnGroup",nil)];
//                    _actionSheet.tag |= ActionSheetTypeUngroup;
//                }
//            }
//        }
//    }
//    
//    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeItemList]])
//    {
//        [_actionSheet addButtonWithTitle:NSLocalizedString(@"Paste", nil)];
//        _actionSheet.tag |= ActionSheetTypePaste;
//    }
//    
//    [_actionSheet showFromBarButtonItem:sender animated:YES];
//}

- (void)trash:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    NSArray *selection = [self.tableView indexPathsForSelectedRows];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath *indexPath in selection)
        [indexSet addIndex:(_itemCount-1)-indexPath.row];    // <--- Sabem que el trash nomes pot apareixer per items de la seccio SectionItems
    
    [_page removeItemsAtIndexes:indexSet];
}


//- (BOOL)validateAddButton
//{
//    return YES;
//}


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
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *indexPath = indexPaths.lastObject;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    return (indexPath.section == SectionItems );
}

//- (BOOL)validateTrashButton
//{
//    if ( !self.tableView.isEditing )
//        return NO;
//    
//    NSArray *selection = [self.tableView indexPathsForSelectedRows];
//    NSIndexPath *lastIndexPath = selection.lastObject;
//    if ( lastIndexPath == nil )
//        return NO;
//    
//    NSInteger section = lastIndexPath.section;
//    for ( NSIndexPath *indexPath in selection )
//    {
//        if ( indexPath.section != section )
//            return NO;
//    }
//    
//    return YES;
//}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        NSIndexSet *indexes = _page.selectedItemIndexes;
        if ( editing )
        {
            // el table view ho deselecciona tot al canviar l'estat de edicio, fem correspondre la vista amb el model
            [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:NO animated:NO];
        }
        else
        {
            // si marxem del mode edit ho deseleccionem tot
            [_page deselectItemsAtIndexes:indexes];
        }
        [self _establishPageSectionAnimated:animated];
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
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:SectionPage];
    UITableViewRowAnimation animationKind = (animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone);
    [tableView reloadSections:indexSet withRowAnimation:animationKind];
}




- (void)_dismissPopViewsAnimated:(BOOL)animated
{
    [_popover dismissPopoverAnimated:animated];
    _popover = nil;
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
    if (section == SectionPage )
    {
        if ( !_isPageSectionHidden )
            return 1;
    }
    else if (section == SectionItems)
    {
        _itemCount = _page.items.count;
        return _itemCount;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *PageCellIdentifier = @"PageCell";
    static NSString *ItemCellIdentifier = @"ItemCell";
    
    NSString *identifier = nil;
    
    if (section == SectionPage)
        identifier = PageCellIdentifier;
    else if (section == SectionItems)
        identifier = ItemCellIdentifier;
    
    SWObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        if (identifier == PageCellIdentifier)
        {
            SWPageCell *pageCell = [[SWPageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PageCellIdentifier];
            pageCell.rightDetailType = SWPageCellRightDetailTypeValueCount;
            cell = pageCell;
        }
        else if (identifier == ItemCellIdentifier)
            cell = [[SWItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ItemCellIdentifier];
    }
        
    SWObjectCell *objCell = (id)cell;
    objCell.acceptedTypes = _modelManager.currentAcceptedTypes;

    SWObject *modelObject = nil;
    
    if (section == SectionPage)
    {
        modelObject = _page;
    }
    else if (section == SectionItems)
    {
        modelObject = [_page.items objectAtIndex:(_itemCount-1)-row];
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
    if (section == SectionPage)
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
    if (section == SectionPage)
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
    if (indexPath.section == SectionPage)
        return NO;
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionPage)
        return NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    _isMoving = YES;
    
    //NSLog( @"moveRowAtIndexPath section,row: %d,%d", destinationIndexPath.section, destinationIndexPath.row );
    [_page moveItemAtPosition:(_itemCount-1)-sourceIndexPath.row toPosition:(_itemCount-1)-destinationIndexPath.row];
    _isMoving = NO;
}

- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    //NSLog( @"proposedDestinationIndexPath section,row: %d,%d", proposedDestinationIndexPath.section, proposedDestinationIndexPath.row );
    if (proposedDestinationIndexPath.section == SectionPage)
        return sourceIndexPath;
    
    return proposedDestinationIndexPath;
}



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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    SWObject *modelObject = nil;
        
    if (section == SectionPage) modelObject = _page;
    else if (section == SectionItems) modelObject = [_page.items objectAtIndex:(_itemCount-1)-row];
    
    SWEditableTableViewController *pushController = nil;

    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        if ( section == SectionPage )
        {
            // deseleccionem els items en el model
            [_page deselectItemsAtIndexes:_page.selectedItemIndexes];
    
            // marquem la seleccio de pagina
            [self markItemsInSection:SectionPage atIndexes:[NSIndexSet indexSetWithIndex:0] scrollToVisible:YES animated:YES];
        }

        else if ( section == SectionItems )
        {
            if ( self.isEditing )
            {
                // seleccionem el item en el model
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
                [_page selectItemsAtIndexes:indexSet];
            }
            else
            {
                // desmarquem la possible seleccio de pagina
                [self unmarkItemsInSection:SectionPage atIndexes:[NSIndexSet indexSetWithIndex:0]];
        
                // deseleccionem si cal els items en el model
                if ( !_page.docModel.allowsMultipleSelection )
                    [_page deselectItemsAtIndexes:_page.selectedItemIndexes];

                // seleccionem el item en el model
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
                [_page selectItemsAtIndexes:indexSet];
        
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


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [super tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
    
        if ( section == SectionPage )
        {
            // desmarquem la possible seleccio de pagina
            [self unmarkItemsInSection:SectionPage atIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    
        else if ( section == SectionItems )
        {
            // deseleccionem els items en el model
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(_itemCount-1)-row];
            [_page deselectItemsAtIndexes:indexSet];
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


#pragma mark - DocumentModel Observer

//- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel*)docModel
//{
//    UITableView *table = self.tableView;
//    [table setAllowsMultipleSelection:docModel.allowsMultipleSelection];
//    // ^-- quan passem a single selection es deselecciona tot en la taula, hem fet que el comportament del model sigui compatible amb aixo
//    // ^-- en mode edit admetem multiple seleccio en la taula (i el model) encara que estem en single selection
//}

#pragma mark - Page Observer<SWObjectObserver>

- (void)identifierDidChangeForObject:(SWObject *)object
{
//    if (object == _page)
//    {
        self.title = object.identifier;
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
//    }
}


- (void)willRemoveObject:(SWObject *)object
{
  //  if (object == _page)
        [self removeFromContainerController];
}


#pragma mark - Page Observer<SWPageObserver>

- (void)page:(SWPage *)page didInsertItemsAtIndexes:(NSIndexSet *)indexes isGrouping:(BOOL)isGrouping
{
    //_itemCount += indexes.count;
    _itemCount = page.items.count;
    
    UITableView *table = self.tableView;
    [table beginUpdates];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:indexes.count];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_itemCount-1)-idx inSection:SectionItems];
        [array addObject:indexPath];
    }];
    
    [table insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    
    [table endUpdates];
}


- (void)page:(SWPage *)page didRemoveItemsAtIndexes:(NSIndexSet *)indexes isGrouping:(BOOL)isGrouping
{
    [self.tableView beginUpdates];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:indexes.count];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_itemCount-1)-idx inSection:SectionItems];
        [indexPaths addObject:indexPath];
    }];
    
    _itemCount = page.items.count;
    //_itemCount -= indexes.count;
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    [self revalidateToolbarButtons];
}


- (void)page:(SWPage *)page didMoveItemAtPosition:(NSInteger)starPosition toPosition:(NSInteger)finalPosition
{
    if (_isMoving)
        return;
        
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:(_itemCount-1)-starPosition inSection:SectionItems];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:(_itemCount-1)-finalPosition inSection:SectionItems];

    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark - Page Observer<SWGroupObserver>

- (void)group:(id<SWGroup>)page didSelectItemsAtIndexes:(NSIndexSet *)indexes
{
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        [self unmarkItemsInSection:SectionPage atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self markItemsInSection:SectionItems atIndexes:indexes scrollToVisible:YES animated:YES];
    }
}


- (void)group:(id<SWGroup>)page didDeselectItemsAtIndexes:(NSIndexSet *)indexes
{
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        [self unmarkItemsInSection:SectionItems atIndexes:indexes];
    }
}




#pragma mark - UIActionSheet Delegate

//- (void)actionSheetVV:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstButtonIndex = actionSheet.firstOtherButtonIndex + 1;
//    
//    Action action = ActionNone;
//    
//    ActionSheetType type = actionSheet.tag;
//    
//    if (type == ActionSheetTypeEmpty)
//    {
//        // Nothing more to do
//        return;
//    }
//    else if (type == ActionSheetTypeSelection)
//    {
//        if (buttonIndex == firstButtonIndex)
//            action = ActionDuplicate;
//        else if (buttonIndex == firstButtonIndex + 1)
//            action = ActionCopy;
//    }
//    else if (type == ActionSheetTypePaste)
//    {
//        if (buttonIndex == firstButtonIndex)
//            action = ActionPaste;
//    }
//    else if (type == (ActionSheetTypeSelection | ActionSheetTypePaste))
//    {
//        if (buttonIndex == firstButtonIndex)
//            action = ActionDuplicate;
//        else if (buttonIndex == firstButtonIndex + 1)
//            action = ActionCopy;
//        else if (buttonIndex == firstButtonIndex + 2)
//            action = ActionPaste;
//    }
//    
//    NSArray *tableViewSelection = [self.tableView indexPathsForSelectedRows];
//    NSMutableIndexSet *selection = [NSMutableIndexSet indexSet];
//    for (NSIndexPath *indexPath in tableViewSelection)
//    {
//        if ( indexPath.section == SectionItems )
//            [selection addIndex:(_itemCount-1)-indexPath.row];
//    }
//    
//    switch (action)
//    {
//        case ActionDuplicate:
//        {
//            NSArray *objects= [_page.items objectsAtIndexes:selection];
//            NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
//                                                               forKey:kSymbolicCodingCollectionKey
//                                                              version:SWVersion];
//                                                                    
//            NSError *error = nil;
//            NSArray *array = [SymbolicUnarchiver unarchivedObjectsWithData:data
//                                                            forKey:kSymbolicCodingCollectionKey
//                                                           builder:_page.builder
//                                                       parentObject:_page
//                                                            version:SWVersion
//                                                            outError:&error];
//
//            if ( array == nil )
//            {
//                // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
//                //NSString *errorStr = [error localizedDescription];
//                NSString *errorStr = NSLocalizedString( @"PasteErrorDescription", nil );
//                NSString *title = NSLocalizedString( @"PasteError", nil );
//                [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
//            }
//            else
//            {
//                [_page insertItems:array atIndexes:nil];
//            }
//            break;
//        }
//            
//        case ActionCopy:
//        {
//            NSArray *objects = [_page.items objectsAtIndexes:selection];
//            NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
//                                                               forKey:kSymbolicCodingCollectionKey
//                                                              version:SWVersion];
//            
//            [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:kPasteboardTypeItemList];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
//            break;
//        }
//           
//        case ActionPaste:
//        {
//            NSData *data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:kPasteboardTypeItemList];
//
//            NSError *error = nil;
//            NSArray *array = [SymbolicUnarchiver unarchivedObjectsWithData:data
//                                                            forKey:kSymbolicCodingCollectionKey
//                                                           builder:_page.builder
//                                                       parentObject:_page
//                                                            version:SWVersion
//                                                            outError:&error];
//
//            if ( array == nil )
//            {
//                // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
//                //NSString *errorStr = [error localizedDescription];
//                NSString *errorStr = NSLocalizedString( @"PasteErrorDescription", nil );
//                NSString *title = NSLocalizedString( @"PasteError", nil );
//                [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
//            }
//            else
//            {
//                [_page addItems:array atIndexes:nil];
//            }
//            break;
//        }
//            
//        default:
//            break;
//    }
//    
//    _actionSheet = nil;
//}
//

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
    
    // copy, duplicate
    if ( action == ActionCopy || action == ActionDuplicate )
    {
        NSArray *objects= [_page.items objectsAtIndexes:selection];
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
    
    // paste
    if ( action == ActionPaste )
    {
        data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:kPasteboardTypeItemList];
    }
    
    // paste, duplicate
    if ( action == ActionPaste || action == ActionDuplicate )
    {
    
        NSError *error = nil;
        NSArray *objects = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                    forKey:kSymbolicCodingCollectionKey
                                    builder:_page.builder
                                    parentObject:_page
                                    version:SWVersion
                                    outError:&error];

        if ( objects == nil )
        {
            // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
            //NSString *errorStr = [error localizedDescription];
            NSString *errorStr = NSLocalizedString( @"PasteErrorDescription", nil );
            NSString *title = NSLocalizedString( @"PasteError", nil );
            [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
        }
        else
        {
            [_page insertItems:objects atIndexes:nil];
        }
    }
    
    // group
    if ( action == ActionGroup )
    {
        [_page insertNewGroupItemForItemsAtIndexes:selection];
    }
    
    // ungroup
    if ( action == ActionUngroup )
    {
        [_page removeGroupItemAtIndex:selection.firstIndex];
    }
    
    _actionSheet = nil;
}


//- (void)actionSheetVV:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstButtonIndex = actionSheet.firstOtherButtonIndex + 1;
//    
//    Action action = ActionNone;
//    
//    ActionSheetType type = actionSheet.tag;
//    
//    if (type == ActionSheetTypeEmpty)
//    {
//        // Nothing more to do
//        return;
//    }
//    else if (type == ActionSheetTypeSelection)
//    {
//        if (buttonIndex == firstButtonIndex)
//            action = ActionDuplicate;
//        else if (buttonIndex == firstButtonIndex + 1)
//            action = ActionCopy;
//    }
//    else if (type == ActionSheetTypePaste)
//    {
//        if (buttonIndex == firstButtonIndex)
//            action = ActionPaste;
//    }
//    else if (type == (ActionSheetTypeSelection | ActionSheetTypePaste))
//    {
//        if (buttonIndex == firstButtonIndex)
//            action = ActionDuplicate;
//        else if (buttonIndex == firstButtonIndex + 1)
//            action = ActionCopy;
//        else if (buttonIndex == firstButtonIndex + 2)
//            action = ActionPaste;
//    }
//    
//    NSArray *tableViewSelection = [self.tableView indexPathsForSelectedRows];
//    NSMutableIndexSet *selection = [NSMutableIndexSet indexSet];
//    for (NSIndexPath *indexPath in tableViewSelection)
//    {
//        if ( indexPath.section == SectionItems )
//            [selection addIndex:(_itemCount-1)-indexPath.row];
//    }
//    
//    NSData *data = nil;
//    
//    // copy, duplicate
//    if ( action == ActionCopy || action == ActionDuplicate )
//    {
//        NSArray *objects= [_page.items objectsAtIndexes:selection];
//        data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
//                                        forKey:kSymbolicCodingCollectionKey
//                                        version:SWVersion];
//    }
//    
//    // copy
//    if ( action == ActionCopy )
//    {
//        [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:kPasteboardTypeItemList];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
//    }
//    
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
//    _actionSheet = nil;
//}




#pragma mark - Add Object View Controller

- (void)didFinishSelectionInAddObjectViewController:(SWAddObjectViewController *)controller
{
    [self _dismissPopViewsAnimated:YES];
}

- (NSInteger)addObjectViewControllerPageIndexToInsertItems:(SWAddObjectViewController *)controller
{
    return _page.documentPageIndex;
}

@end
