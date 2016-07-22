//
//  SWSourceTagsViewController.m
//  HmiPad
//
//  Created by Joan Martin on 7/30/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSourceTagsViewController.h"
#import "SWInspectorViewController.h"
#import "SWTableViewMessage.h"

#import "BubbleView.h"

#import "SWTagCell.h"
#import "SWColor.h"



//#import "SWViewControllerNotifications.h"

//static NSString * const TagCellIdentifier = @"sourceVariableCellIdentifier";

@interface SWSourceTagsViewController()<SWTagCellDelegate>
{
    BubbleView *_bubbleView;
}
@end

@implementation SWSourceTagsViewController

@synthesize sourceItem = _sourceItem;

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithSourceItem:nil];
}

- (id)initWithSourceItem:(SWSourceItem*)sourceItem
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _sourceItem = sourceItem;
        self.title = NSLocalizedString(@"Tags",nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = self.tableView;  // es un SWTableView
    
    
    NSString *nibName = IS_IOS7?SWTagCellNibName:SWTagCellNibName6;
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:SWTagCellIdentifier];
    
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    
//    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    table.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [messageView setMessage:NSLocalizedString(@"SourceTagsViewControllerFooter", nil)];
    [messageView setEmptyMessage:NSLocalizedString(@"SourceTagsViewControllerFooterEmpty", nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Tags", nil)];
    [tableView setTableFooterView:messageView];
    
    //[table setContentInset:UIEdgeInsetsMake(0, 0, 48, 0)];   // workaround al defecte del UITabBar
    //[table setScrollIndicatorInsets:table.contentInset];   // workaround al defecte del UITabBar
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITableView *table = self.tableView;
    [table reloadData];
    
    // 1
    // workaround per evitar la visualitzacio del sourcesViewController a sota d'aquest,
    // posem temporalment de fons el color del tabController pero sense transparencia
//    UITabBarController *tabController = [self tabBarController];
//    UIColor *tmpBackColor = [tabController.view.backgroundColor colorWithAlphaComponent:1.0];
//    UIColor *tmpBackColor = [UIColor colorWithWhite:1.0 alpha:0.8];
//    [table setBackgroundColor:tmpBackColor];

    // 1
    // workaround per evitar la visualitzacio del sourcesViewController a sota d'aquest,
    UIViewController *root = [self.navigationController viewControllers][0];
    UIView *rview = root.view;
    [UIView animateWithDuration:animated?0.2:0 animations:^
    {
        rview.alpha = 0;
    }];
    
    
    [_sourceItem addObjectObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 2
    // tornem amb animacio el color que hauria de tenir
//    UITableView *table = self.tableView;
//    [UIView animateWithDuration:animated?0.2:0 animations:^
//    {
//        table.backgroundColor = [UIColor clearColor];
//    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // 3
    // workaround per evitar la visualitzacio del sourcesViewController a sota d'aquest,
    // posem temporalment de fons el color del tabController pero sense transparencia
//    UITableView *table = self.tableView;
//    UITabBarController *tabController = [self tabBarController];
//    UIColor *tmpBackColor = [tabController.view.backgroundColor colorWithAlphaComponent:1.0];
//    UIColor *tmpBackColor = [UIColor colorWithWhite:1.0 alpha:0.8];
//    [table setBackgroundColor:tmpBackColor];
    
    // 2
    // tornem amb animacio el color que hauria de tenir
    UIViewController *root = [self.navigationController viewControllers][0];
    UIView *rview = root.view;
    [UIView animateWithDuration:animated?0.2:0 animations:^
    {
        rview.alpha = 1;
    }];
    
    [_sourceItem removeObjectObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView reloadData];  // Aixo causa la crida a tableView:didEndDisplayingCell de les celdes, cool!
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = _sourceItem.sourceNodes.count;
    
    [(id)tableView.tableFooterView showForEmptyTable:(rowsCount==0)];
    [tableView setScrollEnabled:(rowsCount>0)];
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SWTagCellIdentifier];
    
    SWTagCell *tagCell = (SWTagCell*)cell;
    
    NSInteger indx = indexPath.row;
    
    SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:indx];
    tagCell.delegate = self;
    tagCell.sourceNode = node;
    
    if ( IS_IOS7 )
    {
//        variableNameField.textColor = [UIColor whiteColor];
//        variableNameField.shadowColor = [UIColor blackColor];
//        variableNameField.shadowOffset = CGSizeMake(0, 1);
//        varCell.expressionFieldTextColor = [UIColor whiteColor];
    }
    else
    {
        UILabel *variableNameField = tagCell.valuePropertyLabel;
        tagCell.darkContext = YES;
        variableNameField.textColor = [UIColor whiteColor];
        variableNameField.shadowColor = [UIColor blackColor];
        variableNameField.shadowOffset = CGSizeMake(0, 1);
        tagCell.expressionFieldTextColor = [UIColor whiteColor];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    //cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [(SWInspectorViewController*)self.tabBarController preferredCellBackgroundColor];
    
    [(SWTagCell*)cell beginObservingModel];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(SWTagCell*)cell endObservingModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

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

#pragma mark Protocol SourceItemObserver

- (void)sourceItem:(SWSourceItem*)source plcTagDidChange:(SWPlcTag*)plcTag atIndex:(NSInteger)indx
{    
    UITableView *table = self.tableView;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indx inSection:0];
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)sourceItem:(SWSourceItem *)source didInsertSourceNodesAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
    }];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

- (void)sourceItem:(SWSourceItem *)source didRemoveSourceNodesAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
    }];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)sourceItem:(SWSourceItem *)source didMoveSourceNodeAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)destinationIndex
{
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:destinationIndex inSection:0]];
}

@end
