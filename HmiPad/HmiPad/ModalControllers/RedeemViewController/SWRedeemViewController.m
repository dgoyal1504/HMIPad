//
//  SWUploadViewController.m
//  HmiPad
//
//  Created by Joan on 18/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWRedeemViewController.h"

#import "AppModelFilesEx.h"
#import "AppModelActivationCodes.h"
#import "AppModelSource.h"

#import "AppUsersModel.h"

#import "SWRedeemCodeCell.h"
#import "SWRedeemNoCodeCell.h"
#import "SWRedeemProgressCell.h"
#import "SWRedeemRemoteProjectCell.h"

#import "SWBlockAlertView.h"

//#import "ColoredButton.h"
#import "SWColor.h"



static NSString * const SWRedeemNoCodeCellIdentifier = @"SWRedeemNoCodeCellIdentifier";
static NSString * const SWRedeemCodeCellIdentifier = @"SWRedeemCodeCellIdentifier";
static NSString * const SWRedeemProgressCellIdentifier = @"SWRedeemProgressCellIdentifier";
static NSString * const SWRedeemRemoteProjectCellIdentifier = @"SWRedeemRemoteProjectCellIdentifier";

NSString *SWRedeemViewControllerWillOpenProjectNotification = @"SWRedeemViewControllerWillOpenProjectNotification";


@interface SWRedeemViewController ()<AppFilesModelObserver, UIAlertViewDelegate>
{
    SWRedeemNoCodeCell *_activationNoCodeCell;
    SWRedeemCodeCell *_activationCodeCell;
    SWRedeemProgressCell *_progressCell;
    SWRedeemRemoteProjectCell *_remoteProjectCell;
    
    FileMD *_activationCodeMD;
    FileMD *_currentProjectMD;
    //SWUploadUploadButtonCell *_uploadButtonCell;
    NSTimer *_statusTimer;
    BOOL _isDownloading;
    BOOL _isActivationCodePresented;
    BOOL _isRemoteProjectPresented;
    BOOL _didFirstHit;
    BOOL _activityShowing;
    //BOOL _areProductsPresented;
    //BOOL _arePaymentsDisabled;
    //BOOL _areActivationsPresented;
    //NSArray *_activationCodes;
    //NSArray *_products;
    //SKProduct *_tappedProduct;
}

@end


// sections
enum
{
    SectionProgress,
    SectionRemoteProject,
    SectionRedeemCode,
    SectionRedeemNoCode,
    SectionsTotalSections,
};


// Section No Activation Code
enum
{
    RowRedeemNoCodeCell = 0,
    SectionRedeemNoCodeTotalRows,
};



// Section Activation Code
enum
{
    RowRedeemCodeCell = 0,
    SectionRedeemCodeTotalRows,
};


// Section Progress
enum
{
    RowProgressCell = 0,
    SectionProgressTotalRows,
};


// Section Upload Button
enum
{
    RowUploadButtonCell = 0,
    SectionUploadTotalRows,
};

// Section RemoteProject
enum
{
    RowRemoteProjectCell = 0,
    SectionRemoteProjectTotalRows,
};

enum
{
    AlertViewRedeemCode = 0,
    AlertViewOther
};

@implementation SWRedeemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (SWRedeemNoCodeCell *)activationNoCodeCell
{
    if ( _activationNoCodeCell == nil )
    {
        _activationNoCodeCell = [self.tableView dequeueReusableCellWithIdentifier:SWRedeemNoCodeCellIdentifier];
    }
    return _activationNoCodeCell;
}




- (SWRedeemCodeCell *)activationCodeCell
{
    if ( _activationCodeCell == nil )
    {
        _activationCodeCell = [self.tableView dequeueReusableCellWithIdentifier:SWRedeemCodeCellIdentifier];
    }
    return _activationCodeCell;
}


- (SWRedeemProgressCell *)progressCell
{
    if ( _progressCell == nil )
    {
        _progressCell = [self.tableView dequeueReusableCellWithIdentifier:SWRedeemProgressCellIdentifier];
    }
    return _progressCell;
}

- (SWRedeemRemoteProjectCell *)remoteProjectCell
{
    if ( _remoteProjectCell == nil )
    {
        _remoteProjectCell = [self.tableView dequeueReusableCellWithIdentifier:SWRedeemRemoteProjectCellIdentifier];
    
    }
    return _remoteProjectCell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xWhiteShadow.png"]
//                    style:UIBarButtonItemStyleBordered
//                    target:self
//                    action:@selector(_dismissController:)];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop                    target:self
        action:@selector(_dismissController:)];
    
    
    [[self navigationItem] setLeftBarButtonItem:closeItem];
    
    NSString *title;
    NSString *message;
    if ( _projectCode )
    {
        title = NSLocalizedString(@"Project Update", nil);
        message = NSLocalizedString(@"RedeemViewControllerProjectMessage", nil);
    }
    else
    {
        title = NSLocalizedString(@"Activation Code Redemption", nil);
        message = NSLocalizedString(@"RedeemViewControllerMessage", nil);
    }
    
    [_labelHeader setText:message];
    [_labelTitle setText:title];
    
    [[self navigationItem] setTitle:title];
    
    [self progressCell];
    [_progressCell.labelProgress setText:title];
    
    [self activationNoCodeCell];
    NSString *user = [usersModel() currentUserName];
    [_activationNoCodeCell.labelUser setText:user];
    
    UIButton *button = _activationNoCodeCell.buttonRedeem;
//    if ( [button respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
//        [button setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
    [button addTarget:self action:@selector(redeemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}




- (void)_performEnterCodeAlert
{
    NSString *title = NSLocalizedString(@"RedeemCodeAlertTitle", nil);
    NSString *placeholder = NSLocalizedString(@"Activation Code", nil);
    NSString *message = NSLocalizedString(@"RedeemCodeAlertMessage", nil);
    SWBlockAlertView *alertView = [[SWBlockAlertView alloc] initWithTitle:title
        message:message
        delegate:nil
        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
        otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.font = [UIFont systemFontOfSize:17];
    textField.textColor = UIColorWithRgb(TextDefaultColor);
    textField.placeholder = placeholder;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.minimumFontSize = 11;

    [alertView setResultBlock:^(BOOL success, NSInteger index)
    {
        if ( success )
        {
            _activationCode = textField.text;
            [self _beginLoadRemoteActivationCode];
        }
        [self _establishDownloading:_isDownloading animated:YES];
        [self _establishActivationNoCodeCell];
    }];
    
    [alertView show];
}


- (void)_performOpenProjectAlert
{
    NSString *projectName = _currentProjectMD.fileName;
    NSString *title = NSLocalizedString(@"OpenRedeemedProjectTitle", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"OpenRedeemedProjectMessage", nil), projectName];
    SWBlockAlertView *alertView = [[SWBlockAlertView alloc] initWithTitle:title
        message:message
        delegate:nil
        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
        otherButtonTitles:NSLocalizedString(@"Open",nil), nil];

    [alertView setResultBlock:^(BOOL success, NSInteger index)
    {
        if ( success )
        {
            [filesModel().fileSource setProjectSources:@[projectName]];
            [self _dismissController:nil];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:SWRedeemViewControllerWillOpenProjectNotification object:nil];
        }
        
        [self _establishDownloading:_isDownloading animated:YES];
        [self _establishActivationNoCodeCell];
    }];
    
    [alertView show];
}




- (void)_performButtonAction
{
    if ( _activationCode == nil && _projectCode == nil )
    {
//        // pregunta un codi d'activacio
//        NSString *title = NSLocalizedString(@"RedeemCodeAlertTitle", nil);
//        NSString *placeholder = NSLocalizedString(@"Activation Code", nil);
//        NSString *message = NSLocalizedString(@"RedeemCodeAlertMessage", nil);
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//            message:message
//            delegate:nil
//            cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
//            otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
//        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
//        [alertView setDelegate:self];
//        alertView.tag = AlertViewRedeemCode;
//    
//        UITextField *textField = [alertView textFieldAtIndex:0];
//        textField.font = [UIFont systemFontOfSize:17];
//        textField.textColor = UIColorWithRgb(TextDefaultColor);
//        textField.placeholder = placeholder;
//        textField.adjustsFontSizeToFitWidth = YES;
//        textField.minimumFontSize = 11;
//
//        [alertView show];
        
        
        [self _performEnterCodeAlert];
    }
    
    else if ( _activationCode )
    {
        if ( _isDownloading )
        {
            [filesModel().files cancelDownload];
        }
        else
        {
            if ( _isActivationCodePresented )
            {
                [self _beginActivationCodeRedeemption];
            }
            else
            {
                [self _beginLoadRemoteActivationCode];
            }
        }
    }
    
    else if ( _projectCode )
    {
        if ( _isDownloading )
        {
            [filesModel().files cancelDownload];
        }
        else
        {
            if ( _didFirstHit )
            {
                [self _beginUpdateProject];
            }
            _didFirstHit = YES;
        }
    }
}




- (void)viewWillAppear:(BOOL)animated
{
    BOOL downloading = [filesModel().files downloadingProject];
    [self _establishDownloading:downloading animated:animated];
    if ( !downloading )
    {
        [self _performButtonAction];
    }
    [self _establishActivationNoCodeCell];
    [filesModel().files addObserver:self];
}


- (void)_establishActivationNoCodeCell
{
    [self activationNoCodeCell];
    NSString *user = [usersModel() currentUserName];
    NSString *uuid = nil;
    
    if ( _activationCode  )
    {
        NSString *format = NSLocalizedString(@"%@ (Activation Code)", nil);
        uuid = [NSString stringWithFormat:format, _activationCode];
    }
    
    else if ( _projectCode )
    {
        NSString *format = NSLocalizedString(@"%@ (Project)", nil);
        uuid = [NSString stringWithFormat:format, _projectCode];
    }
    
    else
    {
        uuid = NSLocalizedString(@"<No Code>", nil);
    }

    [_activationNoCodeCell.labelUser setText:user];
    [_activationNoCodeCell.labelUUID setText:uuid];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [filesModel().files cancelDownload];
    [filesModel().amActivationCodes resetProductsMDArray];
    [filesModel().files removeObserver:self];
}






#pragma mark private

- (void)_dismissController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



//- (void)_reloadSectionsWithUpload:(BOOL)uploadChanged load:(BOOL)loadChanged
//{
//
//    UITableView *table = self.tableView;
//
//
//    if ( uploadChanged )
//    {
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:SectionProgress];
//        
//        if ( _isUploading )
//            [table insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
//        else
//            [table deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
//    }
//
//}


- (void)_establishActivityIndicator:(BOOL)putIt animated:(BOOL)animated
{
    if ( _activityShowing != putIt )
    {
        _activityShowing = putIt;
        UIBarButtonItem *btnItem = nil ;
        if ( putIt )
        {
            UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [activity startAnimating];
            btnItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
        }
        [[self navigationItem] setRightBarButtonItem:btnItem animated:YES];
    }
}


- (void)_establichButtonEnabled:(BOOL)enabled
{
    [_activationNoCodeCell.buttonRedeem setEnabled:enabled];
}

- (void)_establishDownloading:(BOOL)downloading animated:(BOOL)animated
{
//    BOOL downloading = [filesModel() downloadingProject];
    BOOL changed = downloading != _isDownloading;

    _isDownloading = downloading;
    
    //[self _establishActivityIndicator:_isDownloading animated:YES];

//    UIBarButtonItem *btnItem = nil ;
//    if ( _isDownloading )
//    {
//        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
//            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        [activity startAnimating];
//
//        btnItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
//    }
    
    if ( ! _isDownloading )
    {
       // NSLog( @"%@,%g", _progressView, _progressView.progress );
        [self progressCell];
        [_progressCell.progressView setProgress:0];
        [_progressCell.detailProgressView setProgress:0];
    }
    
    if ( changed )
    {
        UITableView *table = self.tableView;
        NSInteger section = [self _computeActualSection:SectionProgress];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
        UITableViewRowAnimation animationKind = (animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone);
        [table reloadSections:indexSet withRowAnimation:animationKind];
    }

    
   // [[self navigationItem] setRightBarButtonItem:btnItem animated:YES];
    NSString *buttonTitle = nil;
    
    if ( _isDownloading )
    {
        buttonTitle = NSLocalizedString(@"Cancel", nil);
    }
    else
    {
        if ( _activationCode )
        {
            buttonTitle = NSLocalizedString(@"Redeem Now", nil);
        }
        else if ( _projectCode )
        {
            buttonTitle = NSLocalizedString(@"Update Now", nil);
        }
        else
        {
            buttonTitle = NSLocalizedString(@"Enter Code", nil);
        }
    }
   
    [self activationCodeCell];
    [_activationNoCodeCell.buttonRedeem setTitle:buttonTitle forState:UIControlStateNormal];
}



#pragma mark - TableView private


// li pasem una seccio de la taula i ens torna la teorica
- (NSInteger)_computeSectionForComparing:(NSInteger)section
{
//    if ( !_isUploading && section >= SectionProgress )
//        section += 1;
//    
//    if ( !_isRemotePresented && section >= SectionRemoteProject )
//        section += 1;
    
    return section;
}

// li pasem una seccio teorica i ens torna la de la taula
- (NSInteger)_computeActualSection:(NSInteger)section
{
    NSInteger tableSection = section;
    
//    if ( !_isUploading && section > SectionProgress )
//        tableSection -= 1;
//    
//    if ( !_isRemotePresented && section > SectionRemoteProject )
//        tableSection -= 1;

    return tableSection;
}


#pragma mark TableView dataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = [self _computeActualSection:SectionsTotalSections];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalRows = 0;
    
    NSInteger compareSection = [self _computeSectionForComparing:section];
    switch ( compareSection )
    {
        case SectionRedeemNoCode:
            totalRows = SectionRedeemNoCodeTotalRows;
            break;
    
        case SectionRedeemCode:
            if ( _isActivationCodePresented )
                totalRows = SectionRedeemCodeTotalRows;
            break;
            
        case SectionProgress:
            if ( _isDownloading )
                totalRows = SectionProgressTotalRows;
            break;
                
        case SectionRemoteProject:
            if ( _isRemoteProjectPresented )
                totalRows = SectionRemoteProjectTotalRows;
            break;
    }
    
    return totalRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    NSString *identifier = CellIdentifier;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = nil;
    
    NSInteger compareSection = [self _computeSectionForComparing:section];
    
    switch ( compareSection )
    {
        case SectionRedeemNoCode:
            if ( row == RowRedeemNoCodeCell) cell = [self activationNoCodeCell];
            break;
    
        case SectionRedeemCode:
            if ( row == RowRedeemCodeCell ) cell = [self activationCodeCell];
            break;
            
        case SectionProgress:
            if ( row == RowProgressCell ) cell = [self progressCell];
            break;
            
        case SectionRemoteProject:
            if ( row == RowRemoteProjectCell ) cell = [self remoteProjectCell];
            break;
    }
    
    if ( cell )
        return cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSInteger compareSection = [self _computeSectionForComparing:section];
    
    switch ( compareSection )
    {
        case SectionRedeemNoCode:
            if ( row == RowRedeemNoCodeCell ) height = 90;
            break;
    
        case SectionRedeemCode:
            if ( row == RowRedeemCodeCell ) height = 104;
            break;
        
        case SectionProgress:
            if ( row == RowProgressCell ) height = 100;
            break;
    
        case SectionRemoteProject:
            if ( row == RowRemoteProjectCell ) height = 104;
            break;
    }

    return height;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if ( IS_IOS7 )
    {
        NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];
        if ( numberOfRows > 0 )
        {
            NSInteger compareSection = [self _computeSectionForComparing:section];
            
            switch ( compareSection )
            {
                case SectionRedeemNoCode:
                    if ( _activationCode ) title = NSLocalizedString(@"ACTIVATION CODE", nil);
                    else if ( _projectCode )title = NSLocalizedString(@"CURRENT PROJECT", nil);
                    else title = NSLocalizedString(@"ACTIVATION CODE", nil);
                    break;
    
                case SectionRedeemCode:
                    title = NSLocalizedString(@"INTEGRATORS SERVICE", nil);
                    break;
        
                case SectionProgress:
                    title = NSLocalizedString(@"DOWNLOAD PROGRESS", nil);
                    break;
    
                case SectionRemoteProject:
                    title = NSLocalizedString(@"REMOTE PROJECT", nil);
                    break;
            }
        }
    }
    return title;
}

#pragma mark button action

- (void)redeemButtonAction:(id)sender
{
    [self _performButtonAction];
}


//#pragma mark TextFieldDelegate (Redeem)
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    NSLog( @"textFieldShouldBeginEditing");
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    NSLog( @"textFieldShouldEndEditing");
//    return YES;
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    NSLog( @"textFieldDidEndEditing");
//}


#pragma mark AlertViewDelegate (Redeem)

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex];
//    NSInteger cancelButtonIndex = [alertView cancelButtonIndex];
//    
//    
//    switch (alertView.tag)
//    {
//        case AlertViewRedeemCode:
//        {
//            if (buttonIndex == cancelButtonIndex)  // cancel
//            {
//                // Nothing to do
//            }
//            else if (buttonIndex == firstOtherButtonIndex) // OK
//            {
//                UITextField *textField = [alertView textFieldAtIndex:0];
//                _activationCode = textField.text;
//                [self _beginLoadRemoteActivationCode];
//            }
//            break;
//        }
//        default:
//        {
//            break;
//        }
//    }
//    
//    [self _establishDownloading:_isDownloading animated:YES];
//    [self _establishActivationNoCodeCell];
//}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    UITextField *textField = [alertView textFieldAtIndex:0];
//    [textField resignFirstResponder];
//}



#pragma mark AppFilesModelObserver (Redeem)

- (void)_beginActivationCodeRedeemption
{
    [self _establishActivityIndicator:YES animated:YES];
    [self _establichButtonEnabled:NO];
    
    [_activationNoCodeCell.buttonRedeem setEnabled:NO];
    
//    if ( [SKProduct isQProduct:_activationCodeMD.productSKU] )
//        [filesModel() redeemLocalActivationCode:_activationCodeMD];
//    
//    else

        [filesModel().files redeemActivationCodeMD:_activationCodeMD];
} 



- (void)appFilesModel:(AppModelFilesEx *)filesModel didRedemCode:(NSString *)code withError:(NSError *)error
{
    if ( error )
    {
        [self _establishDownloadStatusFinished:NO canceled:NO error:error];
        [self _establishActivityIndicator:NO animated:YES];
        [self _establichButtonEnabled:YES];
    }
    else
    {
        [filesModel refreshMDArrayForCategory:kFileCategoryRemoteRedemption];
    }
}


#pragma mark AppFilesModelObserver (Update Project)

- (void)_beginUpdateProject
{
    [self _establishActivityIndicator:YES animated:YES];
    [self _establichButtonEnabled:NO];
    
    [filesModel().files updateRedeemedProjectWithProjectID:_projectCode /*ownerID:_projectOwner*/];
}


#pragma mark AppsFileModelObserver (Download)

- (void)appFilesModel:(AppModelFilesEx *)filesModel beginGroupDownloadForCategory:(FileCategory)category
{
    [self _establishActivityIndicator:YES animated:YES];
    [self _establichButtonEnabled:YES];
    [self _establishDownloading:YES animated:YES];
    [self _resetStatus];
    //[self _resetRemote];
    //[self _resetProducts];
    //[self _resetActivationCodes];
    
    // aqui treure el remote
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel willDownloadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    //NSLog( @"Will download %@", fileName );

    NSString *text = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Downloading:",nil), fileName];
    [_progressCell.labelDetailProgress setText:text];
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel didDownloadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
    
    //NSLog( @"Did download %@", fileName );
    
    [_progressCell.labelDetailProgress setText:NSLocalizedString(@"Progress", nil)];
        
//    if ( NO )
//    {
//        if ( error )
//        {
//            NSString *title = NSLocalizedString(@"Integrators Service Upload", nil );
//            NSString *message = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil
//                otherButtonTitles:ok, nil];
//            [alert show];
//        }
//    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel groupDownloadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category;
{
    //float progressValue = (float)step/(float)stepCount;
    float progressValue = 0.1f + (float)step*(0.9f/(float)stepCount);
    [_progressCell.progressView setProgress:progressValue animated:YES];
    [_progressCell.detailProgressView setProgress:0.05f /*animated:NO*/];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel fileDownloadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
    //float progressValue = (float)bytesRead/(float)totalBytesExpected;
    float progressValue = 0.1f + (float)bytesRead*(0.9f/(float)totalBytesExpected);
    [_progressCell.detailProgressView setProgress:progressValue animated:YES];
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel endGroupDownloadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{
    [self _establishActivityIndicator:NO animated:YES];
    [self _establishDownloading:NO animated:YES];
    [self _establichButtonEnabled:YES];  // no caldria pero bueno
    [self _establishDownloadStatusFinished:finished canceled:canceled error:nil];
    
    if ( finished && !canceled && category == kFileCategoryRemoteGroupAssetFile )
    {
        [self _performOpenProjectAlert];
    }
}


#pragma mark ActivationCodeObserver


- (void)_reloadActivationCode
{
    UITableView *table = self.tableView;
    NSInteger section = [self _computeActualSection:SectionRedeemCode];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}


- (void)_beginLoadRemoteActivationCode
{
    [self _establishActivityIndicator:YES animated:YES];
    [self _establichButtonEnabled:NO];
    [filesModel().files getRemoteFileMDForFileWithUUID:_activationCode forCategory:kFileCategoryRemoteActivationCode];
}

- (void)_resetRemoteActivationCode
{
    if ( _isActivationCodePresented )
    {
        _isActivationCodePresented = NO;
        [self _reloadActivationCode];
    }
}




#pragma mark AppsFileModelObserver (remote project)


- (void)_reloadRemoteProject
{
    UITableView *table = self.tableView;
    NSInteger section = [self _computeActualSection:SectionRemoteProject];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    //[table deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}


//- (void)_beginLoadRemoteProjectMD
//{
//   // [filesModel() getRemoteFileMDForFileWithUUID:_proj forCategory:kFileCategoryRemoteSourceFile];
//}


- (void)_resetRemote 
{
    if ( _isRemoteProjectPresented )
    {
        _isRemoteProjectPresented = NO;
        [self _reloadRemoteProject];
    }
}

- (void)appFilesModel:(AppModelFilesEx *)filesModel didGetRemoteFileMD:(FileMD *)fileMD
    forCategory:(FileCategory)category withError:(NSError *)error
{
    //NSLog( @"remoteFileMD: %@", fileMD);
    
    //if ( category == kFileCategoryRedeemedSourceFile )
    if ( category == kFileCategorySourceFile )
    {
        _currentProjectMD = nil;
    
        BOOL shouldPresent = (error == nil && fileMD != nil );
        BOOL change = ( shouldPresent != _isRemoteProjectPresented );
        _isRemoteProjectPresented = (error==nil);
    
        if ( change )
        {
            [self _reloadRemoteProject];
        }
    
        if ( _isRemoteProjectPresented )
        {
            _currentProjectMD = fileMD;
            [_remoteProjectCell.labelName setText:fileMD.fileName];
            [_remoteProjectCell.labelUUID setText:fileMD.identifier];
            [_remoteProjectCell.labelDate setText:fileMD.fileDateString];
            [_remoteProjectCell.labelSize setText:[fileMD fileSizeString]];
        }
    }
    
    else if ( category == kFileCategoryRemoteActivationCode )
    {
        _activationCodeMD = nil;
    
        BOOL shouldPresent = (error == nil && fileMD != nil );
        BOOL change = (shouldPresent != _isActivationCodePresented ) ;
        _isActivationCodePresented = (error==nil);
    
        if ( change )
        {
            [self _reloadActivationCode];
        }
        
        if ( _isActivationCodePresented )
        {
            _activationCodeMD = fileMD;
            [_activationCodeCell.labelName setText:fileMD.fileName];
            [_activationCodeCell.labelUUID setText:fileMD.accessCode];
            //[_activationCodeCell setText:fileMD.updated];
            [_activationCodeCell.labelDate setText:fileMD.fileDateString];
            [_activationCodeCell.labelSize setText:[fileMD fileSizeString]];
            [_activationCodeCell.labelProjectID setText:fileMD.project];
        }
        [self _establishActivityIndicator:NO animated:YES];
        [self _establichButtonEnabled:YES];
        
        if ( _isActivationCodePresented )  // cucut
            [self _performButtonAction];
    }
    
    if ( error )
    {
        [self _establishActivityIndicator:NO animated:YES];
        [self _establichButtonEnabled:YES];
        [self _establishDownloadStatusFinished:NO canceled:NO error:error];
    }
}


#pragma mark status timer

- (void)_resetStatus
{
    [UIView animateWithDuration:0.3 animations:^
    {
         [_activationNoCodeCell.labelStatus setAlpha:0.0f];
//         [_uploadButtonCell.labelStatus setAlpha:0.0f];
    }];
    
    [_statusTimer invalidate];
    _statusTimer = nil;
}

- (void)_establishDownloadStatusFinished:(BOOL)finished canceled:(BOOL)canceled error:(NSError*)error
{
    NSString *text = nil;
    if ( canceled )
        text = NSLocalizedString(@"Redemption Canceled by User", nil);
    
    else if ( finished )
        text = NSLocalizedString(@"Redemption Completed", nil);
    
    else
    {
        text = NSLocalizedString(@"Redemption Error", nil);
        if ( error ) text = [text stringByAppendingFormat:@": %@", error.localizedDescription];
    }
    
    UIColor *color = nil;
    if ( canceled || finished ) color = UIColorWithRgb(TheNiceGreenColor);
    else color = [UIColor redColor];
    
//    [_uploadButtonCell.labelStatus setText:text];
//    [_uploadButtonCell.labelStatus setAlpha:1.0f];
    UILabel *labelStatus = _activationNoCodeCell.labelStatus;
    [labelStatus setTextColor:color];
    [labelStatus setText:text];
    [labelStatus setAlpha:1.0f];
    _statusTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
        target:self selector:@selector(_resetStatus) userInfo:nil repeats:NO];
}


@end
