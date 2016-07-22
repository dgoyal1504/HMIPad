//
//  FilesViewController.h
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWTableFieldsControllerDelegate.h"
//#import "InsetUITableViewController.h"

@class MessageView ;
@class ManagedTextFieldCell ;
@class TextFieldCell ;
@class SWTableFieldsController ;
@class SWTableViewMessage;

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark DownloadFromServerController
///////////////////////////////////////////////////////////////////////////////////////////


@interface DownloadFromServerController : UITableViewController<UIActionSheetDelegate,UITextFieldDelegate,SWTableFieldsControllerDelegate>
{
    SWTableFieldsController *rightButton ; // amagatzema el boto de la dreta del navigator
    ManagedTextFieldCell *downloadServerNameCell ;
    ManagedTextFieldCell *downloadFileNameCell ;
    SWTableViewMessage *messageDownload ;
    
    BOOL viewAppeared ;
    BOOL dataNeedsReload ;
    
    BOOL downloading ;
    int fileCategory ;  // Es un FileCategory
    
}

- (id)initWithFileCategory:(int)category ;

@end
