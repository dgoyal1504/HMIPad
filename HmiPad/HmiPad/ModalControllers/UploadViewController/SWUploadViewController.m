//
//  SWUploadViewController.m
//  HmiPad
//
//  Created by Joan on 18/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWUploadViewController.h"

#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"
#import "AppModelDocument.h"
#import "AppModelActivationCodes.h"

#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"
#import "UserDefaults.h"

#import "SWUploadProgressCell.h"
#import "SWUploadCurrentProjectCell.h"
#import "SWUploadRemoteProjectCell.h"
#import "SWUploadActivationCodeCell.h"
#import "SWUploadBuyProductButtonCell.h"
#import "SWUploadBuyWarningButtonCell.h"
#import "UIViewController+SWSendMailControllerPresenter.h"

#import "PDFViewController.h"

#import "ColoredButton.h"
//#import "SWCircleButton.h"

#import "SKProduct+priceString.h"
#import "SWColor.h"



static NSString * const SWUploadProgressCellIdentifier = @"SWUploadProgressCellIdentifier";
static NSString * const SWUploadUploadButtonCellIdentifier = @"SWUploadUploadButtonCellIdentifier";
static NSString * const SWUploadCurrentProjectCellIdentifier = @"SWUploadCurrentProjectCellIdentifier";
static NSString * const SWUploadRemoteProjectCellIdentifier = @"SWUploadRemoteProjectCellIdentifier";
static NSString * const SWUploadActivationCodesCellIdentifier = @"SWUploadActivationCodesCellIdentifier";
static NSString * const SWUploadBuyProductsButtonCellIdentifier = @"SWUploadBuyProductsButtonCellIdentifier";
static NSString * const SWUploadBuyWarningButtonCellIdentifier =  @"SWUploadBuyWarningButtonCellIdentifier";


@interface SWUploadViewController ()<AppFilesModelObserver, AppModelActivationCodesObserver, SWUploadBuyProductButtonCellDelegate,
    SWUploadActivationCodeCellDelegate, UIAlertViewDelegate>
{
    SWUploadCurrentProjectCell *_projectCell;
    SWUploadRemoteProjectCell *_remoteProjectCell;
    SWUploadProgressCell *_progressCell;
    SWUploadBuyWarningButtonCell *_buyWarningCell;
    FileMD *_currentProjectMD;  // l'agafem en el viewDidLoad i es valid per la vida de la clase
    //SWUploadUploadButtonCell *_uploadButtonCell;
    NSTimer *_statusTimer;
    BOOL _isUploading;
    BOOL _isRemoteProjectPresented;
    BOOL _arePProductsPresented;
    BOOL _areQProductsPresented;
    BOOL _arePaymentsDisabled;
    BOOL _areActivationsPresented;
    NSArray *_activationCodes;
    NSArray *_products;
    NSInteger _qProductsCount;
    SKProduct *_tappedProduct;
}

@end


//// sections
//enum
//{
//    SectionCurrentProject = 0,
//    SectionProgress,
//    SectionRemoteProject,
//    SectionProducts,
//    SectionActivationCodes,
//    SectionsTotalSections,
//};

// sections
enum
{
    SectionProgress,
    SectionCurrentProject,
    SectionProducts,
    SectionRemoteProject,
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

// Section Activation Codes Store
enum
{
    RowBuyWarningCell = 0,
    SectionBuyWarningCellCount,
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

- (SWUploadBuyWarningButtonCell *)buyWarningCell
{
    if ( _buyWarningCell == nil )
    {
        _buyWarningCell = [self.tableView dequeueReusableCellWithIdentifier:SWUploadBuyWarningButtonCellIdentifier];
        [_buyWarningCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [_buyWarningCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [_buyWarningCell.buttonWarning addTarget:self action:@selector(buttonWarningAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyWarningCell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xWhiteShadow.png"]
//                    style:UIBarButtonItemStyleBordered
//                    target:self
//                    action:@selector(_dismissController:)];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                    target:self
                    action:@selector(_dismissController:)];
    
    [[self navigationItem] setLeftBarButtonItem:closeItem];
    
    [_labelHeader setText:NSLocalizedString(@"UploadViewControllerMessage", nil)];
    
    
//QWE    _currentProjectMD = [filesModel() currentDocumentFileMDWithCategory:kFileCategorySourceFile];
    _currentProjectMD = [filesModel().fileDocument currentDocumentFileMD];  // QWE
    
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
    
    UIButton *buttonUpload = _projectCell.buttonUpload;
    if ( [buttonUpload respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
        [(id)buttonUpload setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
    
    [_projectCell.buttonUpload addTarget:self action:@selector(uploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self uploadButtonCell];
//    [_uploadButtonCell.buttonUpload setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
//    [_uploadButtonCell.buttonUpload addTarget:self action:@selector(uploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //_numProducts = 2;
    //_numActivationCodes = 3;
    
//    UITableView *table = self.tableView;
//    table.sectionHeaderHeight = 0;
//    table.sectionFooterHeight = 0;
}






- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _beginLoadRemoteProjectMD];
    [self _beginPresentingQProducts];
    [self _establishUploadingAnimated:animated];
    
    [filesModel().files addObserver:self];
    [filesModel().amActivationCodes addObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [filesModel().amActivationCodes processPendingreceipts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [filesModel().amActivationCodes resetProductsMDArray];
    
    [filesModel().files removeObserver:self];
    [filesModel().amActivationCodes removeObserver:self];
}






#pragma mark private

- (void)_dismissController:(id)sender
{
    //[self dismissModalViewControllerAnimated:YES] ;
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



- (void)_establishUploadingAnimated:(BOOL)animated
{
    BOOL uploading = [filesModel().files updatingProject];
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
    
//    if ( _isUploading ) buttonTitle = NSLocalizedString(@"CANCEL UPLOAD", nil);
//    else buttonTitle = NSLocalizedString(@"UPLOAD PROJECT", nil);
    
    
    if ( _isUploading ) buttonTitle = NSLocalizedString(@"Cancel Upload", nil);
    else buttonTitle = NSLocalizedString(@"Upload Project", nil);
    
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
        NSArray *allProducts = [filesModel().amActivationCodes productsMDArray];
        if ( allProducts.count > 0 )
        {
            _products = allProducts;
            _qProductsCount = [filesModel().amActivationCodes qProductsCount];
        }
    }

    return _products;
}


- (NSInteger)_qProductsCount
{
    [self _products];
    return _qProductsCount;
}


- (NSArray*)_activationCodes
{
    if ( _activationCodes == nil )
    {
        NSArray *allActivationCodes = [filesModel().files filesMDArrayForCategory:kFileCategoryRemoteActivationCode];
        if ( allActivationCodes.count > 0 )
        {
            NSMutableArray *activationCodes = [NSMutableArray array];
            NSString *currentProjectID = _currentProjectMD.identifier;
            NSString *currentProjectID2 = [@"*" stringByAppendingString:currentProjectID];
            
            for ( FileMD *activationCode in allActivationCodes )
            {
            
            // el activation code hauria de tenir el id, no el url
                NSString *projectID = [activationCode.projects lastObject];
                
                if ( [projectID isEqualToString:currentProjectID] ||
                    [projectID isEqualToString:currentProjectID2] )
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
            if ( _isRemoteProjectPresented )
                totalRows = SectionRemoteProjectTotalRows;
            break;
            
        case SectionActivationCodes:
            if ( _areActivationsPresented )
                totalRows = [[self _activationCodes] count]; // _numActivationCodes;
            break;
            
        case SectionProducts:
            if ( _arePaymentsDisabled)
            {
                totalRows = 1;
            }
            else if ( _areQProductsPresented && _arePProductsPresented )
            {
                totalRows = [[self _products] count];
                if ( totalRows>0 ) totalRows += SectionBuyWarningCellCount;
            }
            else if ( _areQProductsPresented && !_arePProductsPresented )
            {
                totalRows = [self _qProductsCount];
                if ( totalRows>0 ) totalRows += SectionBuyWarningCellCount;
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
            if ( row == RowBuyWarningCell && !_arePaymentsDisabled ) cell = [self buyWarningCell];
            else identifier = SWUploadBuyProductsButtonCellIdentifier;
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
        UIButton *buttonBuy = aCell.buttonBuy;
        UILabel *labelProduct = aCell.labelProduct;
        UILabel *labelTitle = aCell.labelTitle;
        if ( _arePaymentsDisabled )
        {
            [buttonBuy setEnabled:NO];
            if ( [buttonBuy respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
                [(id)buttonBuy setRgbTintColor:TheNiceGreenColor overWhite:YES];
            else [buttonBuy setTintColor:UIColorWithRgb(TheNiceGreenColor)];

            NSString *title = NSLocalizedString(@"BUY (Disabled)", nil);
            NSString *text = NSLocalizedString(@"In App Purchases are disabled on the Settings App", nil);
            [buttonBuy setTitle:title forState:UIControlStateNormal];
            [labelProduct setText:text];
            //[labelProduct setTextColor:UIColorWithRgb(TangerineSelectionColor)];
            //[labelProduct setTextColor:[UIColor redColor]];
        }
        else
        {
            SKProduct *product = [[self _products] objectAtIndex:row-SectionBuyWarningCellCount];
            NSString *productId = product.productIdentifier;
            
            if ( [buttonBuy respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
                [(id)buttonBuy setRgbTintColor:TheNiceGreenColor overWhite:YES];
            else
            {
                [buttonBuy setTintColor:UIColorWithRgb(TheNiceGreenColor)];
                //[buttonBuy setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }
            
            BOOL isWaitingName = ([_tappedProduct.productIdentifier isEqualToString:productId]);
            BOOL isPreparingProduct = [filesModel().amActivationCodes isPreparingProduct:productId];
            BOOL isWaitingReceipt = [filesModel().amActivationCodes isWaitingReceiptForProduct:productId];
            //BOOL isWaitingActivation = [filesModel().amActivationCodes isWaitingActivationForProduct:productId userId:[usersModel() currentUserId]];
            BOOL isWaitingActivation = [filesModel().amActivationCodes isWaitingActivationForProduct:productId userUUID:[cloudKitUser() currentUserUUID]];
            
            BOOL enabled = ! (isWaitingName || isPreparingProduct || isWaitingReceipt || isWaitingActivation );
            [buttonBuy setEnabled:enabled];
            
            NSString *title = nil;
            if ( enabled )
            {
                NSString *format = NSLocalizedString(@"BUY (%@)", nil);
                title = [NSString stringWithFormat:format, product.priceString];
            }
            else if ( isWaitingActivation )
            {
                title = NSLocalizedString(@"ACTIVATING...", nil);
            }
            else if ( isWaitingReceipt || isPreparingProduct )
            {
                title = NSLocalizedString(@"PURCHASING...", nil);
            }
            else if ( isWaitingName )
            {
                title = NSLocalizedString(@"PREPARING...", nil);
            }
            
            [buttonBuy setTitle:title forState:UIControlStateNormal];
            NSString *productDescr = product.localizedDescription;
            [labelProduct setText:productDescr];
            
            NSString *labelTitleText = nil;
            if ( [product isQProduct] )
                labelTitleText = NSLocalizedString(@"New Local Activation Code", nil);
            else
                labelTitleText = NSLocalizedString(@"New Activation Code", nil);
            
            [labelTitle setText:labelTitleText];

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
        //[aCell.labelDate setText:fileMD.created];
        [aCell.labelDate setText:fileMD.fileDateString];
        [aCell.labelProject setText:[fileMD project]];
        
//        NSInteger redemptionsCount = fileMD.redemptions.count;
        NSArray *redemptions = fileMD.redemptions;
        NSInteger maxRedemptions = fileMD.maxRedemptions;
        
        //NSString *totalsStringFmt = NSLocalizedString(@"%d Projects, %d Redemptions", nil);
//        NSString *usedStringFmt = NSLocalizedString(@"%d Used, %d Available", nil);
//        NSString *usedString = [NSString stringWithFormat:usedStringFmt, redemptionsCount, maxRedemptions-redemptionsCount];
        
        NSString *redemptionsString = nil;
        if ( redemptions == nil )
        {
            NSString *redemptionsStringFmt = NSLocalizedString(@"%d Max allowed", nil);
            redemptionsString = [NSString stringWithFormat:redemptionsStringFmt, maxRedemptions];
        }
        else
        {
            NSInteger redemptionsCount = redemptions.count;
            NSString *redemptionsStringFmt = NSLocalizedString(@"%d Used, %d Available", nil);
            redemptionsString = [NSString stringWithFormat:redemptionsStringFmt, redemptionsCount, maxRedemptions-redemptionsCount];
        }
        
        //[aCell.labelTotal setText:totalsString];
        [aCell.labelUsed setText:redemptionsString];
        
        UIButton *buttonEmail = aCell.buttonEmail;
        if ( [buttonEmail respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
            [(id)buttonEmail setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
        
        NSString *title = nil;

        //if ( fileMD.maxProjects == 0 && HMiPadDev )
        if ( [SKProduct isQProduct:fileMD.productSKU] )
        {
            [buttonEmail setEnabled:fileMD.pendingRedemptions>0];
            title = NSLocalizedString(@"Redeem", nil);
        }
        else
        {
            [buttonEmail setEnabled:YES];
            title = NSLocalizedString(@"Send Email", nil);
        }

        [buttonEmail setTitle:title forState:UIControlStateNormal];
        
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
            if ( row == RowProjectCell ) height = 154;
            break;
        
        case SectionProgress:
            if ( row == RowProgressCell ) height = 100;
            break;
    
//        case SectionUploadButton:
//            if ( row == RowUploadButtonCell ) height = 44;
//            break;
            
        case SectionRemoteProject:
            if ( row == RowRemoteProjectCell ) height = 100;
            break;
            
        case SectionActivationCodes:
            height = 94;
            break;
            
        case SectionProducts:
            height = 48;
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
                case SectionCurrentProject:
                    title = NSLocalizedString(@"CURRENT PROJECT", nil);
                    break;
        
                case SectionProgress:
                    title = NSLocalizedString(@"UPLOAD PROGRESS", nil);
                    break;
    
        //        case SectionUploadButton:
        //            if ( row == RowUploadButtonCell ) height = 44;
        //            break;
            
                case SectionRemoteProject:
                    title = NSLocalizedString(@"INTEGRATORS SERVICE", nil);
                    break;
            
                case SectionActivationCodes:
                    title = NSLocalizedString(@"PURCHASED ACTIVATION CODES", nil);
                    break;
            
                case SectionProducts:
                    title = NSLocalizedString(@"ACTIVATION CODES STORE", nil);
                break;
            }
        }
    }
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog( @"IndexPath: %@", indexPath );
}


#pragma mark button action

- (void)uploadButtonAction:(id)sender
{
    NSInteger uploadStep = [filesModel().files groupUploadStep];
    if ( uploadStep == -1 )
        [filesModel().files uploadProject];
    else
        [filesModel().files cancelUpload];
}


- (void)buttonWarningAction:(id)sender
{
    PDFViewController *pdfViewController = [[PDFViewController alloc] init];
    
    //NSString *filePath = [filesModel() fullViewerUrlPathForTextUrl:@"system://Purchasing Expensive Items.pdf" /*forCategory:kExtFileCategoryMainBundle*/];
    
    
    NSString *filePath = [filesModel().filePaths fullViewerUrlPathForTextUrl:@"system://Purchasing Expensive Items.pdf" inDocumentName:nil];

    
    [pdfViewController setPdfUrlText:filePath];
    [pdfViewController setTitle:@"Making a $100 Purchase"];
    [pdfViewController setTitle:@""];
    [self.navigationController pushViewController:pdfViewController animated:YES];
}



//- (void)delayed:(UIViewController*)presentingController
//{
//    [presentingController presentRedeemControllerForActivationCode:nil];
//}


- (void)activationCodeCellDidTouchEmail:(SWUploadActivationCodeCell *)cell
{
    FileMD *fileMD = cell.fileMD;

    if ( [SKProduct isQProduct:fileMD.productSKU] )
    {
        UIViewController *presentingController = [self presentingViewController];
        [self dismissViewControllerAnimated:YES completion:^
        {
            [presentingController presentRedeemControllerForActivationCode:fileMD.accessCode];
        }];
    }
    else
    {
        [self presentMailControllerForActivationCodeMD:fileMD];
    }
}


//- (void)buyProductCellDidTouchBuy:(SWUploadBuyProductButtonCell *)cell
//{
//    _tappedProduct = cell.skProduct;
//    NSString *title = NSLocalizedString(@"ActivationCodeAlertTitle", nil);
//    NSString *placeholder = NSLocalizedString(@"Unique Name", nil);
//    NSString *message = NSLocalizedString(@"ActivationCodeAlertMessage", nil);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//        message:message
//        delegate:nil
//        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
//        otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
//    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [alertView setDelegate:self];
//    alertView.tag = AlertViewActivationName;
//    
//    UITextField *textField = [alertView textFieldAtIndex:0];
//    textField.font = [UIFont systemFontOfSize:17];
//    textField.textColor = UIColorWithRgb(TextDefaultColor);
//    textField.placeholder = placeholder;
//
//    [alertView show];
//    
//    [self _reloadProductsSectionAnimated:NO];
//}


- (void)buyProductCellDidTouchBuy:(SWUploadBuyProductButtonCell *)cell
{
    _tappedProduct = cell.skProduct;
    NSString *title = NSLocalizedString(@"ActivationCodeAlertTitle", nil);
    NSString *placeholder = NSLocalizedString(@"Unique Name", nil);
    NSString *message = NSLocalizedString(@"ActivationCodeAlertMessage", nil);
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.font = [UIFont systemFontOfSize:17];
        textField.textColor = UIColorWithRgb(TextDefaultColor);
        textField.placeholder = placeholder;
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil ) style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action)
    {
        _tappedProduct = nil;
    }];
            
    [alert addAction:actionCancel];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", nil ) style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *a)
    {
        NSArray *textFields = [alert textFields];
        UITextField *textField = textFields.firstObject;
        NSString *name = textField.text;
        [filesModel().amActivationCodes addPaymentForProduct:_tappedProduct forProjectWithUUID:_currentProjectMD.identifier
                    withActivationCodeName:name];
        _tappedProduct = nil;
    }];
            
    [alert addAction:actionOk];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [self _reloadProductsSectionAnimated:NO];
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
//                NSString *name = textField.text;
//                [filesModel().amActivationCodes addPaymentForProduct:_tappedProduct forProjectWithUUID:_currentProjectMD.identifier
//                    withActivationCodeName:name];
//            }
//            break;
//        }
//        default:
//        {
//            break;
//        }
//    }
//    
//    _tappedProduct = nil;
//    [self _reloadProductsSectionAnimated:NO];
//}







#pragma mark AppsFileModelObserver (Upload)

- (void)appFilesModel:(AppModelFilesEx *)filesModel beginGroupUploadForCategory:(FileCategory)category
{
    [self _establishUploadingAnimated:YES];
    [self _resetStatus];
    [self _resetRemote];
    [self _resetAllProducts];
    [self _resetActivationCodes];
    
    // aqui treure el remote
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel willUploadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    //NSLog( @"Will upload %@", fileName );

    NSString *text = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Uploading:",nil), fileName];
    [_progressCell.labelDetailProgress setText:text];
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel didUploadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
    
    //NSLog( @"Did upload %@", fileName );
    
    
    NSString *text = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Uploaded:",nil), fileName];
    [_progressCell.labelDetailProgress setText:text];
        
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


- (void)appFilesModel:(AppModelFilesEx*)filesModel groupUploadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category;
{
    //float progressValue = (float)step/(float)stepCount;
    float progressValue = 0.1f + (float)step*(0.9f/(float)stepCount);
    [_progressCell.progressView setProgress:progressValue animated:YES];
    [_progressCell.detailProgressView setProgress:0.05f animated:NO];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel fileUploadProgress:(double)progress fileName:(NSString *)fileName category:(FileCategory)category
{
    NSString *text = [NSString stringWithFormat:@"%@ '%@' %0.1f%%", NSLocalizedString(@"Uploading:",nil), fileName, progress*100];
    [_progressCell.labelDetailProgress setText:text];
    float progressValue = 0.1f + (float)progress*(0.9f);
    [_progressCell.detailProgressView setProgress:progressValue animated:NO];
}


//- (void)appFilesModel:(AppModelFilesEx *)filesModel fileUploadProgressBytesRead:(long long)bytesRead
//    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
//{
//    //float progressValue = (float)bytesRead/(float)totalBytesExpected;
//    float progressValue = 0.1f + (float)bytesRead*(0.9f/(float)totalBytesExpected);
//    [_progressCell.detailProgressView setProgress:progressValue animated:YES];
//}


- (void)appFilesModel:(AppModelFilesEx*)filesModel endGroupUploadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{
    [self _establishUploadingAnimated:YES];
    [self _establishUploadStatusFinished:finished canceled:canceled error:nil];
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

- (void)_beginPresentingQProducts
{
    _areQProductsPresented = YES;
    _arePProductsPresented = NO;
    [self _reloadProductsSectionAnimated:YES];
}


- (void)_beginPresentingAllProducts
{
    _areQProductsPresented = YES;
    _arePProductsPresented = YES;
    [self _reloadProductsSectionAnimated:YES];
}


- (void)_resetAllProducts
{
    if ( _arePProductsPresented || _areQProductsPresented )
    {
        _areQProductsPresented = NO;
        _arePProductsPresented = NO;
        _products = nil;
        _qProductsCount = 0;
        [filesModel().amActivationCodes resetProductsMDArray];
        [self _reloadProductsSectionAnimated:YES];
    }
}

- (void)appFilesModel:(AppModelFilesEx *)filesModel didGetProductsListingAndCanMakePayments:(BOOL)yesWeCan
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
    [filesModel().files getRemoteFileMDForFileWithUUID:_currentProjectMD.identifier forCategory:kFileCategoryRemoteSourceFile];
}


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
    
    if ( category != kFileCategoryRemoteSourceFile)
        return;
    
    BOOL change = ( (error==nil) != _isRemoteProjectPresented ) ;
    _isRemoteProjectPresented = (error==nil);
    
    if ( change )
    {
        [self _reloadRemoteProject];
    }
    
    if ( _isRemoteProjectPresented )
    {
        [_remoteProjectCell.labelName setText:fileMD.fileName];
        [_remoteProjectCell.labelUUID setText:fileMD.identifier];
        //[_remoteProjectCell.labelDate setText:fileMD.updated];
        [_remoteProjectCell.labelDate setText:fileMD.fileDateString];
        [_remoteProjectCell.labelSize setText:[fileMD fileSizeString]];
        
        [self _beginPresentingAllProducts];
    }
    else
    {
        [self _beginPresentingQProducts];
    }

    [self _beginPresentingActivationCodes];
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



#pragma mark AppsFileModelObserver (redemption)

- (void)appFilesModel:(AppModelFilesEx *)filesModel willChangeRemoteListingForCategory:(FileCategory)category
{
    if ( category != kFileCategoryRemoteActivationCode )
        return;
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError *)error
{
    if ( category == kFileCategoryRemoteActivationCode )
        [self _beginPresentingActivationCodes];
}


#pragma mark AppsFileModelObserver (redemption)

- (void)appFilesModel:(AppModelFilesEx *)filesModel didRedemCode:(NSString *)code withError:(NSError *)error
{
    BOOL change = (error==nil);
    
    if ( change )
        [filesModel refreshMDArrayForCategory:kFileCategoryRemoteRedemption];
}


#pragma mark - AppModelActivationCodesObserver


- (void)appFilesModel:(AppModelActivationCodes *)filesModel didFinishTransactionWithSuccess:(BOOL)success
{
    [self _reloadProductsSectionAnimated:NO];
}

- (void)appFilesModel:(AppModelActivationCodes *)filesModel didProvideContentForProduct:(NSString *)productId
    activation:(NSString *)activationCode success:(BOOL)success
{
//    [defaults() setActivationCodeName:@""];
    [self _reloadProductsSectionAnimated:NO];
    
    if ( [SKProduct isQProduct:productId] )
    {
    
#warning hem de separar-ho del proces de pagar posar-ho a part
                // aqui apliquem una redemption
        //NSLog( @"aplicar redemption" );
       // [filesModel redeemActivationCode:activationCode];
    }
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

- (void)_establishUploadStatusFinished:(BOOL)finished canceled:(BOOL)canceled error:(NSError*)error
{
    NSString *text = nil;
    if ( canceled ) text = NSLocalizedString(@"Upload Canceled by User", nil);
    else if ( finished ) text = NSLocalizedString(@"Upload Completed", nil);
    else
    {
        text = NSLocalizedString(@"Upload Error", nil);
        if ( error ) text = [text stringByAppendingFormat:@": %@", error.localizedDescription];
    }
    
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
