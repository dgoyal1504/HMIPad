//
//  SWCustomSendMailController.m
//  HmiPad
//
//  Created by Joan on 08/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "UIViewController+SWSendMailControllerPresenter.h"

#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"

#import "SWKeyboardDismissNavigationController.h"
#import "SWBlockAlertView.h"

#import "SendMailController.h"
#import "SWExamplesViewController.h"
#import "DownloadFromServerController.h"
#import "SWRedeemViewController.h"
#import "SWUploadViewController.h"
#import "EditAccountTableController.h"
#import "SWCloudKitMigrationController.h"



@implementation UIViewController(SWSendMailControllerPresenter)


- (void)presentMailControllerForActivationCodeMD:(FileMD*)fileMD
{
    SendMailController *mailController = [[SendMailController alloc] init];

    if ( mailController == nil)
        return;
    
    [mailController setSubject:NSLocalizedString(@"ActivationCodeMailMessageSubject",nil)];

    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
    [mailController setToRecipients:toRecipients];
    
    NSMutableString *emailBodyFormat = [NSMutableString stringWithString:NSLocalizedString(@"ActivationCodeBodyFormat%@%@%@", nil)];
    
    NSString *fileName = fileMD.fileName;
    NSString *accessCode = fileMD.accessCode;
    NSString *emailBody = [NSString stringWithFormat:emailBodyFormat, fileName, accessCode, fileMD.fileDateString, fileMD.maxRedemptions ];
    [mailController setMessageBody:emailBody isHTML:NO];
    
    NSString *theFile = [NSString stringWithFormat:@"%@.hmipadcode", accessCode];
    NSData *myData = [accessCode dataUsingEncoding:NSASCIIStringEncoding];
    //[mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:theFile];
    [mailController addAttachmentData:myData mimeType:@"text/plain" fileName:theFile];
    
    //[self presentModalViewController:mailController animated:YES];

    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailController animated:YES completion:nil];
}




- (void)presentMailControllerForFiles:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory
{
    SendMailController *mailController = [[SendMailController alloc] init];
    
    if ( mailController == nil)
        return;
    
    [mailController setSubject:NSLocalizedString(@"MailMessageSubject",nil)];

    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
    [mailController setToRecipients:toRecipients];
    
    NSArray *attachmentMDs = fileMDs;   //[self fileMDsForSelectedRows];
    
    NSMutableString *emailBody;
    if ( [attachmentMDs count] == 0 )
    {
        emailBody = [NSMutableString stringWithString:NSLocalizedString(@"MailMessageFrom", nil)];
    }
    else
    {
        emailBody = [NSMutableString stringWithString:NSLocalizedString(@"MailPleaseFindAttached", nil)];
        for ( FileMD *fileMD in attachmentMDs )
        {
            NSString *fileName = fileMD.fileName;
            [emailBody appendFormat:@"\n%@",fileName];
            NSString *originPath = [filesModel().filePaths originPathForFilename:fileName forCategory:fileCategory];
            
            NSData *myData = [[NSData alloc] initWithContentsOfFile:originPath];
            //[mailController addAttachmentData:myData mimeType:@"text/csv" fileName:fileName];
            [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:fileName];
        }
    }
            
    [mailController setMessageBody:emailBody isHTML:NO];
    
    //[self presentModalViewController:mailController animated:YES];
    
    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailController animated:YES completion:nil];
}


@end

@implementation UIViewController(SWExamplesController)

- (void)presentExamplesController
{
    UIViewController *viewController = [[SWExamplesViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

@end


@implementation UIViewController(ReviewAppMailController)

- (void)presentReviewAppMailController
{
    SendMailController *mailController = [[SendMailController alloc] init];
    
    if ( mailController == nil)
        return;
    
    [mailController setSubject:NSLocalizedString(@"ReviewAppMailMessageSubject",nil)];

    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@ SWSupportEmail];
    [mailController setToRecipients:toRecipients];
    
    NSMutableString *emailBody = [NSMutableString stringWithString:NSLocalizedString(@"ReviewAppMailMessageBodyFormat", nil)];
    
    [mailController setMessageBody:emailBody isHTML:NO];

    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailController animated:YES completion:nil];
    
//    
//    UIViewController *rootPresentedController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
//    [rootPresentedController presentViewController:mailController animated:YES completion:nil];
}

@end


@implementation UIViewController(DownloadFromServerController)

- (void)presentDownloadFromServerControllerForFileCategory:(int)fileCategory
{
    DownloadFromServerController *viewController = [[DownloadFromServerController alloc] initWithFileCategory:fileCategory];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

@end


@implementation UIViewController(SWRedeemViewController)

- (void)presentRedeemControllerForActivationCode:(NSString*)code
{
    NSString *storyBoardName;
    if ( IS_IOS7 ) storyBoardName = @"SWRedeemViewController";
    else storyBoardName = @"SWRedeemViewController6";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    SWRedeemViewController *redeemPresenter = [storyboard instantiateInitialViewController];
    [redeemPresenter setActivationCode:code];
    UINavigationController *navController = [[SWKeyboardDismissNavigationController alloc] initWithRootViewController:redeemPresenter];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)presentUpdateControllerForProjectId:(NSString*)projectId //owner:(UInt32)ownerId
{
    NSString *storyBoardName;
    if ( IS_IOS7 ) storyBoardName = @"SWRedeemViewController";
    else storyBoardName = @"SWRedeemViewController6";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    SWRedeemViewController *updatePresenter = [storyboard instantiateInitialViewController];
    [updatePresenter setProjectCode:projectId];
    //[updatePresenter setProjectOwner:ownerId];
    
    UINavigationController *navController = [[SWKeyboardDismissNavigationController alloc] initWithRootViewController:updatePresenter];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

@end


@implementation UIViewController(SWUploadViewController)

- (void)presentUploadController
{
    NSString *storyBoardName;
    if ( IS_IOS7 ) storyBoardName = @"SWUploadViewController";
    else storyBoardName = @"SWUploadViewController6";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    SWUploadViewController *uploadPresenter = [storyboard instantiateInitialViewController];
    UINavigationController *navController = [[SWKeyboardDismissNavigationController alloc] initWithRootViewController:uploadPresenter];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

@end



@implementation UIViewController(SWLogToICloudAlert)

- (void)presentNoUserAlertFromView:(UIView*)view
{
    NSString *title = NSLocalizedString( @"No iCloud User", nil);
    NSString *message = NSLocalizedString( @"NoICloudUserAlert", nil);
    NSString *ok = NSLocalizedString( @"Ok", nil );
    
    UIAlertControllerStyle alertStyle = view == nil ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:alertStyle];

    if ( alertStyle == UIAlertControllerStyleActionSheet )
    {
        UIPopoverPresentationController *popoverPresentationController = alert.popoverPresentationController;
        popoverPresentationController.sourceRect = view.bounds;
        popoverPresentationController.sourceView = view;
    }

    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:nil];
        
    [alert addAction:actionOk];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end




@implementation UIViewController(SWNewAccountViewController)

- (void)presentNewAccountController
{
    // create account
    UIViewController *viewController = [[EditAccountTableController alloc] initWithUsername:nil type:kAccountControllerNew];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

@end


@implementation UIViewController(SWMigrationAssistantViewController)

- (void)presentMigrationAssistantController
{
    UIViewController *viewController = [[SWCloudKitMigrationController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:viewController animated:YES completion:nil];
}

+ (void)presentMigrationAssistantController
{
    UIViewController *viewController = [[SWCloudKitMigrationController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [SWQuickAlert showAlertController:viewController];
}

@end







