//
//  AppUsersModel.m
//  HMiPad
//
//  Created by Joan on 19/07/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import "AppUsersModel.h"

#import "AppModelFilesEx.h"
#import "AppModelFilePaths.h"

#import "SWAppDelegate.h"

#import "UserDefaults.h"
#import "HMiPadServerAPIClient.h"
#import "AFJSONRequestOperation.h"

#import "NSData+SWCrypto.h"

// comment out one of the two
//#define NSLog1(...) {}
//#define NSLog1(args...) NSLog(args)

NSString *kCurrentUserDidChangeNotification = @"CurrentUserDidChangedNotification" ;

#pragma mark AppUsersModel


@interface AppUsersModel()
@end

@implementation AppUsersModel
{
    BOOL _shouldGetFromUserDefaults;
}



#pragma mark Debug

//------------------------------------------------------------------------------------
- (void) printProfiles
{
//    for ( NSString *name in _profiles )
//    {
//        NSLog1( @"DomusModel printProfiles name: %@", name ) ;
//        UserProfile *profile = [_profiles objectForKey:name] ;
//        [profile print] ;
//    }
    
    for ( UserProfile *profile in _profiles )
    {
        [profile print];
    }
}

#pragma mark - File Model observation

- (void)addObserver:(id<AppUsersModelObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<AppUsersModelObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}



#pragma mark Profiles

//------------------------------------------------------------------------------------
- (NSMutableSet *)defaultProfiles
{
    NSMutableSet *allProfiles = [NSMutableSet set];

    UserProfile *aProfile ;
    
//#if OEM && !HMiPadDev
//    // usuari per defecte per OEMs i no integradors
//    aProfile = [[UserProfile alloc] initWithUserName:@ SWDefaultUser] ;
//    [aProfile setPassword:@ SWDefaultUserPass ];
//    [aProfile setEnabled:YES];
//    [aProfile setIsLocal:YES];
//    [aProfile setUpdated:YES];
//    [aProfile setIntegrator:YES];
//    aProfile.userId = SWEndUserId;
//    [aProfile setLevel:9];
//    //[allProfiles setObject:aProfile forKey:DefaultUser ];
//    [allProfiles addObject:aProfile];
//#endif

//#if !OEMFree

#if HMiPadDev

    // usuari integrator (per tots excepte OEMs gratuits)
    aProfile = [[UserProfile alloc] initWithUserName:@ SWDefaultUser];
    [aProfile setPassword:@ SWDefaultUserPass ];
    [aProfile setEnabled:YES];
    [aProfile setIsLocal:YES];
    [aProfile setUpdated:YES];
    aProfile.userId = SWDefaultUserId;
    
    [aProfile setIntegrator:YES];
    [aProfile setLevel:9];
    [allProfiles addObject:aProfile];
//#endif

#elif HMiPadRun
//#if !OEM || HMiPadDev
    // usuari enduser per no OEMS i Integradors
    aProfile = [[UserProfile alloc] initWithUserName:@ SWDefaultUser];
    [aProfile setPassword:@ SWDefaultUserPass];
    [aProfile setEnabled:YES];
    [aProfile setIsLocal:YES];
    [aProfile setUpdated:YES];
    aProfile.userId = SWDefaultUserId;
    
    [aProfile setIntegrator:NO];
    [aProfile setLevel:0];
    [allProfiles addObject:aProfile];

#endif

    return allProfiles ;
}


#define SWProfilesVersionSimple  2
#define SWProfilesVersionWMetadata 3

////------------------------------------------------------------------------------------
//- (BOOL)_loadProfilesFromDiskOutErrorOLD:(NSError**)outError
//{
//    NSLog1( @"Model loadProfilesFromDisk" ) ;
//
//    // alliberem els profiles actuals doncs en crearem uns de nous
//    _profiles = nil ;
//    
//    // admetem NULL com a entrada de outError, per tant en creem un de temporal
//    NSError *error = nil ;
//    
//    
//    // paths check
//    NSString *fileName = [filesModel() userAccountsFilePath] ;
//    
//    if ( fileName != nil )
//    {  
//        NSData *dataArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0/*NSUncachedRead*/ error:&error];
//        
//        // read chek
//        if ( dataArchive )
//        {
//            QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:dataArchive];
//            int version = [unarchiver version] ;
//            if ( version == SWProfilesVersionSimple ) //NSAssert( false, @"Profiles de usuari versio incorrecta" ) ;
//            {
//                _automaticLogin = [unarchiver decodeInt] ;
//                _profiles = [unarchiver decodeObject];
//            }
//            // unarchive check
//            if ( _profiles ) 
//            {
//                return YES ;
//            }
//                
//            NSString *errMsg = NSLocalizedString(@"Inconsistent or corrupted user profiles file", nil) ;
//            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
////            error = [NSError errorWithDomain:@"com.SweetWilliam.ScadaMobile" code:1 userInfo:info];
//            error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:1 userInfo:info];
//        }
//    }
//   
//    // crea els profiles per defecte
//    _profiles = [self defaultProfiles];
//    
//    // actualitza el error si no es NULL i torna NO    
//    if ( outError != NULL ) *outError = error ;
//    return NO;
//}


//------------------------------------------------------------------------------------
- (BOOL)_loadProfilesFromDiskOutError:(NSError**)outError
{
    NSLog1( @"Model loadProfilesFromDisk" ) ;

    // alliberem els profiles actuals doncs en crearem uns de nous
    _profiles = nil ;
    
    // admetem NULL com a entrada de outError, per tant en creem un de temporal
    NSError *error = nil ;
    
    
    // paths check
    NSString *fileNameNoCr = [filesModel().filePaths userAccountsFilePath] ;
    NSString *fileName = [filesModel().filePaths userAccountsFilePathCrypt];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ( [fm fileExistsAtPath:fileNameNoCr] )
    {
        // load and remove old file
        NSData *dataArchive = [[NSData alloc] initWithContentsOfFile:fileNameNoCr options:0 error:nil];
        [fm removeItemAtPath:fileNameNoCr error:nil];
        
        // encript and save new file
        NSData *cryptArchive = [dataArchive encryptWithKey:[@"remoteEnabled" stringByAppendingString:@AppName]];
        [cryptArchive writeToFile:fileName options:NSDataWritingFileProtectionComplete|NSAtomicWrite error:&error];
    }
    
    
    if ( fileName != nil )
    {  
        //NSData *dataArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0/*NSUncachedRead*/ error:&error];
        
        NSData *cryptArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0/*NSUncachedRead*/ error:&error];
        NSData *dataArchive = [cryptArchive decryptWithKey:[@"remoteEnabled" stringByAppendingString:@AppName]];
        
        // read chek
        if ( dataArchive )
        {
            //NSNumber *projectUserEnabledObj = nil;
            NSNumber *currentUserIDObj = nil;
            
            QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:dataArchive];
            int version = [unarchiver version] ;
            if ( version == SWProfilesVersionSimple ) //NSAssert( false, @"Profiles de usuari versio incorrecta" ) ;
            {
                _automaticLogin = [unarchiver decodeInt] ;
                _identifierForApp = nil;
                _profiles = [unarchiver decodeObject];
            }
            
            else if ( version == SWProfilesVersionWMetadata )
            {
                NSDictionary *metadata = [unarchiver decodeObject];
                _automaticLogin = [_dict_objectForKey(metadata, @"autoLogin") boolValue];
                
//                projectUserEnabledObj = _dict_objectForKey(metadata, @"projectUserEnabled");
//                _projectUserEnabled = [projectUserEnabledObj boolValue];
//                
//                if ( projectUserEnabledObj == nil )
//                    _projectUserEnabled = NO;
                
                currentUserIDObj = _dict_objectForKey(metadata, @"currentUserID");
                _currentUserID = (UInt32)[currentUserIDObj integerValue];
                
                if ( currentUserIDObj == nil )
                    _shouldGetFromUserDefaults = YES;
    
                _identifierForApp = _dict_objectForKey(metadata, @"appID");
                
                _lastAuthUserID = (UInt32)[_dict_objectForKey(metadata, @"lastUserID") integerValue];
                _adminAccessLevel = [_dict_objectForKey(metadata, @"adminAccessLevel") integerValue];
                
                _profiles = [unarchiver decodeObject];
                
            }
            
            // unarchive check
            if ( _profiles ) 
            {
                return YES;
            }
                
            NSString *errMsg = NSLocalizedString(@"Inconsistent or corrupted user profiles file", nil) ;
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//            error = [NSError errorWithDomain:@"com.SweetWilliam.ScadaMobile" code:1 userInfo:info];
            error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:1 userInfo:info];
        }
    }
    
    // No ha anat be:
    
    // creem els profiles per defecte
    _profiles = [self defaultProfiles];
    _currentUserID = SWDefaultUserId;
    
    // actualitzem el error si no es NULL i torna NO
    if ( outError != NULL ) *outError = error ;
    return NO;
}



//------------------------------------------------------------------------------------
- (BOOL)_saveProfilesToDiskOutError:(NSError**)outError
{
    NSError *error;
    NSString *fileName = [filesModel().filePaths userAccountsFilePathCrypt];
    
    // paths check
    if ( fileName != nil )
    {
        NSDictionary *metadata = @
        {
            @"autoLogin" : @(_automaticLogin),
            //@"projectUserEnabled" : @(_projectUserEnabled),
            @"currentUserID" : @(_currentUserID),
            @"appID" : _identifierForApp?_identifierForApp:[NSNull null],
            @"lastAuthUserID" : @(_lastAuthUserID),
            @"adminAccessLevel": @(_adminAccessLevel),
        };
    
        // write
        NSMutableData *dataArchive = [[NSMutableData alloc] init] ;
    
        QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:dataArchive version:SWProfilesVersionWMetadata] ;
        [archiver encodeObject:metadata];
        [archiver encodeObject:_profiles] ;
        [archiver finishEncoding] ;
        
        NSData *cryptArchive = [dataArchive encryptWithKey:[@"remoteEnabled" stringByAppendingString:@AppName]];
        
        BOOL didWrite = [/*dataArchive*/ cryptArchive writeToFile:fileName options:NSDataWritingFileProtectionComplete|NSAtomicWrite error:&error] ;
        
        // write check
        if ( didWrite )
        {
            _shouldGetFromUserDefaults = NO;
            return YES ;
        }
    }
    
    NSLog( @"Could not save profiles:%@", error.localizedDescription );
    
    if ( outError ) *outError = error;
    return NO;
}


- (BOOL)_performSaveAfterActionWithError:(NSError**)outError
{
    return [self _saveProfilesToDiskOutError:outError];
}


- (NSMutableSet*)profiles
{
    if ( _profiles == nil ) [self _loadProfilesFromDiskOutError:NULL] ;
    return _profiles ;
}


- (void)_deleteProfilesFromDisk
{
    NSString *fileName = [filesModel().filePaths userAccountsFilePath] ;
    NSError *error ;
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error] ;   //gestioerror
}


- (BOOL)automaticLogin
{
    [self profiles] ;
    return _automaticLogin;
}


- (BOOL)setAutomaticLogin:(BOOL)value error:(NSError**)outError
{
    _automaticLogin = value ;
    BOOL done = [self _performSaveAfterActionWithError:outError];
    if ( done )
    {
        [self _notifyAutoLoginDidChange] ;
    }
    else
    {
        _automaticLogin = NO;
    }
    return done;
}


- (NSString*)identifierForApp
{
    [self profiles] ;
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


- (void)_getFromUserDefaults
{
    _currentUserID = [defaults() currentUserIdX];
    _lastAuthUserID = [defaults() lastAuthUserIdX];
    _adminAccessLevel = [defaults() adminAccessLevelX];
    BOOL done = [self _performSaveAfterActionWithError:nil];
    if ( done )
    {
        [defaults() setCurrentUserIdX:0];
        [defaults() setLastAuthUserIdX:0];
        [defaults() setAdminAccessLevelX:0];
    }
}


- (UInt32)currentUserId
{
    [self profiles] ;
    
    if ( _shouldGetFromUserDefaults )
        [self _getFromUserDefaults];
    
    return _currentUserID;
}


- (void)_setCurrentUserId:(UInt32)value
{
    //UInt32 previous = _currentUserID;
    _currentUserID = value ;
    
    BOOL done = [self _performSaveAfterActionWithError:nil];
    if ( done )
    {
        [self _notifyCurrentUserDidChange];
    
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @(previous), @"PreviousUser", @(value), @"CurrentUser", nil] ;
//        [nc postNotificationName:kCurrentUserDidChangeNotification object:nil userInfo:userInfo] ;
    }
    else
    {
        _currentUserID = 0;
    }
}

- (UInt32)lastAuthUserId
{
    [self profiles] ;
    
    if ( _shouldGetFromUserDefaults )
        [self _getFromUserDefaults];
    
    return _lastAuthUserID;
}


- (void)setLastAuthUserId:(UInt32)value
{
    _lastAuthUserID = value ;
    
    BOOL done = [self _performSaveAfterActionWithError:nil];
    if ( !done )
    {
        _currentUserID = 0;
    }
}


- (UInt8)adminAccessLevel
{
    [self profiles] ;
    
    if ( _shouldGetFromUserDefaults )
        [self _getFromUserDefaults];
    
    return _adminAccessLevel;
}


- (void)setAdminAccessLevel:(UInt8)value
{
    _adminAccessLevel = value ;
    
    BOOL done = [self _performSaveAfterActionWithError:nil];
    if ( !done )
    {
        _adminAccessLevel = 0;
    }
}


//- (void)setProjectUserEnabled:(BOOL)value
//{
//    _projectUserEnabled = value;
//    
//    BOOL done = [self _performSaveAfterActionWithError:nil];
//    if ( done )
//    {
//        [self _notifyRemoteEnabledDidChange];
//    }
//    else
//    {
//        _projectUserEnabled = YES;
//    }
//}
//
//
//
//- (BOOL)projectUserEnabled
//{
//    [self profiles] ;
//    return _projectUserEnabled;
//}

#pragma mark Individual Profiles



- (void)logInWithUsername:(NSString*)username password:(NSString*)password
{
    UserProfile *profile = [self getProfileCopyForUser:username];
    if ( profile == nil )
    {
        profile = [[UserProfile alloc] initWithUserName:username];
        profile.enabled = YES;
    }
    
    if ( profile.isLocal )
    {
        [self _dealWithLocalLogin:profile password:password];
        return;
    }
    
    [self _dealWithRemoteLogin:profile password:password];
}


- (void)requestPasswordRequestForUsername:(NSString*)username
{
    UserProfile *profile = [self getProfileCopyForUser:username];
    if ( profile == nil )
    {
        profile = [[UserProfile alloc] initWithUserName:username];
        profile.enabled = YES;
    }
    
    if ( profile.isLocal )
    {
        NSString *message = NSLocalizedString(@"Reseting local user passwords is forbiden", nil);
        NSError *error = _errorWithLocalizedDescription_title(message, nil);
        //NSError *error = [self _completeErrorWithLocalizedDescription:message title:nil];
        
        [self _notifyDidRequestPasswordResetForProfile:profile withError:error];
        return;
    }
    
    [self _resetRemotePasswordRequestForProfile:profile];
}


- (void)addProfile:(UserProfile*)profile password:(NSString*)password
{
    [self _addRemoteProfile:profile password:password];
}

// si oldPass i newPass son nil vol dir que fem un update utilitzant el token del usuari,
// si no determinem el token de nou amb els passwords
- (void)updateProfile:(UserProfile*)profile oldPassword:(NSString*)oldPass newPassword:(NSString*)newPass
{
    if ( profile.isLocal )
    {
        [self _updateLocalProfile:profile oldPassword:oldPass newPassword:newPass];
        return;
    }

    [self _updateRemoteProfile:profile oldPassword:oldPass newPassword:newPass];
}


- (void)deleteProfile:(UserProfile*)profile
{
    [self _deleteProfileRequest:profile];
}

- (void)deleteProfileRecord:(UserProfile*)profile
{
    [self _deleteLocalProfileAndNotify:profile];
}




//- (void)processOpenUrl:(NSURL *)url
//{
//    NSString *host = [url host];
//    NSArray *components = [url pathComponents];
//    NSLog( @"host: %@", host );
//    NSLog( @"components: %@", components);
//    
//    if ( host.length > 0 && components.count == 3 )
//    {
//        NSString *userIdStr = [components objectAtIndex:1];
//        UInt32 userId = [userIdStr intValue];
//        NSString *token = [components objectAtIndex:2];
//    
//        if ( NSOrderedSame == [host caseInsensitiveCompare:@"reset_password"] )
//        {
//            [self _finalSetPasswordForUserId:userId resetToken:token];
//            return;
//        }
//    
//        if ( NSOrderedSame == [host caseInsensitiveCompare:@"delete_user"] )
//        {
//            [self _finalDeleteUserWithId:userId deleteToken:token];
//            return;
//        }
//        
//        if ( NSOrderedSame == [host caseInsensitiveCompare:@"activate"] )
//        {
//            [self _finalActivationForUserId:userId activationToken:token];
//            return;
//        }
//        
//        // error;
//    }
//    
//    NSString *format = NSLocalizedString(@"Could not process external URL schema: %@",nil);
//    NSString *message = [NSString stringWithFormat:format, url.absoluteString];
//    NSString *title = NSLocalizedString(@"Url Schema Error", nil );
//    [self _completeErrorWithLocalizedDescription:message title:title];  
//}




- (void)processResetPasswordForUserId:(UInt32)userId newPassword:(NSString*)pass resetToken:(NSString*)token
{
//    UserProfile *profile = [self _profileForKey:userName];
//    UInt32 userId = profile.userId;
    [self _finalSetPasswordForUserId:userId newPassword:pass resetToken:token];
}

- (void)processDeleteUserForUserId:(UInt32)userId resetToken:(NSString*)token
{
    [self _finalDeleteUserWithId:userId deleteToken:token];
}

- (void)processActivateUserForUserId:(UInt32)userId resetToken:(NSString*)token
{
    [self _finalActivationForUserId:userId activationToken:token];
}


- (UserProfile*)getProfileCopyForUser:(NSString*)user;
{
    [self profiles];
    UserProfile *profile = [self _profileForKey:user];
    UserProfile *profileCopy = [profile getProfileCopy];
    return profileCopy;
}

- (BOOL)isUpdatingProfile
{
    return _updatingProfile != NO;
}


//---------------------------------------------------------------------------------------------
- (NSArray*)localUsersArray
{
    if ( _profilesArrayDone == NO ) [self _generateProfilesArrays] ;
    return _localUsersArray ;
}

//---------------------------------------------------------------------------------------------
- (NSArray*)generalUsersArray;
{
    if ( _profilesArrayDone == NO ) [self _generateProfilesArrays] ;
    return _generalUsersArray  ;
}


////---------------------------------------------------------------------------------------------
//- (void)removeGeneralUserAtIndex:(NSInteger)indx
//{
//    [self profiles];
//    [self generalUsersArray];
//    
//    NSString *userToRemove = [_generalUsersArray objectAtIndex:indx];
//    UserProfile *aProfile = [self _profileForKey:userToRemove];
//    
//    [self _setLocalProfileDirty:aProfile];
//   // [self _notifyWillUpdateProfile:aProfile];
//    
//    
//    if ( YES )
//    {
//        // AFNETWORKING success
//        NSError *error = nil;
//        [self _removeGeneralUserAtIndex:indx error:&error];
//        //[self _notifyDidUpdateProfile:aProfile withError:error];
//        [self _notifyDidDeleteGeneralUserAtIndex:indx];
//    }
//    
//    if ( NO )
//    {
//        // AFNETWORKING fail
//        NSError *error = nil ; // <--- error procedent de AFNetwork
//        [self _setLocalProfile:aProfile error:nil];
//        [self _notifyDidUpdateProfile:aProfile withError:error];
//    }
//}




//- (BOOL)removeGeneralUserAtIndex:(NSInteger)indx error:(NSError**)outError
//{
//    BOOL done = [self _removeGeneralUserAtIndex:indx error:outError];
//    return done;
//}

////---------------------------------------------------------------------------------------------
//- (BOOL)userIsAdmin:(NSString*)user
//{
//#if OEMFree
//    return NO ;
//#else
//    return [user isEqualToString:AdminUser] ;
//#endif
//}
//
////---------------------------------------------------------------------------------------------
//- (BOOL)currentUserIsAdmin
//{
//    NSString *user = [defaults() currentUser] ;
//    return [self userIsAdmin:user] ;
//}



//- (BOOL)userIsCurrentUser:(NSString*)userName
//{
//    NSString *user = [defaults() currentUser] ;
//    return [user isEqualToString:userName];
//}
//
//
//- (BOOL)userIsIntegrator:(NSString*)userName
//{
//    [self profiles];
//    UserProfile *profile = [self _profileForKey:userName];
//    return profile.integrator;
//}


- (BOOL)currentUserIsIntegrator
{
//    UInt32 userId = [defaults() currentUserId];
    UInt32 userId = [self currentUserId];
    return [self userIdIsIntegrator:userId];
}


- (UserProfile*)profileForUserId:(UInt32)userId
{
    UserProfile *profile = [self _profileForUserId:userId];
    return profile;
}

- (UserProfile*)currentUserProfile
{
//    UInt32 userId = [defaults() currentUserId];
    UInt32 userId = [self currentUserId];
    UserProfile *profile = [self _profileForUserId:userId];
    return profile;
}

- (BOOL)userIdIsIntegrator:(UInt32)userId
{
    UserProfile *profile = [self _profileForUserId:userId];
    BOOL integrator = profile.integrator;
    return integrator;
}


- (NSString*)userNameForUserId:(UInt32)userId
{
    UserProfile *profile = [self _profileForUserId:userId];
    NSString *userName = profile.username;
    return userName;
}

- (NSString*)currentUserName
{
    //UInt32 userId = [defaults() currentUserId];
    UInt32 userId = [self currentUserId];
    NSString *userName = [self userNameForUserId:userId];
    if ( userName == nil ) userName = @"";
    return userName;
}

//- (UInt32)currentUserId
//{
//    UInt32 userId = [defaults() currentUserId];
//    return userId;
//}



//---------------------------------------------------------------------------------------------
- (UInt8)currentUserAccess
{
    [self profiles];
    //UInt32 userId = [defaults() currentUserId] ;
    UInt32 userId = [self currentUserId];
    UserProfile *profile = [self _profileForUserId:userId];
    
//    if ( profile.integrator ) return [defaults() adminAccessLevel] ;
//    else return profile.level ;    
        
    if ( profile.integrator ) return [self adminAccessLevel] ;
    else return profile.level ;
}


#pragma mark Individual Profiles Private

//static id _dict_objectForKey(NSDictionary* fileDict, NSString* key)
//{
//    id value = [fileDict objectForKey:key];
//    if ( value == [NSNull null] ) value = nil;
//    return value;
//}


- (void)_setProfile:(UserProfile*)profile withResponseDict:(NSDictionary*)responseDict
{
    if ( [responseDict isKindOfClass:[NSDictionary class]] )
    {
        profile.username = _dict_objectForKey(responseDict, @"username");
        profile.email = _dict_objectForKey(responseDict, @"email");
        
        NSString *userLevel = _dict_objectForKey(responseDict, @"user_level");
        profile.level = [userLevel integerValue];
        
        NSString *url = _dict_objectForKey(responseDict, @"url");
        NSString *idTxt = [url lastPathComponent];
        profile.userId = (UInt32)[idTxt integerValue];
    }
}



- (void)_addRemoteProfile:(UserProfile*)profile password:(NSString*)password
{
    [self _notifyWillUpdateProfile:profile];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    //NSString *path = @"users/?set_password=1";
    NSString *path = @"users/";
    
    NSDictionary *parameters = @
    {
        @"username":profile.username,
        @"email":profile.email,
        @"password":password,
        @"user_level":[NSString stringWithFormat:@"%d", profile.level],
    };
    
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:nil parameters:parameters ];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        //UserProfile *srvProfile = profile;   // <-- agafar aProfile la del json que torna
        
        NSDictionary *responseDict = JSON;
        
        [self _setProfile:profile withResponseDict:responseDict];
        
        NSString *format = NSLocalizedString(@"An user activation message was sent to the user associated email", nil);
        NSString *description = [NSString stringWithFormat:format, profile.email];
        NSString *title = NSLocalizedString(@"New User", nil);
        //[self _completeErrorWithLocalizedDescription:description title:title];
        _errorWithLocalizedDescription_title(description, title);
        [self _notifyDidUpdateProfile:profile withError:nil];
        
        
        [self _setLocalProfileAndNotify:profile updated:NO];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"User Creation Error", nil );
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title];
        error = _completeErrorFromResponse_json_withError_title(response, JSON, error, title);
        [self _notifyDidUpdateProfile:profile withError:error];
    }];
}


- (void)_finalActivationForUserId:(UInt32)userId activationToken:(NSString*)token
{
    // aqui confirmar amb el servidor la redemption
    NSLog1( @"FinalActivationForUserId:%ld token:%@", userId, token);
    
    [self _notifyWillUpdateProfile:nil];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    //NSString *path = @"users/?set_password=1";
    NSString *path = [NSString stringWithFormat:@"users/%u/activate/", (unsigned int)userId];
    
    NSDictionary *parameters = @
    {
        @"activation_code":token
    };
    
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:nil parameters:parameters ];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        //UserProfile *srvProfile = profile;   // <-- agafar aProfile la del json que torna
        
        NSDictionary *responseDict = JSON;
        
        NSDictionary *user = _dict_objectForKey(responseDict, @"user");

        NSString *userName = _dict_objectForKey(user,@"username");
        
        UserProfile *profile = [self _profileForUserId:userId];
        if ( profile == nil ) profile = [[UserProfile alloc] initWithUserName:userName];
        

        [self _setProfile:profile withResponseDict:user];
        
        NSString *title = NSLocalizedString(@"User Activation Completed", nil );
        NSString *format = NSLocalizedString(@"Account for user name: %@ has been activated. You should now be able to login with this user name.", nil );
        NSString *message = [NSString stringWithFormat:format,userName];
        _errorWithLocalizedDescription_title(message, title);
        
        [self _setLocalProfileAndNotify:profile updated:YES];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"User Activation Error", nil );
        NSString *message = NSLocalizedString(@"Could not activate user account. The user is already active or activation time has expired.", nil );
        error = _completeErrorFromResponse_json_withError_title_message(response, JSON, error, title, message);
        [self _notifyDidUpdateProfile:nil withError:error];
    }];
    
}


- (void)_updateLocalProfile:(UserProfile*)profile oldPassword:(NSString*)oldPass newPassword:(NSString*)newPass
{
    if ( oldPass.length == 0 && newPass.length == 0 )
    {        
        [self _setLocalProfileAndNotify:profile updated:YES];
    }
    else
    {
        if ( [profile.password isEqualToString:oldPass] )
        {
            profile.password = newPass;
            [self _setLocalProfileAndNotify:profile updated:YES]; // ok
        }
        else
        {
            NSString *title = NSLocalizedString(@"User Account", nil );
            NSString *message = NSLocalizedString(@"Wrong Password", nil);
            NSError *error = _errorWithLocalizedDescription_title(message,title);
            [self _notifyDidUpdateProfile:profile withError:error];
        }
    }
}



- (void)_updateRemoteProfile:(UserProfile*)profile oldPassword:(NSString*)oldPass newPassword:(NSString*)newPass
{
    [self _notifyWillUpdateProfile:profile];
    if ( oldPass.length == 0 && newPass.length == 0 )
    {
        [self _primitiveUpdateRemoteProfile:profile completion:nil];
    }
    else
    {
        [self _primitiveSetRemotePasswordForProfile:profile oldPassword:oldPass newPassword:newPass];  // <- cridara primitive update remote profile
    }
}


- (void)_primitiveUpdateRemoteProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion
{
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"users/%u/", (unsigned int)profile.userId];
    
    NSDictionary *parameters = @
    {
        @"username":profile.username,
        @"email":profile.email,
    };
        
    NSMutableURLRequest *trequest = [client requestWithMethod:@"PUT" path:path token:profile.token parameters:parameters ];
    LogRequest;
    LogBody;

    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        //UserProfile *srvProfile = profile;   // <-- agafar aProfile la del json que torna
        
        NSDictionary *responseDict = JSON;
        
        [self _setProfile:profile withResponseDict:responseDict];
        
        [self _setLocalProfileAndNotify:profile updated:YES];
        
        if ( completion ) completion( YES );
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"User Update Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyDidUpdateProfile:profile withError:error];
        
        if ( completion ) completion( NO );
    }];

}


- (void)_primitiveSetRemotePasswordForProfile:(UserProfile*)profile oldPassword:(NSString*)oldPass newPassword:(NSString*)newPass
{
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"users/%u/password/", (unsigned int)profile.userId];
    
    NSDictionary *parameters = @
    {
        @"old_password":oldPass,
        @"password":newPass,
    };
    
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:profile.token parameters:parameters ];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        [self _primitiveUpdateRemoteProfile:profile completion:nil];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        NSString *title = NSLocalizedString(@"Password Update Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyDidUpdateProfile:profile withError:error];
    }];
}



- (void)_resetRemotePasswordRequestForProfile:(UserProfile*)profile
{
    [self _notifyWillUpdateProfile:profile];
 
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    //NSString *path = [NSString stringWithFormat:@"users/%ld/reset_password/request/", profile.userId];
    NSString *path = [NSString stringWithFormat:@"users/reset_password/%@/", profile.username];
    
    NSDictionary *parameters = nil;
    
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:nil /*profile.token*/ parameters:parameters];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        [self _notifyDidUpdateProfile:profile withError:nil];
        [self _notifyDidRequestPasswordResetForProfile:profile withError:nil];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *message = NSLocalizedString(@"Error Requesting Password Reset", nil);
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:nil message:message];
        error = _completeErrorFromResponse_json_withError_title_message(response, JSON, error, nil, message);
        [self _notifyDidUpdateProfile:profile withError:error];
        [self _notifyDidRequestPasswordResetForProfile:profile withError:error];
        
        
        //NSLog( @"randomPass:%@", _randomPasswordWithLength(9) );
    }];
}


static NSString *_randomPasswordWithLength(int length)
{
    char chars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    int charsLen = sizeof(chars)-1;
    int numsLen = 10;
    char buff[length+1];
    int index;
    
    for ( int i=0; i<2 && i<length ; i++ )
    {
        index = numsLen + arc4random_uniform(charsLen-numsLen);  // els dos primers lletres
        buff[i] = chars[index];
    }
    
    for ( int i=1; i<length-2 ; i++ )
    {
        index = arc4random_uniform(charsLen);  // els del mig numeros i lletres
        buff[i] = chars[index];
    }
    
    for ( int i=length-2 ; i<length ; i++ )
    {
        index = arc4random_uniform(numsLen);  // els dos del final numeros
        buff[i] = chars[index];
    }
    
    buff[length] = '\0';
    
    NSString *result = [NSString stringWithCString:buff encoding:NSUTF8StringEncoding];
    return result;
}


- (void)_finalSetPasswordForUserId:(UInt32)userId newPassword:(NSString*)newPassword resetToken:(NSString*)token
{
    // aqui enviar al servidor la confirmacio del canvi de password
    NSLog1( @"FinalSetPasswordForUserId:%ld token:%@", userId, token);
    
    UserProfile *profile = [self _profileForUserId:userId];
    
    [self _notifyWillUpdateProfile:profile];
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
        
    NSString *path = [NSString stringWithFormat:@"users/%u/reset_password/confirm/", (unsigned int)userId];
    
    //NSString *randomPassword = _randomPasswordWithLength(9);
    NSDictionary *parameters = @
    {
        @"reset_token":token,
       // @"new_password":randomPassword,
        @"new_password":newPassword,
    };

        
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:nil parameters:parameters ];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        [self _setLocalProfileAndNotify:profile updated:YES];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        NSString *title = NSLocalizedString(@"Password Reset Error", nil );
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title];
        error = _completeErrorFromResponse_json_withError_title(response, JSON, error, title);
        [self _notifyDidUpdateProfile:profile withError:error];
    }];    
}



- (void)_dealWithRemoteLogin:(UserProfile*)profile password:(NSString*)password
{
    [self _notifyWillUpdateProfile:profile];
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = @"token/";
    
    NSDictionary *parameters = @
    {
        @"username":profile.username,
        @"password":password, //profile.password,
    };
    
    
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:nil/*profile.token*/ parameters:parameters ];
    LogRequest;
    LogBody;
    
//    NSString *str = [[NSString alloc] initWithData:trequest.HTTPBody encoding:NSUTF8StringEncoding];
//    NSLog1( @"Body :%@", str);
    
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *responseDict = JSON;
        NSString *token = _dict_objectForKey(responseDict, @"token");
        profile.token = token;
        profile.password = password;
        
        [self _setProfile:profile withResponseDict:responseDict];
        
        NSDictionary *user = _dict_objectForKey(responseDict, @"user");
        
        [self _setProfile:profile withResponseDict:user];
//        profile.username = [user objectForKey:@"username"];
//        profile.email = [user objectForKey:@"email"];
//        NSString *url = [user objectForKey:@"url"];
//        NSString *idTxt = [url lastPathComponent];
//        profile.userId = [idTxt integerValue];
        
        
        [self _resetRemoteMDArrays];
        
        NSError *error = nil;
        [self _setLocalProfile:profile updated:YES error:&error];
        if ( error == nil )
        {
            //[defaults() setCurrentUserId:profile.userId];
            [self _setCurrentUserId:profile.userId];
        }
        else
        {
            NSString *title = NSLocalizedString(@"User Profile Saving Error", nil);
            //error = [self _completeErrorWithError:error title:title];
            error = _completeErrorWithError_title(error, title);
        }
        [self _notifyDidUpdateProfile:profile withError:error];  // <--- el possible error el passem aqui
        [self _notifyDidLoginWithProfile:profile localLogin:NO withError:nil];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
//        NSLog( @"FAILURE getToken");
//        error = [self _completeErrorFromResponse:response json:JSON withError:error];
//        // no updatem el profile [self _notifyDidUpdateProfile:profile withError:error];
//        [self _notifyDidLoginWithProfile:profile localLogin:NO withError:error];  // <--- el error el passem aqui
        
        [self _dealWithRemoteLoginFailure:response json:JSON profile:profile password:password error:error];
    }];
}


- (void)_dealWithLocalLogin:(UserProfile*)profile password:(NSString*)password
{
    if ( password.length>0 && [profile.password isEqualToString:password] )
    {
        [self _resetRemoteMDArrays];
        //[defaults() setCurrentUserId:profile.userId];
        [self _setCurrentUserId:profile.userId];
        [self _notifyDidUpdateProfile:profile withError:nil];     // ok
        [self _notifyDidLoginWithProfile:profile localLogin:YES withError:nil];     // ok
    }
    else
    {
        //NSString *title = NSLocalizedString(@"Login Error", nil);
        NSString *message = NSLocalizedString(@"Login Failure", nil);
        NSError *error = _errorWithLocalizedDescription_title(message,nil);
        [self _notifyDidUpdateProfile:profile withError:error];     // ok
        [self _notifyDidLoginWithProfile:profile localLogin:YES withError:error];
    }
}


//---------------------------------------------------------------------------------------------
- (void)_dealWithRemoteLoginFailure:(NSHTTPURLResponse *)response json:(id)JSON profile:(UserProfile*)profile
    password:(NSString*)password error:(NSError*)error
{
    NSLog1( @"responseError: %@", error );
    
    //NSHTTPURLResponse *response = operation.response;
    NSLog1( @"statusCode: %d", [response statusCode] );
    
    BOOL localLogin = (response == nil);
    
    if ( localLogin )
    {
        [self _dealWithLocalLogin:profile password:password];
        return;
    }
    
    //NSString *title = NSLocalizedString(@"Remote Login Failure", nil );
    error = _completeErrorFromResponse_json_withError_title(response,JSON,error,nil);
    [self _notifyDidUpdateProfile:profile withError:error];
    [self _notifyDidLoginWithProfile:profile localLogin:localLogin withError:error];  // no OK
}


//// Esborra sense mes
//- (void)_deleteProfileNOW:(UserProfile*)profile
//{
//
//    [self _notifyWillUpdateProfile:profile];
//    NSInteger currentUserId = [defaults() currentUserId];
//    if ( profile.userId == currentUserId )
//    {
//        NSString *title = NSLocalizedString(@"User Account", nil);
//        NSString *message = NSLocalizedString(@"Can't Delete Current User", nil);
//        NSError *error = _completeErrorWithLocalizedDescription_title(message,title);
//        [self _notifyDidUpdateProfile:profile withError:error];
//        return;
//    }
//
//    [self _setLocalProfileDirty:profile];
//    
//    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
//        
//    NSString *path = [NSString stringWithFormat:@"users/%ld/", profile.userId];
//        
//    NSURLRequest *trequest = [client requestWithMethod:@"DELETE" path:path token:profile.token parameters:nil ];
//    LogRequest;
//    
//    [client enqueueRequest:trequest
//    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
//    {
//        // AFNETWORKING success
//        
//        LogSuccess;
//        [self _deleteLocalProfileAndNotify:profile];
//    }
//    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
//    {
//        LogFailure;
//        [self _dealWithRemoteDeleteFailure:response json:JSON profile:profile error:error];
//    }];
//}



// demana un token via email per delete
- (void)_deleteProfileRequest:(UserProfile*)profile
{

    [self _notifyWillUpdateProfile:profile];
//    NSInteger currentUserId = [defaults() currentUserId];
//    if ( profile.userId == currentUserId )
//    {
//        NSString *title = NSLocalizedString(@"User Account", nil);
//        NSString *message = NSLocalizedString(@"Can't Delete Current User", nil);
//        NSError *error = _completeErrorWithLocalizedDescription_title(message,title);
//        [self _notifyDidUpdateProfile:profile withError:error];
//        return;
//    }

    [self _setLocalProfileDirty:profile];
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
        
    NSString *path = [NSString stringWithFormat:@"users/%u/delete/request/", (unsigned int)profile.userId];
        
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:profile.token parameters:nil ];
    LogRequest;
    LogBody;

    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        // AFNETWORKING success
        
        LogSuccess;
        
        //[self _deleteLocalProfileAndNotify:profile];
        NSString *format = NSLocalizedString(@"A confirmation email for deleting user was sent to: %@", nil);
        NSString *description = [NSString stringWithFormat:format, profile.email];
        NSString *format2 = NSLocalizedString(@"Delete User: %@", nil);
        NSString *title = [NSString stringWithFormat:format2, profile.username];
        //[self _completeErrorWithLocalizedDescription:description title:title];
        _errorWithLocalizedDescription_title(description, title);
        [self _notifyChangeUserListing];
        [self _notifyDidUpdateProfile:profile withError:nil];
        
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        [self _dealWithRemoteDeleteFailure:response json:JSON profile:profile error:error];
    }];
}



- (void)_finalDeleteUserWithId:(UInt32)userId deleteToken:(NSString*)token
{
    NSLog1( @"FinalDeleteUserWithId:%ld token:%@", userId, token);
    
    UserProfile *profile = [self _profileForUserId:userId];
    
    if ( profile == nil )
    {
        NSString *title = NSLocalizedString(@"Error Deleting User", nil );
        NSString *message = NSLocalizedString(@"User could not be deleted because no previous usage record was found. Please login at least once with the user to be deleted and try again", nil );
        //NSError *error = [self _completeErrorWithLocalizedDescription:message title:title];
        NSError *error = _errorWithLocalizedDescription_title(message, title);
        [self _notifyDidUpdateProfile:profile withError:error];
        return;
    }
    
    if ( [self currentUserId] == userId )
    {
        NSString *title = NSLocalizedString(@"Error Deleting User", nil );
        NSString *message = NSLocalizedString(@"Can't delete current user. Please login with another user before deleting this user", nil );
        //NSError *error = [self _completeErrorWithLocalizedDescription:message title:title];
        NSError *error = _errorWithLocalizedDescription_title(message, title);
        [self _notifyDidUpdateProfile:profile withError:error];
        return;
    }
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
        
    NSString *path = [NSString stringWithFormat:@"users/%u/delete/confirm/", (unsigned int)userId];
    
    NSDictionary *parameters = @
    {
        @"delete_token":token,
    };

        
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:profile.token parameters:parameters ];
    LogRequest;
    LogBody;

    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        // AFNETWORKING success
        
        LogSuccess;
        [self _deleteLocalProfileAndNotify:profile];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        [self _dealWithRemoteDeleteFailure:response json:JSON profile:profile error:error];
    }];
}




- (void)_dealWithRemoteDeleteFailure:(NSHTTPURLResponse *)response json:(id)JSON profile:(UserProfile*)profile
    error:(NSError*)error
{
    NSLog1( @"responseError: %@", error );
    
    //NSHTTPURLResponse *response = operation.response;
    NSLog1( @"statusCode: %d", [response statusCode] );
    
    BOOL noResponse = (response == nil);
    
    if ( noResponse )
    {
            // << --- no esborrem local (?)
        
        [self _deleteLocalProfileAndNotify:profile];  // << --- esborrem local igualment
        
        NSString *title = NSLocalizedString(@"User Account", nil );
        NSString *message =  NSLocalizedString(@"Can't Delete User", nil );
        //error = [self _completeErrorWithLocalizedDescription:message title:title];
        error = _errorWithLocalizedDescription_title(message, title);
        [self _notifyDidUpdateProfile:profile withError:error];
    }
    else  // si hi ha resposta
    {
        [self _deleteLocalProfileAndNotify:profile];  // << --- esborrem local igualment
        
        NSString *title = NSLocalizedString(@"Delete User Error", nil );
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title];
        error = _completeErrorFromResponse_json_withError_title(response, JSON, error, title);
        [self _notifyDidUpdateProfile:profile withError:error];
    }
}


//- (void)_uploadCurrentProject
//{
//    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
//    
//    SWAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
//    SWDocument *document = [appDelegate currentDocument];
//    
//    NSData *symbolicData = [document getSymbolicData];
//    NSURL *fileUrl = [document fileURL];
//    NSString *projectName = [fileUrl lastPathComponent];
//    
//    NSLog( @"projectName: %@", projectName );
//    [self _notifyWillUploadProject:projectName];
//    
//    UInt32 userId = [defaults() currentUserId];
//    UserProfile *profile = [self _profileForUserId:userId];
//    
//    NSString *path = @"projects/";
//    
//    NSDictionary *parameters = @
//    {
//        @"name":projectName,
//    };
//
//    NSURLRequest *frequest = [client multipartFormRequestWithMethod:@"POST" path:path token:profile.token parameters:parameters
//    constructingBodyWithBlock: ^(id <AFMultipartFormData> formData)
//    {
//        [formData appendPartWithFileData:symbolicData name:@"project_file" fileName:projectName mimeType:@"text/plain"];
//    }];
//    
//    [client enqueueRequest:frequest
//    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
//    {
//        NSLog(@"%@", JSON);
//        [self _notifyDidUploadProject:projectName withError:nil];
//    }
//    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
//    {
//        NSLog(@"%@", error);
//        NSLog(@"%@", JSON);
//        
//        NSLog( @"FAILURE uploadCurrentProject");
//        error = [self _completeErrorFromResponse:response json:JSON withError:error];
//        [self _notifyDidUploadProject:projectName withError:error];
//    }];
//    
//    
////    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:frequest
////    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
////    {
////        NSLog(@"%@", JSON);
////    }
////    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
////    {
////        NSLog(@"%@", error);
////        NSLog(@"%@", JSON);
////    }];
////    
////    [operation start];
//}
//
//

//- (NSError*)_completeErrorWithLocalizedDescription:(NSString*)message title:(NSString*)title
//{
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message};
//    NSError *error = [[NSError alloc] initWithDomain:@"my" code:0 userInfo:userInfo];
//    return [self _completeErrorWithError:error title:title];
//}


//- (NSError*)_completeErrorWithError:(NSError*)error title:(NSString*)title
//{
//    if ( title != nil && error != nil )
//    {
//        NSString *message = [error localizedDescription];
//        NSString *ok = NSLocalizedString( @"Ok", nil );
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//        [alert show];
//    }
//    return error;
//}


//- (NSError*)_completeErrorFromResponse:(NSHTTPURLResponse *)response json:(id)JSON withError:(NSError*)error title:(NSString*)title
//{
//    return [self _completeErrorFromResponse:response json:JSON withError:error title:title message:nil];
//}


//- (NSError*)_completeErrorFromResponse:(NSHTTPURLResponse *)response json:(id)JSON withError:(NSError*)error title:(NSString*)title message:(NSString*)message
//{
//    NSInteger statusCode = [response statusCode];
//    BOOL errorResponse = statusCode > 0 && (statusCode < 200 || statusCode >= 300);
//
//    if ( errorResponse )
//    {
//        NSMutableString *errStr = [NSMutableString string];
//        
//        NSDictionary *jsonDict = JSON;
//        if ( [jsonDict isKindOfClass:[NSDictionary class]] )
//        {
//
//        
//        BOOL first = YES;
//        for ( NSString *key in jsonDict )
//        {
//            if ( !first ) first = NO, [errStr appendString:@"\n"];
//            [errStr appendFormat:@"%@: %@\n", key, [jsonDict objectForKey:key]];
//            
//            if ( [key isEqualToString:@"username"] )
//            {
//            
//            
//            
//            }
//            else
//            {
//                [errStr appendFormat:@"%@: %@\n", key, _dict_objectForKey(jsonDict, key)];
//            }
//            
//            
//        }
//        }
//        else
//        {
//            errStr = @"";
//        }
//        
//        if ( errStr.length > 0 || message.length > 0)
//        {
//            NSString *descr = errStr;
//            NSString *reason = @"";
//            if ( message.length > 0 )
//            {
//                descr = message;
//                reason = errStr;
//            }
//        
//            NSDictionary *userInfo = @
//            {
//                NSLocalizedDescriptionKey:descr,
//                NSLocalizedFailureReasonErrorKey:reason,
//            };
//            
//            error = [NSError errorWithDomain:@"HMiPad" code:0 userInfo:userInfo];
//        }
//        
//        if ( title != nil )
//        {
//            NSString *descr = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:descr delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//            [alert show];
//        }
//    }
//    
//    NSLog( @"completeErrorFromResponse Error:%@", error);
//    return error;
//}

////---------------------------------------------------------------------------------------------
//- (void)_dealWithPossibleLoginFailure:(UserProfile*)profile operation:(AFHTTPRequestOperation*)operation error:(NSError*)error
//{
//    NSLog( @"responseError: %@", error );
//    
//    NSHTTPURLResponse *response = operation.response;
//    NSInteger statusCode = [response statusCode];
//    NSLog( @"statusCode: %d", statusCode );
//    
//    BOOL localLogin = (response == nil);
//    
//    if ( localLogin )
//    {
//        UserProfile *memberProfile = [_profiles member:profile];
//        if ( memberProfile.password == profile.password )
//        {
//            [self _notifyDidUpdateProfile:profile withError:nil];     // ok
//            [self _notifyDidLoginWithProfile:profile localLogin:YES withError:nil];     // ok
//            return;
//        }
//    }
//    
//    [self _dealWithFailureResponse:profile operation:operation error:error];   // no ok
//    [self _notifyDidLoginWithProfile:profile localLogin:localLogin withError:error];  // no OK
//}




//---------------------------------------------------------------------------------------------
- (void)_setLocalProfileDirty:(UserProfile *)aProfile
{
    [self profiles];
    UserProfile *profile = [_profiles member:aProfile];
    
    if ( profile == nil )
        return;
    
    profile.updated = NO;
}


//---------------------------------------------------------------------------------------------
- (BOOL)_setLocalProfile:(UserProfile *)aProfile updated:(BOOL)updated error:(NSError**)outError
{
    [self profiles];
    UserProfile *profile = [_profiles member:aProfile];
    
    if ( profile == nil )
    {
        [_profiles addObject:aProfile];
        profile = aProfile;
    }
    else
    {
        [profile copyWithProfile:aProfile];
    }
    
    profile.updated = updated;
    _profilesArrayDone = NO;
    
    BOOL done = [self _performSaveAfterActionWithError:outError];
    if ( done ) [self _notifyChangeUserListing];
    return done;
}


- (BOOL)_setLocalProfileAndNotify:(UserProfile *)profile updated:(BOOL)updated
{
    NSError *error = nil;
    
    BOOL done = [self _setLocalProfile:profile updated:updated error:&error];
    if ( done )
    {
//        UInt32 currentUserId = [defaults() currentUserId];
//        if ( currentUserId == profile.userId ) [defaults() setCurrentUserId:currentUserId];
    
        UInt32 currentUserId = [self currentUserId];
        if ( currentUserId == profile.userId ) [self _setCurrentUserId:currentUserId];
    }
    NSString *title = NSLocalizedString(@"Create User",nil);
    
    //[self _completeErrorWithError:error title:title];
    error = _completeErrorWithError_title(error, title);
    [self _notifyDidUpdateProfile:profile withError:error];
    
    return done;
}


- (BOOL)_deleteLocalProfileAndNotify:(UserProfile *)profile
{
    [self profiles];
    [self generalUsersArray];
    
    NSInteger index = [_generalUsersArray indexOfObject:profile.username];
    if ( index != NSNotFound )
    {
        [_generalUsersArray removeObjectAtIndex:index];
        [self _notifyDidDeleteGeneralUserAtIndex:index];
    }

    [_profiles removeObject:profile];
    
    _profilesArrayDone = NO;
    NSError *error = nil;
    BOOL done = [self _performSaveAfterActionWithError:&error];
    if ( !done )
    {
        NSString *title = NSLocalizedString(@"Saving Error", nil);
        _completeErrorWithError_title(error,title);
    }
    [self _notifyChangeUserListing];
    
    return done;
}


//---------------------------------------------------------------------------------------------
- (UserProfile*)_profileForKey:(NSString*)key
{
    _searchUserProfile.username = key;
    _searchUserProfile.userId = 0;
    UserProfile *profile = [_profiles member:_searchUserProfile];
    return profile;
}

//---------------------------------------------------------------------------------------------
- (UserProfile*)_profileForUserId:(UInt32)userId
{
    _searchUserProfile.username = nil;
    _searchUserProfile.userId = userId;
    UserProfile *profile = [_profiles member:_searchUserProfile];
    return profile;
}

////---------------------------------------------------------------------------------------------
//- (void)_generateProfilesArraysV
//{
//    if ( _defaultUsersArray == nil ) _defaultUsersArray = [[NSMutableArray alloc] init] ;
//    else [_defaultUsersArray removeAllObjects];
//    
//    if ( _generalUsersArray == nil ) _generalUsersArray = [[NSMutableArray alloc] init] ;
//    else [_generalUsersArray removeAllObjects];
//    
//    [self profiles];
//    for ( NSString *username in _profiles )
//    {
//        UserProfile *profile = [_profiles objectForKey:username] ; 
//        if ( [profile isDefault] ) [_defaultUsersArray addObject:username];
//        else [_generalUsersArray addObject:username];
//    }
//    
//    // sort arrays
//    [_defaultUsersArray sortUsingSelector:@selector(compare:)];
//    [_generalUsersArray sortUsingSelector:@selector(compare:)];
//    
//    _profilesArrayDone = YES ;
//}


//---------------------------------------------------------------------------------------------
- (void)_generateProfilesArrays
{
    if ( _localUsersArray == nil ) _localUsersArray = [[NSMutableArray alloc] init] ;
    else [_localUsersArray removeAllObjects];
    
    if ( _generalUsersArray == nil ) _generalUsersArray = [[NSMutableArray alloc] init] ;
    else [_generalUsersArray removeAllObjects];
    
    [self profiles];
    for ( UserProfile *profile in _profiles )
    {
        NSString *username = [profile.username copy];
        if ( username == nil ) username = @"<unknown>";
        if ( profile.isLocal ) [_localUsersArray addObject:username];
        else [_generalUsersArray addObject:username];
    }
    
    // sort arrays
    [_localUsersArray sortUsingSelector:@selector(compare:)];
    [_generalUsersArray sortUsingSelector:@selector(compare:)];
    
    _profilesArrayDone = YES ;
}



//---------------------------------------------------------------------------------------------
- (BOOL)_removeGeneralUserAtIndex:(NSInteger)indx error:(NSError**)outError
{
    [self profiles];
    [self generalUsersArray];
    
    NSString *userToRemove = [_generalUsersArray objectAtIndex:indx];
    [_generalUsersArray removeObjectAtIndex:indx];
    
    UserProfile *profileToRemove = [self _profileForKey:userToRemove];
    [_profiles removeObject:profileToRemove];
    // no cal actualitzar profilesArrayDone
    
    //[self _notifyDidDeleteGeneralUserAtIndex:indx];
    
    BOOL done = [self _performSaveAfterActionWithError:outError];
    return done;
}





#pragma mark Observer Notification

//---------------------------------------------------------------------------------------------
- (void)_notifyChangeUserListing
{
    NSArray *observers = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observers )
    {
        if ( [observer respondsToSelector:@selector(appUsersModelGeneralUserListingDidChange:)] )
        {
            [observer appUsersModelGeneralUserListingDidChange:self];
        }
    }
}

- (void)_notifyWillUpdateProfile:(UserProfile*)aProfile
{
    _updatingProfile = YES;
    
    NSArray *observers = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observers )
    {
        if ( [observer respondsToSelector:@selector(appUsersModel:willUpdateProfile:)] )
        {
            [observer appUsersModel:self willUpdateProfile:aProfile];
        }
    }
}

- (void)_notifyDidUpdateProfile:(UserProfile*)aProfile withError:(NSError*)error
{
    _updatingProfile = NO;
    
    NSArray *observers = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observers )
    {
        if ( [observer respondsToSelector:@selector(appUsersModel:didUpdateProfile:withError:)] )
        {
            [observer appUsersModel:self didUpdateProfile:aProfile withError:error];
        }
    }
}

- (void)_notifyDidRequestPasswordResetForProfile:(UserProfile*)aProfile withError:(NSError*)error
{
    NSArray *observers = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observers )
    {
        if ( [observer respondsToSelector:@selector(appUsersModel:didRequestPasswordResetForProfile:withError:)] )
        {
            [observer appUsersModel:self didRequestPasswordResetForProfile:aProfile withError:error];
        }
    }
}


//- (void)_notifyWillUploadProject:(NSString*)projectName
//{
//    _updatingProject = YES;
//    for ( id<AppUsersModelObserver>observer in _observers )
//    {
//        if ( [observer respondsToSelector:@selector(appUsersModel:willUpdateProject:)] )
//        {
//            [observer appUsersModel:self willUpdateProject:projectName];
//        }
//    }
//}
//
//- (void)_notifyDidUploadProject:(NSString*)projectName withError:(NSError*)error
//{
//    _updatingProject = NO;
//    for ( id<AppUsersModelObserver>observer in _observers )
//    {
//        if ( [observer respondsToSelector:@selector(appUsersModel:didUpdateProject:withError:)] )
//        {
//            [observer appUsersModel:self didUpdateProject:projectName withError:error];
//        }
//    }
//}

//- (void)_maybeResetDefaultUserForProfile:(UserProfile*)profile
//{
//    UInt32 currentUserId = [defaults() currentUserId];
//    if ( currentUserId == profile.userId ) [defaults() setCurrentUserId:currentUserId];
//}


- (void)_resetRemoteMDArrays
{
    AppModel *fModel = filesModel();
    [fModel.files resetMDArrayForCategory:kFileCategoryRemoteSourceFile];
    [fModel.files resetMDArrayForCategory:kFileCategoryRemoteAssetFile];
    [fModel.files resetMDArrayForCategory:kFileCategoryRemoteActivationCode];
    [fModel.files resetMDArrayForCategory:kFileCategoryRemoteRedemption];
}

- (void)_notifyDidLoginWithProfile:(UserProfile*)aProfile localLogin:(BOOL)local withError:(NSError*)error
{
    _updatingProfile = NO;
    
    //if ( aProfile.isLocal==NO && error==nil)
//    if ( error == nil)
//        [self setProjectUserEnabled:NO];
    
    
    NSArray *observersCopy = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appUsersModel:didLoginWithProfile:localLogin:withError:)] )
        {
            [observer appUsersModel:self didLoginWithProfile:aProfile localLogin:local withError:error];
        }
    }
}


- (void)_notifyDidDeleteGeneralUserAtIndex:(NSInteger)index
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appUsersModel:didDeleteGeneralUserAtIndex:)] )
        {
            [observer appUsersModel:self didDeleteGeneralUserAtIndex:index];
        }
    }
}

- (void)_notifyAutoLoginDidChange
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appUsersModelAutoLoginDidChange:)] )
        {
            [observer appUsersModelAutoLoginDidChange:self];
        }
    }
}

- (void)_notifyCurrentUserDidChange
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppUsersModelObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appUsersModelCurrentUserDidChange:)] )
        {
            [observer appUsersModelCurrentUserDidChange:self];
        }
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kCurrentUserDidChangeNotification object:nil userInfo:nil] ;
}


//- (void)_notifyRemoteEnabledDidChange
//{
//    NSArray *observersCopy = [_observers copy];
//    for ( id<AppUsersModelObserver>observer in observersCopy )
//    {
//        if ( [observer respondsToSelector:@selector(appUsersModelRemoteEnabledDidChange:)] )
//        {
//            [observer appUsersModelRemoteEnabledDidChange:self];
//        }
//    }
//}

#pragma mark Metodes del AppUsersModel

//------------------------------------------------------------------------------------
- (id)init
{
    self = [super init] ;
    if (self)
    {
        NSLog1(@"Model: init") ;
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _searchUserProfile = [[UserProfile alloc] init];
    }
    return self;
}


//-----------------------------------------------------------------------------------
- (void)dealloc
{   
    NSLog1(@"Model dealloc") ;
}

@end



////////////////////////////////////////////////////////////////////////////////////
#pragma mark Acces Ràpid a DomusModel
////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------- 
static AppUsersModel *_appUsersModel = nil ;

AppUsersModel *usersModel(void)
{
    if ( _appUsersModel == nil ) _appUsersModel = [[AppUsersModel alloc] init] ;
    return _appUsersModel ;
}


//-------------------------------------------------------------------------------------------- 
void usersModel_release(void)
{
    _appUsersModel = nil ;
}




@implementation AppUsersModel(migrate)

- (void)setMigratedForProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion
{
    NSString *userName = profile.username;
    
    UserProfile *migratedProfile = [profile getProfileCopy];
    migratedProfile.username = [userName stringByAppendingString:@"@migrated"];
    
    [self _primitiveUpdateRemoteProfile:migratedProfile completion:completion];
    
    // el treiem immediatament dels profiles inclus abans de saber el resultat de completion
    // s'haura de tornar a logar si es que encara hi era al servidor
    
    [_profiles removeObject:profile];
    [self _setCurrentUserId:SWDefaultUserId];   // log out !
}

@end



