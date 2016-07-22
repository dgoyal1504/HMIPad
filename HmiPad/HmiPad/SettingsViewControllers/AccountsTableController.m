//
//  AccountsTableController.m
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "AccountsTableController.h"
//#import "NewAccountTableController.h"
#import "EditAccountTableController.h"

#import "ControlViewCell.h"
#import "AppUsersModel.h"

#import "SWColor.h"

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif


@interface AccountsTableController()<AppUsersModelObserver>
@end


@implementation AccountsTableController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
///////////////////////////////////////////////////////////////////////////////////////////

enum sectionsInTable
{
    kDefaultAccountsSection = 0,
    kOtherAccountsSection,
    kAddAccountSection,
};

#define TotalSectionsInTable 3

enum rowsInDefaultAccountsSection
{
    kFirstDefaultAccountsRow = 0
    //kAdministratorAccountRow = 0,
    //kNobodyAccountRow
};


enum rowsInOtherAccountsSection
{
    kFirstOtherAccountsRow = 0
};

enum rowsInAddAccountSection
{
    kAddAccountRow = 0
};




///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark AccountsTableController methods
///////////////////////////////////////////////////////////////////////////////////////////////



/*
//---------------------------------------------------------------------------------------------
- (void)setupArrays
{
    [usernamesArray removeAllObjects];
    [defaultUsersArray removeAllObjects]; 
    for ( NSString *username in profilesDictionary )
    {
        UserProfile *profile = [profilesDictionary objectForKey:username];
        if ( [profile isDefault] )
        {
            [defaultUsersArray addObject:username];
        }
        else
        {
            [usernamesArray addObject:username];
        }
    }
}
*/


//---------------------------------------------------------------------------------------------
- (id)init
{
    NSLog1( @"AccountsTableController: init") ;
    //if ( self = [super initWithStyle:UITableViewStylePlain] )
    if ( (self = [super initWithStyle:UITableViewStyleGrouped]) )
    {
  /*      profilesDictionary = [sharedDomusModel() profiles];
        usernamesArray = [[NSMutableArray alloc] init];
        defaultUsersArray = [[NSMutableArray alloc] init];
        [self setupArrays];*/
    }
    return self;
}



//---------------------------------------------------------------------------------------------
- (void)dealloc
{
    // profilesDictionary is neither allocated or retained so nothing to do here
    
    NSLog1( @"AccountsTableController: dealloc") ;
//    [super dealloc];
}


//---------------------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
}


//---------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[[[self navigationController] navigationBar] setDelegate:self] ;
    
    
    [[self navigationItem] setTitle:NSLocalizedString(@"Accounts",nil)] ;
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    [[self tableView] setAllowsSelectionDuringEditing:YES];
    //[[self tableView] setDelaysContentTouches:NO];
    
    /*
    SwitchViewCell *headerCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    [[headerCell label] setText:@"Header View"];
    [[self tableView] setTableHeaderView:headerCell];
    */
    
    /*
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil]; // addButton is a view controller property
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"title"];
    UINavigationBar *subBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,320,44)];

    [navItem setLeftBarButtonItem:addButton] ;
    [addButton release];
    
    [navItem setRightBarButtonItem:[self editButtonItem]]; 
    
    [subBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [subBar setBarStyle:UIBarStyleBlackTranslucent];
    [subBar pushNavigationItem:navItem animated:NO];
    [navItem release];
    
    [[self tableView] setTableHeaderView:subBar];
    [subBar release];
    */
}

//---------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated 
{
    NSLog1( @"AccountsTableController viewWillAppear" );
    [super viewWillAppear:animated];
    
    [[self tableView] reloadData];
    [usersModel() addObserver:self];
}

//---------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [usersModel() removeObserver:self];
	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

//---------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    return YES ;
}

//---------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning 
{
    NSLog1( @"AccountsTableController didReceiveMemoryWarning" ) ;
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}




///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView Data Source methods
///////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return TotalSectionsInTable;
}

//---------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger number ;
    switch ( section )
    {
        case kDefaultAccountsSection:
           // number = [defaultUsersArray count] ;
            number = [[usersModel() defaultUsersArray] count] ;
            break ;
            
        case kOtherAccountsSection:
            //number = [usernamesArray count] ;
            number = [[usersModel() generalUsersArray] count] ;
            break ;
            
        case kAddAccountSection:
            number = 1 ;
            break ;
            
        default:
            number = 0 ;
            break ;
    }
    return number ;
}

//---------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *str ; 
    switch ( section )
    {
        case kDefaultAccountsSection:
            str = NSLocalizedString( @"Default accounts", nil ) ;
            break ;
            
        case kOtherAccountsSection:
            str = NSLocalizedString( @"Other accounts", nil ) ;
            break ;
        
        case kAddAccountSection:
            str = @"" ;
            break ;
            
        default:
            str = @"" ;
            break ;
    }

    return str ;
}

static NSString *DefaultAccountCellIdentifier = @"DefaultAccountCell";
static NSString *OtherAccountCellIdentifier = @"OtherAccountCell";
static NSString *AddAccountCellIdentifier = @"AddAccountCell";

//---------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    NSString *identifier ;
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if ( section == kOtherAccountsSection ) identifier = OtherAccountCellIdentifier;
    else if ( section == kDefaultAccountsSection ) identifier = DefaultAccountCellIdentifier;
    else identifier = AddAccountCellIdentifier;
    
    LabelViewCell *cell = (LabelViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) 
    {
        cell = [[LabelViewCell alloc] initWithReuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue]; 
        [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator] ;
        ControlViewCellContentView *cellContentView = [cell cellContentView] ;
        //[cell setHidesAccessoryWhenEditing:NO];
        
        // Comented out degut al bug que es descriu més endevant
        /// [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator]; 
        
        if ( identifier == OtherAccountCellIdentifier )
        {
            //[[cell label] setTextColor:[ControlViewCell theSystemDarkBlueColor]];
            [cellContentView setMainTextColor:UIColorWithRgb(TheSystemDarkBlueTheme)];
        }
        
        if ( identifier == AddAccountCellIdentifier ) 
        {
            [cellContentView setMainTextFont:[UIFont boldSystemFontOfSize:15]] ;
            [cellContentView setMainTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
            [cellContentView setCenteredMainText:YES] ;
            [cell setMainText:NSLocalizedString(@"New account", nil)] ;
        }
        else
        { 
            [cell setIndentationWidthForDecorationType:ItemDecorationTypeBlueCheckMark right:NO];
        }
    }
    
    
    // Set up the cell...
    
    // Teoricament es podria posar el tipus d'accesori a la creacio de la celda, pero degut
    // a un bug de UIKit, quan es reusa una celda que ha estat esborrada, el accesori queda
    // a UITableViewCellAccessoryNone. Per tant l'establim explicitament aqui cada vegada
    if ( identifier == AddAccountCellIdentifier ) 
    {
        //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        return cell ;
    }

    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSString *name ;
    UserProfile *profile ;
    
    if ( identifier == DefaultAccountCellIdentifier )
    {
        name = [[usersModel() defaultUsersArray] objectAtIndex:row];
    }
    else 
    {
        //name = [usernamesArray objectAtIndex:row];
        name = [[usersModel() generalUsersArray] objectAtIndex:row];
        //NSLog11( @"AccountsTableController cellForRowAtIndexPath cell:%@ name:%@ accesory:%d", [[cell label] text], name, [cell accessoryType] ) ;
        
    }
      
    //profile = [profilesDictionary objectForKey:name];
    profile = [usersModel() getProfileCopyForUser:name];
    if ( [profile enabled] )
    {
        [cell setIndentationLevel:0];
        [cell setDecorationType:ItemDecorationTypeBlueCheckMark right:NO animated:NO];
    }
    else
    {
        [cell setIndentationLevel:1];
        [cell setDecorationType:ItemDecorationTypeNone right:NO animated:NO];
    }
    
        
    int level = [profile level] ;
    NSString *priority = [NSString stringWithFormat:@"%@ %d", (level==0?@"=":@"≤"), level] ;
    //[[cell label] setText:name];
    [cell setMainText:name];
    [[cell secondLabel] setText:priority];
    
    return cell;
}


//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSInteger section = [indexPath section];
    if ( section == kOtherAccountsSection) return YES ;  // fa que desaparegui el disclosure excepte si tenim setHidesAccessoryWhenEditing:NO
    else return NO;
}


//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // fa que no apareguin les barres de moure
}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        // Delete the row from the data source
        NSInteger row = [indexPath row];
        NSAssert( [indexPath section] == kOtherAccountsSection, @"section should be kOtherAccountsSection") ;

        BOOL done = [usersModel() removeGeneralUserAtIndex:row error:nil];  // gestio error
        (void)done;
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) 
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog1(@"AccountsTableController:Moving Account from %@ to %@", fromIndexPath, toIndexPath) ;
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView Delegate methods
///////////////////////////////////////////////////////////////////////////////////////////////




- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog1(@"AccountsTableController:WillSelectRow") ;
    return indexPath;
}

//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if ( section == kOtherAccountsSection) return NO ;  // si es YES mou el backgrownd cap a la dreta
    else return NO;
}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
    NSInteger section = [indexPath section] ;
    NSInteger row = [indexPath row] ;
    UIViewController *viewController ;
    
    /*
    if ( section == kAddAccountSection && row == kAddAccountRow )      
    {
        viewController = [[NewAccountTableController alloc] init];
    }
    else
    */
    {
        NSString *user ;
        UInt16 flags ;
        
        if ( section == kDefaultAccountsSection )
        {
            user = [[usersModel() defaultUsersArray] objectAtIndex:row];
            if ( [usersModel() userIsAdmin:user] ) flags = ( kShouldShowOldPassword ) ;
            else flags = ( kShouldShowActivate ) ;
        }
        
        else if ( section == kOtherAccountsSection  )
        {
            user = [[usersModel() generalUsersArray] objectAtIndex:row];
            flags = ( kShouldShowActivate | kShouldShowPriority ) ;
        }       
        
        else if ( section == kAddAccountSection )
        {
            user = nil ;
            flags = ( kShouldShowActivate | kShouldShowUser | kShouldShowPriority ) ;
        }
    
        viewController = [[EditAccountTableController alloc] initWithUsername:user flags:flags] ;
    }
    
    [[self navigationController] pushViewController:viewController animated:YES];
//    [viewController release];
}


//---------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if ( section == kOtherAccountsSection ) return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleNone;
}

/*
//---------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView 
                            targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
                            toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
//    int row = [proposedDestinationIndexPath row];
//    if ( row == 0 ) row = 1 ;
//    return [NSIndexPath indexPathForRow:row inSection:0];
    return proposedDestinationIndexPath ;
}
*/


#pragma mark AppUsersModelObserver

- (void)appUsersModel:(AppUsersModel*)usersModel didDeleteGeneralUserAtIndex:(NSInteger)index
{
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kOtherAccountsSection];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)appUsersModelGeneralUserListingDidChange:(AppUsersModel*)usersModel
{
    UITableView *tableView = [self tableView];
    [tableView reloadData];
}



///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CallBacks del newAccountController
///////////////////////////////////////////////////////////////////////////////////////////////

////---------------------------------------------------------------------------------------------
//- (void)topViewControllerDidCancel:(UITableViewController*)topController
//{
//    NSLog1( @"AccountsTableController topViewControllerDidCancel") ;
//    [[self navigationController] popViewControllerAnimated:YES];
//}

//---------------------------------------------------------------------------------------------
//- (void)topViewControllerDidSave:(UITableViewController*)topController
//{
//    NSLog1( @"AccountsTableController topViewControllerDidSave") ;
//    

//    NSError *outError = nil ;
//    [usersModel() saveProfilesToDiskOutError:&outError] ;  //gestioerror
    
//#warning observar per actualitzar actiu/no actiu
//    [[self tableView] reloadData];
//    
//    [[self navigationController] popViewControllerAnimated:YES];
//}


@end

