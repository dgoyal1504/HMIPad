//
//  UseDefaults.h
//  iPhoneDomus
//
//  Created by Joan on 19/07/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
// Objecte que conté els user defaults
//------------------------------------------------------------------------------------
@interface UserDefaults : NSObject
{
    //NSString *currentUser;
    //BOOL automaticLogin;
    //BOOL monitoringState;
    //BOOL hiddenChartAlarmsView ;
    BOOL deviceIsIpad ;
    BOOL iosIs5 ;
    BOOL isMultiProcessor ;
    BOOL isMultitaskingSupported ;
    BOOL shouldAnimateTabBarHide;
}

// internes

@property (nonatomic, assign, readonly) BOOL deviceIsIpad ;
@property (nonatomic, assign, readonly) BOOL iosIs5 ;
@property (nonatomic, assign, readonly) BOOL isMultiProcessor ;
@property (nonatomic, assign, readonly) BOOL isMultitaskingSupported ;
@property (nonatomic, assign, readonly) BOOL deviceIsFast ;
@property (nonatomic, assign) BOOL badOEM ;
@property (nonatomic, assign) int currentVersion ;
@property (nonatomic, assign) int lastCameraPosition ;
//@property (nonatomic, assign) BOOL shouldParseFiles;
@property (nonatomic, assign) BOOL shouldNotiyAPNProvider;

// configurables o que depenen de setings d'usuari

@property (nonatomic, assign) UInt32 currentUserIdX;
@property (nonatomic, assign) UInt32 lastAuthUserIdX;
@property (nonatomic, assign) UInt8 adminAccessLevelX;
@property (nonatomic, assign) UInt8 fileAccessLevel;


@property (nonatomic, assign) int sourceFileSortingOptions;
@property (nonatomic, assign) int redeemedSourceFileSortingOptions;
@property (nonatomic, assign) int assetFileSortingOptions;
@property (nonatomic, assign) int recipeFileSortingOptions;
@property (nonatomic, assign) int databaseFileSortingOptions;

@property (nonatomic, assign) int remoteSourceFileSortingOptions;
@property (nonatomic, assign) int remoteAssetFileSortingOptions;
@property (nonatomic, assign) int remoteActivationCodeSortingOptions;
@property (nonatomic, assign) int remoteRedemptionSortingOptions;

@property (nonatomic, assign) int iTunesFileSortingOptions;

@property (nonatomic, assign) BOOL pendingMigrate;


@property (nonatomic, assign) int chartAlarmsViewPage;    // -1 indica cap
@property (nonatomic, assign) BOOL hiddenChartAlarmsView;
@property (nonatomic, assign) BOOL pushedHomeView;
//@property (nonatomic, assign) int currentPageNumber ;
@property (nonatomic, assign) NSString *currentPageName ;
@property (nonatomic, assign) NSString *rootPageName ;
@property (nonatomic, assign) BOOL hiddenPageSwitcher;
@property (nonatomic, assign) NSString *fileServerPort ;

@property (nonatomic, assign) NSString *finsTcpPort ;
@property (nonatomic, assign) NSString *finsTcpAltPort ;

@property (nonatomic, assign) NSString *modbusTcpPort ;
@property (nonatomic, assign) NSString *modbusTcpAltPort ;

@property (nonatomic, assign) NSString *eipAltPort ;
@property (nonatomic, assign) NSString *siemensS7AltPort ;

@property (nonatomic, assign) NSString *defaultHostName ;
@property (nonatomic, assign) NSString *alternateHostName ;
@property (nonatomic, assign) BOOL alternateEnableSSLState ;
@property (nonatomic, assign) int pollingRateOption ;

@property (nonatomic, assign) BOOL enablePageDetentsState ;
@property (nonatomic, assign) BOOL animateVisibleChangesState ;
@property (nonatomic, assign) BOOL animatePageShiftsState ;
@property (nonatomic, assign) BOOL showDoubleColumnState ;


@property (nonatomic, assign) BOOL soundingAlarmsState ;
@property (nonatomic, assign) BOOL alertingAlarmsState ;
@property (nonatomic, assign) BOOL disconnectAlertState ;
@property (nonatomic, assign) BOOL keepConnectedState ;
@property (nonatomic, assign) BOOL multitaskState ;
@property (nonatomic, assign) float tickVolume ;

@property (nonatomic, assign) NSString *downloadServerName ;
@property (nonatomic, assign) NSString *downloadFileName ;
//@property (nonatomic, assign) NSString *activationCodeName ;

@property (nonatomic, assign) BOOL monitoringState;
@property (nonatomic, assign, readonly) BOOL backgroundConditionsAreMet;
@property (nonatomic, assign) BOOL hiddenTabBar;
@property (nonatomic, assign) BOOL hiddenFilesTabBar;
@property (nonatomic, assign) BOOL shouldAnimateTabBarHide;
@property (nonatomic, assign) BOOL hiddenCompanyLogo;

//@property (nonatomic, assign) int storeProducts ; // cada bit indica un producte que s'ha comprat


//// Diccionari de receipts pendents de processar al Integrators Service, conte productID:projectId
//- (NSDictionary*)pendingIASProducts; // keys son productID, values son projectUUIDs
////- (NSString*)projectUUIDForPendingIASProduct:(NSString*)product;
//- (void)addPendingIASProduct:(NSString *)product forProjectUUID:(NSString*)uuid;
//- (void)removePendingIASProduct:(NSString *)product;
//
//// Diccionari de receipts pendents de processar al Integrators Service, conte receipt:projectId
//- (NSDictionary*)pendingISReceipts;  // keys son receipts, values son projectIds
//- (void)addPendingISReceipt:(NSString *)receipt forProjectUUID:(NSString*)projectID;
//- (void)removePendingISReceipt:(NSString *)receipt;
//
//// Transfereix un Producte Pendent a un Receipt pendent
//- (void)moveProjectForProduct:(NSString*)product toPendingReceipt:(NSString*)receipt;

// sourceElements

@property (nonatomic, assign) NSDictionary *validationCodesDictionary;
@property (nonatomic, assign) NSDictionary *altIsFirstStatesDictionary;

// per recordar el mal comportament d'un OEM


// altres

//- (PlcDevice *)defaultPlcDevice ;
- (BOOL)synchronize;


@end

extern NSString *kBackgroundConditionsChangedNotification ;
extern NSString *kEnablePageDetentsStateChangedNotification ;

////////////////////////////////////////////////////////////////////////////////////
#pragma mark Acces Ràpid a UserDefaults
////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------- 
// Funcions per accès ràpid als defaults
//-------------------------------------------------------------------------------------------- 
extern UserDefaults *defaults() ;
extern void defaults_release() ;














