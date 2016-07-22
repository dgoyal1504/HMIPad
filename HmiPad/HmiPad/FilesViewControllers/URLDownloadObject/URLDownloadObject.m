//
//  URLDownloadObject.m
//  ScadaMobile
//
//  Created by Joan on 15/05/11.
//  Copyright 2011 SweetWilliam, S.L. All rights reserved.
//

#import "URLDownloadObject.h"
//#import "AppFilesModel.h"
#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"

#import "SWBlockAlertView.h"

#import "AppUsersModel.h"
#import "UserDefaults.h"
#import "SWColor.h"


//---------------------------------------------------------------------------------------------------

enum
{
    operationTypeDownload = 0,
    operationTypeOpen,
    operationTypeScheme,
} ;


@interface URLDownloadObject()
@end


@implementation URLDownloadObject

NSString *URLDownloadObjectEnded = @"URLDownloadObjectEnded";
NSString *URLDownloadObjectRedeem = @"URLDownloadObjectRedeem";
NSString *URLDownloadObjectRedeemCodeKey = @"URLDownloadObjectRedeemCodeKey";

#define DEBUGING 0

#if DEBUGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif

#define AuthRetries 3

//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Alert Methods
//////////////////////////////////////////////////////////////////////////////////////////////////
enum
{
    kAlertError = 1,    // no cridara el delegat
    kAlertAuthError, 
    kAlertChoice,
    kAlertRedeem,
    kAlertAuthenticate,
    kAlertSchemeConfirmDelete,
    kAlertSchemeConfirmActivate,
    kAlertSchemeResetPassword,
    kAlertSchemeResetPasswordRepeat,
} ;

enum
{
    kTextFieldUser = 101,
    kTextFieldPass,
} ;



//---------------------------------------------------------------------------------------------------
//static URLDownloadObject *sharedInstance;


- (void)alertWithMessage:(NSString*)msg cancelText:(NSString*)cancelText goText:(NSString*)goText withTag:(NSInteger)theTag
{
    NSString *title ;
    if ( operationType == operationTypeDownload ) title = NSLocalizedString( @"Download", nil ) ;   
    if ( operationType == operationTypeOpen ) title = NSLocalizedString( @"Open File", nil ) ;
    if ( operationType == operationTypeScheme) title = NSLocalizedString( @"Action", nil ) ;
    id theDelegate = ( theTag==kAlertError ? nil : self ) ;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                message:msg
                                                delegate:theDelegate
                                                cancelButtonTitle:cancelText 
                                                otherButtonTitles:goText, nil ] ;
    [alert setTag:theTag] ;
    [alert show] ;
    //[alert release] ;
}



////---------------------------------------------------------------------------------------------------
//- (void)errorAlertWithMessageV:(NSString*)msg
//{
//    NSString *goText = NSLocalizedString( @"OK", nil ) ;
//    [self alertWithMessage:msg cancelText:nil goText:goText withTag:kAlertError] ;
//}


//---------------------------------------------------------------------------------------------------
- (void)errorAlertWithMessage:(NSString*)msg
{
    NSString *goText = NSLocalizedString( @"OK", nil ) ;
    [self alertWithMessage:msg cancelText:nil goText:goText withTag:kAlertError] ;
    
    NSString *title ;
    if ( operationType == operationTypeDownload ) title = NSLocalizedString( @"Download", nil ) ;   
    if ( operationType == operationTypeOpen ) title = NSLocalizedString( @"Open File", nil ) ;
    if ( operationType == operationTypeScheme) title = NSLocalizedString( @"Action", nil ) ;
    
    [SWQuickAlert presentQuickAlertWithTitle:title message:msg actionTitle:goText handler:nil];
}


//---------------------------------------------------------------------------------------------------
- (void)authErrorAlert
{
    NSString *errMsg = NSLocalizedString(@"User Authentication Failed", nil) ;            
    NSString *cancelText ;
    NSString *goText ;
    BOOL retry = [theChallenge previousFailureCount] < AuthRetries ;
    if ( retry )
    {
        cancelText = NSLocalizedString( @"Cancel", nil ) ;
        goText = NSLocalizedString( @"Retry", nil ) ;
    }
    else
    {
        cancelText = nil ;
        goText = NSLocalizedString( @"OK", nil ) ;
    }
    [self alertWithMessage:errMsg cancelText:cancelText goText:goText withTag:kAlertAuthError] ;
}

////---------------------------------------------------------------------------------------------------
//- (void)choiceAlertV
//{
//    NSString *fileName = [fileUrlPath lastPathComponent] ;
//    isSource = fileExtensionIsProject(fileName);
//    isActivationCode = fileExtensionIsActivationCode(fileName);
//    activationCode = nil;
//    
//    NSString *format = nil;
//    if ( isSource )
//    {
//        format = NSLocalizedString(@"LoadProjectWarningMessage%@", nil );
//    }
//    
//    else if ( isActivationCode )
//    {
//    
//        NSData *data = [[NSData alloc] initWithContentsOfFile:fileUrlPath];
//        NSInteger dataLength = data.length;
//        if ( dataLength > 0 && dataLength <= 12 )
//            activationCode = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    
//        if ( activationCode )
//            format = NSLocalizedString(@"LoadActivationCodeWarningMessage%@", nil );
//        
//        else
//            format = NSLocalizedString(@"LoadActivationCodeErrorMessage%@", nil );
//    }
//    
//    else
//    {
//        format = NSLocalizedString(@"LoadAssetWarningMessage%@", nil ) ;
//    }
//    
//    NSString *message = [NSString stringWithFormat:format, fileName] ;
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Open External File", nil )
//                                                message:message
//                                                delegate:self
//                                                cancelButtonTitle:NSLocalizedString( @"Cancel", nil ) 
//                                                otherButtonTitles:nil ] ;
//    
//    NSInteger tag = kAlertChoice;
//    if ( isSource )
//    {
//        sourceButtonIndex = [alert addButtonWithTitle:NSLocalizedString( @"Move to Projects", nil )] ;
//    }
//    else if ( isActivationCode )
//    {
//        if ( activationCode )
//            activationCodeButtonIndex = [alert addButtonWithTitle:NSLocalizedString( @"Redeem Code", nil )] ;
//        
//        tag = kAlertRedeem;
//    }
//    else
//    {
//        docsButtonIndex = [alert addButtonWithTitle:NSLocalizedString( @"Move to Assets", nil )] ;
//        #if ( SWRecipes )
//            recipeButtonIndex = [alert addButtonWithTitle:NSLocalizedString( @"Move to Recipes", nil )] ;
//        #endif
//    }
//    
//    [alert setTag:tag] ;
//    [alert show] ;
//    //[alert release] ;
//}
//


//---------------------------------------------------------------------------------------------------
- (void)choiceAlert
{
    NSString *fileName = [fileUrlPath lastPathComponent] ;
    isSource = fileExtensionIsProject(fileName);
    isActivationCode = fileExtensionIsActivationCode(fileName);
    activationCode = nil;
    
    NSString *format = nil;
    if ( isSource )
    {
        format = NSLocalizedString(@"LoadProjectWarningMessage%@", nil );
    }
    
    else if ( isActivationCode )
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:fileUrlPath];
        NSInteger dataLength = data.length;
        if ( dataLength > 0 && dataLength <= 12 )
            activationCode = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
        if ( activationCode )
            format = NSLocalizedString(@"LoadActivationCodeWarningMessage%@", nil );
        
        else
            format = NSLocalizedString(@"LoadActivationCodeErrorMessage%@", nil );
    }
    
    else
    {
        format = NSLocalizedString(@"LoadAssetWarningMessage%@", nil ) ;
    }
    
    NSString *message = [NSString stringWithFormat:format, fileName] ;
    
    
    NSString *title = NSLocalizedString( @"Open External File", nil );
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil )  style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action)
    {
        [self endDownload];
    }];
    [alertController addAction:actionCancel];

    if ( isSource )
    {
        UIAlertAction *sourceButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Move to Projects", nil ) style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            fileCategory = kFileCategorySourceFile ;
            [self moveFileToDestination];
        }];
        [alertController addAction:sourceButtonAction];
    }
    
    else if ( isActivationCode )
    {
    
        if ( activationCode )
        {
            UIAlertAction *redeemCodeAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Redeem Code", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action)
            {
                [self redeemActivationCode];
            }];
            [alertController addAction:redeemCodeAction];
        }
    }
    
    else
    {
        UIAlertAction *assetButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Move to Assets", nil ) style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action)
        {
            fileCategory = kFileCategoryAssetFile;
            [self moveFileToDestination];
        }];
        [alertController addAction:assetButtonAction];
    }
    
    [SWQuickAlert showAlertController:alertController];
}




- (void)resetPasswordAlert
{
    NSString *format = NSLocalizedString(@"Enter new password for user: %@", nil);
    NSString *message = [NSString stringWithFormat:format, schemaUserName];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message //NSLocalizedString( @"Reset Password", nil )
                                                message:nil
                                                delegate:self
                                                cancelButtonTitle:NSLocalizedString( @"Cancel", nil ) 
                                                otherButtonTitles:NSLocalizedString( @"Ok", nil ), nil ] ;
    
    NSInteger tag = kAlertSchemeResetPassword;

    //[alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    UITextField *textField1 = [alert textFieldAtIndex:0];
    textField1.font = [UIFont systemFontOfSize:17];
    textField1.textColor = UIColorWithRgb(TextDefaultColor);
    textField1.placeholder = NSLocalizedString(@"New Password", nil);
    textField1.secureTextEntry = YES;
    
    UITextField *textField2 = [alert textFieldAtIndex:1];
    textField2.font = [UIFont systemFontOfSize:17];
    textField2.textColor = UIColorWithRgb(TextDefaultColor);
    textField2.placeholder = NSLocalizedString(@"Confirm Password", nil);
    textField2.secureTextEntry = YES;
    
    [alert setTag:tag];
    [alert show];
}



//---------------------------------------------------------------------------------------------------
- (void)userAndPasswordAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Server Authentication", nil ) 
                message:@"\n\n\n\n\n" // IMPORTANT
                delegate:self 
                cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                otherButtonTitles:NSLocalizedString(@"Enter",nil), nil];

    [alert setTag:kAlertAuthenticate] ;
    
    NSArray *parts = [fileUrlPath componentsSeparatedByString:@"//"] ;
    NSString *serverUrlFull = [parts lastObject] ;
    NSString *serverUrl = [serverUrlFull stringByDeletingLastPathComponent] ;
    //CGRect bounds = [alert bounds] ;
    
    UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,38,260,40)];
    urlLabel.font = [UIFont systemFontOfSize:16];
    urlLabel.textColor = [UIColor whiteColor];
    urlLabel.backgroundColor = [UIColor clearColor];
    urlLabel.shadowColor = [UIColor blackColor];
    urlLabel.shadowOffset = CGSizeMake(0,-1);
    urlLabel.numberOfLines = 2 ;
    urlLabel.textAlignment = NSTextAlignmentCenter;
    urlLabel.text = serverUrl ;
    [alert addSubview:urlLabel];
    //[urlLabel release] ;

    UITextField *userTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 260.0, 28.0)]; 
    //UITextField *userTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, bounds.size.height-85-35, 260.0, 25.0)];
    [userTextField setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin] ;
    [userTextField setBorderStyle:UITextBorderStyleRoundedRect] ;
    [userTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter] ;
    [userTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone] ;
    //[userTextField setBackgroundColor:[UIColor whiteColor]];
    [userTextField setFont:[UIFont systemFontOfSize:18]] ;
    [userTextField setKeyboardAppearance:UIKeyboardAppearanceAlert] ;
    [userTextField setPlaceholder:NSLocalizedString(@"username",nil)];
    
    [userTextField setTag:kTextFieldUser] ;
    [alert addSubview:userTextField];
    //[userTextField release] ;
 
    UITextField *passTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0+35.0, 260.0, 28.0)]; 
    //UITextField *passTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, bounds.size.height-85-35-35, 260.0, 25.0)];
    [passTextField setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin] ;
    
    [passTextField setBorderStyle:UITextBorderStyleRoundedRect] ;
    [passTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter] ;
    [userTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone] ;
    //[passTextField setBackgroundColor:[UIColor whiteColor]];
    [passTextField setFont:[UIFont systemFontOfSize:18]] ;
    [passTextField setKeyboardAppearance:UIKeyboardAppearanceAlert] ;
    [passTextField setPlaceholder:NSLocalizedString(@"password",nil)];
    [passTextField setSecureTextEntry:YES];
    
    [passTextField setTag:kTextFieldPass] ;
    [alert addSubview:passTextField];
    //[passTextField release] ;
 
    // set place
    //[alert setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
    [alert show];
    //[alert release];
 
    // set cursor and show keyboard
    [userTextField becomeFirstResponder];
}


//---------------------------------------------------------------------------------------------------
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = [alertView tag] ;
    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex] ;
    //NSInteger cancelButtonIndex = [alertView cancelButtonIndex] ;
 
    switch ( tag )
    {
        case kAlertError: // no passa mai     //1
                break ;
                
        case kAlertChoice :
        
            if ( isSource )
            {
                if ( buttonIndex == sourceButtonIndex ) fileCategory = kFileCategorySourceFile ;
//                #if ( SWRecipes )
//                    else if ( buttonIndex == recipeButtonIndex ) fileCategory = kFileCategoryRecipe ;
//                #endif
//                else if ( buttonIndex == docsButtonIndex ) fileCategory = kFileCategoryAssetFile ;
                else fileCategory = kFileCategoryUnknown ;
            }
            
            
            
            else
            {
                if ( buttonIndex == docsButtonIndex ) fileCategory = kFileCategoryAssetFile ;
                #if ( SWRecipes )
                    else if ( buttonIndex == recipeButtonIndex ) fileCategory = kFileCategoryRecipe ;
                #endif
//                fileCategory = kFileCategoryAssetFile ;
            }
            
            [self moveFileToDestination] ;
            break ;
            
            
        case kAlertRedeem:
        
            if ( isActivationCode && activationCode && buttonIndex == activationCodeButtonIndex )
            {
                [self redeemActivationCode];
            }
            else
            {
                [self endDownload];
            }
            break;
            
        case kAlertAuthError: // 1
            
            if ( buttonIndex == firstOtherButtonIndex )
            {
                if ( [theChallenge previousFailureCount] >= AuthRetries ) [self endDownload] ;
                else [self userAndPasswordAlert] ; 
            }
            else
            {
                NSLog1( @"kAlertAuthError Cancel") ;
                [self endDownload] ;
            }
            break ;
            
        case kAlertAuthenticate :
        
            if ( buttonIndex == firstOtherButtonIndex )
            {
                NSLog1( @"UserPassword touched OK") ;
                UITextField *userTextField = (id)[alertView viewWithTag:kTextFieldUser] ;
                UITextField *passTextField = (id)[alertView viewWithTag:kTextFieldPass] ;
                NSString *user = [userTextField text] ;
                NSString *pass = [passTextField text] ;
                
                NSURLCredential *newCredential = [NSURLCredential credentialWithUser:user password:pass persistence:NSURLCredentialPersistenceNone];
                [[theChallenge sender] useCredential:newCredential forAuthenticationChallenge:theChallenge];
                break ;
            }
            else
            {
                NSLog1( @"UserPassword touched Cancel") ;
                [self endDownload] ;
            }
            break ;
            
        case kAlertSchemeConfirmActivate:  //1
        
            if ( buttonIndex == firstOtherButtonIndex )
            {
                [usersModel() processActivateUserForUserId:schemaUserId resetToken:schemaToken];
            }
            [self endDownload];
            break;
            
        case kAlertSchemeConfirmDelete:   //1
        
            if ( buttonIndex == firstOtherButtonIndex )
            {
                [usersModel() processDeleteUserForUserId:schemaUserId resetToken:schemaToken];
            }
            [self endDownload];
            break;
            
        case kAlertSchemeResetPassword:   //1
            
            if ( buttonIndex == firstOtherButtonIndex )
            {
                NSString *pass1 = [[alertView textFieldAtIndex:0] text];
                NSString *pass2 = [[alertView textFieldAtIndex:1] text];
                if ( [pass1 isEqualToString:pass2] && pass1.length >= 4)
                {
                    [usersModel() processResetPasswordForUserId:schemaUserId newPassword:pass1 resetToken:schemaToken];
                    [self endDownload];
                }
                else
                {
                    NSString *message = NSLocalizedString(@"New password must be typed twice and be at least 4 characters long", nil);
                    NSString *goText = NSLocalizedString(@"Ok", nil);
                    
                    [self alertWithMessage:message cancelText:nil goText:goText withTag:kAlertSchemeResetPasswordRepeat];
                }
            }
            else [self endDownload];
            break;
            
        case kAlertSchemeResetPasswordRepeat:  //1
        
            if ( buttonIndex == firstOtherButtonIndex )
            {
                [self resetPasswordAlert];
            }
            else [self endDownload];
            break;
            
    }
}



////---------------------------------------------------------------------------------------------------
//- (void)alertViewV:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    NSInteger tag = [alertView tag] ;
//    
//    // cancel button
//    if ( buttonIndex == [alertView cancelButtonIndex] )
//    {
//        switch ( tag )
//        {
//            case kAlertChoice :
//            case kAlertError:  // no passa mai
//                break ;
//                
//            case kAlertAuthenticate :
//            case kAlertAuthError:
//            {
//                if (DEBUGING) NSLog( @"UserPassword touched Cancel") ;             
//                [self endDownload] ;
//                break ;
//            }
//        }
//    }
//    
//    // ok button
//    else
//    {
//        switch ( tag )
//        {
//            case kAlertError: // no passa mai
//                break ;
//                
//            case kAlertChoice :
//                if ( operationType == operationTypeOpen ) [self moveFileToDestination] ;
//                break ;
//                
//            case kAlertAuthError:
//            {
//                if ( [theChallenge previousFailureCount] >= AuthRetries ) [self endDownload] ;
//                else [self userAndPasswordAlert] ; 
//                break ;
//            }
//            case kAlertAuthenticate :
//            {
//                if (DEBUGING) NSLog( @"UserPassword touched OK") ;
//                UITextField *userTextField = (id)[alertView viewWithTag:kTextFieldUser] ;
//                UITextField *passTextField = (id)[alertView viewWithTag:kTextFieldPass] ;
//                NSString *user = [userTextField text] ;
//                NSString *pass = [passTextField text] ;
//                
//                NSURLCredential *newCredential = [NSURLCredential credentialWithUser:user password:pass persistence:NSURLCredentialPersistenceNone];
//                [[theChallenge sender] useCredential:newCredential forAuthenticationChallenge:theChallenge];
//                break ;
//            }
//        }
//    }
//}




//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark init/dealloc
//////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------------
- (id)initForDownloadingFileUrlName:(NSString*)file withFileCategory:(FileCategory)category
{
    if ( (self = [super init]) )
    {
        // Create the request.
        //fileUrlPath = [file retain] ;
        fileUrlPath = file;
        operationType = operationTypeDownload ;
        fileCategory = category ;
        NSURL *url = [NSURL URLWithString:fileUrlPath] ;
        
        //NSLog1( @"didReceiveResponse URL pass:%@", [url password] ) ;
    
//        NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
//                        cachePolicy:NSURLRequestUseProtocolCachePolicy
//                        timeoutInterval:20.0];
        
        
        NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:url
                cachePolicy:NSURLRequestUseProtocolCachePolicy
                timeoutInterval:20.0];
        
       // [theRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
                        
        // create the connection with the request
        // and start loading the data
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (connection) 
        {
            theConnection = connection ;
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            receivedData = [[NSMutableData alloc] init];
            //[[NSNotificationCenter defaultCenter] postNotificationName:URLDownloadObjectBegan object:self] ;
        } 
        else 
        {
            // Inform the user that the connection failed.
            NSLog1( @"Inform the user that the connection failed" ) ;
            [[NSNotificationCenter defaultCenter] postNotificationName:URLDownloadObjectEnded object:self] ;
            //[self release] ;
            self = nil ;
        }
    }

    return self ;
}

//---------------------------------------------------------------------------------------------------
- (id)initForOpeningFileUrlName:(NSString*)file delegate:(id<URLDownloadObjectDelegate>)delegate
{
    if ( (self = [super init]) )
    {
        // Create the request.
        fileUrlPath = file ;
        operationType = operationTypeOpen ;
        _delegate = delegate;
        [self choiceAlert] ;
    }
    
    return self ;
}


//---------------------------------------------------------------------------------------------------
- (id)initForOpeningSchemeURL:(NSURL*)url
{
    if ( (self = [super init]) )
    {
        operationType = operationTypeScheme;
        
        NSString *host = [url host];
        NSArray *components = [url pathComponents];
        NSLog1( @"host: %@", host );
        NSLog1( @"components: %@", components);
        NSInteger componentsCount = components.count;
    
        if ( host.length > 0 && (componentsCount == 3 || componentsCount == 4) )
        {
            NSString *component1 = [components objectAtIndex:1];
            NSString *component2 = [components objectAtIndex:2];
            NSString *component3 = componentsCount>3?[components objectAtIndex:3]:nil;
            
            schemaUserId = [component1 intValue];
            
            UserProfile *profile = [usersModel() profileForUserId:schemaUserId];
            if ( profile != nil )
            {
                schemaUserName = profile.username;
            }
            NSString *cancelText = NSLocalizedString(@"Cancel", nil);
            NSString *goText = NSLocalizedString(@"Ok", nil);
            
            if ( NSOrderedSame == [host caseInsensitiveCompare:@"reset_password"] )
            {
                schemaUserName = component2;
                schemaToken = component3;
                if ( schemaUserId != 0 )
                {
                    [self resetPasswordAlert];
                    return self;
                }
            }
    
            if ( NSOrderedSame == [host caseInsensitiveCompare:@"delete_user"] )
            {
                schemaToken = component2;
                NSString *username = schemaUserName;
                if ( username.length == 0 ) username = [NSString stringWithFormat:@"%u", (unsigned int)schemaUserId];
                
                NSString *format = NSLocalizedString(@"User: %@ will be deleted", nil);
                NSString *message = [NSString stringWithFormat:format, username];
                [self alertWithMessage:message cancelText:cancelText goText:goText withTag:kAlertSchemeConfirmDelete];
                return self;
            }
        
            if ( NSOrderedSame == [host caseInsensitiveCompare:@"activate"] )
            {
                schemaToken = component2;
                NSString *username = schemaUserName;
                if ( username.length == 0 ) username = [NSString stringWithFormat:@"%u", (unsigned int)schemaUserId];
                
                NSString *format = NSLocalizedString(@"User: %@ will be activated", nil);
                NSString *message = [NSString stringWithFormat:format, username];
                [self alertWithMessage:message cancelText:cancelText goText:goText withTag:kAlertSchemeConfirmActivate];
                return self;
            }
        
            // error;
        }
    
        NSString *format = NSLocalizedString(@"Could not process external URL schema: %@",nil);
        NSString *message = [NSString stringWithFormat:format, url.absoluteString];

        [self errorAlertWithMessage:message];
        [self endDownload];
    }
    
    return self ;
}

//---------------------------------------------------------------------------------------------------
+ (void)downloadFileWithUrlName:(NSString*)file withFileCategory:(int)category
{
    //sharedInstance = nil ;
    //sharedInstance = [[URLDownloadObject alloc] initForDownloadingFileUrlName:file withFileCategory:category] ;
    
    ////[[URLDownloadObject alloc] initForDownloadingFileUrlName:file withFileCategory:category] ;
    //// ell mateix s'allibera
    
    CFTypeRef dynStore = (__bridge_retained CFTypeRef)[[URLDownloadObject alloc] initForDownloadingFileUrlName:file withFileCategory:category] ;
    (void)dynStore ;
    // ell mateix s'allibera
}

//---------------------------------------------------------------------------------------------------
+ (void)openFromExternalAppWithFileUrlName:(NSString*)file delegate:(id<URLDownloadObjectDelegate>)delegate
{
    CFTypeRef dynStore = (__bridge_retained CFTypeRef)[[URLDownloadObject alloc] initForOpeningFileUrlName:file delegate:delegate] ;
    (void)dynStore ;
    // ell mateix s'allibera
}


//---------------------------------------------------------------------------------------------------
+ (void)openFromExternalSchemeURL:(NSURL*)url
{
    CFTypeRef dynStore = (__bridge_retained CFTypeRef)[[URLDownloadObject alloc] initForOpeningSchemeURL:url] ;
    (void)dynStore ;
    // ell mateix s'allibera
}


//---------------------------------------------------------------------------------------------------
- (void)disposeProperties
{
    receivedData = nil ;
    fileUrlPath = nil ;
    theChallenge = nil ;
    theConnection = nil ;
}


//---------------------------------------------------------------------------------------------------
- (void)dealloc
{
    //[self disposeProperties] ;
    //[super dealloc] ;
}


//---------------------------------------------------------------------------------------------------
- (void)selfDispose:(id)dummy
{
    //sharedInstance = nil ;
    
    CFTypeRef dynStore = (__bridge CFTypeRef)self ;
    CFRelease( dynStore ) ;
}

//---------------------------------------------------------------------------------------------------
- (void)endDownload
{
    NSLog1( @"URLDownloadObject endDownload ");
    [theConnection cancel] ;
        
    // notifiquem i ens alliberem a nosaltres mateixos
    [[NSNotificationCenter defaultCenter] postNotificationName:URLDownloadObjectEnded object:self] ;
    [self disposeProperties] ;
    [self performSelector:@selector(selfDispose:) withObject:nil afterDelay:0.0] ;
}


//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark File Methods
//////////////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------------------------
- (NSString *)getDestinationPath
{
    NSString *file = [fileUrlPath lastPathComponent] ;
    NSString *fileName = nil ;
    
    //fileName = [[model() filesRootDirectoryForCategory:fileCategory] stringByAppendingPathComponent:file] ;
    fileName = [filesModel().filePaths fileFullPathForFileName:file forCategory:fileCategory];
    
    return fileName ;
}

//---------------------------------------------------------------------------------------------------
- (void)establishFile
{
//    [filesModel() filesArrayTouchForCategory:fileCategory] ;
//    if ( fileCategory == kFileCategorySourceFile ) [defaults() setShouldParseFiles:YES] ;
}

////---------------------------------------------------------------------------------------------------
//- (void)moveFileToDestinationV
//{
//    NSString *fileName = [self getDestinationPath] ;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ( [fileManager fileExistsAtPath:fileName] )
//    {
//        [fileManager removeItemAtPath:fileName error:nil] ;
//    }
//    
//    NSError *error = nil ;
//    if ( fileName && [fileManager moveItemAtPath:fileUrlPath toPath:fileName error:nil] == NO )
//    {
//        //NSLog(@"Failed to move file '%@', error: '%@'.", fileName, [error localizedDescription]);
//        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Failed to move file. %@", nil), [error localizedDescription]] ;   // localitzar
//        [self errorAlertWithMessage:errMsg] ;
//    }
//    [self establishFile] ;
//    [self endDownload] ;
//}

//---------------------------------------------------------------------------------------------------
- (void)moveFileToDestination
{
    NSError *error = nil ;
//    NSString *fileName = [fileUrlPath lastPathComponent];
//    NSString *fileFullPath = [filesModel() fileFullPathForFileName:fileName forCategory:fileCategory];
//    BOOL success = [filesModel() moveFromExternalFileFullPath:fileUrlPath toFileFullPath:fileFullPath error:&error alwaysDeleteOriginal:YES];
    BOOL success = [filesModel().files moveFromExternalFileFullPath:fileUrlPath toCategory:fileCategory error:&error alwaysDeleteOriginal:YES];
    
//    [model() copyToTemporaryForFileFullPath:fileUrlPath];
//    BOOL success = [model() moveFromTemporaryForFileFullPath:fileFullPath error:&error];
    
    if ( success == NO )
    {
        //NSLog(@"Failed to move file '%@', error: '%@'.", fileName, [error localizedDescription]);
        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Failed to move file. %@", nil), [error localizedDescription]] ;   // localitzar
        [self errorAlertWithMessage:errMsg] ;
    }
    
    [self establishFile] ;
    [self endDownload] ;
}


- (void)redeemActivationCode
{
//    NSData *data = [[NSData alloc] initWithContentsOfFile:fileUrlPath];
//    NSString *code = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
   
    [_delegate URLDownloadObject:self redeemCode:activationCode];
    [self endDownload];
}



//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Delegate Methods
//////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------------
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    NSLog1( @"canAuthenticateAgainstProtectionSpace" ) ;
    return YES ;
}

//---------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog1( @"didReceiveAuthenticationChallenge" ) ;
    //[challenge retain] ;
    //[theChallenge release] ;
    theChallenge = challenge ;
    
/*
    if ( failureCount == 0 )
    {
        [self userAndPasswordAlert] ;
        //NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"user" password:@"user1234" persistence:NSURLCredentialPersistenceNone];
        //[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else 
    {
      //  [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
      //  [self showPreferencesCredentialsAreIncorrectPanel:self];
        
    // fer aixo en lloc de lo anterior?   
        //[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge] ;
        
        
        NSString *errMsg = NSLocalizedString(@"User Authentication Failed", nil) ; 
        [self errorAlertWithMessage:errMsg] ;
        if ( failureCount >= 3 ) [self endDownload] ;
        else [self userAndPasswordAlert] ;
    }
*/
    
    
    if ( [theChallenge previousFailureCount] == 0 )
    {
        [self userAndPasswordAlert] ;
    }
    else
    {
        [self authErrorAlert] ;
    }
}


//---------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
 
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
 
    // receivedData is an instance variable declared elsewhere.
    long long int expectedLength = [response expectedContentLength] ;
    if ( DEBUGING )
    {
        NSLog1( @"didReceiveResponse expectedContentLength:%lld", expectedLength ) ;
        NSLog1( @"didReceiveResponse suggestedFileName:%@", [response suggestedFilename] ) ;
        NSLog1( @"didReceiveResponse MIMEType:%@", [response MIMEType] ) ;
        NSLog1( @"didReceiveResponse TextEncodingName:%@", [response textEncodingName] ) ;
        NSLog1( @"didReceiveResponse URL:%@", [[response URL] absoluteString] ) ;
        NSLog1( @"didReceiveResponse URL pass:%@", [[response URL] password] ) ;
        
        NSLog1(@"didReceiveResponse StatusCode:%d", [(NSHTTPURLResponse*)response statusCode]);
        NSLog1(@"didReceiveResponse LocalizedStringForStatusCode:%@",
            [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse*)response statusCode]]);
    }
    
    [receivedData setLength:0];
    if ( expectedLength <= 0 )
    {
        NSLog1( @"connection canceled" ) ;
        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Unable to access %@", nil), fileUrlPath] ;
            
        [self errorAlertWithMessage:errMsg] ;
        [self endDownload] ;
    }
    
    NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
    if ( statusCode != 200  )
    {
        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Download Failed: HTTP Error %d, \"%@\"", nil),
            statusCode,
            [NSHTTPURLResponse localizedStringForStatusCode:statusCode]] ;
          
        [self errorAlertWithMessage:errMsg] ;
        [self endDownload] ;
    }
    
}


//---------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    NSLog1(@"Received some bytes (%d) of data",[data length]);
    [receivedData appendData:data];
}



//---------------------------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog1(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSString *fileName = [fileUrlPath lastPathComponent] ;
    NSError *error = nil;
    
    NSString *tmpFilePath = [filesModel().filePaths temporaryFilePathForFileName:fileName];
    BOOL success = [receivedData writeToFile:tmpFilePath options:NSAtomicWrite error:&error];

    
    if ( success )
    {
        success = [filesModel().files moveFromTemporaryToCategory:fileCategory forFile:fileName addCopy:NO error:&error];
        if ( success )
        {
            [self establishFile];
        }
    }
    
    if ( success == NO )
    {
        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil),
            [error localizedDescription]] ;
          
        [self errorAlertWithMessage:errMsg] ;
    }
 
    [self endDownload] ;
}

    
    





//---------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Download Failed: %@ %@", nil),
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]] ;
          
    [self errorAlertWithMessage:errMsg] ;
    [self endDownload] ;
}









@end
