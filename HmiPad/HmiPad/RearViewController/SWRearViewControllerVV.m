//
//  AccountsTableController.m
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import "SWRearViewController.h"


#import "SWColor.h"
#import "ControlViewCell.h"
#import "SWTableViewHeader.h"
#import "AppFilesModel.h"
#import "AppUsersModel.h"
#import "UserDefaults.h"

#import "RoundedLabel.h"
#import "SWTableViewMessage.h"
#import "SWTableView.h"

#import "SWCurrentProjectViewController.h"
#import "SWAuxiliarFilesViewController.h"
#import "SWSettingsViewController.h"

#import "SWRevealViewController.h"
#import "ManageAccountsController.h"
#import "LoginWindowControllerC.h"


#import "HTTPConnectionSubclass.h"
#import "HTTPServerSubclass.h"
#import "UIView+DecoratorView.h"
#import <ifaddrs.h>
#import <netinet/in.h>

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark FilesViewController
#pragma mark
///////////////////////////////////////////////////////////////////////////////////////////


@interface SWRearViewController() <AppFilesModelObserver, AppUsersModelObserver, UITableViewDataSource, UITableViewDelegate>

@end




//---------------------------------------------------------------------------------------------
@implementation SWRearViewController
{
    //UITableViewStyle _tableViewStyle;
    //UITableView *_tableView;
    //UIView *_topView;
    
    BOOL _isShowingRemoteStorage;
    BOOL _isShowingRedemptions;
    //BOOL _isShowingRedeemedStorage;
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
///////////////////////////////////////////////////////////////////////////////////////////


#if HMiPadDev
enum sectionsInTable
{
    kUserSection = 0,
    kSectionLocalStorage,
    
#if SWEmbeddedWebServer
    kSectionFileServer,
#endif

#if SWITunesFileSharing
    kSectionExtFileCategories,
#endif
    kSectionRemoteStorage,
    
    TotalSectionsInTable,
    
        //kSectionRedeemedStorage,

#if !SWEmbeddedWebServer
        kSectionFileServer,
#endif

#if !SWITunesFileSharing
        kSectionExtFileCategories,
#endif

        kSectionPickers,     // A Eliminar
        //kSectionICloud,    // posar davant de kSectionFileServer per utilitzar
};

#elif HMiPadRun
enum sectionsInTable
{
    kUserSection = 0,
    kSectionLocalStorage,
    kSectionRemoteStorage,
    
    TotalSectionsInTable,
    
        //kSectionRedeemedStorage,
        kSectionExtFileCategories,
        kSectionFileServer,
    
        kSectionPickers,
};

#endif


enum rowsInUserSection
{
    kAutomaticLoginRow = 0,
    kCurrentAccountRow,
    kManageAccountsRow,
    kSettingsRow,
    TotalRowsInUserSection,
};



#if HMiPadDev
enum rowsInLocalStorageSection
{
    kRowSourcesCurrentProject = 0,
    kRowSourcesCategory,
    kRowAssetsCategory,
    TotalRowsInLocalStorageSection,
    
        kRowRecipesCategory,
};

#elif HMiPadRun
enum rowsInLocalStorageSection
{
    kRowSourcesCurrentProject = 0,
    kRowSourcesCategory,
    TotalRowsInLocalStorageSection,
    
        kRowAssetsCategory,
        kRowRecipesCategory,
};

#endif

//enum rowsInRedeemedStorageSection
//{
//    kRowReddemedSourcesCurrentProject = 0,
//    kRowRedeemedSourcesCategory,
//    TotalRowsInRedeemStorageSection,
//    
//       // kRowEmbeddedAssetsCategory
//};



#if HMiPadDev
enum rowsInRemoteStorageSection
{
    kRowRemoteSourcesCategory = 0,
    kRowRemoteAssetsCategory,
    kRowRemoteActivationCodesCategory,
    TotalRowsInRemoteStorageSection,
    
        kRowRemoteRedemptionsCategory,   // posar a dalt
};


#elif HMiPadRun
enum rowsInRemoteStorageSection
{
    kRowRemoteRedemptionsCategory = 0,
    TotalRowsInRemoteStorageSection,
    
        kRowRemoteSourcesCategory,
        kRowRemoteAssetsCategory,
        kRowRemoteActivationCodesCategory,
};

#endif

enum rowsInExtFileCategories
{
    kRowITunesCategory = 0,
    TotalRowsInExtFileCategoriesSection,
    
    kRowICloudCategory,
} ;

enum rowsInPickers
{
    kRowMusicPlayer = 0,
    kRowMediaPicker,
    kRowImagePicker,
    TotalRowsInPickersSection,
} ;

/*
enum rowsInICloudSection
{
    kRowICloud = 0,
    TotalRowsInICloudSection,
};
*/

enum rowsInFileServerSection
{
    kRowFileServer = 0,
    kRowFileServerInfo,
    TotalRowsInFileServerSection
};


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
///////////////////////////////////////////////////////////////////////////////////////////////



////---------------------------------------------------------------------------------------------------
//- (void)setManageAccountsText
//{
//    if ( manageAccountsCell == nil ) return ;
//
////    NSString *text ;
////    BOOL isAdmin = [usersModel() currentUserIsAdmin] ;
////    
////    if ( isAdmin ) text = NSLocalizedString(@"Manage accounts",nil);
////    else text = NSLocalizedString(@"Edit account",nil);
//    
//    NSString *text = NSLocalizedString(@"Manage accounts",nil);
//    
//    //[[manageAccountsCell label] setText:text];
//    [manageAccountsCell setMainText:text];
//}

//---------------------------------------------------------------------------------------------------
- (ControlViewCell*)manageAccountsCell
{
    if ( manageAccountsCell == nil )
    {
        manageAccountsCell = [[ControlViewCell alloc] initWithReuseIdentifier:nil];
        [manageAccountsCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [manageAccountsCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        NSString *text = NSLocalizedString(@"Manage accounts",nil);
        [manageAccountsCell setMainText:text];
        
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"112-group.png"]] ;
//        [imgView setContentMode:UIViewContentModeCenter] ;
//        [imgView setFrame:CGRectMake(0, 0, 30, 30)] ;
//        [manageAccountsCell setLeftView:imgView] ;
    }
    return manageAccountsCell ;
}

- (LabelViewCell*)currentProjectCell
{
    if ( currentProjectCell == nil )
    {
        currentProjectCell = [[LabelViewCell alloc] initWithReuseIdentifier:nil];
        [currentProjectCell setAccessoryType:UITableViewCellAccessoryNone];
        [currentProjectCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        NSString *text = NSLocalizedString(@"Current project",nil);
        [currentProjectCell setMainText:text];
        [self _setCurrentDocumentName];
//        UILabel *secondLabel = [currentProjectCell secondLabel] ;
//        [secondLabel setText:[filesModel() currentDocumentGetFileName]];
//        [secondLabel setFont:[UIFont boldSystemFontOfSize:17] ] ;
        
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"181-hammer.png"]] ;
//        [imgView setContentMode:UIViewContentModeCenter] ;
//        [imgView setFrame:CGRectMake(0, 0, 40, 40)] ;
//        [currentProjectCell setLeftView:imgView] ;
    }
    return currentProjectCell;
}

//---------------------------------------------------------------------------------------------------
- (ControlViewCell*)settingsCell
{
    if ( settingsCell == nil )
    {
        settingsCell = [[ControlViewCell alloc] initWithReuseIdentifier:nil];
        [settingsCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [settingsCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [settingsCell setMainText:NSLocalizedString(@"Settings",nil)];
    }
    return settingsCell ;
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

///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Convenience methods
///////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark alertView
////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------------------
// Crea i mostra un alertView amb el missatge especificat especificant self com a delegat
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil 
                        otherButtonTitles:NSLocalizedString( @"OK", nil ), nil ] ;
    [alertView show] ;
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Start/Stop
////////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSArray *)localHostAdresses
{
    NSMutableArray* result = [NSMutableArray array];
	struct ifaddrs*	addrs;
	BOOL success = (getifaddrs(&addrs) == 0);
	if (success) 
	{
		const struct ifaddrs* cursor = addrs;
		while (cursor != NULL) 
		{
			if (cursor->ifa_addr->sa_family == AF_INET) 
			{
                char *ifa_name = cursor->ifa_name ;
                if ( YES && ifa_name[0] == 'e' && ifa_name[1] == 'n' )
                {
                    const struct sockaddr_in* ifa_addr = (const struct sockaddr_in*)cursor->ifa_addr;
                    const uint8_t* base = (const uint8_t*)&ifa_addr->sin_addr;
                    NSString *ip = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", base[0], base[1], base[2], base[3]] ;
                    [result addObject:ip] ;
                }
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
    if ([result count] > 0 ) return result ;
    return nil ;
}

//-----------------------------------------------------------------------------
- (void)establishUserSettingsFooter
{
    NSString *message ;
    if ( HMiPadRun )
    {
        message = NSLocalizedString( @"EndUserSectionMessage", nil) ;
    }
    else
    {
        #if OEM
            message = [NSString stringWithFormat:@"%@\n\n%@", @ OEMAddress, NSLocalizedString(@"Powered by ScadaMobile" ,nil)] ;   // localitzar
        #else
            message = NSLocalizedString(@"LogToManageFiles" ,nil) ;
        #endif
    }
    [messageViewUser setMessage:message] ;
}


//----------------------------------------------------------------------------------------
// Posa el switch per arrancar i parar el server
- (void)establishStartSwitchAnimated:(BOOL)animated
{
    UISwitch *startSwitch = [fileServerSwitchCell switchv] ;
    BOOL currentState = [startSwitch isOn] ;
    BOOL newState = [[filesModel() httpServer] isStarted] ;
    if ( newState != currentState ) 
    {
        [startSwitch setOn:newState animated:animated] ;
    }
}


//----------------------------------------------------------------------------------------
// Posa el switch per arrancar i parar el server
- (void)establishLocalLabelWithBonjour:(BOOL)bonjour animated:(BOOL)animated
{
	HTTPServerSubclass *httpServer = [filesModel() httpServer] ;
    BOOL newState = [httpServer isStarted] ;
    
    ItemDecorationType decorationStyle = ItemDecorationTypeNone;
    //BOOL decoratorOnLeft = NO ;
    BOOL decoratorOnRight = NO ;
    NSString *txt ;
    if ( newState )
    {
        if ( bonjour )
        {
            txt = [NSString stringWithFormat:
                @"http://%@:%d\nBonjour: %@",
                [[self localHostAdresses] objectAtIndex:0],
                [httpServer port],
                [httpServer publishedName]
            ] ;
            decorationStyle = ItemDecorationTypeGreen ;
        }
        else
        {
            txt = NSLocalizedString(@"Resolving Embedded Server...", nil) ;
            decorationStyle = ItemDecorationTypeGrayActivityIndicator ;
            decoratorOnRight = YES ;
        }
    }
    else
    {
        txt = NSLocalizedString(@"Web Server Stopped", nil) ;
        //decorationStyle = ItemDecorationTypeGray ;
    }
    
    [fileServerInfoCell setMainText:txt] ;
    if ( decoratorOnRight == NO );
        [fileServerInfoCell setDecorationType:ItemDecorationTypeNone right:YES animated:animated];

    [fileServerInfoCell setDecorationType:decorationStyle right:decoratorOnRight animated:animated];
    //NSLog( @"%d,%d", decorationStyle, decoratorOnRight ) ;
}

//----------------------------------------------------------------------------------------
// Engega el server
- (void)doStartAnimated:(BOOL)animated
{
    [filesModel() startHttpServer:NULL] ;
}


//----------------------------------------------------------------------------------------
// Para el server
- (void)doStopAnimated:(BOOL)animated
{
    [filesModel() stopHttpServer] ;
}



//--------------------------------------------------------------------------------
- (void)switchChanged:(id)sender;
{
    UISwitch *sw = (UISwitch*)sender ;
    if ( [sw isOn] ) [filesModel() startHttpServer:NULL] ;
    else [filesModel() stopHttpServer] ;
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Message View
///////////////////////////////////////////////////////////////////////////////////////////////

//#define MBColor [UIColor whiteColor]
#define MBColor [UIColor colorWithWhite:0.98f alpha:1.0f]

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageViewUser
{
    if ( messageViewUser == nil )
    {
        if ( self.tableView.style == UITableViewStylePlain )
        {
            messageViewUser = [[SWTableViewMessage alloc] initForPlainSectionFooter] ;
            [messageViewUser setBackgroundColor:MBColor];
        }
        else
        {
            messageViewUser = [[SWTableViewMessage alloc] initForSectionFooter] ;
        }

#if OEM
        [[messageViewUser messageViewLabel] setTextAlignment:UITextAlignmentCenter] ;
#endif

        [self establishUserSettingsFooter] ;
    }
    return messageViewUser ;
}




//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageViewLocalStorage
{
    if ( messageViewLocalStorage == nil )
    {
        if ( self.tableView.style == UITableViewStylePlain )
        {
            messageViewLocalStorage = [[SWTableViewMessage alloc] initForPlainSectionFooter];
            [messageViewLocalStorage setBackgroundColor:MBColor];
        }
        else
        {
            messageViewLocalStorage = [[SWTableViewMessage alloc] initForSectionFooter];
        }
        [messageViewLocalStorage setMessage:NSLocalizedString(@"CategoriesList" ,nil)] ;
    }
    return messageViewLocalStorage ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageViewRedeemedStorage
{
    if ( messageViewRedeemedStorage == nil )
    {
        if ( self.tableView.style == UITableViewStylePlain )
        {
            messageViewRedeemedStorage = [[SWTableViewMessage alloc] initForPlainSectionFooter];
            [messageViewRedeemedStorage setBackgroundColor:MBColor];
        }
        else
        {
            messageViewRedeemedStorage = [[SWTableViewMessage alloc] initForSectionFooter];
        }
        [messageViewRedeemedStorage setMessage:NSLocalizedString(@"RedeemedCategoriesList" ,nil)] ;
    }
    return messageViewRedeemedStorage ;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageViewRemoteStorage
{
    if ( messageViewRemoteStorage == nil )
    {
        if ( self.tableView.style == UITableViewStylePlain )
        {
            messageViewRemoteStorage = [[SWTableViewMessage alloc] initForPlainSectionFooter];
            [messageViewRemoteStorage setBackgroundColor:MBColor];
        }
        else
        {
            messageViewRemoteStorage = [[SWTableViewMessage alloc] initForSectionFooter];
        }
        NSString *msg = kRowRemoteActivationCodesCategory<TotalRowsInRemoteStorageSection?
            @"CategoriesRemoteList":@"CategoriesRemoteListR";
        [messageViewRemoteStorage setMessage:NSLocalizedString(msg ,nil)] ;
    }
    return messageViewRemoteStorage ;
}

/*
//---------------------------------------------------------------------------------------------
- (MessageView *)messageICloudView
{
    if ( messageICloudView == nil )
    {
        UITableView *table = [self tableView] ;
        messageICloudView = [[MessageView alloc] initWithTableView:table] ;
        [messageICloudView setMessage:NSLocalizedString(@"MessageICloud" ,nil)] ;
    }
    return messageICloudView ;
}
*/

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageExtFilesView
{
    if ( messageExtFilesView == nil )
    {
        if ( self.tableView.style == UITableViewStylePlain )
        {
            messageExtFilesView = [[SWTableViewMessage alloc] initForPlainSectionFooter] ;
            [messageExtFilesView setBackgroundColor:MBColor];
        }
        else
        {
            messageExtFilesView = [[SWTableViewMessage alloc] initForSectionFooter] ;
        }
        [messageExtFilesView setMessage:NSLocalizedString(@"MessageExtFilesView" ,nil)] ;
    }
    return messageExtFilesView ;
}


//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageFileServerView
{
    if ( messageFileServerView == nil )
    {
        if ( self.tableView.style == UITableViewStylePlain )
        {
            messageFileServerView = [[SWTableViewMessage alloc] initForPlainSectionFooter] ;
            [messageFileServerView setBackgroundColor:MBColor];
        }
        else
        {
            messageFileServerView = [[SWTableViewMessage alloc] initForSectionFooter] ;
        }
        [messageFileServerView setMessage:NSLocalizedString(@"MessageFileServer" ,nil)] ;
    }
    return messageFileServerView ;
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


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Cells and custom views
///////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------
- (SwitchViewCell *)fileServerSwitchCell
{
    if ( fileServerSwitchCell == nil )
    {
        //notificationFlag = NO ;
        
        //rightButton = [[NavigationButtonController alloc] initWithOwner:self]; // navigationItem:[self navigationItem]];
        
        fileServerSwitchCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
        [fileServerSwitchCell setMainText:NSLocalizedString(@"Web Server", nil)];
        //[self establishStartSwitchAnimated:NO] ;
        [[fileServerSwitchCell switchv] addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
        // creem el mainMonitorStateCell
    }
    [self establishStartSwitchAnimated:NO] ;
    return fileServerSwitchCell ;
}

//---------------------------------------------------------------------------------------------
- (InfoViewCell*)fileServerInfoCell
{
    if ( fileServerInfoCell == nil )
    {
        fileServerInfoCell = [[InfoViewCell alloc] initWithReuseIdentifier:nil] ;
        //[self establishLocalLabelWithBonjour:YES] ;
        //[[fileServerInfoCell contentView] setBackgroundColor:[UIColor grayColor]] ;          ///xxxxxxxx
        [[fileServerInfoCell cellContentView] setBackgroundColor:[UIColor clearColor]] ;
    }
    [self establishLocalLabelWithBonjour:YES animated:NO] ;
    return fileServerInfoCell ;
}




///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TextField Delegates and NavigationButtonController callbacks
///////////////////////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SWRearViewController methods
///////////////////////////////////////////////////////////////////////////////////////////////

////---------------------------------------------------------------------------------------------
//- (id)init
//{
//    NSLog1( @"FilesViewController: init") ;
//    //self = [super initWithStyle:UITableViewStyleGrouped];
//    self = [super initWithStyle:UITableViewStylePlain];
//    if ( self )
//    {
//        [self setTitle:NSLocalizedString(@"Files",nil)] ;
////        [[self tabBarItem] setImage:[UIImage imageNamed:@"37-suitcase.png"]] ;     // big
////        [[self tabBarItem] setImage:[UIImage imageNamed:@"25-box.png"]] ;      // small
//    }
//    return self;
//}


//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super init];
//    if (self)
//    {
//        _tableViewStyle = style;  // <-- utilitzada de manera temporal, no accesible desde la interface
//        //_clearsSelectionOnViewWillAppear = YES;
//    }
//    return self;
//}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if ( self )
//    {
//        //_clearsSelectionOnViewWillAppear = YES;
//    }
//    return self;
//
//}

//---------------------------------------------------------------------------------------------
- (id)init
{
    NSLog1( @"FilesViewController: init") ;
    self = [self initWithStyle:UITableViewStyleGrouped];
    if ( self )
    {
        [self setTitle:NSLocalizedString(@"Home",nil)] ;
//        [[self tabBarItem] setImage:[UIImage imageNamed:@"37-suitcase.png"]] ;     // big
//        [[self tabBarItem] setImage:[UIImage imageNamed:@"25-box.png"]] ;      // small
    }
    return self;
}

//- (UITableView *)tableView
//{
//    return _tableView;
//}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    
//    NSLog1( @"FilesViewController: nib") ;
//    [self setTitle:NSLocalizedString(@"Files",nil)] ;
//    [[self tabBarItem] setImage:[UIImage imageNamed:@"37-suitcase.png"]] ;
//    //[[self tabBarItem] setImage:[UIImage imageNamed:@"update30.png"]] ;
//}

////---------------------------------------------------------------------------------------------
//- (void)disposeProperties
//{
//    NSLog1( @"FilesViewController: disposeProperties") ;
//    [[ModelNotificationCenter defaultCenter] removeObserver:self] ;
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil] ;
//
//    messageView = nil ;
//    //messageICloudView = nil ;
//    messageExtFilesView = nil ;
//    messageFileServerView = nil ;
//    messageDownload = nil ;
//    fileServerSwitchCell = nil ;
//    fileServerInfoCell = nil ;;
//
//}

//---------------------------------------------------------------------------------------------
- (void)dealloc
{
    NSLog1( @"SWRearFilesViewController: dealloc") ;
//    [self disposeProperties] ;
}


//- (void)loadView6
//{
//    if ( self.nibName /*|| self.storyboard*/ )
//    {
//        [super loadView];
//        return;
//    }
//
//    // Do not call super, to prevent the apis from unfruitful looking for inexistent xibs!
//    
//    // This is what Apple tells us to set as the initial frame, which is of course totally irrelevant
//    // with the modern view controller containment patterns, let's leave it for the sake of it!
//    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    
//    UIView *view = [[UIView alloc] initWithFrame:frame];
//    CGRect rect = view.bounds;
//    
//    CGRect topViewFrame = rect;
//    topViewFrame.size.height = 44;
//    
//    CGFloat iOS7Offset = 0;
//    if ( IS_IOS7 ) iOS7Offset = 20;
//    topViewFrame.size.height += iOS7Offset;
//    
//    CGRect tableFrame = rect;
//    tableFrame.origin.y = topViewFrame.size.height-iOS7Offset;
//    tableFrame.size.height -= tableFrame.origin.y;
//    
//    //UIView *topView = [[UIView alloc] initWithFrame:topViewFrame];
//    UITableView *topView = [[UITableView alloc] initWithFrame:topViewFrame style:_tableViewStyle];
//    topView.frame = topViewFrame;
//    [topView setUserInteractionEnabled:NO];
//    [topView setScrollEnabled:NO];
//    if ( _tableViewStyle == UITableViewStylePlain)
//        [topView setBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
//    
//    //[topView setBackgroundColor:UIColorWithRgb(SystemDarkerBlueColor)];
//    //[topView setBackgroundColor:DarkenedUIColorWithRgb(SystemDarkerBlueColor,0.7f)];
//    
//    [topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
//    
////    {
////        UIImage *image = [UIImage imageNamed:@"SweetWilliamfonsblanc40.png"];
////        UIView *imageView = [[UIImageView alloc] initWithImage:image];
////        //NSLog( @"%@", NSStringFromCGRect(imageView.frame));
////        [imageView setCenter:CGPointMake(topViewFrame.size.width/2, topViewFrame.size.height/2)];
////        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
////            UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
////        [topView addSubview:imageView];
////    }
//    {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,200,40)];
//        
//        [label setCenter:CGPointMake(topViewFrame.size.width/2, iOS7Offset/2+topViewFrame.size.height/2)];
//        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
//            UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
//        [label setBackgroundColor:[UIColor clearColor]];
//        //[label setText:@"HMI Pad"];
//        [label setText:@ AppName];
//        //[label setFont:[UIFont boldSystemFontOfSize:18]];
//        [label setFont:[UIFont fontWithName:@"Verdana-Bold" size:18]];
//        [label setTextColor:[UIColor darkGrayColor]];
//        [label setShadowColor:[UIColor whiteColor]];
//        [label setShadowOffset:CGSizeMake(1, 1)];
//        [label setTextAlignment:NSTextAlignmentCenter];
//    
//        [topView addSubview:label];
//    }
//    
//    CALayer *topViewLayer = topView.layer;
//    topViewLayer.masksToBounds = NO;
//    topViewLayer.shadowColor = [UIColor blackColor].CGColor;
//    topViewLayer.shadowOpacity = 0.5f;
//    topViewLayer.shadowOffset = CGSizeMake(0,0);
//    topViewLayer.shadowRadius = 2.5f;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:topView.bounds];
//    topViewLayer.shadowPath = shadowPath.CGPath;
//    
//    // create a custom content view for the controller (e.g a UITableView)
//    SWTableView *tableView = [[SWTableView alloc] initWithFrame:tableFrame style:_tableViewStyle];
//    
//    // set the content view to resize along with its superview
//    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [tableView setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
//    [tableView setTableViewOffset:CGPointMake(0, -10)];
//    
//    // set delegates for the UITableView to self
//    tableView.dataSource = self;
//    tableView.delegate = self;
//    
//    // set properties
//    _topView = topView;
//    _tableView = tableView;
//    
//    // add subviews
//    [view addSubview:_tableView];
//    [view addSubview:_topView];
//
//    // set our contentView to the controllers view
//    self.view = view;
//}



- (void)loadView7
{
    [super loadView];
    
    // Do not call super, to prevent the apis from unfruitful looking for inexistent xibs!
    
    // This is what Apple tells us to set as the initial frame, which is of course totally irrelevant
    // with the modern view controller containment patterns, let's leave it for the sake of it!
//    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    
//    UIView *view = [[UIView alloc] initWithFrame:frame];
//    CGRect rect = view.bounds;
    
//    {
//        UIImage *image = [UIImage imageNamed:@"SweetWilliamfonsblanc40.png"];
//        UIView *imageView = [[UIImageView alloc] initWithImage:image];
//        //NSLog( @"%@", NSStringFromCGRect(imageView.frame));
//        [imageView setCenter:CGPointMake(topViewFrame.size.width/2, topViewFrame.size.height/2)];
//        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
//            UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
//        [topView addSubview:imageView];
//    }
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,200,40)];
        
        //[label setCenter:CGPointMake(topViewFrame.size.width/2, iOS7Offset/2+topViewFrame.size.height/2)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
            UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [label setBackgroundColor:[UIColor clearColor]];
        //[label setText:@"HMI Pad"];
        [label setText:@ AppName];
        //[label setFont:[UIFont boldSystemFontOfSize:18]];
        [label setFont:[UIFont fontWithName:@"Verdana-Bold" size:18]];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setShadowColor:[UIColor whiteColor]];
        [label setShadowOffset:CGSizeMake(1, 1)];
        [label setTextAlignment:NSTextAlignmentCenter];
    
        [[self navigationItem] setTitleView:label];
    }
    
    
    // create a custom content view for the controller (e.g a UITableView)
    //SWTableView *tableView = [[SWTableView alloc] initWithFrame:rect style:_tableViewStyle];
    
//    UITableView *tableView = self.tableView;

    // en tableviews posats directament aixo sembla funcionar, en canvi el ajust automatic causa un scroll a dalt de tot en el viewWillAppear
//    [self setAutomaticallyAdjustsScrollViewInsets:NO];
//    CGFloat topGuide = 64;
//    [tableView setContentInset:UIEdgeInsetsMake(topGuide, 0, 0, 0)];
//    [tableView setTableViewOffset:CGPointMake(0, -topGuide)];

    
    // set the content view to resize along with its superview
    //[tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

    
    // set delegates for the UITableView to self
//    tableView.dataSource = self;
//    tableView.delegate = self;
    
    // set properties
    //_tableView = tableView;
    
    // add subviews
    //[view addSubview:_tableView];

    // set our contentView to the controllers view
    //self.view = view;
}


- (void)loadView
{
//    if ( IS_IOS7 ) [self loadView7];
//    else [self loadView6];
    
    [self loadView7];
}


//---------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    id tmpObj ;
        
    automaticLoginCell = [[SwitchViewCell alloc] initWithReuseIdentifier:nil] ;
    [automaticLoginCell setMainText:NSLocalizedString(@"Automatic login", nil)];
    [tmpObj=[automaticLoginCell switchv] setOn:[usersModel() automaticLogin]];  // agafa de preferences
    [tmpObj addTarget:self action:@selector(autoLoginSwitchChanged:) forControlEvents:UIControlEventValueChanged];

    currentAccountCell = [[LabelViewCell alloc] initWithReuseIdentifier:nil] ;
    [currentAccountCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    [currentAccountCell setMainText:NSLocalizedString(@"Current account", nil)];
    
//    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"111-user.png"]] ;
//    [imgView setContentMode:UIViewContentModeCenter] ;
//    [imgView setFrame:CGRectMake(0, 0, 30, 30)] ;
//    [currentAccountCell setLeftView:imgView] ;

    UITableView *table = [self tableView];
    [table setTableFooterView:[self versionView]] ;
    
    if ( IS_IOS7 )
    {
    
    }
    else
    {
        [table setBackgroundColor:[UIColor colorWithWhite:0.98f alpha:1.0]];
    }
    
    [table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
       
    //[[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
//    [nc addObserver:self selector:@selector(currentUserDidChangedNotification:) name:kCurrentUserDidChangeNotification object:nil] ;
    //[[self tableView] setDelaysContentTouches:NO];
}

////---------------------------------------------------------------------------------------------
//- (void)viewDidUnload
//{
//    NSLog1( @"FilesViewController viewDidUnload" );
//    [super viewDidUnload] ;
//    [self disposeProperties] ;
//}

//---------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated 
{
    NSLog1( @"FilesViewController viewWillAppear" );
    
//    if ( dataNeedsReload )
//    {
//        [[self tableView] reloadData] ;
//        dataNeedsReload = NO ;
//    }
    
//    viewAppeared = YES ;

    
    [super viewWillAppear:animated];
    
    
   // [self establishLocalLabelWithBonjour:YES] ;
   // [self establishStartSwitchAnimated:NO] ;

   
//    NSString *userName = [usersModel() currentUserName];
//    [[currentAccountCell secondLabel] setText:userName];
    
    [self _establishSectionsForCurrentUserAnimated:NO];
    [self _setCurrentDocumentName];
    
    BOOL state = [usersModel() automaticLogin];
    [automaticLoginCell.switchv setOn:state animated:YES];
   
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(httpServerReachabilityErrorNotification:) name:kHTTPServerReachabilityErrorNotification object:nil]; 
    [nc addObserver:self selector:@selector(httpServerServiceDidPublishNotification:) name:kHTTPServerServiceDidPublishNotification object:nil]; 
    [nc addObserver:self selector:@selector(httpServerServiceDidNotPublishNotification:) name:kHTTPServerServiceDidNotPublishNotification object:nil]; 
    [nc addObserver:self selector:@selector(httpServerDidExecuteStartNotification:) name:kHTTPServerDidExecuteStartNotification object:nil]; 
    [nc addObserver:self selector:@selector(httpServerDidExecuteStopNotification:) name:kHTTPServerDidStopNotification object:nil];
    
    [nc addObserver:self selector:@selector(currentUserDidChangedNotification:) name:kCurrentUserDidChangeNotification object:nil] ;

    
    [filesModel() addObserver:self];
    [usersModel() addObserver:self];

}

//---------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    
   // [[self navigationController] setToolbarHidden:YES animated:animated] ;
}


//---------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated 
{
    NSLog1( @"FilesViewController viewWillDissappear" ) ;
    
    //viewAppeared = NO ;
    [filesModel() removeObserver:self];
    [usersModel() removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[super viewWillDisappear:animated];
}



/*
- (void)viewDidDisappear:(BOOL)animated 
{
    NSLog1( @"FilesViewController viewDidDissappear: %@", [[self navigationController] topViewController] ) ;
    {
	//do stuff
    }
	[super viewDidDisappear:animated];
}
*/


//---------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //if ( interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) return NO ;
    return YES ;
}

//---------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning 
{

    NSLog1( @"FilesViewController didReceiveMemoryWarning" ) ;
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark private

- (void)_setCurrentDocumentName
{
    UILabel *secondLabel = [currentProjectCell secondLabel] ;
    NSString *name = [filesModel() currentDocumentShortName];
    if ( name )
    {
        [secondLabel setText:name];
        [secondLabel setFont:[UIFont systemFontOfSize:15] ] ;
    }
    else
    {
        [secondLabel setText:NSLocalizedString(@"No Project", nil)];
        [secondLabel setFont:[UIFont italicSystemFontOfSize:15] ] ;
    }
}


#pragma mark establiment del tableView

//- (void)_establishSectionsForCurrentUserAnimated:(BOOL)animated
//{
//    UserProfile *profile = [usersModel() currentUserProfile];
//    
//    NSString *userName = profile.username;
//    [[currentAccountCell secondLabel] setText:userName];
//    
//    BOOL isLocal = (profile.isLocal != NO);
//    //BOOL isEndUser = (HMiPadRun != NO);
//
////    BOOL shouldShowRemoteStorage = !isLocal && !isEndUser;
////    BOOL shouldShowRedeemedStorage = !isLocal;
////    BOOL shouldShowExternalStorage = !isEndUser;
//    
//    
//    BOOL shouldShowRemoteStorage = !isLocal;
//    BOOL shouldShowRedeemedStorage = !isLocal;
////    BOOL shouldShowExternalStorage = !isEndUser;
//
//    UITableView *table = self.tableView;
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    
//    if ( shouldShowRemoteStorage != _isShowingRemoteStorage )
//    {
//        _isShowingRemoteStorage = shouldShowRemoteStorage;
//        messageViewRemoteStorage = nil;
//        if ( kSectionRemoteStorage < TotalSectionsInTable )
//            [indexSet addIndex:kSectionRemoteStorage];
//    }
//    
//    if ( shouldShowRedeemedStorage != _isShowingRedeemedStorage )
//    {
//        _isShowingRedeemedStorage = shouldShowRedeemedStorage;
//        messageViewRedeemedStorage = nil;
//        if ( kSectionRedeemedStorage < TotalSectionsInTable )
//            [indexSet addIndex:kSectionRedeemedStorage];
//    }
//    
////    if ( shouldShowExternalStorage != _isShowingExternalStorage )
////    {
////        _isShowingExternalStorage = shouldShowExternalStorage;
////        messageExtFilesView = nil;
////        [indexSet addIndex:kSectionExtFileCategories];
////    }
//
//    if ( [indexSet count]> 0 )
//    {
//        UITableViewRowAnimation animation = animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone;
//        [table reloadSections:indexSet withRowAnimation:animation];
//    }
//}



//---------------------------------------------------------------------------------------------
//- (void)resetFilesSectionAnimated:(BOOL)animated animateButtons:(BOOL)bAnimated forFileCategory:(FileCategory)category
- (void)_resetFilesSectionForFileCategory:(FileCategory)category animated:(BOOL)animated
{
    // carreguem la secció
    
    UITableViewRowAnimation tableAnimation = (animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone ) ;
    
    NSUInteger row ;
    NSUInteger section ;
    
    if ( category == kFileCategorySourceFile ) section = kSectionLocalStorage, row = kRowSourcesCategory ;
#if SWRecipes
    else if ( category == kFileCategoryRecipe ) section = kSectionLocalStorage, row = kRowRecipesCategory ;
#endif
    else if ( category == kFileCategoryAssetFile ) section = kSectionLocalStorage, row = kRowAssetsCategory ;
    
    //else if ( category == kFileCategoryRedeemedSourceFile ) section = kSectionRedeemedStorage, row = kRowRedeemedSourcesCategory ;
    //else if ( category == kFileCategoryGroupedAssetFile ) section = kSectionRedeemedStorage, row = kRowRedeemedAssetsCategory ;
    
    else if ( category == kFileCategoryRemoteSourceFile) section = kSectionRemoteStorage, row = kRowRemoteSourcesCategory;
    else if ( category == kFileCategoryRemoteAssetFile) section = kSectionRemoteStorage, row = kRowRemoteAssetsCategory;
    else if ( category == kFileCategoryRemoteActivationCode) section = kSectionRemoteStorage, row = kRowRemoteActivationCodesCategory;
    else if ( category == kFileCategoryRemoteRedemption ) section = kSectionRemoteStorage, row = kRowRemoteRedemptionsCategory;
    
    else if ( category == kExtFileCategoryITunes ) section = kSectionExtFileCategories, row = kRowITunesCategory ;
    else return ;
    
    section = [self controllerSectionForModelSection:section];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section] ;
    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:tableAnimation] ;
    
    // no va en iOS 4.3, bug al redibuixar el footerView de la seccio, amb animationNone tampoc va.
    /*
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:kSectionFileCategories] withRowAnimation:tableAnimation] ;
    */
    
    /*
    // en lloc de lo anterior fem la animacio explicita a les files una per una
    NSMutableArray *indexPaths = [NSMutableArray array] ;
    for ( int i=0, count=[[filesModel() filesArray] count] ; i < count ; i++ )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:kSourceFilesSection] ;
        [indexPaths addObject:indexPath] ;
    }
    [[self tableView] reloadRowsAtIndexPaths:indexPaths withRowAnimation:tableAnimation] ;
    */
    
    // si no volem animacio aixo també va pero se suposa que te overhead
    //[[self tableView] reloadData] ;
}

- (void)_establishSectionsForCurrentUserAnimated:(BOOL)animated
{
    UserProfile *profile = [usersModel() currentUserProfile];
    
    NSString *userName = profile.username;
    [[currentAccountCell secondLabel] setText:userName];
    
    BOOL isLocal = (profile.isLocal != NO);
    
    BOOL isShowingRemoteStorage = _isShowingRemoteStorage;
    BOOL shouldShowRemoteStorage = !isLocal;
    //BOOL isShowingRedeemedStorage = _isShowingRedeemedStorage;
    //BOOL shouldShowRedeemedStorage = !isLocal;

    UITableView *table = self.tableView;
    NSMutableIndexSet *indexSetAdd = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *indexSetRemove = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *indexSetReload = [NSMutableIndexSet indexSet];
    
    if ( !shouldShowRemoteStorage && shouldShowRemoteStorage != isShowingRemoteStorage)
    {
        if ( kSectionRemoteStorage < TotalSectionsInTable )
        {
            NSUInteger index = [self controllerSectionForModelSection:kSectionRemoteStorage];
            [indexSetRemove addIndex:index];  // the index before updating
        }
    }
    
    if ( shouldShowRemoteStorage && shouldShowRemoteStorage == isShowingRemoteStorage )
    {
        if ( kSectionRemoteStorage < TotalSectionsInTable )
        {
            NSUInteger index = [self controllerSectionForModelSection:kSectionRemoteStorage];
            [indexSetReload addIndex:index];   // the index before updating
        }
    }
    
//    if ( !shouldShowRedeemedStorage && shouldShowRedeemedStorage != isShowingRedeemedStorage)
//    {
//        if ( kSectionRedeemedStorage < TotalSectionsInTable )
//        {
//            NSUInteger index = [self controllerSectionForModelSection:kSectionRedeemedStorage];
//            [indexSetRemove addIndex:index];   // the index before updating
//        }
//    }
    
    messageViewRemoteStorage = nil;
    messageViewRedeemedStorage = nil;
    _isShowingRemoteStorage = shouldShowRemoteStorage;
//    _isShowingRedeemedStorage = shouldShowRedeemedStorage;
    
    if ( shouldShowRemoteStorage && shouldShowRemoteStorage != isShowingRemoteStorage)
    {
        if ( kSectionRemoteStorage < TotalSectionsInTable )
        {
            NSUInteger index = [self controllerSectionForModelSection:kSectionRemoteStorage];
            [indexSetAdd addIndex:index];   // the index after updating
        }
    }
    
//    if ( shouldShowRedeemedStorage && shouldShowRedeemedStorage != isShowingRedeemedStorage)
//    {
//        if ( kSectionRedeemedStorage < TotalSectionsInTable )
//        {
//            NSUInteger index = [self controllerSectionForModelSection:kSectionRedeemedStorage];
//            [indexSetAdd addIndex:index];   // the index after updating
//        }
//    }

    UITableViewRowAnimation animation = animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone;
    [table beginUpdates];
    {
        if ( [indexSetAdd count] > 0 )
            [table insertSections:indexSetAdd withRowAnimation:animation];
    
        if ( [indexSetRemove count] > 0 )
            [table deleteSections:indexSetRemove withRowAnimation:animation];
        
        if ( [indexSetReload count] > 0 )
            [table reloadSections:indexSetReload withRowAnimation:animation];
    }
    [table endUpdates];
}


//-----------------------------------------------------------------------------
- (NSUInteger)controllerSectionForModelSection:(NSUInteger)section
{
    NSUInteger controllerSection = section;
    if ( !_isShowingRemoteStorage && section > kSectionRemoteStorage) controllerSection -= 1;
    //if ( !_isShowingRedeemedStorage && section > kSectionRedeemedStorage) controllerSection -= 1;
    return controllerSection;
}

- (NSUInteger)controllerRowForModelRow:(NSUInteger)row inSection:(NSUInteger)section
{
    NSUInteger controllerRow = row;
    
    if ( section == kSectionRemoteStorage )
    {
        if ( !_isShowingRedemptions && row > kRowRemoteRedemptionsCategory ) controllerRow -= 1;
    }
    
    return controllerRow;
}

//-----------------------------------------------------------------------------
- (NSUInteger)modelSectionForControllerSection:(NSUInteger)controllerSection
{
    NSUInteger offset = 0;
    if ( !_isShowingRemoteStorage && controllerSection+offset >= kSectionRemoteStorage) offset += 1;
    //if ( !_isShowingRedeemedStorage && controllerSection+offset >= kSectionRedeemedStorage) offset += 1;
    NSUInteger section = controllerSection+offset;
    return section;
}


- (NSUInteger)modelRowForControllerRow:(NSUInteger)controllerRow inModelSection:(NSUInteger)section
{
    NSUInteger offset = 0;
    if ( section == kSectionRemoteStorage )
    {
        if ( !_isShowingRedemptions && controllerRow+offset >= kRowRemoteRedemptionsCategory) offset += 1;
    }
    
    NSUInteger row = controllerRow+offset;
    return row;
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Notificacio de canvi de user settings
///////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
- (void)currentUserDidChangedNotification:(NSNotification *)notification
{
//    NSString *userName = [usersModel() currentUserName];
//    [[currentAccountCell secondLabel] setText:userName];
    
    [self _establishSectionsForCurrentUserAnimated:YES];
}


#pragma mark AppUsersModelObserver

- (void)appUsersModelAutoLoginDidChange:(AppUsersModel*)usersModel
{
    BOOL state = [usersModel automaticLogin];
    [automaticLoginCell.switchv setOn:state animated:YES];
}


#pragma mark AppsFileModelObserver




//---------------------------------------------------------------------------------------------
- (void)appsFileModel:(AppFilesModel *)filesModel didChangeListingForCategory:(FileCategory)category
{
     //[self resetFilesSectionAnimated:YES animateButtons:YES forFileCategory:category] ;
     [self _resetFilesSectionForFileCategory:category animated:NO] ;
}

- (void)appFilesModelCurrentDocumentChange:(AppLocalFilesModel *)filesModel
{
    [self _setCurrentDocumentName];
}

- (void)appsFileModelSourcesDidChange:(AppFilesModel *)filesModel
{

}

- (void)appFilesModel:(AppFilesModel *)filesModel willChangeRemoteListingForCategory:(FileCategory)category
{

}

- (void)appFilesModel:(AppFilesModel *)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError *)error
{
    if ( error == nil )
    {
        //[self resetFilesSectionAnimated:YES animateButtons:YES forFileCategory:category] ;
        [self _resetFilesSectionForFileCategory:category animated:NO] ;
    }
}


////-----------------------------------------------------------------------------
//- (void)filesArraysTouchedNotification:(NSNotification *)notification
//{ 
//    NSLog1( @"FilesViewController: filesArraysTouchedNotification") ;
//    NSDictionary *userInfo = [notification userInfo] ;
//    FileCategory category = [[userInfo objectForKey:kFileCategory] intValue] ;
//
//    // marquem que necesitarem recarregar la taula ( ara o en viewWillAppear )
//    dataNeedsReload = YES ;
//    if ( viewAppeared )
//    {
//        // [[self tableView] reloadSections:indexSet withRowAnimation:UITableViewRowAnimationTop] ; // aquest va pero es lleig
//        [self resetFilesSectionAnimated:YES animateButtons:YES forFileCategory:category] ;
//         
//        dataNeedsReload = NO ;
//    }
//}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark HTTPServerSubclass Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
//- (void)netServiceDidPublish:(NSNetService *)ns
- (void)httpServerServiceDidPublishNotification:(NSNotification *)note
{
    [self establishLocalLabelWithBonjour:YES animated:YES] ;
}

//----------------------------------------------------------------------------------------
//- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
- (void)httpServerServiceDidNotPublishNotification:(NSNotification *)note
{
    [self establishLocalLabelWithBonjour:NO animated:YES] ;
}

//----------------------------------------------------------------------------------------
- (void)httpServerDidExecuteStartNotification:(NSNotification *)note
{
    [self establishLocalLabelWithBonjour:NO animated:YES] ;
    [self establishStartSwitchAnimated:YES] ;
    //[self establishBadgeIcon] ;
    
    HTTPServerSubclass *httpServer = [note object] ;
    if ( [httpServer isStarted] == NO )
    {
        NSError *error = [[note userInfo] objectForKey:@"error"] ;
        [self showAlertViewWithTitle:NSLocalizedString( @"Error starting http Server", nil )  // //gestioerror // posar a applicacio delegate
            message:[error localizedDescription]] ;
    }
}

//----------------------------------------------------------------------------------------
- (void)httpServerDidExecuteStopNotification:(NSNotification *)note
{
    [self establishLocalLabelWithBonjour:NO animated:YES] ;
    [self establishStartSwitchAnimated:YES] ;
    //[self establishBadgeIcon] ;
}

//----------------------------------------------------------------------------------------
- (void)httpServerReachabilityErrorNotification:(NSNotification *)note
{
    NSError *error = [[note userInfo] objectForKey:@"error"] ;
    [self showAlertViewWithTitle:NSLocalizedString( @"File Server Error", nil )  // //gestioerror // posar a applicacio delegate
            message:[error localizedDescription]] ;
            
    [filesModel() stopHttpServer] ;
}




//---------------------------------------------------------------------------------------------
- (void)showMediaLibrary
{


	//[[TKAlertCenter defaultCenter] postAlertWithMessage:@"Doing Something COOL\nand cooler"];

    // Specify a media query; this one matches the entire iPod library because it
    // does not contain a media property predicate
    //MPMediaQuery *everything = [[MPMediaQuery alloc] init];
     
    // Configure the media query to group its media items; here, grouped by artist
    //[everything setGroupingType: MPMediaGroupingArtist];
    
    /*
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate 
            predicateWithValue:@"CIARIES" forProperty:MPMediaItemPropertyAlbumTitle] ;
            
    MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate 
            predicateWithValue:@"30_Sec_Various-twist_my_hips_INST_01" forProperty:MPMediaItemPropertyTitle] ;
            
    NSSet *propertyPredicatesSet = [NSSet setWithObjects:albumPredicate,titlePredicate,nil] ;
    
    MPMediaQuery *albumQuery = [[MPMediaQuery alloc] init];
    [albumQuery setGroupingType:MPMediaGroupingAlbum] ;
    [albumQuery setFilterPredicates:propertyPredicatesSet] ;
    */
    
    
    MPMediaPropertyPredicate *playListPredicate1 = [MPMediaPropertyPredicate 
            predicateWithValue:@"Prove" forProperty:MPMediaPlaylistPropertyName] ;
            
    MPMediaPropertyPredicate *playListPredicate2 = [MPMediaPropertyPredicate 
            predicateWithValue:@"ScadaMobile" forProperty:MPMediaPlaylistPropertyName] ;
    
    //MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate 
    //        predicateWithValue:@"CIARIES" forProperty:MPMediaItemPropertyAlbumTitle] ;
            
    MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate 
            predicateWithValue:@"30_Sec_Various-twist_my_hips_INST_01" forProperty:MPMediaItemPropertyTitle] ;
            
    NSSet *propertyPredicatesSet = [NSSet setWithObjects:/*albumPredicate,*/titlePredicate,playListPredicate1, playListPredicate2,nil] ;
    
    MPMediaQuery *albumQuery = [[MPMediaQuery alloc] init];
    [albumQuery setGroupingType:MPMediaGroupingPlaylist] ;
    [albumQuery setFilterPredicates:propertyPredicatesSet] ;
    
 
    // Obtain the media item collections from the query
    //NSArray *collections = [albumQuery collections];
    NSArray *mediaItems = [albumQuery items] ;
    //[everything release] ;
    
    NSString *albumIDKey = [MPMediaItem persistentIDPropertyForGroupingType: MPMediaGroupingAlbum];
    NSLog( @"calculated album IDKey: %@", albumIDKey ) ;
    NSLog( @"constant   album IDKey: %@", MPMediaItemPropertyAlbumPersistentID ) ;
    
    /*
    MPMediaGroupingTitle,
   MPMediaGroupingAlbum,
   MPMediaGroupingArtist,
   MPMediaGroupingAlbumArtist,
   MPMediaGroupingComposer,
   MPMediaGroupingGenre,
   MPMediaGroupingPlaylist,
   MPMediaGroupingPodcastTitle,
   */    
    
    NSSet *properties = [NSSet setWithObjects:
        //MPMediaItemPropertyPersistentID, 
        //MPMediaItemPropertyAlbumTitle, 
        //MPMediaItemPropertyTitle, 
        MPMediaItemPropertyAssetURL,
        nil] ;
        
    if ( [mediaItems count] == 0 ) 
    {
        //[filesModel() alarmListAddSystemAlarmWithGroup:@"AUDIO" text:@"No s'ha trobat cap cançó que vagi be"] ;
        NSLog( @"TODO notificar a les alarmes que no s'ha trobat cap cançó que vagi be" ) ;
    }
    
    for ( MPMediaItem *mediaItem in mediaItems )
    {
        NSLog( @"  MediaITem: %@", mediaItem ) ;
        [mediaItem enumerateValuesForProperties:properties usingBlock:
        ^(NSString *property, id value, BOOL *stop) 
        {
            NSLog( @"    Property %@ %@", property, value ) ;
            if ( property == MPMediaItemPropertyAssetURL )
            {
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:value forKey:@"SoundURL"] ;
                [nc postNotificationName:@"PlaySound" object:nil userInfo:userInfo] ;
            }
        }] ;
    }
    
    /*
    for ( MPMediaItemCollection *collection in collections )
    {
        NSLog( @"Collection: %@", collection ) ;
        NSArray *mediaItemsb = [collection items] ;
        for ( MPMediaItem *mediaItem in mediaItemsb )
        {
            NSLog( @"  MediaITem: %@", mediaItem ) ;
            [mediaItem enumerateValuesForProperties:properties usingBlock:
            ^(NSString *property, id value, BOOL *stop) 
            {
                NSLog( @"    Property %@ %@", property, value ) ;
            }] ;
        }
    }
    */
    
    
    
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


//---------------------------------------------------------------------------------------------------
- (void)loginWindowDidClose:(LoginWindowControllerC*)sender
{    
    [self setLoginWindow:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView Data Source methods
///////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger totalSections = [self controllerSectionForModelSection:TotalSectionsInTable];
    return totalSections;
}

//---------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)controllerSection
{
    NSInteger number ;
    
    NSUInteger section = [self modelSectionForControllerSection:controllerSection];
    
    
    switch ( section )
    {
        case kUserSection:
            number = TotalRowsInUserSection;
            break;
        
        case kSectionLocalStorage:
            number = TotalRowsInLocalStorageSection ;
            break ;
            
//        case kSectionRedeemedStorage:
//            number = TotalRowsInRedeemStorageSection;
//            break;
            
        case kSectionRemoteStorage:
            number = TotalRowsInRemoteStorageSection;
            break;
            
        case kSectionExtFileCategories:
            number = TotalRowsInExtFileCategoriesSection;
            break ;
        /*
        case kSectionICloud:
            number = TotalRowsInICloudSection ;
            break ;
            */
        
        case kSectionFileServer:
            number = TotalRowsInFileServerSection ;
            break ;
            
        case kSectionPickers:
            number = TotalRowsInPickersSection ;
            break ;
            
        default:
            number = 0 ;
            break ;
    }
    return number ;
}



- (UIView*)tableView_NO:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *str ;
    
    section = [self modelSectionForControllerSection:section];
    switch ( section )
    {
        case kUserSection:
            str = NSLocalizedString( @"User Settings", nil ) ;
            break ;
            
        case kSectionLocalStorage:
            str = NSLocalizedString( @"Local Files", nil ) ;
            break ;
            
//        case kSectionRedeemedStorage:
//            str = NSLocalizedString( @"Local Projects", nil ) ;
//            break ;
            
        case kSectionRemoteStorage:
            str = NSLocalizedString( @"Integrators Service", nil ) ;
            break ;
            
        case kSectionExtFileCategories:
            str = NSLocalizedString( @"External Storage", nil ) ;          // localitzar
            break ;
            
        /*
        case kSectionICloud:
            str = NSLocalizedString( @"iCloud Storage", nil ) ;
            break ; */
        
        case kSectionFileServer: 
            str = NSLocalizedString( @"Embedded Web Server", nil ) ;
            break ;
            
        case kSectionPickers:
            str = @"Pickers Section" ;
            break ;
            
        default:
            str = nil ;
            break ;
    }

    SWTableViewHeader *sectionHeader = [[SWTableViewHeader alloc] initWithHeight:22];
    [sectionHeader setTitle:str];
    return sectionHeader;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str ;
    
    section = [self modelSectionForControllerSection:section];
    switch ( section )
    {
        case kUserSection:
            str = NSLocalizedString( @"User Settings", nil ) ;
            break ;
            
        case kSectionLocalStorage:
            str = NSLocalizedString( @"Local Files", nil ) ;
            break ;
            
//        case kSectionRedeemedStorage:
//            str = NSLocalizedString( @"Redeemed Projects", nil ) ;
//            break ;
            
        case kSectionRemoteStorage:
            str = NSLocalizedString( @"Integrators Service", nil ) ;
            break ;
            
        case kSectionExtFileCategories:
            str = NSLocalizedString( @"External Storage", nil ) ;          // localitzar
            break ;
            
        /*
        case kSectionICloud:
            str = NSLocalizedString( @"iCloud Storage", nil ) ;
            break ; */
        
        case kSectionFileServer: 
            str = NSLocalizedString( @"Embedded Web Server", nil ) ;
            break ;
            
        case kSectionPickers:
            str = @"Pickers Section" ;
            break ;
            
        default:
            str = nil ;
            break ;
    }
    
//    if ( section == kSectionRedeemedStorage && !_isShowingRedeemedStorage ) str = nil;
//    if ( section == kSectionRemoteStorage && !_isShowingRemoteStorage ) str = nil;
    
    return str;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    CGFloat height = 22;
//    
//    if ( section == kSectionRedeemedStorage && !_isShowingRedeemedStorage ) height = 0;
//    if ( section == kSectionRemoteStorage && !_isShowingRemoteStorage ) height = 0;
//
//    return height;
//}



////---------------------------------------------------------------------------------------------------
//- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
//{
//    NSString *str ; 
//    switch ( section )
//    {
//        case kUserSection:
//            str = NSLocalizedString( @"User Settings", nil ) ;
//            break ;
//            
//        case kSectionLocalStorage:
//            str = NSLocalizedString( @"Local Files", nil ) ;
//            break ;
//            
//        case kSectionRemoteStorage:
//            str = NSLocalizedString( @"Integrators Service", nil ) ;
//            break ;
//            
//        case kSectionExtFileCategories:
//            str = NSLocalizedString( @"External Storage", nil ) ;          // localitzar
//            break ;
//            
//        /*
//        case kSectionICloud:
//            str = NSLocalizedString( @"iCloud Storage", nil ) ;
//            break ; */
//        
//        case kSectionFileServer: 
//            str = NSLocalizedString( @"Embedded Web Server", nil ) ;
//            break ;
//            
//        case kSectionPickers:
//            str = @"Pickers Section" ;
//            break ;
//            
//        default:
//            str = nil ;
//            break ;
//    }
//
//    return str ;
//}



//---------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ExternFileCellIdentifier = @"ExternFileCell";
    //static NSString *ICloudCellIdentifier = @"ICloudCell";
    static NSString *DisclosureCellIdentifier = @"DisclosureCell";
    static NSString *PickerCellIdentifier = @"PickerCell";
    //static NSString *ButtonCellIdentifier = @"ButtonCell";
    
    NSString *identifier = nil ; ;
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    section = [self modelSectionForControllerSection:section];
    
    if ( section == kUserSection )
    {
        if ( row == kAutomaticLoginRow ) return automaticLoginCell;
        else if ( row == kCurrentAccountRow ) return currentAccountCell;
        else if ( row == kManageAccountsRow ) return [self manageAccountsCell];
        else if ( row == kSettingsRow ) return [self settingsCell];
    }
    
    if ( section == kSectionLocalStorage )
    {
        if ( row == kRowSourcesCurrentProject ) return [self currentProjectCell];
        identifier = DisclosureCellIdentifier ;
    }
    
//    if ( section == kSectionRedeemedStorage )
//    {
//        if ( row == kRowReddemedSourcesCurrentProject ) return [self currentProjectCell]; 
//        identifier = DisclosureCellIdentifier ;
//    }
    
    if ( section == kSectionRemoteStorage )
    {
        identifier = DisclosureCellIdentifier ;
    }
    
    else if ( section == kSectionExtFileCategories )
    {
        identifier = ExternFileCellIdentifier ;
    }
    
    /*
    else if ( section == kSectionICloud )
    {
        identifier = ICloudCellIdentifier ;
    }*/
    
    else if ( section == kSectionFileServer)
    {
        if ( row == kRowFileServer ) return [self fileServerSwitchCell] ;
        if ( row == kRowFileServerInfo ) return [self fileServerInfoCell] ;
    }
    
    else if ( section == kSectionPickers )
    {
        identifier = PickerCellIdentifier ;
    }
    
    

    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[ControlViewCell alloc] initWithReuseIdentifier:identifier]; 
        //ControlViewCellContentView *cellContentView = [cell cellContentView] ;
        //[[cell label] setTextColor:[ControlViewCell theSystemDarkBlueColor]];
    
        if ( identifier == DisclosureCellIdentifier )
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            RoundedLabel *labelView = [[RoundedLabel alloc] initWithFrame:CGRectMake(0,0,0,0)] ;
    
            [labelView setRgbTintColor:DarkenedRgbColor(SystemDarkerBlueColor, 1.4f)] ;
            [labelView setTextColor:[UIColor whiteColor]] ;
            [labelView setTextAlignment:NSTextAlignmentCenter] ;
            [labelView setFont:[UIFont boldSystemFontOfSize:13]] ;
            [cell setRightView:labelView] ;
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:nil] ;
            [imgView setContentMode:UIViewContentModeCenter] ;
            [imgView setFrame:CGRectMake(0, 0, 40, 40)] ;
            [cell setLeftView:imgView] ;
        }
        
        else if ( identifier == ExternFileCellIdentifier )
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator] ;
            UIImageView *imgView = [[UIImageView alloc] initWithImage:nil] ;
            [imgView setContentMode:UIViewContentModeCenter] ;
            [imgView setFrame:CGRectMake(0, 0, 39, 39)] ;  // imparell perque la imatge te una mida imparell
            [cell setLeftView:imgView] ;
        }
        
        else if ( identifier == PickerCellIdentifier )
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator] ;
        }
        
        /*
        else if ( identifier == ICloudCellIdentifier )
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator] ;
        }
        
        else if ( identifier == ButtonCellIdentifier )
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue]; 
            [cellContentView setCenteredMainText:YES] ;
        }
        */
    }
    
    // Set up the cell...
    
    NSString *name = nil ;
    UIImage *image = nil ;
    
    if ( section == kSectionLocalStorage )
    {
        NSInteger fileCount = 0 ; 
        AppFilesModel *theModel = filesModel() ;
        switch ( row )
        {
            case kRowSourcesCurrentProject:
                // no hauria d'arribar aqui
                break ;
                
            case kRowSourcesCategory :
                name = NSLocalizedString( @"Other Projects", nil ) ;
                image = [UIImage imageNamed:@"FolderDeveloper.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategorySourceFile] count] ;
                break ;
                
            case kRowRecipesCategory :
                name = NSLocalizedString( @"Recipes", nil ) ;
                image = [UIImage imageNamed:@"FolderDeveloper.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryRecipe] count] ;
                break ;
                
            case kRowAssetsCategory :
                name = NSLocalizedString( @"Local Assets", nil ) ;
                image = [UIImage imageNamed:@"FolderDocuments.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryAssetFile] count] ;
                break ;
        }
     
        NSString *tagCountText = [[NSString alloc] initWithFormat:@"%d", fileCount] ;
        [(RoundedLabel*)[cell rightView] setText:tagCountText] ;
    }
    
//    if ( section == kSectionRedeemedStorage )
//    {
//        NSInteger fileCount = 0 ; 
//        AppFilesModel *theModel = filesModel() ;
//        switch ( row )
//        {
//            case kRowReddemedSourcesCurrentProject:
//                // no hauria d'arribar aqui
//                break;
//        
//            case kRowRedeemedSourcesCategory :
//                name = NSLocalizedString( @"Projects", nil ) ;
//                image = [UIImage imageNamed:@"FolderDeveloper.png"] ;
//                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryRedeemedSourceFile] count] ;
//                break ;
//        }
//     
//        NSString *tagCountText = [[NSString alloc] initWithFormat:@"%d", fileCount] ;
//        [(RoundedLabel*)[cell rightView] setText:tagCountText] ;
//    }
    
    else if ( section == kSectionRemoteStorage )
    {
        NSInteger fileCount = 0 ; 
        AppFilesModel *theModel = filesModel() ;
        switch ( row )
        {
            case kRowRemoteSourcesCategory :
                name = NSLocalizedString( @"Projects", nil ) ;
                image = [UIImage imageNamed:@"FolderDeveloper.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryRemoteSourceFile] count] ;
                break ;

            case kRowRemoteAssetsCategory :
                name = NSLocalizedString( @"Assets", nil ) ;
                image = [UIImage imageNamed:@"FolderDocuments.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryRemoteAssetFile] count] ;
                break ;
                
            case kRowRemoteActivationCodesCategory :
                name = NSLocalizedString( @"Activation Codes", nil ) ;
                image = [UIImage imageNamed:@"FolderDocuments.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryRemoteActivationCode] count] ;
                break ;
                
            case kRowRemoteRedemptionsCategory :
                name = NSLocalizedString( @"Redemptions", nil ) ;
                image = [UIImage imageNamed:@"FolderDocuments.png"] ;
                fileCount = [[theModel filesMDArrayForCategory:kFileCategoryRemoteRedemption] count] ;
                break;
            
        }
     
        NSString *tagCountText = [[NSString alloc] initWithFormat:@"%d", fileCount] ;
        [(RoundedLabel*)[cell rightView] setText:tagCountText] ;
    }
    
    else if ( section == kSectionExtFileCategories )
    {
        switch ( row )
        {
            case kRowITunesCategory :
                name = NSLocalizedString( @"iTunes File Sharing", nil ) ;
                image = [UIImage imageNamed:@"ShareITunes.png"] ;
                break ;
                
            case kRowICloudCategory :
                name = NSLocalizedString( @"iCloud", nil ) ;
                //image = no se que ;
                break ;
        }
        [(UIImageView*)[cell leftView] setImage:image] ;
    }
    
    else if ( section == kSectionPickers )
    {
        switch ( row )
        {
            case kRowMusicPlayer :
                name = @"Media Library" ;
                break ;
            
            case kRowMediaPicker :
                name = @"Media Picker" ;
                break ;
            
            case kRowImagePicker :
                name = @"Image Picker" ;
                break ;
        }
    }
    
    /*
    else if ( section == kSectionICloud )
    {
        if ( row == kRowICloud )
        {
            name = NSLocalizedString( @"iCloud", nil ) ;
        }
    }
    */
       
    UIImageView *left = (id)[cell leftView] ;
    if ( left ) [left setImage:image] ;
    [cell setMainText:name] ;  
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView Delegate methods
///////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------

/*
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if ( section == kSourceFilesSection || section == kOtherFilesSection ) return NO ;  // si es YES mou el backgrownd cap a la dreta
    else return NO;
}
*/


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
}




//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    section = [self modelSectionForControllerSection:section];
    
//    if ( section == kSectionRedeemedStorage && !_isShowingRedeemedStorage ) return nil;
//    else if ( section == kSectionRemoteStorage && !_isShowingRemoteStorage ) return nil;
    
    if ( section == kUserSection ) return [self messageViewUser];
    else if ( section == kSectionLocalStorage ) return [self messageViewLocalStorage];
//    else if ( section == kSectionRedeemedStorage ) return [self messageViewRedeemedStorage];
    else if ( section == kSectionRemoteStorage ) return [self messageViewRemoteStorage];
    else if ( section == kSectionExtFileCategories) return [self messageExtFilesView] ;
    //else if ( section == kSectionICloud ) return [self messageICloudView] ;
    else if ( section == kSectionFileServer ) return [self messageFileServerView] ;
    
    
    return nil ;
}

//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //CGFloat width = tableView.bounds.size.width;
    
    section = [self modelSectionForControllerSection:section];
    
    CGFloat height = 0;
    if ( section == kUserSection ) height = [[self messageViewUser] getMessageHeight] ;
    else if ( section == kSectionLocalStorage ) height = [[self messageViewLocalStorage] getMessageHeight] ;
//    else if ( section == kSectionRedeemedStorage /*&& _isShowingRedeemedStorage*/) height = [[self messageViewRedeemedStorage] getMessageHeight] ;
    else if ( section == kSectionRemoteStorage /*&& _isShowingRemoteStorage*/) height = [[self messageViewRemoteStorage] getMessageHeight] ;
    else if ( section == kSectionExtFileCategories ) height = [[self messageExtFilesView] getMessageHeight] ;
    //else if ( section == kSectionICloud ) return [[self messageICloudView] messageHeight] ;
    else if ( section == kSectionFileServer ) height = [[self messageFileServerView] getMessageHeight] ;
    
    return height;
}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSInteger section = [indexPath section] ;
    NSInteger row = [indexPath row] ;
    
    section = [self modelSectionForControllerSection:section];
    
    UIViewController *pushViewController = nil ;
    UIViewController *modalViewController = nil ;
    //BOOL isEditing = [tableView isEditing] ;
    FileCategory fileCategory = kFileCategoryUnknown ;
    
    if ( section == kUserSection )
    {
        if ( row == kCurrentAccountRow )
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            LoginWindowControllerC *loginWin = [self loginWindow];
            [loginWin setCurrentAccount:[usersModel() currentUserName]];
            [loginWin showAnimated:YES] ;
            return ;
        }
        else if ( row == kManageAccountsRow )
        {
            pushViewController = [[ManageAccountsController alloc] init] ;
        }
        else if ( row == kSettingsRow )
        {
            pushViewController = [[SWSettingsViewController alloc] init];
        }
    }
        
    else if ( section == kSectionLocalStorage )
    {
        if ( row == kRowSourcesCurrentProject )
        {
            SWDocument *document = [filesModel() currentDocument];
            pushViewController = [[SWCurrentProjectViewController alloc] initWithFileCategory:kFileCategorySourceFile forDocument:document];
        }
        else
        {
            switch ( row )
            {
                case kRowSourcesCategory : fileCategory = kFileCategorySourceFile ; break ;
                case kRowRecipesCategory : fileCategory = kFileCategoryRecipe ; break ;
                case kRowAssetsCategory : fileCategory = kFileCategoryAssetFile ; break ;
            }
    
            SWDocument *document = [filesModel() currentDocument];
            pushViewController = [[SWAuxiliarFilesViewController alloc] initWithFileCategory:fileCategory forDocument:document];
        }
    }
    
//    else if ( section == kSectionRedeemedStorage )
//    {
//        if ( row == kRowReddemedSourcesCurrentProject )
//        {
//            SWDocument *document = [filesModel() currentDocument];
//            pushViewController = [[SWCurrentProjectViewController alloc] initWithFileCategory:kFileCategoryRedeemedSourceFile forDocument:document];
//        }
//        else
//        {
//            switch ( row )
//            {
//                case kRowRedeemedSourcesCategory : fileCategory = kFileCategoryRedeemedSourceFile ; break ;
//                //case kRowEmbeddedAssetsCategory : fileCategory = kFileCategoryEmbeddedAssetFile ; break ;
//            }
//        
//            SWDocument *document = [filesModel() currentDocument];
//            pushViewController = [[SWAuxiliarFilesViewController alloc] initWithFileCategory:fileCategory forDocument:document];
//        }
//    }

    else if ( section == kSectionRemoteStorage )
    {
        switch ( row )
        {
            case kRowRemoteSourcesCategory : fileCategory = kFileCategoryRemoteSourceFile ; break ;
            case kRowRemoteAssetsCategory : fileCategory = kFileCategoryRemoteAssetFile ; break ;
            case kRowRemoteActivationCodesCategory : fileCategory = kFileCategoryRemoteActivationCode ; break ;
            case kRowRemoteRedemptionsCategory : fileCategory = kFileCategoryRemoteRedemption ; break ;
        }
        
        pushViewController = [[SWAuxiliarFilesViewController alloc] initWithFileCategory:fileCategory forDocument:nil];
    }
    
    else if ( section == kSectionExtFileCategories )
    {
        switch ( row )
        {
            case kRowITunesCategory : fileCategory = kExtFileCategoryITunes ; break ;
            case kRowICloudCategory : fileCategory = kExtFileCategoryICloud ; break ;
        }
        //pushViewController = [[FileViewControllerBase alloc] initWithFileCategory:fileCategory] ;
        pushViewController = [[SWAuxiliarFilesViewController alloc] initWithFileCategory:fileCategory forDocument:nil] ;
    }
    
    else if ( section == kSectionPickers )
    {
        switch ( row )
        {
            case kRowMusicPlayer :
                NSLog( @"Media Library" ) ;
                [self showMediaLibrary] ;
                break ;
            
            case kRowMediaPicker :
                NSLog( @"Media Picker" ) ;
                modalViewController = [[MPMediaPickerController alloc] init] ;
                break ;
            
            case kRowImagePicker :
            {
                NSLog( @"Image Picker" ) ;
                UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init] ;
                [pickerViewController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary] ;
                [pickerViewController setAllowsEditing:YES] ;
                break ;
            }
        }
    }
    
    /*
    else if ( section == kSectionICloud )
    {
        if ( row == kRowICloud )
        {
 //           viewController = [[ICloudFilesViewController alloc] init] ;
        }
    }
    */
    
    // si hem creat un controlador fem push i l'alliverem
    if ( pushViewController != nil )
    {
        [self _pushViewController:pushViewController];
    }
    
    else if ( modalViewController != nil )
    {
      //  [self presentModalViewController:modalViewController animated:YES] ;
        [self presentViewController:modalViewController animated:YES completion:NULL] ;
    }
}





- (void)_pushViewController:(UIViewController*)pushViewController
{
    UINavigationController *navController = nil;
    SWRevealViewController *revealController = nil;
    
    if ( nil != (navController = [self navigationController]) )
    {
        [navController pushViewController:pushViewController animated:YES];
    }
    
    else
    if ( nil != (revealController = [self revealViewController] ) )
    {
        UINavigationController *navContr = [[UINavigationController alloc] initWithRootViewController:pushViewController];
        [revealController setFrontViewController:navContr animated:YES];
        [navContr.navigationBar addGestureRecognizer:[revealController panGestureRecognizer]];
        
        UIBarButtonItem *revealItem;
        UIImage *revealImage = [UIImage imageNamed:@"reveal-icon.png"];
        if ( IS_IOS7 )
        {
            revealItem = [[UIBarButtonItem alloc] initWithImage:revealImage style:UIBarButtonItemStylePlain
                target:revealController action:@selector(revealToggle:)];
        }
        else
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0,0,40,40);
            [button setImage:revealImage forState:UIControlStateNormal];
            [button setShowsTouchWhenHighlighted:YES];
            [button addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
            revealItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
            
//            UIBarButtonItem *revealItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
            
        [pushViewController.navigationItem setLeftBarButtonItem:revealItem];
    }
}



//#pragma mark imagePicker delegate
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//    NSData *imageData = UIImagePNGRepresentation(image);
//    
//    NSString *fileName = @"Photo.jpg";
//    NSString *tmpFilePath = [filesModel() temporaryFilePathForFileName:fileName];
//    [imageData writeToFile:tmpFilePath atomically:YES];
//    
//    NSError *error = nil;
//    [filesModel() moveFromTemporaryToCategory:kFileCategoryAssetFile forFile:fileName error:&error];
//
//    [_popoverController dismissPopoverAnimated:YES];
//    _popoverController = nil;
//}
//
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [_popoverController dismissPopoverAnimated:YES];
//    _popoverController = nil;
//}
//
//
//#pragma mark popoverController delegate
//
//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
//{
//    _popoverController = nil;
//}


@end

