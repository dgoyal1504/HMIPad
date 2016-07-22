//
//  SWAppCloudKitUser.m
//  HmiPad
//
//  Created by joan on 11/08/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWAppCloudKitUser.h"
#import "NSData+SWCrypto.h"
#import "AppModelFilePaths.h"
#import "AppModelCommon.h"

#import "AppUsersModel.h"

@import CloudKit;

@interface SWAppCloudKitUser()
{
    NSMutableArray *_observers; // List of observers
    BOOL _mayAskUserDataUpdate;
    NSString *_identifierForApp;
    //NSMutableSet *_profiles;
}

#define SWProfilesVersionSimple  2
#define SWProfilesVersionWMetadata 3
#define SWProfilesVersionWAllMetadata 4

@end


static NSString *SWUbiquityIdentityToken = @"SWUbiquityIdentityToken";

@implementation SWAppCloudKitUser


- (id)init
{
    self = [super init] ;
    if (self)
    {
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _currentUserProfile = [[UserProfile alloc] initWithUserName:nil];
        
        [self _clearUserProfile];
    }
    return self;
}


- (void)checkICloudAvailabilityNowWithForce:(BOOL)force
{
//    [self _clearUserProfile];               // <-- se suposa que no seria necesari si la notificacio funciones
//    [self _notifyCurrentUserDidLogOut];     // <-- idem
//    [self _testUbiquityIdentityTokenChangeWithNewToken];
    
    
    if ( force || _currentUserProfile.token == nil )
    {
        [self _fetchUserRecordId];    // <-- se suposa que no seria necesari si la notificacio funciones
    }
}


- (void)startICloudAvailabilityNotifications
{
   // [self _testUbiquityIdentityTokenChangeWithNewToken];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_iCloudAccountAvailabilityChanged:) name:NSUbiquityIdentityDidChangeNotification object: nil];
}


#pragma mark - iCloud user change notification




#pragma mark - public


- (BOOL)isIsIcloudReady
{
    return (_currentUserProfile.token != nil);
}


- (CKRecordID*)currentUserRecordId
{
    CKRecordID *recordID = nil;
    
    NSString *recordName = _currentUserProfile.token;
    if ( recordName != nil )
        recordID = [[CKRecordID alloc] initWithRecordName:recordName];
    
    return recordID;
}


- (NSString*)currentUserUUID
{
    NSString *uuid = _currentUserProfile.token;
    return uuid;
}


- (NSString*)identifierForApp
{
    [self _profiles] ;
    if ( _identifierForApp == nil )
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        _identifierForApp = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        NSError *error;
        BOOL done = [self _performSaveAfterActionWithError:&error];
        if ( !done )
        {
            _identifierForApp = nil;
        }
    }
    
    return _identifierForApp;
}



- (BOOL)requiresProfileData
{
    if ( _mayAskUserDataUpdate == NO )
        return NO;

    if ( _currentUserProfile.token != nil && _currentUserProfile.updated == YES )
    { 
        if ( _currentUserProfile.username.length == 0 || _currentUserProfile.email.length == 0 )
        {
            _mayAskUserDataUpdate = NO;
            return YES;
        }
    }
    return NO;
}


- (void)updateWithProfile:(UserProfile*)profile
{
    [self _updateWithProfile:profile completion:nil];
}


#pragma mark - private

- (void)_clearUserProfile
{
    _currentUserProfile.enabled = YES;
    _currentUserProfile.isLocal = YES;
    _currentUserProfile.integrator = YES;
        
    _currentUserProfile.token = nil;
    _currentUserProfile.username = nil;
    _currentUserProfile.email = nil;
    _currentUserProfile.updated = NO;
}


- (void)_profiles
{
    if ( _identifierForApp == nil )
    {
        [self _loadProfilesFromDiskOutError:NULL];
    }
}


- (BOOL)_performSaveAfterActionWithError:(NSError**)outError
{
    return [self _saveProfilesToDiskOutError:outError];
}


- (void)_iCloudAccountAvailabilityChanged:(NSNotification*)note
{
    [self _testUbiquityIdentityTokenChangeWithNewToken];
}


- (void)_testUbiquityIdentityTokenChangeWithNewToken
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id currentICloudToken = [ud objectForKey:SWUbiquityIdentityToken];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    id newICloudToken = [fm ubiquityIdentityToken];
    
    BOOL changed = ![newICloudToken isEqual:currentICloudToken];
    if ( newICloudToken==nil && currentICloudToken==nil ) changed = NO;
    
    
//    [[filesModel() ckContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error)
//    {
//      //
//    }];
    
    
    if ( changed )
    {
        if ( newICloudToken )
        {
            NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:newICloudToken];
            [ud setObject:newTokenData forKey:SWUbiquityIdentityToken];
        }
        else
        {
            [ud removeObjectForKey:SWUbiquityIdentityToken];
        }
    }

    if ( changed )
    {
        _currentUserProfile.token = nil;
        _currentUserProfile.isLocal = YES;
        _currentUserProfile.username = nil;
        _currentUserProfile.email = nil;
        _currentUserProfile.updated = NO;
        [self _notifyCurrentUserDidLogOut];
    }
    
    // APPLE BUG: ubiquityIdentityToken no va.
    
    if ( /*newICloudToken != nil &&*/ _currentUserProfile.token == nil)
    {
        [self _fetchUserRecordId];
    }
}





//- (void)_fetchUserRecordId
//{
//    [[filesModel() ckContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            NSLog( @"accountStatus: %ld", accountStatus );
//            if ( accountStatus == CKAccountStatusAvailable )
//            {
//                [self _fetchUserRecordIdDo];
//            }
//        });
//    }];
//}



- (void)_fetchUserRecordId
{
    [self _notifyCurrentUserWillLogIn];
    //[filesModel() resetCkContainer];
    [[filesModel() ckContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *fetchUserIdError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSError *err = nil;
            if ( fetchUserIdError == nil )
            {
                NSString *recordName = recordID.recordName;
                _currentUserProfile.token = recordName;
                _currentUserProfile.isLocal = !(recordName.length > 0);  // se suposa que sempre es NO en aquest punt
            }
            else
            {
                _currentUserProfile.token = nil;
                _currentUserProfile.isLocal = YES;
                
                NSLog(@"%@ Could not log in with iCloud user, error:%@", NSStringFromSelector(_cmd), fetchUserIdError);
                NSString *title = NSLocalizedString(@"iCloud User", nil);
                
                if ( HMiPadRun )
                    title = nil;
                
                NSString  *message = NSLocalizedString(@"Could not log into iCloud. You can create a new account or log into iCloud from the Settings app. You must also have iCloud Drive enabled for this app on the Settings app", nil);
                err = _errorWithLocalizedDescription_title(message, title);
            }
        
            [self _notifyCurrentUserDidLogInWithError:err];
            
            if ( err == nil )
            {
                [self _testUserRecordWithRecordId:recordID];
            }
        });
    }];
}


//- (void)_fetchUserRecordWithRecordId:(CKRecordID*)recordID
//{
//    [self _notifyCurrentUserWillFetchUserData];
//    [[filesModel() ckDatabase] fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *fetchUserRecordError)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            NSError *err = nil;
//            BOOL shouldMigrate = NO;
//            if ( fetchUserRecordError == nil )
//            {
//                _currentUserProfile.username = [record objectForKey:@"atr01_username"];
//                _currentUserProfile.email = [record objectForKey:@"atr02_email"];
//                _currentUserProfile.userId = [[record objectForKey:@"atr05_IntegratorsServerID"] intValue];
////                UInt64 flags = [[record objectForKey:@"atr04_flags"] longLongValue];
////                shouldMigrate = (flags&1) != 0;
//            }
//            else
//            {
//                _currentUserProfile.username = nil;
//                _currentUserProfile.email = nil;
//                _currentUserProfile.userId = 0;
//                NSLog(@"%@ Could not fetch User Data, error:%@", NSStringFromSelector(_cmd), fetchUserRecordError);
//                NSString *title = NSLocalizedString(@"iCloud User", nil);
//                NSString  *message = NSLocalizedString(@"Could not fetch iCloud User data", nil);
//                err = _errorWithLocalizedDescription_title(message, title);
//            }
//            [self _notifyCurrentUserDidFetchUserDataWithError:err];
//            //if ( shouldMigrate ) [self _notifyCurrentUserRequiresMigration];
//        });
//    }];
//}




- (void)_testUserRecordWithRecordId:(CKRecordID*)recordID
{

    // provem d'escriure en el record del usuari. El recordID que ens passen esta obtingut de cloudKit, pero si el usuari ha canviat el seu compte de iCloud,
    // cloudKit encara es pensa que es el anterior, i per tant la escritura falla.

    CKRecord *userRecord = [[CKRecord alloc] initWithRecordType:@"Users" recordID:recordID];
    [userRecord setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"testDate"];
    
    CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[userRecord] recordIDsToDelete:nil];
    
    [modifyOperation setSavePolicy:CKRecordSaveChangedKeys];

    [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords, NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSError *err = nil;
            if ( operationError == nil )
            {
                _mayAskUserDataUpdate = YES;
            }
            else
            {
                _currentUserProfile.token = nil;
                _currentUserProfile.isLocal = YES;
                NSLog(@"%@ Could not test User, error:%@", NSStringFromSelector(_cmd), operationError);
                NSString *title = NSLocalizedString(@"iCloud User", nil);
                NSString  *message = NSLocalizedString(@"\nCould not verify current HMI Pad iCloud user.\n\nMaybe you changed your iCloud user on the Settings app while " AppName " was running. This will prevent Integrator Service operations to work.\n\nPlease shut down " AppName " completely before editing your iCloud user account", nil);
                err = _errorWithLocalizedDescription_title(message, title);
                [self _notifyCurrentUserDidLogInWithError:err];
            }
            
            if ( err == nil )
            {
                [self _fetchUserRecordWithRecordId:recordID];
            }
        });
    }];
    
    [[filesModel() ckDatabase] addOperation:modifyOperation];
}




- (void)_fetchUserRecordWithRecordId:(CKRecordID*)recordID
{
    [self _notifyCurrentUserWillFetchUserData];
    
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[recordID]];
    fetchOperation.desiredKeys = nil;
    
    [fetchOperation setPerRecordCompletionBlock:^(CKRecord *r, CKRecordID *rID, NSError *perRecordCompletionBlock)
    {
        if ( perRecordCompletionBlock != nil )
        {
            NSLog(@"%@ Could not fetch User Data, error:%@", NSStringFromSelector(_cmd), perRecordCompletionBlock);
        }
    }];
    
    [fetchOperation setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *operationError)
    {
        CKRecord *record = [[recordsByRecordID allValues] firstObject];
    
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSError *err = nil;
            //BOOL shouldMigrate = NO;
            if ( operationError == nil )
            {
                NSString *username = [record objectForKey:@"atr01_username"];
                NSString *email = [record objectForKey:@"atr02_email"];
                _currentUserProfile.username = username;
                _currentUserProfile.email = email;
                _currentUserProfile.userId = [[record objectForKey:@"atr05_IntegratorsServerID"] intValue];
                _currentUserProfile.migrated = [[record objectForKey:@"atr04_flags"] boolValue];
                _currentUserProfile.updated = YES;
//                UInt64 flags = [[record objectForKey:@"atr04_flags"] longLongValue];
//                shouldMigrate = (flags&1) != 0;

                [self _notifyShouldAskUserData];
            }
            else
            {
                _currentUserProfile.username = nil;
                _currentUserProfile.email = nil;
                _currentUserProfile.userId = 0;
                _currentUserProfile.migrated = NO;
                _currentUserProfile.updated = NO;
                
                NSLog(@"%@ Could not fetch User Data, error:%@", NSStringFromSelector(_cmd), operationError);
                NSString *title = NSLocalizedString(@"iCloud User", nil);
                NSString  *message = NSLocalizedString(@"Could not fetch iCloud User data", nil);
                err = _errorWithLocalizedDescription_title(message, title);
                
                if ( [operationError.domain isEqualToString:NSCocoaErrorDomain] )
                {
                    _currentUserProfile.token = nil;
                    _currentUserProfile.isLocal = YES;
                    [self _notifyCurrentUserDidLogInWithError:err];
                }
            }
            [self _notifyCurrentUserDidFetchUserDataWithError:err];
            //if ( shouldMigrate ) [self _notifyCurrentUserRequiresMigration];
        });
    }];
    
     [[filesModel() ckDatabase] addOperation:fetchOperation];
}


- (void)_updateWithProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion
{
    NSString *recordName = _currentUserProfile.token;
    
    if ( recordName.length > 0 )
    {
        CKRecordID *userRecordID = [[CKRecordID alloc] initWithRecordName:recordName];
        CKRecord *userRecord = [[CKRecord alloc] initWithRecordType:@"Users" recordID:userRecordID];
        
        [userRecord setObject:profile.username forKey:@"atr01_username"];
        [userRecord setObject:profile.email forKey:@"atr02_email"];
        [userRecord setObject:@(profile.userId) forKey:@"atr05_IntegratorsServerID"];
       // [userRecord setObject:@(profile.migrated) forKey:@"atr04_flags"];
        
        // touchDate
        [userRecord setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"touchDate"];
    
        CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[userRecord] recordIDsToDelete:nil];
        
        [modifyOperation setSavePolicy:CKRecordSaveChangedKeys];
        
        [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords, NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
        {
            CKRecord *record = savedRecords.firstObject;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                NSError *err = nil;
                if ( operationError == nil )
                {
                    _currentUserProfile.username = [record objectForKey:@"atr01_username"];
                    _currentUserProfile.email = [record objectForKey:@"atr02_email"];
                    _currentUserProfile.userId = [[record objectForKey:@"atr05_IntegratorsServerID"] intValue];
                    //_currentUserProfile.migrated = [[record objectForKey:@"atr04_flags"] boolValue];
                    _currentUserProfile.updated = YES;
                }
                else
                {
                    _currentUserProfile.username = nil;
                    _currentUserProfile.email = nil;
                    _currentUserProfile.userId = 0;
                    _currentUserProfile.migrated = NO;
                    _currentUserProfile.updated = NO;
                    NSLog(@"%@ Could not save User Data, error:%@", NSStringFromSelector(_cmd), operationError);
                    NSString *title = NSLocalizedString(@"iCloud User", nil);
                    NSString  *message = NSLocalizedString(@"Could not save iCloud User data", nil);
                    err = _errorWithLocalizedDescription_title(message, title);
                }

                [self _notifyCurrentUserDidUpdateUserDataWithError:err];
                if (completion ) completion( err == nil );
            });
        }];
        
        [self _notifyCurrentUserWillUpdateUserData];
        [[filesModel() ckDatabase] addOperation:modifyOperation];
    }
}


- (void)_updateMigratedWithProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion
{
    NSString *recordName = _currentUserProfile.token;
    
    if ( recordName.length > 0 )
    {
        CKRecordID *userRecordID = [[CKRecordID alloc] initWithRecordName:recordName];
        CKRecord *userRecord = [[CKRecord alloc] initWithRecordType:@"Users" recordID:userRecordID];
        
        [userRecord setObject:@(profile.migrated) forKey:@"atr04_flags"];
        
        // touchDate
        [userRecord setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"touchDate"];
    
        CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[userRecord] recordIDsToDelete:nil];
        
        [modifyOperation setSavePolicy:CKRecordSaveChangedKeys];
        
        [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords, NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
        {
            CKRecord *record = savedRecords.firstObject;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                NSError *err = nil;
                if ( operationError == nil )
                {
                    _currentUserProfile.migrated = [[record objectForKey:@"atr04_flags"] boolValue];
                }
                else
                {
                    _currentUserProfile.username = nil;
                    _currentUserProfile.email = nil;
                    _currentUserProfile.userId = 0;
                    _currentUserProfile.migrated = NO;
                    _currentUserProfile.updated = NO;
                    NSLog(@"%@ Could not save User Data, error:%@", NSStringFromSelector(_cmd), operationError);
                    NSString *title = NSLocalizedString(@"iCloud User", nil);
                    NSString  *message = NSLocalizedString(@"Could not save iCloud User data", nil);
                    err = _errorWithLocalizedDescription_title(message, title);
                }

                [self _notifyCurrentUserDidUpdateUserDataWithError:err];
                if (completion ) completion( err == nil );
            });
        }];
        
        [self _notifyCurrentUserWillUpdateUserData];
        [[filesModel() ckDatabase] addOperation:modifyOperation];
    }

}



- (BOOL)_loadProfilesFromDiskOutError:(NSError**)outError
{
    NSLog1( @"Model loadProfilesFromDisk" ) ;

    // alliberem els profiles actuals doncs en crearem uns de nous
    _identifierForApp = nil ;
    
    // admetem NULL com a entrada de outError, per tant en creem un de temporal
    NSError *error = nil ;
    
    // paths check
    NSString *fileName = [filesModel().filePaths userAccountsFilePathCryptCK];
    {  
        //NSData *dataArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0/*NSUncachedRead*/ error:&error];
        
        NSData *cryptArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0/*NSUncachedRead*/ error:&error];
        NSData *dataArchive = [cryptArchive decryptWithKey:[@"remoteEnabled" stringByAppendingString:@AppName]];
        
        // read chek
        if ( dataArchive )
        {
            QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:dataArchive];
            int version = [unarchiver version] ;
            
            if ( version == SWProfilesVersionWAllMetadata )
            {
                NSDictionary *metadata = [unarchiver decodeObject];
                _identifierForApp = _dict_objectForKey(metadata, @"appID");
            }
            
            return YES;
        }
    }
    
    // No ha anat be:
    
    // actualitzem el error si no es NULL i torna NO
    if ( outError != NULL ) *outError = error ;
    return NO;
}


- (BOOL)_saveProfilesToDiskOutError:(NSError**)outError
{
    NSError *error;
    NSString *fileName = [filesModel().filePaths userAccountsFilePathCryptCK];
    
    {
        NSDictionary *metadata = @
        {
            @"appID" : _identifierForApp?_identifierForApp:[NSNull null],
        };
    
        // write
        NSMutableData *dataArchive = [[NSMutableData alloc] init] ;
    
        QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:dataArchive version:SWProfilesVersionWAllMetadata] ;
        [archiver encodeObject:metadata];
        [archiver finishEncoding];
        
        NSData *cryptArchive = [dataArchive encryptWithKey:[@"remoteEnabled" stringByAppendingString:@AppName]];
        
        BOOL didWrite = [cryptArchive writeToFile:fileName options:NSDataWritingFileProtectionComplete|NSAtomicWrite error:&error] ;
        
        // write check
        if ( didWrite )
        {
            return YES ;
        }
    }
    
    NSLog( @"Could not save profiles:%@", error.localizedDescription );
    
    if ( outError ) *outError = error;
    return NO;
}



#pragma mark - observer notification

- (void)_notifyCurrentUserDidLogOut
{
    NSLog( @"Notify _notifyCurrentUserDidLogOut" );

    _isLoggingIn = NO;
    _isUpdatingProfile = NO;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUserCurrentUserLogOut:)] )
        {
            [observer cloudKitUserCurrentUserLogOut:self];
        }
    }
}


- (void)_notifyCurrentUserWillLogIn
{
    NSLog( @"Notify _notifyCurrentUserWillLogIn: %@", _currentUserProfile.token );

    _isLoggingIn = YES;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUserCurrentUserWillLogIn:)] )
        {
            [observer cloudKitUserCurrentUserWillLogIn:self];
        }
    }
}


- (void)_notifyCurrentUserDidLogInWithError:(NSError*)error
{
    NSLog( @"Notify _notifyCurrentUserDidLogIn: %@", _currentUserProfile.token );
    
    _isLoggingIn = NO;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUser:currentUserDidLoginWithError:)] )
        {
            [observer cloudKitUser:self currentUserDidLoginWithError:error];
        }
    }
}


- (void)_notifyCurrentUserWillFetchUserData
{
    NSLog( @"Notify _notifyCurrentUserWillFetchUserData: %@, %@", _currentUserProfile.username, _currentUserProfile.email );
    
    _isUpdatingProfile = YES;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUserWillFetchUserData:)] )
        {
            [observer cloudKitUserWillFetchUserData:self];
        }
    }
}


- (void)_notifyCurrentUserDidFetchUserDataWithError:(NSError*)error
{
    NSLog( @"Notify _notifyCurrentUserDidFetchUserData: %@, %@", _currentUserProfile.username, _currentUserProfile.email );
    
    _isUpdatingProfile = NO;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUser:didFetchUserDataWithError:)] )
        {
            [observer cloudKitUser:self didFetchUserDataWithError:error];
        }
    }
}


- (void)_notifyShouldAskUserData
{
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUserShouldAskUserData:)] )
        {
            [observer cloudKitUserShouldAskUserData:self];
        }
    }
}

- (void)_notifyCurrentUserWillUpdateUserData
{
    NSLog( @"Notify _notifyCurrentUserWillFetchUserData: %@, %@", _currentUserProfile.username, _currentUserProfile.email );
    
    _isUpdatingProfile = YES;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUserWillUpdateUserData:)] )
        {
            [observer cloudKitUserWillUpdateUserData:self];
        }
    }
}


- (void)_notifyCurrentUserDidUpdateUserDataWithError:(NSError*)error
{
    NSLog( @"Notify _notifyCurrentUserDidFetchUserData: %@, %@", _currentUserProfile.username, _currentUserProfile.email );
    
    _isUpdatingProfile = NO;
    NSArray *observersCopy = [_observers copy];
    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(cloudKitUser:didUpdateUserDataWithError:)] )
        {
            [observer cloudKitUser:self didUpdateUserDataWithError:error];
        }
    }
}


//- (void)_notifyCurrentUserRequiresMigration
//{
//    NSLog( @"Notify _notifyCurrentUserDidFetchUserData: %@, %@", _currentUserProfile.username, _currentUserProfile.email );
//    
//    _isUpdatingProfile = NO;
//    NSArray *observersCopy = [_observers copy];
//    for ( id<SWAppCloudKitUserObserver>observer in observersCopy )
//    {
//        if ( [observer respondsToSelector:@selector(cloudKitUserRequireMigration:)] )
//        {
//            [observer cloudKitUserRequireMigration:self];
//        }
//    }
//}


#pragma mark - observation

- (void)addObserver:(id<SWAppCloudKitUserObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<SWAppCloudKitUserObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}



#pragma mark acces a appCloudKitUser

static SWAppCloudKitUser *_appCloudKitUser = nil ;

SWAppCloudKitUser *cloudKitUser(void)
{
    if ( _appCloudKitUser == nil ) _appCloudKitUser = [[SWAppCloudKitUser alloc] init] ;
    return _appCloudKitUser ;
}


//void _appCloudKitUser_release(void)
//{
//    _appCloudKitUser = nil ;
//}

@end

@implementation SWAppCloudKitUser(migrate)

- (void)migrateIdentifierForApp
{
    NSString *idforapp = [usersModel() identifierForApp];
    if ( idforapp.length > 0 )
    {
        _identifierForApp = idforapp;
        BOOL done = [self _performSaveAfterActionWithError:NULL];
        if ( !done )
        {
            _identifierForApp = nil;
        }
    }
}



- (BOOL)currentUserHasMigrated
{
    BOOL hasMigrated = _currentUserProfile.userId != 0 && _currentUserProfile.migrated == YES;
    return hasMigrated;
}


- (void)setMigratedForProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion
{
    UserProfile *migratedProfile = [profile getProfileCopy];
    migratedProfile.migrated = YES;
    [self _updateMigratedWithProfile:migratedProfile completion:completion];
}



@end

