//
//  SWSourcesViewController.m
//  HmiPad
//
//  Created by Joan Martin on 7/30/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSourcesViewController.h"

#import "SWInspectorViewController.h"

#import "SWTableViewMessage.h"

#import "SWPlcDevice.h"

#import "SWValue.h"

#import "SWSourceTitleCell.h"
#import "SWSourceUpdateRateCell.h"
#import "SWEnableSourceCell.h"
#import "SWSourceStatusCell.h"

#import "SWSourceTagsViewController.h"

static NSString * const TitleCellIdentifier = @"TitleCell";
static NSString * const DisclosureIndicatorCellIdentifier = @"DisclosureIndicatorCell";
static NSString * const EnableSourceCellIdentifier = @"EnableSourceCell";
static NSString * const UpdateRateCellIdentifier = @"UpdateRateCell";
static NSString * const StatusCellIdentifier = @"StatusCell";

#if HMiPadDev
enum {
    SWCellRowTitleCell,
    SWCellRowEnableSourceCell,
    SWCellRowUpdateRateCell,
    SWCellRowTagsCell,
    SWCellRowStatusCell,
    
    SWCellRowTotalRowsWithStatusCell,
    
        SWCellRowConfigureCell,
};
#endif

#if HMiPadRun
enum {
    SWCellRowTitleCell,
    SWCellRowEnableSourceCell,
    SWCellRowUpdateRateCell,
    SWCellRowStatusCell,
    
    SWCellRowTotalRowsWithStatusCell,
    
        SWCellRowTagsCell,
        SWCellRowConfigureCell,
};
#endif


@interface SWSourcesViewController ()
@end

@interface SWSourcesViewController (ModelObserver) <DocumentModelObserver>
@end

@implementation SWSourcesViewController
{
    NSMutableArray *_waitingInsertPaths;
    NSMutableArray *_waitingDeletePaths;
    //CGPoint _offset;
}

//@synthesize enableConnectionsSwitch = _enableConnectionsSwitch;

@synthesize documentModel = _documentModel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //_offset = CGPointZero;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = nil;
    
    UITableView *tableView = self.tableView;     // es un SWTableView
        
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //tableView.separatorColor = [UIColor colorWithWhite:0.4 alpha:0.5];
    //tableView.separatorColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    if ( ! IS_IOS7 )
        tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.15];

    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [messageView setMessage:NSLocalizedString(HMiPadRun?@"SourcesViewControllerFooterView":@"SourcesViewControllerFooter", nil)];
    [messageView setEmptyMessage:NSLocalizedString(HMiPadRun?@"SourcesViewControllerFooterEmptyView":@"SourcesViewControllerFooterEmpty", nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No PLC Connectors", nil)];
    [tableView setTableFooterView:messageView];
    
    
    
//    [tableView setContentInset:UIEdgeInsetsMake(0, 0, 48, 0)];   // workaround al defecte del UITabBar
//    [tableView setScrollIndicatorInsets:tableView.contentInset];   // workaround al defecte del UITabBar
    
    //_sourceStatusState = [[NSMutableIndexSet alloc] init];
    
    //[self _reloadFromDocumentModel];
}

//- (void)viewDidUnload
//{
//    [self setEnableConnectionsSwitch:nil];  // xxx
//    [super viewDidUnload];
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.editing = self.navigationController.editing;
    
    [self.tableView reloadData];
    [self _updateConnectionsSwitchAnimated:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(_monitorUpdate:) name:kFinsMonitorDidChangeNotification object:nil];
    
    [_documentModel addObserver:self];
    
    
    //[_enableConnectionsSwitch setOn:_documentModel.enableConnections]; // xxx
    //[_headerView.enableConnectionsSwitch setOn:_documentModel.enableConnections];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_documentModel removeObserver:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView reloadData];  // Aixo causa la crida a tableView:didEndDisplayingCell de les celdes, cool!
}



#pragma mark Properties

- (void)setDocumentModel:(SWDocumentModel *)documentModel
{
    _documentModel = documentModel;
    
    if (self.isViewLoaded)
        [self.tableView reloadData];
}

#pragma mark Private Methods


- (void)_monitorUpdate:(NSNotification*)notification
{
    SWSourceItem *sourceItem = [notification object];
    NSInteger sectionIndex = [_documentModel.sourceItems indexOfObjectIdenticalTo:sourceItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:SWCellRowStatusCell inSection:sectionIndex];

    if ( _waitingInsertPaths == nil || _waitingDeletePaths == nil )
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            UITableView *tableView = self.tableView;
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:_waitingInsertPaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteRowsAtIndexPaths:_waitingDeletePaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            
            _waitingInsertPaths = nil;
            _waitingDeletePaths = nil;
        });
    }
       
    if ( _waitingInsertPaths == nil )
         _waitingInsertPaths = [NSMutableArray array];
    
    if ( _waitingDeletePaths == nil )
         _waitingDeletePaths = [NSMutableArray array];
    
    if ( sourceItem.monitorOn )
        [_waitingInsertPaths addObject:indexPath];
    else
        [_waitingDeletePaths addObject:indexPath];
}



#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _documentModel.sourceItems.count;
    
    [(id)tableView.tableFooterView showForEmptyTable:(sectionCount==0)];
    [tableView setScrollEnabled:(sectionCount>0)];
    
    [tableView.tableHeaderView setHidden:(sectionCount==0)];
    
    return sectionCount;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger rows = SWCellRowStatusCell;
//    
//    // Si cal, afegim una row per al status cell
//    if ([_sourceStatusState containsIndex:section])
//    {
//        rows++;
//    }
//    
//    return rows;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = SWCellRowTotalRowsWithStatusCell-1;
    
    // Si cal, afegim una row per al status cell
    SWSourceItem *sourceItem = [_documentModel.sourceItems objectAtIndex:section];
    if (sourceItem.monitorOn)
    {
        rows++;
    }
    
    return rows;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    NSString *identifier = nil;
    
    switch (indexPath.row)
    {
        case SWCellRowTitleCell:
            identifier = TitleCellIdentifier;
            break;
        case SWCellRowUpdateRateCell:
            identifier = UpdateRateCellIdentifier;
            break;
        case SWCellRowEnableSourceCell:
            identifier = EnableSourceCellIdentifier;
            break;
        case SWCellRowStatusCell:
            identifier = StatusCellIdentifier;
            break;
        case SWCellRowConfigureCell:
        case SWCellRowTagsCell:
            identifier = DisclosureIndicatorCellIdentifier;
            break;
        default:
            identifier = CellIdentifier;
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if ([cell isKindOfClass:[SWSourceItemCell class]])
    {
        NSInteger index = indexPath.section;
        
        SWSourceItem *sourceItem = [_documentModel.sourceItems objectAtIndex:index];
        SWSourceItemCell *sourceItemCell = (SWSourceItemCell*)cell;
        sourceItemCell.sourceItem = sourceItem;
        
//        if ([cell isKindOfClass:[SWSourceTitleCell class]])
//        {
//            SWSourceTitleCell *titleCell = (SWSourceTitleCell*)cell;
//            titleCell.decorationSymbolEnabled = YES;
//        }
    }
        
    switch (indexPath.row)
    {
        case SWCellRowEnableSourceCell:
        {
//            SWEnableSourceCell *enableCell = (id)cell;
//            enableCell.enableSourceSwitch.enabled = _enableConnectionsSwitch.isOn;
            break;
        }
            
        case SWCellRowConfigureCell:
            cell.textLabel.text = NSLocalizedString(@"Settings",nil);
            break;
        case SWCellRowTagsCell:
            cell.textLabel.text = NSLocalizedString(@"Tags",nil);
            break;
        default:
            identifier = CellIdentifier;
            break;
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SWSourceItem *sourceItem = [_documentModel.sourceItems objectAtIndex:section];
    NSString *title = [sourceItem.plcDevice protocolAsString];
    return title;
}



#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( !IS_IOS7 && indexPath.row == SWCellRowTitleCell)
    {
        //cell.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    }
    else
    {
        cell.backgroundColor = [(SWInspectorViewController*)self.tabBarController preferredCellBackgroundColor];
    }
    
    if ( [cell respondsToSelector:@selector(beginObservingModel)] )
        [(id)cell beginObservingModel];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell respondsToSelector:@selector(endObservingModel)] )
        [(id)cell endObservingModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SWCellRowStatusCell)
        return 50;

    return 44;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == SWCellRowConfigureCell || row == SWCellRowTagsCell)
    {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SWCellRowTagsCell)
    {
        SWSourceItem *sourceItem = [_documentModel.sourceItems objectAtIndex:indexPath.section];
        SWSourceTagsViewController *tags = [[SWSourceTagsViewController alloc] initWithSourceItem:sourceItem];
        [self.navigationController pushViewController:tags animated:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

//- (void)dealloc
//{
//    NSLog( @"SourcesViewcontroller dealloc");
//}


#pragma mark Model update

- (IBAction)enableConnections:(id)sender
{
    BOOL enable = _enableConnectionsSwitch.isOn;    //xxx
    _documentModel.enableConnections = enable;
}


#pragma mark - View update

- (void)_updateConnectionsSwitchAnimated:(BOOL)animated
{
    BOOL enabled = _documentModel.enableConnections;
    [_enableConnectionsSwitch setOn:enabled animated:animated];
}


@end



#pragma mark SWEventCenterObserver




@implementation SWSourcesViewController (ModelObserver)

- (void)documentModel:(SWDocumentModel *)docModel didInsertSourceItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationFade];
}

- (void)documentModel:(SWDocumentModel *)docModel didRemoveSourceItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationFade];
}

- (void)documentModelEnableConnectionsDidChange:(SWDocumentModel *)docModel
{
    //[_enableConnectionsSwitch setOn:docModel.enableConnections animated:YES]; //xxx
    //[_headerView.enableConnectionsSwitch setOn:docModel.enableConnections animated:YES];
    [self _updateConnectionsSwitchAnimated:YES];
}

- (void)documentModel:(SWDocumentModel *)docModel didMoveSourceItemAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex
{
    [self.tableView moveSection:index toSection:finalIndex];
}


@end

