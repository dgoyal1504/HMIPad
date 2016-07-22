//
//  UserDefaults.m
//  iPhoneDomus
//
//  Created by Joan on 19/07/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import "UserDefaults.h"
//#import "AppUsersModel.h"


////////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////////

NSString *kBackgroundConditionsChangedNotification = @"BackgroundConditionsChangedNotification" ;
NSString *kEnablePageDetentsStateChangedNotification = @"EnablePageDetentsStateChangedNotification" ;

//------------------------------------------------------------------------------------
// Objecte que conté els user defaults
// Els sets i gets de propietats d'aquesta classe agafen les dades de NSUserDefaults
//------------------------------------------------------------------------------------
@implementation UserDefaults

// internes

static NSString* SWOEMDidNotFollowGoodPracticesKey = @"SWUserShouldContactOEM" ;
static NSString* SWCurrentVersionKey = @"SWCurrentVersionKey" ;
static NSString* SWLastCameraPositionKey = @"SWLastCameraPositionKey" ;
static NSString* SWShouldParseFilesKey = @"SWShouldParseFilesKey" ;
static NSString* SWShouldNotiyAPNProviderKey = @"SWShouldNotiyAPNProviderKey" ;
//static NSString* SWHiddenChartAlarmsViewKey = @"SWHiddenChartAlarmsViewKey" ;  // no s'utilitza, ara si

// configurables per l'usuari

static NSString* SWCurrentUserIdKey = @"SWCurrentUserIdKey" ;
static NSString* SWLastAuthUserIdKey = @"SWLastAuthUserIdKey" ;
static NSString* SWAdminAccessLevelKey = @"SWAdminAccessLevelKey" ;
static NSString* SWFileAccessLevelKey = @"SWFileAccessLevelKey" ;

static NSString* SWSourceFileSortingOptionsKey = @"SWSourceFileSortingOptionsKey";
static NSString* SWRedeemedSourceFileSortingOptionsKey = @"SWRedeemedSourceFileSortingOptionsKey";
static NSString* SWAssetFileSortingOptionsKey = @"SWAssetFileSortingOptionsKey";
static NSString* SWRecipeFileSortingOptionsKey = @"SWRecipeFileSortingOptionsKey";
static NSString* SWDatabaseFileSortingOptionsKey = @"SWDatabaseFileSortingOptionsKey";

static NSString* SWRemoteSourceFileSortingOptionsKey = @"SWRemoteSourceFileSortingOptionsKey";
static NSString* SWRemoteAssetFileSortingOptionsKey = @"SWRemoteAssetFileSortingOptionsKey";
static NSString* SWRemoteActivationCodeSortingOptionsKey = @"SWRemoteActivationCodeSortingOptionsKey";
static NSString* SWRemoteRedemptionSortingOptionsKey = @"SWRemoteRedemptionSortingOptionsKey";

static NSString* SWITunesFileSortingOptionsKey = @"SWITunesFileSortingOptionsKey";
static NSString *SWPendingMigrateKey = @"SWPendingMigrateKey";

static NSString* SWChartAlarmsViewPageKey = @"SWChartAlarmsViewPageKey" ;
static NSString* SWHiddenChartAlarmsViewKey = @"SWhiddenChartAlarmsViewKey" ;
static NSString* SWPushedHomeViewKey = @"SWPushedHomeViewKey" ;
//static NSString* SWCurrentPageNumberKey = @"SWCurrentPageNumberKey" ;
static NSString* SWCurrentPageNameKey = @"SWCurrentPageNameKey" ;
static NSString* SWRootPageNameKey = @"SWRootPageNameKey" ;
static NSString* SWHiddenPageSwitcherKey = @"SWhiddenPageSwitcherKey" ;
static NSString* SWFileServerPortKey = @"SWFileServerPortKey" ;

static NSString* SWFinsTcpPortKey = @"SWFinsTcpPortKey" ;
static NSString* SWFinsTcpAltPortKey = @"SWFinsTcpAltPortKey" ;

static NSString* SWModbusTcpPortKey = @"SWModbusTcpPortKey" ;
static NSString* SWModbusTcpAltPortKey = @"SWModbusTcpAltPortKey" ;

static NSString* SWEipAltPortKey = @"SWEipAltPortKey" ;
static NSString* SWSiemensS7AltPortKey = @"SWSiemensS7AltPortKey" ;

static NSString* SWDefaultHostNameKey = @"SWDefaultHostNameKey" ;
static NSString* SWAlternateHostNameKey = @"SWAlternateHostNameKey" ;
static NSString* SWAlternateEnableSSLStateKey = @"SWEnableSSLStateKey" ;
static NSString* SWPollingRateOptionKey = @"SWPollingRateOptionKey" ;

static NSString* SWEnablePageDetentsStateKey = @"SWEnablePageDetentsStateKey" ;
static NSString* SWKeepConnectedStateKey = @"SWKeepConnectedStateKey" ;
static NSString* SWMultitaskStateKey = @"SWMultitaskStateKey" ;
static NSString* SWTickVolumeKey = @"SWTickVolumeKey" ;
static NSString* SWAnimateVisibleChangesStateKey = @"SWAnimateVisibleChangesStateKey" ;
static NSString* SWAnimatePageShiftsStateKey = @"SWAnimatePageShiftsStateKey" ;
static NSString* SWShowDoubleColumnStateKey = @"SWShowDoubleColumnStateKey" ;

static NSString* SWSoundingAlarmsStateKey = @"SWSoundingAlarmsStateKey" ;
static NSString* SWAlertingAlarmsStateKey = @"SWAlertingAlarmsStateKey" ;
static NSString* SWDisconnectAlertStateKey = @"SWDisconnectAlertStateKey" ;

static NSString* SWDownloadServerNameKey = @"SWDownloadServerNameKey" ;
static NSString* SWDownloadFileNameKey = @"SWDownloadFileNameKey" ;
//static NSString* SWActivationCodeNameKey = @"SWActivationCodeNameKey" ;

static NSString* SWMonitoringStateKey = @"SWMonitoringStateKey" ;
static NSString* SWHiddenTabBarKey = @"SWhiddenTabBarKey" ;
static NSString* SWHiddenFilesTabBarKey = @"SWhiddenFilesTabBarKey" ;
static NSString* SWHiddenCompanyLogoKey = @"SWhiddenCompanyLogoKey" ;

//static NSString* SWStoreProductsKey = @"SWStoreProductsKey" ;
//static NSString* SWStorePendingIASProducts = @"SWStorePendingIASProducts";
//static NSString* SWStorePendingISReceipts = @"SWStorePendingISReceipts";

// dicicionaris per sourceElements

static NSString* SWPlcDevicesAltIsFirstDictionaryKey = @"SWPlcDevicesAltIsFirstDictionaryKey" ; // inter
static NSString* SWPlcDevicesCodeDictionaryKey = @"SWPlcDevicesCodeDictionaryKey" ; // configurable

// per recordar el mal comportament d'un OEM



//------------------------------------------------------------------------------------
+ (void)initialize
{
    // assegura que els defaults estan disponibles encara que no s'hagin escrit mai
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:
    
        [NSNumber numberWithBool:NO],           SWOEMDidNotFollowGoodPracticesKey,
        [NSNumber numberWithInteger:0],         SWCurrentVersionKey,
        [NSNumber numberWithInteger:0],         SWLastCameraPositionKey,
//        DefaultUser,                            SWCurrentUserKey,
        [NSNumber numberWithInteger:SWDefaultUserId], SWCurrentUserIdKey,
        [NSNumber numberWithInteger:9],         SWAdminAccessLevelKey,
        
        [NSNumber numberWithInteger:9],         SWFileAccessLevelKey,
        [NSNumber numberWithInteger:1],         SWSourceFileSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWRedeemedSourceFileSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWAssetFileSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWRecipeFileSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWDatabaseFileSortingOptionsKey,
        
        [NSNumber numberWithInteger:1],         SWRemoteSourceFileSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWRemoteAssetFileSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWRemoteActivationCodeSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWRemoteRedemptionSortingOptionsKey,
        [NSNumber numberWithInteger:1],         SWITunesFileSortingOptionsKey,
        [NSNumber numberWithBool:NO],           SWPendingMigrateKey,    // comented, do not even set this unless explicit
#if OEM && !Integrator
        [NSNumber numberWithBool:YES],          SWMonitoringStateKey,
        [NSNumber numberWithBool:NO],           SWHiddenPageSwitcherKey,
        [NSNumber numberWithBool:YES],          SWHiddenTabBarKey,
        [NSNumber numberWithBool:YES],          SWHiddenFilesTabBarKey,
        [NSNumber numberWithBool:NO],           SWHiddenCompanyLogoKey,
        [NSNumber numberWithBool:YES],			SWHiddenChartAlarmsViewKey,
        [NSNumber numberWithInteger:0],         SWChartAlarmsViewPageKey,
#else
        [NSNumber numberWithBool:NO],           SWMonitoringStateKey,
        [NSNumber numberWithBool:NO],      		SWHiddenPageSwitcherKey,
        [NSNumber numberWithBool:YES],          SWHiddenTabBarKey,
        [NSNumber numberWithBool:YES],          SWHiddenFilesTabBarKey,
        [NSNumber numberWithBool:NO],           SWHiddenCompanyLogoKey,
        [NSNumber numberWithBool:YES],			SWHiddenChartAlarmsViewKey,
        [NSNumber numberWithInteger:0],         SWChartAlarmsViewPageKey,
#endif
        [NSNumber numberWithBool:YES],          SWShouldParseFilesKey,
        [NSNumber numberWithBool:YES],          SWShouldNotiyAPNProviderKey,
        [NSNumber numberWithBool:NO],           SWPushedHomeViewKey,
        //[NSNumber numberWithInteger:0],         SWCurrentPageNumberKey,
        @"Tags",                                SWCurrentPageNameKey,
        @"Tags",                                SWRootPageNameKey,
        
        @"8080",                                SWFileServerPortKey,
        
        @"9600",                                SWFinsTcpPortKey,
        @"9600",                                SWFinsTcpAltPortKey,
        
        @"502",                                 SWModbusTcpPortKey,
        @"502",                                 SWModbusTcpAltPortKey,
        
        @"44818",                               SWEipAltPortKey,
        @"102",                                 SWSiemensS7AltPortKey,
        
        @"",                                    SWDefaultHostNameKey,
        @"",                                    SWAlternateHostNameKey,
        [NSNumber numberWithBool:NO],           SWAlternateEnableSSLStateKey,    // a eliminar (no)
        [NSNumber numberWithInt:0],             SWPollingRateOptionKey,    // a eliminar (no)
        
        [NSNumber numberWithBool:YES],          SWEnablePageDetentsStateKey,

        [NSNumber numberWithBool:NO],           SWKeepConnectedStateKey,
        [NSNumber numberWithBool:NO],           SWMultitaskStateKey,
        [NSNumber numberWithFloat:1.0],         SWTickVolumeKey,
        [NSNumber numberWithBool:YES],          SWAnimateVisibleChangesStateKey,
        [NSNumber numberWithBool:YES],          SWAnimatePageShiftsStateKey,
        [NSNumber numberWithBool:YES],          SWSoundingAlarmsStateKey,
        [NSNumber numberWithBool:YES],          SWAlertingAlarmsStateKey,
        [NSNumber numberWithBool:YES],          SWDisconnectAlertStateKey,
        [NSNumber numberWithBool:YES],          SWShowDoubleColumnStateKey,
        
        @"",                                    SWDownloadServerNameKey,
        @"",                                    SWDownloadFileNameKey,
//        @"",                                    SWActivationCodeNameKey,
        
        //[NSNumber numberWithInteger:0],         SWStoreProductsKey,
        //[NSArray array],                        SWStorePendingIapReceipts,
//        [NSDictionary dictionary],              SWStorePendingIASProducts,
//        [NSDictionary dictionary],              SWStorePendingISReceipts,
        
        [NSDictionary dictionary],              SWPlcDevicesCodeDictionaryKey,
        [NSDictionary dictionary],              SWPlcDevicesAltIsFirstDictionaryKey,
        
        nil];
 
    // ho amagatzema en el NSRegistrationDomain, que és a l'ultim que mirarà en cas que no en trobi d'altre.
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    //[appDefaults release] ;
    
}


//------------------------------------------------------------------------------------
- (id)init
{
    if ( (self = [super init] ) )
    {
        
        //BOOL isIpad = NO ;
        
        UIDevice* device = [UIDevice currentDevice];
        BOOL isIpad = ([device userInterfaceIdiom] == UIUserInterfaceIdiomPad) ;
        
		BOOL backgroundSupported = NO;
        if ( [device respondsToSelector:@selector(isMultitaskingSupported)] ) backgroundSupported = [device isMultitaskingSupported];
        
        BOOL ios5 = [UIToolbar respondsToSelector:@selector(appearance)] ;
        
        BOOL isMulti = [[NSProcessInfo processInfo] processorCount] > 1 ;
        
        // ens asegurem de tenir els valors adequats es NO per exemple despres de sincronitzar amb iTunes a partir d'un altre
        if ( backgroundSupported == NO ) [self setMultitaskState:NO] ;
        if ( isIpad == NO ) [self setShowDoubleColumnState:NO] ;
        
        iosIs5 = ios5 ;
        isMultiProcessor = isMulti ;
        deviceIsIpad = isIpad ;
        isMultitaskingSupported = backgroundSupported ;
        shouldAnimateTabBarHide = NO ;
    }
    return self ;
}

//------------------------------------------------------------------------------------
- (BOOL)synchronize
{
    return [[NSUserDefaults standardUserDefaults] synchronize];
}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults - Internes
////////////////////////////////////////////////////////////////////////////////////






//------------------------------------------------------------------------------------
- (BOOL)badOEM
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWOEMDidNotFollowGoodPracticesKey];
}

- (void)setBadOEM:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWOEMDidNotFollowGoodPracticesKey];
}

//------------------------------------------------------------------------------------
- (int)currentVersion
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWCurrentVersionKey];
}

- (void)setCurrentVersion:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWCurrentVersionKey];
}

//------------------------------------------------------------------------------------
- (int)lastCameraPosition
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWLastCameraPositionKey];
}

- (void)setLastCameraPosition:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWLastCameraPositionKey];
}


//------------------------------------------------------------------------------------
- (BOOL)deviceIsIpad
{
    return deviceIsIpad ;
}

//------------------------------------------------------------------------------------
- (BOOL)iosIs5
{
    return iosIs5 ;
}

//------------------------------------------------------------------------------------
- (BOOL)isMultiProcessor
{
    return isMultiProcessor ;
}


//------------------------------------------------------------------------------------
- (BOOL)isMultitaskingSupported
{
    return isMultitaskingSupported ;
}

//------------------------------------------------------------------------------------
- (BOOL)deviceIsFast
{
    return isMultitaskingSupported || deviceIsIpad ;
}

//------------------------------------------------------------------------------------
- (BOOL)shouldParseFiles
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWShouldParseFilesKey];
}

- (void)setShouldParseFiles:(BOOL)value
{
    // la petició de parsejar fitxers implica que el model ja no es valid i que la pròxima 
    // vegada que es necessiti s'haura de carregar dels fitxers parsejats
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWShouldParseFilesKey];
    
    // En cas afirmatiu toquem el model per que s'actualitzi (lazy)
    //if ( value ) [model() pageNodesTouch] ;
}


//------------------------------------------------------------------------------------
- (BOOL)shouldNotiyAPNProvider
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWShouldNotiyAPNProviderKey];
}

- (void)setShouldNotiyAPNProvider:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWShouldNotiyAPNProviderKey];
}



////////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults - Configurables
////////////////////////////////////////////////////////////////////////////////////

////------------------------------------------------------------------------------------
//- (NSString*)currentUser
//{
//    return [[NSUserDefaults standardUserDefaults] stringForKey:SWCurrentUserKey];
//}
//
//- (void)setCurrentUser:(NSString *)value
//{
//    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults] ;
//    NSString *previous = [userDefs stringForKey:SWCurrentUserKey] ;
//    
//    [userDefs setObject:value forKey:SWCurrentUserKey];
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: previous, @"PreviousUser", value, @"CurrentUser", nil] ;
//    [nc postNotificationName:kCurrentUserDidChangeNotification object:nil userInfo:userInfo] ;
//    
//    
////    [nc postNotificationName:kUserSettingsChangedNotification object:nil] ;
//    
//    // quan canviem d'usuari hem de marcar per parsejar doncs pot haver canviat la prioritat
//    // ha de ser al final per evitar que algun viewController que hagi de desapareixer torni a carregar el model
//    [self setShouldParseFiles:YES] ;
//}


//------------------------------------------------------------------------------------
- (UInt32)currentUserIdX
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWCurrentUserIdKey];
}

- (void)setCurrentUserIdX:(UInt32)value
{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults] ;
    //UInt32 previous = [userDefs integerForKey:SWCurrentUserIdKey] ;
    
    [userDefs setInteger:value forKey:SWCurrentUserIdKey];
    
//    {
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @(previous), @"PreviousUser", @(value), @"CurrentUser", nil] ;
//        [nc postNotificationName:kCurrentUserDidChangeNotification object:nil userInfo:userInfo] ;
//    }
    
    // quan canviem d'usuari hem de marcar per parsejar doncs pot haver canviat la prioritat
    // ha de ser al final per evitar que algun viewController que hagi de desapareixer torni a carregar el model
    [self setShouldParseFiles:YES] ;
}



//------------------------------------------------------------------------------------
- (UInt32)lastAuthUserIdX
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWLastAuthUserIdKey];
}

- (void)setLastAuthUserIdX:(UInt32)value
{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults] ;
    [userDefs setInteger:value forKey:SWLastAuthUserIdKey];
}





//------------------------------------------------------------------------------------
- (UInt8)adminAccessLevelX
{
    //return 9 ;
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWAdminAccessLevelKey];
}

- (void)setAdminAccessLevel:(UInt8)value
{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults] ;
    [userDefs setInteger:value forKey:SWAdminAccessLevelKey];
    
//    NSString *user = [userDefs stringForKey:SWCurrentUserKey] ;
//    [self setCurrentUser:user] ;
    
    UInt32 userId = [userDefs integerForKey:SWCurrentUserIdKey] ;
    [self setCurrentUserIdX:userId] ;
}


//------------------------------------------------------------------------------------
- (UInt8)fileAccessLevelX
{
    //return 9 ;
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWFileAccessLevelKey];
}

- (void)setFileAccessLevel:(UInt8)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWFileAccessLevelKey];
}


//------------------------------------------------------------------------------------
- (int)sourceFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWSourceFileSortingOptionsKey];
}

- (void)setSourceFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWSourceFileSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)redeemedSourceFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWRedeemedSourceFileSortingOptionsKey];
}

- (void)setRedeemedSourceFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWRedeemedSourceFileSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)recipeFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWRecipeFileSortingOptionsKey];
}

- (void)setRecipeFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWRecipeFileSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)assetFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWAssetFileSortingOptionsKey];
}

- (void)setAssetFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWAssetFileSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)databaseFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWDatabaseFileSortingOptionsKey];
}

- (void)setDatabaseFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWDatabaseFileSortingOptionsKey];
}


//------------------------------------------------------------------------------------
- (int)remoteSourceFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWRemoteSourceFileSortingOptionsKey];
}

- (void)setRemoteSourceFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWRemoteSourceFileSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)remoteAssetFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWRemoteAssetFileSortingOptionsKey];
}

- (void)setRemoteAssetFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWRemoteAssetFileSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)remoteActivationCodeSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWRemoteActivationCodeSortingOptionsKey];
}

- (void)setRemoteActivationCodeSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWRemoteActivationCodeSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)remoteRedemptionSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWRemoteRedemptionSortingOptionsKey];
}

- (void)setRemoteRedemptionSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWRemoteRedemptionSortingOptionsKey];
}

//------------------------------------------------------------------------------------
- (int)iTunesFileSortingOptions
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWITunesFileSortingOptionsKey];
}

- (void)setITunesFileSortingOptions:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWITunesFileSortingOptionsKey];
}


- (BOOL)pendingMigrate
{
    BOOL pendingMigrate =  [[NSUserDefaults standardUserDefaults] boolForKey:SWPendingMigrateKey];
    return pendingMigrate;
}

- (void)setPendingMigrate:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWPendingMigrateKey];
}


//------------------------------------------------------------------------------------
- (BOOL)hiddenPageSwitcher
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWHiddenPageSwitcherKey];
}

- (void)setHiddenPageSwitcher:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWHiddenPageSwitcherKey];
}


//------------------------------------------------------------------------------------
- (BOOL)hiddenChartAlarmsView
{
    //return hiddenChartAlarmsView;
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWHiddenChartAlarmsViewKey];
}

- (void)setHiddenChartAlarmsView:(BOOL)value
{
    //hiddenChartAlarmsView = value ;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWHiddenChartAlarmsViewKey];
}


//------------------------------------------------------------------------------------
- (int)chartAlarmsViewPage
{
    //return hiddenChartAlarmsView;
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWChartAlarmsViewPageKey];
}

- (void)setChartAlarmsViewPage:(int)value
{
    //hiddenChartAlarmsView = value ;
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWChartAlarmsViewPageKey];
}


//------------------------------------------------------------------------------------
- (BOOL)pushedHomeView
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWPushedHomeViewKey];
}

- (void)setPushedHomeView:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWPushedHomeViewKey];
}


//------------------------------------------------------------------------------------
- (NSString*)currentPageName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWCurrentPageNameKey];
}

- (void)setCurrentPageName:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWCurrentPageNameKey];
}

//------------------------------------------------------------------------------------
- (NSString*)rootPageName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWRootPageNameKey];
}

- (void)setRootPageName:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWRootPageNameKey];
}


//------------------------------------------------------------------------------------
- (NSString*)fileServerPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWFileServerPortKey];
}

- (void)setFileServerPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWFileServerPortKey];
}

//------------------------------------------------------------------------------------
- (NSString*)finsTcpPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWFinsTcpPortKey];
}

- (void)setFinsTcpPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWFinsTcpPortKey];
}

//------------------------------------------------------------------------------------
- (NSString*)finsTcpAltPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWFinsTcpAltPortKey];
}

- (void)setFinsTcpAltPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWFinsTcpAltPortKey];
}

//------------------------------------------------------------------------------------
- (NSString*)modbusTcpPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWModbusTcpPortKey];
}

- (void)setModbusTcpPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWModbusTcpPortKey];
}


//------------------------------------------------------------------------------------
- (NSString*)modbusTcpAltPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWModbusTcpAltPortKey];
}

- (void)setModbusTcpAltPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWModbusTcpAltPortKey];
}


//------------------------------------------------------------------------------------
- (NSString*)eipAltPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWEipAltPortKey];
}

- (void)setEipAltPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWEipAltPortKey];
}

//------------------------------------------------------------------------------------
- (NSString*)siemensS7AltPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWSiemensS7AltPortKey];
}

- (void)setSiemensS7AltPort:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWSiemensS7AltPortKey];
}


//------------------------------------------------------------------------------------
- (NSString*)defaultHostName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SWDefaultHostNameKey];
}

- (void)setDefaultHostName:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWDefaultHostNameKey];
}


//------------------------------------------------------------------------------------
- (NSString*)alternateHostName
{
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:SWAlternateHostNameKey] ;
    return value ;
}

- (void)setAlternateHostName:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWAlternateHostNameKey];
}


//------------------------------------------------------------------------------------
- (BOOL)alternateEnableSSLState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWAlternateEnableSSLStateKey];
}

- (void)setAlternateEnableSSLState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWAlternateEnableSSLStateKey];
}

//------------------------------------------------------------------------------------
- (int)pollingRateOption
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SWPollingRateOptionKey];
}

- (void)setPollingRateOption:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:SWPollingRateOptionKey];
    //[model() updateDefaultPollRates] ;
}


//------------------------------------------------------------------------------------
- (BOOL)enablePageDetentsState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWEnablePageDetentsStateKey];
}

- (void)setEnablePageDetentsState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWEnablePageDetentsStateKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kEnablePageDetentsStateChangedNotification object:nil] ;
}


//------------------------------------------------------------------------------------
- (BOOL)animatePageShiftsState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWAnimatePageShiftsStateKey];
}

- (void)setAnimatePageShiftsState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWAnimatePageShiftsStateKey];
}


//------------------------------------------------------------------------------------
- (BOOL)animateVisibleChangesState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWAnimateVisibleChangesStateKey];
}

- (void)setAnimateVisibleChangesState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWAnimateVisibleChangesStateKey];
}


//------------------------------------------------------------------------------------
- (BOOL)showDoubleColumnState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWShowDoubleColumnStateKey];
}

- (void)setShowDoubleColumnState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWShowDoubleColumnStateKey];
}
//------------------------------------------------------------------------------------
- (BOOL)soundingAlarmsState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWSoundingAlarmsStateKey];
}

- (void)setSoundingAlarmsState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWSoundingAlarmsStateKey];
}

//------------------------------------------------------------------------------------
- (BOOL)alertingAlarmsState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWAlertingAlarmsStateKey];
}

- (void)setAlertingAlarmsState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWAlertingAlarmsStateKey];
}

//------------------------------------------------------------------------------------
- (BOOL)disconnectAlertState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWDisconnectAlertStateKey];
}

- (void)setDisconnectAlertState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWDisconnectAlertStateKey];
}

//------------------------------------------------------------------------------------
- (BOOL)keepConnectedState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWKeepConnectedStateKey];
}

- (void)setKeepConnectedState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWKeepConnectedStateKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kBackgroundConditionsChangedNotification object:nil] ;
}


//------------------------------------------------------------------------------------
- (BOOL)multitaskState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWMultitaskStateKey];
}

- (void)setMultitaskState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWMultitaskStateKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kBackgroundConditionsChangedNotification object:nil] ;
}

//------------------------------------------------------------------------------------
- (float)tickVolume
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:SWTickVolumeKey];
}

- (void)setTickVolume:(float)value
{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:SWTickVolumeKey];
}



//------------------------------------------------------------------------------------
- (NSString*)downloadServerName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SWDownloadServerNameKey];
}

- (void)setDownloadServerName:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWDownloadServerNameKey];
}

//------------------------------------------------------------------------------------
- (NSString*)downloadFileName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SWDownloadFileNameKey];
}

- (void)setDownloadFileName:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWDownloadFileNameKey];
}


////------------------------------------------------------------------------------------
//- (NSString*)activationCodeName
//{
//    return [[NSUserDefaults standardUserDefaults] objectForKey:SWActivationCodeNameKey];
//}
//
//- (void)setActivationCodeName:(NSString*)value
//{
//    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWActivationCodeNameKey];
//}





#warning todo: hauria de mirar el estat del document actual
//------------------------------------------------------------------------------------
- (BOOL)monitoringState
{
    return YES ;
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWMonitoringStateKey];
}

- (void)setMonitoringState:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWMonitoringStateKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kBackgroundConditionsChangedNotification object:nil] ;
}

//------------------------------------------------------------------------------------
- (BOOL)backgroundConditionsAreMet
{
    BOOL monitor = [self monitoringState] ;
    BOOL alwaysConn = [self keepConnectedState] ;
    BOOL multitask = [self multitaskState] ;
    return alwaysConn && multitask && monitor ;
}

//------------------------------------------------------------------------------------
- (BOOL)hiddenTabBar
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWHiddenTabBarKey];
}

- (void)setHiddenTabBar:(BOOL)value
{
	if ( value ) [self setShouldAnimateTabBarHide:YES] ;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWHiddenTabBarKey];
}

//------------------------------------------------------------------------------------
- (BOOL)hiddenFilesTabBar
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWHiddenFilesTabBarKey];
}

- (void)setHiddenFilesTabBar:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWHiddenFilesTabBarKey];
}

//------------------------------------------------------------------------------------
- (BOOL)shouldAnimateTabBarHide
{
    return shouldAnimateTabBarHide ;
}

- (void)setShouldAnimateTabBarHide:(BOOL)value
{
    shouldAnimateTabBarHide = value ;
}


//------------------------------------------------------------------------------------
- (BOOL)hiddenCompanyLogo
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWHiddenCompanyLogoKey];
}

- (void)setHiddenCompanyLogo:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:SWHiddenCompanyLogoKey];
}


//------------------------------------------------------------------------------------

//- (NSArray*)pendingIapReceips
//{
//    NSArray *pendingReceips = [[NSUserDefaults standardUserDefaults] objectForKey:SWStorePendingIapReceipts];
//    return pendingReceips;
//}
//
//- (void)addPendingIapReceipt:(NSString *)value
//{
//    NSArray *theReceipts = [self pendingIapReceips];
//    NSUInteger index = [theReceipts indexOfObject:value];
//    if ( index == NSNotFound )
//    {
//        NSMutableArray *mArray = [NSMutableArray arrayWithArray:theReceipts];
//        [mArray addObject:value];
//        [[NSUserDefaults standardUserDefaults] setObject:mArray forKey:SWStorePendingIapReceipts];
//    }
//}
//
//- (void)removePendingIapReceipt:(NSString *)value
//{
//    NSArray *theReceipts = [self pendingIapReceips];
//    NSUInteger index = [theReceipts indexOfObject:value];
//    if ( index != NSNotFound )
//    {
//        NSMutableArray *mArray = [NSMutableArray arrayWithArray:theReceipts];
//        [mArray removeObjectAtIndex:index];
//        [[NSUserDefaults standardUserDefaults] setObject:mArray forKey:SWStorePendingIapReceipts];
//    }
//}




//- (NSDictionary*)pendingIASProducts
//{
//    NSDictionary *pendingProducts = [[NSUserDefaults standardUserDefaults] objectForKey:SWStorePendingIASProducts];
//    return pendingProducts;
//}
//
//- (NSString*)projectUUIDForPendingIASProduct:(NSString*)product
//{
//    NSDictionary *theProducts = [self pendingIASProducts];
//    NSString *dUUID = [theProducts objectForKey:product];
//    return dUUID;
//}
//
//- (void)addPendingIASProduct:(NSString *)product forProjectUUID:(NSString*)projectID
//{
//    NSDictionary *theProducts = [self pendingIASProducts];
//    NSString *dUUID = [theProducts objectForKey:product];
//    if ( dUUID == nil || ![dUUID isEqualToString:projectID]  )
//    {
//        NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary:theProducts];
//        [mDictionary setObject:projectID forKey:product];
//        [[NSUserDefaults standardUserDefaults] setObject:mDictionary forKey:SWStorePendingIASProducts];
//    }
//}
//
//- (void)removePendingIASProduct:(NSString *)product
//{
//    NSDictionary *theProducts = [self pendingIASProducts];
//    NSString *dUUID = [theProducts objectForKey:product];
//    if ( dUUID != nil )
//    {
//        NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary:theProducts];
//        [mDictionary removeObjectForKey:product];
//        [[NSUserDefaults standardUserDefaults] setObject:mDictionary forKey:SWStorePendingIASProducts];
//    }
//}
//
//
//- (void)moveProjectForProduct:(NSString*)product toPendingReceipt:(NSString*)receipt
//{
//    NSDictionary *theProducts = [self pendingIASProducts];
//    NSString *dUUID = [theProducts objectForKey:product];
//    
//    if ( dUUID != nil )
//    {
//        [self addPendingISReceipt:receipt forProjectUUID:dUUID];
//        [self removePendingIASProduct:product];
//    }
//}
//
////------------------------------------------------------------------------------------
//
//- (NSDictionary*)pendingISReceipts
//{
//    NSDictionary *pendingReceips = [[NSUserDefaults standardUserDefaults] objectForKey:SWStorePendingISReceipts];
//    return pendingReceips;
//}
//
//- (void)addPendingISReceipt:(NSString *)receipt forProjectUUID:(NSString*)projectID
//{
//    NSDictionary *theReceipts = [self pendingISReceipts];
//    NSString *dUUID = [theReceipts objectForKey:receipt];
//    if ( dUUID == nil || ![dUUID isEqualToString:projectID] )
//    {
//        NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary:theReceipts];
//        [mDictionary setObject:projectID forKey:receipt];
//        [[NSUserDefaults standardUserDefaults] setObject:mDictionary forKey:SWStorePendingISReceipts];
//    }
//}
//
//- (void)removePendingISReceipt:(NSString *)receipt
//{
//    NSDictionary *theReceipts = [self pendingISReceipts];
//    NSString *dUUID = [theReceipts objectForKey:receipt];
//    if ( dUUID != nil )
//    {
//        NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary:theReceipts];
//        [mDictionary removeObjectForKey:receipt];
//        [[NSUserDefaults standardUserDefaults] setObject:mDictionary forKey:SWStorePendingISReceipts];
//    }
//}

//- (NSString*)productIdForPendingISReceipt:(NSString*)receipt
//{
//    NSDictionary *theReceipts = [self pendingISReceipts];
//    NSString *dProduct = [theReceipts objectForKey:receipt];
//    return dProduct;
//}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults - Internes
////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (NSDictionary*)validationCodesDictionary
{
    NSDictionary *value = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SWPlcDevicesCodeDictionaryKey] ;
    return value ;
}

- (void)setValidationCodesDictionary:(NSDictionary *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWPlcDevicesCodeDictionaryKey];
}

//------------------------------------------------------------------------------------
- (NSDictionary*)altIsFirstStatesDictionary
{
    NSDictionary *value = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SWPlcDevicesAltIsFirstDictionaryKey] ;
    return value ;
}

- (void)setAltIsFirstStatesDictionary:(NSDictionary *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:SWPlcDevicesAltIsFirstDictionaryKey];
}


@end



////////////////////////////////////////////////////////////////////////////////////
#pragma mark Acces Ràpid a UserDefaults
////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------- 
// userDefaults
//-------------------------------------------------------------------------------------------- 
static UserDefaults *userDefaults = nil ;
UserDefaults *defaults(void) ;
UserDefaults *defaults()
{
    if ( userDefaults == nil ) userDefaults = [[UserDefaults alloc] init] ;
    return userDefaults ;
}
    
//-------------------------------------------------------------------------------------------- 
void defaults_release(void) ;
void defaults_release()
{
    //[userDefaults release] ;
    userDefaults = nil ;
}







