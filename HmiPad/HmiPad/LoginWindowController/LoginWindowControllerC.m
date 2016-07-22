//
//  loginWindowController.m
//  iPhoneDomusSwitch_090417b
//
//  Created by Joan on 19/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "loginWindowControllerC.h"
#import "AppUsersModel.h"

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif



#pragma mark LoginWindowController()

@interface LoginWindowControllerC()<AppUsersModelObserver>

@end



#pragma mark LoginWindowController implementation

@implementation LoginWindowControllerC
{
    BOOL _isObservingUsers;
}



#pragma mark - View Lifecycle


- (id)init
{
    self = [super init];
    if ( self )
    {
        [self startObservingUsers];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LoginViewC *loginView = self.loginView;
    [loginView establishForgotPasswordButton:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self establishActivityIndicator:[usersModel() isUpdatingProfile] animated:NO];
//    [usersModel() addObserver:self];

}


- (void)viewWillDisappear:(BOOL)animated
{
//    [usersModel() removeObserver:self];
	[super viewWillDisappear:animated];
}


#pragma mark - LoginView delegate methods

- (void)loginViewDidEnter:(LoginViewC*)loginView
{
    [super loginViewDidEnter:loginView];
    NSString *user = loginView.userText;
    NSString *pass = loginView.passText;
    
    [usersModel() logInWithUsername:user password:pass];
}


- (void)loginViewDidCancel:(LoginViewC*)loginView
{
    [super loginViewDidCancel:loginView];
    [self dismiss];
}


- (void)loginViewDidForgotPassword:(LoginViewC *)loginView
{
    [super loginViewDidForgotPassword:loginView];
    [usersModel() requestPasswordRequestForUsername:loginView.userText];
}


#pragma mark - private


#pragma mark - AppUsersModelObserver


- (void)appUsersModel:(AppUsersModel *)usersModel willUpdateProfile:(UserProfile *)profile
{
    [self establishActivityIndicator:YES animated:YES];
}


- (void)appUsersModel:(AppUsersModel*)usersModel didUpdateProfile:(UserProfile*)aProfile withError:(NSError*)error
{    
    [self establishActivityIndicator:NO animated:YES];

    if ( error )
    {
    }
}


- (void)appUsersModel:(AppUsersModel*)usersModel didLoginWithProfile:(UserProfile*)profile
    localLogin:(BOOL)local withError:(NSError*)error;
{
    if ( error )
    {
        if ( local )
        {
            //[_selfWindow setWindowLevel:UIWindowLevelNormal] ;
            NSString *errString = NSLocalizedString(@"Local authentication failed", nil);
            [self establishResultText:errString];
        }
        else
        {
            //[_selfWindow setWindowLevel:UIWindowLevelNormal] ;
            NSString *title = NSLocalizedString(@"Remote authentication failed", nil );
            [self establishResultText:title];
        }
    }
    else
    {
        [self dismiss];
    }
}


- (void)appUsersModel:(AppUsersModel *)usersModel didRequestPasswordResetForProfile:(UserProfile *)profile withError:(NSError *)error
{
    if ( error )
    {
        NSString *description = [error localizedDescription];
        //[_selfWindow setWindowLevel:UIWindowLevelNormal] ;
        //_loginView.resultLabel.text = description;
        [self establishResultText:description];
    }
    else
    {
        //[_selfWindow setWindowLevel:UIWindowLevelNormal] ;
        NSString *title = NSLocalizedString(@"Reset password request email was sent", nil );
        //_loginView.resultLabel.text = title;
        [self establishResultText:title];
    }
    [self resign];
}

@end
