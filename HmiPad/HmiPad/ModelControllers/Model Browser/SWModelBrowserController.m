//
//  SWModelBrowserController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SWModelBrowserController.h"


#import "NSString+FontAwesome.h"
#import "UIImage+Resize.h"

#import "SWDocument.h"
#import "SWPage.h"
#import "SWItem.h"
#import "SWAlarm.h"
#import "SWSourceItem.h"
#import "SWRestApiItem.h"
#import "SWSourceNode.h"
#import "SWReadExpression.h"
#import "SWSystemItem.h"

#import "SWObjectCell.h"
#import "SWPageCell.h"
#import "SWSourceCell.h"
#import "SWTagCell.h"
#import "SWItemCell.h"
#import "SWAlarmCell.h"
#import "SWProjectUserCell.h"
#import "SWDatabaseCell.h"
#import "SWModelBrowserCell.h"

#import "SWTableSectionHeaderView.h"
#import "SWTableViewMessage.h"
#import "BubbleView.h"

#import "SWModelManager.h"

//#import "SWFloatingPopoverManager.h"
#import "SWPageBrowserController.h"
#import "SWObjectBroswerController.h"
#import "SWArrayTypeBrowserController.h"
#import "SWSourceVariablesBrowserController.h"

#import "SWRevealController.h"
#import "SWTableView.h"

#import "SWColor.h"
#import "Drawing.h"


enum
{
    ModelBrowserSectionBrowser = 0,
    ModelBrowserSectionExtra
};


enum
{
    ModelBrowserRowSystemItems = 0,
    ModelBrowserRowPages,
    ModelBrowserRowBackgroundItems,
    ModelBrowserRowAlarms,
    ModelBrowserRowProjectUsers,
    ModelBrowserRowDataLoggers,
    ModelBrowserRowRestApis,
    ModelBrowserRowSources,
    ModelBrowserRowCount
};

enum
{
    ModelBrowserSearchTypeSectionUnknown = 0,
    ModelBrowserSearchTypeSectionPages,
    ModelBrowserSearchTypeSectionAlarms,
    ModelBrowserSearchTypeSectionProjectUsers,
    ModelBrowserSearchTypeSectionDatabases,
    ModelBrowserSearchTypeSectionRestApiItems,
    ModelBrowserSearchTypeSectionItems,
    ModelBrowserSearchTypeSectionSources,
    ModelBrowserSearchTypeSectionTags,
//    ModelBrowserSearchTypeBackgroundItems,
    ModelBrowserSearchTypeSectionSystem,
    ModelBrowserSearchTypeSectionCount
};

@interface SWModelBrowserController ()<SWRevealViewControllerDelegate,SWTagCellDelegate>
- (void)setDocumentModel:(SWDocumentModel*)documentModel;
@end

@interface SWModelBrowserController()<UISearchBarDelegate,DocumentModelObserver, UITableViewDelegate, UITableViewDataSource>
@end

@implementation SWModelBrowserController
{
    UISearchBar *_searchBar;
    UIView *_searchHeaderView;
    BubbleView *_bubbleView;
    //SWTableViewMessage *_messageView;
    
    NSMutableArray *_searchedAlarms;
    NSMutableArray *_searchedProjectUsers;
    NSMutableArray *_searchedDatabases;
    NSMutableArray *_searchedRestApiItems;
    NSMutableArray *_searchedItems;
    NSMutableArray *_searchedPages;
    NSMutableArray *_searchedSources;
    NSMutableArray *_searchedNodes;
    NSMutableArray *_searchedSystemItems;
    
    NSArray *_extraViewControllers;
    __weak NSTimer *_timer;
    SWModelManager *_modelManager;
}



#pragma mark protocol SWModelBrowserViewController

@synthesize browsingStyle = _browsingStyle;
@synthesize delegate = _delegate;
@synthesize identifiyingObject = _identifiyingObject;


- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[SWDocumentModel class]], @"objecte erroni per controlador" );
    self = [self initWithModel:object];
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

@synthesize documentModel = _documentModel;

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithModel:nil];
}

- (id)initWithModel:(SWDocumentModel*)documentModel
{
    //self = [super initWithStyle:UITableViewStylePlain];
    self = [super init];
    if (self)
    {
        _documentModel = documentModel;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
        _browsingStyle = SWModelBrowsingStyleManagement;
        
        _searchedItems = [NSMutableArray array];
        _searchedAlarms = [NSMutableArray array];
        _searchedProjectUsers = [NSMutableArray array];
        _searchedDatabases = [NSMutableArray array];
        _searchedRestApiItems = [NSMutableArray array];
        _searchedPages = [NSMutableArray array];
        _searchedSources = [NSMutableArray array];
        _searchedNodes = [NSMutableArray array];
        _searchedSystemItems = [NSMutableArray array];
        
    // self.title = NSLocalizedString(@"Model Browser",nil);
        [self setBrowsingStyle:SWModelBrowsingStyleManagement];
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.hidesBottomBarWhenPushed = YES;
    
    UIView *selfView = self.view;
    
    //_tableView = [[UITableView alloc] initWithFrame:selfView.bounds style:UITableViewStylePlain];
    _tableView = [[SWTableView alloc] initWithFrame:selfView.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [selfView addSubview:_tableView];
    
    UITableView *table = self.tableView;
    UIColor *ncolor = UIColorWithRgb(DarkenedRgbColor(SystemDarkerBlueColor, 0.7f));
    
    // ---- SEARCH STUFF ---- //
    _searchBar = [[UISearchBar alloc] init];
    [_searchBar sizeToFit];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"Search",nil);
    
    if ( IS_IOS7 )
    {
        [_searchBar setBarStyle:UIBarStyleBlack];  // <-- fa sortir el texte gris en lloc de negre
    }
    
    
    CGRect searchFrame = _searchBar.frame;
    CGSize searchBarSize = searchFrame.size;
    
//    UIImage *searchImg = [[UIImage imageNamed:@"searchTextBG.png"]   // <--- s'hauria de trobar versio @2x
//        resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)];
    
    

    CGSize size = CGSizeMake(34,32);
    UIImage *searchImg = glossyImageWithSizeAndColor(size, ncolor.CGColor, YES, NO, 16, 3);
    searchImg = [searchImg resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)];
    
    
    [_searchBar setSearchFieldBackgroundImage:searchImg forState:UIControlStateNormal];
    
    [_searchBar setImage:[UIImage imageNamed:@"01-magnifygray.png"]
							 forSearchBarIcon:UISearchBarIconSearch 
										state:UIControlStateNormal];
   
    [_searchBar setBackgroundImage:[[UIImage alloc]init]];    // <--- posem imatge vuida per obtenir transparencia

    if ( IS_IOS7 )
    {
        [_searchBar setBarTintColor:ncolor];
    }
    else
    {
        [_searchBar setTintColor:ncolor];
    }

    for (UIView *subview in _searchBar.subviews)
    {
		if ([subview isKindOfClass:[UITextField class]])
        {
			UITextField *searchTextField = (UITextField *) subview;
			searchTextField.textColor = [UIColor lightGrayColor];// [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
		}
    }
    
    UIImage *sViewImage = glossyImageWithSizeAndColor(CGSizeMake(1,searchBarSize.height), ncolor.CGColor, NO, NO, 0, 1);
    
    _searchHeaderView = [[UIImageView alloc] initWithImage:sViewImage /*[UIImage imageNamed:@"searchBarBG.png"]*/];
    _searchHeaderView.frame = _searchBar.frame;
    _searchHeaderView.contentMode = UIViewContentModeScaleToFill;
    _searchHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchHeaderView.userInteractionEnabled = YES;
 
    //[_searchHeaderView addSubview:_searchBar];
    
    
//    UIView *sview = [[UIView alloc] initWithFrame:_searchBar.frame];
//    sview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    
//    
//    UIToolbar *tview = [[UIToolbar alloc] initWithFrame:_searchBar.frame];
//    tview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//   // tview.barStyle = UIBarStyleBlack;
//    tview.tintColor = ncolor;
//    [tview addSubview:sview];
    
    [_searchHeaderView addSubview:_searchBar];
    table.tableHeaderView = _searchDisabled ? nil : _searchHeaderView;
    
    //_messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [self _reloadFooterMessage];
    //[table setTableFooterView:_messageView];
    
    
    [selfView setBackgroundColor:ncolor];
    [table setBackgroundColor:ncolor];
    //[table setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0f]];
    
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if (_searchActive) // <---------- Restore search search if possible
        [self setSearchText:_searchText];

    [_documentModel addObserver:self];
}


- (void)setBrowsingStyle:(SWModelBrowsingStyle)browsingStyle
{
    _browsingStyle = browsingStyle;
    
    NSString *title = nil;
    if ( _browsingStyle == SWModelBrowsingStyleManagement ) title = @"Model Browser";
    else if ( _browsingStyle == SWModelBrowsingStyleSeeker ) title = @"Model Seeker";
    
    self.title = NSLocalizedString(title,nil);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //NSLog( @"SWModelBrowserController viewWillAppear");
//    if (_browsingStyle == SWModelBrowsingStyleManagement)
//        [self.navigationController setToolbarHidden:NO animated:NO];
    
    [self.tableView reloadData];
    [self _selectRowForPresentedFrontController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //NSLog( @"SWModelBrowserController viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //NSLog( @"SWModelBrowserController viewWillDisppear");
    [_searchBar resignFirstResponder];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //NSLog( @"SWModelBrowserController viewDidDisappear");
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
    [_documentModel removeObserver:self];
}

#pragma mark - Public Methods

- (void)setSearchText:(NSString *)searchText
{
    _searchText = searchText;
    [_searchBar setText:searchText];
    
    if ( searchText == nil)
    {
        if ( _searchActive )
        {
            _searchActive = NO;
            [self _resetSearch];
        }
    }
    else
    {
        [self _performSearchWithText:searchText];
    }
}


- (void)setExtraViewControllers:(NSArray *)extraViewControllers animated:(BOOL)animated
{
    if ( extraViewControllers.count == 0 )  // utilitzem _extraViewControllers com un centinela, per tant el posem a nil si es un array vuit
        extraViewControllers = nil;

    if ( _searchActive )
    {
        _extraViewControllers = extraViewControllers;
    }
    else
    {
        BOOL insert = !_extraViewControllers && extraViewControllers;
        BOOL reload = _extraViewControllers && extraViewControllers;
        BOOL delete = _extraViewControllers && !extraViewControllers;
        _extraViewControllers = extraViewControllers ;

        UITableViewRowAnimation animationType = animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
        [_tableView beginUpdates];
        if (insert) [_tableView insertSections:indexSet withRowAnimation:animationType];
        if (reload) [_tableView reloadSections:indexSet withRowAnimation:animationType];
        if (delete) [_tableView deleteSections:indexSet withRowAnimation:animationType];
        [_tableView endUpdates];
    }
}

- (void)setFrontViewControllerOfArrayType:(SWArrayType)arrayType animated:(BOOL)animated
{
    SWArrayTypeBrowserController *abc = [[SWArrayTypeBrowserController alloc] initWithDocumentModel:_documentModel andArrayType:arrayType];
    abc.delegate = _delegate;
    abc.browsingStyle = _browsingStyle;
    
    //abc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
    abc.preferredContentSize = self.preferredContentSize;
    SWRevealController *revealController = (SWRevealController*)self.revealViewController;
    [revealController setFrontViewControllerWithControllers:@[abc] animated:animated]; // animated == NO does not work!
}

#pragma mark - Private Methods

- (void)setDocumentModel:(SWDocumentModel*)documentModel
{
    _documentModel = documentModel;
    
    if (self.isViewLoaded) 
    {
        [self.tableView reloadData];
    }
}

- (NSInteger)_rowForArrayType:(SWArrayType)arrayType
{
    NSInteger row = NSNotFound;
    
    switch (arrayType)
    {
        case SWArrayTypeSystemItems:
            row = ModelBrowserRowSystemItems;
            break;
            
        case SWArrayTypePages:
            row = ModelBrowserRowPages;
            break;
            
        case SWArrayTypeAlarms:
            row = ModelBrowserRowAlarms;
            break;
            
        case SWArrayTypeProjectUsers:
            row = ModelBrowserRowProjectUsers;
            break;
            
        case SWArrayTypeDataLoggers:
            row = ModelBrowserRowDataLoggers;
            break;
            
        case SWArrayTypeRestApiItems:
            row = ModelBrowserRowRestApis;
            break;
            
        case SWArrayTypeBackgroundItems:
            row = ModelBrowserRowBackgroundItems;
            break;
            
        case SWArrayTypeSources:
            row = ModelBrowserRowSources;
            break;
            
        case SWArrayTypeUnknown:
            break;
    }
    
    return row;
}


- (SWArrayType)_arrayTypeForRow:(NSInteger)row
{
    SWArrayType arrayType = SWArrayTypeUnknown;
    
    switch (row)
    {
        case ModelBrowserRowSystemItems:
            arrayType = SWArrayTypeSystemItems;
            break;
        
        case ModelBrowserRowPages:
            arrayType = SWArrayTypePages;
            break;
                
        case ModelBrowserRowBackgroundItems:
            arrayType = SWArrayTypeBackgroundItems;
            break;
                
        case ModelBrowserRowAlarms:
            arrayType = SWArrayTypeAlarms;
            break;
                    
        case ModelBrowserRowProjectUsers:
            arrayType = SWArrayTypeProjectUsers;
            break;
            
        case ModelBrowserRowDataLoggers:
            arrayType = SWArrayTypeDataLoggers;
            break;
            
        case ModelBrowserRowRestApis:
            arrayType = SWArrayTypeRestApiItems;
            break;
                
        case ModelBrowserRowSources:
            arrayType = SWArrayTypeSources;
            break;
                
        case ModelBrowserRowCount:    // <-- per fer callar el compilador
            break;
    }
    return arrayType;
}


- (NSString*)_message
{
    NSString *message = nil;
    
    if (_searchActive)
        message = @"Search For Items, Sources, System Items, Types, and any model instance.";
    else
        message = _browsingStyle == SWModelBrowsingStyleManagement ? @"ModelBrowserFooter" : @"ModelBrowserFooter2";
    
    return NSLocalizedString(message,nil);
}


- (void)_reloadFooterMessage
{
    NSString *message = [self _message];
    
//    if ( !_searchActive && _browsingStyle == SWModelBrowsingStyleManagement )
//    {
//        message = [NSString stringWithFormat:@"%@\n\n%@", message, _documentModel.uuid];
//    }
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [messageView setMessage:message];
    [messageView setEmptyTitle:NSLocalizedString(@"Empty Model", nil)];
    messageView.messageViewLabel.alpha = 0.67f;
    [messageView setDarkContext:YES];
    
    [self.tableView setTableFooterView:messageView];
}


#pragma mark - Search Stuff

- (void)setSearchDisabled:(BOOL)searchDisabled
{
    _searchDisabled = searchDisabled;
    self.tableView.tableHeaderView = _searchDisabled ? nil : _searchHeaderView;
}

- (void)_resetController
{
    if ( [self isViewLoaded] )
    {
        [self _reloadFooterMessage];
        [self.tableView reloadData];
    }
}

- (void)_reloadCurrentSearch
{
    [self _resetSearch];
    [self _performSearchWithText:_searchText];
}


- (void)_performSearchWithText:(NSString*)text
{
    if ( _timer == nil )
        _timer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_performSearchNow:) userInfo:nil repeats:YES];

    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if ( _searchActive == NO )
    {
        _searchActive = YES;
        [self _resetSearch];
    }
    _searchText = text;
}

- (void)_stopSearch
{
    [self _removeAllSearchedObjects];
    
    _searchActive = NO;
    [self _resetController];
}

- (void)_resetSearch
{
    [self _removeAllSearchedObjects];
    [self _resetController];
}


- (void)_performSearchNow:(id)timer
{
    [self _filterContentForSearchText:_searchText scope:nil];
    
    if ( [self isViewLoaded] )
    {
        [self _reloadFooterMessage];
        [self.tableView reloadData];
    }
}


- (void)_filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self _removeAllSearchedObjects];
    
    if (!searchText || searchText.length == 0)
        return;
    
    for (SWPage *page in _documentModel.pages) // <---- Cerquem Pàgines
    {
        if ([page matchesSearchWithString:searchText])
            [_searchedPages addObject:page];
        
        for (SWItem *item in page.items) // <---- Cerquem Items
        {
            if ([item matchesSearchWithString:searchText])
                [_searchedItems addObject:item];
        }
    }
    
    for (SWAlarm *alarm in _documentModel.alarmItems) // <---- Cerquem Alarmes
    {
        if ([alarm matchesSearchWithString:searchText])
            [_searchedAlarms addObject:alarm];
    }
    
    for (SWProjectUser *user in _documentModel.projectUsers)
    {
        if ( [user matchesSearchWithString:searchText])
            [_searchedProjectUsers addObject:user];
    }
    
    for ( SWDataLoggerItem *database in _documentModel.dataLoggerItems)
    {
        if ( [database matchesSearchWithString:searchText])
            [_searchedDatabases addObject:database];
    }
    
    for ( SWRestApiItem *restApiItem in _documentModel.restApiItems)
    {
        if ( [restApiItem matchesSearchWithString:searchText] )
            [_searchedRestApiItems addObject:restApiItem];
    }
    
    for (SWSourceItem *source in _documentModel.sourceItems) // <---- Cerquem Sources
    {
        if ([source matchesSearchWithString:searchText])
            [_searchedSources addObject:source];
        
        for (SWSourceNode *node in source.sourceNodes) // <---- Cerquem Tags
        {
            if ([node matchesSearchWithString:searchText])
                [_searchedNodes addObject:node];  
        }
    }
    
    for (SWSystemItem *item in _documentModel.systemItems) // <---- Cerquem Items de Sistema
    {
        if ([item matchesSearchWithString:searchText])
            [_searchedSystemItems addObject:item];
    }
}

- (void)_removeAllSearchedObjects
{
    [_searchedItems removeAllObjects];
    [_searchedAlarms removeAllObjects];
    [_searchedProjectUsers removeAllObjects];
    [_searchedDatabases removeAllObjects];
    [_searchedRestApiItems removeAllObjects];
    [_searchedPages removeAllObjects];
    [_searchedSources removeAllObjects];
    [_searchedNodes removeAllObjects];
    [_searchedSystemItems removeAllObjects];
}


//-(void)_performSearchWithText:(NSString*)searchText
//{
//    _searchActive = YES;
//        
//    [self _filterContentForSearchText:searchText scope:nil];
//    
//    if ( [self isViewLoaded] )
//    {
//        [self _reloadFooterMessage];
//        [self.tableView reloadData];
//    }
//}




- (NSArray*)_searchedObjectsInSection:(NSInteger)section
{
    switch (section)
    {
        case ModelBrowserSearchTypeSectionItems:
            return _searchedItems;
            break;
            
        case ModelBrowserSearchTypeSectionAlarms:
            return _searchedAlarms;
            break;
            
        case ModelBrowserSearchTypeSectionProjectUsers:
            return _searchedProjectUsers;
            break;
            
        case ModelBrowserSearchTypeSectionDatabases:
            return _searchedDatabases;
            break;
            
        case ModelBrowserSearchTypeSectionRestApiItems:
            return _searchedRestApiItems;
            break;
            
        case ModelBrowserSearchTypeSectionPages:
            return _searchedPages;
            break;
            
        case ModelBrowserSearchTypeSectionSources:
            return _searchedSources;
            break;
            
        case ModelBrowserSearchTypeSectionTags:
            return _searchedNodes;
            break;
            
        case ModelBrowserSearchTypeSectionSystem:
            return _searchedSystemItems;
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSString*)_searchedTitleInSection:(NSInteger)section
{
    switch (section)
    {
        case ModelBrowserSearchTypeSectionItems:
            return NSLocalizedString(@"ITEMS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionAlarms:
            return NSLocalizedString(@"ALARMS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionProjectUsers:
            return NSLocalizedString(@"USERS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionDatabases:
            return NSLocalizedString(@"DATA LOGGERS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionRestApiItems:
            return NSLocalizedString(@"REST CONNECTORS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionPages:
            return NSLocalizedString(@"PAGES", nil);
            break;
            
        case ModelBrowserSearchTypeSectionSources:
            return NSLocalizedString(@"PLC CONNECTORS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionTags:
            return NSLocalizedString(@"TAGS", nil);
            break;
            
        case ModelBrowserSearchTypeSectionSystem:
            return NSLocalizedString(@"SYSTEM", nil);
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSInteger)_numberOfSectionsForSearchedData
{
    return ModelBrowserSearchTypeSectionCount;
}

- (NSInteger)_numberOfRowsForSearchedDataInSection:(NSInteger)section
{
    return [[self _searchedObjectsInSection:section] count];
}

- (UITableViewCell*)_searchedDataCellForRowAtIndexPath:(NSIndexPath*)indexPath // <------ Atenció! estem suposant que els objectes cercats són sempre SWObject!
{
    if (!_searchActive)
        return nil;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    id object = [[self _searchedObjectsInSection:section] objectAtIndex:row];
        
    static NSString * const SearchModelObjectCellIdentifier = @"SearchModelObjectCell";
    static NSString * const SearchSourceCellIdentifier = @"SearchSourceCellIdentifier";
    static NSString * const SearchPageCellIdentifier = @"SearchPageCellIdentifier";
    static NSString * const SearchAlarmCellIdentifier = @"SearchAlarmCellIdentifier";
    static NSString * const SearchProjectUsersCellIdentifier = @"SearchProjectUsersCellIdentifier";
    static NSString * const SearchDatabasesCellIdentifier = @"SearchDatabasesCellIdentifier";
    static NSString * const SearchRestApiItemsCellIdentifier = @"SearchRestApiItemsCellIdentifier";
    NSString * const SearchTagCellIdentifier = SWTagCellIdentifier; //@"sourceVariableCellIdentifier";
    static NSString * const SearchItemCellIdentifier = @"SearchItemCellIdentifier";
    
    NSString *identifier = nil;
    
    switch (section)
    {
        case ModelBrowserSearchTypeSectionTags:
            identifier = SearchTagCellIdentifier;
            break;
        
        case ModelBrowserSearchTypeSectionSources:
            identifier = SearchSourceCellIdentifier;
            break;
            
        case ModelBrowserSearchTypeSectionPages:
            identifier = SearchPageCellIdentifier;
            break;
            
        case ModelBrowserSearchTypeSectionAlarms:
            identifier = SearchAlarmCellIdentifier;
            break;

        case ModelBrowserSearchTypeSectionProjectUsers:
            identifier = SearchProjectUsersCellIdentifier;
            break;
            
        case ModelBrowserSearchTypeSectionDatabases:
            identifier = SearchDatabasesCellIdentifier;
            break;
            
        case ModelBrowserSearchTypeSectionRestApiItems:
            identifier = SearchRestApiItemsCellIdentifier;
            break;
            
        case ModelBrowserSearchTypeSectionItems:
            identifier = SearchItemCellIdentifier;
            break;
            
        default:
            identifier = SearchModelObjectCellIdentifier;
            break;
    }
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        switch (section)
        {
            case ModelBrowserSearchTypeSectionTags:
            {
                NSString *nibName = IS_IOS7?SWTagCellNibName:SWTagCellNibName6;
                UINib *tagCellNib = [UINib nibWithNibName:nibName bundle:nil];
                SWTagCell *tagCell = [[tagCellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
                NSAssert( [tagCell.reuseIdentifier isEqualToString:SearchTagCellIdentifier], nil );
                [tagCell setDelegate:self];
                cell = tagCell;
                break;
            }
            case ModelBrowserSearchTypeSectionSources:
                cell = [[SWSourceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchSourceCellIdentifier];
                break;
                
            case ModelBrowserSearchTypeSectionPages:
                cell = [[SWPageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchPageCellIdentifier];
                break;
                
            case ModelBrowserSearchTypeSectionAlarms:
                cell = [[SWAlarmCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchAlarmCellIdentifier];
                break;
                
            case ModelBrowserSearchTypeSectionProjectUsers:
                cell = [[SWProjectUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchProjectUsersCellIdentifier];
                break;
                
            case ModelBrowserSearchTypeSectionDatabases:
                cell = [[SWDatabaseCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchDatabasesCellIdentifier];
                break;
                
            case ModelBrowserSearchTypeSectionRestApiItems:
                #warning revisar
                cell = [[SWObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchRestApiItemsCellIdentifier];
                break;
                
            case ModelBrowserSearchTypeSectionItems:
                cell = [[SWItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchItemCellIdentifier];
                break;
                
            default:
                cell = [[SWObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchModelObjectCellIdentifier];
                break;
        }
    }
    
    BOOL managementStyle = _browsingStyle==SWModelBrowsingStyleManagement;
    
//    SWModelBrowserCellAccessoryType accessory =
//        showConfigurator?SWModelBrowserCellAccessoryTypeGearIndicator:SWModelBrowserCellAccessoryTypeDisclosureIndicator;
    
    if (section == ModelBrowserSearchTypeSectionTags)
    {
        SWTagCell *tagCell = (id)cell;
        tagCell.sourceNode = (SWSourceNode*)object;
        
        // el tipus tags es final
        SWValueCellAccessoryType accessory =
            managementStyle?SWValueCellAccessoryTypeNone:SWValueCellAccessoryTypeSeekerIndicator;
        
        tagCell.accessory = accessory;
//        x
//        
//        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        //UIColor *color = UIColorWithRgb(MultipleSelectionColor);
//        UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
//        selectionView.backgroundColor = color;
//        
//        [tagCell setSelectedBackgroundView:selectionView];
//
//        tagCell.valuePropertyLabel.highlightedTextColor = UIColorWithRgb(TangerineSelectionColor);
//        tagCell.valueSemanticTypeLabel.highlightedTextColor = tagCell.valueSemanticTypeLabel.textColor;
//        tagCell.valueAsStringLabel.highlightedTextColor = tagCell.valueAsStringLabel.textColor;
//        
//        
        
        
        
        
//        UIView *accessoryView = nil;
//        if (showConfigurator)
//            accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"14-ingray.png"]];
//        tagCell.accessoryView = accessoryView;
    }
    else // <---------- En aquest punt suposem que la cel·la "cell" es subclasse de SWObjectCell!
    {
        SWObject *modelObject = object;
        SWObjectCell *objectCell = (id)cell;
        
        objectCell.modelObject = modelObject;
        
        SWModelBrowserCellAccessoryType accessory =
            managementStyle?SWModelBrowserCellAccessoryTypeNone:SWModelBrowserCellAccessoryTypeDisclosureIndicator;
        
        objectCell.accessory = accessory;
        objectCell.acceptedTypes = _modelManager.currentAcceptedTypes;
    }
        
    return cell;
}

- (UIView*)_searchViewForHeaderInSection:(NSInteger)section
{
    if (!_searchActive)
        return nil;
    
    NSArray *array = [self _searchedObjectsInSection:section];
    if (array.count == 0)
        return nil;
    
    NSString *title = nil;
    
    title = [self _searchedTitleInSection:section];
    
    SWTableSectionHeaderView *tvh = [[SWTableSectionHeaderView alloc] init];
    tvh.title = title;
    
    return tvh;
}

- (CGFloat)_searchHeightForHeaderInSection:(NSInteger)section
{
    return [[self _searchedObjectsInSection:section] count]>0?30:0;
}

- (void)_searchDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing)
        return;
    
    NSInteger section = indexPath.section;
    
    id object = [[self _searchedObjectsInSection:section] objectAtIndex:indexPath.row];
    
    if (_browsingStyle == SWModelBrowsingStyleManagement)
    {
        id configuringObject = nil;
        if ( section == ModelBrowserSearchTypeSectionTags )
            configuringObject = @[object];   // <- en el cas de tags un array es el que ultimament s'espera a SWNodeConfiguratorController
        else
            configuringObject = object;
        
        //SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
        //[_modelManager presentModelConfiguratorForObject:configuringObject animated:NO presentingControllerKey:nil];
        [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:configuringObject animated:IS_IPHONE];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (_browsingStyle == SWModelBrowsingStyleSeeker)
    {
        UIViewController *vc = nil;
        if (section == ModelBrowserSearchTypeSectionSources)
        {
            SWSourceItem *source = object;
            SWSourceVariablesBrowserController *svlc = [[SWSourceVariablesBrowserController alloc] initWithSourceItem:source];
            svlc.delegate = _delegate;
            svlc.browsingStyle = _browsingStyle;
            vc = svlc;
        }
        else if (section == ModelBrowserSearchTypeSectionTags)
        {
            SWSourceNode *node = object;
            [_delegate modelBrowser:self didSelectValue:(SWValue*)node.readExpression];
        }
        else // <--------- En aquest punt suposem que l'objecte sel·leccionat és un SWObject i mostrem el seu configurador per defecte
        {
            SWObject *modelObject = object;
            SWObjectBroswerController *obc = [[SWObjectBroswerController alloc] initWithModelObject:modelObject];
            obc.delegate = _delegate;
            obc.browsingStyle = _browsingStyle;
            vc = obc;
        }
        
      
        //vc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        vc.preferredContentSize = self.preferredContentSize;
        SWRevealViewController *revealController = self.revealViewController;
        NSArray *frontControllers = nil;
        if (vc) frontControllers = @[vc];
        [(SWRevealController*)revealController setFrontViewControllerWithControllers:frontControllers animated:YES];
    }
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searchActive)
        return [self _numberOfSectionsForSearchedData];
	else
        return 1 + (_extraViewControllers.count>0?ModelBrowserSectionExtra:ModelBrowserSectionBrowser);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchActive)
    {
        return [self _numberOfRowsForSearchedDataInSection:section];
    }
    else
	{
        if ( section == ModelBrowserSectionBrowser)
        {
            return _documentModel?ModelBrowserRowCount:0;
        }
        else if ( section == ModelBrowserSectionExtra)
        {
            return _extraViewControllers.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchActive)
        return [self _searchedDataCellForRowAtIndexPath:indexPath];
 
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"Cell";
    NSString *identifier = CellIdentifier;
        
    SWModelBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[SWModelBrowserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.accessory = SWModelBrowserCellAccessoryTypeDisclosureIndicator;
        UILabel *textLabel = cell.textLabel;
        textLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.67f];
        //cell.textLabel.alpha = 0.67f;
        //cell.rightDetailTextLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.67f];
        cell.rightDetailTextLabel.textColor = [UIColor colorWithWhite:0.5f alpha:0.67f];
        //cell.rightDetailTextLabel.alpha = 0.67f;
        cell.imageView.alpha = 0.67f;
        cell.darkContext = YES;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        UIColor *color = DarkenedUIColorWithRgb(SystemDarkerBlueColor, 1.0);
        view.backgroundColor = color;
        [cell setSelectedBackgroundView:view];
    }
    
    NSString *text = nil;
    NSString *imageName = nil;
    NSString *detailText = nil;
    
    if (section == ModelBrowserSectionBrowser)
    {
        NSString *detailFormat = nil;
        switch (row)
        {
            case ModelBrowserRowSystemItems:
            {
                text = NSLocalizedString(@"System",nil);
                detailFormat = NSLocalizedString( @"%d items", nil );
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.systemItems.count];
                imageName = @"71-compass.png";
//                
//                
//                text = [NSString stringWithFormat:@"%@ %@",
//                    [NSString fontAwesomeIconStringForEnum:FAIconStarEmpty],
//                    NSLocalizedString(@"System",nil)];
//                
//                NSDictionary *baseAttrDict = @
//                {
//                    NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
//                    NSForegroundColorAttributeName:[UIColor lightGrayColor],
//                };
//                
//                NSDictionary *awesomeAttrDict = @
//                {
//                    NSFontAttributeName:[UIFont fontWithName:kFontAwesomeFamilyName size:18],
//                    NSForegroundColorAttributeName:[UIColor lightGrayColor]
//                };
//                
//                NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text attributes:baseAttrDict];
//                
//                [attrText setAttributes:awesomeAttrDict range:NSMakeRange(0, 1)];
//                
//                cell.textLabel.attributedText = attrText;
                
                break;
            }
            case ModelBrowserRowPages:
                text = NSLocalizedString(@"Pages",nil);
                detailFormat = NSLocalizedString( @"%d pages", nil );
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.pages.count];
                imageName = @"96-book.png";
                break;
                
            case ModelBrowserRowBackgroundItems:
                text = NSLocalizedString(@"Background",nil);
                detailFormat = NSLocalizedString(@"%d items",nil);
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.backgroundItems.count];
                imageName = @"97-puzzle-piece.png";
                break;
                
            case ModelBrowserRowAlarms:
                text = NSLocalizedString(@"Alarms",nil);
                detailFormat = NSLocalizedString(@"%d alarms",nil);
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.alarmItems.count];
                imageName = @"78-stopwatch.png";
                break;
                
            case ModelBrowserRowProjectUsers:
                text = NSLocalizedString(@"Users", nil);
                detailFormat = NSLocalizedString(@"%d users",nil);
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.projectUsers.count];
                imageName = @"112-group.png";
                break;
                
            case ModelBrowserRowDataLoggers:
                text = NSLocalizedString(@"Data loggers", nil);
                detailFormat = NSLocalizedString(@"%d data loggers",nil);
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.dataLoggerItems.count];
                imageName = @"293-database.png";
                break;
                
            case ModelBrowserRowRestApis:
                text = NSLocalizedString(@"REST connectors", nil);
                detailFormat = NSLocalizedString(@"%d apis",nil);
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.restApiItems.count];
                imageName = @"55-network.png";
                break;
                
            case ModelBrowserRowSources:
                text = NSLocalizedString(@"PLC Connectors",nil);
                detailFormat = NSLocalizedString(@"%d sources",nil);
                detailText = [NSString stringWithFormat:detailFormat, _documentModel.sourceItems.count];
                imageName = @"55-network.png";
                break;
                
            default:
                break;
        }
    }
    
    else if ( section == ModelBrowserSectionExtra )
    {
        UIViewController *controller = [_extraViewControllers objectAtIndex:row];
        text = controller.title;
        detailText = nil;
        imageName = nil;
    }
    
    // setup the cell
    
    cell.textLabel.text = text;

    UIImage *image = nil;
    if ( imageName )
    {
        UIImage *image0 = [UIImage imageNamed:imageName];
        CGFloat height = image0.size.height;
        image = [image0 resizedImageWithContentMode:UIViewContentModeCenter bounds:CGSizeMake(30,height) contentScale:image0.scale interpolationQuality:kCGInterpolationDefault cropped:NO];
    }
    
    cell.imageView.image = image;
    
//    UIImageView *imageView = cell.imageView;
//    imageView.frame = CGRectMake(0, 0, 40, 40);
//    imageView.contentMode = UIViewContentModeCenter;
//    imageView.image = [UIImage imageNamed:imageName];
    
    cell.rightDetailTextLabel.text = detailText;
        
    [self _setTableAccessoryForCell:cell];
	   
    return cell;
}




- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_searchActive)
        return [self _searchViewForHeaderInSection:section];
    
    NSString *title = nil;
    
    if (section == ModelBrowserSectionBrowser)
        title = NSLocalizedString(@"MODEL OBJECTS",nil);
    
    else if ( section == ModelBrowserSectionExtra)
        title = NSLocalizedString(@"DATA PICKERS",nil);
    
    
    SWTableSectionHeaderView *tvh = [[SWTableSectionHeaderView alloc] init];
    //tvh.titleLabel.alpha = 0.67f;
    tvh.title = title;
    
    return tvh;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_searchActive)
        return [self _searchHeightForHeaderInSection:section];

    return 30;
}

#pragma mark - Table view delegate

//- (CGFloat)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 0;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ( [cell respondsToSelector:@selector(beginObservingModel)] )
    {
        [(id)cell beginObservingModel];
    }
    
    if (_searchActive)
    {
        [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
           
        if (_browsingStyle != SWModelBrowsingStyleSeeker)
            return;
        
        if (indexPath.section == ModelBrowserSearchTypeSectionTags) 
        {
            SWTagCell *tagCell = (id)cell;
            
            SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
            id seekedObject = [manager currentSeekedValue];
            
            if (seekedObject == tagCell.sourceNode.readExpression) // <------- Aquí mirem si el tag que es mostra està actualment sel·leccionat en la lupa.
                cell.selected = YES;
            else
                cell.selected = NO;
        }
    }
    else
    {
    
        UIColor *ncolor = UIColorWithRgb(DarkenedRgbColor(SystemDarkerBlueColor, 0.7f));
        //UIColor *ncolor = [UIColor colorWithWhite:0.3f alpha:1.0f];
        [cell setBackgroundColor:ncolor];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ( [cell respondsToSelector:@selector(endObservingModel)] )
    {
        [(id)cell endObservingModel];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (_searchActive)
    {
        [self _searchDidSelectRowAtIndexPath:indexPath];
    } 
    else
    {
        UIViewController *vc = nil;
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        if ( section == ModelBrowserSectionBrowser)
        {
            SWArrayType arrayType = [self _arrayTypeForRow:row];
            [self setFrontViewControllerOfArrayType:arrayType animated:YES];
            return;
        }
        
        else if ( section == ModelBrowserSectionExtra )
        {
            UIViewController *evc = [_extraViewControllers objectAtIndex:row];
            vc = evc;
        }
        
        //vc.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        vc.preferredContentSize = self.preferredContentSize;
        SWRevealController *revealController = (SWRevealController*)self.revealViewController;
        [revealController setFrontViewControllerWithControllers:@[vc] animated:YES];
    }
}

#pragma mark - SWRevealControllerDelegate Delegate Methods

- (void)_setTableAccessoryForCell:(SWModelBrowserCell*)cell
{
    SWRevealViewController *revealController = self.revealViewController;
    FrontViewPosition position = revealController.frontViewPosition;
    
    CGFloat rightOffset = 0;
    if ( position == FrontViewPositionLeft || position == FrontViewPositionRight )
         rightOffset = revealController.rearViewRevealOverdraw;
    
    cell.rightOffset = rightOffset;
    [cell layoutSubviews];
}


- (void)_selectRowForPresentedFrontController
{
    if ( _browsingStyle == SWModelBrowsingStyleSeeker )
        return;
    
    NSInteger section = NSNotFound;
    NSInteger row = NSNotFound;
    SWRevealController *revealController = (id)self.revealViewController;
    //FrontViewPosition position = revealController.frontViewPosition;

    //if ( position == FrontViewPositionRight )
    {
        UIViewController *rootController = [revealController rootFrontViewController];
        if ( [rootController isKindOfClass:[SWArrayTypeBrowserController class]] )
        {
            SWArrayTypeBrowserController *arrayTypeController = (id)rootController;
            section = ModelBrowserSectionBrowser;
            SWArrayType arrayType = arrayTypeController.arrayType;
            row = [self _rowForArrayType:arrayType];
        }
        else
        {
            section = ModelBrowserSectionExtra;
            row = [_extraViewControllers indexOfObjectIdenticalTo:rootController];
        }
        
        if ( section != NSNotFound && row != NSNotFound )
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
}


//- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
//{
//    UITableView *table = self.tableView;
//    CGRect rect = table.frame;
//    if ( position != FrontViewPositionRight )
//    {
//        rect.size.width = revealController.rearViewRevealWidth+revealController.rearViewRevealOverdraw;
//        [UIView animateWithDuration:0.25f animations:^
//        {
//            table.frame = rect;
//        }];
//    }
//}


- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position
{
//    UITableView *table = self.tableView;
//    CGRect rect = table.frame;
//    if ( position != FrontViewPositionRight )
//    {
//        rect.size.width = revealController.rearViewRevealWidth+revealController.rearViewRevealOverdraw;
//        table.frame = rect;
//    }


    CGFloat revealWidth = revealController.rearViewRevealWidth;
    CGFloat overDraw = revealController.rearViewRevealOverdraw;
    
    CGFloat width = revealWidth;
    if ( position == FrontViewPositionRightMost || position == FrontViewPositionRightMostRemoved )
         width += overDraw;

    if ( !_searchActive )
    {
        UITableView *table = self.tableView;
        for ( SWModelBrowserCell *cell in table.visibleCells )
        {
            cell.rightOffset = revealWidth+overDraw-width;;
            [cell layoutSubviews];
        }
    }

    CGRect searchFrame = _searchBar.frame;
    searchFrame.size.width = width;
    _searchBar.frame = searchFrame;

}





- (void)revealController:(SWRevealController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if ( position == FrontViewPositionRight )
        [self _selectRowForPresentedFrontController];
}


- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{

//    UITableView *table = self.tableView;
//    CGRect rect = table.frame;
//    if ( position == FrontViewPositionRight )
//    {
//        rect.size.width = revealController.rearViewRevealWidth;
//        [UIView animateWithDuration:0.25f animations:^
//        {
//            table.frame = rect;
//        }];
//    }
}





#pragma mark - UISearchBar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    [_searchBar setText:nil];
    
    [self _stopSearch];
    
    SWRevealViewController *revealController = self.revealViewController;
    FrontViewPosition frontViewPosition = revealController.frontViewPosition;
    if ( revealController.frontViewController != nil &&
        (frontViewPosition == FrontViewPositionRightMost || frontViewPosition == FrontViewPositionRightMostRemoved))
    {
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:YES];
    
    SWRevealViewController *revealController = self.revealViewController;
    [revealController setFrontViewPosition:FrontViewPositionRightMostRemoved animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchText = searchText;
        
    if (!searchText || searchText.length == 0)
    {        
        [self _stopSearch];
    }
    else
    {
        [self _performSearchWithText:searchText];
    }
}



#pragma mark - Document Model Observer

- (void)documentModel:(SWDocumentModel *)docModel didInsertObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet *)indexes
{
    if (!_searchActive)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self _rowForArrayType:type] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)documentModel:(SWDocumentModel *)docModel didRemoveObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet *)indexes
{
    if (!_searchActive)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self _rowForArrayType:type] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)documentModelChangeCheckpoint:(SWDocumentModel *)docModel
{
    if ( _searchActive )
        [self _reloadCurrentSearch];
}

@end
