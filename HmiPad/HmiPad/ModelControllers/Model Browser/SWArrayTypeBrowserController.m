//
//  SWAlarmsBrowserController.m
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWArrayTypeBrowserController.h"

#import "SWPageBrowserController.h"
#import "SWSourceVariablesBrowserController.h"
#import "SWObjectBroswerController.h"

#import "SWModelManager.h"
#import "SWAddObjectViewController.h"
#import "SWCoverVerticalPopoverController.h"
#import "SWRevealViewController.h"
//#import "SWConfigurationController.h"

#import "SWAlarmCell.h"
#import "SWProjectUserCell.h"
#import "SWDatabaseCell.h"
#import "SWRestApiItemCell.h"
#import "SWPageCell.h"
#import "SWSourceCell.h"

#import "SWTableSectionHeaderView.h"
#import "SWTableViewMessage.h"

#import "SWNavBarTitleView.h"

#import "SWDocument.h"
#import "SymbolicCoder.h"

#import "SWAlertCenter.h"
#import "SWPasteboardTypes.h"

typedef enum {
    ActionSheetTypeEmpty = 0,
    ActionSheetTypeSelection = 1 << 0,
    ActionSheetTypePaste = 1 << 1
} ActionSheetType;

typedef NS_ENUM(NSInteger, Action) {
    ActionNone          = 0,
    ActionCopy          = 1,
    ActionPaste         = 2,
    ActionDuplicate     = 3
};


@interface SWArrayTypeBrowserController()<UIActionSheetDelegate, SWAddObjectViewControllerDelegate>
@end

@implementation SWArrayTypeBrowserController
{
    UIActionSheet *_actionSheet;
    NSArray *_actionSheetTitles;
    UIPopoverController *_popover;
    SWCoverVerticalPopoverController *_coverPopover;
    SWModelManager *_modelManager;
}

#pragma mark protocol SWModelBrowserViewController

//@synthesize browsingStyle = _browsingStyle;
//@synthesize delegate = _delegate;

//- (id)initWithIdentifyingObject:(id)object docModel:(SWDocumentModel*)docModel

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[SWDocumentModel class]], @"objecte erroni per controlador" );
    NSAssert( [identifyingObject isKindOfClass:[NSNumber class]], @"objecte erroni per controlador" );
    self = [self initWithDocumentModel:object andArrayType:[identifyingObject intValue]];
    return self;
}

- (id)identifiyingObject
{
    return [NSNumber numberWithInt:_arrayType];
}

#pragma mark controller lifecycle

- (id)initWithDocumentModel:(SWDocumentModel*)documentModel andArrayType:(SWArrayType)type
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _documentModel = documentModel;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
        _arrayType = type;
        _browsingStyle = SWModelBrowsingStyleManagement;
        
        NSString *title = nil;
        
        switch (_arrayType)
        {
            case SWArrayTypeSystemItems:
                title = @"System";
                break;

            case SWArrayTypeBackgroundItems:
                title = @"Background";
                break;
                
            case SWArrayTypePages:
                title = @"Pages";
                break;
                
            case SWArrayTypeAlarms:
                title = @"Alarms";   // localitzat mes avall
                break;
                
            case SWArrayTypeProjectUsers:
                title = @"Users";   // localitzat mes avall
                break;
                
            case SWArrayTypeDataLoggers:
                title = @"Data Loggers";
                break;
                
            case SWArrayTypeRestApiItems:
                title = @"REST Connectors";
                break;
                
            case SWArrayTypeSources:
                title = @"PLC Connectors";
                break;
                
            default:
                title = @"List";
                break;
        }
        
        self.title = NSLocalizedString(title,nil);
        SWNavBarTitleView *_titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"Object List", nil);
        _titleView.mainLabel.text = self.title;
        self.navigationItem.titleView = _titleView;
        [_titleView sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_browsingStyle == SWModelBrowsingStyleSeeker || _arrayType == SWArrayTypeSystemItems)
    {
        UINavigationItem *navItem = self.navigationItem;
        if (navItem.rightBarButtonItem == self.editButtonItem)
            navItem.rightBarButtonItem = nil;
    }
    
    NSString *footerString = nil;
    NSString *emptyTitle = nil;
    switch ( _arrayType )
    {
        case SWArrayTypeSystemItems:
            emptyTitle = @"No Items";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeSystem" : @"FooterStringArrayTypeSystem2" ;
            break;
            
        case SWArrayTypeAlarms:
            emptyTitle = @"No Alarms";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeAlarm" : @"FooterStringArrayTypeAlarm2" ;
            break;
            
        case SWArrayTypeProjectUsers:
            emptyTitle = @"No Users";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeProjectUser" : @"FooterStringArrayTypeProjectUser2" ;
            break;
            
        case SWArrayTypeDataLoggers:
            emptyTitle = @"No Databases";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeDatabase" : @"FooterStringArrayTypeDatabase2" ;
            break;
            
        case SWArrayTypeRestApiItems:
            emptyTitle = @"No APIS";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeRestApiItems" : @"FooterStringArrayTypeRestApiItems2" ;
            break;
            
        case SWArrayTypeBackgroundItems:
            emptyTitle = @"No Items";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeBackgroundItems" : @"FooterStringArrayTypeBackgroundItems2";
            break;
            
        case SWArrayTypePages:
            emptyTitle = @"No Pages";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypePages" : @"FooterStringArrayTypePages2";
            break;
            
        case SWArrayTypeSources:
            emptyTitle = @"No Connectors";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeSources" : @"FooterStringArrayTypeSources2";
            break;
            
        default:
            emptyTitle = @"No Items";
            footerString = _browsingStyle == SWModelBrowsingStyleManagement ?
            @"FooterStringArrayTypeList" : @"FooterStringArrayTypeList2";
            break;
    }
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    
    [messageView setMessage:NSLocalizedString(footerString, nil)];
    [messageView setEmptyTitle:NSLocalizedString(emptyTitle, nil)];

    UITableView *table = self.tableView;
    
    [table setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [table setTableFooterView:messageView];
    
//    BOOL multipleSelection = _documentModel.allowsMultipleSelection && ![self _isIntermediateController];
    BOOL multipleSelection = ![self _isIntermediateController];
    
    [table setAllowsMultipleSelection:multipleSelection];
    [_documentModel addObserver:self];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //NSLog( @"SWArrayTypeBrowserController viewWillAppear %@", self);
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        //[self.navigationController setToolbarHidden:NO animated:NO];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revalidateToolbarButtons) name:kPasteboardContentDidChangeNotification object:nil];
        
//        if ( _arrayType == SWArrayTypePages )
//        {
//            if ( !self.isEditing )
//            {
//                NSInteger pageIndex = _documentModel.selectedPageIndex;
//                [self markItemsInSection:0 atIndexes:[NSIndexSet indexSetWithIndex:pageIndex] scrollToVisible:YES animated:YES];
//            }
//        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //NSLog( @"SWArrayTypeBrowserController viewDidAppear %@", self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    //NSLog( @"SWArrayTypeBrowserController viewWillDisappear %@", self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //NSLog( @"SWArrayTypeBrowserController viewDidDisappear %@", self);

}

- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
    
    [_documentModel removeObserver:self];
}

#pragma mark - Properties

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

    if ( _arrayType == SWArrayTypeAlarms )
    {
        SWAlarm *alarm = [[SWAlarm alloc] initInDocument:_documentModel];
        [_documentModel addObject:alarm ofType:_arrayType];
    }
    
    else if ( _arrayType == SWArrayTypeProjectUsers )
    {
        SWProjectUser *user = [[SWProjectUser alloc] initInDocument:_documentModel];
        [_documentModel addObject:user ofType:_arrayType];
    }
    
    else if ( _arrayType == SWArrayTypeDataLoggers )
    {
        SWDataLoggerItem *database = [[SWDataLoggerItem alloc] initInDocument:_documentModel];
        [_documentModel addObject:database ofType:_arrayType];
    }
    
    else if ( _arrayType == SWArrayTypeRestApiItems )
    {
        SWRestApiItem *restApiItem = [[SWRestApiItem alloc] initInDocument:_documentModel];
        [_documentModel addObject:restApiItem ofType:_arrayType];
    }
    
    else if ( _arrayType == SWArrayTypeSources )
    {
       // [self _dismissPopViewsAnimated:NO];
        
        SWAddObjectViewController *aovc = [[SWAddObjectViewController alloc] initWithDocument:_documentModel allowedObjectTypes:SWObjectTypeSource];
        //aovc.contentSizeForViewInPopover = CGSizeMake(320, 320);
        aovc.preferredContentSize = CGSizeMake(320, 320);
        aovc.delegate = self;
        //aovc.title = NSLocalizedString(@"Add", nil);
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:aovc];
        //nnn
        if ( IS_IPHONE )
        {
//            [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//            [self presentViewController:nvc animated:YES completion:^
//            {
//                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
//                target:self action:@selector(_dismisPresentedController:)];
//                [aovc.navigationItem setLeftBarButtonItem:buttonItem];
//            }];
            
            _coverPopover = [[SWCoverVerticalPopoverController alloc] initWithContentViewController:nvc forPresentingInController:self.revealViewController];
            _coverPopover.displacementOffset = 44;
            [_coverPopover presentCoverVerticalPopoverAnimated:YES completion:^
            {
                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                    target:self action:@selector(_dismisCoverVerticalController:)];
                [aovc.navigationItem setLeftBarButtonItem:buttonItem];
            }];
            
        }
        else
        {
            _popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
            [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
    else if ( _arrayType == SWArrayTypePages )
    {
        SWPage *page = [[SWPage alloc] initInDocument:_documentModel];
        [_documentModel addPage:page];
    }
    
    else if ( _arrayType == SWArrayTypeBackgroundItems )
    {
      //  [self _dismissPopViewsAnimated:NO];
        
        SWAddObjectViewController *aovc = [[SWAddObjectViewController alloc] initWithDocument:_documentModel allowedObjectTypes:SWObjectTypeBackgroundItem];
        aovc.delegate = self;
        //aovc.title = NSLocalizedString(@"Add", nil);
        //aovc.contentSizeForViewInPopover = CGSizeMake(320, 320);
        aovc.preferredContentSize =  CGSizeMake(320, 320);
        
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:aovc];
        if ( IS_IPHONE )
        {
//            [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//            [self presentViewController:nvc animated:YES completion:^
//            {
//                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
//                target:self action:@selector(_dismisPresentedController:)];
//                [aovc.navigationItem setLeftBarButtonItem:buttonItem];
//            }];
            
            _coverPopover = [[SWCoverVerticalPopoverController alloc] initWithContentViewController:nvc forPresentingInController:self.revealViewController];
            _coverPopover.displacementOffset = 44;
            [_coverPopover presentCoverVerticalPopoverAnimated:YES completion:^
            {
                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                    target:self action:@selector(_dismisCoverVerticalController:)];
                [aovc.navigationItem setLeftBarButtonItem:buttonItem];
            }];
        }
        else
        {
            _popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
            [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
    else
    {
        NSLog(@"Insertion not supported for arrayType %d", _arrayType);
    }
}


- (void)_dismisCoverVerticalController:(id)sender
{
//    UIViewController *presented = [self presentedViewController];
//    [presented dismissViewControllerAnimated:YES completion:nil];
    
    [_coverPopover dismissCoverVerticalPopoverAnimated:YES completion:nil];
}


- (void)configure:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    
    //SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
    NSArray *objects = [_documentModel objectsOfType:_arrayType];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        SWObject *modelObject = [objects objectAtIndex:indexPath.row];
        //[_modelManager presentModelConfiguratorForObject:modelObject animated:NO presentingControllerKey:nil];
        [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:modelObject animated:IS_IPHONE];
    }
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
//    if ( indexPaths.count > 0 )
//    {
//        [_actionSheet addButtonWithTitle:NSLocalizedString(@"Duplicate",nil)];
//        [_actionSheet addButtonWithTitle:NSLocalizedString(@"Copy",nil)];
//        _actionSheet.tag |= ActionSheetTypeSelection;
//    }
//    
//    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[self _pasteboardTypes]])
//    {
//        [_actionSheet addButtonWithTitle:NSLocalizedString(@"Paste", nil)];
//        _actionSheet.tag |= ActionSheetTypePaste;
//    }
//    
//    [_actionSheet showFromBarButtonItem:sender animated:YES];
//}

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
    ];
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSInteger count = indexPaths.count;
    
    if ( count > 0 )
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionCopy]];
    }
    
    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[self _pasteboardTypes]])
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionPaste]];
        _actionSheet.tag |= ActionSheetTypePaste;
    }
    
    if ( count > 0 )
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionDuplicate]];
    }
    
    [_actionSheet showFromBarButtonItem:sender animated:YES];
}


- (void)trash:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    NSArray *selection = [self.tableView indexPathsForSelectedRows];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath *indexPath in selection)
        [indexSet addIndex:indexPath.row];
    
//    if (_arrayType == SWArrayTypePages)
//        [_documentModel removePagesAtIndexes:indexSet];
//    else
        [_documentModel removeObjectsAtIndexes:indexSet ofType:_arrayType];
}

- (BOOL)validateActionButton
{
    BOOL enabled = (_arrayType != SWArrayTypeSystemItems ) ;
    if ( enabled )
    {
        NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
        NSIndexPath *indexPath = indexPaths.lastObject;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    
        enabled = (indexPath != nil);
        enabled = enabled || [[UIPasteboard applicationPasteboard] containsPasteboardTypes:[self _pasteboardTypes]] ;
    }
    return enabled;
}

- (BOOL)validateAddButton
{
    BOOL enabled = (_arrayType != SWArrayTypeSystemItems ) ;
    return enabled;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{

    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        NSIndexSet *indexSet = nil;
        if ( editing )
        {
            indexSet = [self indexSetForItemsInSelectedRowsWithSection:0];
        }
    
        [super setEditing:editing animated:animated];   // <-- Super

        if ( editing )
        {
            // el table view ho deselecciona tot al canviar l'estat de edicio, ho tornem a recuperar
            [self markItemsInSection:0 atIndexes:indexSet scrollToVisible:NO animated:NO];
        }
        else
        {
            // si marxem del mode edit quedara tot deseleccionat
        }
    }
    else
    {
        [super setEditing:editing animated:animated];
    }
}


- (NSIndexSet*)_indexSetForTagsInSelectedRows
{
    UITableView *tableView = self.tableView;
    NSArray *indexPaths = [tableView indexPathsForSelectedRows];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for ( NSIndexPath *indexPath in indexPaths )
    {
        NSInteger row = indexPath.row;
            [indexSet addIndex:row];
    }
    return indexSet;
}

#pragma mark - Private Methods

- (NSString*)_pasteboardType
{
    if (_arrayType == SWArrayTypeAlarms)
        return kPasteboardAlarmListType;
    
    else if (_arrayType == SWArrayTypeProjectUsers)
        return kPasteboardProjectUserListType;
    
    else if (_arrayType == SWArrayTypeDataLoggers)
        return kPasteboardDatabaseListType;
    
    else if (_arrayType == SWArrayTypeRestApiItems)
        return kPasteboardRestApiItemListType;
    
    else if (_arrayType == SWArrayTypeBackgroundItems)
        return kPasteboardBackgroundItemListType;

    else if (_arrayType == SWArrayTypePages)
        return kPasteboardPageListType;

    else if (_arrayType == SWArrayTypeSources)
        return kPasteboardSourceListType;
    
    //NSAssert(NO, @"Unknown PasteboardType!");
    return nil;
}

- (NSArray*)_pasteboardTypes
{
    NSString *pasteboardType = [self _pasteboardType];
    
    if ( pasteboardType )
        return @[pasteboardType];
    
    return @[];
}

- (BOOL)_isIntermediateController
{
    return (_arrayType == SWArrayTypePages || _arrayType == SWArrayTypeSources || _browsingStyle == SWModelBrowsingStyleSeeker);
}

- (void)_dismissPopViewsAnimated:(BOOL)animated
{
    [_popover dismissPopoverAnimated:animated];
    _popover = nil;
    
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:animated];
    _actionSheet = nil;
    
    [self _dismisCoverVerticalController:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = [[_documentModel objectsOfType:_arrayType] count];
    [(id)tableView.tableFooterView showForEmptyTable:(rowsCount==0)];
    [tableView setScrollEnabled:(rowsCount>0)];
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SWObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        if (_arrayType == SWArrayTypeAlarms)
        {
            cell = [[SWAlarmCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        else if (_arrayType == SWArrayTypeProjectUsers)
        {
            cell = [[SWProjectUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        else if ( _arrayType == SWArrayTypeDataLoggers )
        {
            cell = [[SWDatabaseCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        else if ( _arrayType == SWArrayTypeDataLoggers )
        {
            cell = [[SWRestApiItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        else if (_arrayType == SWArrayTypePages)
        {
            SWPageCell *pageCell = [[SWPageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            pageCell.rightDetailType = SWPageCellRightDetailTypeItemCount;
            cell = pageCell;
        }
        
        else if (_arrayType == SWArrayTypeSources)
        {
            cell = [[SWSourceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }

        else
        {
            cell = [[SWObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    
    SWObject *modelObject = [[_documentModel objectsOfType:_arrayType] objectAtIndex:indexPath.row];
    cell.acceptedTypes = _modelManager.currentAcceptedTypes;
    //cell.acceptedTypes = self.acceptedTypes;
    
//    BOOL showConfigurator = NO;
//    
//    if ( ![self _isIntermediateController ] )
//        showConfigurator = _browsingStyle==SWModelBrowsingStyleManagement;
    
    BOOL showConfigurator = ![self _isIntermediateController];
    
    SWModelBrowserCellAccessoryType accessoryType = showConfigurator?SWModelBrowserCellAccessoryTypeGearIndicator:SWModelBrowserCellAccessoryTypeDisclosureIndicator;
//    if ( _arrayType == SWArrayTypePages )
//    {
//        if ( _documentModel.selectedPageIndex == indexPath.row )
//            accessoryType = SWModelBrowserCellAccessoryTypeGroupDisclosureIndicator;
//    }
    
    cell.accessory = accessoryType;
    cell.modelObject = modelObject;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [_documentModel removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] ofType:_arrayType];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    _isMoving = YES;
    [_documentModel moveObjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row ofType:_arrayType];
    _isMoving = NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    SWTableSectionHeaderView *header = [[SWTableSectionHeaderView alloc] init];
//    header.title = self.title;
//    return header;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return 30;
    
    return 0;
}



#pragma mark - Table view mark cell

- (void)_setCell:(UITableViewCell*)cell marked:(BOOL)marked
{
    UIColor *backGroundColor = marked?[UIColor colorWithWhite:1.0f alpha:1.0f]:[UIColor colorWithWhite:0.96f alpha:1.0f];
    [cell setBackgroundColor:backGroundColor];
}

- (void)_markCellAtIndex:(NSInteger)index;
{
    [self _unMark];

    UITableView *table = self.tableView;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];

    [self _setCell:cell marked:YES];
}

- (void)_unMark
{
    UITableView *table = self.tableView;
    NSArray *cells = [table visibleCells];
    for ( UITableViewCell *cell in cells )
        [self _setCell:cell marked:NO];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL marked = NO;
    
    if ( _arrayType == SWArrayTypePages )
    {
        NSInteger row = indexPath.row;
        if ( _documentModel.selectedPageIndex == row )
            marked = YES;
    }
    [self _setCell:cell marked:marked];
    
    [(SWObjectCell*)cell beginObservingModel];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(SWObjectCell*)cell endObservingModel];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    
//    if (tableView.editing)
//    {
//        // Nothing to do
//    }
//    else
//    {
//        SWObject *modelObject = [[_documentModel objectsOfType:_arrayType] objectAtIndex:indexPath.row];
//        
//        if (_arrayType == SWArrayTypePages)
//        {
//            SWPage *page = [_documentModel.pages objectAtIndex:indexPath.row];
//            SWPageBrowserController *pbc = [[SWPageBrowserController alloc] initWithPage:page];
//            pbc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
//            pbc.acceptedTypes = _acceptedTypes;
//            pbc.delegate = _delegate;
//            pbc.browsingStyle = _browsingStyle;
//            
//            [self.navigationController pushViewController:pbc animated:YES];
//        }
//        else if (_arrayType == SWArrayTypeSources)
//        {
//            SWSourceItem *source = [_documentModel.sourceItems objectAtIndex:indexPath.row];
//            SWSourceVariablesBrowserController *vlc = [[SWSourceVariablesBrowserController alloc] initWithSourceItem:source];
//            vlc.acceptedTypes = _acceptedTypes;
//            vlc.delegate = _delegate;
//            vlc.browsingStyle = _browsingStyle;
//            vlc.title = NSLocalizedString(@"Source", nil);
//            vlc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
//            
//            [self.navigationController pushViewController:vlc animated:YES];
//        }
//        else
//        {
//            if (_browsingStyle == SWModelBrowsingStyleManagement)
//            {
//            
//                SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
//                [manager presentModelConfiguratorForObject:modelObject animated:NO];
//                [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            }
//            else if (_browsingStyle == SWModelBrowsingStyleSeeker)
//            {
//                SWObjectBroswerController *obc = [[SWObjectBroswerController alloc] initWithModelObject:modelObject];
//                obc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
//                obc.acceptedTypes = _acceptedTypes;
//                obc.delegate = _delegate;
//                obc.browsingStyle = _browsingStyle;
//                
//                [self.navigationController pushViewController:obc animated:YES];
//            }
//        }
//    }
//}






- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (tableView.editing)
    {
        [self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
    }
    else
    {
        SWObject *modelObject = [[_documentModel objectsOfType:_arrayType] objectAtIndex:indexPath.row];
        
        if (_arrayType == SWArrayTypePages)
        {
            SWPage *page = [_documentModel.pages objectAtIndex:indexPath.row];
            SWPageBrowserController *pbc = [[SWPageBrowserController alloc] initWithPage:page];
            //pbc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
            pbc.preferredContentSize = self.preferredContentSize;
            //pbc.acceptedTypes = _acceptedTypes;
            pbc.delegate = _delegate;
            pbc.browsingStyle = _browsingStyle;
            
            [self.navigationController pushViewController:pbc animated:YES];
        }
        else if (_arrayType == SWArrayTypeSources)
        {
            SWSourceItem *source = [_documentModel.sourceItems objectAtIndex:indexPath.row];
            SWSourceVariablesBrowserController *vlc = [[SWSourceVariablesBrowserController alloc] initWithSourceItem:source];
            //vlc.acceptedTypes = _acceptedTypes;
            vlc.delegate = _delegate;
            vlc.browsingStyle = _browsingStyle;
            vlc.title = NSLocalizedString(@"Source", nil);
            //vlc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
            vlc.preferredContentSize = self.preferredContentSize;
            
            [self.navigationController pushViewController:vlc animated:YES];
        }
        else
        {
            if (_browsingStyle == SWModelBrowsingStyleManagement)
            {
                // desmarquem si cal la seleccio actual
                if ( !_documentModel.allowsMultipleSelection )
                {
                    NSMutableIndexSet *indexSet = [self indexSetForItemsInSelectedRowsWithSection:section];
                    [indexSet removeIndex:row];
                    
                    // ^-- necesari perque en aquest moment row ja conta com seleccionat i per una extranya rao acaba deseleccionat
                    [self unmarkItemsInSection:section atIndexes:indexSet];
                }
            
                [self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
            }
            else if (_browsingStyle == SWModelBrowsingStyleSeeker)
            {
                SWObjectBroswerController *obc = [[SWObjectBroswerController alloc] initWithModelObject:modelObject];
                //obc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
                obc.preferredContentSize = self.preferredContentSize;
                //obc.acceptedTypes = _acceptedTypes;
                obc.delegate = _delegate;
                obc.browsingStyle = _browsingStyle;
                
                [self.navigationController pushViewController:obc animated:YES];
            }
        }
    }
}




- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
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
        [selection addIndex:indexPath.row];
    }
    
    NSData *data = nil;
    
    // copy, duplicate
    if ( action == ActionCopy || action == ActionDuplicate )
    {
        NSArray *objects= [[_documentModel objectsOfType:_arrayType] objectsAtIndexes:selection];
        data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
                                                               forKey:kSymbolicCodingCollectionKey
                                                              version:SWVersion];
    }
    
    // copy
    if ( action == ActionCopy )
    {
        [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:[self _pasteboardType]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
    }
    
    // paste
    if ( action == ActionPaste )
    {
        data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:[self _pasteboardType]];
    }
    
    // paste, duplicate
    if ( action == ActionPaste || action == ActionDuplicate )
    {
        NSError *error = nil;
        NSArray *objects = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                                        forKey:kSymbolicCodingCollectionKey
                                                        builder:_documentModel.builder
                                                        parentObject:_documentModel
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
            [_documentModel insertObjects:objects atIndexes:nil ofType:_arrayType];
        }
    }

    _actionSheet = nil;
}


//- (void)actionSheetVVV:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstButtonIndex = actionSheet.firstOtherButtonIndex + 1;
//    
//    Action action = ActionNone;
//    
//    ActionSheetType type = actionSheet.tag;
//    
//    if (type == ActionSheetTypeEmpty)
//    {
//        // Nothing to do
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
//        [selection addIndex:indexPath.row];
//    
//    NSData *data = nil;
//    
//    // copy, duplicate
//    if ( action == ActionCopy || action == ActionDuplicate )
//    {
//        NSArray *objects= [[_documentModel objectsOfType:_arrayType] objectsAtIndexes:selection];
//        data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
//                                                               forKey:kSymbolicCodingCollectionKey
//                                                              version:SWVersion];
//    }
//    
//    // copy
//    if ( action == ActionCopy )
//    {
//        [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:[self _pasteboardType]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
//    }
//    
//    // paste
//    if ( action == ActionPaste )
//    {
//        data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:[self _pasteboardType]];
//    }
//    
//    // paste, duplicate
//    if ( action == ActionPaste || action == ActionDuplicate )
//    {
//        NSError *error = nil;
//        NSArray *objects = [SymbolicUnarchiver unarchivedObjectsWithData:data
//                                                        forKey:kSymbolicCodingCollectionKey
//                                                        builder:_documentModel.builder
//                                                        parentObject:_documentModel
//                                                        version:SWVersion
//                                                        outError:&error];
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
//            [_documentModel insertObjects:objects atIndexes:nil ofType:_arrayType];
//        }
//    }
//
//    _actionSheet = nil;
//}




@end

#pragma mark - Model Observation

@implementation SWArrayTypeBrowserController (ModelObserver)

- (void)documentModel:(SWDocumentModel *)docModel didInsertObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet *)indexes
{
    if (type != _arrayType)
        return;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self revalidateToolbarButtons];
}


//- (void)documentModelNOOR:(SWDocumentModel*)docModel willRemoveObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet*)indexes;
//{
//    NSArray *deletingObjects = [[docModel objectsOfType:type] objectsAtIndexes:indexes];
//    
//    // Comprobem que no hi hagi cap controlador pushat al stack del navCtrll que depengui del objecte eliminat.
//    
//    NSArray *viewControllers = self.navigationController.viewControllers;
//    NSInteger selfIndex = [viewControllers indexOfObjectIdenticalTo:self];
//    
//    //NSInteger nextIndex = viewControllers.count >= (selfIndex+1) ? NSNotFound : (selfIndex + 1);
//    
//    NSInteger nextIndex = selfIndex + 1;
//    
//    if (nextIndex >= viewControllers.count)
//        nextIndex = NSNotFound;
//    
//    if (nextIndex != NSNotFound)
//    {
//        UIViewController *vc = [viewControllers objectAtIndex:nextIndex];
//        
//        id object = nil;
//        
//        switch (type)
//        {
//            case SWArrayTypePages:
//                object = [(SWPageBrowserController*)vc page];
//                break;
//                
//            case SWArrayTypeSources:
//                object = [(SWSourceVariablesBrowserController*)vc sourceItem];
//                break;
//                
//            case SWArrayTypeAlarms:
//            case SWArrayTypeBackgroundItems:
//            case SWArrayTypeSystemItems:
//                // Nothing to do!
//                break;
//        }
//        
//        if (object)
//        {
//            if ([deletingObjects containsObject:object])
//            {
//                [self.navigationController popToViewController:self animated:YES];
//            }
//        }
//    }
//}


- (void)documentModel:(SWDocumentModel *)docModel didRemoveObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet *)indexes
{
    if (type != _arrayType)
        return;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self revalidateToolbarButtons];
}

- (void)documentModel:(SWDocumentModel *)docModel didMoveObjectOfType:(SWArrayType)type atIndex:(NSInteger)index toIndex:(NSInteger)finalIndex
{
    if (type != _arrayType)
        return;
    
    if (!_isMoving)
        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] toIndexPath:[NSIndexPath indexPathForRow:finalIndex inSection:0]];
    
}

- (void)documentModel:(SWDocumentModel *)docModel didSelectObjectOfType:(SWArrayType)type atIndex:(NSInteger)index oldIndex:(NSInteger)oldIndex
{
    if (type != _arrayType)
        return;

    [self _markCellAtIndex:index];
}


//- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel*)docModel
//{
//    UITableView *table = self.tableView;
//    BOOL multipleSelection = docModel.allowsMultipleSelection && ![self _isIntermediateController];
//    [table setAllowsMultipleSelection:multipleSelection];
//}

#pragma mark - Add Object View Controller

- (void)addObjectViewController:(SWAddObjectViewController *)controller didAddObject:(id)object
{
    [self _dismissPopViewsAnimated:YES];
}

@end
