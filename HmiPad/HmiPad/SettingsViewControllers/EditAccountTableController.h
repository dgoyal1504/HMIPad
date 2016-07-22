//
//  EditAccountTableController.h
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWTableFieldsController;
@class ManagedTextFieldCell;
@class ControlViewCell;
@class SwitchViewCell;
@class UserProfile;
@class SWTableViewMessage ;

//typedef enum AccountTableControllerFlags
//{
//    kShouldShowActivate =       1 << 0,
//    kShouldShowUser =           1 << 1,
//    kShouldShowOldPassword =    1 << 2,
//    kShouldShowPassword =       1 << 3,
//    kShouldShowPriority =       1 << 4,
//    kShouldSeparatePassword =   1 << 5,
//} AccountTableControllerFlags ;


typedef enum AccountTableControllerType
{
    kAccountControllerNew =       1,
    kAccountControllerUpdateRemote =  2,
    kAccountControllerUpdateLocal =  3,
    kAccountControllerUpdateCurrent = 4,
    kAccountControllerUpdateICloud = 5,
} AccountTableControllerType ;


@interface EditAccountTableController : /*Inset*/UITableViewController<UITextFieldDelegate>

{
    UserProfile *profile;
    AccountTableControllerType controllerType;
    
    SwitchViewCell *activateCell ;
    ManagedTextFieldCell *usernameCell ;
    ManagedTextFieldCell *emailCell ;
    ManagedTextFieldCell *oldPasswordCell ;
    ManagedTextFieldCell *passwordCell ;
    ManagedTextFieldCell *confirmPasswordCell ;
    ManagedTextFieldCell *priorityCell ;
    ControlViewCell *subscribeCell;
    ControlViewCell *loginCell;
    
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *saveButton;
    SWTableFieldsController *rightButton;
    
    BOOL saveIsShown ;
    BOOL switchChanged;
    //SWTableViewMessage *messageView ;
}

//- (id)initWithUsername:(NSString*)user flags:(AccountTableControllerFlags)flags;
- (id)initWithUsername:(NSString*)user type:(AccountTableControllerType)type;

@end

