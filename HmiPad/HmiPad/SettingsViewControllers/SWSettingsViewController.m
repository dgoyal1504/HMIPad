//
//  SettingsViewController.m
//  iPhoneDomus
//
//  Created by Joan on 07/12/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import "SWSettingsViewController.h"
#import "SWTableFieldsController.h"
#import "SWTableViewMessage.h"
//#import "LoginWindowControllerC.h"
#import "UIViewController+SWSendMailControllerPresenter.h"
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
//#import "AppFilesModelCategories.h"
#import "AppModel.h"
#import "AppModelActivationCodes.h"
#import "AppModelImage.h"
#import "AppUsersModel.h"
#import "UserDefaults.h"
//#import "StoreManager.h"

#import "SWBlockAlertView.h"
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
@interface SWSettingsViewController()

- (void)multitaskSwitchChanged:(UISwitch *)switchv;

@end

//------------------------------------------------------------------------
@implementation SWSettingsViewController



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

#if HMiPadDev
enum sectionsInTable
{
    kAlarmsSection,
    kMaintenanceSection,
    //kMigrateToICLoudSection,
    kCommsSection,
    kFeedbackSection,
    totalSections,
    
        kUserSection,
        kUserInterfaceSection,
        kMigrateToICLoudSection,
};

#elif HMiPadRun
enum sectionsInTable
{
    kAlarmsSection,
    kMaintenanceSection,
    //kMigrateToICLoudSection,   // fer-ho automatic per HMI View
    kCommsSection,
    totalSections,            // fins aqui !
    
        kUserSection,
        kFeedbackSection,
        kUserInterfaceSection,
        kMigrateToICLoudSection,
};
#endif

enum rowsInUserSection
{
    kAccessLimitRow = 0,
    kFileAccessLimitRow,
    totalRowsInUserSection,
};

enum rowsInUserInterfaceSection
{
    kEnableDetentsRow,
    kHiddenTabBarRow,
    kHiddenFilesTabBarRow,
    kAnimateVisibleChanges,
    kAnimatePageShifts,
    kDoubleColumnRow,
    totalRowsInUserInterfaceSection,
};



#if HMiPadDev
enum rowsInAlarmsSection
{
    kDisconnectAlert,
    kKeepConnectedRow,
    totalRowsInAlarmsSection,
    
        kMultitaskRow,
        kTickVolumeRow,
        kAlertingAlarms,
        kSoundingAlarms,
};


#elif HMiPadRun
enum rowsInAlarmsSection
{
    kDisconnectAlert,
    kKeepConnectedRow,
    kMultitaskRow,
    kTickVolumeRow,
    totalRowsInAlarmsSection,
    
        kAlertingAlarms,
        kSoundingAlarms,
};
#endif

enum rowsInCommsSection
{
    kFileServerPortRow,
    totalRowsInCommsSection
};

#if HMiPadDev
enum rowsInMaintenanceSection
{
    kClearImageCache,
    kClearReceiptsCache,
    totalRowsInMaintenanceSection
};

#elif HMiPadRun
enum rowsInMaintenanceSection
{
    kClearImageCache,
    totalRowsInMaintenanceSection,
        kClearReceiptsCache,
};
#endif


enum rowsInMigrateToICLoudSection
{
    kMigrateToIcloudRow,
    totalRowsInMigrateToICLoudSection
};

enum rowsInFeedbackSection
{
    kLoveApp,
    kReviewApp,
    totalRowsInFeedbackSection
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
        [tmpObj setTextAlignment:NSTextAlignmentRight] ;
        [tmpObj setKeyboardType:UIKeyboardTypeNumbersAndPunctuation] ;
        [tmpObj setReturnKeyType:UIReturnKeyDone];
//        [self setAccessLimitTextFieldValue:[defaults() adminAccessLevel]] ;
        [self setAccessLimitTextFieldValue:[usersModel() adminAccessLevel]] ;
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
        [tmpObj setTextAlignment:NSTextAlignmentRight] ;
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
        [textField setTextAlignment:NSTextAlignmentRight] ;
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
//        else if ( theCell == &finsTcpPortCell )
//        {
//            labelTxt = NSLocalizedString(@"Local Port",nil);    
//            portTxt = [defaults() finsTcpPort] ;
//            placeholder = @"9600" ;
//            returnKey = UIReturnKeyNext;
//        }        
//        else if ( theCell == &finsTcpAltPortCell )
//        {
//            labelTxt = NSLocalizedString(@"Remote Port",nil);    
//            portTxt = [defaults() finsTcpAltPort] ;
//            placeholder = @"9600" ;
//            [textField setReturnKeyType:UIReturnKeyDone];
//        }
//        else if ( theCell == &modbusTcpPortCell )
//        {
//            labelTxt = NSLocalizedString(@"Local Port",nil);    
//            portTxt = [defaults() modbusTcpPort] ;
//            placeholder = @"502" ;
//            returnKey = UIReturnKeyNext;
//        }
//        else if ( theCell == &modbusTcpAltPortCell )
//        {
//            labelTxt = NSLocalizedString(@"Remote Port",nil);    
//            portTxt = [defaults() modbusTcpAltPort] ;
//            placeholder = @"502" ;
//            returnKey = UIReturnKeyDone;
//        }
//        else if ( theCell == &eipAltPortCell )
//        {
//            labelTxt = NSLocalizedString(@"Remote Port",nil);    
//            portTxt = [defaults() eipAltPort] ;
//            placeholder = @"44818" ;
//            returnKey = UIReturnKeyDone;
//        }
//        else if ( theCell == &siemensS7AltPortCell )
//        {
//            labelTxt = NSLocalizedString(@"Remote Port",nil);    
//            portTxt = [defaults() siemensS7AltPort] ;
//            placeholder = @"102" ;
//            returnKey = UIReturnKeyDone;
//        }

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



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Convenience Methods
///////////////////////////////////////////////////////////////////////////////////////////



//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageView
{
    if ( messageView == nil )
    {
        messageView = [[SWTableViewMessage alloc] initForSectionFooter] ;
        NSString* message = NSLocalizedString( @"UserSectionMessage", nil) ;
        [messageView setMessage:message] ;
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


- (SWTableViewMessage *)mViewMaintenance
{
    if ( mViewMaintenance == nil )
    {
        mViewMaintenance = [[SWTableViewMessage alloc] initForSectionFooter]  ;
        [mViewMaintenance setMessage:NSLocalizedString( @"MaintenanceSectionMessage", nil)] ;  // localitzar
    }
    return mViewMaintenance ;
}

- (SWTableViewMessage *)mViewMigrate
{
    if ( mViewMigrate == nil )
    {
        mViewMigrate = [[SWTableViewMessage alloc] initForSectionFooter]  ;
        [mViewMigrate setMessage:NSLocalizedString( @"MigrateSectionMessage", nil)] ;  // localitzar
    }
    return mViewMigrate ;
}


- (SWTableViewMessage *)mViewFeedback
{
    if ( mViewFeedback == nil )
    {
        mViewFeedback = [[SWTableViewMessage alloc] initForSectionFooter]  ;
        [mViewFeedback setMessage:NSLocalizedString( @"FeedbackSectionMessage", nil)] ;  // localitzar
    }
    return mViewFeedback ;
}


////---------------------------------------------------------------------------------------------------
//- (void)maybeReloadData
//{    
//    if ( dataNeedsReload )
//    {
//        UILabel *secondLabel = [currentAccountCell secondLabel] ;
//        [secondLabel setText:[usersModel() currentUserName]];
//        //dispose( messageView ) ;
//        [self establishUserSettingsFooter] ;
//        [[self tableView] reloadData] ;
//        dataNeedsReload = NO ;
//    } 
//} 




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
    [nc removeObserver:self];
    
    [rightButton stopWithCancel:YES animated:NO];
}

//----------------------------------------------------------------------------------------
- (void)dealloc 
{
    NSLog1( @"SettingsViewController: dealloc") ;
    [self disposeProperties];
}


//----------------------------------------------------------------------------------------
- (void)loadView 
{
    NSLog1( @"SettingsViewController: loadView") ;
    [super loadView];
}


//----------------------------------------------------------------------------------------
- (void)viewDidLoad 
{

    NSLog1( @"SettingsViewController: viewDidLoad") ;
    [super viewDidLoad];
    
    rightButton = [[SWTableFieldsController alloc] initWithOwner:self];

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
    // actualitzar dades del model o preferències
    
    [super viewWillAppear:animated];
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
    //[[NSNotificationCenter defaultCenter] removeObserver:self] ;

    [rightButton stopWithCancel:YES animated:NO]; // no accepta els canvis 
	[super viewWillDisappear:animated];
}


//----------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated 
{
    NSLog1( @"SettinsViewController: viewDidDisappear") ;
	[super viewDidDisappear:animated];
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

////-----------------------------------------------------------------------------
//- (void)currentUserDidChangedNotification:(NSNotification *)notification
//{ 
//
//}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TextField Delegates and NavigationButtonController callbacks
///////////////////////////////////////////////////////////////////////////////////////////


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

    for ( UITextField *textField in textFields )
    {
        NSString *text = [textField text] ;
        
        if ( textField == [fileServerPortCell textField] )
        {
            [defaults() setFileServerPort:text] ;
        }
        else if ( textField == [accessLimitCell textField] )
        {
            unsigned int intValue = [text intValue] ;
            //[defaults() setAdminAccessLevel:intValue] ;
            [usersModel() setAdminAccessLevel:intValue] ;
            [self setAccessLimitTextFieldValue:intValue] ;
        }
        else if ( textField == [fileAccessLimitCell textField])
        {
            unsigned int intValue = [text intValue] ;
            [defaults() setFileAccessLevel:intValue] ;
            [self setFileAccessLimitTextFieldValue:intValue] ;
        }
    }
}


//-----------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
    
    BOOL port = (textField == [fileServerPortCell textField]) ;
    
    BOOL plcSecureArea = NO ; // No esborrar, Guardar per futura referencia (textField == [plcSecureMemoryAreaCell textField]) ;
    //BOOL plcValidationCode = NO ; // (textField == [plcValidationCodeCell textField]) ;
        
    if ( [string length] == 0 ) return YES ;
    int textFieldLen = [[textField text] length] ;
    
    if ( textFieldLen >= (port?5:0)+(accessLimit?1:0)+(plcSecureArea?6:0) ) return NO ;
    
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ; 
    
    NSString *validStringSet ;
//    if ( hostAddr || hostName) validStringSet = @"0123456789=@&%?,=_:-+./abcdefghijklmnopqrstuvwxyz";
//    else if ( plcCode ) validStringSet = @"0123456789abcdefABCDEF";
//    else
    if ( port || accessLimit || fileAccessLimit || (plcSecureArea && textFieldLen > 0 ) ) validStringSet = @"0123456789";
    else if ( plcSecureArea && textFieldLen == 0 ) validStringSet = @"0123456789dDwWhH";
    else NSAssert( NO, @"No puc trobar el conjunt de caracters valid per el textField" ) ; 
                
    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:validStringSet] ;
    NSScanner *scanner = [NSScanner scannerWithString:string] ;
    NSString *filtered = nil ;
    [scanner scanCharactersFromSet:validSet intoString:&filtered] ;
    
    BOOL result = [string isEqualToString:filtered] ;

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
    BOOL port = (textField == [fileServerPortCell textField] );
                
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


////------------------------------------------------------------------------ 
//- (void)pollRateChanged:(UIControl *)sender
//{
//    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender ;
//    int newRateOption = [segmentedControl selectedSegmentIndex] ;
//    if ( [defaults() pollingRateOption] == newRateOption ) return ;
//    
//    [self updatePollRateCellImage] ;
//    [defaults() setPollingRateOption:newRateOption] ;
//    
//}


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
    float newValue = [slider value] ;
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
    
    NSUInteger number = totalSections;
    return number ;
}


//---------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSUInteger count = 0 ;
    switch ( section )
    {
        case kUserSection:
            count = totalRowsInUserSection ;
            break ;
                
        case kUserInterfaceSection:
            count = totalRowsInUserInterfaceSection ;
            break ;
            
        case kAlarmsSection:
            count = totalRowsInAlarmsSection ;
            break ;
        
        case kCommsSection:
            count = totalRowsInCommsSection ;
            break ;
            
        case kMaintenanceSection:
            count = totalRowsInMaintenanceSection;
            break;
            
        case kMigrateToICLoudSection:
            count = totalRowsInMigrateToICLoudSection;
            break;
            
        case kFeedbackSection:
            count = totalRowsInMaintenanceSection;
            break;
    }

    return count ;
}

//---------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *str ;
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
            
        case kMaintenanceSection:
            str = NSLocalizedString( @"Maintenance", nil ) ;
            break ;
            
        case kMigrateToICLoudSection:
            str = NSLocalizedString( @"Migrate to iCloud", nil );
            break;
            
        case kFeedbackSection:
            str = NSLocalizedString( @"Give Feedback", nil ) ;
            break ;
        
            
        default:
            str = nil ;
            break ;
    }

    return str ;
}


static NSString *CellIdentifier = @"Cell";
static NSString *ButtonLikeCellIdentifier = @"ButtonLikeCell";

//---------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    UITableViewCell *theCell = nil ;
    NSString* identifier = nil ; 
    
    switch ( section )
    {
        case kUserSection:
            if ( row == kAccessLimitRow) theCell = [self accessLimitCell];
            else if ( row == kFileAccessLimitRow) theCell = [self fileAccessLimitCell];
            break;
                
        case kUserInterfaceSection:
            if ( row == kEnableDetentsRow ) theCell = [self enablePageDetentsCell];
            else if ( row == kHiddenTabBarRow ) theCell = [self hiddenTabBarCell] ;
            else if ( row == kHiddenFilesTabBarRow ) theCell = [self hiddenFilesTabBarCell] ;
            else if ( row == kAnimateVisibleChanges ) theCell = [self animateVisibleChangesCell] ;
            else if ( row == kAnimatePageShifts ) theCell = [self animatePageShiftsCell] ;
            else if ( row == kDoubleColumnRow ) theCell = [self doubleColumnCell] ;
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
            
        case kMaintenanceSection:
            identifier = ButtonLikeCellIdentifier;
            break;
            
        case kMigrateToICLoudSection:
            identifier = ButtonLikeCellIdentifier;
            break;
            
        case kFeedbackSection:
            identifier = ButtonLikeCellIdentifier;
            break;

        default:
            identifier = CellIdentifier ;
            break;
    }
       
    // si està identificada per theCell, la torna directament.
    if ( theCell != nil ) return theCell ;
   
    NSAssert( identifier != nil, @"Cell identifier can not be nil!") ;
   // en cas contrari executa el procediment habitual
    LabelViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier] ;
       
    if ( cell == nil )
    {
        cell = [[LabelViewCell alloc] initWithReuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        //ControlViewCellContentView *cellContentView = [cell cellContentView] ;
        
        if ( identifier == ButtonLikeCellIdentifier )
        {
            [cell setIsButtonLikeCell:YES];
        }
        
        if ( section == kMaintenanceSection )
        {
            if ( row == kClearImageCache ) [cell setMainText:NSLocalizedString(@"Clear Image Cache", nil)];
            else if ( row == kClearReceiptsCache ) [cell setMainText:NSLocalizedString(@"Delete Pending Receipts", nil)];
        }
        
        if ( section == kMigrateToICLoudSection )
        {
            if ( row == kMigrateToIcloudRow ) [cell setMainText:NSLocalizedString(@"Open Migration Assistant", nil)];
        }
        
        else if ( section == kFeedbackSection )
        {
            if ( row == kLoveApp )[cell setMainText:NSLocalizedString(@"Review App", nil)];
            else if ( row == kReviewApp )[cell setMainText:NSLocalizedString(@"Technical Support", nil)];
        }
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


////---------------------------------------------------------------------------------------------------
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

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
    CGFloat result = 0 ;
    if ( section == kUserSection ) result = [[self messageView] getMessageHeight] ;
    else if ( section == kUserInterfaceSection ) result = [[self mViewUserInterface] getMessageHeight] ;
    else if ( section == kAlarmsSection ) result = [[self mViewAlarms] getMessageHeight] ;
    else if ( section == kCommsSection ) result = [[self mViewWebServer] getMessageHeight] ;
    else if ( section == kMaintenanceSection ) result = [[self mViewMaintenance] getMessageHeight] ;
    else if ( section == kMigrateToICLoudSection ) result = [[self mViewMigrate] getMessageHeight] ;
    else if ( section == kFeedbackSection ) result = [[self mViewFeedback] getMessageHeight] ;
    return result;
}

//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = nil ;
    if ( section == kUserSection ) result = [self messageView] ;
    else if ( section == kUserInterfaceSection ) result = [self mViewUserInterface] ;
    else if ( section == kAlarmsSection ) result = [self mViewAlarms] ;
    else if ( section == kCommsSection ) result = [self mViewWebServer] ;
    else if ( section == kMaintenanceSection ) result = [self mViewMaintenance];
    else if ( section == kMigrateToICLoudSection ) result = [self mViewMigrate];
    else if ( section == kFeedbackSection ) result = [self mViewFeedback];
    return result ;
}



//---------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog1( @"SettingsViewController: didSelectRowAtIndexPath %@", indexPath ) ;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if ( section == kMaintenanceSection )
    {
        if ( row == kClearImageCache ) [filesModel().amImage clearImageCache];
        else if ( row == kClearReceiptsCache ) [filesModel().amActivationCodes removeAllPendingReceipts];
    }
    
    else if ( section == kMigrateToICLoudSection )
    {
        if ( row == kMigrateToIcloudRow ) [self presentMigrationAssistantController];
    }
    
    
    else if ( section == kFeedbackSection )
    {
        if ( row == kLoveApp ) [self _presentLoveApp];
        else if ( row == kReviewApp ) [self presentReviewAppMailController];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)_presentLoveApp
{
//    NSString *myAppID = @ HMiPadID;
    
//    NSString *format = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
//    
//    NSString * urlString = [NSString stringWithFormat:format, myAppID];
//    NSURL *url = [NSURL URLWithString:urlString];
//    [[UIApplication sharedApplication] openURL:url];
    
    
    NSString *title = NSLocalizedString(@"Write an App Store review", nil);
    //NSString *message = NSLocalizedString(@"A 5 star comment helps us to build awareness and to continue improving the app.", nil);
    NSString *message = NSLocalizedString(@"We would really appreciate that you take the time to review "AppName".\nThank You!", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *other = NSLocalizedString(@"Rate/Review", nil);
    SWBlockAlertView *alertView = [[SWBlockAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:other, nil];
    [alertView setResultBlock:^(BOOL success, NSInteger index)
    {
        if ( success )
        {
            NSString *myAppID = @ HMiPadID;
            NSString *format = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
    
            NSString * urlString = [NSString stringWithFormat:format, myAppID];
            NSURL *url = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alertView show];
}



@end

