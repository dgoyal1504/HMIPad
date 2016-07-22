//
//  EditAccountTableController.m
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "SWEditICLoudUserAccountController.h"
#import "SWTableFieldsController.h"
#import "SWTableFieldsControllerDelegate.h"

#import "SWTableViewMessage.h"
//#import "LoginWindowControllerC.h"

#import "ControlViewCell.h"

//#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"

#import "SWColor.h"


#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif


@interface SWEditICLoudUserAccountController()<SWAppCloudKitUserObserver,SWTableFieldsControllerDelegate,UIActionSheetDelegate>
{
//    BOOL shouldShowActivate:1;
//    BOOL shouldShowUser:1;
//    BOOL shouldShowEmail:1;
//    BOOL shouldShowOldPassword:1;
//    BOOL shouldShowPassword:1;
//    BOOL shouldShowPriority:1;
//    BOOL shouldShowLogin:1;
//    BOOL shouldSeparatePassword:1;
//    
//    int sectionCount;
//    
//    int activateSection;
//    int activateSectionRowCount;
//    int activateRow;
//    
//    int editAccountsSection;
//    int editAccountsSectionRowCount;
//    int usernameRow;
//    int emailRow;
//    int priorityRow;
//    
//    int passwordSection;
//    int passwordSectionRowCount;
//    int oldPasswordRow;          // <-- pertany a editAccountsSection si rellevant si shouldSeparatePassword es NO
//    int passwordRow;
//    int confirmPasswordRow; 
//    
//    int subscribeSection;
//    int subscribeSectionRowCount;
//    int subscribeRow;
//    
//    int loginSection;
//    int loginSectionRowCount;
//    int loginRow;
    
//    UIBarButtonItem *trashButtonItem;
}
@end


#pragma mark EditAccountTableController

//---------------------------------------------------------------------------------------------
@implementation SWEditICLoudUserAccountController

#define kHOffset 14
#define kVOffset 12


//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageView
{
 	if ( messageView == nil )
    {
        messageView = [[SWTableViewMessage alloc] initForSectionFooter]; //initWithTableView:table ];
    }
    return messageView;
}


//---------------------------------------------------------------------------------------------
- (void)updateMessageViewWithText:(NSString*)text
{
    [[self messageView] setMessage:text];
}


//---------------------------------------------------------------------------------------------
- (UIBarButtonItem *)saveButton
{
    if ( saveButton == nil )
    {
        saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doSave:)];
    }
    return saveButton;
}


//---------------------------------------------------------------------------------------------
- (void)establishSaveButton:(BOOL)putIt
{
    UIBarButtonItem *button = nil;
    if ( putIt ) button = [self saveButton];
    [[self navigationItem] setRightBarButtonItem:button animated:YES];
}

//----------------------------------------------------------------------------------------
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


#pragma mark EditAccountTableController methods


- (id)init
{
    self = [super init];
    if ( self )
    {
        profile = [cloudKitUser() currentUserProfile];
    }
    return self;
}


- (void)disposeProperties
{

    NSLog1( @"EditAccountTableController: disposeProperties");
    [rightButton stopWithCancel:YES animated:NO];
}


- (void)dealloc
{

    NSLog1( @"EditAccountTableController: dealloc");
    [self disposeProperties];
}


- (void)loadView
{
    [super loadView];
}





//---------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSString *username = profile.username;
    BOOL isNewUser = controllerType == kAccountControllerNew;
    BOOL isCurrentUser = profile.userId == [usersModel() currentUserId];
    
    rightButton = [[SWTableFieldsController alloc] initWithOwner:self];
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close",nil)
        style:UIBarButtonItemStylePlain /*UIBarButtonSystemItemCancel*/ target:self action:@selector(doClose:)];
        
    UITextField *textField;

    usernameCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil];
    [usernameCell setMainText:NSLocalizedString(@"Username",nil)];
    [textField=[usernameCell textField] setPlaceholder:NSLocalizedString(@"username",nil)];
    [textField setText:profile.username];
    [textField setReturnKeyType:UIReturnKeyNext];
    

    emailCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil];
    [emailCell setMainText:NSLocalizedString(@"Email",nil)];
    [textField=[emailCell textField] setPlaceholder:NSLocalizedString(@"email",nil)];
    [textField setText:profile.email];
    [textField setReturnKeyType:UIReturnKeyDone];

    if ( shouldShowOldPassword )
    {
        oldPasswordCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil];
        [oldPasswordCell setMainText:NSLocalizedString(@"Old password",nil)];
        [textField=[oldPasswordCell textField] setPlaceholder:NSLocalizedString(@"current password",nil)];
        [textField setSecureTextEntry:YES];
        [textField setReturnKeyType:UIReturnKeyNext];
    }
    
    if ( shouldShowPassword )
    {
        passwordCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil];
        textField=[passwordCell textField];
        if ( shouldShowOldPassword )
        {
            [passwordCell setMainText:NSLocalizedString(@"New Password",nil)];
            [textField setPlaceholder:NSLocalizedString(@"new password",nil)];
        }
        else
        {
            [passwordCell setMainText:NSLocalizedString(@"Password",nil)];
            [textField setPlaceholder:NSLocalizedString(@"password",nil)];
        }
        
        [textField setSecureTextEntry:YES];
        [textField setReturnKeyType:UIReturnKeyNext];
    
        confirmPasswordCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil];
        [confirmPasswordCell setMainText:NSLocalizedString(@"Confirm",nil)];
        [textField=[confirmPasswordCell textField] setPlaceholder:NSLocalizedString(@"confirm password",nil)];
        [textField setSecureTextEntry:YES];
    }
        
    sectionCount = 0;
    
    // activate account section
    
    activateSection = shouldShowActivate ? sectionCount++ : -1;
    activateSectionRowCount = 0;
    
    activateRow = shouldShowActivate ? activateSectionRowCount++ : -1;
    
    // edit account section
    BOOL showEditAccountSection = shouldShowUser|shouldShowEmail|shouldSeparatePassword;
    
    editAccountsSection = showEditAccountSection ? sectionCount++ : -1;
    editAccountsSectionRowCount = 0;
    
    usernameRow = shouldShowUser ? editAccountsSectionRowCount++ : -1;
    emailRow = shouldShowEmail ? editAccountsSectionRowCount++ : -1;
    
    if ( shouldSeparatePassword == NO )
    {
        oldPasswordRow = shouldShowOldPassword ? editAccountsSectionRowCount++ : -1;
        passwordRow = shouldShowPassword ? editAccountsSectionRowCount++ : -1;
        confirmPasswordRow = shouldShowPassword ? editAccountsSectionRowCount++ : -1;
    }
    
    priorityRow = shouldShowPriority ? editAccountsSectionRowCount++ : -1;
    
    // separate password section
    
    passwordSection = shouldSeparatePassword ? sectionCount++ : -1;
    passwordSectionRowCount = 0;
    
    if ( shouldSeparatePassword )
    {
        oldPasswordRow = shouldShowOldPassword ? passwordSectionRowCount++ : -1;
        passwordRow = shouldShowPassword ? passwordSectionRowCount++ : -1;
        confirmPasswordRow = shouldShowPassword ? passwordSectionRowCount++ : -1;
    }
    
    
    // subscribe section ( never shown )
    
    //BOOL showSubscribe = (username && profile.unlocked == NO);
    BOOL showSubscribe = NO;
    
    subscribeSection = showSubscribe ? sectionCount++ : -1;
    
    subscribeSectionRowCount = 0;
    subscribeRow = showSubscribe ? subscribeSectionRowCount++ : -1;
    
    
    // login section
    BOOL noLogin = isCurrentUser || isNewUser;
    
    loginSection = -1;
    if ( !noLogin ) loginSection = sectionCount++;
    loginRow = -1;
    loginSectionRowCount = 0;
    if ( !noLogin ) loginRow = loginSectionRowCount++;
    
    // Afageix el boto de Cancel. El boto de save no es posarà fins que s'ha
    // comprovat la consistencia de les dades
    
        
    //[[self tableView] setDelaysContentTouches:NO];
    
    
    // afegim els items al toolbar
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    trashButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashAction:)] ;

    NSArray *toolBarItems ;
    toolBarItems = [NSArray arrayWithObjects:space, trashButtonItem, nil] ;
    [self setToolbarItems:toolBarItems];
    
    UINavigationItem *navItem = [self navigationItem];
    [navItem setLeftBarButtonItem:cancelButton animated:YES];
    
    if ( isNewUser )
    {
        [navItem setTitle:NSLocalizedString(@"New Account",nil)];
        [navItem setPrompt:NSLocalizedString(@"Enter New Account Information",nil)];
    }
    else
    {
        [navItem setTitle:profile.username];
        if ( showEditAccountSection )
            [navItem setPrompt:NSLocalizedString(@"Edit Account Information",nil)];
        else
            [navItem setPrompt:nil];
    }
    
    BOOL noDelete = profile.isLocal || isNewUser /*|| isCurrentUser*/;
    [trashButtonItem setEnabled:!noDelete];
}


//---------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    NSLog1( @"EditAccountTableController: viewDidUnload");
    [super viewDidUnload];
    [self disposeProperties];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog1( @"EditAccountTableController: viewWillAppear");
    UINavigationController *navController = [self navigationController];
    [navController setToolbarHidden:NO animated:YES];
    
    [self establishActivityIndicator:[usersModel() isUpdatingProfile] animated:NO];
    [usersModel() addObserver:self];
}


- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    NSLog1( @"EditAccountTableController: viewDidAppear");
}


//----------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated 
{
    NSLog1( @"EditAccountTableController: viewWillDisappear");
    [rightButton stopWithCancel:YES animated:NO]; // no accespta els canvis
    [usersModel() removeObserver:self];
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    NSLog1( @"EditAccountTableController: viewDidDisappear");
	[super viewDidDisappear:animated];
}


////---------------------------------------------------------------------------------------------
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    
//    return YES;
//}


//---------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning 
{

    NSLog1( @"EditAccountTableController didReceiveMemoryWarning" );
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark TableView Data Source methods

//---------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return sectionCount;
}

//---------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if ( section == activateSection ) return activateSectionRowCount;
    if ( section == editAccountsSection ) return editAccountsSectionRowCount;
    if ( section == passwordSection ) return passwordSectionRowCount;
    if ( section == subscribeSection ) return subscribeSectionRowCount;
    if ( section == loginSection ) return loginSectionRowCount;
    return 0;
}


//---------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *str = nil; 
    if ( section == activateSection ) str = NSLocalizedString(@"Account activation",nil);
    else if ( section == editAccountsSection ) str = NSLocalizedString(@"Account information",nil);
    else if ( section == passwordSection ) str = NSLocalizedString(@"Password Change",nil);
    else if ( section == subscribeSection ) str = nil;
    else if ( section == loginSection ) str = nil;
    return str;
}


//---------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    UITableViewCell *cell = nil;
    
    if ( section == activateSection )
    {
        if ( row == activateRow ) cell = activateCell;
    }
    
    else if ( section == editAccountsSection )
    {
        if ( row == usernameRow ) cell = usernameCell;
        else if ( row == emailRow ) cell = emailCell;
        else if ( row == priorityRow ) cell = priorityCell;
        
        if ( !shouldSeparatePassword )
        {
            if ( row == oldPasswordRow ) cell = oldPasswordCell;
            if ( row == passwordRow ) cell = passwordCell;
            if ( row == confirmPasswordRow ) cell = confirmPasswordCell;
        }
    }
    
    else if ( section == passwordSection )
    {
        if ( shouldSeparatePassword )
        {
            if ( row == oldPasswordRow ) cell = oldPasswordCell;
            else if ( row == passwordRow ) cell = passwordCell;
            else if ( row == confirmPasswordRow ) cell = confirmPasswordCell;
        }
    }
    
    else if ( section == subscribeSection )
    {
        if ( row == subscribeRow ) cell = [self subscribeCell];
    }
    
    else if ( section == loginSection )
    {
        if ( row == loginRow ) cell = [self loginCell];
    }
    
    NSAssert ( cell != nil, @"Cell no pot ser nil" ); 
    return cell;
}


#pragma mark TableView Delegate methods

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog1(@"NewAccountTableController:WillSelectRow");
    return indexPath;
}
*/


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if ( section == subscribeSection && row == subscribeRow )
    {
        NSLog1( @"Launch subscription request");
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ( section == loginSection && row == loginRow )
    {
        NSLog1( @" DO Login" );
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        loginWindow = [[LoginWindowControllerC alloc] init] ;
        [loginWindow setDelegate:self];
        
        NSString *user = profile.username;
        [loginWindow setCurrentAccount:user];
        [loginWindow setUsername:user];
        [loginWindow showAnimated:YES completion:nil] ;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

/*
//---------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footer = nil;
    if ( section == kMessageSection  )
    {
        footer = message;//message;
    }
    return footer;
}
*/


//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSLog1( @"EditAccountTableController heightForFooterInSection section: %d", section );
    if ( section == editAccountsSection && [[messageView message] length] )
    {
        return [messageView getMessageHeight];
    }
    return 0;
}


//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    NSLog1( @"EditAccountTableController viewForFooterInSection section: %d", section );
    if ( section == editAccountsSection && [[messageView message] length] )
    {
        return messageView;
    }
    return nil;
}



#pragma mark Button actions


//--------------------------------------------------------------------------------
- (void)doClose:(id)sender
{
    NSLog1(@"NewAccountTableController:CancelButton");
    [self _doDismiss];
}



//--------------------------------------------------------------------------------
- (void)trashAction:(id)sender
{
    NSLog1( @"deletetouched" );

    NSString *titleFormat = nil;
    BOOL isCurrentUser = profile.userId == [usersModel() currentUserId];
    if ( isCurrentUser )
        titleFormat = NSLocalizedString(@"ActionSheetDeleteTitle%@", nil);
    else
        titleFormat = NSLocalizedString(@"ActionSheetDeleteTitleOther%@", nil);
    
    NSString *title = [NSString stringWithFormat:titleFormat, profile.username];
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    NSString *destructiveTitle = NSLocalizedString(@"Yes, Please Delete", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
        initWithTitle:title
        delegate:self
        cancelButtonTitle:cancelTitle
        destructiveButtonTitle:destructiveTitle otherButtonTitles:nil];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}



- (void)_doDismiss
{
    UINavigationController *navController = [self navigationController];
    if ( navController )
    {
        UIViewController *rootViewController = [[navController viewControllers] objectAtIndex:0];
        if ( self != rootViewController )
        {
            [navController popViewControllerAnimated:YES];
            return ;
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



//--------------------------------------------------------------------------------
- (void)doSave:(id)sender
{
    NSLog1(@"NewAccountTableController:SaveButton");

    //NSString *user = username;
    //NSString *user = profile.username;
    //BOOL createUser = (user == nil );
    
    //BOOL isNewUser = controllerType == kAccountControllerNew;
    
    NSString *user = profile.username;
    if ( shouldShowUser ) user = [[usernameCell textField] text];
    
    //if ( shouldShowUser ) user = [[usernameCell textField] text];
    
    if ( [user length] > 0 ) // si conté alguna cosa es que ha passat el test de errors
    {
        [profile setUsername:user];
        
//        NSString *passwordText = [[passwordCell textField] text];
//        if ( passwordText && [passwordText length] > 0 )
//        {
//            [profile setPassword:passwordText];
//        }
        
        if ( shouldShowEmail )
        {
            NSString *emailText = [[emailCell textField] text];
            if ( emailText && [emailText length] > 0 )
            {
                [profile setEmail:emailText];
            }
        }
        
        if ( shouldShowActivate )
        {
            BOOL enabled = [[activateCell switchv] isOn];
            [profile setEnabled:enabled];
        }
        
        if ( shouldShowPriority )
        {
            NSInteger level = [[[priorityCell textField] text] intValue];
            [profile setLevel:level];
        }
        
        NSString *oldPasswordText = [[oldPasswordCell textField] text];
        NSString *passwordText = [[passwordCell textField] text];

        if ( controllerType == kAccountControllerNew )
        {
            [usersModel() addProfile:profile password:passwordText];
        }
        else
        {
            [usersModel() updateProfile:profile oldPassword:oldPasswordText newPassword:passwordText];
        }
    }
       
    //[self _doDismiss];
}


#pragma mark DeleteButtonViewDelegate

//- (void)deleteButtonViewDidTouch:(SWDeleteButtonView *)deleteButtonView
//{
//    NSLog( @"deletetouched" );
//    
//    NSString *titleFormat = NSLocalizedString(@"ActionSheetDeleteTitle%@", nil);
//    NSString *title = [NSString stringWithFormat:titleFormat, profile.username];
//    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
//    NSString *destructiveTitle = NSLocalizedString(@"Yes, please delete it", nil);
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//        initWithTitle:title
//        delegate:self
//        cancelButtonTitle:cancelTitle
//        destructiveButtonTitle:destructiveTitle otherButtonTitles:nil];
//    
//    [actionSheet showInView:self.view];
//}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger destructiveIndex = [actionSheet destructiveButtonIndex];
    if ( buttonIndex == destructiveIndex )
    {
        BOOL isCurrentUser = profile.userId == [usersModel() currentUserId];
        if ( isCurrentUser )
        {
            [usersModel() deleteProfile:profile];
        }
        else
        {
            [usersModel() deleteProfileRecord:profile];
        }
        [self _doDismiss];
    }
}

#pragma mark Metodes Delegats del LoginWindowController

//---------------------------------------------------------------------------------------------------
- (void)loginWindowDidClose:(LoginWindowControllerC*)sender
{    
    loginWindow = nil;
    [self _doDismiss];
}



#pragma mark AppUsersModelObserver

- (void)appUsersModel:(AppUsersModel*)usersModel didDeleteGeneralUserAtIndex:(NSInteger)index
{

}


- (void)appUsersModelGeneralUserListingDidChange:(AppUsersModel*)usersModel
{

}


- (void)appUsersModel:(AppUsersModel *)usersModel willUpdateProfile:(UserProfile *)profile
{
    [self establishActivityIndicator:YES animated:YES];
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
    
//    [self _updateProfile:aProfile];

    [self establishActivityIndicator:NO animated:YES];
    saveIsShown = NO;   // despres de guardar considerem que ha salvat, encara que sigui amb error
    switchChanged = NO;

    if ( error == nil )
    {
        [self _doDismiss];
    }
}







#pragma mark TextField Delegates, NavigationButtonController, Switch action




//-----------------------------------------------------------------------------
// cridat per el switch de activar compte
- (void)activateSwitchChanged:(UISwitch*)sender;
{
    NSLog1(@"EditAccountTableController activateSwitchChanged :%d", [sender isOn]);
    
    // anotem que el switch s'ha mogut
    switchChanged = YES;
    
    // si el navigationButtonController està actiu no fem res ara
    if ( ![rightButton isStarted] )
    {
        // en cas contrari actualitzem el boto de save d'acord amb l'estat d'errors
        saveIsShown = YES;
        [self establishSaveButton:saveIsShown];
    }
}


//-----------------------------------------------------------------------------
// treu el missatge i mostra el resultat al tableView
- (void)clearErrorsAndUpdate
{
    [self updateMessageViewWithText:@""];
 //   [[self tableView] reloadData];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:editAccountsSection] withRowAnimation:UITableViewRowAnimationNone]; 
    	// posem animation None doncs aparentment esta ja dintre de l'animacio del teclat. reloadData no va perque treu el teclat

}



//----------------------------------------------------------------------------------
- (void)tableFieldsControllerDidStart:(SWTableFieldsController*)controller
{
	[self clearErrorsAndUpdate];
}


//----------------------------------------------------------------------------------
- (void)tableFieldsController:(SWTableFieldsController*)controller 
			didProvideControl:(UIControl*)aControl animated:(BOOL)animated
{
	UIBarButtonItem *barItem = nil;
    if ( aControl ) barItem = [[UIBarButtonItem alloc] initWithCustomView:aControl];
    [[self navigationItem] setRightBarButtonItem:barItem animated:animated];
}

//--------------------------------------------------------------------------------
// aquest es cridat per el NavigationButtonController
- (void)tableFieldsControllerCancel:(SWTableFieldsController*)controller animated:(BOOL)animated
{    
    NSLog1(@"NewAccountTableController:navigationButtonControllerCancel");
    
    // Hem cancel-lat, pero no podem simplement deixar el boto de save en l'últim 
    // estat que estava perque el switch pot haver canviat
    if ( switchChanged )
        saveIsShown = YES;
    
    // ho deixem en el ultim estat que estava
    [self establishSaveButton:saveIsShown];
}

//--------------------------------------------------------------------------------
// aquest es cridat per el NavigationButtonController
- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    NSLog1(@"NewAccountTableController:navigationButtonControllerApply");
    
    saveIsShown = YES;
    [self establishSaveButton:saveIsShown];
}


- (BOOL)tableFieldsController:(SWTableFieldsController *)controller
    validateField:(id)field forCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
    outErrorString:(NSString *__autoreleasing *)errorString
{
    NSString *errMsgs = nil ;
   
    UITextField *usernameField = [usernameCell textField];
    UITextField *emailField = [emailCell textField];
    UITextField *oldPasswordField = [oldPasswordCell textField];  // serà nil si oldPasswordCell no es fa servir
    UITextField *passwordField = [passwordCell textField];
    UITextField *confirmPasswordField = [confirmPasswordCell textField];
    UITextField *priorityField = [priorityCell textField];
    
    NSString *text = [(UITextField*)field text];
    NSInteger len = text.length;
    
    NSString *oldPassText = oldPasswordField.text;
    NSString *passText = passwordField.text;
    NSString *confirmText = confirmPasswordField.text;
    
    BOOL passChanging = oldPassText.length>0 || passText.length>0 || confirmText.length>0 ;
    
    if ( field == usernameField )
    {
        if ( len < 4 )
        {
            errMsgs = NSLocalizedString(@"Username must be at least 4 characters long", nil);
        }
    }
    
    else if ( field == emailField )
    {
        NSString *pattern = @"[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})";
        //NSString *pattern2 = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSInteger count = [regex numberOfMatchesInString:text options:0 range:NSMakeRange(0, len)];
        if ( count != 1 )
        {
            errMsgs = NSLocalizedString(@"Enter a valid email address", nil);
        }
    }
    
    else if ( field == oldPasswordField )
    {
        if ( (passChanging) && len < 1 /*![text isEqualToString:[profile password]]*/ )
        {
            errMsgs = NSLocalizedString(@"Old password must be entered", nil);
        }
    }
    
    else if ( field == passwordField )
    {
        if ( (passChanging) && len < 1 )
        {
            errMsgs = NSLocalizedString(@"Password must be entered", nil);
        }
        
        else if ( len > 0 && len < 4 )
        {
            errMsgs = NSLocalizedString(@"Password must be at least 4 characters long", nil);
        }

    }
    
    else if ( field == confirmPasswordField )
    {
        if ( (passChanging) && len < 1 )
        {
            errMsgs = NSLocalizedString(@"Password must be entered", nil);
        }

        else if ( (len > 0 || passChanging) && ![text isEqualToString:passText] )
        {
            errMsgs = NSLocalizedString(@"Password confirmation failed", nil);
        }
    }
    
    else if ( field == priorityField )
    {
        if ( len < 1 )
        {
            errMsgs = NSLocalizedString(@"Access level was not entered", nil);
        }
    }
    
    *errorString = errMsgs;
    return (errMsgs == nil);   // <---- nil vol dir ok
}



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITextField *oldPasswordField = [oldPasswordCell textField];
    UITextField *passwordField = [passwordCell textField];
    UITextField *confirmPasswordField = [confirmPasswordCell textField];
    if ( textField == oldPasswordField || textField == passwordField || textField == confirmPasswordField )
    {
        [rightButton recordTextResponder:oldPasswordField];
        [rightButton recordTextResponder:passwordField];
        [rightButton recordTextResponder:confirmPasswordField];
    }

}

//-----------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ManagedTextFieldCell *responderCell = nil;
    if ( textField == [usernameCell textField] ) 
    {
        if (shouldShowPassword ) responderCell = oldPasswordCell;
        else responderCell = passwordCell;
    }
    else if ( textField == [oldPasswordCell textField] ) 
    {
        responderCell = passwordCell;
    }
    else if ( textField == [passwordCell textField]) 
    {
        responderCell = confirmPasswordCell;
    }
    else if ( textField == [confirmPasswordCell textField]) 
    {
        if ( shouldShowPriority ) responderCell = priorityCell;
    }
    
    if ( responderCell )
    {
        [[responderCell textField] becomeFirstResponder];
    	return NO;
    }
    
    return YES;
}


/*
//-----------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog1( @"NewAccountTableController: textFieldwillBeginEditing: %@", textField );
    return YES;
}
*/

/*
//-----------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog1( @"NewAccountTableController: textFieldDidBeginEditing: %@", textField );
}
*/

//------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string length] == 0 ) return YES;
    
    int maxLength;
    NSMutableCharacterSet *validSet;
    if ( textField == [priorityCell textField] ) 
    {
        validSet = [NSMutableCharacterSet decimalDigitCharacterSet ];
        maxLength = 1;
    }
    else
    {
        validSet = [NSMutableCharacterSet alphanumericCharacterSet];
        [validSet addCharactersInString:@"@_-."];
        maxLength = 20;
        if ( textField == [emailCell textField] )
        {
            maxLength = 50;
        }
    }
    
    if ( [[textField text] length] >= maxLength ) return NO;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    NSString *filtered = nil;
    [scanner scanCharactersFromSet:validSet intoString:&filtered];
    return [string isEqualToString:filtered];
}

/*
//------------------------------------------------------------------------
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
*/

/*
//-----------------------------------------------------------------------------
// Aquesta es cridada automàticament al resignar el text field com a
// first responder     
- (void)textFieldDidEndEditing:(UITextField *)textField
{ 
    NSLog1( @"NewAccountTableController: textFieldDidEndEditing:" );
}
*/





@end

