//
//  AppUsersModel.h
//  HMiPad
//
//  Created by Joan on 19/07/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import "QuickCoder.h"
#import "UserProfile.h"


@class AppUsersModel;

#pragma mark AppUsersModelObserver

extern NSString *kCurrentUserDidChangeNotification ;

@protocol AppUsersModelObserver<NSObject>

@optional
- (void)appUsersModel:(AppUsersModel*)usersModel didDeleteGeneralUserAtIndex:(NSInteger)index;
- (void)appUsersModelGeneralUserListingDidChange:(AppUsersModel*)usersModel;
- (void)appUsersModelAutoLoginDidChange:(AppUsersModel*)usersModel;
- (void)appUsersModelCurrentUserDidChange:(AppUsersModel*)usersModel;  // <- same as kCurrentUserDidChangeNotification
//- (void)appUsersModelRemoteEnabledDidChange:(AppUsersModel*)usersModel;

- (void)appUsersModel:(AppUsersModel*)usersModel willUpdateProfile:(UserProfile*)profile;
- (void)appUsersModel:(AppUsersModel*)usersModel didUpdateProfile:(UserProfile*)profile withError:(NSError*)error;

- (void)appUsersModel:(AppUsersModel*)usersModel didLoginWithProfile:(UserProfile*)profile localLogin:(BOOL)remote withError:(NSError*)error;
- (void)appUsersModel:(AppUsersModel*)usersModel didRequestPasswordResetForProfile:(UserProfile*)profile withError:(NSError*)error;

//- (void)appUsersModel:(AppUsersModel*)usersModel willUpdateProject:(NSString*)projectName;   // a eliminar
//- (void)appUsersModel:(AppUsersModel*)usersModel didUpdateProject:(NSString*)projectName withError:(NSError*)error;    // a eliminar

@end


#pragma mark AppUsersModel


@interface AppUsersModel : NSObject
{
    NSMutableArray *_observers; // List of observers
    
    // perfils i altres parametres de seguretat
    BOOL _automaticLogin;
    //BOOL _remoteEnabled;
    //BOOL _projectUserEnabled;
    NSString *_identifierForApp;
    UInt32 _currentUserID;
    UInt32 _lastAuthUserID;
    UInt8 _adminAccessLevel;
    NSMutableSet *_profiles;
    UserProfile *_searchUserProfile;
    
    // usuaris perfils individuals
    NSMutableArray *_localUsersArray;
    NSMutableArray *_generalUsersArray;
    BOOL _profilesArrayDone;
    BOOL _updatingProfile;
}

//------------------------------------------------------------------
// Observers
- (void)addObserver:(id<AppUsersModelObserver>)observer;
- (void)removeObserver:(id<AppUsersModelObserver>)observer;

//------------------------------------------------------------------
// perfils i altres parametres de seguretat
@property (nonatomic, readonly) BOOL automaticLogin;
- (BOOL)setAutomaticLogin:(BOOL)value error:(NSError**)outError;


//------------------------------------------------------------------
// identificador unic (substitut de identifierForVendor)
@property (nonatomic, readonly) NSString *identifierForApp;

//------------------------------------------------------------------
// debug (a elimimar)
-(void)printProfiles;

//------------------------------------------------------------------
// usuaris, perfils individuals
- (NSArray*)localUsersArray;
- (NSArray*)generalUsersArray;
- (UserProfile*)getProfileCopyForUser:(NSString*)user;


- (void)logInWithUsername:(NSString*)username password:(NSString*)password;
- (void)addProfile:(UserProfile*)profile password:(NSString*)password;
- (void)updateProfile:(UserProfile*)profile oldPassword:(NSString*)oldPass newPassword:(NSString*)newPass;
- (void)deleteProfile:(UserProfile*)profile;
- (void)requestPasswordRequestForUsername:(NSString*)username;

- (void)deleteProfileRecord:(UserProfile*)profile;

- (void)processResetPasswordForUserId:(UInt32)userId newPassword:(NSString*)pass resetToken:(NSString*)token;
- (void)processDeleteUserForUserId:(UInt32)userId resetToken:(NSString*)resetToken;
- (void)processActivateUserForUserId:(UInt32)userId resetToken:(NSString*)token;

- (BOOL)isUpdatingProfile;

- (BOOL)currentUserIsIntegrator;

- (BOOL)userIdIsIntegrator:(UInt32)userId;
- (NSString*)userNameForUserId:(UInt32)userId;

- (UserProfile*)profileForUserId:(UInt32)userId;
- (UserProfile*)currentUserProfile;
- (NSString*)currentUserName;
//- (UInt32)currentUserId;
- (UInt8)currentUserAccess;

//@property (nonatomic) BOOL projectUserEnabled;
// ^- Indica que tenim un usuari de projecte logat.
// ^- Encara que sigui NO, el usuari pot ser local i per tant no permetre operacions remotes.
@property (nonatomic) UInt32 currentUserId;
@property (nonatomic) UInt32 lastAuthUserId;
@property (nonatomic) UInt8 adminAccessLevel;

@end


#pragma mark Acces a AppUsersModel

//extern NSString *AdminUser ;
//extern NSString *DefaultUser ;
extern AppUsersModel *usersModel(void) ;
extern void usersModel_release(void) ;




@interface AppUsersModel(migrate)

- (void)setMigratedForProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion;

@end







