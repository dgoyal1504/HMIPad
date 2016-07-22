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
@class UserProfile;
@class SWTableViewMessage ;


@interface SWEditICLoudUserAccountController : /*Inset*/UITableViewController<UITextFieldDelegate>

{
    UserProfile *profile;
    
    ManagedTextFieldCell *usernameCell;
    ManagedTextFieldCell *emailCell;
    
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *saveButton;
    SWTableFieldsController *rightButton;
    
    BOOL saveIsShown ;
    BOOL switchChanged;
    SWTableViewMessage *messageView ;
    UILabel *messageViewLabel;
}

//- (id)initWithUsername:(NSString*)user flags:(AccountTableControllerFlags)flags;
- (id)initWithUsername:(NSString*)user type:(AccountTableControllerType)type;

@end

