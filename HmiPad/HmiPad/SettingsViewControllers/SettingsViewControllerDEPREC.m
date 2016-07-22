//
//  SettingsViewController.m
//  iPhoneDomus
//
//  Created by Joan on 07/12/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWTableFieldsController.h"
#import "SWTableViewMessage.h"
#import "LoginWindowControllerC.h"
//#import "AccountsTableController.h"
#import "ManageAccountsController.h"
#import "EditAccountTableController.h"
//#import "StoreViewController.h"
//#import "ViewControllerHelper.h"

//#import "FilesViewController.h"
//#import "ConnectionsViewController.h"

#import "ControlViewCell.h"
//#import "IDomusAppDelegate.h" // veure si es pot prescindir
//#import "SourceElement.h"
//#import "PlcDevice.h"
#import "AppFilesModel.h"
#import "AppUsersModel.h"
#import "UserDefaults.h"
//#import "StoreManager.h"

#import "SWColor.h"


#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SettingsViewController
///////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
@interface SettingsViewController()

- (void)multitaskSwitchChanged:(UISwitch *)switchv;

@end

//------------------------------------------------------------------------
@implementation SettingsViewController



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
///////////////////////////////////////////////////////////////////////////////////////////


#define totalRestrictedSections 1

/*
#define totalFullSections 7

#if LITE
    #define totalSections (totalFullSections + 0)  // ha de ser 8 en la lite
#else
    #define totalSections totalFullSections  // ha de ser 7 en la total
#endif
*/

#if SMMOD
enum sectionsInTable
{
    kUserSection = 0,
    kUserInterfaceSection,
    kAlarmsSection,
    kCommsSection,
//    kModbusTcpSection,
//    kCommunicationSection1,
    totalSections,
    
    kInAppPurchaseSection,    // posar a sobre de total sections si es vol utilitzar
    kFinsTcpSection,          // al final de tot per evitar la seva utilitzacio
    kEipSection,              // al final de tot per evitar la seva utilitzacio
    kSiemensS7Section,        // al final de tot per evitar la seva utilitzacio
};

#else
enum sectionsInTable
{
    kUserSection = 0,
    kUserInterfaceSection,
    kAlarmsSection,
    kCommsSection,
    
//    kFinsTcpSection,
//    kModbusTcpSection,
//    kEipSection,
//    kSiemensS7Section,
//    kCommunicationSection1,
    
    totalSections,            // fins aqui !
    kInAppPurchaseSection,    // posar a sobre de total sections si es vol utilitzar
};
#endif

//#define totalRestrictedRowsInUserSection 2
//#define totalSemiRestrictedRowsInUserSection 3
//#define totalRowsInUserSection 4
enum rowsInUserSection
{
    kAutomaticLoginRow = 0,
    kCurrentAccountRow,
    kManageAccountsRow,
    kAccessLimitRow,
    kFileAccessLimitRow,
    totalRowsInUserSection,
};

//#define totalRowsInUserInterfaceSection 10
enum rowsInUserInterfaceSection
{
    kEnableDetentsRow = 0,
    kHiddenTabBarRow,
    kHiddenFilesTabBarRow,
    kAnimateVisibleChanges,
    kAnimatePageShifts,
    kDoubleColumnRow,
    //kSoundingAlarms,
    //kAlertingAlarms,
    //kKeepConnectedRow,
    //kMultitaskRow,
    totalRowsInUserInterfaceSection,
};

//#define totalRowsInAlarmsSection 10
enum rowsInAlarmsSection
{
    kAlertingAlarms = 0,
    kSoundingAlarms,
    kDisconnectAlert,
    kKeepConnectedRow,
    kMultitaskRow,
    kTickVolumeRow,
    totalRowsInAlarmsSection,
};

//#define totalRestrictedRowsInCommsSection 0
//#define totalRowsInCommsSection 1
enum rowsInCommsSection
{
    kFileServerPortRow = 0,
    totalRowsInCommsSection
};

//#define totalRowsInFinsTcpSection 2
enum rowsInFinsTcpSection
{
    kFinsTcpPortRow = 0,
    kFinsTcpAltPortRow,
    totalRowsInFinsTcpSection
};

//#define totalRowsInModbusTcpSection 2
enum rowsInModbusTcpSection
{
    kModbusTcpPortRow = 0,
    kModbusTcpAltPortRow,
    totalRowsInModbusTcpSection,
};

//#define totalRowsInEipSection 1
enum rowsInEIPSection
{
    kEipAltPortRow = 0,
    totalRowsInEipSection
};

//#define totalRowsInSiemensS7Section 1
enum rowsInSiemensS7Section
{
    kSiemensS7AltPortRow = 0,
    totalRowsInSiemensS7Section,
};

//#define totalRowsInCommunicationSection1 4
enum rowsInCommunicationSection1
{
    kHost1AddrRow = 0,
    kHost2NameRow,
    kHost2EnableSSLRow,
    kPollRateRow,
    totalRowsInCommunicationSection1
};


//#define totalRowsInInAppPurchaseSection 1
enum rowsInInAppPurchaseSection
{
    kBuyAllowancesRow = 0,
    totalRowsInInAppPurchaseSection
};




///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
///////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------------
- (void)setAccessLimitTextFieldValue:(int)value
{
    NSString *strValue = [NSString stringWithFormat:@"%d", value] ;
    [[accessLimitCell textField] setText:strValue] ;
    [accessLimitCell setNeedsLayout] ;
}

//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell *)accessLimitCell
{
    if ( accessLimitCell == nil )
    {
        id tmpObj ;
        accessLimitCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil] ;
        [accessLimitCell setTabWidth:0] ; // override textFieldCell default to 20
        [accessLimitCell setMainText:NSLocalizedString(@"Admin access level limit",nil)];
        [tmpObj=[accessLimitCell textField] setFrame:CGRectMake(0,0,70,31)];
        [tmpObj setPlaceholder:@"0-9"];
        [tmpObj setTextAlignment:UITextAlignmentRight] ;
        [tmpObj setKeyboardType:UIKeyboardTypeNumbersAndPunctuation] ;
        [tmpObj setReturnKeyType:UIReturnKeyDone];
        [self setAccessLimitTextFieldValue:[defaults() adminAccessLevel]] ;
    }
    return accessLimitCell ;
}


//---------------------------------------------------------------------------------------------------
- (void)setAccessLimitCell:(ManagedTextFieldCell *)aCell
{
    if ( accessLimitCell != aCell )
    {
//        [accessLimitCell release];
//        accessLimitCell = [aCell retain];
        accessLimitCell = aCell;
        
    }
}

//---------------------------------------------------------------------------------------------------
- (void)setFileAccessLimitTextFieldValue:(int)value
{
    NSString *strValue = [NSString stringWithFormat:@"%d", value] ;
    [[fileAccessLimitCell textField] setText:strValue] ;
    [fileAccessLimitCell setNeedsLayout] ;
}

//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell *)fileAccessLimitCell
{
    if ( fileAccessLimitCell == nil )
    {
        id tmpObj ;
        fileAccessLimitCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil] ;
        [fileAccessLimitCell setTabWidth:0] ; // override textFieldCell default to 20
        [fileAccessLimitCell setMainText:NSLocalizedString(@"User file access level limit",nil)];
        [tmpObj=[fileAccessLimitCell textField] setFrame:CGRectMake(0,0,70,31)];
        [tmpObj setPlaceholder:@"0-9"];
        [tmpObj setTextAlignment:UITextAlignmentRight] ;
        [tmpObj setKeyboardType:UIKeyboardTypeNumbersAndPunctuation] ;
        [tmpObj setReturnKeyType:UIReturnKeyDone];
        [self setFileAccessLimitTextFieldValue:[defaults() fileAccessLevel]] ;
    }
    return fileAccessLimitCell ;
}


//---------------------------------------------------------------------------------------------------
- (void)setFileAccessLimitCell:(ManagedTextFieldCell *)aCell
{
    if ( fileAccessLimitCell != aCell )
    {
//        [fileAccessLimitCell release];
//        fileAccessLimitCell = [aCell retain];
        fileAccessLimitCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (void)setManageAccountsText
{
    if ( manageAccountsCell == nil ) return ;

//    NSString *text ;
//    BOOL isAdmin = [usersModel() currentUserIsAdmin] ;
//    
//    if ( isAdmin ) text = NSLocalizedString(@"Manage accounts",nil);
//    else text = NSLocalizedString(@"Edit account",nil);
    
    NSString *text = NSLocalizedString(@"Manage accounts",nil);
    
    //[[manageAccountsCell label] setText:text];
    [manageAccountsCell setMainText:text];
}

//---------------------------------------------------------------------------------------------------
- (ControlViewCell*)manageAccountsCell
{
    if ( manageAccountsCell == nil )
    {
        manageAccountsCell = [[ControlViewCell alloc] initWithReuseIdentifier:nil];
        [manageAccountsCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [manageAccountsCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        //[[manageAccountsCell label] setText:NSLocalizedString(@"Manage accounts", nil)];
        [self setManageAccountsText] ;
    }
    return manageAccountsCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setManageAccountsCell:(ControlViewCell*)aCell
{
    if ( manageAccountsCell != aCell )
    {
//        [manageAccountsCell release];
//        manageAccountsCell = [aCell retain];
        manageAccountsCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (void)setPortCellTextFieldValue:(NSString*)strValue forCell:(ManagedTextFieldCell*__strong*)theCell
{
    [[*theCell textField] setText:strValue] ;
    [*theCell setNeedsLayout] ;
}


//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell *)portCellForCell:(ManagedTextFieldCell*__strong*)theCell
{
    if ( *theCell == nil )
    {
        *theCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil] ;
        [*theCell setTabWidth:0] ; // override textFieldCell default to 20
        UITextField *textField = [*theCell textField] ;
        [textField setFrame:CGRectMake(0,0,70,31)];
        //[textField setPlaceholder:@"port"];
        [textField setTextAlignment:UITextAlignmentRight] ;
        [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation] ;
        [textField setReturnKeyType:UIReturnKeyDone];
        NSString *labelTxt = nil ;
        NSString *portTxt = nil ;
        NSString *placeholder = nil ;
        UIReturnKeyType returnKey = UIReturnKeyDefault ;
        if ( theCell == &fileServerPortCell )
        {
            labelTxt = NSLocalizedString(@"Port",nil); 
            portTxt = [defaults() fileServerPort] ;
            placeholder = @"8080" ;
            returnKey = UIReturnKeyDone;
        }
        else if ( theCell == &finsTcpPortCell )
        {
            labelTxt = NSLocalizedString(@"Local Port",nil);    
            portTxt = [defaults() finsTcpPort] ;
            placeholder = @"9600" ;
            returnKey = UIReturnKeyNext;
        }        
        else if ( theCell == &finsTcpAltPortCell )
        {
            labelTxt = NSLocalizedString(@"Remote Port",nil);    
            portTxt = [defaults() finsTcpAltPort] ;
            placeholder = @"9600" ;
            [textField setReturnKeyType:UIReturnKeyDone];
        }
        else if ( theCell == &modbusTcpPortCell )
        {
            labelTxt = NSLocalizedString(@"Local Port",nil);    
            portTxt = [defaults() modbusTcpPort] ;
            placeholder = @"502" ;
            returnKey = UIReturnKeyNext;
        }
        else if ( theCell == &modbusTcpAltPortCell )
        {
            labelTxt = NSLocalizedString(@"Remote Port",nil);    
            portTxt = [defaults() modbusTcpAltPort] ;
            placeholder = @"502" ;
            returnKey = UIReturnKeyDone;
        }
        else if ( theCell == &eipAltPortCell )
        {
            labelTxt = NSLocalizedString(@"Remote Port",nil);    
            portTxt = [defaults() eipAltPort] ;
            placeholder = @"44818" ;
            returnKey = UIReturnKeyDone;
        }
        else if ( theCell == &siemensS7AltPortCell )
        {
            labelTxt = NSLocalizedString(@"Remote Port",nil);    
            portTxt = [defaults() siemensS7AltPort] ;
            placeholder = @"102" ;
            returnKey = UIReturnKeyDone;
        }

        //[[*theCell label] setText:labelTxt];   
        [*theCell setMainText:labelTxt];    
        [textField setPlaceholder:placeholder] ;
        [textField setReturnKeyType:returnKey];
        [self setPortCellTextFieldValue:portTxt forCell:theCell] ;
    }
    return *theCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setPortCell:(ManagedTextFieldCell *)aCell forCell:( ManagedTextFieldCell*__strong*)theCell
{
    if ( *theCell != aCell )
    {
//        [*theCell release];
//        *theCell = [aCell retain];
        *theCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell*)host1AddrViewCell
{
    if ( host1AddrViewCell == nil )
    {
        id tmpObj ;        
        host1AddrViewCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil] ;
        //[[host1AddrViewCell label] setText:NSLocalizedString(@"Address",nil)];
        [host1AddrViewCell setMainText:NSLocalizedString(@"Local",nil)];
        [tmpObj=[host1AddrViewCell textField] setPlaceholder:@"192.168.250.0"];
        [tmpObj setText:[defaults() defaultHostName]];
        [tmpObj setKeyboardType:UIKeyboardTypeNumbersAndPunctuation] ;
        [tmpObj setReturnKeyType:UIReturnKeyNext];
    }
    return host1AddrViewCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setHost1AddrViewCell:(ManagedTextFieldCell*)aCell
{
    if ( host1AddrViewCell != aCell )
    {
//        [host1AddrViewCell release];
//        host1AddrViewCell = [aCell retain];
        host1AddrViewCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell*)host2NameViewCell
{
    if ( host2NameViewCell == nil )
    {
        id tmpObj ;
        host2NameViewCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:rightButton reuseIdentifier:nil] ;
        //[[host2NameViewCell label] setText:NSLocalizedString(@"Host",nil)];
        [host2NameViewCell setMainText:NSLocalizedString(@"Remote",nil)];
        [tmpObj=[host2NameViewCell textField] setPlaceholder:@"www.remotehost.com"];
        [tmpObj setText:[defaults() alternateHostName]];
        [tmpObj setKeyboardType:UIKeyboardTypeURL] ;
        [tmpObj setReturnKeyType:UIReturnKeyDone];
    }
    return host2NameViewCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setHost2NameViewCell:(ManagedTextFieldCell*)aCell
{
    if ( host2NameViewCell != aCell )
    {
//        [host2NameViewCell release];
//        host2NameViewCell = [aCell retain];
        host2NameViewCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)host2EnableSSLCell
{
    if ( host2EnableSSLCell == nil )
    {
        id tmpObj ;
        host2EnableSSLCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        //[[host2EnableSSLCell label] setText:NSLocalizedString(@"Enable SSL", nil)];
        [host2EnableSSLCell setMainText:NSLocalizedString(@"Enable SSL", nil)];
        [tmpObj=[host2EnableSSLCell switchv] setOn:[defaults() alternateEnableSSLState]];
        [tmpObj addTarget:self action:@selector(enableSSLSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return host2EnableSSLCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setHost2EnableSSLCell:(SwitchViewCell*)aCell
{
    if ( host2EnableSSLCell != aCell )
    {
//        [host2EnableSSLCell release];
//        host2EnableSSLCell = [aCell retain];
        host2EnableSSLCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (void)updatePollRateCellImage
{
    const static int FASTOPTION = 3 ;
    UISegmentedControl *segmented = (id)[pollRateCell rightView] ;
    int pollOption = [segmented selectedSegmentIndex] ;
    UIImage *image ;
    if ( pollOption == FASTOPTION || ![defaults() deviceIsIpad] ) image = [UIImage imageNamed:@"63-runnerWhite.png"] ;
    else image = [UIImage imageNamed:@"63-runner.png"] ;
    [segmented setImage:image forSegmentAtIndex:FASTOPTION] ;
}



//---------------------------------------------------------------------------------------------------
- (ControlViewCell*)pollRateCell
{
    if ( pollRateCell == nil )
    {
        pollRateCell = [[ControlViewCell alloc] initWithReuseIdentifier:nil] ;
        NSArray *segmentedItems = [[NSArray alloc] initWithObjects:@"2s", @"1s", @"0.5s", @"0s", nil] ;
        UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems:segmentedItems] ;
//        [segmentedItems release] ;
        [segmented setFrame:CGRectMake(0,0,136,31)] ;
        [segmented setSegmentedControlStyle:UISegmentedControlStyleBar] ;
        [segmented addTarget:self action:@selector(pollRateChanged:) forControlEvents:UIControlEventValueChanged];
        int pollOption = [defaults() pollingRateOption] ;
        [segmented setSelectedSegmentIndex:pollOption] ;
        [pollRateCell setRightView:segmented] ;
        [pollRateCell setMainText:NSLocalizedString(@"Poll Rate", nil)];
        [self updatePollRateCellImage] ;
//        [segmented release] ;
    }
    return pollRateCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setPollRateCell:(ControlViewCell*)aCell
{
    if ( pollRateCell != aCell )
    {
//        [pollRateCell release];
//        pollRateCell = [aCell retain];
        pollRateCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)enablePageDetentsCell
{
    if ( enablePageDetentsCell == nil )
    {
        id tmpObj ;
        enablePageDetentsCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [enablePageDetentsCell setMainText:NSLocalizedString(@"Paging enabled", nil)]; 
        [tmpObj=[enablePageDetentsCell switchv] setOn:[defaults() enablePageDetentsState]];
        [tmpObj addTarget:self action:@selector(enablePageDetentsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return enablePageDetentsCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setEnablePageDetentsCell:(SwitchViewCell*)aCell
{
    if ( enablePageDetentsCell != aCell )
    {
//        [enablePageDetentsCell release];
//        enablePageDetentsCell = [aCell retain];
        enablePageDetentsCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)animateVisibleChangesCell
{
    if ( animateVisibleChangesCell == nil )
    {
        id tmpObj ;
        animateVisibleChangesCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [animateVisibleChangesCell setMainText:NSLocalizedString(@"Animate Visible Changes", nil)];
        [tmpObj=[animateVisibleChangesCell switchv] setOn:[defaults() animateVisibleChangesState]];
        [tmpObj addTarget:self action:@selector(animateVisibleChangesSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return animateVisibleChangesCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setAnimateVisibleChangesCell:(SwitchViewCell*)aCell
{
    if ( animateVisibleChangesCell != aCell )
    {
//        [animateVisibleChangesCell release];
//        animateVisibleChangesCell = [aCell retain];
        animateVisibleChangesCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)animatePageShiftsCell
{
    if ( animatePageShiftsCell == nil )
    {
        id tmpObj ;
        animatePageShiftsCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [animatePageShiftsCell setMainText:NSLocalizedString(@"Animate Page Shifts", nil)];
        [tmpObj=[animatePageShiftsCell switchv] setOn:[defaults() animatePageShiftsState]];
        [tmpObj addTarget:self action:@selector(animatePageShiftsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return animatePageShiftsCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setAnimatePageShiftsCell:(SwitchViewCell*)aCell
{
    if ( animatePageShiftsCell != aCell )
    {
//        [animatePageShiftsCell release];
//        animatePageShiftsCell = [aCell retain];
        animatePageShiftsCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)doubleColumnCell
{
    if ( doubleColumnCell == nil )
    {
        doubleColumnCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [doubleColumnCell setMainText:NSLocalizedString(@"Two Columns in Portrait", nil)] ;        
        //[doubleColumnCell setBottomText:NSLocalizedString(@"iPad Only", nil)] ;        
        UISwitch *switchv = [doubleColumnCell switchv] ;
        [switchv setOn:[defaults() showDoubleColumnState]];
        [switchv addTarget:self action:@selector(doubleColumnSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return doubleColumnCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setDoubleColumnCell:(SwitchViewCell*)aCell
{
    if ( doubleColumnCell != aCell )
    {
//        [doubleColumnCell release];
//        doubleColumnCell = [aCell retain];
        doubleColumnCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)hiddenTabBarCell
{
    if ( hiddenTabBarCell == nil )
    {
        id tmpObj ;
        hiddenTabBarCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [hiddenTabBarCell setMainText:NSLocalizedString(@"Show tab bar on home", nil)];
        [tmpObj=[hiddenTabBarCell switchv] setOn: ! [defaults() hiddenTabBar]];
        [tmpObj addTarget:self action:@selector(hiddenTabBarSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return hiddenTabBarCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setHiddenTabBarCell:(SwitchViewCell*)aCell
{
    if ( hiddenTabBarCell != aCell )
    {
//        [hiddenTabBarCell release];
//        hiddenTabBarCell = [aCell retain];
        hiddenTabBarCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)hiddenFilesTabBarCell
{
    if ( hiddenFilesTabBarCell == nil )
    {
        id tmpObj ;
        hiddenFilesTabBarCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [hiddenFilesTabBarCell setMainText:NSLocalizedString(@"Show tab bar on files", nil)];
        [tmpObj=[hiddenFilesTabBarCell switchv] setOn: ! [defaults() hiddenFilesTabBar]];
        [tmpObj addTarget:self action:@selector(hiddenFilesTabBarSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return hiddenFilesTabBarCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setHiddenFilesTabBarCell:(SwitchViewCell*)aCell
{
    if ( hiddenFilesTabBarCell != aCell )
    {
//        [hiddenFilesTabBarCell release];
//        hiddenFilesTabBarCell = [aCell retain];
        hiddenFilesTabBarCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)soundingAlarmsCell
{
    if ( soundingAlarmsCell == nil )
    {
        id tmpObj ;
        soundingAlarmsCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [soundingAlarmsCell setMainText:NSLocalizedString(@"Play Alarm Sound", nil)];
        [tmpObj=[soundingAlarmsCell switchv] setOn:[defaults() soundingAlarmsState]];
        [tmpObj addTarget:self action:@selector(soundingAlarmsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return soundingAlarmsCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setSoundingAlarmsCell:(SwitchViewCell*)aCell
{
    if ( soundingAlarmsCell != aCell )
    {
//        [soundingAlarmsCell release];
//        soundingAlarmsCell = [aCell retain];
        soundingAlarmsCell = aCell;
    }
}

/*
//---------------------------------------------------------------------------------------------------
- (void)setDisconnectAlertCellEnabled:(BOOL)enabled animated:(BOOL)animated
{
    UISwitch *sswitch = (id)[disconnectAlertCell rightView] ;
    [sswitch setUserInteractionEnabled:enabled] ;
    [sswitch setOn:(enabled?[defaults() disconnectAlertState]:0) animated:animated] ;
    
    void (^block)(void) = ^
    {
        [sswitch setAlpha:(enabled?1.0f:0.5f)] ;
    } ;
    
    if ( animated ) [UIView animateWithDuration:0.15 animations:block] ;
    else block() ;
}
*/

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)disconnectAlertCell
{
    if ( disconnectAlertCell == nil )
    {
        id tmpObj ;
        disconnectAlertCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [disconnectAlertCell setMainText:NSLocalizedString(@"Alarm on Disconnection", nil)];   // localitzar
        [tmpObj=[disconnectAlertCell switchv] setOn:[defaults() disconnectAlertState]];
        [tmpObj addTarget:self action:@selector(disconnectAlertSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        //[self setDisconnectAlertCellEnabled:[defaults() alertingAlarmsState] animated:NO] ;
    }
    return disconnectAlertCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setDisconnectAlertCell:(SwitchViewCell*)aCell
{
    if ( disconnectAlertCell != aCell )
    {
//        [disconnectAlertCell release];
//        disconnectAlertCell = [aCell retain];
        disconnectAlertCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)alertingAlarmsCell
{
    if ( alertingAlarmsCell == nil )
    {
        id tmpObj ;
        alertingAlarmsCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [alertingAlarmsCell setMainText:NSLocalizedString(@"Alert on Alarm", nil)];
        [tmpObj=[alertingAlarmsCell switchv] setOn:[defaults() alertingAlarmsState]];
        [tmpObj addTarget:self action:@selector(alertingAlarmsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return alertingAlarmsCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setAlertingAlarmsCell:(SwitchViewCell*)aCell
{
    if ( alertingAlarmsCell != aCell )
    {
//        [alertingAlarmsCell release];
//        alertingAlarmsCell = [aCell retain];
        alertingAlarmsCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)keepConnectedCell
{
    if ( keepConnectedCell == nil )
    {
        id tmpObj ;
        keepConnectedCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [keepConnectedCell setMainText:NSLocalizedString(@"Keep Connected", nil)];
        [tmpObj=[keepConnectedCell switchv] setOn:[defaults() keepConnectedState]];
        [tmpObj addTarget:self action:@selector(keepConnectedSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return keepConnectedCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setKeepConnectedCell:(SwitchViewCell*)aCell
{
    if ( keepConnectedCell != aCell )
    {
//        [keepConnectedCell release];
//        keepConnectedCell = [aCell retain];
        keepConnectedCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (SwitchViewCell*)multitaskCell
{
    if ( multitaskCell == nil )
    {
        multitaskCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        [multitaskCell setMainText:NSLocalizedString(@"Background Process", nil)];
        
        UISwitch *switchv = [multitaskCell switchv] ;
        [switchv setOn:[defaults() multitaskState]];
        
/*        
		BOOL backgroundSupported = NO;

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        UIDevice* device = [UIDevice currentDevice];
        if ( [device respondsToSelector:@selector(isMultitaskingSupported)] ) backgroundSupported = [device isMultitaskingSupported];
//#endif
*/
        
        BOOL backgroundSupported = [defaults() isMultitaskingSupported] ;
        
        if ( backgroundSupported )
        {
    	    [switchv addTarget:self action:@selector(multitaskSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        else
        {
            [[multitaskCell cellContentView] setMainTextColor:[UIColor lightGrayColor]] ;
        	[switchv setUserInteractionEnabled:NO] ;
            [switchv setAlpha:0.5f] ;
        }
        
    }
    return multitaskCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setMultitaskCell:(SwitchViewCell*)aCell
{
    if ( multitaskCell != aCell )
    {
//        [multitaskCell release];
//        multitaskCell = [aCell retain];
        multitaskCell = aCell;
    }
}

//---------------------------------------------------------------------------------------------------
- (void)setTickVolumeCellEnabled:(BOOL)enabled animated:(BOOL)animated
{
    UISlider *slider = (id)[tickVolumeCell rightView] ;
    [slider setUserInteractionEnabled:enabled] ;
    [slider setValue:(enabled?[defaults() tickVolume]:0) animated:animated] ;
    
    void (^block)(void) = ^
    {
        [slider setAlpha:(enabled?1.0f:0.5f)] ;
    } ;
    
    if ( animated ) [UIView animateWithDuration:0.15 animations:block] ;
    else block() ;
}

//---------------------------------------------------------------------------------------------------
- (ControlViewCell*)tickVolumeCell
{
    if ( tickVolumeCell == nil )
    {
        tickVolumeCell = [[ControlViewCell alloc] initWithReuseIdentifier:nil] ;
        /*
        NSArray *segmentedItems = [[NSArray alloc] initWithObjects:@"2s", @"1s", @"0.5s", @"0s", nil] ;
        UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems:segmentedItems] ;
        [segmentedItems release] ;
        [segmented setFrame:CGRectMake(0,0,136,31)] ;
        [segmented setSegmentedControlStyle:UISegmentedControlStyleBar] ;
        [segmented addTarget:self action:@selector(pollRateChanged:) forControlEvents:UIControlEventValueChanged];
        int pollOption = [defaults() pollingRateOption] ;
        [segmented setSelectedSegmentIndex:pollOption] ;
        */
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0,0,200,40)] ;
        //[slider setFrame:CGRectMake(0,0,40,40)] ;
        //float value = [defaults() tickVolume] ;
        //[slider setValue:value] ;
        [slider setMinimumValueImage:[UIImage imageNamed:@"SpeakerMute.png"]] ;
        [slider setMaximumValueImage:[UIImage imageNamed:@"SpeakerMax.png"]] ;
        [slider setContinuous:NO] ;
        [slider addTarget:self action:@selector(tickVolumeChanged:) forControlEvents:UIControlEventValueChanged] ;
        
        [tickVolumeCell setRightView:slider] ;
        [tickVolumeCell setMainText:NSLocalizedString(@"Tick", nil)];           // localitzar
        //[tickVolumeCell setBottomText:@"Volume"] ;
//        [slider release] ;
        
        [self setTickVolumeCellEnabled:[defaults() multitaskState] animated:NO] ;
    }
    return tickVolumeCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setTickVolumeCell:(ControlViewCell*)aCell
{
    if ( tickVolumeCell != aCell )
    {
//        [tickVolumeCell release];
//        tickVolumeCell = [aCell retain];
        tickVolumeCell = aCell;
    }
}


//---------------------------------------------------------------------------------------------------
- (ControlViewCell*)buyAllowancesCell
{
    if ( buyAllowancesCell == nil )
    {
        buyAllowancesCell = [[ControlViewCell alloc] initWithReuseIdentifier:nil] ;
        [buyAllowancesCell setSelectionStyle:UITableViewCellSelectionStyleBlue]; 
        //[buyAllowancesCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator]; 
        ControlViewCellContentView *cellContentView = [buyAllowancesCell cellContentView] ;
        [cellContentView setMainTextFont:[UIFont boldSystemFontOfSize:15]] ;
        [cellContentView setMainTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
        [cellContentView setCenteredMainText:YES] ;
        [buyAllowancesCell setMainText:NSLocalizedString(@"Go to Store",nil)];               // localitzar
    }
    return buyAllowancesCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setBuyAllowancesCell:(ControlViewCell*)aCell
{
    if ( buyAllowancesCell != aCell )
    {
//        [buyAllowancesCell release];
//        buyAllowancesCell = [aCell retain];
        buyAllowancesCell = aCell;
    }
}



//---------------------------------------------------------------------------------------------------
- (LoginWindowControllerC *)loginWindow
{
    if ( loginWindow == nil )
    {
        loginWindow = [[LoginWindowControllerC alloc] init] ;
        [loginWindow setDelegate:self];
    }
    return loginWindow;
}

//---------------------------------------------------------------------------------------------------
- (void)setLoginWindow:(LoginWindowControllerC*)newValue
{
    if ( loginWindow != newValue )
    {
//        [loginWindow release];
//        loginWindow = [newValue retain];
        loginWindow = newValue;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Convenience Methods
///////////////////////////////////////////////////////////////////////////////////////////



/*
//-----------------------------------------------------------------------------
- (void)delayedRowsInsert:(NSArray*)indexPaths
{
    UITableView *tableView = [self tableView] ;
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    // workaround per el bug que no mostra la linea de separacio entre les celdes
    [tableView setEditing:YES animated:NO];
    [tableView setEditing:NO animated:NO];
}
*/
/*
//-----------------------------------------------------------------------------
- (void)delayedRowsDelete:(NSArray*)indexPaths
{
    UITableView *tableView = [self tableView] ;
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}
*/
//-----------------------------------------------------------------------------
- (void)establishUserSettingsFooter
{
    NSString *message ; ;
    if ( [usersModel() currentUserIsIntegrator] )
    {
        message = NSLocalizedString( @"UserSectionMessage", nil) ;
    }
    else
    {
        #if OEM
            message = [NSString stringWithFormat:@"%@\n\n%@", @ OEMAddress, NSLocalizedString(@"Powered by ScadaMobile" ,nil)] ;   // localitzar
        #else
            message = NSLocalizedString(@"LogToManageFiles" ,nil) ;
        #endif
    }
    [messageView setMessage:message] ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageView
{
    if ( messageView == nil )
    {
//        UITableView *table = [self tableView] ;
        messageView = [[SWTableViewMessage alloc] initForSectionFooter] ;

#if OEM
        [[messageView messageViewLabel] setTextAlignment:UITextAlignmentCenter] ;
#endif

        [self establishUserSettingsFooter] ;
    }
    return messageView ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mViewUserInterface
{
    if ( mViewUserInterface == nil )
    {
//        UITableView *table = [self tableView] ;
        mViewUserInterface = [[SWTableViewMessage alloc] initForSectionFooter] ;
        [mViewUserInterface setMessage:NSLocalizedString( @"UserInterfaceSectionMessage", nil)] ;  // localitzar
    }
    return mViewUserInterface ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mViewAlarms
{
    if ( mViewAlarms == nil )
    {
        //UITableView *table = [self tableView] ;
        mViewAlarms = [[SWTableViewMessage alloc] initForSectionFooter]  ;
        [mViewAlarms setMessage:NSLocalizedString( @"AlarmsSectionMessage", nil)] ;  // localitzar
    }
    return mViewAlarms ;
}


//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mViewWebServer
{
    if ( mViewWebServer == nil )
    {
        //UITableView *table = [self tableView] ;
        mViewWebServer = [[SWTableViewMessage alloc] initForSectionFooter]  ;
        [mViewWebServer setMessage:NSLocalizedString( @"CommsSectionMessage", nil)] ;  // localitzar
    }
    return mViewWebServer ;
}


//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)mViewDefaults
{
    if ( mViewDefaults == nil )
    {
        //UITableView *table = [self tableView] ;
        mViewDefaults = [[SWTableViewMessage alloc] initForSectionFooter]  ;
        [mViewDefaults setMessage:NSLocalizedString( @"DefaultSectionsMessage", nil)] ;  // localitzar
    }
    return mViewDefaults ;
}



//---------------------------------------------------------------------------------------------
- (UIView *)versionView
{
    if ( versionView == nil )
    {
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0,60,20)] ;
        [versionLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor) ];
        [versionLabel setBackgroundColor:[UIColor clearColor]];
        [versionLabel setFont:[UIFont italicSystemFontOfSize:13.0f]] ;
        [versionLabel setText:@ SWVersionText ] ;
        
        [[self tableView] setTableFooterView:versionLabel] ;
        versionView = versionLabel ;
    }
    return versionView ;
}


//-----------------------------------------------------------------------------
- (NSInteger)actualSectionForSection:(NSUInteger)section outSectionCount:(NSUInteger*)outCount
{
    NSInteger offset = 0 ;
    NSInteger count = 0 ;
    BOOL isAdmin = [usersModel() currentUserIsIntegrator] ;
    //BOOL isNobody = [[defaults() currentUser] isEqualToString:@"nobody"] ;
    BOOL isNobody = NO;
   
    count = totalSections ;
    if ( !isAdmin && (count-=1) && section >= kUserInterfaceSection ) offset++ ;   // user interface no hi es per no admin
    if ( isNobody && (count-=1) && section+offset >= kAlarmsSection ) offset++ ;  // alarms section no hi es per nobody
    if ( !isAdmin && (count-=(totalSections-kCommsSection)) && section+offset >= kCommsSection ) offset+=(1+section-kCommsSection) ;    
    
    if ( outCount ) *outCount = count ;
    return section+offset ;
}




//-----------------------------------------------------------------------------
- (NSInteger)actualRowForRow:(NSInteger)row section:(NSUInteger)section outRowCount:(NSUInteger*)outCount
{
    BOOL isIpad = [defaults() deviceIsIpad] ;
    BOOL noDColumCell = !isIpad || ![defaults() iosIs5] ;
    
    BOOL isAdmin = [usersModel() currentUserIsIntegrator] ;
    //BOOL isNobody = [[defaults() currentUser] isEqualToString:@"nobody"] ;
    BOOL isNobody = NO;
    
    section = [self actualSectionForSection:section outSectionCount:NULL] ;
    
    NSInteger offset = 0;
    NSInteger count = 0;
    switch ( section )
    {
        case kUserSection:
            count = totalRowsInUserSection ;
            if ( isNobody && (count-=1) && row >= kManageAccountsRow ) offset++ ;  // manage account no hi es per nobody
            if ( !isAdmin && (count-=1) && row+offset >= kAccessLimitRow ) offset++ ;  // accessLimit no hi es per no admin
            if ( !isAdmin && (count-=1) && row+offset >= kFileAccessLimitRow ) offset++ ;  // fileAccess limit no hi es per no admin
            break ;
                
        case kUserInterfaceSection:
            count = totalRowsInUserInterfaceSection ;
            if ( isIpad && (count-=1) && row >= kHiddenTabBarRow ) offset++ ;
            if ( noDColumCell && (count-=1) && row+offset >= kDoubleColumnRow ) offset++ ;
            break ;
            
        case kAlarmsSection:
            count = totalRowsInAlarmsSection ;
            break ;
        
        case kCommsSection:
            count = totalRowsInCommsSection ;
            break ;
            
//        case kFinsTcpSection:
//            count = totalRowsInFinsTcpSection ;
//            break ;
//
//        case kModbusTcpSection:
//            count = totalRowsInModbusTcpSection ;
//            break ;
//            
//        case kEipSection:
//            count = totalRowsInEipSection ;
//            break ;
//            
//        case kSiemensS7Section:
//            count = totalRowsInSiemensS7Section ;
//            break ;
//            
//        case kCommunicationSection1:
//            count = totalRowsInCommunicationSection1 ;
//            break ;
            
        case kInAppPurchaseSection:
            count = totalRowsInInAppPurchaseSection ;
            break ;

        default:
            break ;
    }
    if ( outCount ) *outCount = count ;
    return row + offset ;
}


//-----------------------------------------------------------------------------
- (void)establishCurrentUserId:(UInt32)newUser oldUserId:(UInt32)oldUser
{
    // si no hi ha canvi d'usuari, no fem res
    //NSString *oldUser = [defaults() currentUser] ;
    if ( oldUser == newUser ) return ;
    
    // seran YES en cas de que el vell o nou usuari mostrin la fila de 'Manage accounts' o 'Edit account'
//    BOOL oldState = ! [oldUser isEqualToString:@"nobody"];  // hauria de ser per nivell access
//    BOOL newState = ! [newUser isEqualToString:@"nobody"];
    BOOL oldState = YES;
    BOOL newState = YES;
    
    // seran YES en cas de que el vell o nou usuari mostrin les seccions de 'Comms'
    BOOL oldState2 = [usersModel() userIdIsIntegrator:oldUser];
    BOOL newState2 = [usersModel() userIdIsIntegrator:newUser];
    
    // si hi ha algun textField editant-se, cancel-la la edició. 
    // (Soluciona a lo bruto el bug del teclat que desapareix al insertar una fila)
    if ( [rightButton isStarted] )
    {
        [rightButton stopWithCancel:YES animated:YES]; // no accepta els canvis 
    }
 
    // actualitzem el Model
    //[defaults() setCurrentUser:newUser] ; // model (defaults)
    
    // actualitzem els Views
    // posa el nom a la celda de currentAccount
    NSString *userName = [usersModel() userNameForUserId:newUser];
    [[currentAccountCell secondLabel] setText:userName];

    // si cal posa el texte adequat a la celda de manageAccounts
    if ( manageAccountsCell != nil && newState ) [self setManageAccountsText] ;
    
    // si no s'han d'afegir o treure files o seccions ja hem acabat
    if ( oldState == newState && oldState2 == newState2 ) return ;
    
    // en cas contrari preparem els arrays amb les insercions o borrats en batch que necesitem fer
    NSMutableArray *insertRowsArray = [[NSMutableArray alloc] initWithCapacity:1] ;
    NSMutableArray *deleteRowsArray = [[NSMutableArray alloc] initWithCapacity:1] ;
    NSMutableIndexSet *insertSecsSet = [[NSMutableIndexSet alloc] init] ;
    NSMutableIndexSet *deleteSecsSet = [[NSMutableIndexSet alloc] init] ;
    
    // si hem de actuar sobre la fila de 'manage account'
    if ( oldState != newState )
    {
        // creem l'array de indexpaths amb la fila a modificar
        NSIndexPath *manageAccountsIndexPath = [NSIndexPath indexPathForRow:kManageAccountsRow inSection:kUserSection] ;
        //NSIndexPath *enablePageDetentsIndexPath = [NSIndexPath indexPathForRow:kEnableDetentsRow inSection:kMiscellaneousSection] ;
        //NSIndexPath *hiddenTabBarIndexPath = [NSIndexPath indexPathForRow:kHiddenTabBarRow inSection:kMiscellaneousSection] ;
    
        // afegim o eliminem la fila de manage account i access limit  
        if ( oldState == NO && newState == YES )
        {
            [insertRowsArray addObject:manageAccountsIndexPath] ;
        }
    
        if ( oldState == YES && newState == NO )
        {        
            [deleteRowsArray addObject:manageAccountsIndexPath] ; 
            [self setManageAccountsCell:nil];
        }
    }
    
    
    // si hem d'actuar sobre les seccions de 'Comms', 'kCommunicationSection1', i 'kSecuritySection'
    if ( oldState2 != newState2 )
    {
        // establim el footer adequat segons l'usuari
        //dispose( messageView ) ;
        [self establishUserSettingsFooter] ;
        
        // actualitzem els indexsets amb les seccions a modificar
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:kAccessLimitRow inSection:kUserSection] ;
        NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:kFileAccessLimitRow inSection:kUserSection];
    
        // entrem en usuari administrador ( la insercio es refereix a lo que hi haura, es a dir el conjunt complert )
        if ( oldState2 == NO && newState2 == YES )
        {
            [insertRowsArray addObject:indexPath2] ;  
            [insertRowsArray addObject:indexPath3] ;
            [insertSecsSet addIndex:kUserInterfaceSection] ;
            [insertSecsSet addIndex:kCommsSection] ;
            
//            [insertSecsSet addIndex:kModbusTcpSection] ;
//            [insertSecsSet addIndex:kCommunicationSection1] ;
#if !SMMOD
//            [insertSecsSet addIndex:kFinsTcpSection] ;
//            [insertSecsSet addIndex:kEipSection] ;
//            [insertSecsSet addIndex:kSiemensS7Section] ;
#endif


            
#if LITE && totalSections > totalFullSections
            [insertSecsSet addIndex:kInAppPurchaseSection] ;
#endif
        }
        
        
    
        // entrem en usuari no administrador ( el delete es refereix a lo que hi ha es a dir el conjust complert )
        if ( oldState2 == YES && newState2 == NO )
        {
            [deleteRowsArray addObject:indexPath2] ;
            [deleteRowsArray addObject:indexPath3];
            [self setAccessLimitCell:nil] ;
            [self setFileAccessLimitCell:nil];
            
            [deleteSecsSet addIndex:kUserInterfaceSection] ;
            [self setEnablePageDetentsCell:nil] ;
            [self setHiddenTabBarCell:nil] ;
            [self setHiddenFilesTabBarCell:nil] ;
            [self setAnimateVisibleChangesCell:nil] ;
            [self setDoubleColumnCell:nil] ;
            [self setAnimatePageShiftsCell:nil] ;
            
            [deleteSecsSet addIndex:kCommsSection] ;  
            [self setPortCell:nil forCell:&fileServerPortCell];
            

//            [deleteSecsSet addIndex:kModbusTcpSection] ;  
//            [self setPortCell:nil forCell:&modbusTcpPortCell];
//            [self setPortCell:nil forCell:&modbusTcpAltPortCell];
            
#if !SMMOD
//            [deleteSecsSet addIndex:kFinsTcpSection] ;  
//            [self setPortCell:nil forCell:&finsTcpPortCell]; 
//            [self setPortCell:nil forCell:&finsTcpAltPortCell];
            
//            [deleteSecsSet addIndex:kEipSection] ;
//            [self setPortCell:nil forCell:&eipAltPortCell] ;
            
//            [deleteSecsSet addIndex:kSiemensS7Section] ;
//            [self setPortCell:nil forCell:&siemensS7AltPortCell] ;
#endif

//            [deleteSecsSet addIndex:kCommunicationSection1] ;
//            [self setHost1AddrViewCell:nil] ;
//            [self setHost2NameViewCell:nil] ;
//            [self setHost2EnableSSLCell:nil] ;
//            [self setPollRateCell:nil] ;
            
            
#if LITE && totalSections > totalFullSections
            [deleteSecsSet addIndex:kInAppPurchaseSection] ;
            [self setBuyAllowancesCell:nil] ;
#endif
        }
    }
    
    if ( oldState == YES && newState == NO )
    {
        int indx = kAlarmsSection ;
        if ( !oldState2 ) indx-=1 ;
        [deleteSecsSet addIndex:indx] ;
        [self setSoundingAlarmsCell:nil] ;
        [self setDisconnectAlertCell:nil] ;
        [self setAlertingAlarmsCell:nil] ;
        [self setKeepConnectedCell:nil] ;
        [self setMultitaskCell:nil] ;
        [self setTickVolumeCell:nil] ;
    }
    
    if ( oldState == NO && newState == YES )
    {
        int indx = kAlarmsSection ;
        if ( !newState2 ) indx-=1 ;
        [insertSecsSet addIndex:indx] ;
    }
    //jlz   
    // finalment insertem o eliminem les celdes
    UITableView *tableView = [self tableView] ;
    [tableView setTableFooterView:nil] ; // workaround al freze bug amb "CoreAnimation: ignoring exception: CALayer position contains NaN"
    
    [tableView beginUpdates] ;
    if ( [deleteRowsArray count] > 0 ) [tableView deleteRowsAtIndexPaths:deleteRowsArray withRowAnimation:UITableViewRowAnimationFade];
    if ( [deleteSecsSet count] > 0 ) [tableView deleteSections:deleteSecsSet withRowAnimation:UITableViewRowAnimationFade] ;
    if ( [insertSecsSet count] > 0 ) [tableView insertSections:insertSecsSet withRowAnimation:UITableViewRowAnimationFade] ;
    if ( [insertRowsArray count] > 0 ) [tableView insertRowsAtIndexPaths:insertRowsArray withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates] ;
    
    [tableView setTableFooterView:[self versionView]] ; // workaround al freze bug amb "CoreAnimation: ignoring exception: CALayer position contains NaN"
    
    //[tableView reloadData] ;
    
    // workaround per el bug que no mostra la linea de separacio entre les celdes
    if ( [insertRowsArray count] > 0 )
    {
        //[tableView setEditing:YES animated:NO];
        //[tableView setEditing:NO animated:NO];
    }
    
    // alliberem els arrays i indexSets
//    [insertRowsArray release] ;
//    [deleteRowsArray release] ;
//    [insertSecsSet release] ;
//    [deleteSecsSet release] ;
}


//---------------------------------------------------------------------------------------------------
- (void)maybeReloadData
{    
    if ( dataNeedsReload )
    {
        UILabel *secondLabel = [currentAccountCell secondLabel] ;
        [secondLabel setText:[usersModel() currentUserName]];
        //dispose( messageView ) ;
        [self establishUserSettingsFooter] ;
        [[self tableView] reloadData] ;
        dataNeedsReload = NO ;
    } 
} 




///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Controller Methods
///////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (id)init
{
    NSLog1( @"SettingsViewController: init") ;
    
    // APPROACH 1 : inicialització a partir de un nib
   // return [super initWithNibName:@"SettingsViewController" bundle:nil];
    
    // APPROACH 2 : inicialització programatica
    self = [super initWithStyle:UITableViewStyleGrouped] ;
    
    if ( self )
    {
        [self setTitle:NSLocalizedString(@"Settings",nil)] ;
        //[[self tabBarItem] setImage:[UIImage imageNamed:@"20-gear-2.png"]] ;   // big
        //[[self tabBarItem] setImage:[UIImage imageNamed:@"14-gear.png"]] ;     // small
    }
    return self ;
}


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


//----------------------------------------------------------------------------------------
- (void)disposeProperties
{
    NSLog1( @"SettingsViewController: disposeProperties") ;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self] ;
    
    [rightButton stopWithCancel:YES animated:NO] ;
//    dispose( rightButton ) ;
//    dispose( messageView ) ;
//    dispose( mViewUserInterface ) ;
//    dispose( mViewAlarms ) ;
//    dispose( mViewWebServer ) ;
//    dispose( mViewDefaults ) ;
//    dispose( versionView ) ;
//    
//    dispose( automaticLoginCell ) ;
//    dispose( currentAccountCell ) ;
//    dispose( manageAccountsCell ) ;
//    dispose( accessLimitCell ) ;
//    dispose( fileAccessLimitCell );
//    
//    dispose( fileServerPortCell ) ;
//    
//    dispose( finsTcpPortCell ) ;
//    dispose( finsTcpAltPortCell ) ;
//    
//    dispose( modbusTcpPortCell ) ;
//    dispose( modbusTcpAltPortCell ) ;
//    
//    dispose( eipAltPortCell ) ;
//    dispose( siemensS7AltPortCell ) ;
//
//    dispose( host1AddrViewCell ) ;
//    dispose( host2NameViewCell ) ;
//    dispose( host2EnableSSLCell ) ;
//    dispose( pollRateCell ) ;
//    
//    dispose( enablePageDetentsCell ) ;
//    dispose( hiddenTabBarCell ) ;
//    dispose( hiddenFilesTabBarCell ) ;
//    dispose( animateVisibleChangesCell ) ;
//    dispose( doubleColumnCell ) ;
//    dispose( animateVisibleChangesCell ) ;
//
//    dispose( soundingAlarmsCell ) ;
//    dispose( disconnectAlertCell ) ;
//    dispose( alertingAlarmsCell ) ;
//    dispose( keepConnectedCell ) ;
//    dispose( multitaskCell ) ;
//    dispose( tickVolumeCell ) ;
//    
//    dispose( buyAllowancesCell ) ;
// 

}

//----------------------------------------------------------------------------------------
- (void)dealloc 
{
    NSLog1( @"SettingsViewController: dealloc") ;
    [self disposeProperties] ;
//    [loginWindow release] ;
//    [super dealloc];
}


//----------------------------------------------------------------------------------------
- (void)loadView 
{
    NSLog1( @"SettingsViewController: loadView") ;
    [super loadView] ;
    
}


//----------------------------------------------------------------------------------------
- (void)viewDidLoad 
{

    NSLog1( @"SettingsViewController: viewDidLoad") ;
    [super viewDidLoad];

//    [self setDeviceBasedTintColor] ;
    
    dataNeedsReload = NO ;
    viewAppeared = NO ;
    
    id tmpObj ;
    
        rightButton = [[SWTableFieldsController alloc] initWithOwner:self]; //navigationItem:[self navigationItem]];
        
        automaticLoginCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
        //[[automaticLoginCell label] setText:NSLocalizedString(@"Automatic login", nil)];
        [automaticLoginCell setMainText:NSLocalizedString(@"Automatic login", nil)];
        [tmpObj=[automaticLoginCell switchv] setOn:[usersModel() automaticLogin]];  // agafa de preferences
        [tmpObj addTarget:self action:@selector(autoLoginSwitchChanged:) forControlEvents:UIControlEventValueChanged];

        currentAccountCell = [[LabelViewCell alloc] initWithReuseIdentifier:nil] ;
        [currentAccountCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        //[[currentAccountCell label] setText:NSLocalizedString(@"Current account", nil)];
        [currentAccountCell setMainText:NSLocalizedString(@"Current account", nil)];
        UILabel *secondLabel = [currentAccountCell secondLabel] ;
        [secondLabel setText:[usersModel() currentUserName]];
        [secondLabel setFont:[UIFont boldSystemFontOfSize:17] ] ;

        /*UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0,60,20)] ;
        [versionLabel setTextColor:[ControlViewCell theDarkerSystemDarkBlueColor]] ;
        [versionLabel setBackgroundColor:[UIColor clearColor]];
        [versionLabel setFont:[UIFont italicSystemFontOfSize:13.0f]] ;
        [versionLabel setText:@ SWVersionText ] ;
        
        [[self tableView] setTableFooterView:versionLabel] ;
        [versionLabel release] ;
        */
        
        [[self tableView] setTableFooterView:[self versionView]] ;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
       
    //[[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(currentUserDidChangedNotification:) name:kCurrentUserDidChangeNotification object:nil] ;
    //[[self tableView] setDelaysContentTouches:NO];

}

//----------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    NSLog1( @"SettinsViewController: viewDidUnload") ;
    [super viewDidUnload] ;
    [self disposeProperties] ;
} 

//----------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated 
{
    NSLog1( @"SettinsViewController: viewWillAppear") ;
    //[appDelegate() setSettingsPending:YES] ;
    //[self getHostAddrTextsFromModel] ;
    //[self getHostNameFromModel] ;
    
    // actualitzar dades del model o preferències
    
    [super viewWillAppear:animated];
    
    [self maybeReloadData] ;
    
    viewAppeared = YES ;
    
   // NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
   // [nc addObserver:self selector:@selector(userSettingsChangedNotification:) name:kUserSettingsChangedNotification object:nil] ;
}




//----------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated 
{
    NSLog1( @"SettinsViewController: viewDidAppear") ;
    [super viewDidAppear:animated];
    
    //viewAppeared = YES ;
}


//----------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated 
{
    NSLog1( @"SettinsViewController: viewWillDisAppear") ;
    viewAppeared = NO ;
    //[[NSNotificationCenter defaultCenter] removeObserver:self] ;

    [rightButton stopWithCancel:YES animated:NO]; // no accepta els canvis 
	[super viewWillDisappear:animated];
}


//----------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated 
{
    NSLog1( @"SettinsViewController: viewDidDisappear") ;
	[super viewDidDisappear:animated];
    
   // [appDelegate() setSettingsPending:NO] ;   //malu
}




//----------------------------------------------------------------------------------------
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    NSLog1( @"SettinsViewController: shouldAutorotateToInterfaceOrientation") ;
    
    return YES;
}


//----------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning 
{

    NSLog1( @"SettinsViewController didReceiveMemoryWarning" ) ;
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
    //NSLog1(@"SettingsWiewController: Memory Warning") ;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Notificacio de canvi de user settings
///////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
- (void)currentUserDidChangedNotification:(NSNotification *)notification
{ 
    dataNeedsReload = YES ;
    if ( viewAppeared )
    {
        NSDictionary *userInfo = [notification userInfo] ;
        UInt32 previousUserId = [[userInfo objectForKey:@"PreviousUser"] integerValue] ;
        UInt32 currentUserId = [[userInfo objectForKey:@"CurrentUser"] integerValue] ;
        [self establishCurrentUserId:currentUserId oldUserId:previousUserId] ;
    }
}


#pragma mark AppUsersModelObserver

- (void)appUsersModelAutoLoginDidChange:(AppUsersModel*)usersModel
{
    BOOL state = [usersModel automaticLogin];
    [automaticLoginCell.switchv setOn:state animated:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TextField Delegates and NavigationButtonController callbacks
///////////////////////////////////////////////////////////////////////////////////////////



//--------------------------------------------------------------------------------
- (void)commitChangesInSourceElementsWithMainChanged:(BOOL)mainChanged altChanged:(BOOL)altChanged
{
//    // mira quines son les conexións per defecte i si han canviat els parametres prova de reconectar 
//    // això s'ha de fer per els sourceElements rellevants
//    if ( [defaults() monitoringState] && (mainChanged || altChanged) ) 
//    {
//        // iterem per tots els sources i resetejem els que agafen el plcDevice per defecte 
//        for ( SourceElement *sourceElement in [model() sourceElements] )
//        {
//            PlcDevice *device = [sourceElement plcDevice] ;
//            if ( device->isDefault && [sourceElement plcObjectIgnited] )
//            {
//                BOOL altHostIsFirst = [model() altIsFirstForPlcDevice:device] ;
//                if ( (altChanged && altHostIsFirst) || (mainChanged && !altHostIsFirst) || ([sourceElement plcObjectLinked] == NO) )
//                {
//                    [sourceElement closeCommunicationObject];
//                    [sourceElement ignitePlcCommsObject] ;
//                }
//            }
//        }
//    }
}


//----------------------------------------------------------------------------------
- (void)tableFieldsController:(SWTableFieldsController*)controller
			didProvideControl:(UIControl*)aControl animated:(BOOL)animated
{
	UIBarButtonItem *barItem = nil ;
    if ( aControl ) barItem = [[UIBarButtonItem alloc] initWithCustomView:aControl];
    [[self navigationItem] setRightBarButtonItem:barItem animated:animated];
//    [barItem release] ;
}

//--------------------------------------------------------------------------------
// aquest es cridat per el NavigationButtonController
- (void)tableFieldsControllerCancel:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    //[self getHostAddrTextsFromModel];
}

//--------------------------------------------------------------------------------
// aquest es cridat per el NavigationButtonController
- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    NSArray *textFields = [controller textResponders] ;
    BOOL mainChanged = NO ;
    BOOL altChanged = NO ;
    BOOL validationChanged = NO ;
    for ( UITextField *textField in textFields )
    {

        NSString *text = [textField text] ;
        
//        UInt16 defaultProtocol = kProtocolTypeNone ; //[defaults() defaultProtocol] ;
//        BOOL fins = YES || defaultProtocol==kProtocolTypeOmronFins ;   // BUG atencio s'ha de fer alguna cosa amb això
//        BOOL modbus = YES || defaultProtocol==kProtocolTypeModbus ;
//        BOOL eip = YES || defaultProtocol==kProtocolTypeEIP || defaultProtocol==kProtocolTypeEIP_PCCC ;
//        BOOL siemens = YES || defaultProtocol==kProtocolTypeSiemensISO_TCP ;
        
        if ( textField == [fileServerPortCell textField] )
        {
            [defaults() setFileServerPort:text] ;
        }
//        else if ( textField == [finsTcpPortCell textField] )
//        {
//            mainChanged = (fins) ;
//            [defaults() setFinsTcpPort:text] ;
//        }
//        else if ( textField == [finsTcpAltPortCell textField]  )
//        {
//            altChanged = (fins) ;
//            [defaults() setFinsTcpAltPort:text] ;
//        }
//        else if ( textField == [modbusTcpPortCell textField] )
//        {
//            mainChanged = (modbus) ;
//            [defaults() setModbusTcpPort:text] ;
//        }
//        else if ( textField == [modbusTcpAltPortCell textField] )
//        {
//            altChanged = (modbus) ;
//            [defaults() setModbusTcpAltPort:text] ;
//        }
//        else if ( textField == [eipAltPortCell textField] )
//        {
//            altChanged = (eip) ;
//            [defaults() setEipAltPort:text] ;
//        }
//        else if ( textField == [siemensS7AltPortCell textField] )
//        {
//            altChanged = (siemens) ;
//            [defaults() setSiemensS7AltPort:text] ;
//        }
//        else if ( textField == [host1AddrViewCell textField] ) 
//        {
//            mainChanged = YES ;
//            [defaults() setDefaultHostName:text] ;
//        }
//        else if ( textField == [host2NameViewCell textField] )
//        {
//            altChanged = YES ;
//            [defaults() setAlternateHostName:text] ;
//        }
        else if ( textField == [accessLimitCell textField] )
        {
            unsigned int intValue = [text intValue] ;
            [defaults() setAdminAccessLevel:intValue] ;
            [self setAccessLimitTextFieldValue:intValue] ;
        }
        else if ( textField == [fileAccessLimitCell textField])
        {
            unsigned int intValue = [text intValue] ;
            [defaults() setFileAccessLevel:intValue] ;
            [self setFileAccessLimitTextFieldValue:intValue] ;
        }
    }
    
    // mira quina es la conexió actual i si han canviat els parametres prova de reconectar // ATENCIO ha de mirar el canvi de port segons protocol
    [self commitChangesInSourceElementsWithMainChanged:mainChanged||validationChanged altChanged:altChanged||validationChanged] ;
}


//-----------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ManagedTextFieldCell *responderCell = nil ;
    if ( textField == [finsTcpPortCell textField] )
    {
    	responderCell = finsTcpAltPortCell ;
    }
    
    else if ( textField == [modbusTcpPortCell textField] )
    {
    	responderCell = modbusTcpAltPortCell ;
    }
    
    else if ( textField == [host1AddrViewCell textField] )
    {
    	responderCell = host2NameViewCell ;
    }
    
    if ( responderCell )
    {
        [[responderCell textField] becomeFirstResponder] ;
       /* UITableView *table = [self tableView] ;
    	NSIndexPath *indexPath = [table indexPathForCell:responderCell] ;
        [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES] ; */
    	return NO ;
    }

    return YES ;
}
   
/*
//-----------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog1( @"SettingsViewController: textFieldwillBeginEditing: %@", textField ) ;
    return YES ;
}
*/
/*
//------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog1( @"SettingsViewController: textFieldDidBeginEditing: %@", textField ) ;
    theCurrentTextField = textField ;
    //[[self rightButton] establish:YES animated:YES] ;
    [[self rightButton] startAnimated:YES];
}
*/

//------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog1( @"SettingsViewController: ReplacementText: %@", string ) ;
    /*
    BOOL port = (textField == [host1PortViewCell textField] || textField == [host2PortViewCell textField] ) ;
    BOOL hostAddr = (textField == [host1AddrViewCell textField]) ;  
    BOOL hostName = (textField == [host2NameViewCell textField]) ;*/
    
    BOOL accessLimit = (textField == [accessLimitCell textField]);
    BOOL fileAccessLimit = (textField == [fileAccessLimitCell textField]);
    BOOL hostAddr = (textField == [host1AddrViewCell textField]) ;  
    BOOL hostName = (textField == [host2NameViewCell textField]) ;
    BOOL port = (textField == [fileServerPortCell textField] || 
                textField == [finsTcpPortCell textField] || 
                textField == [finsTcpAltPortCell textField] || 
                textField == [modbusTcpPortCell textField] || 
                textField == [modbusTcpAltPortCell textField] || 
                textField == [eipAltPortCell textField] ||
                textField == [siemensS7AltPortCell textField] ) ;
    
    BOOL plcSecureArea = NO ; // No esborrar, Guardar per futura referencia (textField == [plcSecureMemoryAreaCell textField]) ;
    BOOL plcValidationCode = NO ; // (textField == [plcValidationCodeCell textField]) ;
    
    BOOL plcCode = (plcValidationCode || !( port || hostAddr || hostName || /*accessLimit ||*/ plcSecureArea )) ;
        
    if ( [string length] == 0 ) return YES ;
    int textFieldLen = [[textField text] length] ;
    
    if ( textFieldLen >= (port?5:0)+(hostAddr?100:0)+(hostName?100:0)+(accessLimit?1:0)+
                                       +(plcSecureArea?6:0)+(plcCode?4:0) ) return NO ;
    
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ; 
    
    NSString *validStringSet ;
    if ( hostAddr || hostName) validStringSet = @"0123456789=@&%?,=_:-+./abcdefghijklmnopqrstuvwxyz";
    else if ( plcCode ) validStringSet = @"0123456789abcdefABCDEF";
    else if ( port || accessLimit || fileAccessLimit || (plcSecureArea && textFieldLen > 0 ) ) validStringSet = @"0123456789";
    else if ( plcSecureArea && textFieldLen == 0 ) validStringSet = @"0123456789dDwWhH";
    else NSAssert( NO, @"No puc trobar el conjunt de caracters valid per el textField" ) ; 
                
    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:validStringSet] ;
    NSScanner *scanner = [NSScanner scannerWithString:string] ;
    NSString *filtered = nil ;
    [scanner scanCharactersFromSet:validSet intoString:&filtered] ;
    
    BOOL result = [string isEqualToString:filtered] ;
//    [pool release] ;

    return result;
}

//------------------------------------------------------------------------
// resignFirstResponder en un textField, crida aquesta
//

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog1( @"SettingsViewController: TextFieldShouldEndEditing"  );

    // comprovar la validesa del hostName o hostAddress
    //BOOL host = (textField == [host1AddrViewCell textField] || textField == [host2NameViewCell textField] ) ;   
     
    // comprovar la validesa del port
    BOOL port = (textField == [fileServerPortCell textField] || 
                textField == [finsTcpPortCell textField] || 
                textField == [finsTcpAltPortCell textField] || 
                textField == [modbusTcpPortCell textField] || 
                textField == [modbusTcpAltPortCell textField] || 
                textField == [eipAltPortCell textField] ||
                textField == [siemensS7AltPortCell textField] );
                
    //BOOL plcCode = (textField == [plcValidationCodeCell textField] || !(host || port) ) ;
    
    NSString *str = nil ;
    if ( port )
    {
        int intValue = [[textField text] intValue] ;
        if ( intValue > 65535 ) intValue = 65535 ;
        str = [NSString stringWithFormat:@"%d", intValue] ;
    }
    
    /*
    if ( plcCode )
    {
        str = [[textField text] uppercaseString] ;
        int numLeadingZeros = 4-[str length] ;
        if ( numLeadingZeros > 0 )
        {
            NSString *formatStr = [[NSString alloc] initWithFormat:@"%%0%dd%%@", numLeadingZeros] ;  // donara algo com '%03d%@'
            str = [NSString stringWithFormat:formatStr, 0, str] ;
            [formatStr release] ;
        }
    }
    */
    
    if ( str != nil )
    {
        [textField setText:str] ;
    }
    
    return YES ;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Action Methods
///////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------
- (void)autoLoginSwitchChanged:(UISwitch *)switchv
{
    BOOL newAutoLoginState = [switchv isOn] ;
    
    NSLog1( @"Autologin: %d", newAutoLoginState) ;
    BOOL done = [usersModel() setAutomaticLogin:newAutoLoginState error:nil];
    
    if ( !done )
    {
        [switchv setOn:[usersModel() automaticLogin] animated:YES];
    }    
}


//------------------------------------------------------------------------ 
- (void)enableSSLSwitchChanged:(UISwitch *)switchv
{
    BOOL newEnableState = [switchv isOn] ;
    if ( [defaults() alternateEnableSSLState] == newEnableState ) return ;
    
    [defaults() setAlternateEnableSSLState:newEnableState] ;      // tindra efecte a la propera conexió (revisar això)
    [self commitChangesInSourceElementsWithMainChanged:NO altChanged:YES] ;
}

//------------------------------------------------------------------------ 
- (void)pollRateChanged:(UIControl *)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender ;
    int newRateOption = [segmentedControl selectedSegmentIndex] ;
    if ( [defaults() pollingRateOption] == newRateOption ) return ;
    
    [self updatePollRateCellImage] ;
    [defaults() setPollingRateOption:newRateOption] ;
    
}


//------------------------------------------------------------------------ 
- (void)enablePageDetentsSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() enablePageDetentsState] == newState ) return ;
    
    [defaults() setEnablePageDetentsState:newState] ;
}

//------------------------------------------------------------------------ 
- (void)hiddenTabBarSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = ! [switchv isOn] ;
    if ( [defaults() hiddenTabBar] == newState ) return ;
    
    [defaults() setHiddenTabBar:newState] ;
}

//------------------------------------------------------------------------ 
- (void)hiddenFilesTabBarSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = ! [switchv isOn] ;
    if ( [defaults() hiddenFilesTabBar] == newState ) return ;
    
    [defaults() setHiddenFilesTabBar:newState] ;
}


//------------------------------------------------------------------------ 
- (void)animateVisibleChangesSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() animateVisibleChangesState] == newState ) return ;
    
    [defaults() setAnimateVisibleChangesState:newState] ;
}

//------------------------------------------------------------------------ 
- (void)animatePageShiftsSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() animatePageShiftsState] == newState ) return ;
    
    [defaults() setAnimatePageShiftsState:newState] ;
}

//------------------------------------------------------------------------ 
- (void)doubleColumnSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() showDoubleColumnState] == newState ) return ;
    
    [defaults() setShowDoubleColumnState:newState] ;
}


//------------------------------------------------------------------------ 
- (void)alertingAlarmsSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() alertingAlarmsState] == newState ) return ;
    
    [defaults() setAlertingAlarmsState:newState] ;
    
    //[self setDisconnectAlertCellEnabled:newState animated:YES] ;
    if ( !newState )
    {
        [defaults() setSoundingAlarmsState:NO] ;   
    	UISwitch *aSwitch = [soundingAlarmsCell switchv] ;
    	[aSwitch setOn:NO animated:YES] ;
    }
}

//------------------------------------------------------------------------ 
- (void)soundingAlarmsSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() soundingAlarmsState] == newState ) return ;
    
    [defaults() setSoundingAlarmsState:newState] ;
    if ( newState )
    {
        [defaults() setAlertingAlarmsState:YES] ;
        UISwitch *aSwitch = [alertingAlarmsCell switchv] ;
    	[aSwitch setOn:YES animated:YES] ;
        //[self setDisconnectAlertCellEnabled:YES animated:YES] ;
    }
}

//------------------------------------------------------------------------ 
- (void)disconnectAlertSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() disconnectAlertState] == newState ) return ;
    
    [defaults() setDisconnectAlertState:newState] ;
    /*if ( newState )
    {
        UISwitch *aSwitch = [alertingAlarmsCell switchv] ;
    	[aSwitch setOn:newState animated:YES] ;
        [defaults() setAlertingAlarmsState:newState] ;
    }
    */
}


//------------------------------------------------------------------------ 
- (void)keepConnectedSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() keepConnectedState] == newState ) return ;
    
    [defaults() setKeepConnectedState:newState] ;
    
    if ( !newState )
    {
        [defaults() setMultitaskState:NO] ;
    	UISwitch *aSwitch = [multitaskCell switchv] ;
    	[aSwitch setOn:NO animated:YES] ;
        [self setTickVolumeCellEnabled:NO animated:YES] ;
    }
}

//------------------------------------------------------------------------ 
- (void)multitaskSwitchChanged:(UISwitch *)switchv
{
    BOOL newState = [switchv isOn] ;
    if ( [defaults() multitaskState] == newState ) return ;
    
    [defaults() setMultitaskState:newState] ;
    
    [self setTickVolumeCellEnabled:newState animated:YES] ;
    if ( newState )
    {
        [defaults() setKeepConnectedState:YES] ;
    	UISwitch *aSwitch = [keepConnectedCell switchv] ;
    	[aSwitch setOn:YES animated:YES] ;
    }
}


//------------------------------------------------------------------------ 
- (void)tickVolumeChanged:(UIControl *)sender
{
    UISlider *slider = (UISlider *)sender ;
    CGFloat newValue = [slider value] ;
    if ( [defaults() tickVolume] == newValue ) return ;
    [defaults() setTickVolume:newValue] ;
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(playBackgroundTick)] ;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Data Source de la tabla
///////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    //NSInteger number = totalRestrictedSections ;
    //if ( [model() currentUserIsAdmin] ) number = totalSections ;
    //return number ;
    
    NSUInteger number ;
    [self actualSectionForSection:0 outSectionCount:&number] ;
    return number ;
}


//---------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    /*
    NSInteger number ;
    
    switch ( section )
    {
        case kUserSection:
            //number = totalRestrictedRowsInUserSection ;
            //if ( [model() currentUserIsAdmin] ) number = totalRowsInUserSection ;
            //else if ( ! [[defaults() currentUser] isEqualToString:@"nobody"] ) number = totalSemiRestrictedRowsInUserSection; 
            number = totalRowsInUserSection ;
            break ;
                
        case kUserInterfaceSection:
            number = totalRowsInUserInterfaceSection ;
            break ;
            
        case kAlarmsSection:
            number = totalRowsInAlarmsSection ;
            break ;
        
        case kCommsSection:
            //number = totalRestrictedRowsInCommsSection ;
            //if ( [model() currentUserIsAdmin] ) number = totalRowsInCommsSection;
            number = totalRowsInCommsSection ;
            break ;
            
            
        case kFinsTcpSection:
            number = totalRowsInFinsTcpSection ;
            break ;

        case kModbusTcpSection:
            number = totalRowsInModbusTcpSection ;
            break ;
            
        case kEipSection:
            number = totalRowsInEipSection ;
            break ;
            
        case kSiemensS7Section:
            number = totalRowsInSiemensS7Section ;
            break ;
            
        case kCommunicationSection1:
            number = totalRowsInCommunicationSection1 ;
            break ;
            
        case kInAppPurchaseSection:
            number = totalRowsInInAppPurchaseSection ;
            break ;

        default:
            number = 0 ;
            break ;
    }
    
    NSInteger offset = [self rowOffsetForRow:number section:section] ;
    return number-offset ;
    */
    
    NSUInteger number ;
    [self actualRowForRow:0 section:section outRowCount:&number] ;
    return number ;
}

//---------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *str ;
    section = [self actualSectionForSection:section outSectionCount:NULL] ;
    switch ( section )
    {
    
        case kUserSection:
            str = NSLocalizedString( @"User Settings", nil ) ;
            break ;
                    
        case kUserInterfaceSection:
            str =  NSLocalizedString( @"User Interface", nil ) ;
            break ;
            
        case kAlarmsSection:
            str = NSLocalizedString( @"Alarms and Background Task", nil ) ;    // localitzar
            break ;
            
        case kCommsSection:
            str = NSLocalizedString( @"Embedded Web Server", nil ) ; 
            break ;
            
//        case kFinsTcpSection:
//            str = NSLocalizedString( @"Omron FINS/TCP defaults", nil ) ;           
//            break ;
//
//        case kModbusTcpSection:
//            str = NSLocalizedString( @"Modbus/TCP defaults", nil ) ;
//            break ;
//            
//        case kEipSection:
//            str = NSLocalizedString( @"Ethernet/IP defaults", nil ) ;
//            break ;
//            
//        case kSiemensS7Section:
//            str = NSLocalizedString( @"Siemens/ISO_TCP defaults", nil ) ;
//            break ;
//
//        case kCommunicationSection1:
//            str =  NSLocalizedString( @"Default Connection", nil ) ;
//            break ;
            
        case kInAppPurchaseSection:
            str =  NSLocalizedString( @"Tag Allowances Store", nil ) ;   // localitzar
            break ;
            
        default:
            str = nil ;
            break ;
    }

    return str ;
}



//---------------------------------------------------------------------------------------------------
// Customize the appearance of table view cells.
//---------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    UITableViewCell *theCell = nil ;
    NSString* identifier = nil ; 
    
    /*
    // ajusta la fila per el offset per realment crear la celda adequada
    NSInteger offset = [self rowOffsetForRow:row section:section] ;
    row = row + offset ;
    
    // ajusta la seccio per el offset per realment crear la celda adequada
    NSInteger soffset = [self sectionOffsetForSection:section] ;
    section = section + soffset ;
    */
    
    row = [self actualRowForRow:row section:section outRowCount:NULL] ;
    section = [self actualSectionForSection:section outSectionCount:NULL] ;
    
    // determina la celda adecuada per aquest indexPath. El tipus de celda que es necesita es pot
    // identificar per "theCell" segons si ja ha estat creada previament per exemple en IB, o bé
    // mitjançant "identifier". Les dues a l'hora son incompatibles. Les celdes previament creades 
    // no son reusables i per tant nomès poden apareixer una vegada a la taula.
    // 
    switch ( section )
    {
        case kUserSection:
            if ( row == kAutomaticLoginRow ) theCell = automaticLoginCell;
            else if ( row == kCurrentAccountRow ) theCell = currentAccountCell;
            else if ( row == kManageAccountsRow ) theCell = [self manageAccountsCell];
            else if ( row == kAccessLimitRow) theCell = [self accessLimitCell];
            else if ( row == kFileAccessLimitRow) theCell = [self fileAccessLimitCell];
            break;
                
        case kUserInterfaceSection:
            if ( row == kEnableDetentsRow ) theCell = [self enablePageDetentsCell];
            else if ( row == kHiddenTabBarRow ) theCell = [self hiddenTabBarCell] ;
            else if ( row == kHiddenFilesTabBarRow ) theCell = [self hiddenFilesTabBarCell] ;
            //else if ( row == kKeepConnectedRow ) theCell = [self keepConnectedCell];
            //else if ( row == kMultitaskRow ) theCell = [self multitaskCell];
            else if ( row == kAnimateVisibleChanges ) theCell = [self animateVisibleChangesCell] ;
            else if ( row == kAnimatePageShifts ) theCell = [self animatePageShiftsCell] ;
            else if ( row == kDoubleColumnRow ) theCell = [self doubleColumnCell] ;
            //else if ( row == kSoundingAlarms ) theCell = [self soundingAlarmsCell] ;
            //else if ( row == kAlertingAlarms ) theCell = [self alertingAlarmsCell] ;
            break;
            
        case kAlarmsSection:
            if ( row == kSoundingAlarms ) theCell = [self soundingAlarmsCell] ;
            else if ( row == kAlertingAlarms ) theCell = [self alertingAlarmsCell] ;
            else if ( row == kDisconnectAlert ) theCell = [self disconnectAlertCell] ;
            else if ( row == kKeepConnectedRow ) theCell = [self keepConnectedCell];
            else if ( row == kMultitaskRow ) theCell = [self multitaskCell];
            else if ( row == kTickVolumeRow ) theCell = [self tickVolumeCell] ;
            break ;
        
        case kCommsSection:
            if ( row == kFileServerPortRow ) theCell = [self portCellForCell:&fileServerPortCell] ;// theCell = [self fileServerPortCell] ; 
            break;
            
//        case kFinsTcpSection:
//            if ( row == kFinsTcpPortRow ) theCell = [self portCellForCell:&finsTcpPortCell] ;
//            else if ( row == kFinsTcpAltPortRow ) theCell = [self portCellForCell:&finsTcpAltPortCell] ;
//            break ;
//        
//        case kModbusTcpSection:
//            if ( row == kModbusTcpPortRow ) theCell = [self portCellForCell:&modbusTcpPortCell] ;
//            else if ( row == kModbusTcpAltPortRow ) theCell = [self portCellForCell:&modbusTcpAltPortCell] ;
//            break ;
//        
//        case kEipSection:
//            if ( row == kEipAltPortRow ) theCell = [self portCellForCell:&eipAltPortCell] ;
//            break ;
//            
//        case kSiemensS7Section:
//            if ( row == kSiemensS7AltPortRow ) theCell = [self portCellForCell:&siemensS7AltPortCell] ;
//            break ;
//            
//        case kCommunicationSection1 :
//            //if ( row == kHost1PortRow ) theCell = [self host1PortViewCell];
//            if ( row == kHost1AddrRow ) theCell = [self host1AddrViewCell];
//            else if ( row == kHost2NameRow ) theCell = [self host2NameViewCell];
//            else if ( row == kHost2EnableSSLRow ) theCell = [self host2EnableSSLCell];
//            else if ( row == kPollRateRow ) theCell = [self pollRateCell] ;
//            break;
            
        case kInAppPurchaseSection:
            if ( row == kBuyAllowancesRow ) theCell = [self buyAllowancesCell];
            break ;

        default:
            identifier = CellIdentifier ;
            break;
    }
       
    // si està identificada per theCell, la torna directament.
    if ( theCell != nil ) return theCell ;
   
    NSAssert( identifier != nil, @"Cell identifier can not be nil!") ;
   // en cas contrari executa el procediment habitual
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier] ;
       
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [[cell textLabel] setText:@"standard cell"] ;
    }
           
    //[cell setNeedsLayout] ;
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Metodes Delegats de la tabla
///////////////////////////////////////////////////////////////////////////////////////////

/*
//---------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    CGFloat height = 44 ;
    switch ( section )
    {
        case kMonitorSection:
            break;
    
        case kCommunicationSection:
            //if ( row == kRemoteHostAddrRow ) height = 80 ;
            //else if ( row == kRemoteHostNameRow ) height = 80 ;
            break ;
       
        case kUserSection:
            break ;
        
        case kFilesSection:
            break ;
            
        default:
            break ;
    }
    return height ;
}
*/


//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    section = [self actualSectionForSection:section outSectionCount:NULL] ;
    CGFloat result = 0 ;
    if ( section == kUserSection ) result = [[self messageView] getMessageHeight] ;
    else if ( section == kUserInterfaceSection ) result = [[self mViewUserInterface] getMessageHeight] ;
    else if ( section == kAlarmsSection ) result = [[self mViewAlarms] getMessageHeight] ;
    else if ( section == kCommsSection ) result = [[self mViewWebServer] getMessageHeight] ;
//    else if ( section == kCommunicationSection1 ) result = [[self mViewDefaults] getMessageHeight] ;
    return result;
}

//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    section = [self actualSectionForSection:section outSectionCount:NULL] ;
    UIView *result = nil ;
    if ( section == kUserSection ) result = [self messageView] ;
    else if ( section == kUserInterfaceSection ) result = [self mViewUserInterface] ;
    else if ( section == kAlarmsSection ) result = [self mViewAlarms] ;
    else if ( section == kCommsSection ) result = [self mViewWebServer] ;
//    else if ( section == kCommunicationSection1 ) result = [self mViewDefaults] ;
    return result ;
}



//---------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSLog1( @"SettingsViewController: didSelectRowAtIndexPath %@", indexPath ) ;
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    row = [self actualRowForRow:row section:section outRowCount:NULL] ;
    section = [self actualSectionForSection:section outSectionCount:NULL] ;
    
    UINavigationController *navController = [self navigationController] ;
    
    
    if ( section == kInAppPurchaseSection && row == kBuyAllowancesRow )
    {
//        StoreViewController *storeController = [[StoreViewController alloc] init] ;
//        [navController pushViewController:storeController animated:YES]; // el pop el farà el navigation controller
//        [storeController release];
        return ;
    }
    
    
    // per defecte les celdes derivades de controlViewCell no mostren cap estat de selecció
    // pero n'hi ha algunes que si
    if ( section == kUserSection && row == kCurrentAccountRow )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        LoginWindowControllerC *loginWin = [self loginWindow];
        [loginWin setCurrentAccount:[usersModel() currentUserName]];
        [loginWin showAnimated:YES] ;
//        [loginWin setModalPresentationStyle:UIModalPresentationFullScreen];
//        [self presentViewController:loginWin animated:YES completion:nil];
        return ;
    }
        
//    NSString *user = [defaults() currentUser];
//    BOOL isAdmin = [usersModel() userIsAdmin:user] ;
    
    if ( section == kUserSection && row == kManageAccountsRow )
    {
//        if ( isAdmin )
//        {
//            AccountsTableController *accountsTable = [[AccountsTableController alloc] init] ;
//            [navController pushViewController:accountsTable animated:YES]; // el pop el farà el navigation controller
//        }
//        else
//        {
//            EditAccountTableController *editAccountTable = [[EditAccountTableController alloc] 
//                initWithUsername:user 
//                flags:(kShouldShowOldPassword)] ;
//            [navController pushViewController:editAccountTable animated:YES];
//        }

        ManageAccountsController *accountsTable = [[ManageAccountsController alloc] init] ;
        [navController pushViewController:accountsTable animated:YES]; // el pop el farà el navigation controller

        return ;
    }
}

    
    
///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Metodes Delegats del EditAccountTableController
///////////////////////////////////////////////////////////////////////////////////////////

////---------------------------------------------------------------------------------------------
//- (void)topViewControllerDidCancel:(UITableViewController*)sender    
//{    
//    [[self navigationController] popViewControllerAnimated:YES];
//}

////---------------------------------------------------------------------------------------------
//- (void)topViewControllerDidSave:(UITableViewController*)sender
//{
//
////    NSError *outError = nil ;
////    [usersModel() saveProfilesToDiskOutError:&outError] ;
//    
//    //[[self tableView] reloadData];
//    [[self navigationController] popViewControllerAnimated:YES];
//}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Metodes Delegats del LoginWindowController
///////////////////////////////////////////////////////////////////////////////////////////

////---------------------------------------------------------------------------------------------------
//- (void)loginWindowWillOpen:(LoginWindowController*)loginWin
//{
//    [loginWin setCurrentAccount:[defaults() currentUser]];
//}


////---------------------------------------------------------------------------------------------------
//- (BOOL)loginWindowWillClose:(LoginWindowController*)loginWin canceled:(BOOL)userCanceled userChanged:(BOOL)userChanged
//{
//
//    NSLog1( @"SettingsViewController: loginWindowWillClose from loginWindow") ;
//    if ( userCanceled ) return YES ;
//
//    NSString *username = [loginWin username] ;
//    UserProfile *profile = [usersModel() getProfileCopyForUser:username] ;
//    
//    BOOL didPass = YES ;
//    if ( didPass ) didPass = [profile enabled] ;
//    if ( didPass ) didPass = [[loginWin password] isEqualToString:[profile password]] ;
//        
//    return didPass ;
//}

////---------------------------------------------------------------------------------------------------
//- (void)loginWindowDidClose:(LoginWindowController*)sender canceled:(BOOL)userCanceled userChanged:(BOOL)userChanged
//{
//    NSLog1( @"SettingsViewController: loginWindowDidClose from loginWindow windows" ) ;
//    
//    if ( userCanceled == NO && userChanged )
//    {
//        NSString *username = [sender username] ;
//        [defaults() setCurrentUser:username] ;
////        [self establishCurrentUser:username];
//    }
//    [self setLoginWindow:nil];
//    
//}


//---------------------------------------------------------------------------------------------------
- (void)loginWindowDidClose:(LoginWindowControllerC*)sender
{
//    [loginWindow dismissViewControllerAnimated:YES completion:^
//    {
//        [self setLoginWindow:nil];
//    }];
    
    [self setLoginWindow:nil];
}


@end

