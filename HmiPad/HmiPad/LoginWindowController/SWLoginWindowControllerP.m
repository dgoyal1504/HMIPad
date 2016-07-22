//
//  SWLoginWindowControllerP.m
//  HmiPad
//
//  Created by Joan Lluch on 26/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWLoginWindowControllerP.h"
#import "SWDocumentModel.h"
#import "SWSystemItemUsersManager.h"
#import "SWSystemItemProject.h"
#import "SWProjectUser.h"
#import "AppUsersModel.h"
#import "AppModel.h"
#import "AppModelImage.h"
//#import "AppModelDocument.h"
#import "Drawing.h"
#import "SWColor.h"


#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif


#pragma mark - SWLoginWindowControllerP()

@interface SWLoginWindowControllerP()<AppUsersModelObserver/*,AppModelDocumentObserver*/>
{
    __weak SWDocumentModel *_docModel;
    __weak SWSystemItemUsersManager *_usersMgr;
    UIToolbar *_unexpectedToolbar;
    BOOL _isObservingUsers;
}

@end


#pragma mark - LoginWindowController implementation

@implementation SWLoginWindowControllerP
{
    UIColor *_backColor;
    NSString *_backImageName;
}


- (id)initWithUsersManager:(SWSystemItemUsersManager*)usersManager;
{
    self = [super init];
    if ( self )
    {
        _usersMgr = usersManager;
        _docModel = usersManager.docModel;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    LoginViewC *loginView = self.loginView;
    [loginView establishForgotPasswordButton:NO];
    
   // [self establishActivityIndicator:[usersModel() isUpdatingProfile] animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}


# pragma mark - public methods

//- (void)showAnimated:(BOOL)animated
//{
//    [super showAnimated:animated];
//    
//    UIColor *color = nil;
//    SWValue *colorValue = _usersMgr.backgroundColor;
//    if ( ![colorValue valueIsEmpty] ) color = [colorValue valueAsColor];
//    [self _setBackgroundColor:color];
//    
//    //[self.loginView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1.0]];
//    
//    NSString *imageName = [_usersMgr.backgroundImage valueAsString];
//    [self _setBackgroundImageName:imageName];
//    
//    NSString *companyTitle = [_usersMgr.companyTitle valueAsString];
//    [self _setCompanyTitle:companyTitle];
//    
//    NSString *companyLogoImageName = [_usersMgr.companyLogo valueAsString];
//    [self _setCompanyLogoImageName:companyLogoImageName];
//    
//    SWSystemItemProject *systemProject = [_docModel systemItemProject];
//    NSString *projectName = [systemProject.title valueAsString];
//    [self _setProjectName:projectName];
//}



- (void)showAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    UIColor *color = nil;
    SWValue *colorValue = _usersMgr.backgroundColor;
    if ( ![colorValue valueIsEmpty] ) color = [colorValue valueAsColor];
    
    void (^selfcompletion)(void) = ^(void)
    {
        if ( _unexpectedToolbar )
            [self.loginView setBackgroundColor:[UIColor clearColor]];
    };
    
    [super showAnimated:animated completion:^(BOOL finished)
    {
        selfcompletion();
        if ( completion )
            completion(finished);
    }];


    [self _setBackgroundColor:color];
    
    if ( _unexpectedToolbar )
        [self.loginView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];  // <<-- millora el efecte de fade-out

    NSString *imageName = [_usersMgr.backgroundImage valueAsString];
    [self _setBackgroundImageName:imageName];
    
    NSString *companyTitle = [_usersMgr.companyTitle valueAsString];
    [self _setCompanyTitle:companyTitle];
    
    NSString *companyLogoImageName = [_usersMgr.companyLogo valueAsString];
    [self _setCompanyLogoImageName:companyLogoImageName];
    
    SWSystemItemProject *systemProject = [_docModel systemItemProject];
    NSString *projectName = [systemProject.title valueAsString];
    [self _setProjectName:projectName];
}


- (void)dismiss
{
    if ( _unexpectedToolbar )
        [self.loginView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];  // <<-- millora el efecte de fade-out
    
    [super dismiss];
}


#pragma mark - private

- (void)_setProjectName:(NSString*)name
{
    LoginViewC *loginView = self.loginView;
    [loginView.titleLabel setText:name];
}


- (void)_setBackgroundColorV:(UIColor*)color
{
    _backColor = color;
    [self _setBackImage];
    
    LoginViewC *loginView = self.loginView;
    if ( color == nil ) color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [loginView setBackgroundColor:color];
    
    UInt32 rgb = rgbColorForUIcolor( color ) ;
    CGFloat brightness = BrightnessForRgb(rgb) ;
    [loginView setTextColorIsDark:!(brightness < 0.59)];
}



//- (void)_setUnexpectedColor:(UIColor*)color
//{
//    LoginViewC *loginView = self.loginView;
//    if ( color == nil )
//    {
//        if ( _unexpectedToolbar == nil )
//        {
//            // THE MOST UNEXPECTED: http://stackoverflow.com/questions/17704240/ios-7-dynamic-blur-effect-like-in-control-center
//            _unexpectedToolbar = [[UIToolbar alloc] initWithFrame:loginView.bounds];
//            _unexpectedToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
//            
//            ;
//            _unexpectedToolbar.barTintColor = nil; //[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
//            //_unexpectedToolbar.barStyle = UIBarStyleBlack;
//            [loginView insertSubview:_unexpectedToolbar atIndex:0];
//            
////            UIColor *bColor = [UIColor colorWithRed:0.5 green:0.5 blue:0 alpha:1.0];
////            [loginView setBackgroundColor:[bColor colorWithAlphaComponent:0.3]];
//            
//            [loginView setBackgroundColor:[UIColor clearColor]];
//        }
//    }
//    else
//    {
//        [_unexpectedToolbar removeFromSuperview];
//        _unexpectedToolbar = nil;
//        //color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.0];
//        [loginView setBackgroundColor:color];
//    }
//}


- (void)_setBackgroundColor:(UIColor*)color
{
    _backColor = color;
    [self _setBackImage];
    
    LoginViewC *loginView = self.loginView;
    
    UInt32 rgb = 0xffffff;
    if ( color == nil )
    {
        if ( _unexpectedToolbar == nil )
        {
            // THE MOST UNEXPECTED: http://stackoverflow.com/questions/17704240/ios-7-dynamic-blur-effect-like-in-control-center
            _unexpectedToolbar = [[UIToolbar alloc] initWithFrame:loginView.bounds];
            _unexpectedToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _unexpectedToolbar.barTintColor = nil; //[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
            //_unexpectedToolbar.barStyle = UIBarStyleBlack;
            [loginView insertSubview:_unexpectedToolbar atIndex:0];
        }
    }
    else
    {
        [_unexpectedToolbar removeFromSuperview];
        _unexpectedToolbar = nil;
        //color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.0];
        [loginView setBackgroundColor:color];
        rgb = rgbColorForUIcolor( color ) ;
    }
    
    CGFloat brightness = BrightnessForRgb(rgb) ;
    [loginView setTextColorIsDark:!(brightness < 0.59)];
}



- (void)_setBackgroundColorNO:(UIColor*)color
{
    _backColor = color;
    [self _setBackImage];
    
    LoginViewC *loginView = self.loginView;
    
    UInt32 rgb = 0xffffff;
    if ( color )
    {
        [loginView setBackgroundColor:color];
        rgb = rgbColorForUIcolor( color ) ;
    }
    else
    {
        [loginView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.66]];  // <<-- millora el efecte de fade-out
    }
    
    CGFloat brightness = BrightnessForRgb(rgb) ;
    [loginView setTextColorIsDark:!(brightness < 0.59)];
}






- (void)_setBackgroundImageName:(NSString *)imageName
{    
    _backImageName = imageName;
    [self _setBackImage];
}


- (void)_setCompanyTitle:(NSString*)companyTitle
{
    LoginViewC *loginView = self.loginView;
    if ( companyTitle.length == 0 ) companyTitle = @AppName;
    
    [loginView.labelhmipad setText:companyTitle];
}


- (void)_setCompanyLogoImageNameB:(NSString *)companyLogoImageName
{
    LoginViewC *loginView = self.loginView;
    if ( companyLogoImageName.length == 0 )
    {
        UIImage *logoImage = [UIImage imageNamed:@"CompanyLogo.png"];
        [loginView.logoImage setImage:logoImage];
    }
    else
    {
        [filesModel().amImage getOriginalImageWithName:companyLogoImageName inDocumentName:_docModel.redeemedName completionBlock:^(UIImage *image)
        {
            [loginView.logoImage setImage:image];
        }];
    }
}


- (void)_setCompanyLogoImageName:(NSString *)companyLogoImageName
{
    LoginViewC *loginView = self.loginView;
    if ( companyLogoImageName.length == 0 )
    {
        [loginView.logoImage setImage:nil];
    }
    else
    {
        [filesModel().amImage getOriginalImageWithName:companyLogoImageName inDocumentName:_docModel.redeemedName completionBlock:^(UIImage *image)
        {
            [loginView.logoImage setImage:image];
        }];
    }
}


- (void)_setBackImageB
{
    LoginViewC *loginView = self.loginView;
    
    if ( _backImageName.length == 0 )
    {
        UIImage *image = nil;
        if ( _backColor == nil ) image = [UIImage imageNamed:@"fonsPantalla7.png"];
        else image = glossyImageWithSizeAndColor(CGSizeMake(40, 40), _backColor.CGColor, NO, NO, 0, 2);
        
        [loginView.backView setImage:image];
    }
    else
    {
        [filesModel().amImage getOriginalImageWithName:_backImageName inDocumentName:_docModel.redeemedName completionBlock:^(UIImage *image)
        {
            [loginView.backView setImage:image];
        }];
    }
}


- (void)_setBackImage
{
    LoginViewC *loginView = self.loginView;
    
    if ( _backImageName.length == 0 )
    {
        UIImage *image = nil;
        if ( _backColor != nil ) image = glossyImageWithSizeAndColor(CGSizeMake(40, 40), _backColor.CGColor, NO, NO, 0, 2);
        [loginView.backView setImage:image];
    }
    else
    {
        [filesModel().amImage getOriginalImageWithName:_backImageName inDocumentName:_docModel.redeemedName completionBlock:^(UIImage *image)
        {
            [loginView.backView setImage:image];
        }];
    }
}


- (void)_selectProjectUser:(SWProjectUser *)selectedUser
{
    [_docModel selectProjectUser:selectedUser];
}




#pragma mark - LoginView delegate methods

//- (void)loginViewDidEnterV:(LoginViewC*)loginView
//{
//    [super loginViewDidEnter:loginView];
//    
//    NSString *user = loginView.userText;
//    NSString *pass = loginView.passText;
//
//    BOOL done = NO;
//    SWProjectUser *selectedUser = nil;
//    
//    NSArray *projectUsers = _docModel.projectUsers;
//    for ( SWProjectUser *prjUser in projectUsers )
//    {
//        NSString *userTxt = prjUser.userName.valueAsString;
//        NSString *passTxt = prjUser.userP.valueAsString;
//    
//        if ( [user isEqualToString:userTxt] && [pass isEqualToString:passTxt] )
//        {
//            done = YES;
//            selectedUser = prjUser;
//            break;
//        }
//    }
//    
//    // si no hem trobat usuaris, a la versio HMI Draw permetem el usuari per defecte
//    if ( !done && HMiPadDev )
//    {
//        if ( [user isEqualToString:@SWDefaultUser] && [pass isEqualToString:@SWDefaultUserPass] )
//        {
//            done = YES;
//            selectedUser = nil;
//        }
//    }
//    
//    if ( done )
//    {
//        // set current user
//        [self _selectProjectUser:selectedUser];
//        [self dismiss];
//        return;
//    }
//    else
//    {
//        // si som aqui es que no hem trobat cap usuari de projecte
//        [usersModel() logInWithUsername:user password:pass];
//    }
//}



//- (void)loginViewDidEnterV:(LoginViewC*)loginView
//{
//    [super loginViewDidEnter:loginView];
//    
//    NSString *user = loginView.userText;
//    NSString *pass = loginView.passText;
//
//    BOOL done = NO;
//    SWProjectUser *selectedUser = nil;
//    
//    NSArray *projectUsers = _docModel.projectUsers;
//    for ( SWProjectUser *prjUser in projectUsers )
//    {
//        NSString *userTxt = prjUser.userName.valueAsString;
//        NSString *passTxt = prjUser.userP.valueAsString;
//    
//        if ( [user isEqualToString:userTxt] && [pass isEqualToString:passTxt] )
//        {
//            done = YES;
//            selectedUser = prjUser;
//            break;
//        }
//    }
//    
//    if ( done )
//    {
//        // set current user
//        [self _selectProjectUser:selectedUser];
//        [self dismiss];
//        return;
//    }
//    else
//    {
//        // si som aqui es que no hem trobat cap usuari de projecte
//        
//        [self startObservingUsers];
//        [usersModel() logInWithUsername:user password:pass];
//    }
//}




- (void)loginViewDidEnter:(LoginViewC*)loginView
{
    [super loginViewDidEnter:loginView];
    
    NSString *user = loginView.userText;
    NSString *pass = loginView.passText;

    BOOL done = NO;
    SWProjectUser *selectedUser = nil;
    
    // busquem usuaris de projecte
    
    NSArray *projectUsers = _docModel.projectUsers;
    for ( SWProjectUser *prjUser in projectUsers )
    {
        NSString *userTxt = prjUser.userName.valueAsString;
        NSString *passTxt = prjUser.userP.valueAsString;
    
        if ( [user isEqualToString:userTxt] && [pass isEqualToString:passTxt] )
        {
            done = YES;
            selectedUser = prjUser;
            break;
        }
    }
    
    if ( done )
    {
        // set current user
        [self _selectProjectUser:selectedUser];
        [self dismiss];
        return;
    }
    
    // potser es el usuari admim
    
    if ( [user isEqualToString:@"admin"] )
    {
        SWSystemItemUsersManager *usersMgr = _docModel.systemItemUsersManager;
        NSString *adminPass = usersMgr.adminUserPassword.valueAsString;
    
        if ( [pass isEqualToString:adminPass] )
        {
            // set no user
            [self _selectProjectUser:nil];
            [self dismiss];
            return;
        }
    }
    
    // si som aqui es que no hem trobat cap usuari de projecte
    
    [self startObservingUsers];
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
    //[usersModel() requestPasswordRequestForUsername:loginView.userText];
}



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
    if ( error  )
    {
        if ( local )
        {
            NSString *errString = NSLocalizedString(@"Local authentication failed", nil);
            [self establishResultText:errString];
        }
        else
        {
            NSString *title = NSLocalizedString(@"User authentication failed", nil );
            [self establishResultText:title];
        }
    }

    else
    {
        [self _selectProjectUser:nil];
        [self dismiss];
    }
}


- (void)appUsersModel:(AppUsersModel *)usersModel didRequestPasswordResetForProfile:(UserProfile *)profile withError:(NSError *)error
{
    // no hauria de passar mai
    [self resign];
}


@end
