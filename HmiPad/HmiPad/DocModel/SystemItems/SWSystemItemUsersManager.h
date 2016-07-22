//
//  SWSystemItemUsersManager.h
//  HmiPad
//
//  Created by Joan Lluch on 25/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

@interface SWSystemItemUsersManager : SWSystemItem

@property (nonatomic,readonly) SWExpression *login;
@property (nonatomic,readonly) SWExpression *enableAutoLogin;
@property (nonatomic,readonly) SWExpression *adminUserPassword;
@property (nonatomic,readonly) SWValue *currentUserName;
@property (nonatomic,readonly) SWValue *currentUserLevel;
@property (nonatomic,readonly) SWValue *backgroundColor;
@property (nonatomic,readonly) SWValue *backgroundImage;
@property (nonatomic,readonly) SWValue *companyTitle;
@property (nonatomic,readonly) SWValue *companyLogo;

- (void)updateCurrentProjectUserIfNeeded;
- (void)performForcedLogin;
- (void)performOptionalLogin;
- (void)performDismissLogin;

@end
