//
//  SWSourceVariablesListController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWSourceVariablesBrowserController.h"

//#import "SWViewControllerNotifications.h"

#import "SWModelBrowserCell.h"
#import "SWTableSectionHeaderView.h"
#import "SWTableViewMessage.h"

#import "SWNavBarTitleView.h"
//#import "SWPickerViewController.h"
#import "SWTableFieldsController.h"


//#import "SWFloatingPopoverManager.h"

//#import "SWConfigurationController.h"
#import "SWDocumentModel.h"
#import "SWSourceNode.h"
#import "SWSourceItem.h"

#import "SWPasteboardTypes.h"
#import "SWSourceCell.h"
#import "SWTagCell.h"

#import "SWReadExpression.h"

#import "BubbleView.h"

#import "SWColor.h"
#import "Drawing.h"

#import "SWAlertCenter.h"
#import "SWModelManager.h"

typedef enum {
    ActionSheetTypeEmpty = 0,
    ActionSheetTypeSelection = 1 << 0,
    ActionSheetTypePaste = 1 << 1
} ActionSheetType;

typedef enum {
    ActionNone          = 0,
    ActionCopy          = 1,
    ActionPaste         = 2,
    ActionDuplicate     = 3
} Action;

static NSString *sourceConfigurationCellIdentifier = @"sourceConfigurationCellIdentifier";
//static NSString *sourceVariableCellIdentifier = @"sourceVariableCellIdentifier";

NSString * const SWSourceNodesDidChangeNotification = @"SWSourceNodesDidChangeNotifiaction";

enum
{
    SectionSource = 0,
    SectionTagList,
    SectionsCount
};



@interface SWSourceVariablesBrowserController() <SWModelBrowserViewController, UIActionSheetDelegate, SourceItemObserver, DocumentModelObserver,SWTagCellDelegate>
@end

@implementation SWSourceVariablesBrowserController
{
    UIActionSheet *_actionSheet;
    NSArray *_actionSheetTitles;
    SWNavBarTitleView *_titleView;
    SWModelManager *_modelManager;
    BOOL _isSourceSectionHidden;
    
    NSInteger _tagSection;
    BubbleView *_bubbleView;
}



#pragma mark protocol SWModelBrowserViewController

//@synthesize browsingStyle = _browsingStyle;
//@synthesize delegate = _delegate;
@synthesize identifiyingObject = _identifiyingObject;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[SWSourceItem class]], @"objecte erroni per controlador" );
    self = [self initWithSourceItem:object];
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



@synthesize sourceItem = _sourceItem;


- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithSourceItem:nil];
}

- (id)initWithSourceItem:(SWSourceItem *)sourceItem
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _sourceItem = sourceItem;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
        if ( _identifiyingObject == nil ) _identifiyingObject = sourceItem;
        //self.title = NSLocalizedString(@"Source Variables", nil);
        self.title = sourceItem.identifier;
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"PLC Connector", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;
        
    }
    return self;
}

//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    
//    self.title = NSLocalizedString(@"Source Variables", nil);
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44;
    
    if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        UINavigationItem *navItem = self.navigationItem;
        if (navItem.rightBarButtonItem == self.editButtonItem)
            navItem.rightBarButtonItem = nil;
    }
    
    [self setSelectedNode:_selectedNode];
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    NSString *message = _browsingStyle == SWModelBrowsingStyleManagement ? @"SourceVariablesListControllerFooter" : @"SourceVariablesListControllerFooter2";
    [messageView setMessage:NSLocalizedString(message, nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Tags", nil)];
    
    UITableView *table = self.tableView;
    [table setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [table setTableFooterView:messageView];
    
    [_sourceItem addObjectObserver:self];
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
//        SWDocumentModel *docModel = _sourceItem.docModel;
//        [table setAllowsMultipleSelection:docModel.allowsMultipleSelection];
//        [docModel addObserver:self];
        [table setAllowsMultipleSelection:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        //[self.navigationController setToolbarHidden:NO animated:NO];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revalidateToolbarButtons)
            name:kPasteboardContentDidChangeNotification object:nil];
        
        [self _establishSourceSectionAnimated:animated];
    }
    
    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
//        SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
//        SWValue *value = [manager currentSeekedValue];
        SWValue *value = [_modelManager currentSeekedValue];
        if ([value isKindOfClass:[SWReadExpression class]])
        {
            SWReadExpression *readExp = (SWReadExpression*)value;
            [self setSelectedNode:readExp.node animated:NO];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
    
//    if ( _browsingStyle == SWModelBrowsingStyleManagement )
//        [_sourceItem.docModel removeObserver:self];
    
    [_sourceItem removeObjectObserver:self];
}

#pragma mark Properties

- (void)setSourceItem:(SWSourceItem *)sourceItem
{
    _sourceItem = sourceItem;
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
//        
//        //self.clearsSelectionOnViewWillAppear = NO;
//    }
//    else
//    {
//        navItem.rightBarButtonItem = editButton;
//        //self.clearsSelectionOnViewWillAppear = YES;
//    }
//}

#pragma mark Public Methods

- (void)setSelectedNode:(SWSourceNode *)selectedNode
{
    [self setSelectedNode:selectedNode animated:NO];
}

- (void)setSelectedNode:(SWSourceNode *)selectedNode animated:(BOOL)animated
{
    _selectedNode = selectedNode;
    
    if (!self.isViewLoaded)
        return;
    
    NSIndexPath *indexPath = nil;
    NSInteger row = [_sourceItem.sourceNodes indexOfObjectIdenticalTo:_selectedNode];
    
    if (row != NSNotFound)
        indexPath = [NSIndexPath indexPathForRow:row inSection:_tagSection];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark Overriden Methods

- (void)add:(id)sender
{
    [self _dismissPopViewsAnimated:NO];

    NSInteger indx = _sourceItem.sourceNodes.count;
    BOOL done = [_sourceItem insertNewVariablesAtIndexes:[NSIndexSet indexSetWithIndex:indx]];
    
    if (!done)
        NSLog( @"[fhu099] Error adding new variable" );
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SWSourceNodesDidChangeNotification object:self userInfo:nil];
}

//- (void)configureV:(id)sender
//{
//    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
//    NSMutableIndexSet *variableIndexes = [NSMutableIndexSet indexSet];
//    
//    for (NSIndexPath *indexPath in indexPaths)
//        [variableIndexes addIndex:indexPath.row];
//    
//    NSArray *array = [_sourceItem.sourceNodes objectsAtIndexes:variableIndexes];
//    
//    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
//    [manager presentModelConfiguratorForObject:array animated:NO];
//}


- (void)configure:(id)sender
{
    [self _dismissPopViewsAnimated:NO];
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    //SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
    
    NSMutableArray *presentedNodes = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        if ( section == SectionSource )
        {

            //[_modelManager presentModelConfiguratorForObject:_sourceItem animated:NO presentingControllerKey:nil];
            [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:_sourceItem animated:IS_IPHONE];

           // [manager presentModelConfiguratorForObject:_sourceItem animated:NO presentingControllerKey:nil];

        }
        else if ( section == SectionTagList )
        {
            [presentedNodes addObject:[_sourceItem.sourceNodes objectAtIndex:row]];
        }
    }
    
    if ( presentedNodes.count > 0 )
    
        //[_modelManager presentModelConfiguratorForObject:presentedNodes animated:NO presentingControllerKey:nil];
        [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:presentedNodes animated:IS_IPHONE];

//        [manager presentModelConfiguratorForObject:presentedNodes animated:NO presentingControllerKey:nil];

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
    ];
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *anyIndexPath = nil;
    NSInteger section = NSNotFound;
    if ( indexPaths.count > 0)
    {
        anyIndexPath = indexPaths[0];
        section = anyIndexPath.section;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    }
    
    if ( section == SectionTagList )
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionCopy]];
    }
    
    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeTagList]])
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionPaste]];
    }
    
    if ( section == SectionTagList )
    {
        [_actionSheet addButtonWithTitle:_actionSheetTitles[ActionDuplicate]];
    }
    
    [_actionSheet showFromBarButtonItem:sender animated:YES];
}


//- (void)actionVVV:(id)sender
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
//        NSIndexPath *indexPath = indexPaths[0];  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
//    
//        if ( indexPath.section == SectionTagList )
//        {
//            [_actionSheet addButtonWithTitle:NSLocalizedString(@"Duplicate",nil)];
//            [_actionSheet addButtonWithTitle:NSLocalizedString(@"Copy",nil)];
//            _actionSheet.tag |= ActionSheetTypeSelection;
//        }
//    }
//    
//    if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeTagList]])
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
        [indexSet addIndex:indexPath.row];    // <--- Sabem que el trash nomes pot apareixer per items de la seccio SectionTagList
        
    [_sourceItem removeVariablesAtIndexes:indexSet];

    [[NSNotificationCenter defaultCenter] postNotificationName:SWSourceNodesDidChangeNotification object:self userInfo:nil];
    //[self revalidateToolbarButtons];
}



- (BOOL)validateActionButton
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *indexPath = indexPaths.lastObject;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    
    BOOL enabled = (indexPath && indexPath.section == SectionTagList);
    
    enabled = enabled || [[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeTagList]];
    
    return enabled;
}


- (BOOL)validateTrashButton
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *indexPath = indexPaths.lastObject;  // <--- Sabem que tots els indexpaths seran de la mateixa seccio
    return (indexPath.section == SectionTagList );
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSIndexSet *indexSet = nil;
    
    if ( _browsingStyle == SWModelBrowsingStyleManagement )
    {
        if ( editing )
        {
            indexSet = [self indexSetForItemsInSelectedRowsWithSection:SectionTagList];
        }
    
        [super setEditing:editing animated:animated];   // <-- Super

        if ( editing )
        {
            // el table view ho deselecciona tot al canviar l'estat de edicio, ho tornem a recuperar
            [self markItemsInSection:SectionTagList atIndexes:indexSet scrollToVisible:NO animated:NO];
        }
        else
        {
            // si marxem del mode edit quedara tot deseleccionat
        }
        [self _establishSourceSectionAnimated:animated];
    }
    else
    {
        [super setEditing:editing animated:animated];
    }
}


//- (NSIndexSet*)indexSetForItemsInSelectedRowsWithSection:(NSInteger)aSection
//{
//    UITableView *tableView = self.tableView;
//    NSArray *indexPaths = [tableView indexPathsForSelectedRows];
//    
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    for ( NSIndexPath *indexPath in indexPaths )
//    {
//        NSInteger section = indexPath.section;
//        NSInteger row = indexPath.row;
//        if ( section == aSection )
//            [indexSet addIndex:row];
//    }
//    return indexSet;
//}


#pragma mark Private Methods



- (void)_establishSourceSectionAnimated:(BOOL)animated
{
    BOOL editing = self.editing;
    BOOL changed = editing != _isSourceSectionHidden;
    
    if ( !changed )
        return;
    
    _isSourceSectionHidden = editing;
    
    UITableView *tableView = self.tableView;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:SectionSource];
    UITableViewRowAnimation animationKind = (animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone);
    [tableView reloadSections:indexSet withRowAnimation:animationKind];
}








- (void)_dismissPopViewsAnimated:(BOOL)animated
{
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:animated];
    _actionSheet = nil;
}


////#warning JoanLL! si vols fer un "marcatge" diferent en les celles, fes-ho a la classe SWEditableTableViewController, que és classe mare de tots els controladors de manipulació d'objectes del model browser, així tots heretaran el mateix disseny! (En particular, aquesta classe està pendent de ser modificada per tal de ser filal de SWEditableTableViewController).
//
////#warning, No em serveix perque el que vull es deixar el estil per defecte de iOS en el browser, i fer un estil especial per la seleccio a la lupa, per tant crec que ho de de posar aqui, i al SWValueViewerCell. Lo bonic seria que les source variables poguessin utilitzar el SWObjectBrowserController per el cas de la lupa
//- (void)_setSelectedBackgroundsForCell:(SWTagCell *)cell
//{
//    if ( _browsingStyle == SWModelBrowsingStyleManagement )
//    {
//        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        UIColor *color = UIColorWithRgb(MultipleSelectionColor);
//        selectionView.backgroundColor = color;
//        
//        [cell setSelectedBackgroundView:selectionView];
//        
//        cell.valuePropertyLabel.highlightedTextColor = cell.valuePropertyLabel.textColor;
//        cell.valueSemanticTypeLabel.highlightedTextColor = cell.valueSemanticTypeLabel.textColor;
//        cell.valueAsStringLabel.highlightedTextColor = cell.valueAsStringLabel.textColor;
//    }
//    
//    else if ( _browsingStyle == SWModelBrowsingStyleSeeker )
//    {
//        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
//        selectionView.backgroundColor = color;
//        
//        [cell setSelectedBackgroundView:selectionView];
//
//        cell.valuePropertyLabel.highlightedTextColor = UIColorWithRgb(TangerineSelectionColor);
//        cell.valueSemanticTypeLabel.highlightedTextColor = cell.valueSemanticTypeLabel.textColor;
//        cell.valueAsStringLabel.highlightedTextColor = cell.valueAsStringLabel.textColor;
//    }
//}



#pragma mark BubbleView management

- (void)_dismissMessageViewAnimated:(BOOL)animated
{
    if ( _bubbleView )
    {
        [_bubbleView dismissAnimated:YES];
        _bubbleView = nil;
    }
}

- (void)bubbleViewTouched:(BubbleView*)sender
{
    [self _dismissMessageViewAnimated:YES];
}


#pragma mark SWTacCell delegate

- (void)tagCell:(SWTagCell*)cell presentMessage:(NSString*)msg fromView:(UIView*)view
{
    if ( _bubbleView == nil )
    {
        _bubbleView = [[BubbleView alloc] initWithPresentingView:self.tableView];
        _bubbleView.delegate = self;
    }
    
    [_bubbleView presentFromView:view vGap:12.0f message:msg animated:YES];
}

- (void)tagCellDismissMessage:(SWTagCell *)cell
{
    [self _dismissMessageViewAnimated:YES];
}

#pragma mark ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _dismissMessageViewAnimated:YES];
}


#pragma mark Protocol Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        count = SectionsCount;
        _tagSection = 1;
    }
    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        count = 1;
        _tagSection = 0;
    }
    
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = 0;
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        switch (section)
        {
            case SectionSource:
                if ( !_isSourceSectionHidden )
                    rowsCount = 1;
                    break;
            
            case SectionTagList:
                rowsCount = _sourceItem.sourceNodes.count;
                break;
            
            default:
                break;
        }
    }
    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        rowsCount = _sourceItem.sourceNodes.count;
        [(id)tableView.tableFooterView showForEmptyTable:(rowsCount==0)];
        [tableView setScrollEnabled:(rowsCount>0)];
    }

    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *defaultCell = @"defaultCell";
    
    NSString *identifier = nil;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        switch (section)
        {
            case SectionSource:
                identifier = sourceConfigurationCellIdentifier;
                break;
                
            case SectionTagList:
                identifier = SWTagCellIdentifier;
                break;
                
            default:
                identifier = defaultCell;
                break;
        }
    }
    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        identifier = SWTagCellIdentifier;
    }
        
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
    if (cell == nil)
    {
        if ([identifier isEqualToString:sourceConfigurationCellIdentifier])
        {
            SWSourceCell *sourceCell = [[SWSourceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sourceConfigurationCellIdentifier];
            sourceCell.rightDetailType = SWSourceCellRightDetailTypeConnectionStatus;
            sourceCell.accessory = SWModelBrowserCellAccessoryTypeGearIndicator;
            cell = sourceCell;
            // ^-- el selected background esta configurat a SWObjectCell
        }
        else if ([identifier isEqualToString:SWTagCellIdentifier])
        {
            NSString *nibName = IS_IOS7?SWTagCellNibName:SWTagCellNibName6;
            UINib *cellNib = [UINib nibWithNibName:nibName bundle:nil];
            SWTagCell *tagCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
            NSAssert( [tagCell.reuseIdentifier isEqualToString:SWTagCellIdentifier], nil );
            tagCell.delegate = self;
            tagCell.accessory = _browsingStyle==SWModelBrowsingStyleManagement?SWValueCellAccessoryTypeGearIndicator:SWValueCellAccessoryTypeSeekerIndicator;
            cell = tagCell;
        
            //[self _setSelectedBackgroundsForCell:(SWTagCell*)cell];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCell];
        }
    }
    
    if ([identifier isEqualToString:sourceConfigurationCellIdentifier])
    {
        SWSourceCell *sourceCell = (id)cell;
        sourceCell.modelObject = _sourceItem;
    }
    else if ([identifier isEqualToString:SWTagCellIdentifier])
    {
        SWTagCell *tagCell = (SWTagCell*)cell;
        SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:row];
        tagCell.sourceNode = node;
        
        UIView *accessory = nil ;
        if ( _browsingStyle == SWModelBrowsingStyleManagement )
        {
            //accessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"14-geargray.png"]];
        }
        tagCell.accessoryView = accessory;
        
//        if ( _browsingStyle == SWModelBrowsingStyleSeeker || cell.isEditing )
//        {
//            UILabel *variableNameField = varCell.variableNameField;
//            UILabel *expressionField = varCell.expressionField;
//            UILabel *memoryAddressField = varCell.memoryAddresField;
//            variableNameField.highlightedTextColor =  variableNameField.textColor;
//            memoryAddressField.highlightedTextColor =  memoryAddressField.textColor;
//            expressionField.highlightedTextColor = expressionField.textColor;
//        }
    }
    else
    {
        cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionSource)
        return NO;
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionSource)
        return NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    _isMoving = YES;
    [_sourceItem moveNodeAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    _isMoving = NO;
}

- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.section == 0)
        return sourceIndexPath;
    
    return proposedDestinationIndexPath;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    
    if (section == SectionTagList)
    {
        SWTableSectionHeaderView *header = [[SWTableSectionHeaderView alloc] init];
        header.title = NSLocalizedString(@"TAGS", nil);
        view = header;
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SectionTagList)
        return 30;
    
    return 0;
}

 #pragma mark Protocol Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
    
//    if (indexPath.section == SectionSourceConfiguration)
//        return;
    
    [(SWObjectCell*)cell beginObservingModel];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(SWObjectCell*)cell endObservingModel];
}


//- (void)tableViewVV:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    
//    if (_browsingStyle == SWModelBrowsingStyleSeeker)
//    {
//        SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:indexPath.row];
//        
//        if ([_delegate respondsToSelector:@selector(modelBrowser:didSelectValue:)])
//            [_delegate modelBrowser:self didSelectValue:node.readExpression];
//    }
//    else if (_browsingStyle == SWModelBrowsingStyleManagement)
//    {
//        if (indexPath.section == SectionSource)
//        {
//            SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
//            [manager presentModelConfiguratorForObject:_sourceItem animated:NO];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            return;
//        }
//        
//        if (tableView.editing)
//            return;
//        
//        NSInteger index = indexPath.row;
//        
//        SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:index];
//        
//        SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
//        [manager presentModelConfiguratorForObject:@[node] animated:NO];
//
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        if ( section == SectionSource )
        {
            // desmarquem la possible seleccio de tags
            NSIndexSet *indexSet = [self indexSetForItemsInSelectedRowsWithSection:SectionTagList];
            [self unmarkItemsInSection:SectionTagList atIndexes:indexSet];
        
            // marquem el source
            [self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
        }
        else if ( section == SectionTagList )
        {
            if ( self.isEditing )
            {
                [self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
            }
            else
            {
                // desmarquem la possible seleccio de source
                [self unmarkItemsInSection:SectionSource atIndexes:[NSIndexSet indexSetWithIndex:0]];
            
                // desmarquem si cal la seleccio de tags
                if ( !_sourceItem.docModel.allowsMultipleSelection )
                {
                    NSMutableIndexSet *indexSet = [self indexSetForItemsInSelectedRowsWithSection:SectionTagList];
                    [indexSet removeIndex:row];
                    // ^-- necesari perque en aquest moment row ja conta com seleccionat i per una extranya rao acaba deseleccionat

                    [self unmarkItemsInSection:SectionTagList atIndexes:indexSet];
                }
            
                [self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
            }
        }
    
        //[self markItemsInSection:section atIndexes:[NSIndexSet indexSetWithIndex:row] scrollToVisible:YES animated:YES];
    }

    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:row];
        
        if ([_delegate respondsToSelector:@selector(modelBrowser:didSelectValue:)])
            [_delegate modelBrowser:self didSelectValue:node.readExpression];
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


#pragma mark - Table Selection

//- (void)_markItemsInSection:(NSInteger)section atIndexes:(NSIndexSet*)indexes scrollToVisible:(BOOL)scroll animated:(BOOL)animated
//{
//    __block NSIndexPath *indexPath = nil;
//    UITableView *table = self.tableView;
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        NSInteger row = idx;
//        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//    }];
//    
//    if ( scroll )
//        [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
//    
//    [self revalidateToolbarButtons];
//}
//
//
//- (void)_unmarkItemsInSection:(NSInteger)section atIndexes:(NSIndexSet *)indexes
//{
//    UITableView *table = self.tableView;
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        NSInteger row = idx;
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//        [table deselectRowAtIndexPath:indexPath animated:NO];
//    }];
//    
//    [self revalidateToolbarButtons];
//}


#pragma mark - DocumentModel Observer

//- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel*)docModel
//{
//    UITableView *table = self.tableView;
//    [table setAllowsMultipleSelection:docModel.allowsMultipleSelection];
//}


#pragma mark - SWObjectObserver

- (void)identifierDidChangeForObject:(SWObject *)object
{
//    if (object == _sourceItem )
//    {
        self.title = object.identifier;
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
//    }
}


- (void)willRemoveObject:(SWObject *)object
{
  //  if (object == _sourceItem)
        [self removeFromContainerController];
}

#pragma mark Protocol SourceItemObserver

- (void)sourceItem:(SWSourceItem*)source plcTagDidChange:(SWPlcTag*)plcTag atIndex:(NSInteger)indx
{
    NSInteger section = _tagSection;
    
    UITableView *table = self.tableView;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indx inSection:section];
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)sourceItem:(SWSourceItem *)source didInsertSourceNodesAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:_tagSection];
        [indexPaths addObject:indexPath];
    }];

    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self revalidateToolbarButtons];
}

- (void)sourceItem:(SWSourceItem *)source didRemoveSourceNodesAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:_tagSection];
        [indexPaths addObject:indexPath];
    }];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self revalidateToolbarButtons];
}

- (void)sourceItem:(SWSourceItem *)source didMoveSourceNodeAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)destinationIndex
{
    if (_isMoving)
        return;

    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:_tagSection] toIndexPath:[NSIndexPath indexPathForRow:destinationIndex inSection:_tagSection]];
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
        if ( indexPath.section == SectionTagList )
            [selection addIndex:indexPath.row];
    }
    
    NSData *data = nil;
    
    // copy, duplicate
    if ( action == ActionCopy || action == ActionDuplicate )
    {
        NSArray *objects = [_sourceItem.sourceNodes objectsAtIndexes:selection];
        data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
                                                               forKey:kSymbolicCodingCollectionKey
                                                              version:SWVersion];
    }
    
    // copy
    if ( action == ActionCopy )
    {
        [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:kPasteboardTypeTagList];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
    }
    
    // paste
    if ( action == ActionPaste )
    {
        data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:kPasteboardTypeTagList];
    }
    
    // paste, duplicate
    if ( action == ActionPaste || action == ActionDuplicate )
    {
        NSError *error = nil;
        NSArray *objects = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                                            forKey:kSymbolicCodingCollectionKey
                                                           builder:_sourceItem.builder
                                                       parentObject:_sourceItem
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
            [_sourceItem insertSourceNodes:objects atIndexes:nil];
        }
    }
    

    _actionSheet = nil;
}



- (void)actionSheetVVV:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger firstButtonIndex = actionSheet.firstOtherButtonIndex + 1;
    
    Action action = ActionNone;
    
    ActionSheetType type = actionSheet.tag;
    
    if (type == ActionSheetTypeEmpty)
    {
        // Nothing more to do
        return;
    }
    else if (type == ActionSheetTypeSelection)
    {
        if (buttonIndex == firstButtonIndex)
            action = ActionDuplicate;
        else if (buttonIndex == firstButtonIndex + 1)
            action = ActionCopy;
    }
    else if (type == ActionSheetTypePaste)
    {
        if (buttonIndex == firstButtonIndex)
            action = ActionPaste;
    }
    else if (type == (ActionSheetTypeSelection | ActionSheetTypePaste))
    {
        if (buttonIndex == firstButtonIndex)
            action = ActionDuplicate;
        else if (buttonIndex == firstButtonIndex + 1)
            action = ActionCopy;
        else if (buttonIndex == firstButtonIndex + 2)
            action = ActionPaste;
    }
    
    NSArray *tableViewSelection = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *selection = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in tableViewSelection)
    {
        if ( indexPath.section == SectionTagList )
            [selection addIndex:indexPath.row];
    }
    
    NSData *data = nil;
    
    // copy, duplicate
    if ( action == ActionCopy || action == ActionDuplicate )
    {
        NSArray *objects = [_sourceItem.sourceNodes objectsAtIndexes:selection];
        data = [SymbolicArchiver archivedDataWithArrayOfObjects:objects
                                                               forKey:kSymbolicCodingCollectionKey
                                                              version:SWVersion];
    }
    
    // copy
    if ( action == ActionCopy )
    {
        [[UIPasteboard applicationPasteboard] setData:data forPasteboardType:kPasteboardTypeTagList];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
    }
    
    // paste
    if ( action == ActionPaste )
    {
        data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:kPasteboardTypeTagList];
    }
    
    // paste, duplicate
    if ( action == ActionPaste || action == ActionDuplicate )
    {
        NSError *error = nil;
        NSArray *objects = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                                            forKey:kSymbolicCodingCollectionKey
                                                           builder:_sourceItem.builder
                                                       parentObject:_sourceItem
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
            [_sourceItem insertSourceNodes:objects atIndexes:nil];
        }
    }
    

    _actionSheet = nil;
}

@end
