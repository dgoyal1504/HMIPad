//
//  SWCurrentProjectViewController.m
//  HmiPad
//
//  Created by Joan on 16/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "SWCurrentProjectViewController.h"

#import "AppModelFilesEx.h"
#import "AppModelDocument.h"
#import "AppModelSource.h"

//#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"
#import "SWCurrentProjectView.h"

#import "SWNavBarTitleView.h"
#import "SWCircleButton.h"
#import "SWImageManager.h"

#import "SWBlockAlertView.h"
//#import "SWBlockActionSheet.h"

#import "UIViewController+SWSendMailControllerPresenter.h"
#import "LoginWindowControllerC.h"
#import "SWRevealViewController.h"

#import "Drawing.h"
#import "SWColor.h"




#define RowHeight 70

@interface SWCurrentProjectViewController () <SWCurrentProjectViewDelegate,AppFilesModelObserver, AppModelDocumentObserver, DocumentModelObserver,UITableViewDataSource,UITableViewDelegate,LoginWindowControllerDelegate>
{
    SWCurrentProjectView *_currentProjectView;
    SWDocumentModel *_docModel;
    FileCategory _fileCategory;
    UIImage *_placeholderImage;
    LoginWindowControllerC *_loginWindow;  // per amagatzemar la finestra de login
    BOOL isRunOnly;
}
@end

@implementation SWCurrentProjectViewController
{
    BOOL _showEmptyTable;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFileCategory:(int)aCategory //forDocument:(SWDocument *)document
{
    self = [super init];
    if ( self )
    {
        _fileCategory = aCategory;
        isRunOnly = HMiPadRun?YES:NO;
        
        SWDocument *document = [filesModel().fileDocument currentDocument];
        _docModel = document.docModel;
        
        [_docModel addObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [_docModel removeObserver:self];
    //NSLog( @"SWAuxiliarFilesViewController: dealloc");
}


- (void)loadViewV
{
    NSString *theNibName;
    if ( IS_IOS7 ) theNibName = @"SWCurrentProjectView";
    else theNibName = @"SWCurrentProjectView6";

    UINib *nib = [UINib nibWithNibName:theNibName bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:self options:nil];
    _currentProjectView = [objects objectAtIndex:0];
    
    CGRect rect = _currentProjectView.bounds;
    [_currentProjectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

    UIView *view = [[UIView alloc] initWithFrame:rect];
    [view setBackgroundColor:_currentProjectView.backgroundColor];
    
    if ( IS_IOS7 )
    {
        rect.origin.y = 44+20;
        rect.size.height -= rect.origin.y;
        [_currentProjectView setFrame:rect];
    }
    
    [view addSubview:_currentProjectView];
    
    self.view = view;
}


- (void)loadView
{
    NSString *theNibName;
    if ( IS_IOS7 ) theNibName = @"SWCurrentProjectView";
    else theNibName = @"SWCurrentProjectView6";

    UINib *nib = [UINib nibWithNibName:theNibName bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:self options:nil];
    _currentProjectView = [objects objectAtIndex:0];
    
    CGRect rect = _currentProjectView.bounds;
    [_currentProjectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];

    UIScrollView *view = [[UIScrollView alloc] initWithFrame:rect];
    [view setScrollEnabled:YES];
    [view setContentSize:rect.size];
    [view setBackgroundColor:_currentProjectView.backgroundColor];
    
//    if ( IS_IOS7 )
//    {
//        rect.origin.y = 44+20;
//        rect.size.height -= rect.origin.y;
//        [_currentProjectView setFrame:rect];
//    }
    
    [view addSubview:_currentProjectView];
    
    self.view = view;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SWNavBarTitleView *titleView = [[SWNavBarTitleView alloc] init];
    titleView.mainLabel.text = [self baseTitle];
    titleView.secondaryLabel.text = [self secondaryTitle];
    [titleView sizeToFit];
    UINavigationItem *navItem = self.navigationItem;
    navItem.titleView = titleView;
    
    UITableView *tableLocalAssets = _currentProjectView.tableAssets;
    tableLocalAssets.rowHeight = 24;
    [tableLocalAssets setDataSource:self];
    [tableLocalAssets setDelegate:self];

    CALayer *layer = tableLocalAssets.layer;
    [layer setCornerRadius:5];
    
    [_currentProjectView.switchEmbedded addTarget:self action:@selector(switchEmbeddedTarget:) forControlEvents:UIControlEventValueChanged];
    
    [_currentProjectView setDelegate:self];
    [_currentProjectView setRunOnly:isRunOnly];
    
    [self setupCellData];
    [self setupCurrentProjectViewSelection];
    [self setupEmbeddedAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [filesModel().files addObserver:self];
    [filesModel().fileDocument addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [filesModel().files removeObserver:self];
    [filesModel().fileDocument removeObserver:self];
    [super viewWillDisappear:animated];
}

#pragma mark private

- (NSString*)baseTitle
{
    if ( _fileCategory == kFileCategorySourceFile )
        return NSLocalizedString(@"Current Project",nil);
    
//    else if ( _fileCategory == kFileCategoryRedeemedSourceFile )
//        return NSLocalizedString(@"Current Project",nil);
    
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)secondaryTitle
{
    if ( _fileCategory == kFileCategorySourceFile )
        return NSLocalizedString(@"Projects",nil);
    
//    else if ( _fileCategory == kFileCategoryRedeemedSourceFile )
//        return NSLocalizedString(@"Projects",nil);
    
    return nil;
}


- (FileMD*)projectMD
{
    // QWE return [filesModel() currentDocumentFileMDWithCategory:fileCategory];
    return [filesModel().fileDocument currentDocumentFileMD];   // QWE
}

- (NSArray*)embeddedAssetFileMDs
{
    FileMD *projectMD = [self projectMD];
    return [filesModel().files assetsMDArrayEmbeddedInProjectName:projectMD.fileName];
}

- (UIImage *)placeholderImageV
{
    if ( _placeholderImage == nil )
    {
        CGFloat radius = 5;
        radius = 0;
        UIColor *color = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1];
        UIImage *image = glossyImageWithSizeAndColor( CGSizeMake(RowHeight-2, RowHeight-2), [color CGColor], NO, NO, radius, 1 );
        //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, radius+1, 0, radius+1)];
        _placeholderImage = image;
    }
    return _placeholderImage;
}


- (UIImage *)placeholderImage
{
    if ( _placeholderImage == nil )
    {
        CGFloat radius = 0;
        UIColor *color = [UIColor colorWithWhite:1 alpha:0];
        UIImage *image = glossyImageWithSizeAndColor( CGSizeMake(RowHeight, RowHeight), [color CGColor], NO, NO, radius, 1 );
        _placeholderImage = image;
    }
    return _placeholderImage;
}



- (UIImage*)defaultImageForFileFullPath:(NSString*)fileFullPath
{
    if ( fileFullPath == nil )
    {
#warning To DO s'ha de Tornar placeholder per el tipus d'arxiu
        return nil;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:fileFullPath];

    UIDocumentInteractionController *interactionController =
        [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    // interactionController.delegate = interactionDelegate;
   
    NSArray *icons = [interactionController icons];   // aparentment torna 64x64 i 320x320
   
    UIImage *firstIcon = nil;
    if ( icons.count > 0 )
        firstIcon = [icons objectAtIndex:0];


//   NO ESBORRAR, MANTENIR PER REFERENCIA aparentment torna 64x64 i 320x320
//    for ( UIImage *img in icons)
//    {
//        NSLog( @"iconSize %@", NSStringFromCGSize( img.size ));
//    }
 
    return firstIcon;
}

- (void)configureUploadButon:(UIButton*)button label:(UILabel*)label
{
    NSString *str1 = nil;
    NSString *str2 = nil;
    
    if ( isRunOnly ) str1 = @"Update";
    else str1 = @"Activate";
    
    if ( isRunOnly ) str2 = @"Update this project to the latest version";
    else str2 = @"Store this Project in the Cloud or Activate for final users";
    
    str1 = NSLocalizedString( str1, nil );
    str2 = NSLocalizedString( str2, nil );
    
    if ( [button respondsToSelector:@selector(setRgbTintColor:overWhite:)])
        [(ColoredButton*)button setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
    
    [button setTitle:str1 forState:UIControlStateNormal];
    
    [label setText:str2];
}

- (void)configureDuplicateButton:(UIButton*)button label:(UILabel*)label
{
    NSString *str1 = nil;
    NSString *str2 = nil;
    
    str1 = @"Duplicate";
    str1 = NSLocalizedString( str1, nil );
    
    str2 = @"Create New Local Project based on this one";
    str2 = NSLocalizedString( str2, nil );
    
    
    if ( [button respondsToSelector:@selector(setRgbTintColor:overWhite:)])
        [(ColoredButton*)button setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
    
    [button setTitle:str1 forState:UIControlStateNormal];
    
    [label setText:str2];
}

- (void)configureCloseButton:(UIButton*)button label:(UILabel*)label
{
    NSString *str1 = nil;
    NSString *str2 = nil;
    
    str1 = @"Close";
    str1 = NSLocalizedString( str1, nil );
    
    str2 = @"Close this Project";
    str2 = NSLocalizedString( str2, nil );
    
    if ( [button respondsToSelector:@selector(setRgbTintColor:overWhite:)])
        [(ColoredButton*)button setRgbTintColor:Theme_RGB(0, 255, 32, 32) overWhite:YES];  // vermell

    [button setTitle:str1 forState:UIControlStateNormal];
    
    [label setText:str2];
}


- (void)setupCurrentProjectViewSelection
{
    FileMD *fileMD = [self projectMD];
    
    [self configureUploadButon:[_currentProjectView buttonUpload] label:[_currentProjectView labelPromptUpdate]];
    [self configureDuplicateButton:[_currentProjectView buttonDuplicate] label:[_currentProjectView labelPromptDuplicate]];
    [self configureCloseButton:[_currentProjectView buttonClose] label:[_currentProjectView labelPromptClose]];
    
    [_currentProjectView setViewsDisabled:(fileMD==nil)];
}

- (void)setupCellData
{
    FileMD *fileMD = nil;
    NSString *name = nil;
    NSString *ident = nil;
    NSString *date = nil;
    NSString *size = nil;
    
    fileMD = [self projectMD];
    [_currentProjectView setViewsDisabled:(fileMD==nil)];
    
    name = fileMD.fileName;
    ident = fileMD.identifier;
    date = fileMD.fileDateString;
    size = fileMD.fileSizeString;
    
    [_currentProjectView.labelFileName setText:name];
    [_currentProjectView.labelFileIdent setText:ident];
    [_currentProjectView.labelModDate setText:date];
    [_currentProjectView.labelSize setText:size];
    
    
    UIButton *buttonImage = _currentProjectView.buttonImage;
    if ( [buttonImage imageForState:UIControlStateNormal] == nil )
    {
        [buttonImage setImage:[self placeholderImage] forState:UIControlStateNormal];
    }
    
    UIImage *image = fileMD.thumbnailImage;

    if ( image != nil )
    {
        [buttonImage setImage:image forState:UIControlStateNormal];
    }
    else
    {
        NSString *imageFullPath = fileMD.imageFullPath;
        
        //image = [self defaultImageForFileFullPath:imageFullPath];
        image = [self placeholderImage];
        [buttonImage setImage:image forState:UIControlStateNormal];
        
        SWImageManager *imageManager = [SWImageManager defaultManager];
        [imageManager getImageWithOriginalPath:imageFullPath size:CGSizeMake(RowHeight,RowHeight) contentMode:UIViewContentModeScaleAspectFill completionBlock:^(UIImage *aImage)
        {
            if ( aImage != nil )
                [buttonImage setImage:aImage forState:UIControlStateNormal];
        }];
    }
    
    //image = [image resizedImageWithContentMode:UIViewContentModeCenter bounds:CGSizeMake(RowHeight,RowHeight) contentScale:image.scale interpolationQuality:kCGInterpolationDefault cropped:NO];
    
    UISwitch *switchEmbedded = _currentProjectView.switchEmbedded;
    [switchEmbedded setOn:_docModel.embeededAssets animated:YES];
}


- (void)setupEmbeddedAnimated:(BOOL)animated
{
    BOOL embeededAssets = _docModel.embeededAssets;
    [_currentProjectView.switchEmbedded setOn:embeededAssets animated:animated];
    
    NSString *labelAssetsText = nil;
    if ( embeededAssets )
        labelAssetsText = NSLocalizedString(@"Attached Assets", nil);
    else
        labelAssetsText = NSLocalizedString(@"Required Local Assets", nil);
    
    [_currentProjectView.labelAssets setText:labelAssetsText];
}

- (void)reloadTableAnimated:(BOOL)animated
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    UITableViewRowAnimation animation = animated?UITableViewRowAnimationFade:UITableViewRowAnimationNone;
    [_currentProjectView.tableAssets reloadSections:indexSet withRowAnimation:animation];
}

////---------------------------------------------------------------------------------------------
//- (void)resetSourceFiles
//{
////    if ( _fileCategory == kFileCategorySourceFile ) [filesModel() setProjectSources:nil];
////    else if ( _fileCategory == kFileCategoryRedeemedSourceFile ) [filesModel() setProjectSources:nil];
//    
//    [filesModel() setProjectSources:nil];
//}



#pragma mark switch target


- (void)switchEmbeddedTarget:(UISwitch*)switchEmbedded
{
    BOOL isOn = switchEmbedded.isOn;
    _docModel.embeededAssets = isOn;
}


#pragma mark Assets Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ( isRunOnly )
        return 0;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( isRunOnly )
        return 0;
    
    NSInteger fileCount = 0;
    
    if ( _docModel.embeededAssets ) fileCount = [[self embeddedAssetFileMDs] count];
    else fileCount = _docModel.fileList.count;
    
    if ( (_showEmptyTable = (fileCount == 0)) )
        fileCount = 1;
    
    return fileCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReuseCellIdentifier = @"cell";
    
    if ( _showEmptyTable )
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.textColor = UIColorWithRgb(Theme_RGB(0, 76, 76, 76));  // <- Iron
        cell.textLabel.font = [UIFont italicSystemFontOfSize:13];
        
        NSString *emptyText = nil;
        if ( _docModel.embeededAssets )
            emptyText = NSLocalizedString(@"No Assets", nil);
        else
            emptyText = NSLocalizedString(@"No Selected Assets", nil);
        
        cell.textLabel.text = emptyText;
    
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseCellIdentifier];
    if ( cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseCellIdentifier];
        cell.textLabel.textColor = UIColorWithRgb(Theme_RGB(0, 76, 76, 76));  // <- Iron
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    
    NSInteger row = [indexPath row];

    NSString *fileName = nil;
    if ( _docModel.embeededAssets )
    {
        NSArray *embeddedAssetsMDs = [self embeddedAssetFileMDs];
        FileMD *fileMD = [embeddedAssetsMDs objectAtIndex:row];
        fileName = fileMD.fileName;
    }
    else
    {
        NSArray *fileList = _docModel.fileList;
        fileName =  [fileList objectAtIndex:row];
    }
    cell.textLabel.text = fileName;

    return cell;
}


#pragma mark AppsFileModelDocumentObserver


- (void)appFilesModelCurrentDocumentChange:(AppModelDocument*)filesDocument
{
    [_docModel removeObserver:self];
    
    SWDocument *document = filesDocument.currentDocument;
    _docModel = document.docModel;
    
    [_docModel addObserver:self];
}

- (void)appFilesModelCurrentDocumentFileMDDidChange:(AppModelDocument *)filesDocument
{
    [self setupCellData];
    [self setupCurrentProjectViewSelection];
}


#pragma mark AppsFileModelObserver

- (void)appFilesModel:(AppModelFilesEx *)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError *)error
{
    if ( category == kFileCategoryEmbeddedAssetFile )
    {
        [self reloadTableAnimated:YES];
    }
}

#pragma mark SWDocumentModelObserver

- (void)documentModelThumbnailDidChange:(SWDocumentModel *)docModel
{
    [self setupCellData];
}

- (void)documentModelFileListDidChange:(SWDocumentModel *)docModel
{
    [self reloadTableAnimated:YES];
}



- (void)documentModelEmbeddedAssetsDidChange:(SWDocumentModel *)docModel
{
    [self setupEmbeddedAnimated:YES];
    [self reloadTableAnimated:YES];
    
    // to do reload del table view amb els embeeded
}


- (void)documentModelSaveCheckpoint:(SWDocumentModel *)docModel
{
    [self setupCellData];
}


#pragma mark Login LoginWindowControllerDelegate

//---------------------------------------------------------------------------------------------------
- (void)loginWindowDidClose:(LoginWindowControllerC*)sender
{    
    _loginWindow = nil;
}


#pragma mark SWFileViewCurrentProjectDelegate

- (void)currentProjectViewDidTouchImageButton:(SWCurrentProjectView *)view
{

}

//- (void)currentProjectViewDidTouchUploadButtonVELL:(SWCurrentProjectView *)view
//{    
//    if ( isRunOnly ) [self presentUpdateControllerForProjectId:_docModel.uuid owner:_docModel.ownerID];
//    else [self presentUploadController];
//}


//- (void)currentProjectViewDidTouchUploadButtonV:(SWCurrentProjectView *)view
//{
////    UserProfile *profile = [usersModel() currentUserProfile];
//    UserProfile *profile = [cloudKitUser() currentUserProfile];
//    BOOL isLocal = profile.isLocal;
//    
//    if ( isLocal )
//    {
//        //NSString *title = NSLocalizedString( @"Activate Project", nil );
//        NSString *message = NSLocalizedString( @"You must log into a registered user before you can activate projects. You can now log into an existing account or register as a new user", nil );
//        NSString *other1 = NSLocalizedString( @"Log In", nil );
//        NSString *other2 = NSLocalizedString( @"New User Account", nil );
//        NSString *cancel = NSLocalizedString( @"Cancel", nil );
//        //SWBlockAlertView *alert = [[SWBlockAlertView alloc] initWithTitle:title
//          //  message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:other1,other2, nil];
//        
//        SWBlockActionSheet *alert = [[SWBlockActionSheet alloc] initWithTitle:message
//            delegate:nil cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:other1,other2, nil];
//    
//        NSInteger firstChoice = [alert firstOtherButtonIndex];
//        [alert setResultBlock:^(BOOL success, NSInteger index)
//        {
//            if ( success )
//            {
//                if ( index == firstChoice )
//                {
//                    // log in
//                    _loginWindow = [[LoginWindowControllerC alloc] init] ;
//                    [_loginWindow setDelegate:self];
//                    [_loginWindow setCurrentAccount:[usersModel() currentUserName]];
//                    [_loginWindow showAnimated:YES completion:nil] ;
//                }
//                else if ( index == firstChoice+1 )
//                {
//                    // create account
//                    [self presentNewAccountController];
//                }
//            }
//        }];
//    
//        //[alert show];
//        UIView *uploadBtn = view.buttonUpload;
//        [alert showFromRect:uploadBtn.bounds inView:uploadBtn animated:YES];
//        return;
//    }
//
//    if ( isRunOnly )
//    {
//        [self presentUpdateControllerForProjectId:_docModel.uuid owner:_docModel.ownerID];
//    }
//    else
//    {
//        [filesModel().fileDocument saveDocumentWithCompletion:^(BOOL success)
//        {
//            if ( success )
//                [self presentUploadController];
//        }];
//    }
//}


- (void)currentProjectViewDidTouchUploadButton:(SWCurrentProjectView *)view
{
//    UserProfile *profile = [usersModel() currentUserProfile];
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    BOOL isLocal = profile.isLocal;
    
    if ( isLocal )
    {
        [self presentNoUserAlertFromView:view.buttonUpload];
        return;
    }

    if ( isRunOnly )
    {
        [self presentUpdateControllerForProjectId:_docModel.uuid /*owner:_docModel.ownerID*/];
    }
    else
    {
        [filesModel().fileDocument saveDocumentWithCompletion:^(BOOL success)
        {
            if ( success )
                [self presentUploadController];
        }];
    }
}


//- (void)currentProjectViewDidTouchDuplicateButton:(SWCurrentProjectView *)view
//{
//    NSString *ok = NSLocalizedString( @"Ok", nil );
//    NSString *cancel = NSLocalizedString( @"Cancel", nil );
//    //NSString *title = NSLocalizedString( @"Duplicate Project", nil );
//    NSString *message = NSLocalizedString( @"A duplicate of the current project will be created", nil );
////    SWBlockAlertView *alert = [[SWBlockAlertView alloc] initWithTitle:title
////            message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:ok, nil];
//    
//    
//    SWBlockActionSheet *alert = [[SWBlockActionSheet alloc] initWithTitle:message
//        delegate:nil cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:ok, nil];
//    
//    [alert setResultBlock:^(BOOL success, NSInteger index)
//    {
//        if ( success )
//            [filesModel().fileDocument duplicateProject];
//    }];
//    
//    //[alert show];
//    UIView *duplicateBtn = view.buttonDuplicate;
//    [alert showFromRect:duplicateBtn.bounds inView:duplicateBtn animated:YES];
//
//   // [filesModel() duplicateProject];
//}


- (void)currentProjectViewDidTouchDuplicateButton:(SWCurrentProjectView *)view
{
    NSString *ok = NSLocalizedString( @"Ok", nil );
    NSString *cancel = NSLocalizedString( @"Cancel", nil );
    NSString *message = NSLocalizedString( @"A duplicate of the current project will be created", nil );
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popoverPresentationController = actionSheet.popoverPresentationController;
    
    UIView *duplicateBtn = view.buttonDuplicate;
    popoverPresentationController.sourceRect = duplicateBtn.bounds;
    popoverPresentationController.sourceView = duplicateBtn;
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action)
    {
         [filesModel().fileDocument duplicateProject];
    }];
    
    [actionSheet addAction:actionCancel];
    [actionSheet addAction:actionOk];
    [self presentViewController:actionSheet animated:YES completion:nil];
}



- (void)currentProjectViewDidTouchCloseButton:(SWCurrentProjectView *)view
{
    //[filesModel() closeDocument];
    [filesModel().fileSource setProjectSources:nil];
    
    SWRevealViewController *revealController = self.revealViewController;
    [revealController setFrontViewPosition:FrontViewPositionRightMostRemoved animated:YES];
}

@end
