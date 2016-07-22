//
//  AccountsTableController.m
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "ManageAccountsController.h"

#import "AppUsersModel.h"
#import "UserDefaults.h"

#import "EditAccountTableController.h"
//#import "SWRedeemViewController.h"
#import "SWTableViewMessage.h"
#import "ControlViewCell.h"

#import "UIViewController+SWSendMailControllerPresenter.h"

#import "SWColor.h"

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif


@interface ManageAccountsController()<AppUsersModelObserver>
{
    SWTableViewMessage *mEditAccount;
    SWTableViewMessage *mNewAccount;
    SWTableViewMessage *mRedemCode;
    SWTableViewMessage *mSubscription;
    
    BOOL _isShowingRedeemSection;
    
//    int kEditAccountSection;
//    int kRedemCodeSection;
//    int kSubscriptionSection;
//    int kLocalAccountsSection;
//    int kOtherAccountsSection;
//    int kNewAccountSection;
//    int TotalSectionsInTable;
}
@end


@implementation ManageAccountsController
{
    BOOL _deleting;
}

#if HMiPadDev
enum sections
{
    kEditAccountSection = 0,
    kLocalAccountsSection,
    kOtherAccountsSection,
    kNewAccountSection,
    TotalSectionsInTable,
    
        kRedemCodeSection,
        kSubscriptionSection,
};

#elif HMiPadRun
enum sections
{
    kEditAccountSection = 0,
    kOtherAccountsSection,
    kNewAccountSection,
    kRedemCodeSection,
    TotalSectionsInTable,
    
        kLocalAccountsSection,
        kSubscriptionSection,
};

#endif

enum rowsInDefaultAccountsSection
{
    kFirstDefaultAccountsRow = 0,
};

enum rowsInOtherAccountsSection
{
    kFirstOtherAccountsRow = 0
};

enum rowsInEditAccountSection
{
    kEditAccountEditRow = 0,
    TotalRowsInEditAccountSection,
};

enum rowsInRedemCodeSection
{
    kRedemCodeRow,
    TotalRowsInRedemCodeSection,
};

enum rowsInNewAccountSection
{
    kNewAccountRow = 0,
    TotalRowsInNewAccountSection,
};



enum rowsInNewSubscriptionSection
{
    kSubscriptionRow = 0,
    TotalRowsInSubscriptionSection,
};



#pragma mark ManageAccountsTableController methods



//---------------------------------------------------------------------------------------------
- (id)init
{
    NSLog1( @"AccountsTableController: init") ;
    if ( (self = [super initWithStyle:UITableViewStyleGrouped]) )
    {
//        kEditAccountSection = -1;
//        kRedemCodeSection = -1;
//        kSubscriptionSection = -1;
//        kLocalAccountsSection = -1;
//        kOtherAccountsSection = -1;
//        kNewAccountSection = -1;
//        TotalSectionsInTable = -1;
//        
//    #if HMiPadDev
//        int i = 0;
//        kEditAccountSection = i++;
//        kLocalAccountsSection = i++;
//        kOtherAccountsSection = i++;
//        kNewAccountSection = i++;
//        kRedemCodeSection = i++;
//        kSubscriptionSection = i++;
//        TotalSectionsInTable = i++;
//
//    #elif HMiPadRun
//        int i = 0;
//        kEditAccountSection = i++;
//        //kNewActivationCodeSection = i++;
//        //kDefaultAccountsSection = i++;
//        kOtherAccountsSection = i++;
//        kNewAccountSection = i++;
//        kRedemCodeSection = i++;
//        TotalSectionsInTable = i++;
//        
//    #endif

    }
    return self;
}



//---------------------------------------------------------------------------------------------
- (void)dealloc
{
    NSLog1( @"AccountsTableController: dealloc") ;
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
    
    [[self navigationItem] setTitle:NSLocalizedString(@"Accounts",nil)] ;
  //  [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    [[self tableView] setAllowsSelectionDuringEditing:YES];
    
    [self _establishSectionsForCurrentUserAnimated:NO];
    //[[self tableView] setDelaysContentTouches:NO];
}

//---------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    NSLog1( @"AccountsTableController viewWillAppear" );
    
    [[self tableView] reloadData];
    [self _establishSectionsForCurrentUserAnimated:NO];

    [self establishActivityIndicator:[usersModel() isUpdatingProfile] animated:NO];
    
    UINavigationController *navController = [self navigationController];
    [navController setToolbarHidden:YES animated:YES];
    
    [usersModel() addObserver:self];
}

//---------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    NSLog1( @"AccountsTableController viewDidAppear" );
}


- (void)viewWillDisappear:(BOOL)animated
{
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];

    [usersModel() removeObserver:self];
    
    
    NSLog1( @"AccountsTableController viewWillDisappear" );
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    NSLog1( @"AccountsTableController viewDidDisappear" );
	[super viewDidDisappear:animated];
}


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


#pragma mark Private

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mEditAccount
{
    if ( mEditAccount == nil )
    {
        mEditAccount = [[SWTableViewMessage alloc] initForSectionFooter] ;
        [mEditAccount setMessage:NSLocalizedString( @"ManageAccountsSectionEditAccountMessage", nil)] ;  // localitzar
    }
    return mEditAccount ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mNewAccount
{
    if ( mNewAccount == nil )
    {
        mNewAccount = [[SWTableViewMessage alloc] initForSectionFooter] ;
        [mNewAccount setMessage:NSLocalizedString( @"ManageAccountsSectionNewAccountMessage", nil)] ;  // localitzar
    }
    return mNewAccount ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mRedemCode
{
    if ( mRedemCode == nil )
    {
        mRedemCode = [[SWTableViewMessage alloc] initForSectionFooter] ;
        [mRedemCode setMessage:NSLocalizedString( @"ManageAccountsSectionRedemCodeMessage", nil)] ;  // localitzar
    }
    return mRedemCode ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mSubscription
{
    if ( mSubscription == nil )
    {
        mSubscription = [[SWTableViewMessage alloc] initForSectionFooter] ;
        [mSubscription setMessage:NSLocalizedString( @"ManageAccountsSectionSubscriptionMessage", nil)] ;  // localitzar
    }
    return mSubscription ;
}


- (void)establishActivityIndicator:(BOOL)putIt animated:(BOOL)animated
{
    UIBarButtonItem *btnItem = nil ;
    if ( putIt )
    {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity startAnimating];

        btnItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    }
    [[self navigationItem] setRightBarButtonItem:btnItem animated:YES];
}


#pragma mark TableView Data Source methods

//---------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return TotalSectionsInTable;
}

//---------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger number ;
    if ( section == kLocalAccountsSection )
        number = [[usersModel() localUsersArray] count] ;
    
    else if ( section == kOtherAccountsSection )
        number = [[usersModel() generalUsersArray] count] ;
    
    else if ( section == kEditAccountSection )
        number = TotalRowsInEditAccountSection;
    
    else if ( section == kRedemCodeSection )
        number = _isShowingRedeemSection?TotalRowsInRedemCodeSection:0;
    
    else if ( section == kNewAccountSection )
        number = TotalRowsInNewAccountSection;
    
    else if ( section == kSubscriptionSection )
        number = TotalRowsInSubscriptionSection;
    
    else
        number = 0 ;

    return number ;
}

//---------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *str = nil ;
    
    if ( [self tableView:aTableView numberOfRowsInSection:section] == 0 )
        return str;
    
    if ( section == kLocalAccountsSection )
        str = NSLocalizedString( @"Local Accounts", nil ) ;

    else if ( section == kOtherAccountsSection )
        str = NSLocalizedString( @"Other User Accounts", nil ) ;

    else if ( section == kEditAccountSection )
        str = NSLocalizedString( @"Current User", nil ) ;
        //str = [defaults() currentUser];
    
    else if ( section == kNewAccountSection )
        str = NSLocalizedString( @"User Account Creation", nil ) ;
    
    else if ( section == kRedemCodeSection )
        str = NSLocalizedString( @"Project Activation", nil ) ;
    
    else if ( section == kSubscriptionSection )
        str = NSLocalizedString( @"Project Distribution", nil ) ;
    
    else if ( section == kNewAccountSection )
        str = nil ;
    
    else
        str = nil ;

    return str ;
}

static NSString *DefaultAccountCellIdentifier = @"DefaultAccountCell";
static NSString *OtherAccountCellIdentifier = @"OtherAccountCell";
//static NSString *AddAccountCellIdentifier = @"AddAccountCell";
static NSString *ButtonLikeCellIdentifier = @"ButtonLikeCell";
static NSString *CurrentUserCellIdentifier = @"CurrentUserCell";


//---------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    NSString *identifier ;
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if ( section == kOtherAccountsSection ) identifier = OtherAccountCellIdentifier;
    else if ( section == kLocalAccountsSection ) identifier = DefaultAccountCellIdentifier;
    else if ( section == kEditAccountSection && row == kEditAccountEditRow ) identifier = CurrentUserCellIdentifier;
    else identifier = ButtonLikeCellIdentifier;
    
    LabelViewCell *cell = (LabelViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) 
    {
        cell = [[LabelViewCell alloc] initWithReuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue]; 
        //[cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator] ;
        ControlViewCellContentView *cellContentView = [cell cellContentView] ;
        
        if ( identifier == OtherAccountCellIdentifier )
        {
            //[[cell label] setTextColor:[ControlViewCell theSystemDarkBlueColor]];
            [cellContentView setMainTextColor:UIColorWithRgb(TheSystemDarkBlueTheme)];
        }
        
        else if ( identifier == ButtonLikeCellIdentifier )
        {
            [cell setIsButtonLikeCell:YES];
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
    if ( identifier == ButtonLikeCellIdentifier ) 
    {
        //[cell setAccessoryType:UITableViewCellAccessoryNone];
        
        if ( section == kRedemCodeSection )
        {
            [cell setMainText:NSLocalizedString(@"Redeem Activation Code", nil)] ;
        }
        else if ( section == kNewAccountSection )
        {
            [cell setMainText:NSLocalizedString(@"New Account", nil)] ;
        }
        else if ( section == kSubscriptionSection )
        {
            [cell setMainText:NSLocalizedString(@"Subscribe to Integrators Service", nil)] ;
        }
        
        return cell ;
    }

    //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSString *name = nil ;
    UserProfile *profile = nil ;
    
    if ( identifier == DefaultAccountCellIdentifier )
    {
        name = [[usersModel() localUsersArray] objectAtIndex:row];
    }
    else if ( identifier == OtherAccountCellIdentifier )
    {
        name = [[usersModel() generalUsersArray] objectAtIndex:row];
    }
    else if ( identifier == CurrentUserCellIdentifier )
    {
        name = [usersModel() currentUserName];
    }

    profile = [usersModel() getProfileCopyForUser:name];
    ControlViewCellContentView *cellContentView = [cell cellContentView];
    if ( profile.updated == NO )
    {
        //name = NSLocalizedString(@"Updating...",nil);
        [cellContentView setMainTextFont:[UIFont italicSystemFontOfSize:15]] ;
    }
    else
    {
        [cellContentView setMainTextFont:[UIFont boldSystemFontOfSize:17]] ;
    }
    
    if ( profile.enabled )
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


////---------------------------------------------------------------------------------------------
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) 
//    {
//        // Delete the row from the data source
//        NSInteger row = [indexPath row];
//        NSAssert( [indexPath section] == kOtherAccountsSection, @"section should be kOtherAccountsSection") ;
//
//        _deleting = YES;
//        [usersModel() removeGeneralUserAtIndex:row];  // gestio error
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) 
//    {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog1(@"AccountsTableController:Moving Account from %@ to %@", fromIndexPath, toIndexPath) ;
}


#pragma mark TableView Delegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell.reuseIdentifier isEqualToString:ButtonLikeCellIdentifier] )
    {
        [(LabelViewCell*)cell setIsButtonLikeCell:YES];
    }
}

//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat result = 0;
    if ( section == kEditAccountSection ) result = [[self mEditAccount] getMessageHeight] ;
    else if ( section == kNewAccountSection ) result = [[self mNewAccount] getMessageHeight] ;
    else if ( section == kRedemCodeSection && _isShowingRedeemSection ) result = [[self mRedemCode] getMessageHeight] ;
    else if ( section == kSubscriptionSection ) result = [[self mSubscription] getMessageHeight] ;
    return result;
}

//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = nil;
    if ( section == kEditAccountSection ) result = [self mEditAccount] ;
    else if ( section == kNewAccountSection ) result = [self mNewAccount] ;
    else if ( section == kRedemCodeSection && _isShowingRedeemSection ) result = [self mRedemCode] ;
    else if ( section == kSubscriptionSection ) result = [self mSubscription] ;
    return result ;
}



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
    
    UIViewController *viewController = nil ;
    NSString *user = nil ;
    
    AccountTableControllerType type = 0;
        
    if ( section == kEditAccountSection )
    {
        //flags = (  kShouldShowUser | kShouldShowPriority | kShouldShowOldPassword | kShouldShowPassword | kShouldSeparatePassword ) ;
        type = kAccountControllerUpdateCurrent;
        user = [usersModel() currentUserName];
    }
    
    else if ( section == kLocalAccountsSection )
    {
        //flags = (  /*kShouldShowUser |*/ kShouldShowPriority /*| kShouldShowPassword*/ ) ;
        type = kAccountControllerUpdateLocal;
        user = [[usersModel() localUsersArray] objectAtIndex:row];
    }
    
    else if ( section == kOtherAccountsSection  )
    {
        //flags = ( kShouldShowActivate | /*kShouldShowUser |*/ kShouldShowPriority /*| kShouldShowPassword*/ ) ;
        type = kAccountControllerUpdateRemote;
        user = [[usersModel() generalUsersArray] objectAtIndex:row];
    }
    
    else if ( section == kNewAccountSection )
    {
        //flags = ( kShouldShowActivate | kShouldShowUser | kShouldShowPriority | kShouldShowPassword  ) ;
        type = kAccountControllerNew;
        viewController = [[EditAccountTableController alloc] initWithUsername:nil type:type] ;
    }
    
    else if ( section == kRedemCodeSection)
    {
        [self presentRedeemControllerForActivationCode:nil];
    }
    
    else if ( section == kSubscriptionSection )    // << ---- moure a files o treure totalment
    {
        viewController = nil; // << ---- posar
        //[usersModel() uploadProject];
        //NSLog( @"Subscription code view controller needed" ) ;
        //[filesModel() subscribeToIntegratorService];
    }
    
    if ( user )
    {
        viewController = [[EditAccountTableController alloc] initWithUsername:user type:type] ;
    }
    
    if ( viewController )
    {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:navController animated:YES completion:nil];
        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
#pragma mark establiment del tableView

- (void)_establishSectionsForCurrentUserAnimated:(BOOL)animated
{
    UserProfile *profile = [usersModel() currentUserProfile];
    
    BOOL isLocal = (profile.isLocal != NO);
    BOOL shouldShowRedeemSection = !isLocal;

    UITableView *table = self.tableView;
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

    if ( shouldShowRedeemSection != _isShowingRedeemSection )
    {
        _isShowingRedeemSection = shouldShowRedeemSection;
        mRedemCode = nil;
        if ( kRedemCodeSection < TotalSectionsInTable )
            [indexSet addIndex:kRedemCodeSection];
    }
    
    if ( [indexSet count]> 0 )
    {
        UITableViewRowAnimation animation = animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone;
        [table reloadSections:indexSet withRowAnimation:animation];
    }
}


#pragma mark Notificacio de canvi de user settings

//-----------------------------------------------------------------------------
- (void)currentUserDidChangedNotification:(NSNotification *)notification
{
//    NSString *userName = [usersModel() currentUserName];
//    [[currentAccountCell secondLabel] setText:userName];
    
    [self _establishSectionsForCurrentUserAnimated:YES];
    
}

#pragma mark AppUsersModelObserver

- (void)appUsersModel:(AppUsersModel*)usersModel didDeleteGeneralUserAtIndex:(NSInteger)index
{
    UITableView *tableView = self.tableView;
    if ( !_deleting )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kOtherAccountsSection];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:kOtherAccountsSection] withRowAnimation:UITableViewRowAnimationFade];
    [self establishActivityIndicator:NO animated:YES];
}

- (void)appUsersModelGeneralUserListingDidChange:(AppUsersModel*)usersModel
{
    UITableView *tableView = [self tableView];
    //[tableView reloadData];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:kOtherAccountsSection] withRowAnimation:UITableViewRowAnimationFade];
    [self establishActivityIndicator:NO animated:YES];
}


- (void)appUsersModel:(AppUsersModel *)usersModel willUpdateProfile:(UserProfile *)profile
{
    [self establishActivityIndicator:YES animated:YES];
    [self _reloadProfile:profile];
}

- (void)appUsersModel:(AppUsersModel*)usersModel didUpdateProfile:(UserProfile*)aProfile withError:(NSError*)error
{
//    if ( error )
//    {
//        NSString *title = NSLocalizedString(@"User Account Update", nil );
//        NSString *message = [error localizedDescription];
//        NSString *ok = NSLocalizedString( @"Ok", nil );
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//        [alert show];
//    }
    
    [self _reloadProfile:aProfile];
    [self establishActivityIndicator:NO animated:YES];
}


//- (void)appUsersModel:(AppUsersModel *)usersModel willUpdateProject:(NSString *)projectName
//{
//    [self establishActivityIndicator:YES animated:YES];
//}
//
//
//- (void)appUsersModel:(AppUsersModel *)usersModel didUpdateProject:(NSString *)projectName withError:(NSError *)error
//{
//    if ( error )
//    {
//        NSString *title = NSLocalizedString(@"Project Update", nil );
//        NSString *message = [error localizedDescription];
//        NSString *ok = NSLocalizedString( @"Ok", nil );
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//        [alert show];
//    }
//
//    [self establishActivityIndicator:NO animated:YES];
//}



- (void)_reloadProfile:(UserProfile*)aProfile
{
    void (^block)(NSArray*, UserProfile*, NSInteger) = ^(NSArray *usersArray, UserProfile *profile, NSInteger section)
    {
        NSString *username = profile.username;
        NSInteger index = [usersArray indexOfObject:username];
        if ( index != NSNotFound )
        {
            //NSLog( @"updated %@", username );
            UITableView *tableView = self.tableView;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    };
    
    if ( kEditAccountSection < TotalSectionsInTable)
        block( @[ [usersModel() currentUserName] ], aProfile, kEditAccountSection);
    
    if ( kLocalAccountsSection < TotalSectionsInTable )
        block( [usersModel() localUsersArray], aProfile, kLocalAccountsSection);
    
    if ( kOtherAccountsSection < TotalSectionsInTable )
        block( [usersModel() generalUsersArray], aProfile, kOtherAccountsSection);
}


@end

