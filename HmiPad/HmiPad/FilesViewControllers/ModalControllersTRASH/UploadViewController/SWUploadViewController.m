//
//  SWUploadViewController.m
//  HmiPad
//
//  Created by Joan on 18/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWUploadViewController.h"
#import "SWUploadProgressCell.h"
//#import "SWUploadUploadButtonCell.h"
#import "SWUploadCurrentProjectCell.h"
#import "SWUploadRemoteProjectCell.h"
#import "SWUploadActivationCodeCell.h"
#import "SWUploadBuyProductButtonCell.h"
#import "UIViewController+SWSendMailControllerPresenter.h"
//#import "SendMailController.h"


#import "ColoredButton.h"
#import "AppFilesModel.h"
#import "AppUsersModel.h"
#import "UserDefaults.h"
#import "SWColor.h"



static NSString * const SWUploadProgressCellIdentifier = @"SWUploadProgressCellIdentifier";
static NSString * const SWUploadUploadButtonCellIdentifier = @"SWUploadUploadButtonCellIdentifier";
static NSString * const SWUploadCurrentProjectCellIdentifier = @"SWUploadCurrentProjectCellIdentifier";
static NSString * const SWUploadRemoteProjectCellIdentifier = @"SWUploadRemoteProjectCellIdentifier";
static NSString * const SWUploadActivationCodesCellIdentifier = @"SWUploadActivationCodesCellIdentifier";
static NSString * const SWUploadBuyProductsButtonCellIdentifier = @"SWUploadBuyProductsButtonCellIdentifier";


@interface SWUploadViewController ()<AppFilesModelObserver,SWUploadBuyProductButtonCellDelegate,
    SWUploadActivationCodeCellDelegate, UIAlertViewDelegate>
{
    SWUploadCurrentProjectCell *_projectCell;
    SWUploadRemoteProjectCell *_remoteProjectCell;
    SWUploadProgressCell *_progressCell;
    FileMD *_currentProjectMD;  // l'agafem en el viewDidLoad i es valid per la vida de la clase
    //SWUploadUploadButtonCell *_uploadButtonCell;
    NSTimer *_statusTimer;
    BOOL _isUploading;
    BOOL _isRemotePresented;
    BOOL _areProductsPresented;
    BOOL _arePaymentsDisabled;
    BOOL _areActivationsPresented;
    NSArray *_activationCodes;
    NSArray *_products;
    //SKProduct *_tappedProduct;
}

@end


// sections
enum
{
    SectionCurrentProject = 0,
    //SectionUploadButton,
    SectionProgress,
    SectionRemoteProject,
    SectionProducts,
    SectionActivationCodes,
    SectionsTotalSections,
};


// Section Project
enum
{
    RowProjectCell = 0,
    SectionProjectTotalRows,
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
    AlertViewActivationName = 0,
    AlertViewOther
};

@implementation SWUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (SWUploadProgressCell *)progressCell
{
    if ( _progressCell == nil )
    {
        _progressCell = [self.tableView dequeueReusableCellWithIdentifier:SWUploadProgressCellIdentifier];
    
    }
    return _progressCell;
}


//- (SWUploadUploadButtonCell *)uploadButtonCell
//{
//    if ( _uploadButtonCell == nil )
//    {
//        _uploadButtonCell = [self.tableView dequeueReusableCellWithIdentifier:SWUploadUploadButtonCellIdentifier];
//    
//    }
//    return _uploadButtonCell;
//}


- (SWUploadCurrentProjectCell *)projectCell
{
    if ( _projectCell == nil )
    {
        _projectCell = [self.tableView dequeueReusableCellWithIdentifier:SWUploadCurrentProjectCellIdentifier];
    
    }
    return _projectCell;
}


- (SWUploadRemoteProjectCell *)remoteProjectCell
{
    if ( _remoteProjectCell == nil )
    {
        _remoteProjectCell = [self.tableView dequeueReusableCellWithIdentifier:SWUploadRemoteProjectCellIdentifier];
    
    }
    return _remoteProjectCell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xWhiteShadow.png"]
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(_dismissController:)];
    [[self navigationItem] setLeftBarButtonItem:closeItem];
    
    [_labelHeader setText:NSLocalizedString(@"UploadViewControllerMessage", nil)];
    
    
    _currentProjectMD = [filesModel() currentDocumentFileMD];
    
    NSString *title = _currentProjectMD.fileName;
    
    [[self navigationItem] setTitle:title];
    
    [self progressCell];
    [_progressCell.labelProgress setText:title];
    
    [self projectCell];
    [_projectCell.labelName setText:title];
    [_projectCell.labelUUID setText:_currentProjectMD.identifier];
    NSString *owner = [usersModel() currentUserName];
    [_projectCell.labelOwner setText:owner];
    [_projectCell.labelDate setText:[_currentProjectMD fileDateString]];
    [_projectCell.labelSize setText:[_currentProjectMD fileSizeString]];
    
    [_projectCell.buttonUpload setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
    [_projectCell.buttonUpload addTarget:self action:@selector(uploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self uploadButtonCell];
//    [_uploadButtonCell.buttonUpload setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
//    [_uploadButtonCell.buttonUpload addTarget:self action:@selector(uploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //_numProducts = 2;
    //_numActivationCodes = 3;
}






- (void)viewWillAppear:(BOOL)animated
{    
    [self _beginLoadRemoteProjectMD];
    [self _establishUploadingAnimated:animated];
    
    [filesModel() addObserver:self];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [filesModel() removeObserver:self];
}






#pragma mark private

- (void)_dismissController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES] ;
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



- (void)_establishUploadingAnimated:(BOOL)animated
{
    BOOL uploading = [filesModel() updatingProject];
    BOOL changed = uploading != _isUploading;

    _isUploading = uploading;

    UIBarButtonItem *btnItem = nil ;
    if ( _isUploading )
    {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity startAnimating];

        btnItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    }
    
    else
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
//        if ( _isUploading )
//            [table insertSections:indexSet withRowAnimation:animationKind];
//        else
//            [table deleteSections:indexSet withRowAnimation:animationKind];
        
        [table reloadSections:indexSet withRowAnimation:animationKind];
    }

    
    [[self navigationItem] setRightBarButtonItem:btnItem animated:YES];
    NSString *buttonTitle = nil;
    if ( _isUploading ) buttonTitle = NSLocalizedString(@"CANCEL UPLOAD", nil);
    else buttonTitle = NSLocalizedString(@"UPLOAD PROJECT", nil);
//    [self uploadButtonCell];
//    [_uploadButtonCell.buttonUpload setTitle:buttonTitle forState:UIControlStateNormal];
    
    [self projectCell];
    [_projectCell.buttonUpload setTitle:buttonTitle forState:UIControlStateNormal];
}



#pragma mark TableView dataSource


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



- (NSArray*)_products
{
    if ( _products == nil )
    {
        NSArray *allProducts = [filesModel() productsMDArray];
        if ( allProducts.count > 0 )
        {
            _products = allProducts;
        }
    }

    return _products;
}





- (NSArray*)_activationCodes
{
    if ( _activationCodes == nil )
    {
        NSArray *allActivationCodes = [filesModel() filesMDArrayForCategory:kFileCategoryRemoteActivationCode];
        if ( allActivationCodes.count > 0 )
        {
            NSMutableArray *activationCodes = [NSMutableArray array];
            for ( FileMD *activationCode in allActivationCodes )
            {
                NSArray *projects = activationCode.projects;
                NSString *projectID = projects.lastObject;
#warning provisional, a treure
                projectID = _currentProjectMD.identifier;     // PROVISIONAL, A TREURE
                
                if ( [projectID isEqualToString:_currentProjectMD.identifier] )
                {
                    [activationCodes addObject:activationCode];
                }
            }
            _activationCodes = activationCodes;
        }
    }
    return _activationCodes;
}


//- (FileMD*)_activationCodeMDAtIndex:(int)indx
//{
//    return [[self _activationCodes] objectAtIndex:indx];
//}


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
        case SectionCurrentProject:
            totalRows = SectionProjectTotalRows;
            break;
            
        case SectionProgress:
            if ( _isUploading )
                totalRows = SectionProgressTotalRows;
            break;
    
//        case SectionUploadButton:
//           totalRows = SectionUploadTotalRows;
//            break;
            
        case SectionRemoteProject:
            if ( _isRemotePresented )
                totalRows = SectionRemoteProjectTotalRows;
            break;
            
        case SectionActivationCodes:
            if ( _areActivationsPresented )
                totalRows = [[self _activationCodes] count]; // _numActivationCodes;
            break;
            
        case SectionProducts:
            if ( _areProductsPresented )
            {
                if ( _arePaymentsDisabled)
                    totalRows = 1;
                else
                    totalRows = [[self _products] count];
            }
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
        case SectionCurrentProject:
            if ( row == RowProjectCell ) cell = [self projectCell];
            break;
            
        case SectionProgress:
            if ( row == RowProgressCell ) cell = [self progressCell];
            break;
    
//        case SectionUploadButton:
//            if ( row == RowUploadButtonCell ) cell = [self uploadButtonCell];
//            break;
            
        case SectionRemoteProject:
            if ( row == RowRemoteProjectCell ) cell = [self remoteProjectCell];
            break;
            
        case SectionActivationCodes:
            identifier = SWUploadActivationCodesCellIdentifier;
            break;
            
        case SectionProducts:
            identifier = SWUploadBuyProductsButtonCellIdentifier;
            break;
            
    }
    
    if ( cell )
        return cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
    
    if ( identifier == SWUploadBuyProductsButtonCellIdentifier )
    {
        SWUploadBuyProductButtonCell *aCell = (id)cell;
        ColoredButton *buttonBuy = aCell.buttonBuy;   
        UILabel *labelProduct = aCell.labelProduct;
        if ( _arePaymentsDisabled )
        {
            [buttonBuy setRgbTintColor:TheNiceGreenColor overWhite:YES];
            [buttonBuy setEnabled:NO];
            [buttonBuy setRgbTintColor:TheNiceGreenColor overWhite:YES];
            NSString *title = NSLocalizedString(@"BUY (Disabled)", nil);
            NSString *text = NSLocalizedString(@"In App Purchases are disabled on the Settings App", nil);
            [buttonBuy setTitle:title forState:UIControlStateNormal];
            [labelProduct setText:text];
            //[labelProduct setTextColor:UIColorWithRgb(TangerineSelectionColor)];
            //[labelProduct setTextColor:[UIColor redColor]];
        }
        else
        {
            SKProduct *product = [[self _products] objectAtIndex:row];
            NSString *productId = product.productIdentifier;
            
            [buttonBuy setRgbTintColor:TheNiceGreenColor overWhite:YES];
            BOOL isWaitingReceipt = [filesModel() isProductWaitingReceipt:productId];
            BOOL isWaitingActivation = [filesModel() isProductWaitingActivation:productId];
            BOOL enabled = ! (isWaitingReceipt || isWaitingActivation);
            [buttonBuy setEnabled:enabled];
            
            NSString *title = nil;
            if ( enabled )
            {
                NSString *format = NSLocalizedString(@"BUY (%@)", nil);
                title = [NSString stringWithFormat:format, product.priceString];
            }
            else if ( isWaitingReceipt )
            {
                title = NSLocalizedString(@"PURCHASING...", nil);
            }
            else if ( isWaitingActivation )
            {
                title = NSLocalizedString(@"ACTIVATING...", nil);
            }
            
            [buttonBuy setTitle:title forState:UIControlStateNormal];
            [labelProduct setText:product.localizedDescription];

            aCell.skProduct = product;
            aCell.delegate = self;
        }
    }
    
    if ( identifier == SWUploadActivationCodesCellIdentifier )
    {
        SWUploadActivationCodeCell *aCell = (id)cell;
        FileMD *fileMD = [[self _activationCodes] objectAtIndex:row];
        [aCell.labelName setText:fileMD.fileName];
        [aCell.labelCode setText:fileMD.accessCode];
        [aCell.labelDate setText:fileMD.created];
        
        ColoredButton *buttonEmail = aCell.buttonEmail;
        [buttonEmail setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
        NSString *title = NSLocalizedString(@"SEND EMAIL", nil);
        [buttonEmail setTitle:title forState:UIControlStateNormal];
        
        NSString *totalsStringFmt = NSLocalizedString(@"%d Projects, %d Redemptions", nil);
        NSString *usedStringFmt = NSLocalizedString(@"%d Projects, %d Redemptions", nil);
        NSString *totalsString = [NSString stringWithFormat:totalsStringFmt, fileMD.maxProjects, fileMD.maxRedemptions];
        NSString *usedString = [NSString stringWithFormat:usedStringFmt, fileMD.projects.count, fileMD.redemptions.count];
        
        [aCell.labelTotal setText:totalsString];
        [aCell.labelUsed setText:usedString];
        aCell.fileMD = fileMD;
        aCell.delegate = self;
    }
    

    
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
        case SectionCurrentProject:
            if ( row == RowProjectCell ) height = 144;
            break;
        
        case SectionProgress:
            if ( row == RowProgressCell ) height = 122;
            break;
    
//        case SectionUploadButton:
//            if ( row == RowUploadButtonCell ) height = 44;
//            break;
            
        case SectionRemoteProject:
            if ( row == RowRemoteProjectCell ) height = 130;
            break;
            
        case SectionActivationCodes:
            height = 100;
            break;
            
        case SectionProducts:
            height = 48;
            break;
    }

    return height;
}


#pragma mark button action

- (void)uploadButtonAction:(id)sender
{
    NSInteger uploadStep = [filesModel() groupUploadStep];
    if ( uploadStep == 0 )
        [filesModel() uploadProject];
    else
        [filesModel() cancelUpload];
}


- (void)activationCodeCellDidTouchEmail:(SWUploadActivationCodeCell *)cell
{
    FileMD *fileMD = cell.fileMD;
    
    [self presentMailControllerForActivationCode:fileMD];
    
//    SendMailController *mailController = [[SendMailController alloc] init];
//    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
//    
//    [mailController setSubject:NSLocalizedString(@"ActivationCodeMailMessageSubject",nil)];
//
//    // Set up recipients
//    NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
//    [mailController setToRecipients:toRecipients];
//    
//    NSMutableString *emailBodyFormat = [NSMutableString stringWithString:NSLocalizedString(@"ActivationCodeBodyFormat%@%@%d", nil)];
//    
//    NSString *accessCode = fileMD.accessCode;
//    NSString *emailBody = [NSString stringWithFormat:emailBodyFormat, accessCode, fileMD.created, fileMD.maxRedemptions ];
//    [mailController setMessageBody:emailBody isHTML:NO];
//    
//    NSString *fileName = @"AccessCode.hmipadcode";
//    NSData *myData = [accessCode dataUsingEncoding:NSASCIIStringEncoding];
//    [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:fileName];
//    
//    
//    [self presentModalViewController:mailController animated:YES];
////    [self presentViewController:mailController animated:YES completion:nil];
//   // [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)buyProductCellDidTouchBuy:(SWUploadBuyProductButtonCell *)cell
{
    [filesModel() addPaymentForProduct:cell.skProduct];
    [self _reloadProductsSectionAnimated:NO];
    
//    _tappedProduct = cell.skProduct;
//    NSString *title = NSLocalizedString(@"ActivationCodeAlertTitle", nil);
//    NSString *message = NSLocalizedString(@"ActivationCodeAlertMessage", nil);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//        message:message
//        delegate:nil
//        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
//        otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
//    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [alertView setDelegate:self];
//    
//
//    NSString *name = [defaults() activationCodeName];
//    UITextField *textField = [alertView textFieldAtIndex:0];
//    textField.font = [UIFont systemFontOfSize:17];
//    textField.textColor = UIColorWithRgb(TextDefaultColor);
//    textField.text = name;
//
//    [alertView show];
    
}




//#pragma mark AlertViewDelegate (Upload)
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex];
//    NSInteger cancelButtonIndex = [alertView cancelButtonIndex];
//    
//    switch (alertView.tag)
//    {
//        case AlertViewActivationName:
//        {
//            if (buttonIndex == cancelButtonIndex)  // cancel
//            {
//                // Nothing to do
//            }
//            else if (buttonIndex == firstOtherButtonIndex) // OK
//            {
//                UITextField *textField = [alertView textFieldAtIndex:0];
//                [defaults() setActivationCodeName:textField.text];
//            
//                [filesModel() addPaymentForProduct:_tappedProduct];
//                [self _reloadProductsSectionAnimated:NO];
//            }
//            break;
//        }
//        default:
//        {
//            break;
//        }
//        
//        _tappedProduct = nil;
//    }
//}







#pragma mark AppsFileModelObserver (Upload)

- (void)appFilesModel:(AppFilesModel *)filesModel beginGroupUploadForCategory:(FileCategory)category
{
    [self _establishUploadingAnimated:YES];
    [self _resetStatus];
    [self _resetRemote];
    [self _resetProducts];
    [self _resetActivationCodes];
    
    // aqui treure el remote
}


- (void)appFilesModel:(AppFilesModel*)filesModel willUploadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    NSLog( @"Will upload %@", fileName );

    NSString *text = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Uploading:",nil), fileName];
    [_progressCell.labelDetailProgress setText:text];
}


- (void)appFilesModel:(AppFilesModel*)filesModel didUploadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
    
    NSLog( @"Did upload %@", fileName );
    
    [_progressCell.labelDetailProgress setText:NSLocalizedString(@"Progress", nil)];
        
    if ( NO )
    {
        if ( error )
        {
            NSString *title = NSLocalizedString(@"Integrators Service Upload", nil );
            NSString *message = [error localizedDescription];
            NSString *ok = NSLocalizedString( @"Ok", nil );
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil
                otherButtonTitles:ok, nil];
            [alert show];
        }
    }
}


- (void)appFilesModel:(AppFilesModel*)filesModel groupUploadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category;
{
    float progressValue = (float)step/(float)stepCount;
    [_progressCell.progressView setProgress:progressValue animated:YES];
    [_progressCell.detailProgressView setProgress:0.05f animated:NO];
}


- (void)appFilesModel:(AppFilesModel *)filesModel fileUploadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
    float progressValue = (float)bytesRead/(float)totalBytesExpected;
    [_progressCell.detailProgressView setProgress:progressValue animated:YES];
}


- (void)appFilesModel:(AppFilesModel*)filesModel endGroupUploadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{
    [self _establishUploadingAnimated:YES];
    [self _establishUploadStatusFinished:finished canceled:canceled];
    [self _beginLoadRemoteProjectMD];
}


#pragma mark AppsFileModelObserver (Products)


- (void)_reloadProductsSectionAnimated:(BOOL)animated
{
    UITableView *table = self.tableView;
    NSInteger section = [self _computeActualSection:SectionProducts];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    //[table deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    UITableViewRowAnimation animation = animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone;
    [table reloadSections:indexSet withRowAnimation:animation];
}


- (void)_beginPresentingProducts
{
    _areProductsPresented = YES;
    [self _reloadProductsSectionAnimated:YES];
}


- (void)_resetProducts
{
    if ( _areProductsPresented )
    {
        _areProductsPresented = NO;
        _products = nil;
        [filesModel() refreshProductsMDArray];
        [self _reloadProductsSectionAnimated:YES];
    }
}

- (void)appFilesModel:(AppFilesModel *)filesModel didGetProductsListingAndCanMakePayments:(BOOL)yesWeCan
{
    _arePaymentsDisabled = !yesWeCan;
    [self _reloadProductsSectionAnimated:YES];
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


- (void)_beginLoadRemoteProjectMD
{
    //FileMD *documentMD = [filesModel() currentDocumentFileMD];
    [filesModel() getRemoteFileMDForFileWithUUID:_currentProjectMD.identifier forCategory:kFileCategoryRemoteSourceFile];
}


- (void)_resetRemote 
{
    if ( _isRemotePresented )
    {
        _isRemotePresented = NO;
        [self _reloadRemoteProject];
    }
}

- (void)appFilesModel:(AppFilesModel *)filesModel didGetRemoteFileMD:(FileMD *)fileMD
    forCategory:(FileCategory)category withError:(NSError *)error
{
    NSLog( @"remoteFileMD: %@", fileMD);
    
    BOOL change = ( (error==nil) != _isRemotePresented ) ;
    _isRemotePresented = (error==nil);
    
    if ( change )
    {
        [self _reloadRemoteProject];
    }
    
    if ( _isRemotePresented )
    {
        [_remoteProjectCell.labelName setText:fileMD.fileName];
        [_remoteProjectCell.labelUUID setText:fileMD.identifier];
        [_remoteProjectCell.labelDate setText:fileMD.updated];
        [_remoteProjectCell.labelSize setText:[fileMD fileSizeString]];
        
        [self _beginPresentingProducts];
        [self _beginPresentingActivationCodes];
    }
}


#pragma mark AppsFileModelObserver (activation codes)


- (void)_reloadActivationCodes
{
    UITableView *table = self.tableView;
    NSInteger section = [self _computeActualSection:SectionActivationCodes];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}


- (void)_beginPresentingActivationCodes
{    
    _areActivationsPresented = YES;
    _activationCodes = nil;
    [self _reloadActivationCodes];
}


- (void)_resetActivationCodes
{
    if ( _areActivationsPresented )
    {
        _areActivationsPresented = NO;
        _activationCodes = nil;
        [self _reloadActivationCodes];
    }
}


- (void)appFilesModel:(AppFilesModel *)filesModel willChangeRemoteListingForCategory:(FileCategory)category
{
    if ( category != kFileCategoryRemoteActivationCode )
        return;
}


- (void)appFilesModel:(AppFilesModel *)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError *)error
{
    if ( category != kFileCategoryRemoteActivationCode )
        return;
    
    [self _beginPresentingActivationCodes];
}



#pragma mark AppsFileModelObserver (transaccions)


- (void)appFilesModel:(AppFilesModel *)filesModel didFinishTransactionWithSuccess:(BOOL)success
{
    [self _reloadProductsSectionAnimated:NO];
}

- (void)appFilesModel:(AppFilesModel *)filesModel didProvideContentWithSuccess:(BOOL)success
{
//    [defaults() setActivationCodeName:@""];
    [self _reloadProductsSectionAnimated:NO];
}

#pragma mark status timer

- (void)_resetStatus
{
    [UIView animateWithDuration:0.3 animations:^
    {
         [_projectCell.labelStatus setAlpha:0.0f];
//         [_uploadButtonCell.labelStatus setAlpha:0.0f];
    }];
    
    [_statusTimer invalidate];
    _statusTimer = nil;
}

- (void)_establishUploadStatusFinished:(BOOL)finished canceled:(BOOL)canceled
{
    NSString *text = nil;
    if ( canceled ) text = NSLocalizedString(@"Upload Canceled by User", nil);
    else if ( finished ) text = NSLocalizedString(@"Upload Completed", nil);
    else text = NSLocalizedString(@"Upload Error", nil);
    
    UIColor *color = nil;
    if ( canceled || finished ) color = UIColorWithRgb(TheNiceGreenColor);
    else color = [UIColor redColor];
    
//    [_uploadButtonCell.labelStatus setText:text];
//    [_uploadButtonCell.labelStatus setAlpha:1.0f];
    UILabel *labelStatus = _projectCell.labelStatus;
    [labelStatus setTextColor:color];
    [labelStatus setText:text];
    [labelStatus setAlpha:1.0f];
    _statusTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
        target:self selector:@selector(_resetStatus) userInfo:nil repeats:NO];
}


@end
