//
//  SettingsViewController.h
//  iPhoneDomus
//
//  Created by Joan on 07/12/08.
//  Copyright 2008 SweetWilliam, S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableFieldsControllerDelegate.h"
#import "SWTableViewController.h"

@class SWTableViewMessage ;
@class ControlViewCell, InfoViewCell, SwitchViewCell, ManagedTextFieldCell, LabelViewCell;
@class SWTableFieldsController;
@protocol NavigationButtonControllerDelegate ;

@interface SWSettingsViewController : SWTableViewController<UITextFieldDelegate,SWTableFieldsControllerDelegate>
{
    SWTableFieldsController *rightButton ; // amagatzema el boto de la dreta del navigator    
    
    SWTableViewMessage *messageView ;
    SWTableViewMessage *mViewUserInterface ;
    SWTableViewMessage *mViewAlarms ;
    SWTableViewMessage *mViewWebServer ;
    SWTableViewMessage *mViewMaintenance ;
    SWTableViewMessage *mViewMigrate;
    SWTableViewMessage *mViewFeedback ;
    //SWTableViewMessage *mViewDefaults ;
    UIView *versionView ;
    
    //ControlViewCell *manageConnectionsCell; // celda per accedir a les comptes si es administrador
    
    
    //SwitchViewCell *automaticLoginCell; // celda que conté el switch de automatic login
    //LabelViewCell *currentAccountCell; // celda que mostra la conta actual i permet Login
    //ControlViewCell *manageAccountsCell; // celda per accedir a les comptes si es administrador
    ManagedTextFieldCell *accessLimitCell; // celda que mostra el nivell d'acces limit
    ManagedTextFieldCell *fileAccessLimitCell; // celda que mostra el nivell d'acces a fitxers
    
    ManagedTextFieldCell *fileServerPortCell; // celda que mostra el port per defecte del file server
    
//    ManagedTextFieldCell *finsTcpPortCell; // celda que mostra el port per defecte del protocol fins
//    ManagedTextFieldCell *finsTcpAltPortCell; // celda que mostra el port per defecte del protocol fins
//    
//    ManagedTextFieldCell *modbusTcpPortCell; // celda que mostra el port per defecte del protocol modbus
//    ManagedTextFieldCell *modbusTcpAltPortCell; // celda que mostra el port per defecte del protocol modbus
//    
//    ManagedTextFieldCell *eipAltPortCell; // celda que mostra el port per defecte del protocol EIP
//    ManagedTextFieldCell *siemensS7AltPortCell; // celda que mostra el port per defecte del protocol Siemens
//    
//    ManagedTextFieldCell *host1AddrViewCell; // celda per entrar la addressa local
//    ManagedTextFieldCell *host2NameViewCell; // celda per entrar la addressa remota 
//    SwitchViewCell *host2EnableSSLCell; // celda per establir si es vol ssl
//    ControlViewCell *pollRateCell; // celda per establir el interval de poll
    
    SwitchViewCell *enablePageDetentsCell; // celda per establir si es vol que el page switcher tingui parades
    SwitchViewCell *hiddenTabBarCell; // celda per establir si es vol continuar comunicant en repos
    SwitchViewCell *hiddenFilesTabBarCell; // celda per establir si es vol continuar comunicant en repos
    SwitchViewCell *animateVisibleChangesCell ; // celda per establir que continuem comunicant en el background
    SwitchViewCell *doubleColumnCell ; // celda per establir doble columna en iPad Portrait
    SwitchViewCell *animatePageShiftsCell ; // celda per establir que continuem comunicant en el background
    
    SwitchViewCell *alertingAlarmsCell ; // celda per establir que les alarmes presenten una alerta
    SwitchViewCell *soundingAlarmsCell ; // celda per establir que les alarmes sonen
    SwitchViewCell *disconnectAlertCell ; // celda per establir que volem alarmes de desconexio
    SwitchViewCell *keepConnectedCell; // celda per establir si es vol continuar comunicant en repos
    SwitchViewCell *multitaskCell ; // celda per establir que continuem comunicant en el background
    ControlViewCell *tickVolumeCell; // celda per establir el interval de poll
    
//    ControlViewCell *buyAllowancesCell ; // celda que representa un boto per comprar drets
    
    
    //ManagedTextFieldCell *plcValidationCodeCell;
    
    
    //ControlViewCell *manageFilesCell; // celda per accedir als fitxers
    
    
//    BOOL dataNeedsReload ;
//    BOOL viewAppeared ;
    
}


//@property (nonatomic, retain) ControlViewCell *manageAccountsCell ;

//@property (nonatomic, retain) ManagedTextFieldCell *host1PortViewCell ;
//@property (nonatomic, retain) ManagedTextFieldCell *host1AddrViewCell ;

//@property (nonatomic, retain) ManagedTextFieldCell *host2PortViewCell ;
//@property (nonatomic, retain) ManagedTextFieldCell *host2NameViewCell ;
//@property (nonatomic, retain) SwitchViewCell *host2EnableSSLCell ;


//@property (nonatomic, retain) ControlViewCell *manageFilesCell ;


//@property (nonatomic, retain) ManagedTextFieldCell *plcValidationCodeCell ;

//@property (nonatomic, retain) LoginWindowControllerC *loginWindow ;


@end


