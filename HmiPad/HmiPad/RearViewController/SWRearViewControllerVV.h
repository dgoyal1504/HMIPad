//
//  FilesViewController.h
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "NavigationButtonControllerDelegate.h"
//#import "InsetUITableViewController.h"

@class SWTableViewMessage ;
@class ControlViewCell, InfoViewCell, SwitchViewCell, ManagedTextFieldCell, LabelViewCell;
@class LoginWindowControllerC;

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark FilesViewController
///////////////////////////////////////////////////////////////////////////////////////////

#import "SWTableViewController.h"

@interface SWRearViewController : SWTableViewController
//@interface SWRearViewController : UIViewController
{
    SwitchViewCell *automaticLoginCell; // celda que conté el switch de automatic login
    LabelViewCell *currentAccountCell; // celda que mostra la conta actual i permet Login
    ControlViewCell *manageAccountsCell; // celda per accedir a les comptes si es administrador
    LabelViewCell *currentProjectCell; // celda per accedir al projecte actual
    ControlViewCell *settingsCell; // celda per accedir als settings
    ManagedTextFieldCell *accessLimitCell; // celda que mostra el nivell d'acces limit
    ManagedTextFieldCell *fileAccessLimitCell; // celda que mostra el nivell d'acces a fitxers

    SwitchViewCell *fileServerSwitchCell ;
    InfoViewCell *fileServerInfoCell;
    
    SWTableViewMessage *messageViewUser;
    SWTableViewMessage *messageViewLocalStorage;
    SWTableViewMessage *messageViewRedeemedStorage;
    SWTableViewMessage *messageViewRemoteStorage ;
    SWTableViewMessage *messageExtFilesView ;
    SWTableViewMessage *messageFileServerView ;
    SWTableViewMessage *messageDownload ;
    UIView *versionView ;
    
    LoginWindowControllerC *loginWindow;  // per amagatzemar la finestra de login
}

// metodes asimilables a un UITableViewController
//- (id)initWithStyle:(UITableViewStyle)style;
//@property (nonatomic,retain) UITableView *tableView;
//@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;


@end
