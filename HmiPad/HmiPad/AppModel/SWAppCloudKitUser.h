//
//  SWAppCloudKitUser.h
//  HmiPad
//
//  Created by joan on 11/08/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

@class SWAppCloudKitUser;

@protocol SWAppCloudKitUserObserver<NSObject>
@optional

- (void)cloudKitUserCurrentUserWillLogIn:(SWAppCloudKitUser*)cloudKitUser;
- (void)cloudKitUser:(SWAppCloudKitUser*)cloudKitUser currentUserDidLoginWithError:(NSError*)error;
- (void)cloudKitUserCurrentUserLogOut:(SWAppCloudKitUser*)cloudKitUser;

- (void)cloudKitUserWillFetchUserData:(SWAppCloudKitUser*)cloudKitUser;
- (void)cloudKitUser:(SWAppCloudKitUser*)cloudKitUser didFetchUserDataWithError:(NSError*)error;
- (void)cloudKitUserShouldAskUserData:(SWAppCloudKitUser*)cloudKitUser;

- (void)cloudKitUserWillUpdateUserData:(SWAppCloudKitUser*)cloudKitUser;
- (void)cloudKitUser:(SWAppCloudKitUser*)cloudKitUser didUpdateUserDataWithError:(NSError*)error;

//- (void)cloudKitUserRequireMigration:(SWAppCloudKitUser*)cloudKitUser;


@end

@class CKRecordID;

@interface SWAppCloudKitUser : NSObject

- (void)startICloudAvailabilityNotifications;
- (void)checkICloudAvailabilityNowWithForce:(BOOL)force;

// read only properties
//@property (nonatomic, readonly) BOOL *isIcloudReady;
@property (nonatomic, readonly) CKRecordID *currentUserRecordId;
@property (nonatomic, readonly) UserProfile *currentUserProfile;
@property (nonatomic, readonly) NSString *currentUserUUID;
@property (nonatomic, readonly) BOOL isLoggingIn;
@property (nonatomic, readonly) BOOL isUpdatingProfile;
@property (nonatomic, readonly) BOOL requiresProfileData;

// identificador unic (substitut de identifierForVendor)
@property (nonatomic, readonly) NSString *identifierForApp;

// Methods
- (void)updateWithProfile:(UserProfile*)profile;

// Observers
- (void)addObserver:(id<SWAppCloudKitUserObserver>)observer;
- (void)removeObserver:(id<SWAppCloudKitUserObserver>)observer;


@end

@interface SWAppCloudKitUser(migrate)

- (void)migrateIdentifierForApp;

- (BOOL)currentUserHasMigrated;
- (void)setMigratedForProfile:(UserProfile*)profile completion:(void(^)(BOOL done))completion;
@end

#pragma mark Acces a SWAppCloudKitUser

extern SWAppCloudKitUser *cloudKitUser(void);

