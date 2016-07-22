//
//  SWAppDelegate.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/2/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "objc/runtime.h"
#import <dispatch/dispatch.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "SWAppDelegate.h"

#import "AppModelFilesEx.h"
#import "AppModelActivationCodes.h"
#import "AppModelDocument.h"
#import "AppModelSource.h"
#import "AppModelFileServer.h"

//#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"
#import "UserDefaults.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"

//#import "SWBlockAlertview.h"

#import "SWToolbarViewController.h"
#import "SWRearViewController.h"
#import "SWDocumentController.h"
#import "SWImageManager.h"
#import "SWErrorPresenterViewController.h"
#import "SWRedeemViewController.h"
#import "EditAccountTableController.h"

#import "SWFloatingPopoverController.h"

#import "LoginWindowControllerC.h"

#import "SWPasteboardTypes.h"

#import "SWAlertCenter.h"
#import "SWEventCenter.h"
#import "SWBlockAlertView.h"

#import "SWRevealController.h"
#import "SWFloatingPopoverController.h"
#import "SWTableSectionHeaderView.h"
#import "SWModelBrowserController.h"

#import "SWFloatingPopoverView.h"
#import "SWNavBarTitleView.h"

#import "UIViewController+SWSendMailControllerPresenter.h"

#import "SWKeyboardListener.h"
#import "URLDownloadObject.h"

#import "SWColor.h"


// comment out one of the two
#define NSLog1(...) {}
//#define NSLog1(args...) NSLog(args)

#define DEBUG 0



NSUInteger DeviceSystemMajorVersion(void);

NSUInteger DeviceSystemMajorVersion(void)
{
   static NSUInteger _deviceSystemMajorVersion = -1;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^
   {
       _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] firstObject] intValue];
   });
   return _deviceSystemMajorVersion;
}



UIUserInterfaceIdiom DeviceUserInterfaceIdiom(void);

UIUserInterfaceIdiom DeviceUserInterfaceIdiom(void)
{
   static UIUserInterfaceIdiom _deviceUserInterfaceIdiom = -1;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^
   {
       _deviceUserInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
   });
   return _deviceUserInterfaceIdiom;
}



@interface SWAppDelegate() <AppFilesModelObserver, AppModelDocumentObserver,SWFloatingPopoverControllerDelegate,URLDownloadObjectDelegate,UIPopoverControllerDelegate, AVAudioSessionDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate,LoginWindowControllerDelegate,SWAppCloudKitUserObserver >
@end

@interface SWAppDelegate()

@property (nonatomic,strong) NSURL *openUrl ;
@property (nonatomic,strong) UILocalNotification *openLocalNotif ;
//@property (nonatomic,retain) UIWindow *window;

//@property (nonatomic, readonly) SWRevealViewController *grandRootViewController;   // not used should be nil
@property (nonatomic, readonly) SWRevealViewController *detailRevealViewController;
@property (nonatomic, readonly) SWToolbarViewController *rootViewController;
@property (nonatomic, readonly) LoginWindowControllerC * loginController;
@property (nonatomic, readonly) SWDocumentController *documentController;

@end


@implementation SWAppDelegate
{
    UINavigationController *_documentNavigator;
    BOOL isOpeningDocument;
    BOOL _projectValidated;
    BOOL aknowledmentPending ;
    
    NSTimer *_integratorTimer;
    NSTimeInterval _nextTimeInterval;
    //SWBlockAlertView * _timerAlertView;
    
    UIBackgroundTaskIdentifier bgTask;
    
    
    BOOL firstBackgroundWarning ;
    BOOL secondBackgroundWarning ;
    NSTimer *waitReachabilityTimer ;
    NSTimer *backgroundTimer ;
    
    NSTimer *repeatVibrationTimer ;
    NSTimer *repeatTickTimer ;
    int playVibrateCount ;
    int appState ;
    SystemSoundID systemSoundId;
    AVAudioPlayer *foreverPlayer ;
    AVAudioPlayer *tickPlayer ;
    AVPlayer *userPlayer ;

    
    SWFloatingPopoverController *_projectControllerFPopover;
    CGPoint _projectControllerPosition;

    UIPopoverController *_projectControllerPopover;

}

enum AppState
{
    kSWAppStateActive = 0,
    kSWAppStateResigned,
    kSWAppStateBakground,
} ;

@synthesize window = _window;
//@synthesize openUrl = _openUrl;



- (void)setupAppearanceProxies
{

    UIColor *color = DarkenedUIColorWithRgb(SystemDarkerBlueColor,1.2f);
    //UIColor *color = DarkenedUIColorWithRgb(SystemDarkerBlueColor,0.5f);
    //UIColor *color = [UIColor colorWithWhite:0.5 alpha:1.0];    // Colors
    
    //UIColor *fcolor = UIColorWithRgb(OpacifiedRgbColor(DarkenedRgbColor(SystemDarkerBlueColor, 0.5f), 0.7f));
    UIColor *tcolor = UIColorWithRgb(DarkenedRgbColor(SystemDarkerBlueColor, 1.4f));   // + clar
    UIColor *ncolor = UIColorWithRgb(DarkenedRgbColor(SystemDarkerBlueColor, 0.7f));   // + fosc
    UIColor *hcolor = UIColorWithRgb(DarkenedRgbColor(SystemDarkerBlueColor, 1.0f));   // normal
    UIColor *wcolor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f];
    //UIColor *hhcolor = UIColorWithRgb(DarkenedRgbColor(TheSystemDarkBlueTheme, 2.0f));
    UIColor *wwcolor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    UIColor *wwwcolor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    //UIColor *bcolor = [UIColor colorWithRed:0.5 green:0.3 blue:0.3 alpha:1.0];
    
    // Default appearance
    
    if ( IS_IOS7 )
    {
        
//        [[UINavigationBar appearance] setBarTintColor:hcolor];
//        [[UINavigationBar appearance] setTintColor:ncolor];
//        
//        [[UIToolbar appearance] setBarTintColor:hcolor];
//        [[UIToolbar appearance] setTintColor:ncolor];

      [[SWNavBarTitleView appearance] setTintsColor:hcolor];
        
    }
    else
    {
        [[UINavigationBar appearance] setTintColor:color];
        [[UIToolbar appearance] setTintColor:color];
        [[UISearchBar appearance] setTintColor:color];
    }

   // [[UISegmentedControl appearance] setTintColor:color];
    //[[SWFloatingPopoverView appearance] setTintsColor:color] ;
    //[[SWNavBarTitleView appearance] setTintColor:color] ;
    
    // Clases que implementen el  UIAppearanceContainer protocol
    //Class TC = [SWToolbarViewController class];
    Class FP = [SWFloatingPopoverController class];
    Class MB = [SWModelBrowserController class];
    Class RC = [SWRevealController class];
    Class NC = [UINavigationController class];
    //Class PC = [UIPopoverController class];
    Class NBV = [UINavigationBar class];
    Class TBV = [UIToolbar class];
    
    

    
    // FloatingPopover
//<<<<<<< HEAD
    
    [[SWFloatingPopoverView appearanceWhenContainedIn:FP, nil] setTintsColor:ncolor] ;
//=======
//    [[SWFloatingPopoverView appearanceWhenContainedIn:FP, nil] setTintsColor:ncolor] ;
//    [[UINavigationBar appearanceWhenContainedIn:FP, nil] setTintColor:ncolor];
//    [[UISegmentedControl appearanceWhenContainedIn:FP, nil] setTintColor:ncolor];
//    [[SWTableSectionHeaderView appearanceWhenContainedIn:FP, nil] setTintsColor:tcolor/*fcolor*/];
//>>>>>>> roundedTextView
    
    if ( IS_IOS7 )
    {
        [[UINavigationBar appearanceWhenContainedIn:FP, nil] setBarTintColor:ncolor];
       // [[UINavigationBar appearanceWhenContainedIn:FP, nil] setTintColor:wcolor];
        [[SWNavBarTitleView appearanceWhenContainedIn:FP, nil] setTintsColor:wcolor];
    }
    else
    {
        [[UINavigationBar appearanceWhenContainedIn:FP, nil] setTintColor:ncolor];
        //[[UISegmentedControl appearanceWhenContainedIn:FP, nil] setTintColor:ncolor];
    }

//    [[UINavigationBar appearanceWhenContainedIn:FP, nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:wcolor,UITextAttributeTextShadowColor:[UIColor blackColor]}];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor blackColor]];
    [[UINavigationBar appearanceWhenContainedIn:FP, nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:wcolor,NSShadowAttributeName:shadow}];
    
    [[SWTableSectionHeaderView appearanceWhenContainedIn:FP, nil] setTintsColor:tcolor/*fcolor*/];
    
    // RevealController
//<<<<<<< HEAD
    
    [[SWTableSectionHeaderView appearanceWhenContainedIn:RC, nil] setTintsColor:tcolor];
  
    // FloatingPopover + RevealController + ModelBrowser
    
    [[SWTableSectionHeaderView appearanceWhenContainedIn:MB,RC,FP, nil] setTintsColor:tcolor /*[UIColor darkGrayColor]*/];
    
    if ( IS_IOS7 )
    {
    }
    else
    {
        [[UISearchBar appearanceWhenContainedIn:MB,RC,FP, nil] setTintColor:ncolor];
    }
    
//    // PopoverController + RevealController + ModelBrowser
//    
//    [[SWTableSectionHeaderView appearanceWhenContainedIn:MB,RC,PC, nil] setTintColor:tcolor /*[UIColor darkGrayColor]*/];
//    [[UISearchBar appearanceWhenContainedIn:MB,RC,PC, nil] setTintColor:ncolor];
//=======
//    [[SWTableSectionHeaderView appearanceWhenContainedIn:RC, nil] setTintsColor:tcolor];
//  
//    // FloatingPopover + RevealController + ModelBrowser
//    [[SWTableSectionHeaderView appearanceWhenContainedIn:MB,RC,FP, nil] setTintsColor:tcolor /*[UIColor darkGrayColor]*/];
//    [[UISearchBar appearanceWhenContainedIn:MB,RC,FP, nil] setTintColor:ncolor];
//    
//    // PopoverController + RevealController + ModelBrowser
//    [[SWTableSectionHeaderView appearanceWhenContainedIn:MB,RC,PC, nil] setTintsColor:tcolor /*[UIColor darkGrayColor]*/];
//    [[UISearchBar appearanceWhenContainedIn:MB,RC,PC, nil] setTintColor:ncolor];
//>>>>>>> roundedTextView

    //
    // FloatingPopover + RevealController + NavigationController
    //
    if ( IS_IOS7 )
    {
        [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setBarTintColor:wwcolor];
        [[UIToolbar appearanceWhenContainedIn:NC,RC,FP, nil] setBarTintColor:wwcolor];
//        [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:hcolor,UITextAttributeTextShadowColor:[UIColor whiteColor]}];
        shadow.shadowColor = [UIColor whiteColor];
        [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:hcolor,NSShadowAttributeName:shadow}];
    }
    else
    {
        [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setTintColor:wwcolor];
        [[UIToolbar appearanceWhenContainedIn:NC,RC,FP, nil] setTintColor:wwcolor];
        shadow.shadowColor = [UIColor whiteColor];
        [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:hcolor,NSShadowAttributeName:shadow}];
    }

    [[SWNavBarTitleView appearanceWhenContainedIn:NC,RC,FP, nil] setTintsColor:hcolor];   // ncolor
    
//<<<<<<< HEAD
//=======
//    // FloatingPopover + RevealController + NavigationController
//    [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setTintColor:hhcolor];
//    [[UINavigationBar appearanceWhenContainedIn:NC,RC,FP, nil] setTitleTextAttributes:@{UITextAttributeTextColor:hcolor,UITextAttributeTextShadowColor:[UIColor whiteColor]}];
//    [[SWNavBarTitleView appearanceWhenContainedIn:NC,RC,FP, nil] setTintsColor:ncolor];  // <- hcolor
//    [[UIToolbar appearanceWhenContainedIn:NC,RC,FP, nil] setTintColor:hhcolor];
//>>>>>>> roundedTextView
    
    
    //
    // FloatingPopover + RevealController + NavigationController + NavigationBar
    //
    
    if ( IS_IOS7 )
    {
//        [[UINavigationBar appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTitleTextAttributes:@{
//        UITextAttributeTextColor:[UIColor redColor],
//        UITextAttributeTextShadowColor:[UIColor whiteColor],
//        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}];  // <- normal
    
//    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTitleTextAttributes:@{
//        UITextAttributeTextColor:[UIColor grayColor],
//        UITextAttributeTextShadowColor:[UIColor whiteColor],
//        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}
//        forState:UIControlStateHighlighted]; // <- highlitgted
    }
    else
    {
    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTintColor:wwwcolor];
    
//    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTitleTextAttributes:@{
//        NSForegroundColorAttributeName:ncolor,
//        UITextAttributeTextShadowColor:[UIColor whiteColor],
//        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}
//        forState:UIControlStateNormal];  // <- normal
//    
//    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTitleTextAttributes:@{
//        NSForegroundColorAttributeName:[UIColor grayColor],
//        UITextAttributeTextShadowColor:[UIColor whiteColor],
//        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}
//        forState:UIControlStateHighlighted]; // <- highlitgted
        
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTitleTextAttributes:@{
        NSForegroundColorAttributeName:ncolor,
        NSShadowAttributeName:shadow}
        forState:UIControlStateNormal];  // <- normal
    
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC,FP, nil] setTitleTextAttributes:@{
        NSForegroundColorAttributeName:[UIColor grayColor],
        NSShadowAttributeName:shadow}
        forState:UIControlStateHighlighted]; // <- highlitgted
    }
    
    
    // FloatingPopover + RevealController + NavigationController + ToolBar
    
    if ( IS_IOS7 )
    {
    }
    else
    {
        [[UIBarButtonItem appearanceWhenContainedIn:TBV, NC,RC,FP, nil] setTintColor:ncolor];
    }
    
//    // PopoverController + RevealController + NavigationController
//    
//    [[UINavigationBar appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:wwcolor];
//    [[UINavigationBar appearanceWhenContainedIn:NC,RC,PC, nil] setTitleTextAttributes:@{UITextAttributeTextColor:hcolor,UITextAttributeTextShadowColor:[UIColor whiteColor]}];
//    [[SWNavBarTitleView appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:hcolor];
//    [[UIToolbar appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:wwcolor];
//    
//<<<<<<< HEAD
//    [[UIBarButtonItem appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:tcolor];
//=======
////    
////    // FloatingPopover + RevealController + NavigationController
////    [[UINavigationBar appearanceWhenContainedIn:NC,RC, nil] setTintColor:hhcolor];
////    [[UINavigationBar appearanceWhenContainedIn:NC,RC, nil] setTitleTextAttributes:@{UITextAttributeTextColor:hcolor,UITextAttributeTextShadowColor:[UIColor whiteColor]}];
////    [[SWNavBarTitleView appearanceWhenContainedIn:NC,RC, nil] setTintColor:ncolor];  // <- hcolor
////    [[UIToolbar appearanceWhenContainedIn:NC,RC, nil] setTintColor:hhcolor];
////
////    
////    // FloatingPopover + RevealController + NavigationController + NavigationBar
////    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC, nil] setTintColor:hhhcolor];
////    
////    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC, nil] setTitleTextAttributes:@{
////        UITextAttributeTextColor:ncolor,    // <- hcolor
////        UITextAttributeTextShadowColor:[UIColor whiteColor],
////        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}
////        forState:UIControlStateNormal];
////    
////    [[UIBarButtonItem appearanceWhenContainedIn:NBV, NC,RC, nil] setTitleTextAttributes:@{
////        UITextAttributeTextColor:[UIColor grayColor],    // <- hcolor
////        UITextAttributeTextShadowColor:[UIColor whiteColor],
////        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}
////        forState:UIControlStateHighlighted];
////    
////    // FloatingPopover + RevealController + NavigationController + ToolBar
////    [[UIBarButtonItem appearanceWhenContainedIn:TBV, NC,RC, nil] setTintColor:ncolor];     // <- hcolor
////    
////    
////    
//    
//    
//    
//    
//    
//    
//    
//    
////    // PopoverController + NavigationController + NavigationController
////    [[UINavigationBar appearanceWhenContainedIn:NC,NC,PC, nil] setTintColor:hhcolor];
////    [[UINavigationBar appearanceWhenContainedIn:NC,NC,PC, nil] setTitleTextAttributes:@{UITextAttributeTextColor:hcolor,UITextAttributeTextShadowColor:[UIColor whiteColor]}];
////    [[SWNavBarTitleView appearanceWhenContainedIn:NC,NC,PC, nil] setTintColor:hcolor];
////    [[UIToolbar appearanceWhenContainedIn:NC,NC,PC, nil] setTintColor:hhcolor];
////    
////    [[UIBarButtonItem appearanceWhenContainedIn:NC,NC,PC, nil] setTintColor:tcolor];
//    
//    
//    // PopoverController + RevealController + NavigationController
//    [[UINavigationBar appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:hhcolor];
//    [[UINavigationBar appearanceWhenContainedIn:NC,RC,PC, nil] setTitleTextAttributes:@{UITextAttributeTextColor:hcolor,UITextAttributeTextShadowColor:[UIColor whiteColor]}];
//    [[SWNavBarTitleView appearanceWhenContainedIn:NC,RC,PC, nil] setTintsColor:hcolor];
//    [[UIToolbar appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:hhcolor];
//    
//    [[UIBarButtonItem appearanceWhenContainedIn:NC,RC,PC, nil] setTintColor:tcolor];
//    
//    
//
//    
//    
//    
//    //[[UIBarButtonItem appearanceWhenContainedIn:NC,NC,FP, nil]
//    //    setTitleTextAttributes:@{UITextAttributeTextColor:ncolor} forState:UIControlStateNormal];
//    
//    //[[UISearchBar appearanceWhenContainedIn:FP, nil] setTintColor:[UIColor darkGrayColor]];
//>>>>>>> roundedTextView
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // creem una finestra
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    
    // set default appearance
    [self setupAppearanceProxies];
    
    [self _establishMainWindow] ;
    //[self _establishDocumentController];
    
    [_window makeKeyAndVisible] ;
    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
    
    
    NSError *error = nil ;
    BOOL filesDirExists = [filesModel() projectDirectoryExists] ;
    
    //BOOL loadResult = [[usersModel() localUsersArray] count] > 0 ;  // sempre torna YES !!
    BOOL loadResult = YES;
    
    BOOL firstLaunch = (loadResult == NO || filesDirExists == NO) ;
    
    if ( firstLaunch )
    {
        // el métode loadProfilesFromDiskOutError haura creat els comptes per defecte en el model
        // de tota manera esborrem tots els fitxer perque l'error de lectura pot ser per una inconsistència
        // o intent d'atac
        BOOL creaDirsResult = [filesModel() createApplicationSupportDirectory];
        if ( creaDirsResult == NO )
        {
            NSString *message = NSLocalizedString(@"CouldNotCreateApplicationSupportDir", nil);
            [self showAlertViewWithTitle:NSLocalizedString( @"Error", nil ) message:message tag:3];
            return YES ;
        }
        
//        // tot i que els defaults estableixen automàticament l'usuari per defecte, el re-establim
//        // per si venim de una inconsistència en el fitxer de profile
//        [usersModel() setCurrentUserId:SWDefaultUserId];
//        
//        // establim el valor per defecte de automatic login (quedarà salvat en els profiles)
//        BOOL saveResult = [usersModel() setAutomaticLogin:YES error:&error];

        BOOL saveResult = YES;
        BOOL syncResult = [defaults() synchronize];
        
        // si no podem guardar, malu! no temim gaire a fer...
        if ( saveResult == NO || syncResult == NO )
        {
            NSString *message = [NSString stringWithFormat:@"%@\n%@", 
                NSLocalizedString(@"CouldNotCreateDefaultSettings", nil),
                (error ? [error localizedDescription] : @"" )  ] ;
            [self showAlertViewWithTitle:NSLocalizedString( @"Error", nil ) message:message tag:3];
            return YES ;
        }   
    
        // Creem un nou directori per els fitxers i hi copiem els exemples
        BOOL creaResult = [filesModel() createFilesDirectory] ;
        BOOL copyResult = [filesModel() copyFileTemplates];
        
        // si no podem crear els templates, malu! no temim gaire a fer...
        if ( creaResult == NO || copyResult == NO )
        {
            NSString *message = NSLocalizedString(@"CouldNotCreateDefaultFiles", nil) ;
            [self showAlertViewWithTitle:NSLocalizedString( @"Error", nil ) message:message tag:3];
            return YES ;
        }
        
        // Hem Esborrat tots els documents i copiat els exemples, avisem del que s'ha fet
        NSString *welcomeString = (HMiPadDev?@"WelcomeMessage":@"WelcomeMessageR");
        NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(welcomeString, nil), @AppName ] ;
        [self showAlertViewWithTitle:NSLocalizedString(@"Welcome", nil) message:message tag:HMiPadDev?2:1];
        
        // posem la versio actual
        [defaults() setCurrentVersion:SWVersion];
        
        // carreguem el projecte per defecte
    }
    
    else  // no es el primer cop que s'obra
    {
        [filesModel() maybeCreateAuxiliarDirectories];
        int preVersion = [defaults() currentVersion];
        if ( preVersion != SWVersion ) // si estem en un update o upgrade
        {
            // actualitzem a la versio actual
            [defaults() setCurrentVersion:SWVersion];
            
            if ( HMiPadDev )
            {
                NSString *message = NSLocalizedString(@"AskUpdateExamples", nil) ;
                [self showAlertViewWithTitle:NSLocalizedString( @"Load Example Projects", nil ) message:message tag:4];
                // [filesModel() copyFileTemplates] ;
            }
        }
        
        // la versio existent fins ara no tenia iCloud, vol dir que haurem de migrar
        if ( preVersion > 0 && preVersion < SWMinVersionICloud )
        {
            // migra el identificador de app
            [cloudKitUser() migrateIdentifierForApp];
            
            // necesita presentar el asistent de migracio
            [defaults() setPendingMigrate:YES];
        }
    }

//    if ( launchOptions )
//    {
//       // [self setLaunchOptions:launchOpts] ;
//       NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
//       [self setOpenUrl:url] ;
//    }


    
    // Start Keyboard observation
    [SWKeyboardListener sharedInstance];
    
    // Start cloudkit user change notifications
    [cloudKitUser() startICloudAvailabilityNotifications];
    
    [cloudKitUser() addObserver:self];
    
//    // set default appearance
//    [self setupAppearanceProxies];
//    
//    [self _establishMainWindow] ;
//    //[self _establishDocumentController];
//    
//    [_window makeKeyAndVisible] ;

    [filesModel().amActivationCodes beginTransactionObservations];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    if ( DEBUG ) NSLog(@"AppDelegate: Application will resign active") ;
    appState = kSWAppStateResigned ;
    
    [self setPlayAlarmVibration:0 withSound:NO] ;
    
    // tanquem el servidor de arxius
    [filesModel().fileServer stopHttpServer] ;
    //[window setHidden:YES] ;
    
//    BOOL monitoringState = [defaults() monitoringState] ;
//    if ( monitoringState )
    {
        BOOL alwaysConnected = [defaults() keepConnectedState] ;
        if ( alwaysConnected )
        {
            [self startBackgroundProcessIfNone] ;
        }
        else
        {
            [self _clausureSources];
        }
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{

    if ( DEBUG ) NSLog(@"AppDelegate: Application did enter background") ;
    appState = kSWAppStateBakground ;
    
    [self _saveDocument];
    
    [defaults() synchronize] ;
    
    
    BOOL backgroundConditions = [defaults() backgroundConditionsAreMet] ;
    if ( backgroundConditions )
    {
        [self setPlayBackgroundTick:YES] ;
    }

    [[SWImageManager defaultManager] save];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
     if ( DEBUG ) NSLog(@"AppDelegate: Application will enter foreground") ;
    appState = kSWAppStateResigned ;
    
    [self stopBackgroundProcessIfAny] ;
    [self setPlayBackgroundTick:NO] ;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ( DEBUG ) NSLog(@"AppDelegate: Application did become active") ;
    appState = kSWAppStateActive ;
    
    [cloudKitUser() checkICloudAvailabilityNowWithForce:YES];
    
    [self stopBackgroundProcessIfAny] ;
    [self setPlayAlarmVibration:0 withSound:NO] ;

#if !UseCloudKit
    if ( ! [usersModel() automaticLogin] )
    {
        if ( _loginController == nil )
            _loginController = [[LoginWindowControllerC alloc] init];
        
        [_loginController setDelegate:self];
        [_loginController setCancelForbiden:YES];
        NSString *userName = [usersModel() currentUserName];
        [_loginController setUsername:userName];
        [_loginController setCurrentAccount:userName];
        [_loginController showAnimated:NO completion:nil] ;
        [self _doApplicationDidBecomeActiveOnLoginScreen];
    }
    else
    {
        [self _doApplicationDidBecomeActive] ;
    }
#endif

#if UseCloudKit

    [self _doApplicationDidBecomeActive] ;
#endif

}


- (void)applicationWillTerminate:(UIApplication *)application
{

    [defaults() synchronize] ;
    [[SWImageManager defaultManager] save];
    [self _closeDocument];
    
//    ModelNotificationCenter *mnc = [ModelNotificationCenter defaultCenter];
//    [mnc removeObserver:self];


    [filesModel().amActivationCodes endTransactionObservations];



    [self _invalidateIntegratorTimer];
    
    [filesModel().files removeObserver:self];
    [filesModel().fileDocument removeObserver:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    [self setApplicationBadge:0];
}


//--------------------------------------------------------------------------------------------  
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url 
            sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    _openUrl = url ;
    return YES ;
}

//--------------------------------------------------------------------------------------------  
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self setOpenLocalNotif:notification] ;
}


//- (NSUInteger)applicationV:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    SWDocumentModel *docModel = _documentController.docModel;
//    if ( docModel != nil )
//    {
//        SWProjectAllowedOrientation allowedOrientation = docModel.allowedOrientation;
//        
//        if ( allowedOrientation == SWProjectAllowedOrientationPortrait )
//            return UIInterfaceOrientationMaskPortrait;
//        
//        if ( allowedOrientation == SWProjectAllowedOrientationLandscape )
//            return UIInterfaceOrientationMaskLandscape;
//    }
//
//    return UIInterfaceOrientationMaskAll;
//}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    SWDocumentModel *docModel = _documentController.docModel;
    if ( docModel != nil )
    {
        SWProjectAllowedOrientation allowedOrientation = [docModel allowedOrientationForCurrentIdiom];
        
        if ( allowedOrientation == SWProjectAllowedOrientationPortrait )
            return UIInterfaceOrientationMaskPortrait;
        
        if ( allowedOrientation == SWProjectAllowedOrientationLandscape )
            return UIInterfaceOrientationMaskLandscape;
    }

    return UIInterfaceOrientationMaskAll;
}

#pragma mark public

//- (SWDocument*)currentDocument
//{
//    SWDocument *document = _documentController.document;
//    return document;
//}


#pragma mark convenience

#if !UseCloudKit
- (void)_doApplicationDidBecomeActiveOnLoginScreen
{
    if ( _openUrl )
    {
        // nomes procesem els schemes, les importacions d'arxiu i redemptions es deixen per despres de login
        if ( ! [_openUrl isFileURL] )
        {
            [self _processScheme];
            _openUrl = nil;
        }
    }
}
#endif

//--------------------------------------------------------------------------------------------  
- (void)_doApplicationDidBecomeActive
{
    if ( _openUrl )
    {
        if ( [_openUrl isFileURL] )
            [self _processFileUrl];
        else 
            [self _processScheme];

        _openUrl = nil;
    }
    
    
//    // migrem si cal
//    if ( [defaults() pendingMigrate] )  no aqui
//    {
//        //migrate;
//       // [_rootViewController presentMigrationAssistantController]
//        [UIViewController presentMigrationAssistantController];
//    }
    
    if ( _documentController.docModel == nil )
    {
        [self _openDocument];
    }
    else
    {
        [self _igniteSources];
        [self _validateProject];  // Aqui
    }

   // [filesModel().amActivationCodes beginTransactionObservations];  comentat i mogut a didFinishLaunching
}


////----------------------------------------------------------------------------------------
//// Crea i mostra un alertView amb el missatge especificat especificant self com a delegat
//// Evita la sobreposició de alertViews amb els flags aknowledmentPending i settingsPending
//- (void)showAlertViewWithTitleV:(NSString *)title message:(NSString *)msg tag:(NSInteger)type
//{
//    if ( aknowledmentPending ) return ;
//    if ( _loginController ) return ;
//    
//    UIAlertView *alertView = nil ;
//    
//    switch ( type )
//    {
//        case 1: // avis inicial de HMI View
//        {
//            alertView = [[UIAlertView alloc] initWithTitle:title
//                                                message:msg
//                                                delegate:self 
//                                                cancelButtonTitle:nil 
//                                                otherButtonTitles:NSLocalizedString( @"Open Application Panel", nil ), nil ] ;
//            break ;
//        }
//        
//        case 2: // errors amb un simple OK
//        {
//            alertView = [[UIAlertView alloc] initWithTitle:title
//                                                message:msg
//                                                delegate:self 
//                                                cancelButtonTitle:nil
//                                                otherButtonTitles:NSLocalizedString( @"OK", nil ), nil ] ;
//            break ;
//        }
//        
//        case 3: // errors que no requereixen cap continuació excepte tancar la aplicacio
//        {
//            alertView = [[UIAlertView alloc] initWithTitle:title
//                                                message:msg
//                                                delegate:self 
//                                                cancelButtonTitle:nil 
//                                                otherButtonTitles:nil ] ;
//            break ;
//        }
//        
//        case 4: // ask download examples
//        {
//            alertView = [[UIAlertView alloc] initWithTitle:title
//                                                message:msg
//                                                delegate:self 
//                                                cancelButtonTitle:NSLocalizedString(@"Not now", nil)
//                                                otherButtonTitles:NSLocalizedString(@"Update", nil), nil ] ;
//            break;
//        }
//        
//        default : return ;
//    }
//        
//    aknowledmentPending = YES ;
//    [alertView setTag:type] ;
//    [alertView show] ;
//}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger type = alertView.tag;
//    
//    if ( buttonIndex == alertView.cancelButtonIndex )
//        return;
//    
//    switch ( type )
//    {
//        case 1:
//            //[_grandRootViewController setFrontViewPosition:FrontViewPositionRight animated:YES];
//            [_rootViewController setLeftOverlayPosition:SWLeftOverlayPositionShown animated:YES];
//            break;
//            
//        case 4:
//            [filesModel() copyFileTemplates] ;
//            break;
//    }
//
//}


//----------------------------------------------------------------------------------------
// Crea i mostra un alertView amb el missatge especificat especificant self com a delegat
// Evita la sobreposició de alertViews amb els flags aknowledmentPending i settingsPending
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)msg tag:(NSInteger)type
{
    if ( aknowledmentPending ) return;
    if ( _loginController ) return ;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    switch ( type )
    {
        case 1: // avis inicial de HMI View
        {
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString( @"Open Application Panel", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *a)
            {
                [_rootViewController setLeftOverlayPosition:SWLeftOverlayPositionShown animated:YES];
            }];
            
            [alert addAction:action];
            break ;
        }
        
        case 2: // errors amb un simple OK
        {
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", nil ) style:UIAlertActionStyleDefault
            handler:nil];
            
            [alert addAction:action];
            break ;
        }
        
        case 3: // errors que no requereixen cap continuació excepte tancar la aplicacio
        {
            break ;
        }
        
        case 4: // ask download examples
        {
            UIAlertAction *action0 = [UIAlertAction actionWithTitle:NSLocalizedString( @"Not now", nil ) style:UIAlertActionStyleCancel
            handler:nil];
            
            [alert addAction:action0];
        
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString( @"Update", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *a)
            {
                [filesModel() copyFileTemplates];
            }];
            
            [alert addAction:action1];
    
            break;
        }
        
        default : return ;
    }
        
    aknowledmentPending = YES ;
    
    //[_rootViewController presentViewController:alert animated:YES completion:nil];
    [SWQuickAlert showAlertController:alert];
}



#pragma mark background process


//--------------------------------------------------------------------------------------------  
- (void)startBackgroundProcessIfNone
{
    if ( bgTask == UIBackgroundTaskInvalid )
    {
        UIApplication* app = [UIApplication sharedApplication];
        
        [self startBackgroundTimer] ;
        //[self setPlayForever:YES] ;
        
        if ( DEBUG ) NSLog(@"AppDelegate beginBackgroundTaskWithExpirationHandler") ;
        bgTask = [app beginBackgroundTaskWithExpirationHandler: ^
        {
            // Synchronize the cleanup call on the main thread in case
            // the task actually finishes at around the same time.
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (bgTask != UIBackgroundTaskInvalid) 
                {
                    if ( DEBUG) NSLog( @"AppDelegate endBackgroundTask will call 1" ) ;
                    [self setApplicationBadge:0] ;
                    [self _closeDocument];
                    [app endBackgroundTask:bgTask];
                    bgTask = UIBackgroundTaskInvalid;
                }
            });
        }];
    }

}


//----------------------------------------------------------------------------------------
- (void)startBackgroundTimer
{
    if ( backgroundTimer == nil )
    {
        backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                    target:self selector:@selector(backgroundTimerFired:)
                                    userInfo:nil repeats:YES] ;
    }
    firstBackgroundWarning = NO ;
    secondBackgroundWarning = NO ;
}


//----------------------------------------------------------------------------------------
- (void)invalidateBackgroundTimer
{
    if ( backgroundTimer )
    {
        [backgroundTimer invalidate] ;
        backgroundTimer = nil ;
    }
}

//----------------------------------------------------------------------------------------
- (void)backgroundTimerFired:(NSTimer*)theTimer
{
    UIApplication* app = [UIApplication sharedApplication];
    NSTimeInterval remaining = [app backgroundTimeRemaining] ;
    if ( DEBUG )
    {
//        Reachability *reachability = [Reachability sharedReachability] ;
//        NSLog( @"remaining %g, reachab:%d", remaining, [reachability status] ) ;
        NSLog( @"remaining %g", remaining ) ;
    }
    
    
    if ( remaining < 60 )
    {
        NSString *alarmLabel = nil ;
        NSString *alarmText = nil ;
        if ( NO && secondBackgroundWarning == NO && remaining < 10)
        {
            alarmLabel = NSLocalizedString(@"Open", nil) ;
            alarmText = NSLocalizedString(@"LessThan10secLeft", nil) ;
            secondBackgroundWarning = YES ;
        }
        
        if ( firstBackgroundWarning == NO )
        {
            alarmLabel = NSLocalizedString(@"Open", nil) ;
            alarmText = NSLocalizedString(@"LessThan1minuteLeft", nil) ; 
            firstBackgroundWarning = YES ;
        }
    
        if ( alarmText )
        {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if ( localNotif )
            {
                [localNotif setAlertAction:alarmLabel] ;
                [localNotif setAlertBody:alarmText] ;
                [localNotif setUserInfo:[NSDictionary dictionaryWithObject:@"timeout" forKey:@"type"]] ;
                [localNotif setSoundName:UILocalNotificationDefaultSoundName];
                [app presentLocalNotificationNow:localNotif];
                //[localNotif release];
            }
        }
    }
}


//--------------------------------------------------------------------------------------------  
- (void)stopBackgroundProcessIfAny
{
    [self invalidateBackgroundTimer] ;
    //[self setPlayForever:NO] ;
    
    if ( bgTask != UIBackgroundTaskInvalid )
    {
        UIApplication* app = [UIApplication sharedApplication];
        
        if ( DEBUG ) NSLog( @"AppDelegate endBackgroundTask will call 2" ) ;
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid ;
    }
}




////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Application Badge
////////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------------  
- (void)setApplicationBadge:(NSInteger)newBadgeNumber
{
    UIApplication* app = [UIApplication sharedApplication];
    NSInteger badgeNumber = [app applicationIconBadgeNumber] ;
    if ( newBadgeNumber != badgeNumber ) [app setApplicationIconBadgeNumber:newBadgeNumber] ;
}

////--------------------------------------------------------------------------------------------  
//- (void)setAlarmsNavigatorBadge:(NSInteger)newBadgeNumber
//{
//    UITabBarItem *tabBarItem = [alarmsNavigator tabBarItem] ;
//    NSString *newBadgeStr = nil ;
//    if ( newBadgeNumber) newBadgeStr = [NSString stringWithFormat:@"%d", newBadgeNumber] ;
//    NSString *badgeStr = [tabBarItem badgeValue] ;
//    if ( ![badgeStr isEqualToString:newBadgeStr] ) [tabBarItem setBadgeValue:newBadgeStr] ;
//}        


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Alarm Sound
////////////////////////////////////////////////////////////////////////////////////////////

#define AUDIOSERVICES true
#define AVAUDIOPLAYER !AUDIOSERVICES

#define PLAYINBACKGROUND 1

#define VIBRATEREPEAT 1    // (indica numero de vegades que volem vibrar)

#if AUDIOSERVICES
/*
//--------------------------------------------------------------------------------------------  
- (void)playVibrate
{
    if ( (playVibrateCount++)%4 != 0 ) AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    if ( playVibrateCount > VIBRATEREPEAT )
    {
        [repeatVibrationTimer invalidate] ;
        repeatVibrationTimer = nil ;
    }
}
*/

//--------------------------------------------------------------------------------------------  
- (void)playVibrate
{
    if ( playVibrateCount == 0 )
    {
        [repeatVibrationTimer invalidate] ;
        repeatVibrationTimer = nil ;
    }
    if ( playVibrateCount%4 != 0 ) AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    playVibrateCount-- ;
}


/*
//--------------------------------------------------------------------------------------------  
- (void)playAlarmSound
{
    AudioServicesPlaySystemSound( systemSoundId );
    //AudioServicesPlayAlertSound( systemSoundId );   // aquesta faria vibrar breument
}
*/


//--------------------------------------------------------------------------------------------  
- (void)setPlayAlarmVibration:(NSInteger)unAckAlarms withSound:(BOOL)withSound
{
    if ( unAckAlarms )
    {        
        if ( withSound )
        {
            if ( systemSoundId ) AudioServicesDisposeSystemSoundID(systemSoundId) ; 
        
            //NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"mail-sent" withExtension:@"caf"];
            NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"Alarm" withExtension:@"caf"];
            //NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"AlarmAAC" withExtension:@"caf"];

            AudioServicesCreateSystemSoundID( (__bridge CFURLRef)soundUrl, &systemSoundId );
            AudioServicesPlaySystemSound( systemSoundId );
            //[self playAlarmSound] ;
        }
        
        playVibrateCount = VIBRATEREPEAT ;
        if ( playVibrateCount ) [self playVibrate] ;
        if ( playVibrateCount )
        {
            if ( repeatVibrationTimer == nil ) 
            {
                repeatVibrationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                target:self selector:@selector(playVibrate) 
                                userInfo:nil repeats:YES];
            }
        }
        
    }
    else
    {
        if ( systemSoundId ) AudioServicesDisposeSystemSoundID(systemSoundId) ; 
        systemSoundId = 0 ;
        
        [repeatVibrationTimer invalidate] ;
        repeatVibrationTimer = nil ;
    }
}
#endif


#if AVAUDIOPLAYER
//--------------------------------------------------------------------------------------------  
- (void)playVibrate
{
    if ( (++playVibrateCount)%4 != 0 ) AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
}


//--------------------------------------------------------------------------------------------  
- (void)playAlarmSound
{
    BOOL didPlay = [audioPlayer play] ;
    //NSLog( @"playAlarmSound didPlay:%d", didPlay ) ;
}


//--------------------------------------------------------------------------------------------  
- (void)setPlayAlarmSound:(NSInteger)activeAlarms
{
    if ( activeAlarms )
    {
        if ( repeatSoundTimer == nil )
        {
            //NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"mail-sent" withExtension:@"caf"];
            NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"Alarm" withExtension:@"caf"];
            //NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"AlarmAAC" withExtension:@"caf"];
            
            if ( audioPlayer == nil )
            {
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
                [audioPlayer setDelegate:self] ;
                AVAudioSession *audioSession = [AVAudioSession sharedInstance] ;
                [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil] ;
                [audioSession setDelegate:self] ;
            }
        
            repeatSoundTimer = [NSTimer scheduledTimerWithTimeInterval:23.0
                                target:self selector:@selector(playAlarmSound) 
                                userInfo:nil repeats:YES];
        
            [self playAlarmSound] ;
        
        }
        
        if ( NO && repeatVibrationTimer == nil )
        {
            playVibrateCount = 0 ;
            repeatVibrationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                target:self selector:@selector(playVibrate) 
                                userInfo:nil repeats:YES];
            [self playVibrate] ;
        }
        
    }
    else
    {
        [repeatSoundTimer invalidate] ;
        repeatSoundTimer = nil ;

        [audioPlayer stop] ;
        
        [repeatVibrationTimer invalidate] ;
        repeatVibrationTimer = nil ;
    }
}

//--------------------------------------------------------------------------------------------  
- (void)beginInterruption
{
    NSLog1( @"AVSesion beginInterruption" ) ;
}

//--------------------------------------------------------------------------------------------  
- (void)endInterruption
{
    NSLog1( @"AVSesion endInterruption" ) ;
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog1( @"AudioPlayer beginInterruption" ) ;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    NSLog1( @"AudioPlayer endInterruption" ) ;
}

#endif

//--------------------------------------------------------------------------------------------  
- (void)setPlayForever:(BOOL)value
{
#if PLAYINBACKGROUND
    if ( value )
    {
        if ( foreverPlayer == nil )
        {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance] ;
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil] ;
            NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"mail-sent" withExtension:@"caf"];
            foreverPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
            [foreverPlayer setDelegate:self] ;
            [foreverPlayer setNumberOfLoops:-1] ;
            [foreverPlayer setVolume:0] ;
        }
        [foreverPlayer play] ;
        //NSLog1( @"Started playing forever" ) ;
    }
    else
    {
        if ( foreverPlayer )
        {
            [foreverPlayer stop] ;
            //[foreverPlayer release] ;
            foreverPlayer = nil ;
            //NSLog1( @"Stopped playing forever" ) ;
        }
    }
#endif
}


//--------------------------------------------------------------------------------------------  
- (void)playBackgroundTick
{
    if ( tickPlayer == nil )
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance] ;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil] ;
        NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"beep-beep" withExtension:@"caf"];
        tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
        [tickPlayer setDelegate:self] ;
        [tickPlayer setNumberOfLoops:0] ;
    }
    [tickPlayer setVolume:[defaults() tickVolume]] ;
    [tickPlayer play] ;
}

//--------------------------------------------------------------------------------------------  
- (void)setPlayBackgroundTick:(BOOL)value
{
    if ( value )
    {
        if ( repeatTickTimer == nil ) 
        {
            repeatTickTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                            target:self selector:@selector(playBackgroundTick) 
                            userInfo:nil repeats:YES];
        }
        
        [self playBackgroundTick] ;
        NSLog1( @"Started playing tick" ) ;
    }
    else
    {
        if ( tickPlayer )
        {
            [tickPlayer stop] ;
            //[tickPlayer release] ;
            tickPlayer = nil ;
            NSLog1( @"Stopped playing tick" ) ;
        }
        
        if ( repeatTickTimer )
        {
            [repeatTickTimer invalidate] ;
            repeatTickTimer = nil ;
        }
    }
}



/*
//--------------------------------------------------------------------------------------------
- (void)doPlayPlayerItem:(AVPlayerItem*)playerItem
{
    if ( userPlayer == nil && playerItem )  // start
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance] ;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil] ;
        userPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        //[userPlayer setDelegate:self] ;
        //[userPlayer setNumberOfLoops:1] ;
        //[userPlayer setVolume:1.0] ;
        [userPlayer play] ;
        NSLog( @"Started playing userPlayer" ) ;
    }
    else if ( userPlayer && playerItem == nil )  // stop
    {
        [userPlayer pause] ;
        [userPlayer release] ;
        userPlayer = nil ;
        NSLog( @"Stopped playing userPlayer" ) ;
    }
    else if ( userPlayer && playerItem )  // stop + start
    {
        [userPlayer replaceCurrentItemWithPlayerItem:playerItem] ;
        NSLog( @"Replaced playing userPlayer" ) ;
    }
}
*/

/*
//--------------------------------------------------------------------------------------------
- (void)playSoundNotification:(NSNotification*)note
{
    NSDictionary *userInfo = [note userInfo] ;
    NSURL *soundURL = [userInfo objectForKey:@"SoundURL"] ;
    //NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Alarm" withExtension:@"caf"];
    AVPlayerItem *playerItem = nil ;
    if ( soundURL ) playerItem = [[AVPlayerItem alloc] initWithURL:soundURL] ;
    [self doPlayPlayerItem:playerItem] ;
    [playerItem release] ;
}
*/

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog1( @"AudioPlayer beginInterruption" ) ;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog1( @"AudioPlayer endInterruption" ) ;
}




#pragma mark Private - LoginController delegate


////---------------------------------------------------------------------------------------------------
//- (void)loginWindowWillOpen:(LoginWindowController*)sender
//{
//    [sender setCancelForbiden:YES];
//    //[[sender usernameTextField] setText:[defaults() currentUser]];
//    [sender setUsername:[defaults() currentUser]];
//    [sender setCurrentAccount:[defaults() currentUser]];
//}


////---------------------------------------------------------------------------------------------------
//- (BOOL)loginWindowWillClose:(LoginWindowController*)sender canceled:(BOOL)userCanceled userChanged:(BOOL)userChanged
//{
//    NSLog1( @"ApplicationDelegate: loginWindowWillClose from loginWindow") ;
//    // el login window amb aquest delegat no permet cance-lar, pero per si de cas
//    // aquí no deixem sortir
//    if ( userCanceled  ) return NO ;
//
//    NSString *username = [sender username] ;
//    UserProfile *profile = [usersModel() getProfileCopyForUser:username] ;
//    
//    BOOL didPass = YES ;
//    if ( didPass ) didPass = [profile enabled] ;
//    if ( didPass ) didPass = [[sender password] isEqualToString:[profile password]] ;
//    
//    if ( didPass )
//    {
//        if ( userChanged ) [defaults() setCurrentUser:username] ; // update model (defaults)
//        //[window makeKeyAndVisible];
//        return YES ;
//    }
//    
//    return NO ;
//}


////---------------------------------------------------------------------------------------------------
//- (void)loginWindowDidClose:(LoginWindowController*)sender canceled:(BOOL)userCanceled userChanged:(BOOL)userChanged
//{
//    NSLog1( @"ApplicationDelegate: loginWindowDidClose from loginWindow windows" ) ;
//    _loginController = nil;
//    [self _doApplicationDidBecomeActive] ;
//}


//---------------------------------------------------------------------------------------------------
- (void)loginWindowDidClose:(LoginWindowControllerC*)sender
{
    NSLog1( @"ApplicationDelegate: loginWindowDidClose from loginWindow windows" ) ;
    _loginController = nil;
    [self _doApplicationDidBecomeActive] ;
}



#pragma mark Private - Establiment dels ViewControllers de la Aplicacio


//---------------------------------------------------------------------------------------------
- (void)_doPresentErrorPresenterWithTitle:(NSString*)title message:(NSString*)message
{
    SWErrorPresenterViewController *errorPresenter = [[SWErrorPresenterViewController alloc] init];
    [errorPresenter setTitle:title];
    [errorPresenter setMessage:message];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:errorPresenter] ;
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
//    [_mainNavigator presentViewController:navController animated:YES completion:nil];
    [_rootViewController presentViewController:navController animated:YES completion:nil];
}


- (void)_processFileUrl
{
    if ( [_openUrl isFileURL] )
    {
        NSString *fileName = [_openUrl path] ;
        [URLDownloadObject openFromExternalAppWithFileUrlName:fileName delegate:self] ;
    }
}

- (void)_processScheme
{
    NSString *scheme = [_openUrl scheme];
    if ( scheme && NSOrderedSame == [scheme caseInsensitiveCompare:@"hmipad"] )
    {
        //[usersModel() processOpenUrl:_openUrl];
        [URLDownloadObject openFromExternalSchemeURL:_openUrl];
    }
}


//- (void)_establishDocumentController
- (void)_openDocument;
{
    [filesModel().fileDocument openDocumentWithCompletion:nil];
}

- (void)_saveDocument
{
    [filesModel().fileDocument saveDocumentWithCompletion:nil];
}

- (void)_closeDocument
{
    [filesModel().fileDocument closeDocumentWithCompletion:nil];
}

- (void)_resetProjectSources
{
    [filesModel().fileSource setProjectSources:nil];
}

- (void)_clausureSources
{
    SWDocumentModel *docModel = _documentController.docModel;
    [docModel clausureSources];
}

- (void)_igniteSources
{
    SWDocumentModel *docModel = _documentController.docModel;
    [docModel igniteSources];
}




//---------------------------------------------------------------------------------------------------

- (void)_establishDocumentControllerWithController:(SWDocumentController*)documentController
{
    _documentController = documentController;
    [_rootViewController setContentViewController:documentController animated:YES];   // cucut
}


- (void)_establishAllowedOrientation
{
    SWDocumentModel *docModel = _documentController.docModel;
    if ( docModel != nil )
    {
        //SWProjectAllowedOrientation allowedOrientation = docModel.allowedOrientation;
        SWProjectAllowedOrientation allowedOrientation = [docModel allowedOrientationForCurrentIdiom];
        
        UIInterfaceOrientation currentOrientation = _documentController.interfaceOrientation;
        
//        [device performSelector:NSSelectorFromString(@"setOrientation:")
//            withObject:(__bridge id)((void*)UIInterfaceOrientationLandscapeRight)];
        BOOL currentPortrait = UIInterfaceOrientationIsPortrait(currentOrientation);
        BOOL currentLandscape = UIInterfaceOrientationIsLandscape(currentOrientation);
        BOOL allowedPortrait = (allowedOrientation == SWProjectAllowedOrientationPortrait);
        BOOL allowedLandscape = (allowedOrientation == SWProjectAllowedOrientationLandscape);

        BOOL shouldChange = (currentPortrait && allowedLandscape) || (currentLandscape && allowedPortrait ) ;
        
        if ( shouldChange )
        {
            UIDevice *device = [UIDevice currentDevice];
            
            NSString *methodStr = [NSString stringWithFormat:@"set%@:", @"Orientation"];
            SEL selector = NSSelectorFromString(methodStr);
            Method method = class_getInstanceMethod([device class], selector );
        
            if ( method != NULL )
            {
                void (*setter)(id, SEL, UIDeviceOrientation) = (void (*)(id, SEL, UIDeviceOrientation))method_getImplementation(method);
                
            //void (*setter)(id, SEL, UIDeviceOrientation) = (void (*)(id, SEL, UIDeviceOrientation))[device methodForSelector:selector];
            
                if ( setter )
                {
                    UIDeviceOrientation deviceOrientation = allowedLandscape?UIDeviceOrientationLandscapeLeft:UIDeviceOrientationPortrait;
                    setter( device, selector, deviceOrientation);
                }
            }
        }
    }
}



- (void)_establishMainWindowIPad
{
//    const CGFloat oWidth = 320;
//    const CGFloat eWidth = 240;
    
    const CGFloat oWidth = 320;
    const CGFloat eWidth = (IS_IPHONE ? 60 : 156 );

    _rootViewController = [[SWToolbarViewController alloc] init];
    [_rootViewController setLeftOverlayWidth:oWidth];
    [_rootViewController setLeftOverlayExtensionWidth:eWidth];

    // posem un documentcontroller vuit pero el _documentController encara sera nil
    SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:nil];
    [_rootViewController setContentViewController:documentController animated:NO];
    
    SWRearViewController *rearViewController = [[SWRearViewController alloc] init];
    
    UIViewController *rearController = nil;
    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
    
    //rearNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    SWRevealViewController * rearReveal = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:nil];
    [rearReveal setFrontViewShadowOpacity:0.1];
    [rearReveal setFrontViewShadowRadius:10];
    
    [rearReveal setFrontViewShadowOpacity:0];
    [rearReveal setFrontViewShadowRadius:0];
    
//    [rearReveal setToggleAnimationDuration:0.25];
//        [rearReveal setBounceBackOnLeftOverdraw:NO];
//        [rearReveal setStableDragOnLeftOverdraw:YES];
    [rearReveal setBounceBackOnOverdraw:NO];
    [rearReveal setStableDragOnOverdraw:YES];
        
    [rearReveal setFrontViewPosition:FrontViewPositionRightMostRemoved];
    [rearReveal setRearViewRevealWidth:eWidth];
    [rearReveal setRearViewRevealOverdraw:oWidth-eWidth];
    [rearReveal setExtendsPointInsideHit:YES];
    [rearReveal setRearViewRevealDisplacement:60];
    rearController = rearReveal;

       // rearController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
    
    [_rootViewController setOverlayViewController:rearController animated:NO];
}




//- (void)_establishMainWindowIPadN
//{
//    _rootViewController = [[SWToolbarViewController alloc] init];
//    [_rootViewController setLeftOverlayWidth:320];
//    [_rootViewController setLeftOverlayExtensionWidth:120];
//
//    // posem un documentcontroller vuit pero el _documentController encara sera nil
//    SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:nil];
//    [_rootViewController setContentViewController:documentController animated:NO];
//    
//    _detailRevealViewController = [[SWRevealViewController alloc] initWithRearViewController:nil frontViewController:_rootViewController];
////    [_detailRevealViewController setFrontViewShadowOpacity:0.1];
//    [_detailRevealViewController setFrontViewShadowRadius:1];
//    [_detailRevealViewController setFrontViewShadowOffset:CGSizeMake(0, 0)];
//    //[_detailRevealViewController setFrontViewShadowColor:[UIColor lightGrayColor]];
//    [_detailRevealViewController setBounceBackOnOverdraw:NO];
//    [_detailRevealViewController setStableDragOnOverdraw:YES];
//    [_detailRevealViewController setRearViewRevealWidth:320-60];
//    [_detailRevealViewController setRearViewRevealOverdraw:60];
//    [_detailRevealViewController setRearViewRevealDisplacement:0];
//    
//    SWRearViewController *rearViewController = [[SWRearViewController alloc] init];
//    UINavigationController *rearController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
//    
//    _grandRootViewController = [[SWRevealViewController alloc] initWithRearViewController:rearController
//        frontViewController:_detailRevealViewController];
//
////    [_grandRootViewController setFrontViewShadowOpacity:0.1];
////    [_grandRootViewController setFrontViewShadowRadius:10];
//    
//    [_grandRootViewController setFrontViewShadowRadius:1];
//    [_grandRootViewController setFrontViewShadowOffset:CGSizeMake(0, 0)];
//    [_grandRootViewController setBounceBackOnOverdraw:NO];
//    [_grandRootViewController setStableDragOnOverdraw:YES];
//    [_grandRootViewController setRearViewRevealWidth:60];
//    [_grandRootViewController setRearViewRevealOverdraw:320-60];
//    
////    [_grandRootViewController panGestureRecognizer];
//
////
////    [_grandRootViewController setFrontViewShadowRadius:1.5];
////    
////    UIPanGestureRecognizer *panGestureRecognizer = _detailRevealViewController.panGestureRecognizer;
////
////    [_rootViewController.toolbar addGestureRecognizer:panGestureRecognizer];
//
//}


- (void)_establishMainWindow
{
    [self _establishMainWindowIPad];

    //[_window addSubview:_rootViewController.view];
    [_window setRootViewController:_rootViewController];
//    [_window setRootViewController:_grandRootViewController];
    
    
    // ens afegim com a observadors de canvis en el model
    //ModelNotificationCenter *mnc = [ModelNotificationCenter defaultCenter] ;
    [filesModel().files addObserver:self];
    [filesModel().fileDocument addObserver:self];
    
    // comencem a observar alarmes per tenir el icon badge actualitzat i enviar notificacions locals en background
    //[mnc addObserver:self selector:@selector(alarmStateChangedNotification:) name:kAlarmItemsDidChangedNotification object:nil] ;
    
    // notificacio de viewer
    //[mnc addObserver:self selector:@selector(viewerShouldAppearNotification:) name:kViewerShouldAppearNotification object:nil] ;
    
    // notificacio de player
    //[mnc addObserver:self selector:@selector(playerShouldAppearNotification:) name:kPlayerShouldAppearNotification object:nil] ;
    //[mnc addObserver:self selector:@selector(playerShouldRepeatNotification:) name:kPlayerShouldRepeatNotification object:nil] ;
    
    // canvi del document actual
    //[mnc addObserver:self selector:@selector(currentSourcesChangedNotification:) name:kCurrentSourcesChangedNotification object:nil];
    
    // ens afegim com a observadors de canvis en els usersettings
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(currentUserDidChangeNotification:) name:kCurrentUserDidChangeNotification object:nil] ;
    [nc addObserver:self selector:@selector(documentCheckPointNotification:) name:SWDocumentCheckPointNotification object:nil] ;
    [nc addObserver:self selector:@selector(documentDidBeginEditingNotification:) name:SWDocumentDidBeginEditingNotification object:nil] ;
    [nc addObserver:self selector:@selector(documentDidEndEditingNotification:) name:SWDocumentDidEndEditingNotification object:nil] ;
    [nc addObserver:self selector:@selector(documentControllerPartialRevealNotification:) name:SWDocumentControllerPartialRevealNotification object:nil];
    [nc addObserver:self selector:@selector(documentControllerFullRevealNotification:) name:SWDocumentControllerFullRevealNotification object:nil];
    [nc addObserver:self selector:@selector(documentControllerAllowedInterfaceIdiomOrientationNotification:) name:SWDocumentControllerAllowedInterfaceIdiomOrientationNotification object:nil];
    
    [nc addObserver:self selector:@selector(redeemViewControllerWillOpenProjectNotification:) name:SWRedeemViewControllerWillOpenProjectNotification object:nil];
    
    // Accio del boto project
    //[nc addObserver:self selector:@selector(projectButtonActionNotification:) name:SWProjectButtonActionNotification object:nil];
    //[nc addObserver:self selector:@selector(playSoundNotification:) name:@"PlaySound" object:nil] ;
    
    if ( [defaults() isMultitaskingSupported] ) 
    {
        BOOL backgroundConditions = [defaults() backgroundConditionsAreMet] ;
        [self setPlayForever:backgroundConditions] ;

        // comencem a observar canvis en condicions que poden canviar el badge de la aplicacio
        [nc addObserver:self selector:@selector(backgroundConditionsChangedNotification:) name:kBackgroundConditionsChangedNotification object:nil] ;
    }    
}

//#define FloatingPopover YES




#pragma mark ValidateProject



//- (void)_alertAndCloseProjectWithDone:(BOOL)done
//{
//    NSString *title = NSLocalizedString(@"Warning", nil);
//    NSString *ok = NSLocalizedString(@"OK", nil);
//    NSString *message = NSLocalizedString(done?@"YouDoNotHavePermission":@"YouDoNotHavePermissionNoDone", nil);
//    
//    SWBlockAlertView *alert = [[SWBlockAlertView alloc]
//        initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//    __weak id theSelf = self;
//    [alert setResultBlock:^(BOOL success, NSInteger index)
//    {
//        [theSelf _resetProjectSources];
//    }];
//    
//    [alert show];
//}


- (void)_alertAndCloseProjectWithDone:(BOOL)done
{
    NSString *title = NSLocalizedString(@"Warning", nil);
    NSString *ok = NSLocalizedString(@"OK", nil);
    NSString *message = NSLocalizedString(done?@"YouDoNotHavePermission":@"YouDoNotHavePermissionNoDone", nil);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction *a)
    {
        [self _resetProjectSources];
    }];
            
    [alert addAction:action];
    
    [SWQuickAlert showAlertController:alert];
    
//    [_rootViewController presentViewController:alert animated:YES completion:nil];
    
}


//- (void)_validateProject
//{
//
////    SWDocument *document = [filesModel() currentDocument];
////    SWDocumentModel *docModel = document.docModel;
//    
//    SWDocumentModel *docModel = _documentController.docModel;
//
//    if ( docModel == nil )
//        return;
//    
//    _projectValidated = YES;
//    NSString *projectID = docModel.uuid;
//    
//    if ( HMiPadDev )
//    {
//        
//        //return;  // treure aixo:
//
//        [filesModel().files validateProjectWithProjectID:projectID /*ownerID:0*/ completion:^(BOOL done, BOOL result)
//        {
//            _projectValidated = (done && result);
//            //[self _stopIntegratorTimer];
//            [self _resumeIntegratorTimer];
//        }];
//        
//        _projectValidated = NO;    // <-- no valid per defecte
//        //[self _stopIntegratorTimer];
//        [self _resumeIntegratorTimer];
//    }
//    
//    else if ( HMiPadRun )
//    {
//        UInt32 currentUserId = [usersModel() currentUserId];
////        UInt32 lastAuthUserId = [defaults() lastAuthUserId];
//        UInt32 lastAuthUserId = [usersModel() lastAuthUserId];
//    
//        //UInt32 owner =  docModel.ownerID;
//        _projectValidated = YES;   // <-- valid per defecte
//        [filesModel().files validateProjectWithProjectID:projectID /*ownerID:owner*/ completion:^(BOOL done, BOOL result)
//        {
//            if ( result )
//                [usersModel() setLastAuthUserId:currentUserId];
//            
//            if ( lastAuthUserId == currentUserId )
//            {
//                _projectValidated = result || !done;   // <-- si no hem canviat d'usuari admetem validacions lazy
//            }
//            else
//            {
//                _projectValidated = result;  // <-- si hem canviat d'usuari la validacio ha de ser estricta      // CloudKit: ATENCIO TREURE AIXO
//                if ( !result )
//                    [usersModel() setLastAuthUserId:0];  // <-- si no hi ha validacio obliguem a que hi sigui
//            }
//            
//            if ( !_projectValidated )
//                [self _alertAndCloseProjectWithDone:done];
//        }];
//    }
//    
//    // si no automatic login del project user i hi ha usuaris presentar el login de project user.
//    [docModel showProjectUserLoginIfNeeded];
//    
//}


- (void)_validateProject
{
    SWDocumentModel *docModel = _documentController.docModel;

    if ( docModel == nil )
        return;
    
    _projectValidated = YES;
    NSString *projectID = docModel.uuid;
    
    if ( HMiPadDev )
    {
        _projectValidated = NO;    // <-- no valid per defecte
        [self _resumeIntegratorTimer];
        
        [filesModel().files validateProjectWithProjectID:projectID completion:^(BOOL done, BOOL result)
        {
            _projectValidated = (done && result);   // <-- validacions han de ser extrictes
            if ( _projectValidated ) [self _stopIntegratorTimer];
            else [self _resumeIntegratorTimer];
        }];
        
    }
    
    else if ( HMiPadRun )
    {
        _projectValidated = YES;   // <-- valid per defecte
        [filesModel().files validateProjectWithProjectID:projectID /*ownerID:owner*/ completion:^(BOOL done, BOOL result)
        {
            _projectValidated = result || !done;   // <-- s'admetem validacions lazy
            if ( !_projectValidated )
                [self _alertAndCloseProjectWithDone:done];
        }];
    }
    
    // si no automatic login del project user i hi ha usuaris presentar el login de project user.
    [docModel showProjectUserLoginIfNeeded];
    
}




#define NEXTTIMEINTERVAL (60*10)
//#define NEXTTIMEINTERVAL (10)

- (NSTimer*)integratorTimer
{
    if ( _integratorTimer == nil )
    {
        _integratorTimer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_integratorTimerFired:) userInfo:nil repeats:YES];
        _nextTimeInterval = NEXTTIMEINTERVAL;
    }
    
    return _integratorTimer;
}


//- (void)_integratorTimerFiredV:(id)sender
//{
//    UserProfile *profile = [usersModel() currentUserProfile];
//    BOOL isLocal = profile.isLocal;
//    
//    NSString *title = NSLocalizedString(@"IntegratorTimeoutTitle", nil);
//    NSString *message = NSLocalizedString(isLocal?@"IntegratorTimeoutMessageLocal":@"IntegratorTimeoutMessage", nil);
//    NSString *other1 = NSLocalizedString(@"Edit Mode", nil);
//    NSString *other2 = NSLocalizedString(isLocal?@"New User":@"Activate…", nil);
//    
//    SWBlockAlertView *timerAlertView = [[SWBlockAlertView alloc]
//        initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:other1, other2, nil];
//    //__weak SWAppDelegate *theSelf = self;
//    NSInteger firstOtherButton = [timerAlertView firstOtherButtonIndex];
//    
//    [timerAlertView setResultBlock:^(BOOL ok, NSInteger index)
//    {
//        NSLog1( @"vale (un moment siusplau)" );
//        [self _resumeIntegratorTimer];
//        
//        SWDocumentModel *docModel = _documentController.docModel;
//        [docModel setEditMode:YES animated:YES];
//        
//        if ( index == firstOtherButton )
//        {
//            // res (ja ha posat edit mode)
//        }
//        else if ( index == firstOtherButton+1 )
//        {
//            if ( isLocal ) [_documentController presentNewAccountController];
//            else
//            {
//                [filesModel().fileDocument saveDocumentWithCompletion:^(BOOL success)
//                {
//                    if ( success )
//                        [_documentController presentUploadController];
//                }];
//                
//            }
//        }
//        
//    }];
//    
//    [self _freezeIntegratorTimer];
//    [timerAlertView show];
//}



- (void)_integratorTimerFired:(id)sender
{
    //UserProfile *profile = [usersModel() currentUserProfile];
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    
    BOOL isLocal = profile.isLocal;
    
    NSString *title = NSLocalizedString(@"IntegratorTimeoutTitle", nil);
//    NSString *message = NSLocalizedString(isLocal?@"IntegratorTimeoutMessageLocal":@"IntegratorTimeoutMessage", nil);
    NSString *message = NSLocalizedString(@"IntegratorTimeoutMessage", nil);
    NSString *other1 = NSLocalizedString(@"Edit Mode", nil);
    //NSString *other2 = NSLocalizedString(isLocal?@"New User":@"Activate…", nil);
    NSString *other2 = NSLocalizedString(@"Activate…", nil);
    
    
    UIAlertController *timerAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    void (^common)() = ^()
    {
        NSLog1( @"vale (un moment siusplau)" );
        [self _resumeIntegratorTimer];
        
        SWDocumentModel *docModel = _documentController.docModel;
        [docModel setEditMode:YES animated:YES];
    };
    
    UIAlertAction *alertAction0 = [UIAlertAction actionWithTitle:other1 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        common();
    }];
    
    [timerAlert addAction:alertAction0];
    
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:other2 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        common();
//        if ( isLocal ) [_documentController presentNewAccountController];
        if ( isLocal ) [_documentController presentNoUserAlertFromView:nil];
        else
        {
            [filesModel().fileDocument saveDocumentWithCompletion:^(BOOL success)
            {
                if ( success )
                    [_documentController presentUploadController];
            }];
        }
    }];
    
    [timerAlert addAction:alertAction1];
    
    [self _freezeIntegratorTimer];
    
    [_documentController presentViewController:timerAlert animated:YES completion:nil];
}


- (void)_resumeIntegratorTimer
{
    if ( _projectValidated )
        return;
    
    if ( HMiPadRun || HMiPadDevBeta)
        return;
    
    SWDocumentModel *docModel = _documentController.docModel;
    if ( docModel && ![docModel editMode] )
    {
        [self integratorTimer];
        [_integratorTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_nextTimeInterval]];
        _nextTimeInterval = (_nextTimeInterval*0.8);
        if ( _nextTimeInterval < 10 ) _nextTimeInterval = 10;
    }
}

- (void)_stopIntegratorTimer
{
    if ( _projectValidated && _integratorTimer )
    {
        [self _invalidateIntegratorTimer];
        return;
    }
    
    [_integratorTimer setFireDate:[NSDate distantFuture]];
    _nextTimeInterval = NEXTTIMEINTERVAL;
}


- (void)_freezeIntegratorTimer
{
    [_integratorTimer setFireDate:[NSDate distantFuture]];
}



- (void)_invalidateIntegratorTimer
{
    [_integratorTimer invalidate];
    _integratorTimer = nil;
}


#pragma mark DocumentController notifications


- (void)documentCheckPointNotification:(NSNotification*)note
{
    [self _stopIntegratorTimer];
}

- (void)documentDidBeginEditingNotification:(NSNotification*)note
{
    [self _freezeIntegratorTimer];
}

- (void)documentDidEndEditingNotification:(NSNotification*)note
{
    [self _resumeIntegratorTimer];
}

- (void)documentControllerPartialRevealNotification:(NSNotification*)note
{
    [self _freezeIntegratorTimer];
    [cloudKitUser() checkICloudAvailabilityNowWithForce:NO];
}

- (void)documentControllerFullRevealNotification:(NSNotification*)note
{
    [self _resumeIntegratorTimer];
}

- (void)documentControllerAllowedInterfaceIdiomOrientationNotification:(NSNotification*)note
{
    [self _establishAllowedOrientation];
}


#pragma mark URLDownloadObjectDelegate

- (void)URLDownloadObject:(URLDownloadObject *)sender redeemCode:(NSString *)code
{
    UserProfile *profile = [usersModel() currentUserProfile];
    if ( profile.isLocal )
    {
        NSString *message = NSLocalizedString(@"CouldNotRedeemForLocalUser", nil) ;
        [self showAlertViewWithTitle:NSLocalizedString( @"Warning", nil ) message:message tag:2];
    }
    else
    {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SWRedeemViewController" bundle:nil];
//        SWRedeemViewController *redeemPresenter = [storyboard instantiateInitialViewController];
//        [redeemPresenter setActivationCode:code];
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:redeemPresenter];
//        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
//        [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//        [_rootViewController presentViewController:navController animated:YES completion:nil];
        
        [_rootViewController presentRedeemControllerForActivationCode:code];
    }
}

#pragma mark AppCloudKitUserObserver

- (void)cloudKitUser:(SWAppCloudKitUser *)cloudKitUser didFetchUserDataWithError:(NSError *)error
{
    if ( error != nil )
        return;

    // ok tenim un usuari bo, mirem si tenim activations pendents
    [filesModel().amActivationCodes processPendingreceipts];
    
    
    if ( [cloudKitUser currentUserHasMigrated] )
        return;

    // ok tenim usuari cloudKit pendent de migrar, migrem si cal
    if ( [defaults() pendingMigrate] )
    {
        //migrate;
       // [_rootViewController presentMigrationAssistantController]
        [UIViewController presentMigrationAssistantController];
    }
    
}


//- (void)cloudKitUser:(SWAppCloudKitUser *)cloudKitUser currentUserDidLoginWithError:(NSError *)error
//{
//    if ( error != nil )
//        return;
//    
//    if ( [cloudKitUser currentUserHasMigrated] )
//        return;
//
//    // ok tenim usuari cloudKit pendent de migrar, migrem si cal
//    if ( [defaults() pendingMigrate] )
//    {
//        //migrate;
//       // [_rootViewController presentMigrationAssistantController]
//        [UIViewController presentMigrationAssistantController];
//    }
//}



#pragma mark AppsFileModelDocumentObserver

- (void)appFilesModel:(AppModelDocument*)filesDocument willOpenDocumentName:(NSString*)name
{
    SWAlertCenter *ac = [SWAlertCenter defaultCenter];
    NSString *loadingString = NSLocalizedString(@"Loading...",nil);
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [aiv startAnimating];
    [ac setPermanent:YES];
    [ac postAlertWithMessage:loadingString view:aiv];
}


- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didOpenWithError:(NSError*)error
{
    //SWDocument *document = filesModel.currentDocument;
    BOOL success = (error == nil);

    SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:success?document:nil];
    [self _establishDocumentControllerWithController:documentController];
    [self _establishAllowedOrientation];
    
    SWAlertCenter *ac = [SWAlertCenter defaultCenter];
    [ac cancelPendingAlerts];
    isOpeningDocument = NO;
    
    if ( success )
    {
        if ( IS_IPHONE && document )
        {
            //[_grandRootViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            [_rootViewController setLeftOverlayPosition:SWLeftOverlayPositionHidden animated:YES];
        }
    }
    else
    {
        NSString *title = NSLocalizedString( @"Could not Open Document", nil );
        //NSError *error = document.lastError;
        
        NSString *headerFormat = NSLocalizedString(@"***\nErrors found when attempting to open document:\n\"%@\"\n***", nil);
        NSString *header = [NSString stringWithFormat:headerFormat, document.getFileName];

        NSString *errMsg = error.localizedDescription;

        NSError *underError = [error.userInfo objectForKey:NSUnderlyingErrorKey];
        NSString *message = nil;

        if ( underError )  message = [NSString stringWithFormat:@"%@\n\n%@: \"%@\"", header, errMsg, underError.localizedDescription];  // localitzar
        else message = [NSString stringWithFormat:@"%@\n\n%@", header, errMsg];     // localitzar
        [self _doPresentErrorPresenterWithTitle:title message:message];
    }
    
    [self _validateProject];
}




//- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didSaveWithSuccess:(BOOL)success
//{
//    if (!success) 
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//            message:@"The document couldn't be saved"
//            delegate:nil
//            cancelButtonTitle:@"Dismiss"
//            otherButtonTitles:nil];
//        [alert show];
//    }
//}


- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didSaveWithSuccess:(BOOL)success
{
    if (!success) 
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"The document couldn't be saved" preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel
        handler:nil];
            
        [alert addAction:action];
    
       // [_rootViewController presentViewController:alert animated:YES completion:nil];
        [SWQuickAlert showAlertController:alert];
    }
}


//- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didCloseWithSuccess:(BOOL)success
//{
//
//    SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:nil];
//    [self _establishDocumentControllerWithController:documentController];
//    
//    if (!success)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//            message:@"The document couldn't be saved"
//            delegate:nil
//            cancelButtonTitle:@"Dismiss"
//            otherButtonTitles:nil];
//        [alert show];
//    }
//    
//    [self _stopIntegratorTimer];
//}


- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didCloseWithSuccess:(BOOL)success
{

    SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:nil];
    [self _establishDocumentControllerWithController:documentController];
    
    if (!success)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"The document couldn't be saved" preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel
        handler:nil];
            
        [alert addAction:action];
    
        //[_rootViewController presentViewController:alert animated:YES completion:nil];
        [SWQuickAlert showAlertController:alert];
    }
    
    [self _stopIntegratorTimer];
}


#pragma mark notifications


//- (void)projectButtonActionNotification:(NSNotification*)notification
//{
//    id buttonItem = [notification userInfo];
//    [self _toggleProjectPopover:buttonItem];
//}


#warning todo
//--------------------------------------------------------------------------------------------  
- (void)alarmStateChangedNotification:(NSNotification *)note
{
//    //NSLog(@"AppDelegate: alarmStateChangedNotification fired") ;
//    id userInfo = [note userInfo] ;
//    if ( userInfo == kAlarmNotificationInfoAcknowledge ) [self setPlayAlarmVibration:0 withSound:NO] ;
//    
//    // determinem el numero de alarmes
//    NSInteger activeAlarms = [model() numberOfActiveAlarms] ;
//    NSInteger unAckAlarms = [model() numberOfUnacknowledgedAlarms] ;
//    
//    // posem un badge amb el numero de alarmes a en el Home
//    [self setAlarmsNavigatorBadge:activeAlarms] ;
//    
//    // aqui fer que soni
//    BOOL soundAlarm = [defaults() soundingAlarmsState] ;
//    BOOL alertAlarm = [defaults() alertingAlarmsState] ;  // ha de ser 1 si soundAlarm es 1
//    BOOL hudAlarm = NO ;
//    if ( userInfo == kAlarmNotificationInfoRemove ) soundAlarm = NO, alertAlarm = NO ;
//    if ( userInfo == kAlarmNotificationInfoAddOnce ) alertAlarm = NO, soundAlarm = NO, hudAlarm = YES ;
//
//    // Si tenim condicions per multitasca
//    // posem un badge amb el numero de alarmes a la aplicacio
//    //BOOL backgroundConditions = [defaults() backgroundConditionsAreMet] ;
//    //if ( backgroundConditions ) [self setApplicationBadge:activeAlarms] ;
//    BOOL keepConnected = [defaults() keepConnectedState] ;
//    if ( keepConnected ) [self setApplicationBadge:activeAlarms] ;
//
//    // si no esta en background o no es cumpleixen les condicions no cal fer res mes, tornem
//    // if ( bgTask == UIBackgroundTaskInvalid ) return ;
//
//    
//    NSString *alarmDescription = [model() alarmListMostRecentAlarmDescription] ;
//    NSString *alarmTotalDescr = [model() alarmListTotalActiveAlarmsDescription] ;
//    
//    
//    // si la aplicacio esta activa tornem ara, en cas contrari presentarem una notificacio
//    if ( appState == kSWAppStateActive && loginWindow == nil )
//    {
//        if ( unAckAlarms )
//        {
//            NSString *soundLastTxt = @"" ;
//            if ( soundAlarm ) 
//            {
//                [self setPlayAlarmVibration:unAckAlarms withSound:YES] ;
//                soundLastTxt = NSLocalizedString(@"AlarmSoundLast30Sec",nil) ;
//            }
//
//            if ( alertAlarm )
//            {
//                NSString *title = alarmDescription;
//                if ( [title length] == 0 )
//                {
//                    //title = [NSString stringWithFormat:NSLocalizedString(@"%dActive%s\n%dUnacknowledged",nil), 
//                    //    activeAlarms, (activeAlarms==1?"":"s"), unAckAlarms ] ;
//                    title = [NSString stringWithFormat:NSLocalizedString(@"%d%sUnacknowledged",nil), unAckAlarms, (unAckAlarms==1)?"":"s" ] ;
//                }
//                NSMutableString *msg = [NSMutableString stringWithString:alarmTotalDescr] ;
//                if ( [alarmTotalDescr length] && [soundLastTxt length] ) [msg appendString:@"\n\n"] ;
//                if ( [soundLastTxt length] ) [msg appendString:soundLastTxt] ;
//                [self showAlertViewWithTitle:title message:msg tag:4] ;
//            }
//            
//            if ( hudAlarm )
//            {
//                if ( [alarmDescription length] )
//                {
//                    NSMutableString *alarmText = [NSMutableString stringWithString:alarmDescription] ;
//                    //if ( [alarmTotalDescr length] ) [alarmText appendFormat:@"\n\n%@", alarmTotalDescr] ;
//                    [[SWAlertCenter defaultCenter] postAlertWithMessage:alarmText];
//                }
//            }
//        }
//        return ;
//    }
//        
//    
//    // si som aqui es que estem en background o en repos
//    // mirem si hem de presentar una notificacio local
//    //NSString *alarmText = [model() alarmListMostRecentAlarmDescription] ;
//    //NSString *alarmText = [NSString stringWithFormat:@"%@%@", alarmDescription, alarmTotalDescr] ;
//    if ( [alarmDescription length] )
//    {    
//        NSMutableString *alarmText = [NSMutableString stringWithString:alarmDescription] ;
//        if ( [alarmDescription length] && [alarmTotalDescr length] ) [alarmText appendString:@"\n\n"] ;
//        if ( [alarmTotalDescr length] ) [alarmText appendString:alarmTotalDescr] ;
//        
//        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//        if ( localNotif )
//        {
//            NSString *alarmLabel = NSLocalizedString(@"View", nil) ;
//            [localNotif setAlertAction:alarmLabel] ;
//            [localNotif setAlertBody:alarmText] ;
//            [localNotif setUserInfo:[NSDictionary dictionaryWithObject:@"alarm" forKey:@"type"]] ;
//            NSString *soundName = nil ;
//            if ( soundAlarm )
//            {
//                if ( appState == kSWAppStateResigned /*|| PLAYINBACKGROUND*/ )   
//                {
//                    // si es kSWAppStateResigned o va permanentment sona amb el setPlayAlarmVibration
//                    [self setPlayAlarmVibration:unAckAlarms withSound:NO] ;
//                }
//                else
//                {
//                    // si es kSWAppStateBakground sona amb la notificacio
//                    //soundName = @"Alarm.caf" ;
//                    soundName = @"Alarm.caf" ;  // atencio mirar 
//                    // "Playing UI Sound Effects or Invoking Vibration Using System Sound Services"
//                    // "Preparing Custom Alert Sounds"
//                }
//            
//            /*
//                if ( appState == kSWAppStateBakground ) 
//                {
//                    soundName = @"Alarm.caf" ;
//                    if ( PLAYINBACKGROUND ) [self setPlayAlarmVibration:activeAlarms withSound:NO] ;
//                }
//            */
//            }
//            
//            [localNotif setSoundName:soundName]; // si es kSWAppStateResigned ya sona amb setPlayAlarmVibration:withSound
//            UIApplication* app = [UIApplication sharedApplication];
//            [app presentLocalNotificationNow:localNotif];
//            [localNotif release];
//        }
//    }
}


//---------------------------------------------------------------------------------------------------
// visualitza un player
//
//- (void)playerShouldAppearNotification:(NSNotification *)notification
//{
//    NSDictionary *userInfo = [notification userInfo] ;
//    NSString *text = [userInfo objectForKey:kViewerLabel] ;
//    NSString *urlText = [userInfo objectForKey:kViewerTextURL] ;
//
//    [[SWPlayerCenter defaultCenter] playSoundTextUrl:urlText labelText:text] ;
//}

//---------------------------------------------------------------------------------------------------
// posa el estat de repeticio de un player actiu
//
//- (void)playerShouldRepeatNotification:(NSNotification *)notification
//{
//    NSDictionary *userInfo = [notification userInfo] ;
//    BOOL repeat = [[userInfo objectForKey:kPlayerRepeat] boolValue] ;
//    [[SWPlayerCenter defaultCenter] setRepeat:repeat] ;
//}

//---------------------------------------------------------------------------------------------------
// genera si cal o reutilitza els items per el tabbarcontroller
//
- (void)currentUserDidChangeNotification:(NSNotification *)notification
{
    // depenent de l'usuari actual
//    BOOL isAdmin = [usersModel() currentUserIsIntegrator] ;
//    BOOL isAdvancedUser = [usersModel() currentUserAccess] >= [defaults() fileAccessLevel];
    
    [self _validateProject];
}

//--------------------------------------------------------------------------------------------  
- (void)backgroundConditionsChangedNotification:(NSNotification *)note
{
    // posem el badge a zero o el numero de alarmes si tenim les condicions per multitasca
    NSInteger newBadgeNumber = 0 ;
    BOOL keepConnected = [defaults() keepConnectedState] ;
    //if ( keepConnected ) newBadgeNumber = [model() numberOfActiveAlarms] ;
    //[self setApplicationBadge:newBadgeNumber] ;
    
    BOOL backgroundConditions = [defaults() backgroundConditionsAreMet] ;
    [self setPlayForever:backgroundConditions] ;
}


- (void)redeemViewControllerWillOpenProjectNotification:(NSNotification *)note
{
    [_rootViewController setLeftOverlayPosition:SWLeftOverlayPositionHidden animated:YES];
}


#pragma mark SWFloatingPopoverDelegate


- (void)floatingPopoverControllerCloseButton:(SWFloatingPopoverController *)floatingPopoverController
{
    [floatingPopoverController dismissFloatingPopoverWithAnimation:SWFloatingPopoverAnimationFade];
}


- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
{
    _projectControllerPosition = floatingPopoverController.presentationPosition;
    _projectControllerFPopover = nil;
}


#pragma mark UIPopoverDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _projectControllerPopover = nil;
}

@end
