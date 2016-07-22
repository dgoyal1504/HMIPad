//
//  SWCustomSendMailController.m
//  HmiPad
//
//  Created by Joan on 08/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "UIViewController+SWSendMailControllerPresenter.h"

#import "SendMailController.h"
#import "AppFilesModel.h"



@implementation UIViewController(SWSendMailControllerPresenter)


- (void)presentMailControllerForActivationCode:(FileMD*)fileMD
{    
    SendMailController *mailController = [[SendMailController alloc] init];
    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [mailController setSubject:NSLocalizedString(@"ActivationCodeMailMessageSubject",nil)];

    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
    [mailController setToRecipients:toRecipients];
    
    NSMutableString *emailBodyFormat = [NSMutableString stringWithString:NSLocalizedString(@"ActivationCodeBodyFormat%@%@%d", nil)];
    
    NSString *accessCode = fileMD.accessCode;
    NSString *emailBody = [NSString stringWithFormat:emailBodyFormat, accessCode, fileMD.created, fileMD.maxRedemptions ];
    [mailController setMessageBody:emailBody isHTML:NO];
    
    NSString *fileName = @"AccessCode.hmipadcode";
    NSData *myData = [accessCode dataUsingEncoding:NSASCIIStringEncoding];
    [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:fileName];
    
    [self presentModalViewController:mailController animated:YES];
}




- (void)presentMailControllerForFiles:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory
{
    SendMailController *mailController = [[SendMailController alloc] init];
    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [mailController setSubject:NSLocalizedString(@"MailMessageSubject",nil)];

    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
    [mailController setToRecipients:toRecipients];
    
    NSArray *attachmentMDs = fileMDs;   //[self fileMDsForSelectedRows];
    
    NSMutableString *emailBody;
    if ( [attachmentMDs count] == 0 )
    {
        emailBody = [NSString stringWithString:NSLocalizedString(@"MailMessageFrom", nil)];
    }
    else
    {
        emailBody = [NSMutableString stringWithString:NSLocalizedString(@"MailPleaseFindAttached", nil)];
        for ( FileMD *fileMD in attachmentMDs )
        {
            NSString *fileName = fileMD.fileName;
            [emailBody appendFormat:@"\n%@",fileName];
            //NSString *originPath = [self originPathForFileName:fileName];
            NSString *originPath = [filesModel() originPathForFilename:fileName forCategory:fileCategory];
            
            NSData *myData = [[NSData alloc] initWithContentsOfFile:originPath];
            //[mailController addAttachmentData:myData mimeType:@"text/csv" fileName:fileName];
            [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:fileName];
        }
    }
            
    [mailController setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:mailController animated:YES];
}









@end
