//
//  SWEventsViewController.m
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWHistoEventsViewController.h"
#import "SWInspectorViewController.h"

#import "SWTableViewMessage.h"

#import "ColoredButton.h"
#import "SWColor.h"
#import "UIView+Additions.h"
#import "SWEventCell.h"
#import "SWEvent.h"

#import "SWHistoAlarms.h"
#import "SWHistoAlarmsCache.h"

#import "Drawing.h"

@interface SWHistoEventsViewController ()<UISearchDisplayDelegate, UISearchBarDelegate>
{
    //SWHistoAlarmsDatabaseContext *_dbContext;
    SWHistoAlarmsCache *_histoAlarmsCache;
    //SWHistoAlarmsCache *_histoAlarmsCache1;
    
    UISearchBar *_searchBar;
    NSString *_searchText;
    BOOL _searchActive;
    __weak NSTimer *_timer;
    //UISearchDisplayController *_searchController;
}

@end

@interface SWHistoEventsViewController(ModelObserver) <SWHistoAlarmsCacheDelegate>
{
}
@end

@implementation SWHistoEventsViewController
{
    NSInteger _numberOfRowss[5];
    NSInteger _numberOfSections;
    //NSInteger _numberOfRows1;
    CGRect _commentFrame;
    SWEventCell *_anyCell;
}

//@synthesize eventCenter = _eventCenter;
//@synthesize ackButton = _ackButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = nil;
    
    UITableView *tableView = self.tableView;   // es un SWTableView
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;    // no separator
  //  tableView.separatorColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    
//    [tableView setContentInset:UIEdgeInsetsMake(0, 0, 48, 0)];   // workaround al defecte del UITabBar
//    [tableView setScrollIndicatorInsets:tableView.contentInset];   // workaround al defecte del UITabBar


//    SWHistoAlarms *histoAlarms = _documentModel.histoAlarms;
//    SWDatabaseContextTimeRange contextRange = [histoAlarms dbContextRange];
//    
//    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
//    CFAbsoluteTime earlier = [SWDatabaseContext differenceTimeForRange:contextRange time:now offset:-1];
//    
//    _histoAlarmsCache = [[SWHistoAlarmsCache alloc] init];
//    SWHistoAlarmsDatabaseContext *dbContext0 = [_documentModel.histoAlarms dbContextWithReferenceTime:now];
//    SWHistoAlarmsDatabaseContext *dbContext1 = [_documentModel.histoAlarms dbContextWithReferenceTime:earlier];
//    [_histoAlarmsCache setDbContexts:@[dbContext0,dbContext1]];
//#warning (fix me) - si canvia el mes amb l'aplicacio funcionant no s'actualitzaran els dbContexts 
    
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableHeader];
    NSString *message = @"HistoEventsViewControllerFooter";
    [messageView setMessage:NSLocalizedString(message, nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Alarms", nil)];
    
    //[tableView setTableFooterView:messageView];
    [tableView setTableHeaderView:messageView];
    
    SWDatabaseContextTimeRange contextRange = [_histoAlarms dbContextRange];
    
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime earlier = [SWDatabaseContext differenceTimeForRange:contextRange time:now offset:-1];
    
    _histoAlarmsCache = [[SWHistoAlarmsCache alloc] init];
    SWHistoAlarmsDatabaseContext *dbContext0 = [_histoAlarms dbContextForReadingWithReferenceTime:now];
    SWHistoAlarmsDatabaseContext *dbContext1 = [_histoAlarms dbContextForReadingWithReferenceTime:earlier];
    [_histoAlarmsCache setDbContexts:@[dbContext0,dbContext1]];
#warning (fix me) - si canvia el mes amb l'aplicacio funcionant no s'actualitzaran els dbContexts
    
    
    
    //_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    _searchBar = [[UISearchBar alloc] init];
    [_searchBar sizeToFit];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar setDelegate:self];
    [_searchBar setPlaceholder:NSLocalizedString(@"Search",nil)];
    
//    CGSize size = CGSizeMake(34,32);
//    UIImage *searchImg = glossyImageWithSizeAndColor(size, [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor, YES, NO, 16, 3);
//    searchImg = [searchImg resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)];
//    
//    
//    [_searchBar setSearchFieldBackgroundImage:searchImg forState:UIControlStateNormal];
    
    [_searchBar setImage:[UIImage imageNamed:@"01-magnifygray.png"]
							 forSearchBarIcon:UISearchBarIconSearch 
										state:UIControlStateNormal];
    
    
    
    
    [_searchBar setBackgroundImage:[[UIImage alloc]init]];   // <-- image vuida per obtenir transparencia
    
    
//    [_searchBar setScopeButtonTitles:@[@"date", @"label", @"comment"]];
    //[_searchBar setShowsScopeBar:YES];
    //[_searchBar setShowsSearchResultsButton:YES];
    
    //[_searchBar setShowsCancelButton:YES animated:NO];
    
//    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
//    [_searchController setDelegate:self];
//    [_searchController setSearchResultsDataSource:self];
//    [_searchController setSearchResultsDelegate:self];
//    [_searchController setDisplaysSearchBarInNavigationBar:YES];
    
    //[[[self navigationController] navigationItem] setTitleView:_searchBar];
    
    
    UIView *_searchHeaderView = [[UIView alloc] init];
     /*[UIImage imageNamed:@"searchBarBG.png"]*/
    
    _searchHeaderView.frame = _searchBar.frame;
    _searchHeaderView.contentMode = UIViewContentModeScaleToFill;
    _searchHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchHeaderView.userInteractionEnabled = YES;
    _searchHeaderView.backgroundColor = [UIColor clearColor];
    [_searchHeaderView addSubview:_searchBar];
    
    [[self navigationItem] setTitleView:_searchHeaderView];
    //[tableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
    
    //[tableView setTableHeaderView:_searchBar];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[_searchController setActive:YES animated:NO];
    
    [_histoAlarmsCache setDelegate:self];
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_histoAlarmsCache setDelegate:nil];
    [super viewWillDisappear:animated];
}


//#pragma mark - Properties

//- (void)setDocumentModel:(SWDocumentModel *)documentModel
//{
//    _documentModel = documentModel;
//    if (self.isViewLoaded)
//    {
//        [self.tableView reloadData];
//    }
//}

- (void)setHistoAlarms:(SWHistoAlarms *)histoAlarms
{
    _histoAlarms = histoAlarms;
    if (self.isViewLoaded)
    {
        [self.tableView reloadData];
    }
}


#pragma mark - Search

- (void)_resetController
{
    if ( [self isViewLoaded] )
        [self.tableView reloadData];
}


- (void)_performSearchWithText:(NSString*)text
{
    if ( _timer == nil )
        _timer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_performSearchNow:) userInfo:nil repeats:YES];

    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    _searchActive = YES;
    _searchText = text;
}


- (void)_stopSearch
{
    _searchActive = NO;
    [_histoAlarmsCache setSearchText:nil];
}


- (void)_performSearchNow:(id)timer
{
    [_histoAlarmsCache setSearchText:_searchText];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _numberOfSections = [_histoAlarmsCache numberOfSections];
    return _numberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _numberOfRowss[section] = [_histoAlarmsCache numberOfRowsForSection:section];
    

    
//    [(id)tableView.tableFooterView showForEmptyTable:(rowsCount==0)];
//    [tableView setScrollEnabled:(rowsCount>0)];
    
//    NSInteger totalRows = 0;
//    for ( NSInteger i=0 ; i<_numberOfSections ; i++ )
//        totalRows += _numberOfRowss[i];
//    
//    if ( totalRows == 0 )
//    {
//        SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
//        NSString *message = @"HistoEventsViewControllerFooter";
//        [messageView setMessage:NSLocalizedString(message, nil)];
//        [messageView setEmptyTitle:NSLocalizedString(@"No Alarms", nil)];
//    
//        [tableView setTableFooterView:messageView];
//    }
    
    
    return _numberOfRowss[section];
}


static NSString *CellIdentifier = @"SWEventCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    SWEvent *event = [_histoAlarmsCache eventAtRow:_numberOfRowss[section]-1-row forSection:section];

    cell.event = event;
    cell.isHisto = YES;
        
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ( _anyCell == nil )
        _anyCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    SWEvent *event = [_histoAlarmsCache eventAtRow:_numberOfRowss[section]-1-row forSection:section];
    
    NSString *comment = event.commentText;
    
    CGFloat height = [_anyCell heightForComment:comment];
    
    return height;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    title = [_histoAlarmsCache.dbContexts[section] keyName];
    
    return title;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [(SWInspectorViewController*)self.tabBarController preferredCellBackgroundColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - SearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog( @"will begin search");
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSLog( @"did begin search");
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog( @"will end search");
}


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    NSLog( @"did end search");
}


#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSLog( @"selectedScopeButtonIndexDidChange to %ld", (long)selectedScope);
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search bar Cancel clicked");
    [_searchBar resignFirstResponder];
    [_searchBar setText:nil];
    
    [self _stopSearch];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog( @"Search bar did begin search");
    
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchText = searchText;
        
    if ( searchText.length == 0)
    {        
        [self _stopSearch];
    }
    else
    {
        [self _performSearchWithText:searchText];
    }
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search bar Search Clicked");
//    [self searchTableList];
}




@end

@implementation SWHistoEventsViewController (ModelObserver)

- (void)histoAlarmsCache:(SWHistoAlarmsCache *)haCache didUpdateSection:(NSInteger)section
{
    [self.tableView reloadData];
    
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
//    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

@end
