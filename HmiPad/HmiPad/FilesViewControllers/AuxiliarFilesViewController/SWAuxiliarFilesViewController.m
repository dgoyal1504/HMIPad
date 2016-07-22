//
//  SWAuxiliarFilesViewController.m
//  HmiPad
//
//  Created by Joan on 08/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "SWAuxiliarFilesViewController.h"

#import "AppModelFilesEx.h"
#import "AppModelFilePaths.h"
#import "AppModelSource.h"
#import "AppModelDocument.h"
#import "AppModelDownloadExamples.h"

#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"

#import "SWImageManager.h"

#import "SWFileViewerCell.h"
#import "SWFileViewerProjectCell.h"
#import "SWFileViewerRemoteProjectCell.h"
#import "SWFileViewerRemoteAssetCell.h"
#import "SWFileViewerRemoteActivationCodeCell.h"
#import "SWFileViewerRemoteRedemptionCell.h"
#import "SWFileViewerProgressView.h"
#import "SWFileViewerSimpleCurrentProjectView.h"

#import "SWRevealTableViewCell.h"

#import "SWFileViewerHeaderView.h"
#import "SWTableViewMessage.h"
#import "SWTableSectionHeaderView.h"
#import "SWNavBarTitleView.h"

#import "SWUploadViewController.h"
//#import "SWRedeemViewController.h"

#import "DownloadFromServerController.h"
#import "URLDownloadObject.h"

#import "SWBlockAlertView.h"

#import "QBImagePickerController.h"

#import "ColoredButton.h"
#import "UIViewController+SWSendMailControllerPresenter.h"
#import "SWDropCenter.h"

#import "SKProduct+priceString.h"
#import "UIImage+Resize.h"
#import "SWColor.h"
#import "Drawing.h"


#import "UIView+Additions.h"


#pragma mark
#pragma mark FilesViewController
#pragma mark


NSString *const SWFileViewerNibName = @"SWFileViewerXib";


@class UIAlertController;

//---------------------------------------------------------------------------------------------
@interface SWAuxiliarFilesViewController() <UITableViewDelegate, UITableViewDataSource,
    UIActionSheetDelegate /*UIAlertViewDelegate*/,
    AppFilesModelObserver, AppModelDocumentObserver, AppModelSourceObserver, DocumentModelObserver,
    SWFileViewCellDelegate, SWFileViewerHeaderViewDelegate, SWFileViewerSimpleCurrentProjectViewDelegate,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate,
    QBImagePickerControllerDelegate, SWRevealTableViewCellDataSource, SWRevealTableViewCellDelegate>
{
    SWTableViewMessage *messageView;
    SWFileViewerHeaderView *headerView;
    CGFloat initialHeaderViewHeight;
    UIImage *backImage;
    UIActionSheet *_actionSheet;
    UIAlertController *_alertController;
    NSArray *iCloudResults;
    NSMutableSet *selectedSet;
    NSMutableSet *pendingSelectedSet;
    NSIndexPath *selectedIndexPath;
    NSIndexPath *_revealedIndexPath;
    
    BOOL isShowingHeader;
    BOOL isOpeningDocument;
    BOOL buttonsAreShown;
    //BOOL _sectionProjectShown;
    UIBarButtonItem *_savedLeftButonItem;
    UITableView *_tableView;
    UIToolbar *_toolbar;
    NSArray *_toolbarItems;
    NSArray *_toolbarItemsProgress;
    UIRefreshControl *_refreshControl;
    UIBarButtonItem *addButtonItem;
    UIBarButtonItem *reloadButtonItem;
    UIBarButtonItem *actionButtonItem;
    SWFileViewerProgressView *progressViewItem;
    UIBarButtonItem *trashButtonItem;
    FileCategory fileCategory;
    SWDocumentModel *_docModel;
    BOOL isRunOnly;
    BOOL isICloud;
    //NSString *_renamingFileName;
    UIImage *_placeholderImage;
    UINib *_nib;
    
    UIPopoverController *_popoverController;
    SWFileViewerSimpleCurrentProjectView *_currentProjectView;
}

//@property (nonatomic,retain) UIActionSheet *actionSheet;

@end




//---------------------------------------------------------------------------------------------
@implementation SWAuxiliarFilesViewController
{
   // NSInteger _leadingFileSection;
    NSInteger _sourceFilesSection;
    NSInteger _totalSectionsInTable;
}

//@synthesize actionSheet;

#pragma mark Constants

#define RowHeight 70
#define RowHeightProject /*80*/ 90
#define RowHeightAsset /*80*/ 90
#define RowHeightDatabase /*80*/ 90
#define RowHeightLeading 124
#define RowHeightRemoteProject /*84*/ 100
#define RowHeightRemoteAsset /*84*/ 100
#define RowHeightActivationCode /*110*/ 120
#define RowHeightRedemption /*90*/ 110

//---------------------------------------------------------------------------------------------
//enum sectionsInTable
//{
//    kSourceFilesSection = 0,
//    TotalSectionsInTable,
//};

enum rowsInLeadingFileSection
{
    kFirstLeadingFileRow = 0,
    TotalRowsInLeadingFileSection,
};

enum rowsInSourceFilesSection
{
    kFirstSourceFileRow = 0
};


//---------------------------------------------------------------------------------------------
enum
{
    actionRefreshAction = 1,
    actionShareAction,
    actionTrashAction,
    actionCloseAction,
    actionAddAction,
};





#pragma mark Metodes depenents de categoria

//---------------------------------------------------------------------------------------------
- (NSString*)baseTitle
{
    if ( fileCategory == kFileCategorySourceFile ||
        fileCategory == kFileCategoryRecipe ||
        fileCategory == kFileCategoryAssetFile ||
        fileCategory == kFileCategoryDatabase)
            return NSLocalizedString(@"Local Files",nil);
    
//    else if ( fileCategory == kFileCategoryRedeemedSourceFile )
//        return NSLocalizedString(@"Redeemed Files",nil);

    else if ( fileCategory == kFileCategoryRemoteSourceFile ||
        fileCategory == kFileCategoryRemoteAssetFile ||
        fileCategory == kFileCategoryRemoteActivationCode ||
        fileCategory == kFileCategoryRemoteRedemption )
            return NSLocalizedString(@"Integrators Service",nil);
    
    else if ( fileCategory == kExtFileCategoryITunes )
        return NSLocalizedString(@"iTunes File Sharing",nil);
    
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)secondaryTitle
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"Projects",nil); 
    else if ( fileCategory == kFileCategoryRecipe ) return NSLocalizedString(@"Recipes",nil);
    else if ( fileCategory == kFileCategoryAssetFile ) return NSLocalizedString(@"Assets",nil);
    else if ( fileCategory == kFileCategoryDatabase ) return NSLocalizedString(@"Databases",nil);
    
    //else if ( fileCategory == kFileCategoryRedeemedSourceFile ) return NSLocalizedString(@"Projects",nil);
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return NSLocalizedString(@"Projects",nil);
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return NSLocalizedString(@"Assets",nil);
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return NSLocalizedString(@"Activation Codes",nil);
    else if ( fileCategory == kFileCategoryRemoteRedemption ) return NSLocalizedString(@"Redemptions",nil);
    
    else if ( fileCategory == kExtFileCategoryITunes ) return NSLocalizedString(@"Files",nil);
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)footerText
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(HMiPadDev?@"SelectSourceFiles":@"SelectSourceFilesR" ,nil);
    else if ( fileCategory == kFileCategoryRecipe ) return NSLocalizedString(@"SelectRecipeFiles",nil);     // localitzar ?
    else if ( fileCategory == kFileCategoryAssetFile ) return NSLocalizedString(@"SelectDocumentFiles",nil);
    else if ( fileCategory == kFileCategoryDatabase ) return NSLocalizedString(HMiPadDev?@"SelectDatabases":@"SelectDatabasesR",nil);
    
    //else if ( fileCategory == kFileCategoryRedeemedSourceFile) return NSLocalizedString(@"SelectRedeemedSourceFiles" ,nil);
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return NSLocalizedString(@"SelectRemoteSourceFiles",nil);
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return NSLocalizedString(@"SelectRemoteAssetsFiles",nil);
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return NSLocalizedString(@"SelectRemoteActivationCodes",nil);
    else if ( fileCategory == kFileCategoryRemoteRedemption ) return NSLocalizedString(@"SelectRemoteRedemptions",nil);
    
    else if ( fileCategory == kExtFileCategoryITunes ) return NSLocalizedString(@"SelectITunesFiles",nil); 
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)emptyFooterTitile
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"No Projects" ,nil); 
    else if ( fileCategory == kFileCategoryRecipe ) return NSLocalizedString(@"No Files",nil);     // localitzar ?
    else if ( fileCategory == kFileCategoryAssetFile ) return NSLocalizedString(@"No Files",nil);
    else if ( fileCategory == kFileCategoryDatabase ) return NSLocalizedString(@"No Files",nil);
    
    //else if ( fileCategory == kFileCategoryRedeemedSourceFile) return NSLocalizedString(@"SelectRedeemedSourceFiles" ,nil);
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return NSLocalizedString(@"No Projects",nil);
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return NSLocalizedString(@"No Files",nil);
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return NSLocalizedString(@"No Activation Codes",nil);
    else if ( fileCategory == kFileCategoryRemoteRedemption ) return NSLocalizedString(@"No Redemptions",nil);
    
    else if ( fileCategory == kExtFileCategoryITunes ) return NSLocalizedString(@"No Files",nil);
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)emptyFooterText
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(HMiPadDev?@"EmptySelectSourceFiles":@"EmptySelectSourceFilesR" ,nil);
//    else if ( fileCategory == kFileCategoryRecipe ) return NSLocalizedString(@"SelectRecipeFiles",nil);     // localitzar ?
//    else if ( fileCategory == kFileCategoryAssetFile ) return NSLocalizedString(@"SelectDocumentFiles",nil);
//    
//    else if ( fileCategory == kFileCategoryRedeemedSourceFile) return NSLocalizedString(@"SelectRedeemedSourceFiles" ,nil); 
//    
//    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return NSLocalizedString(@"SelectRemoteSourceFiles",nil);
//    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return NSLocalizedString(@"SelectRemoteAssetsFiles",nil);
//    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return NSLocalizedString(@"SelectRemoteActivationCodes",nil);
//    else if ( fileCategory == kFileCategoryRemoteRedemption ) return NSLocalizedString(@"SelectRemoteRedemptions",nil);
//    
//    else if ( fileCategory == kExtFileCategoryITunes ) return NSLocalizedString(@"SelectITunesFiles",nil); 
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)mainSectionTitle
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"CURRENT PROJECT" ,nil);
    //if ( fileCategory == kFileCategoryRedeemedSourceFile ) return NSLocalizedString(@"CURRENT PROJECT" ,nil);
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)secundarySectionTitle
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"PROJECT FILES" ,nil);
    //if ( fileCategory == kFileCategoryRedeemedSourceFile ) return NSLocalizedString(@"PROJECT FILES" ,nil);
    return nil;
}


//---------------------------------------------------------------------------------------------
- (void)setSourceFilesArray:(NSArray*)sourceFiles
{
    if ( fileCategory == kFileCategorySourceFile ) [filesModel().fileSource setProjectSources:sourceFiles];
    //else if ( fileCategory == kFileCategoryRedeemedSourceFile ) [filesModel() setProjectSources:sourceFiles];
    else if ( fileCategory == kFileCategoryAssetFile) [_docModel setFileList:sourceFiles];
}



//---------------------------------------------------------------------------------------------
- (NSArray*)sourceFilesArray
{
    if ( fileCategory == kFileCategorySourceFile )
    {
        return [filesModel().fileSource getProjectSources];
    }
    
    else if ( fileCategory == kFileCategoryAssetFile )
    {
        NSArray *assets = [filesModel().files filesMDArrayForCategory:fileCategory];
        NSArray *fileList = [_docModel fileList];
        NSMutableArray *normalizedList = [NSMutableArray array];
        for ( FileMD *asset in assets )
        {
            NSString *fileName = asset.fileName;
            if ([fileList containsObject:fileName] )
                [normalizedList addObject:fileName];
        }
        return normalizedList;
    }
    
    return nil;
}


//---------------------------------------------------------------------------------------------
- (void)performActionUponSelectingFileMD:(FileMD*)fileMD
{
    if ( fileCategory == kFileCategoryRemoteActivationCode)
    {
        //if ( fileMD.maxProjects == 0 && HMiPadDev )
        if ( [SKProduct isQProduct:fileMD.productSKU] )
        {
            [self presentRedeemControllerForActivationCode:fileMD.accessCode];
        }
        else
        {
            [self presentMailControllerForActivationCodeMD:fileMD];
        }
    }
    
//    else if ( fileCategory == kFileCategorySourceFile )
//    {
//        BOOL selected = [pendingSelectedSet containsObject:fileMD.fileName];
//        if ( HMiPadDev && selected )
//        {
//            UserProfile *profile = [usersModel() currentUserProfile];
//            BOOL isLocal = profile.isLocal;
//            if ( isLocal )
//            {
//                [self presentNewAccountController];
//            }
//            else
//            {
//                [filesModel().fileDocument saveDocumentWithCompletion:^(BOOL success)
//                {
//                    if ( success )
//                        [self presentUploadController];
//                }];
//            }
//        }
//    }
    

    else if ( fileCategory == kFileCategorySourceFile )
    {
        if ( fileMD.isDisabled  )
        {
            if ( HMiPadDev )
            {
            
#if UseCloudKit
                UserProfile *profile = [cloudKitUser() currentUserProfile];
#else
                UserProfile *profile = [usersModel() currentUserProfile]
#endif
                BOOL isLocal = profile.isLocal;
                if ( isLocal )
                {

#if UseCloudKit
                    #warning to do
                    // TO DO : complain (no icloud)
#else
                    [self presentNewAccountController];
#endif
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
        }
        else
        {
            [self updateSourcesArray];
        }
    }
    
    else if ( fileCategory == kFileCategoryAssetFile )
    {
        [self updateSourcesArray];
    }
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile )
    {
        [self _doDownloadProjectAndAssets];
    }
    
    else if ( fileCategory == kFileCategoryRemoteAssetFile )
    {
        [self _doDownloadFiles];
    }
    
}


//---------------------------------------------------------------------------------------------
- (NSArray*)fileMDs
{
    return [filesModel().files filesMDArrayForCategory:fileCategory];
}


//---------------------------------------------------------------------------------------------
- (FileMD*)projectFileMD
{
    return [filesModel().fileDocument currentDocumentFileMD];   // QWE
}


//---------------------------------------------------------------------------------------------
- (FileMD*)fileMDAtIndex:(NSInteger)indx
{
    return [[self fileMDs] objectAtIndex:indx];
}


- (void)deleteFileWithFileMD:(FileMD*)fileMD
{
    return [filesModel().files deleteFileWithFileMD:fileMD forCategory:fileCategory];
}


- (NSString *)cellIdentifier
{
    if ( fileCategory == kFileCategorySourceFile ) return SWFileViewerProjectCellIdentifier;
    else if ( fileCategory == kFileCategoryRecipe ) return @"Joquese";
    else if ( fileCategory == kFileCategoryAssetFile ) return SWFileViewerCellIdentifier;
    else if ( fileCategory == kFileCategoryDatabase ) return SWFileViewerCellIdentifier;
    
//    else if ( fileCategory == kFileCategoryRedeemedSourceFile ) return SWFileViewerProjectCellIdentifier;
    else if ( fileCategory == kFileCategoryEmbeddedAssetFile ) return SWFileViewerCellIdentifier;
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return SWFileViewerRemoteProjectCellIdentifier;
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return SWFileViewerRemoteAssetCellIdentifier;
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return SWFileViewerRemoteActivationCodeCellIdentifier;
    else if ( fileCategory == kFileCategoryRemoteRedemption ) return SWFileViewerRemoteRedemptionCellIdentifier;
    else if ( fileCategory == kExtFileCategoryITunes ) return SWFileViewerCellIdentifier; 
    return nil;
}

- (NSString*)primitiveNibNameForCellWithReuseIdentifier:(NSString*)reuseIdentifier
{
    if ( reuseIdentifier == SWFileViewerProjectCellIdentifier ) return @"SWFileViewerProjectCell";
    //else if ( reuseIdentifier == SWFileViewerCurrentProjectCellIdentifier ) return @"SWFileViewerCurrentProjectCell";
    else if ( reuseIdentifier == SWFileViewerCellIdentifier ) return @"SWFileViewerCell";
    else if ( reuseIdentifier == SWFileViewerRemoteProjectCellIdentifier ) return @"SWFileViewerRemoteProjectCell";
    else if ( reuseIdentifier == SWFileViewerRemoteAssetCellIdentifier ) return @"SWFileViewerRemoteAssetCell";
    else if ( reuseIdentifier == SWFileViewerRemoteActivationCodeCellIdentifier ) return @"SWFileViewerRemoteActivationCodeCell";
    else if ( reuseIdentifier == SWFileViewerRemoteRedemptionCellIdentifier ) return @"SWFileViewerRemoteRedemptionCell";
    else if ( reuseIdentifier == SWFileViewerCellIdentifier ) return @"SWFileViewerCell";
    return nil;
}

- (NSString*)nibNameForCellWithReuseIdentifier:(NSString*)reuseIdentifier
{
    NSString *primitiveIdentifier = [self primitiveNibNameForCellWithReuseIdentifier:reuseIdentifier];
    if ( IS_IOS7 ) return primitiveIdentifier;
    else return [primitiveIdentifier stringByAppendingString:@"6" ];
}

- (NSString*)primitiveNibNameForObjectWithClass:(Class)class
{
    if ( class == [SWFileViewerSimpleCurrentProjectView class] ) return @"SWFileViewerSimpleCurrentProjectView";
    else if ( class == [SWFileViewerHeaderView class] ) return @"SWFileViewerHeaderView";
    else if ( class == [SWFileViewerProgressView class] ) return @"SWFileViewerProgressView";
    return nil;
}

- (NSString*)nibNameForObjectWithClass:(Class)class
{
    NSString *primitiveIdentifier = [self primitiveNibNameForObjectWithClass:class];
    if ( IS_IOS7 ) return primitiveIdentifier;
    else return [primitiveIdentifier stringByAppendingString:@"6" ];
}


#pragma mark - Setup depenent de la categoria

//- (void)configureColoredButton:(UIButton*)button forContext:(NSInteger)context
//{
//    UIColor *tintColor = nil;
//    BOOL enabled = YES;
//    NSString *title = nil;
//    UIImage *image = nil;
//    
//    if ( context == 0 )   // selected
//    {
//        if ( fileCategory == kFileCategorySourceFile )
//        {
//            if ( HMiPadDev )
//            {
//                tintColor = UIColorWithRgb(TheNiceGreenColor);
//                title = @"Activate";
//            }
//            else
//            {
//                image = [UIImage imageNamed:@"forward-25.png"];
//                enabled = NO;
//            }
//        }
//        else
//        {
//            tintColor = UIColorWithRgb(TheNiceGreenColor);
//            title = @"Selected";
//        }
//    }
//    else if ( context == 1 )  // selecting
//    {
//        tintColor = UIColorWithRgb(TheNiceGreenColor);
//        if ( fileCategory == kFileCategorySourceFile ) title = @"Close";   // a canviar
//        else title = @"Selected";
//    }
//    else if ( context == 2 )  // unselected
//    {
//        if ( fileCategory == kFileCategorySourceFile ) title = @"Open";
//        else if ( fileCategory == kFileCategoryRemoteActivationCode ) title = @"Send Mail";
//        else title = @"Select";
//    }
//    else if ( context == 3 )  // unselected special case
//    {
//        if ( fileCategory == kFileCategoryRemoteActivationCode ) title = @"Redeem";
//        else title = @"Select";
//    }
//    else if ( context == 4 )  // unselected special case
//    {
//        if ( fileCategory == kFileCategoryRemoteActivationCode ) title = @"Redeem", enabled = NO;
//        else title = @"Select";
//    }
//    
//    title = NSLocalizedString( title, nil);
//    
//    [button setTintColor:tintColor];
//
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTitle:title forState:UIControlStateNormal];
//    [button setEnabled:enabled];
//}


//- (void)configureIncludeButtonForCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
//{
//    NSInteger context = [self _contextForCell:cell atIndexPath:indexPath];
//    UIButton *button = cell.buttonInclude;
//
//    UIColor *tintColor = nil;
//    UIImage *image = nil;
//    NSString *title = nil;
//    BOOL enabled = NO;
//    
//    [self _buttonPropertiesForContext:context outTitle:&title outImage:&image outTintColor:&tintColor outEnabled:&enabled];
//
//    [button setTintColor:tintColor];
//
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTitle:title forState:UIControlStateNormal];
//    [button setEnabled:enabled];
//}


- (void)configureTickImageForCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    BOOL shown = ( fileCategory == kFileCategoryAssetFile );
    [cell setShouldHideButtonTick:!shown];
    
    if ( !shown )
        return;
    
    NSInteger context = [self _contextForCell:cell atIndexPath:indexPath];
    UIColor *tintColor = nil;
    UIColor *circleColor = nil;
//    if ( context == 0 ) tintColor = UIColorWithRgb(TheNiceGreenColor);  // selected
//    else if ( context == 1 ) tintColor = [UIColor greenColor]; // selecting
//    else if ( context == 2 ) tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];  // unselected
    
    
    if ( context == 0 ) tintColor = UIColorWithRgb(TheNiceGreenColor), circleColor = UIColorWithRgb(TheNiceGreenColor);  // selected
    else if ( context == 1 ) tintColor = [UIColor greenColor], circleColor = [UIColor grayColor]; // selecting previously unselected
    else if ( context == 2 ) tintColor = [UIColor lightGrayColor], circleColor = [UIColor grayColor];  // unselecting previously selected
    else if ( context == 5 ) tintColor = [UIColor grayColor], circleColor = [UIColor grayColor];  // unselected
    
    SWCircleButton *tickView = cell.buttonTick;
    tickView.tintColor = tintColor;
    //tickView.circleView.tintColor = circleColor;
    
    //[tickView lesSubvistes];
    
}


- (void)configureHighlight:(BOOL)shouldHighlight forCell:(UITableViewCell *)cell
{
    //UIColor *backColor = shouldHighlight?[UIColor colorWithWhite:0.96f alpha:1.0f]:[UIColor colorWithWhite:0.90f alpha:1.0f];
    //UIColor *backColor = shouldHighlight?[UIColor colorWithWhite:0.94f alpha:1.0f]:[UIColor colorWithWhite:0.96f alpha:1.0f];
    
    
    UIColor *backColor = shouldHighlight?[UIColor colorWithWhite:0.99f alpha:1.0f]:[UIColor colorWithRed:0.92 green:1 blue:0.92 alpha:1];
    //UIColor *backColor = shouldHighlight?[UIColor colorWithWhite:0.99f alpha:1.0f]:[UIColor colorWithWhite:0.925 alpha:1.0];
    [cell setBackgroundColor:backColor];
}


- (void)configureRevealButtonForCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    BOOL hide = ( fileCategory == kFileCategoryAssetFile );  // el fotem a fora per un tema estetic
    
    [cell setShouldHideButtonReveal:hide];
    
//    UIButton *button = cell.buttonReveal;
//    button.enabled = shown;
//    button.hidden = !shown;
}


- (void)configureRightItemButton:(SWCellButtonItem*)cellItem forCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    UIImage *image = nil;
    NSString *title = NSLocalizedString(@"Delete", nil);
    
    if ( [self _isEnabledIndexPath:indexPath] )
        title = NSLocalizedString(@"Close", nil);
    

    cellItem.backgroundColor = [UIColor redColor];;
    cellItem.title = title;
    cellItem.tintColor = [UIColor whiteColor];
    cellItem.image = image;
    cellItem.width = 75;
}


//- (void)configureLeftItemButtonV:(SWCellButtonItem*)cellItem forCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
//{
//    NSInteger context = [self _contextForCell:cell atIndexPath:indexPath];
//
//    UIColor *backColor = nil;
//    UIImage *image = nil;
//    NSString *title = nil;
//    
//    [self _buttonPropertiesForContext:context outTitle:&title outImage:&image outTintColor:&backColor outEnabled:nil];
//    
//    cellItem.backgroundColor = backColor ? backColor : /*[UIColor colorWithRed:1 green:0.5 blue:0 alpha:1]*/[UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
//    cellItem.title = title;
//    cellItem.tintColor = [UIColor whiteColor];
//    cellItem.image = image;
//    cellItem.width = 75;
//}


- (void)configureLeftItemButton:(SWCellButtonItem*)cellItem forCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    UIColor *backColor = nil;
    UIImage *image = nil;
    NSString *title = nil;
    BOOL enabled = YES;
    
    NSInteger context = [self _contextForCell:cell atIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    FileMD *fileMD = [self fileMDAtIndex:row];
    
    if ( fileCategory == kFileCategoryRemoteActivationCode)
    {
        if ( [SKProduct isQProduct:fileMD.productSKU] )
        {
            title = @"Redeem";
        }
        else
        {
            title = @"Send Mail";
        }
    }
    
    else if ( fileCategory == kFileCategorySourceFile )
    {
        if ( fileMD.isDisabled  )
        {
            if ( HMiPadDev )
            {
            
#if UseCloudKit
                UserProfile *profile = [cloudKitUser() currentUserProfile];
#else
                UserProfile *profile = [usersModel() currentUserProfile];
#endif
                BOOL isLocal = profile.isLocal;
                if ( isLocal ) title = @"Activate";
                else title = @"Activate";
                backColor = UIColorWithRgb(TheNiceGreenColor);
            }
            else
            {
                image = [UIImage imageNamed:@"forward-25.png"];
                enabled = NO;
            }
        }
        else
        {
            title = @"Open Project";
        }
    }
    
    else if ( fileCategory == kFileCategoryAssetFile )
    {
        if ( context == 2 || context == 5 ) title = @"Select Asset";
        else backColor = UIColorWithRgb(TheNiceGreenColor), title = @"Unselect";
    }
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile )
    {
        title = @"Download Project + Assets";
    }
    
    else if ( fileCategory == kFileCategoryRemoteAssetFile )
    {
        title = @"Download Asset";
    }
    
    title = NSLocalizedString( title, nil );
    
    cellItem.backgroundColor = backColor ? backColor : [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
    cellItem.title = title;
    cellItem.tintColor = [UIColor whiteColor];
    cellItem.image = image;
    cellItem.width = 75;
}


- (void)setupCellData:(id<SWFileViewerCellProtocol>)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    FileMD *fileMD = nil;
    NSString *name = nil;
    NSString *ident = nil;
    NSString *date = nil;
    NSString *size = nil;
    UIImage *image = nil;
    BOOL isDisabled = NO;
    
    if ( section == _sourceFilesSection )
    {
        fileMD = [self fileMDAtIndex:row];
    }
    
    
    if ( fileCategory == kFileCategoryRemoteActivationCode )
    {
        SWFileViewerRemoteActivationCodeCell *actCell = (SWFileViewerRemoteActivationCodeCell *)cell;

        name = fileMD.fileName;
        ident = fileMD.accessCode;
        date = fileMD.fileDateString;
        image = [UIImage imageNamed:@"54-lock.png"];
        
        NSString *projectIdString = [fileMD project];
        
        NSArray *redemptions = fileMD.redemptions;
        NSInteger maxRedemptions = fileMD.maxRedemptions;
        
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
        
        [actCell.labelProjectID setText:projectIdString];
        [actCell.labelRedemptions setText:redemptionsString];
    }
    
    else if ( fileCategory == kFileCategoryRemoteRedemption )
    {
        SWFileViewerRemoteRedemptionCell *rdmCell = (SWFileViewerRemoteRedemptionCell *)cell;

        name = fileMD.fileName;
        ident = fileMD.accessCode;
        date = fileMD.fileDateString;
        image = [UIImage imageNamed:@"20-gear-2.png"];
        
        NSString *deviceId = [fileMD deviceIdentifier];
        [rdmCell.labelDeviceIdentifier setText:deviceId];
    }
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile )
    {
        name = fileMD.fileName;
        ident = fileMD.identifier;
        date = fileMD.fileDateString;
        size = fileMD.fileSizeString;
        
        image = [UIImage imageNamed:@"181-hammer.png"];
    }
    
    else if ( fileCategory == kFileCategoryRemoteAssetFile )
    {
        name = fileMD.fileName;
        ident = fileMD.identifier;
        date = fileMD.fileDateString;
        size = fileMD.fileSizeString;
        
        image = [UIImage imageNamed:@"68-paperclip.png"];
    }
    
    else // categories locals
    {
        name = fileMD.fileName;
        ident = fileMD.identifier;
        date = fileMD.fileDateString;
        size = fileMD.fileSizeString;
        isDisabled = fileMD.isDisabled;
    }
    
    [cell.labelFileName setText:name];
    [cell.labelFileIdent setText:ident];
    [cell.labelModDate setText:date];
    [cell.labelSize setText:size];
    //[self configureHighlight:!isDisabled forCell:cell];

    [cell setShouldApplyImageBorder:image==nil];
    
    UIButton *buttonImage = cell.buttonImage;
    
    
    if ( image == nil )
    {
        image = fileMD.thumbnailImage;
    }
    
    if ( image == nil )
    {
        if ( [buttonImage imageForState:UIControlStateNormal] == nil )
        {
            [buttonImage setImage:[self placeholderImage] forState:UIControlStateNormal];
            //[buttonImage setTitle:@"No Image Available" forState:UIControlStateNormal];
        }
    }

    if ( image )
    {
        [buttonImage setImage:image forState:UIControlStateNormal];
    }
    else
    {
        image = [self placeholderImage];
//        if ( imageFullPath == nil )
//            image = [self _defaultImageForFileFullPath:fileMD.fullPath];
        
        [buttonImage setImage:image forState:UIControlStateNormal];
        //[buttonImage setTitle:@"No Image Available" forState:UIControlStateNormal];
        
        NSString *imageFullPath = fileMD.imageFullPath;
        SWImageManager *imageManager = [SWImageManager defaultManager];
        
        if ( fileCategory == kFileCategorySourceFile )
        {
            [imageManager getAsynchronousImageAtPath:imageFullPath
            completionBlock:^(UIImage *aImage)
            {
                if ( aImage != nil )
                    [buttonImage setImage:aImage forState:UIControlStateNormal];
            }];
        }
        else
        {
            if ( imageFullPath == nil )
            {
                image = [self _defaultImageForFileFullPath:fileMD.fullPath];
                [buttonImage setImage:image forState:UIControlStateNormal];
            }
            else
            {
                [imageManager getImageWithOriginalPath:imageFullPath size:CGSizeMake(RowHeight,RowHeight)
                    contentMode:UIViewContentModeScaleAspectFill
                    completionBlock:^(UIImage *aImage)
                {
                    if ( aImage != nil )
                        [buttonImage setImage:aImage forState:UIControlStateNormal];
                }];
            }
        }
    }
    
    //image = [image resizedImageWithContentMode:UIViewContentModeCenter bounds:CGSizeMake(RowHeight,RowHeight) contentScale:image.scale interpolationQuality:kCGInterpolationDefault cropped:NO];

}


- (NSInteger)_contextForCell:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSInteger context = -1;
    NSInteger section = [indexPath section];
    
    if ( section == _sourceFilesSection )
    {
        NSInteger row = [indexPath row];
        FileMD *fileMD = [self fileMDAtIndex:row];
        //[self setSelectedBackgroundWithMultipleSelection:[self supportsMultipleSelectionWhileEditing] forCell:cell];
    
        NSString *name = fileMD.fileName;
        
        if ( [pendingSelectedSet containsObject:name] )
        {
            if ( [selectedSet containsObject:name] )
                context = 0;  // selected
            else
                context = 1;   // selecting previously unselected
        }
        else
        {
            if ( [selectedSet containsObject:name] )
                context = 2;  // unselecting previously selected
            else
                context = 5;  // unselected
        }
        
        if ( fileCategory == kFileCategoryRemoteActivationCode )
        {
            if ( [SKProduct isQProduct:fileMD.productSKU] )
            {
                context = 3 ;
                if (fileMD.pendingRedemptions==0) context = 4;
            }
        }
        

    }
    
    return context;
}


- (void)_buttonPropertiesForContext:(NSInteger)context outTitle:(NSString**)outTitle outImage:(UIImage**)outImage
    outTintColor:(UIColor **)outTintColor  outEnabled:(BOOL*)outEnabled
{
    UIColor *tintColor = nil;
    BOOL enabled = YES;
    NSString *title = nil;
    UIImage *image = nil;
    
    if ( context == 6 )   // selected
    {
        if ( fileCategory == kFileCategorySourceFile )
        {
            if ( HMiPadDev )
            {
                tintColor = UIColorWithRgb(TheNiceGreenColor);
                title = @"Activate Project";
            }
            else
            {
                image = [UIImage imageNamed:@"forward-25.png"];
                enabled = NO;
            }
        }
    }
    
    else if ( context == 0 )
    {
        if ( fileCategory == kFileCategorySourceFile ) title = @"Open Project";
        else title = @"Unselect", tintColor = UIColorWithRgb(TheNiceGreenColor);
    }
    else if ( context == 1 )  // selecting
    {
        tintColor = UIColorWithRgb(TheNiceGreenColor);
        if ( fileCategory == kFileCategorySourceFile ) title = @"Close Project";   // a canviar
        else title = @"Unselect";
    }
    else if ( context == 2 || context == 5 )  // unselected
    {
        if ( fileCategory == kFileCategorySourceFile ) title = @"Open Project";
        else if ( fileCategory == kFileCategoryRemoteActivationCode ) title = @"Send Mail";
        else if ( fileCategory == kFileCategoryRemoteSourceFile ) title = @"Download Project + Assets";
        else if ( fileCategory == kFileCategoryRemoteAssetFile ) title = @"Download Asset";
        else title = @"Select Asset";
    }
    else if ( context == 3 )  // unselected special case
    {
        if ( fileCategory == kFileCategoryRemoteActivationCode ) title = @"Redeem Code", tintColor = UIColorWithRgb(TheNiceGreenColor);
        else title = @"Select";
    }
    else if ( context == 4 )  // unselected special case
    {
        if ( fileCategory == kFileCategoryRemoteActivationCode ) title = @"Redeem Code", enabled = NO;
        else title = @"Select";
    }
    
    title = NSLocalizedString( title, nil);
    
    if ( outTintColor )  *outTintColor = tintColor;
    if ( outTitle ) *outTitle = title;
    if ( outImage ) *outImage = image;
    if ( outEnabled ) *outEnabled = enabled;
}



#pragma mark supporting methods

//---------------------------------------------------------------------------------------------
- (BOOL)supportsSourceFileSelection
{
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    //if ( fileCategory == kFileCategoryRedeemedSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRecipe ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteSourceFile) return YES; //n
    if ( fileCategory == kFileCategoryRemoteAssetFile) return YES;  //n
    if ( fileCategory == kFileCategoryRemoteActivationCode ) return YES;

    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsMultipleSourceFileSelection
{
    if ( fileCategory == kFileCategoryRecipe ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    //if ( fileCategory == kFileCategoryDatabase ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsSelection
{
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsMultipleSelection
{
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsMultipleSelectionWhileEditing
{
    return YES;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsReloadTemplates
{
    if (isRunOnly) return NO;
    
    //if ( fileCategory == kFileCategorySourceFile ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsRefreshGesture
{
    if ( fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteAssetFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteActivationCode ) return YES;
    if ( fileCategory == kFileCategoryRemoteRedemption ) return YES;
    if ( fileCategory == kExtFileCategoryITunes ) return YES;
    
    if ( fileCategory == kFileCategorySourceFile) return YES;
    if ( fileCategory == kFileCategoryAssetFile) return YES;
    if ( fileCategory == kFileCategoryDatabase) return YES;
    
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsLeadingFileSection
{
//    if ( fileCategory == kFileCategorySourceFile ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsAddToolButton
{
    if (isRunOnly) return NO;
    
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    if ( fileCategory == kFileCategoryRecipe ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    return NO;
}


//---------------------------------------------------------------------------------------------
- (BOOL)supportsActionToolButton
{
    if (isRunOnly) return NO;
    
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    if ( fileCategory == kFileCategoryDatabase ) return YES;
    
    if ( fileCategory == kExtFileCategoryITunes ) return YES;
    
    return NO;
}

- (BOOL)supportsActionWhenOpen
{
    if ( fileCategory == kFileCategoryDatabase ) return NO;
    if ( fileCategory == kFileCategorySourceFile ) return NO;
    return [self supportsActionToolButton];
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsDownloadToolButton
{
    if (isRunOnly) return NO;
    
    if ( [self supportsActionToolButton] ) return NO;
    
    if ( fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteAssetFile ) return YES;
    
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsTrashToolButton
{
    if ( fileCategory != kFileCategoryRemoteActivationCode ) return YES;
    return NO;
}

- (BOOL)supportsTrashWhenOpen
{
    if ( fileCategory == kFileCategoryDatabase ) return NO;
    if ( fileCategory == kFileCategorySourceFile ) return NO;
    return [self supportsTrashToolButton];
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsProgressToolView
{
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    
    if ( fileCategory == kFileCategorySourceFile) return YES;

    if ( fileCategory == kFileCategoryRemoteAssetFile ||
        fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    
    return NO;
}




//---------------------------------------------------------------------------------------------
- (BOOL)shouldHideSelectionButton
{
    //if ( fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    //if ( fileCategory == kFileCategoryRemoteAssetFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteRedemption ) return YES;
    
    if ( fileCategory == kExtFileCategoryITunes ) return YES;
    if ( fileCategory == kFileCategoryDatabase ) return YES;
    return NO;
}



#pragma mark Properties

//---------------------------------------------------------------------------------------------
- (UITableView *)tableView
{
    return _tableView;
}

//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageView
{
    if ( messageView == nil )
    {
        messageView = [[SWTableViewMessage alloc] initForTableFooter];
        [messageView setMessage:[self footerText]];
        [messageView setEmptyMessage:[self emptyFooterText]];
        [messageView setEmptyTitle:[self emptyFooterTitile]];
    }
    return messageView;
}


#pragma mark - Private


//- (UINib*)_nib
//{
//    if ( _nib == nil )
//    {
//        _nib = [UINib nibWithNibName:SWFileViewerNibName bundle:nil];
//    }
//    return _nib;
//}
//
//
//- (id)_newFileViewerObjectWithClass:(Class)class
//{
//    id cell = nil;
//    NSLog(@"1");
//    NSArray *objects = [[self _nib] instantiateWithOwner:nil options:nil];
//    for ( id object in objects )
//    {
//        if ( [object isMemberOfClass:class] )   // Member!
//        {
//            cell = object;
//            break;
//        }
//    }
//    
//    NSLog(@"2");
//    return cell;
//}


//- (id)_newFileViewerCellWithReuseIdentifier:(NSString*)identifier
//{
//    id cell = nil;
//    NSLog(@"3");
//    NSArray *objects = [[self _nib] instantiateWithOwner:nil options:nil];
//    for ( SWFileViewerCell *aCell in objects )
//    {
//        if ( [aCell isKindOfClass:[SWFileViewerCell class]] )
//        {
//            //NSLog( @"%@", aCell.reuseIdentifier );
//            if ( [aCell.reuseIdentifier isEqualToString:identifier])
//            {
//                cell = aCell;
//                break;
//            }
//        }
//    }
//    
//    NSLog(@"4");
//    return cell;
//}

//---------------------------------------------------------------------------------------------
- (BOOL)_supportsMultipleSelectionNow
{
    if ( [[self tableView] isEditing] ) return [self supportsMultipleSelectionWhileEditing];
    return [self supportsMultipleSelection]; 
}




- (id)_newFileViewerObjectWithClass:(Class)class
{
    NSString *nibName = [self nibNameForObjectWithClass:class];
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    id anObject = [objects objectAtIndex:0];
    
    NSAssert( [anObject isMemberOfClass:class], @"Inconsistent Class from Nib" );   // Member!

    return anObject;
}


- (id)_newFileViewerCellWithReuseIdentifier:(NSString*)identifier
{
    NSString *nibName = [self nibNameForCellWithReuseIdentifier:identifier];
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    UITableViewCell *aCell = [objects objectAtIndex:0];

    NSAssert( [aCell.reuseIdentifier isEqualToString:identifier], @"Inconsistent Cell Identifier" );

    return aCell;
}


- (SWFileViewerCell *)newfileViewerCellWithReuseIdentifier:(NSString*)identifier;
{
    SWFileViewerCell *cell = nil;
    cell = [self _newFileViewerCellWithReuseIdentifier:identifier];
    return cell;
}


- (SWFileViewerHeaderView *)newHeaderView
{
    SWFileViewerHeaderView *hview = [self _newFileViewerObjectWithClass:[SWFileViewerHeaderView class]];
    return hview;
}


- (SWFileViewerProgressView *)newProgressView
{
    SWFileViewerProgressView *view = [self _newFileViewerObjectWithClass:[SWFileViewerProgressView class]];
    CGSize size = self.view.bounds.size;
    size.width = 320;  // !!
    view.frame = CGRectMake(0, 0, size.width, 44);
    view.backgroundColor = [UIColor clearColor];
    return view;
}


- (SWFileViewerSimpleCurrentProjectView*)newCurrentProjectView
{
    SWFileViewerSimpleCurrentProjectView *currentProjectView = [self _newFileViewerObjectWithClass:[SWFileViewerSimpleCurrentProjectView class]];
        
    ColoredButton *button = currentProjectView.buttonInclude;
    NSString *str1 = @"Close";

    str1 = NSLocalizedString( str1, nil );
    
    if ( [button respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
        [button setRgbTintColor:Theme_RGB(0, 255, 32, 32) overWhite:YES];  // gris clar, str1
        
    [button setTitle:str1 forState:UIControlStateNormal];
    
    return currentProjectView;
}

//-----------------------------------------------------------------------------
- (UIImage *)backImage
{
    if ( backImage == nil )
    {
        CGFloat radius = 1; 
        //UIColor *color = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];   // aqua
        //UIColor *color = [UIColor colorWithRed:0.5 green:0.75 blue:1 alpha:1];   // ~= sky
        //UIColor *color = [UIColor colorWithRed:181.0f/255 green:213.0f/255 blue:1 alpha:1];   // selected text
        
        UIColor *color = [UIColor colorWithRed:0.88 green:0.92 blue:0.98 alpha:1];   // selected text
        UIImage *image = glossyImageWithSizeAndColor( CGSizeMake(radius*2+2, 44), [color CGColor], NO, NO, radius, 1 /*2*/ );
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, radius+1, 0, radius+1)];
        backImage = image;
    }
    return backImage;
}


- (UIImage *)placeholderImageV
{
    if ( _placeholderImage == nil )
    {
        CGFloat radius = 0;
        UIColor *color = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1];
        UIImage *image = glossyImageWithSizeAndColor( CGSizeMake(RowHeight, RowHeight), [color CGColor], NO, NO, radius, 1 );
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


//-----------------------------------------------------------------------------
- (void)setSelectedBackgroundWithMultipleSelection:(BOOL)multipleSelect forCell:(UITableViewCell *)cell
{
    if ( multipleSelect )
    {
//        UIImageView *selView = [[UIImageView alloc] initWithImage:[self backImage]];
//        [cell setMultipleSelectionBackgroundView:selView];
        
        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        selectionView.backgroundColor = UIColorWithRgb(MultipleSelectionColor);
        [cell setMultipleSelectionBackgroundView:selectionView];
    }
}


////---------------------------------------------------------------------------------------------
//- (NSArray *)indexPathsForSelectedRows
//{
//    NSArray *indexPaths = nil;
//    UITableView *table = [self tableView];
//    if ( [table respondsToSelector:@selector(indexPathsForSelectedRows)] ) 
//    {
//        indexPaths = [table indexPathsForSelectedRows];
//    }
//    else 
//    {
//        NSIndexPath *indexPath = [table indexPathForSelectedRow];
//        if ( indexPath ) indexPaths = [NSArray arrayWithObject:indexPath];  // < iOS 5.0
//    }
//    return indexPaths;
//}


//---------------------------------------------------------------------------------------------
- (NSArray *)indexPathsForSelectedRows
{
    UITableView *table = [self tableView];
    NSArray *indexPaths = [table indexPathsForSelectedRows];
    return indexPaths;
}



//---------------------------------------------------------------------------------------------
- (NSArray *)fileMDsForSelectedRows   // inSourceFilesSection
{
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSArray *fileMDs = [self fileMDs];
    
    NSArray *indexPaths = _revealedIndexPath ? @[_revealedIndexPath] : [self indexPathsForSelectedRows];
    
    for ( NSIndexPath *indexPath in indexPaths )
    {
        NSInteger section = [indexPath section];
        if ( section == _sourceFilesSection )
        {
            NSInteger row = [indexPath row];
            FileMD *fileMD = [fileMDs objectAtIndex:row];
            [files addObject:fileMD];
        }
    }
    return files;
}
////---------------------------------------------------------------------------------------------
//- (NSArray *)indexPathsForSourceFiles
//{
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//    NSArray *filenames = [self fileNames];
//
//    int count = [filenames count];
//    for ( int i=0; i<count; i++ )
//    {
//        NSString *fileName = [filenames objectAtIndex:i];
//        if ( [tmpSourcesArray containsObject:fileName] )
//        {
//            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:kSourceFilesSection];
//            [indexPaths addObject:path];
//        }
//    }
//    
//    return indexPaths;
//}

//---------------------------------------------------------------------------------------------
- (void)setSelectionSettings
{
    UITableView *table = [self tableView];
    
    [table setAllowsSelection:[self supportsSelection]];
    [table setAllowsMultipleSelection:[self supportsMultipleSelection]];
    
    [table setAllowsSelectionDuringEditing:YES];
    [table setAllowsMultipleSelectionDuringEditing:[self supportsMultipleSelectionWhileEditing]];
}


#pragma mark Convenience methods

//---------------------------------------------------------------------------------------------
- (void)establishRightBarButtonItemsAnimated:(BOOL)animated
{
    UIBarButtonItem *buttonItem = nil;
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];
    BOOL isEditing = [self isEditing];
    if ( [[self fileMDs] count] == 0 )
    {
        if ( isEditing ) 
        {
            [self setEditing:NO animated:animated]; // focem fora de edicio i tornem
            return;
        }
    }
    else 
    {
        buttonItem = [self editButtonItem];
        [items addObject:buttonItem];
    }
    
//    if ( NO )
//    {
//        NSArray *segmentItems = [NSArray arrayWithObjects:[UIImage imageNamed:@"folderWhite30.png"], [UIImage imageNamed:@"iCloudWhite30.png"], nil];
//        //NSArray *segmentItems = [NSArray arrayWithObjects:@"folder", @"iCloud", nil];
//
//        UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems:segmentItems];
//        [segmented setSegmentedControlStyle:UISegmentedControlStyleBar];
//        [segmented addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
//        [segmented setSelectedSegmentIndex:0];
//        //[segmented setEnabled:NO forSegmentAtIndex:1];
//        
//        UIColor *color= [[[self navigationController] navigationBar] tintColor];
//        [segmented setTintColor:color];
//        [segmented setSelectedSegmentIndex:(isICloud?1:0)];
//        //[[self navigationItem] setTitleView:segmented];
//    
//        UIBarButtonItem *btItem = [[UIBarButtonItem alloc] initWithCustomView:segmented];
//        [items addObject:btItem];
//
//        [[self navigationItem] setRightBarButtonItems:items animated:animated]; 
//    }
//    
//    else
//    {
        [[self navigationItem] setRightBarButtonItem:buttonItem animated:animated];
//    }
}


- (void)establishToolbarItems
{
    // afegim els items al toolbar
    
    NSMutableArray *toolBarItems = [NSMutableArray array];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // add
    if ( [self supportsAddToolButton] )
    {
        addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
        [toolBarItems addObjectsFromArray:@[addButtonItem, space]];
    }
    
    // reload
    if ( [self supportsReloadTemplates] )
    {
        reloadButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
        [toolBarItems addObjectsFromArray:@[reloadButtonItem, space]];
    }
    
    // action
    if ( [self supportsActionToolButton] )
    {
        actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    }
    else if ( [self supportsDownloadToolButton] )
    {
        actionButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download2-25.png"]
            style:UIBarButtonItemStylePlain target:self action:@selector(shareAction:)];
    }
    
    if ( actionButtonItem ) [toolBarItems addObjectsFromArray:@[actionButtonItem, space]];
    
    // trash
    if ( [self supportsTrashToolButton] )
    {
        trashButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashAction:)];
        if ( toolBarItems.count == 0 )
            [toolBarItems addObject:space];  // si no hi ha cap mes item volem la paperera a la dreta.
        
        [toolBarItems addObjectsFromArray:@[trashButtonItem, space]];
    }
    
    if ( toolBarItems.count > 0 )
        [toolBarItems removeLastObject];
    
    _toolbarItems = toolBarItems;
    
    if ( [self supportsProgressToolView] )
    {
        progressViewItem = [self newProgressView];
        progressViewItem.alpha = 0.0f;   // <<-- aqui no va, ho he posat tambe al will appear
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:progressViewItem];
        _toolbarItemsProgress = [NSArray arrayWithObjects:space, barItem, space, nil];
    }
    
    [_toolbar setItems:_toolbarItems];

}


//---------------------------------------------------------------------------------------------
- (void)establishActionButtons
{
    BOOL enable = NO;
    if ( [self isEditing] )
    {
        NSArray *indexPaths = [self indexPathsForSelectedRows];
        enable = [indexPaths count]>0;
    }
    
    BOOL enableTrash = enable ;
    BOOL enableAction = enable ;
    
    [trashButtonItem setEnabled:enableTrash];
    [actionButtonItem setEnabled:enableAction];

}

//---------------------------------------------------------------------------------------------
- (void)establishSegmentedOptionHeader
{
    FileSortingOption sorting = [filesModel().files fileSortingOptionForCategory:fileCategory];

    if ( sorting != kFileSortingOptionAny )
    {
        NSInteger option = 0 ;
        if ( sorting == kFileSortingOptionDateDescending ) option = 0;
        if ( sorting == kFileSortingOptionNameAscending ) option = 1;
        [headerView setSegmentedValue:option];
    }
}

//---------------------------------------------------------------------------------------------
- (void)establishReloadButton
{
    BOOL enable = NO;
    if ( isICloud ) 
    {
        enable = YES;
    }
    else 
    {
        enable = [self supportsReloadTemplates];
    }
    [reloadButtonItem setEnabled:enable];
}

//---------------------------------------------------------------------------------------------
// sobregrabada per suportar editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:animated];

    [self establishRightBarButtonItemsAnimated:NO];
    [self establishActionButtons];
}


//---------------------------------------------------------------------------------------------
- (void)establishConfirmButton:(BOOL)putIt animated:(BOOL)animated
{
    //if ( [defaults() deviceIsIpad] )
    {
        UIBarButtonItem *button = nil;
        if ( putIt )
        {
            //button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doSet:)];
            button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Confirm",nil) style:UIBarButtonItemStyleDone target:self action:@selector(doConfirm:)];
                        
            //BarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doSet:)];
            [button setStyle:UIBarButtonItemStyleDone];
        }
        [[self navigationItem] setRightBarButtonItem:button animated:animated];
    }
}


//---------------------------------------------------------------------------------------------
- (void)establishUndoButton:(BOOL)putIt animated:(BOOL)animated
{
    UIBarButtonItem *button = nil;
    if ( putIt )
    {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(doUndo:)];
    }
    
    if ( button == nil )
        button = _savedLeftButonItem;
    
    [[self navigationItem] setLeftBarButtonItem:button animated:animated];
}


- (void)establishActivityIndicator:(BOOL)putIt animated:(BOOL)animated
{
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

//---------------------------------------------------------------------------------------------
- (void)resetSelectedSources
{
    NSArray *selected = [self sourceFilesArray];
    
    selectedSet = nil;
    selectedSet = [[NSMutableSet alloc] initWithArray:selected];
    
    pendingSelectedSet = nil;
    pendingSelectedSet = [[NSMutableSet alloc] initWithArray:selected];
}

//---------------------------------------------------------------------------------------------
- (void)updateSourcesArray
{
    NSArray *selected = [pendingSelectedSet allObjects];
    [self setSourceFilesArray:selected];
}




//---------------------------------------------------------------------------------------------
// recupera i visualitza els fitxers a partir del model
- (void)resetFilesSectionAnimated:(BOOL)animated animateButtons:(BOOL)bAnimated              //**
{
    //recuperem els sources
    [self resetSelectedSources];
    UITableView *table = [self tableView];
    
    // carreguem la secció
    UITableViewRowAnimation tableAnimation = (animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone );
    
    [table beginUpdates];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:_sourceFilesSection];
//    if ( _leadingFileSection >= 0 )
//    {
//        FileMD *fileMD = [self mainFileMD];
//        _sectionProjectShown = ( fileMD != nil );
//        
//        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kFirstLeadingFileRow inSection:_leadingFileSection];
//        //[table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:tableAnimation];
//        [table reloadSections:[NSIndexSet indexSetWithIndex:_leadingFileSection] withRowAnimation:tableAnimation];
//    }
//
//    // no va, bug al redibuixar el footerView de la seccio, amb animationNone tampoc va.
    [table reloadSections:indexSet withRowAnimation:tableAnimation];

    [table endUpdates];
    
//    if ( animated )
//        [table reloadSections:[NSMutableIndexSet indexSetWithIndex:_sourceFilesSection] withRowAnimation:UITableViewRowAnimationFade];
//    
//    else
//        [table reloadData];
    
    
    [self showHeaderIfNeededAnimated:animated];
    
    
    //[self establishEditButton:YES animated:bAnimated];
    [self establishRightBarButtonItemsAnimated:NO];

    [self establishUndoButton:NO animated:bAnimated];
    buttonsAreShown = NO;
    
    
    /*
    // en lloc de lo anterior fem la animacio explicita a les files una per una
    NSMutableArray *indexPaths = [NSMutableArray array];
    //for ( int i=0, count=[[model() filesArray] count]; i < count; i++ )
    NSInteger section = kSourceFilesSection;
    for ( int i=0, count=[self fileCount]; i < count; i++ )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];   //$$
        [indexPaths addObject:indexPath];
    }
    [[self tableView] reloadRowsAtIndexPaths:indexPaths withRowAnimation:tableAnimation];   //$$
    */
    
    // si no volem animacio aixo també va pero se suposa que te overhead
    //[[self tableView] reloadData];
    
    // amaguem els butons
    //[self establishEditButton:YES animated:bAnimated];
}


//---------------------------------------------------------------------------------------------
- (void)doUndo:(id)sender
{
    // recuperem els sources i fem un reload de la seccio complerta
    [self resetFilesSectionAnimated:NO animateButtons:YES];
}


//---------------------------------------------------------------------------------------------
- (void)doConfirm:(id)sender
{
     // actualitzem el model
    [self updateSourcesArray];
}


//---------------------------------------------------------------------------------------------
- (void)maybeDismissActionSheetAnimated:(BOOL)animated
{
    if ( _actionSheet )
    {
        [_actionSheet dismissWithClickedButtonIndex:[_actionSheet cancelButtonIndex] animated:animated];
        _actionSheet = nil;
    }
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if (IS_IOS8)
    {
        if ( _alertController )
        {
            [_alertController dismissViewControllerAnimated:animated completion:nil];
            _alertController = nil;
        }
    }
    
#endif

}



#pragma mark FilesViewController methods

//---------------------------------------------------------------------------------------------
- (id)initWithFileCategory:(FileCategory)aCategory /*forDocument:(SWDocument *)document*/
{
    self = [super init];
    if ( self )
    {
        fileCategory = aCategory;
        isRunOnly = HMiPadRun?YES:NO;
        
        SWDocument *document = [filesModel().fileDocument currentDocument];
        _docModel = document.docModel;

       _sourceFilesSection = 0;
       _totalSectionsInTable = _sourceFilesSection+1;
       
       [_docModel addObserver:self];
    }
    return self;
}


//---------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_docModel removeObserver:self];
    //NSLog( @"SWAuxiliarFilesViewController: dealloc");
}


//---------------------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}


//---------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = [self view];
    CGRect rect = [view bounds];
    
    SWNavBarTitleView *titleView = [[SWNavBarTitleView alloc] init];
    titleView.mainLabel.text = [self baseTitle];
    titleView.secondaryLabel.text = [self secondaryTitle];
    [titleView sizeToFit];
    UINavigationItem *navItem = self.navigationItem;
    navItem.titleView = titleView;
    _savedLeftButonItem = self.navigationItem.leftBarButtonItem;
    
    CGFloat toolbarHeight = 44;
    
    // crea la taula
    rect.size.height -= toolbarHeight;
    
    UITableViewController *tableViewController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    
    if ( [self supportsRefreshGesture] )
    {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        tableViewController.refreshControl = _refreshControl;
    }
    
    [self addChildViewController:tableViewController];
    
    UIView *tableViewControllerView = tableViewController.view;
    tableViewControllerView.frame = rect;
    [tableViewControllerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [view addSubview:tableViewControllerView];

    _tableView = tableViewController.tableView;
    NSAssert( _tableView==tableViewControllerView, @"Estem assumint tableView == controller.view");

    
     ////
    //_tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    //[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
//    [_tableView setBackgroundColor:DarkenedUIColorWithRgb(SystemDarkerBlueColor,3.0f)];
//    [_tableView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
   // [_tableView setBackgroundColor:[UIColor underPageBackgroundColor]];
   

    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setTableFooterView:[self messageView]];
    
    
    headerView = [self newHeaderView];
    initialHeaderViewHeight = headerView.bounds.size.height;
    [headerView setDelegate:self];
   // [_tableView setTableHeaderView:headerView];
   
//    [_tableView setSeparatorColor:[UIColor colorWithWhite:0.83 alpha:1.0]];    // 0.83
//    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
//    [_tableView setBackgroundColor:[UIColor underPageBackgroundColor]];

    

    if ( [self supportsLeadingFileSection] )
    {
        _currentProjectView = [self newCurrentProjectView];
        [_currentProjectView setDelegate:self];
        [self setupProjectViewData];
        [self setupCurrentProjectViewSelection];
    
        if ( !IS_IPHONE )  // el currentprojectviewcell esta fixe mes amunt que el tableview
        {
            CALayer *layer = _currentProjectView.layer;
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:_currentProjectView.bounds];
            layer.shadowPath = path.CGPath;
            layer.shadowOffset = CGSizeMake(0, 1);
            layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
            layer.shadowRadius = 1 /*3*/ ;
            layer.shadowOpacity = 1;
        
            CGRect tableBounds = _tableView.bounds;
            CGRect projectViewFrame = _currentProjectView.bounds;
            projectViewFrame.size.width = tableBounds.size.width;
        
            if ( IS_IOS7 )
                projectViewFrame.origin.y = 44+20;
        
            _currentProjectView.frame = projectViewFrame;
        
            [view addSubview:_currentProjectView];
            tableBounds.origin.y = projectViewFrame.size.height;
            tableBounds.size.height -= projectViewFrame.size.height;
            _tableView.frame = tableBounds;
        }
    }
    
    // creem el toolbar
    rect.origin.y = rect.size.height;
    rect.size.height = toolbarHeight;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:rect];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    //[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    
    [self establishToolbarItems];
    
    // per ara desabilitem alguns els buttonItems
    [self establishActionButtons];
    [self establishReloadButton];
    
    // afegim com subviews
    //[view addSubview:_tableView];
    [view addSubview:_toolbar];
    
    //[self setDeviceBasedTintColor];
    //[toolbar setDeviceBasedTintColor];

    isICloud = NO;
    
    [self establishRightBarButtonItemsAnimated:NO];
    [self setSelectionSettings];
}



//---------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated 
{
    //NSLog( @"FilesViewController viewWillAppear" );
    [super viewWillAppear:animated];
    
    [self resetSelectedSources];
    [self establishSegmentedOptionHeader];
     progressViewItem.alpha = 0.0f;
    
    buttonsAreShown = NO;
    
//    FileMD *fileMD = [self mainFileMD];
//    _sectionProjectShown = ( fileMD != nil );

    [[self tableView] reloadData];
    [self showHeaderIfNeededAnimated:NO];

    
    [filesModel().files addObserver:self];
    [filesModel().fileDocument addObserver:self];
    [filesModel().fileSource addObserver:self];
    
    //[_docModel addObserver:self];
}

//---------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}


//---------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated 
{
    //NSLog( @"SourcesViewController viewWillDissappear" );
    
   // viewAppeared = NO;
    
    [filesModel().files removeObserver:self];
    [filesModel().fileDocument removeObserver:self];
    [filesModel().fileSource removeObserver:self];

    //[_docModel removeObserver:self];
    [self maybeDismissActionSheetAnimated:animated];
    
	[super viewWillDisappear:animated];
    
}


//---------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated 
{
    //NSLog( @"SourcesViewController viewDidDissappear: %@", [[self navigationController] topViewController] );
    
	[super viewDidDisappear:animated];
    
}



//---------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

//---------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning 
{

    //NSLog( @"FilesViewController didReceiveMemoryWarning" );
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



#pragma mark Table Header




//- (void)showHeaderIfNeededAnimatedV:(BOOL)animated
//{
//    int number = [[self fileMDs] count];
//    BOOL show = (number!=0);
//    
//    if ( show == isShowingHeader)
//        return;
//
//    isShowingHeader = show;
//    //CGRect newFrame = CGRectMake(0, 0, _tableView.bounds.size.width, height);
//
//    [_tableView setTableHeaderView:headerView];
//    
//    NSTimeInterval duration = animated?0.3:0;
//    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut
//    animations:^
//    {
//        //[headerView setFrame:newFrame];
//        [headerView setAlpha:show?1.0:0.0];
//    }
//    completion:nil];
//}


- (void)showHeaderIfNeededAnimated:(BOOL)animated
{
    NSInteger number = [[self fileMDs] count];
    BOOL show = (number!=0);
    
    if ( show == isShowingHeader)
        return;

    isShowingHeader = show;
    //CGRect newFrame = CGRectMake(0, 0, _tableView.bounds.size.width, height);
    
    UIView *theHeader;
    if ( _currentProjectView && IS_IPHONE )    // <- el header es la combinacio del currentProjectView i el headerView
    {
        CGRect frame1 = _currentProjectView.bounds;
        CGRect frame2 = headerView.bounds;
        CGRect frame0 = CGRectMake(0, 0, frame2.size.width, frame1.size.height+frame2.size.height );

        frame2.origin.y = frame1.size.height;

        theHeader = [[UIView alloc] initWithFrame:frame0];
        _currentProjectView.frame = frame1;
        [_currentProjectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_currentProjectView setBackgroundColor:headerView.backgroundColor];   // <- igualem els colors de fons
        headerView.frame = frame2;
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [theHeader addSubview:_currentProjectView];
        [theHeader addSubview:headerView];
    }
    else   // < - el header es nomes el headerView
    {
        theHeader = headerView;
    }

    [_tableView setTableHeaderView:theHeader];
    
    NSTimeInterval duration = animated?0.3:0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut
    animations:^
    {
        //[headerView setFrame:newFrame];
        [theHeader setAlpha:show?1.0:0.0];
    }
    completion:nil];
}



#pragma mark Cell Setup


- (void)setupCellSelection:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [self configureTickImageForCell:cell atIndexPath:indexPath];
}


- (void)setupVisibleCellsSelection
{
    NSArray *visibleCells = [_tableView visibleCells];
    for ( SWFileViewerCell *cell in visibleCells )
    {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        [self setupCellSelection:cell atIndexPath:indexPath];
    }
}


- (void)setupRevealButton:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [self configureRevealButtonForCell:cell atIndexPath:indexPath];
}


- (void)setupCurrentProjectViewSelection
{
    if ( _currentProjectView )
    {
        FileMD *fileMD = [self projectFileMD];
        [_currentProjectView setDisabled:(fileMD==nil)];
    }
}


- (void)setupProjectViewData
{
    if ( _currentProjectView )
    {
        FileMD *fileMD = [self projectFileMD];

        NSString *name = fileMD.fileName;
        NSString *ident = fileMD.identifier;
        NSString *date = fileMD.fileDateString;
        NSString *size = fileMD.fileSizeString;

        [_currentProjectView.labelFileName setText:name];
        [_currentProjectView.labelFileIdent setText:ident];
        [_currentProjectView.labelModDate setText:date];
        [_currentProjectView.labelSize setText:size];
    }
}



- (UIImage*)_defaultImageForFileFullPath:(NSString*)fileFullPath
{
    if ( fileFullPath == nil )
    {
        return [self placeholderImage];
        //return nil;
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




#pragma mark TableView Data Source methods




//---------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return _totalSectionsInTable;
}

//---------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger number = 0;
//    if ( section == _leadingFileSection )
//    {
//        if ( _sectionProjectShown )
//            number = TotalRowsInLeadingFileSection;
//        else
//            number = 0;
//    }
//    else
    if ( section == _sourceFilesSection )
    {
        number = [[self fileMDs] count];
        [[self messageView] showForEmptyTable:(number==0)];
    }
    return number;
}


////---------------------------------------------------------------------------------------------------
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    
//    if ( section == _leadingFileSection )
//        title = [self mainSectionTitle];
//
//    else if ( section == _sourceFilesSection )
//        title = [self secundarySectionTitle];
//    
//    SWTableSectionHeaderView *tvh = nil;
//    if ( title )
//    {
//        tvh = [[SWTableSectionHeaderView alloc] init];
//        tvh.title = title;
//    }
//    return tvh;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    CGFloat height = 0;
//    
//    if ( _sectionProjectShown )
//    {
//    if ( section == _leadingFileSection )
//        title = [self mainSectionTitle];
//
//    else if ( section == _sourceFilesSection )
//        title = [self secundarySectionTitle];
//
//    if ( title )
//        height = 30;
//    }
//    return height;
//}


//---------------------------------------------------------------------------------------------
//static NSString *SourceFilesCellIdentifier = @"SourceFilesCell";
//static NSString *EmptyCellIdentifier = @"EmptyCell";







//---------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    
    //NSInteger row = [indexPath row];
    
    NSInteger section = [indexPath section];
    
    SWFileViewerCell *cell = nil;
//    if ( section == _leadingFileSection )
//    {
//        identifier = SWFileViewerCurrentProjectCellIdentifier;
//        if ( _currentProjectCell == nil )
//        {
//            _currentProjectCell = [self _newFileViewerCellWithReuseIdentifier:identifier];
//            [_currentProjectCell setDelegate:self];
//            [_currentProjectCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
//        }
//        cell = _currentProjectCell;
//    }
//    
//    else
    {
        if ( section == _sourceFilesSection )
        {
            identifier = [self cellIdentifier];
        }
    
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [self _newFileViewerCellWithReuseIdentifier:identifier];
    
            [cell setDelegate:self];
            [cell setDataSource:self];
            
            [cell setAllowsRevealInEditMode:NO];
            
            
//            [cell setBounceBackOnRightOverdraw:NO];
//            [cell setBounceBackOnLeftOverdraw:YES];
            
            [cell setCellRevealMode:SWCellRevealModeReversedWithAction];
            
            //[cell setShouldHideButton:[self shouldHideSelectionButton]];
            [cell setShouldHideButton:YES];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            //[self setSelectedBackgroundWithMultipleSelection:[self supportsMultipleSelectionWhileEditing] forCell:cell];
        }
    }
    
    [self setSelectedBackgroundWithMultipleSelection:[self supportsMultipleSelectionWhileEditing] forCell:cell];
    [self setupCellData:cell atIndexPath:indexPath];
    [self setupRevealButton:cell atIndexPath:indexPath];
    [self setupCellSelection:cell atIndexPath:indexPath];

    return cell;
}





//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSInteger section = [indexPath section];
    
    if ( section == _sourceFilesSection ) return YES;  // fa que desaparegui el disclosure excepte si tenim setHidesAccessoryWhenEditing:NO
    else return NO;

}


//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // fa que no apareguin les barres de moure
}


/*
//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
}
*/

/*
//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

#pragma mark TableView Delegate methods

//---------------------------------------------------------------------------------------------

/*
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

/*
//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    return nil;
}
*/

/*
//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{    
    return 0.0f;
}
*/

/*
//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    return nil;
}


//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
*/

/*
//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

}
*/



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    CGFloat height = 0;
    
//    if ( section == _leadingFileSection )
//        height = RowHeightLeading;
    
    if ( section == _sourceFilesSection )
    {
        height = RowHeight;
        if ( fileCategory == kFileCategorySourceFile ) height = RowHeightProject;
        //else if ( fileCategory == kFileCategoryRedeemedSourceFile ) height = RowHeight;
        else if ( fileCategory == kFileCategoryAssetFile ) height = RowHeightAsset;
        else if ( fileCategory == kFileCategoryDatabase ) height = RowHeightDatabase;
        else if ( fileCategory == kFileCategoryRemoteSourceFile ) height = RowHeightRemoteProject;
        else if ( fileCategory == kFileCategoryRemoteAssetFile ) height = RowHeightRemoteAsset;
        else if ( fileCategory == kFileCategoryRemoteActivationCode ) height = RowHeightActivationCode;
        else if ( fileCategory == kFileCategoryRemoteRedemption ) height = RowHeightRedemption;
        
    }
    return height;
}

//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayCell:(SWFileViewerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldHighlight = [self _isEnabledIndexPath:indexPath];
    [self configureHighlight:shouldHighlight forCell:cell];
}


//---------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldSelect = [self _isEnabledIndexPath:indexPath];
    if ( !shouldSelect )
        return nil;
    
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _isEnabledIndexPath:indexPath];
}


- (BOOL)_isEnabledIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if ( section == _sourceFilesSection )
    {
        FileMD *fileMD = [self fileMDAtIndex:row];
        return !fileMD.isDisabled;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _isEnabledIndexPath:indexPath];
}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger section = [indexPath section];
    if ( section == _sourceFilesSection )
    {
        selectedIndexPath = nil;
        
        BOOL isEditing = [self isEditing];
        if ( isEditing  )
        {
            selectedIndexPath = indexPath;
            [self establishActionButtons];
        }
    }
}


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if ( section == _sourceFilesSection )
    {
        BOOL isMultipleSelec = [self _supportsMultipleSelectionNow];
        if ( isMultipleSelec == NO ) return;
        
        BOOL isEditing = [self isEditing];
        if ( isEditing )
        {
            [self establishActionButtons];
        }
    }
}

/*
//---------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if ( section == kOtherFilesSection ) return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleNone;
}
*/

/*
//---------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView 
                            targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
                            toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
//    int row = [proposedDestinationIndexPath row];
//    if ( row == 0 ) row = 1;
//    return [NSIndexPath indexPathForRow:row inSection:0];
    return proposedDestinationIndexPath;
}
*/

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    return 1;
//
//}

//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}


#pragma mark private

- (void)_saveImageData:(NSData*)imageData withName:(NSString*)fileName
{
    NSString *tmpFilePath = [filesModel().filePaths temporaryFilePathForFileName:fileName];
    [imageData writeToFile:tmpFilePath atomically:YES];

    NSError *error = nil;
    [filesModel().files moveFromTemporaryToCategory:kFileCategoryAssetFile forFile:fileName addCopy:YES error:&error];
}



#pragma mark UIImagePickerController,QBImagePickerControllerDelegate delegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{

    // evitem la interaccio del QBImagePickerController que implementa el mateix delegat
    if ( ![picker isKindOfClass:[UIImagePickerController class]] )
        return;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( image == nil ) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = @"image.png";
    
    [self _saveImageData:imageData withName:fileName];
    
    [self _dismissPicker:picker];
}

- (void)_dismissPicker:(UIViewController*)picker
{
    [_popoverController dismissPopoverAnimated:YES];
    _popoverController = nil;
    
    if ( picker.presentingViewController != nil )
        [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self _dismissPicker:picker];
}


#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerControllerDidCancelPicking:(QBImagePickerController *)picker
{
    [self _dismissPicker:picker];
}


- (void)imagePickerController:(QBImagePickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)assets
{
    for ( ALAsset *asset in assets )
    {
        NSLog(@"Selected asset:%@", asset);
        NSLog(@"Selected original asset:%@", [asset originalAsset] );
        
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        CGFloat scale = [assetRepresentation scale];
        UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:scale orientation:UIImageOrientationUp];
        
        NSString *uti = [assetRepresentation UTI];
        NSString *fileName = [assetRepresentation filename];
        
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        
        NSLog( @"uti :%@", uti);
        NSLog( @"filename :%@", fileName);
        
        NSData *imageData = UIImagePNGRepresentation(image);
    
        [self _saveImageData:imageData withName:fileName];
    }
        
    [self _dismissPicker:picker];
}


- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController
{
    return NSLocalizedString(@"Select All", nil);
}

- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController
{
    return NSLocalizedString(@"Deselect All", nil);;
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    NSString *format = NSLocalizedString(@"%d photos",nil);
    return [NSString stringWithFormat:format, numberOfPhotos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    NSString *format = NSLocalizedString(@"%d videos",nil);
    return [NSString stringWithFormat:format, numberOfVideos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    NSString *format = NSLocalizedString(@"%d Photos, %d Videos",nil);
    return [NSString stringWithFormat:format, numberOfPhotos, numberOfVideos];
}

#pragma mark popoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popoverController = nil;
}


#pragma mark AppsFileModelDocumentObserver

- (void)appFilesModelCurrentDocumentChange:(AppModelDocument*)filesDocument
{
    [_docModel removeObserver:self];
    
    SWDocument *document = filesDocument.currentDocument;
    _docModel = document.docModel;
    
    [_docModel addObserver:self];
}


//- (void)appFilesModelCurrentDocumentFileMDWillChange:(AppModelDocument *)filesDocument
//{
//    for ( SWFileViewerCell *cell in _tableView.visibleCells )
//    {
//        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
//        if ( indexPath.section == _sourceFilesSection )
//        {
//            FileMD *fileMD = [self fileMDAtIndex:indexPath.row];
//            if ( fileMD.isDisabled )
//                [self configureHighlight:YES forCell:cell];
//        }
//    }
//}


- (void)appFilesModelCurrentDocumentFileMDDidChange:(AppModelDocument *)filesDocument
{
    [self setupProjectViewData];
    [self setupCurrentProjectViewSelection];
    [self establishActionButtons];
    
    for ( SWFileViewerCell *cell in _tableView.visibleCells )
    {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        BOOL shouldHighlight = [self _isEnabledIndexPath:indexPath];
        [self configureHighlight:shouldHighlight forCell:cell];
    }
}


//- (void)appFilesModelCurrentDocumentChangeNN:(AppModelDocument*)filesDocument
//{
//    [_docModel removeObserver:self];
//    
//    SWDocument *document = filesDocument.currentDocument;
//    _docModel = document.docModel;
//    
//    [self setupProjectViewData];
//    [self setupCurrentProjectViewSelection];
//    
//    [self _updateVisibleCells];
//    
//    [self establishActionButtons];
//    
//    [_docModel addObserver:self];




#pragma mark - AppModelFilesObserver (sources)

- (void)appsFileModelSourcesDidChange:(AppModelSource*)filesSource
{
    [self resetSelectedSources];
}


#pragma mark - AppModelFilesObserver (listing)

// canvis locals

//- (void)appsFileModel:(AppModelFiles *)appModelFiles didUpdateListingForCategory:(FileCategory)category
//{
//    if ( category == fileCategory )
//    {
//        [self _updateVisibleCells];
//    }
//}


- (void)appsFileModel:(AppModelFiles*)appModelFiles didChangeListingForCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        [_refreshControl endRefreshing];
    
        [self resetFilesSectionAnimated:YES animateButtons:NO];
        [self establishSegmentedOptionHeader];
        [self establishActionButtons];
    }
}


//- (void)appsFileModel:(AppModelFiles *)appModelFiles didUpdateFileAtFullPath:(NSString *)fullPath forCategory:(FileCategory)category
//{
//    if ( category == kFileCategorySourceFile && category == fileCategory )
//    {
//        NSString *defaultNameForNew = [filesModel().fileDocument defaultNameForNewProject];
//        NSString *updatingFile = [fullPath lastPathComponent];
//        if ( [updatingFile hasPrefix:[defaultNameForNew stringByDeletingPathExtension]] )
//        {
//            //[self _doRenameFile:updatingFile placeholderText:nil];
//        }
//        else
//        {
//            //[filesModel().fileSource setProjectSources:@[updatingFile]];
//        }
//    }
//}


// canvis remots

- (void)appFilesModel:(AppModelFilesEx *)filesModel willChangeRemoteListingForCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        [self establishActivityIndicator:YES animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError *)error
{
    if ( category == fileCategory )
    {
        [_refreshControl endRefreshing];
        
        [self resetFilesSectionAnimated:YES animateButtons:NO];
        [self establishSegmentedOptionHeader];
        [self establishActionButtons];
        
        if ( error != nil )
        {
            NSString *title = NSLocalizedString(@"Remote Listing Update", nil );
            NSString *message = [error localizedDescription];
            NSString *ok = NSLocalizedString( @"Ok", nil );
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
            [alert show];
        }
    }
}


#pragma mark AppsFileModelObserver (upload)

- (void)appFilesModel:(AppModelFilesEx *)filesModel beginGroupUploadForCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        NSString *text = NSLocalizedString( @"Upload", nil);
        [progressViewItem.labelFile setText:text];
        [progressViewItem.progresView setProgress:0.0f];
        progressViewItem.alpha = 1.0f;
        
        [_toolbar setItems:_toolbarItemsProgress animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel willUploadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        NSString *format = NSLocalizedString( @"Uploading: %@", nil);
        NSString *text = [NSString stringWithFormat:format, fileName];
        [progressViewItem.labelFile setText:text];
    }
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel groupUploadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    if ( category == fileCategory )
    {
        //float progressValue = (float)step/(float)stepCount;
        float progressValue = 0.1f + (float)step*(0.9f/(float)stepCount);
        [progressViewItem.progresView setProgress:progressValue animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel fileUploadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel didUploadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
//if ( category == fileCategory )
    {
        //NSLog( @"Did upload %@", fileName );
        [self establishRightBarButtonItemsAnimated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel endGroupUploadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{
    if ( category == fileCategory )
    {
        NSString *text;
        if ( finished )
            text = NSLocalizedString( @"Upload Complete", nil);
        else
            text = NSLocalizedString( @"Download Error", nil);
        
        [progressViewItem.labelFile setText:text];
    
    
        [progressViewItem.progresView setProgress:1.0f];
        [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            progressViewItem.alpha = 0.0f;
        }
        completion:^(BOOL finsh)
        {
            [_toolbar setItems:_toolbarItems animated:YES];
        }];
    }
}


#pragma mark AppsFileModelObserver (download)

- (void)appFilesModel:(AppModelFilesEx *)filesModel beginGroupDownloadForCategory:(FileCategory)category
{
    //if ( category == fileCategory )
    {
        NSString *text = NSLocalizedString( @"Download", nil);
        [progressViewItem.labelFile setText:text];
        [progressViewItem.progresView setProgress:0.0f];
        progressViewItem.alpha = 1.0f;
        
        [_toolbar setItems:_toolbarItemsProgress animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel willDownloadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    //if ( category == fileCategory )
    {
        NSString *format = NSLocalizedString( @"Downloading: %@", nil);
        NSString *text = [NSString stringWithFormat:format, fileName];
        [progressViewItem.labelFile setText:text];
    }
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel groupDownloadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    //if ( category == fileCategory )
    {
        //float progressValue = (float)step/(float)stepCount;
        float progressValue = 0.1f + (float)step*(0.9f/(float)stepCount);
        [progressViewItem.progresView setProgress:progressValue animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel fileDownloadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel didDownloadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel endGroupDownloadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{

    //if ( category == fileCategory )
    {
        NSString *text;
        if ( finished )
            text = NSLocalizedString( @"Download Complete", nil);
        else
            text = NSLocalizedString( @"Download Error", nil);
        
        [progressViewItem.labelFile setText:text];
    
    
        [progressViewItem.progresView setProgress:1.0f];
        [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            progressViewItem.alpha = 0.0f;
        }
        completion:^(BOOL finsh)
        {
            [_toolbar setItems:_toolbarItems animated:YES];
        }];
    }
}



#pragma mark AppsFileModelObserver (delete)


- (void)appFilesModel:(AppModelFilesEx*)filesModel willDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        //NSLog( @"Will delete %@", fileName );
        [self establishActivityIndicator:YES animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel didDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error
{
    if ( category == fileCategory )
    {
        //NSLog( @"Did delete %@", fileName );
        [self establishRightBarButtonItemsAnimated:YES];
    }
}


#pragma mark SWDocumentModelObserver

// canvi de la seleccio d'arxius en el document
- (void)documentModelFileListDidChange:(SWDocumentModel*)docModel
{
    if ( fileCategory == kFileCategoryAssetFile)
    {
        [self resetFilesSectionAnimated:NO animateButtons:NO];
    }
}


- (void)documentModelSaveCheckpoint:(SWDocumentModel *)docModel
{
    //NSLog( @"Document Model Save Checkpoint" );
    
    [self setupProjectViewData];
    [self setupCurrentProjectViewSelection];
}


- (void)documentModelThumbnailDidChange:(SWDocumentModel *)docModel
{
    NSInteger index = [filesModel().fileDocument currentDocumentFileMDIndex];

    if ( index != NSNotFound )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:_sourceFilesSection];
        id<SWFileViewerCellProtocol> cell = (id)[_tableView cellForRowAtIndexPath:indexPath];
        if ( cell )
            [self setupCellData:cell atIndexPath:indexPath];
    }
}



#pragma mark SWRevealTableViewCellDelegate


- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell willMoveToPosition:(SWCellRevealPosition)position
{
    if ( position != SWCellRevealPositionCenter )
        [self _dismissAllCellsSkippingCell:revealTableViewCell];
}


- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress
{
    [self _dismissAllCellsSkippingCell:revealTableViewCell];
}


- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell didMoveToPosition:(SWCellRevealPosition)position
{
//    if ( position == SWCellRevealPositionCenter ) _revealedIndexPath = nil,NSLog( @"revealCell -:%d %@ %lx", position, _revealedIndexPath, (long)revealTableViewCell );
//    else _revealedIndexPath = [_tableView indexPathForCell:revealTableViewCell],NSLog( @"revealCell +:%d %@ %lx", position, _revealedIndexPath, (long)revealTableViewCell );
}


- (void)_dismissAllCellsSkippingCell:(SWRevealTableViewCell *)revealTableViewCell
{
    for ( SWRevealTableViewCell *cell in _tableView.visibleCells )
    {
        if ( cell == revealTableViewCell )
            continue;
        
        [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
    }
}


#pragma mark SWRevealTableViewCellDataSource

- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWFileViewerCell*)revealTableViewCell
{
    if ( fileCategory == kFileCategoryRemoteActivationCode )
        return nil;
    
    NSMutableArray *items = [NSMutableArray array];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:revealTableViewCell];
    BOOL enabled = [self _isEnabledIndexPath:indexPath];
    BOOL closing = (!enabled && fileCategory == kFileCategorySourceFile);
    BOOL removing = (fileCategory == kFileCategoryRemoteRedemption);
    
    NSString *deleteStr = NSLocalizedString( closing?@"Close":removing?@"Remove":@"Delete", nil);
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:deleteStr handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
    {
        _revealedIndexPath = [_tableView indexPathForCell:cell];
        
        if ( closing ) [self closeAction:item];
        else [self trashAction:item];

        return YES;
    }];

    item1.backgroundColor = closing?[UIColor orangeColor]:[UIColor redColor];
    item1.tintColor = [UIColor whiteColor];
    item1.width = 75;
    
    [items addObject:item1];
    
    if ( !closing && !removing )
    {
        NSString *moreStr = NSLocalizedString( @"More", nil);
        SWCellButtonItem *item3 = [SWCellButtonItem itemWithTitle:moreStr handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            _revealedIndexPath = [_tableView indexPathForCell:cell];

            [self shareAction:item];
 
            return YES;
        }];
    
        item3.backgroundColor = [UIColor grayColor];
        item3.tintColor = [UIColor whiteColor];
        item3.width = 75;
    
        [items addObject:item3];
    }
    
    return items;
}


- (NSArray*)leftButtonItemsInRevealTableViewCell:(SWFileViewerCell *)revealTableViewCell
{
    if ( [self shouldHideSelectionButton] )
        return nil;
    
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:nil handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
    {
        _revealedIndexPath = [_tableView indexPathForCell:cell];
        [self _doIncludeButtonForCell:(id)cell];
        _revealedIndexPath = nil;
        return YES;
    }];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:revealTableViewCell];
    [self configureLeftItemButton:item1 forCell:revealTableViewCell atIndexPath:indexPath];
    
    
//    item1.backgroundColor = buttonInclude.tintColor;  //  [UIColor colorWithRed:0.01 green:0.5 blue:1 alpha:1];
//    item1.tintColor = [UIColor whiteColor];
//    item1.width = 75;
    
    //NSLog( @"left items");
    return @[item1];
}


#pragma mark SWFileViewCellDelegate

- (void)fileViewCellDidTouchRevealButton:(SWFileViewerCell *)cell
{
    SWCellRevealPosition position = cell.revealPosition == SWCellRevealPositionCenter ? SWCellRevealPositionLeft : SWCellRevealPositionCenter;
    [cell setRevealPosition:position animated:YES];
}


// tocat en la cell el boto de seleccio d'arxius
-(void)fileViewCellDidTouchIncludeButton:(SWFileViewerCell*)cell
{
    [self _doIncludeButtonForCell:cell];
}


-(void)fileViewCellDidTouchImageButton:(SWFileViewerCell*)cell
{
    //NSLog( @"fileViewCellDidTouchImageButton" );
}



#pragma mark SWFileViewCurrentProjectDelegate

- (void)simpleCurrentProjectViewDidTouchImageButton:(SWFileViewerSimpleCurrentProjectView *)view
{

}

- (void)simpleCurrentProjectViewDidTouchIncludeButton:(SWFileViewerSimpleCurrentProjectView *)view
{
   [self _doClose];
}




#pragma mark SWFileViewerHeaderViewDelegate

- (void)fileViewerHeaderView:(SWFileViewerHeaderView *)viewerHeader didSelectSegmentAtIndex:(NSInteger)indx
{
    FileSortingOption option = kFileSortingOptionAny;
    if ( indx == 0 ) option = kFileSortingOptionDateDescending;
    if ( indx == 1 ) option = kFileSortingOptionNameAscending;
    [filesModel().files setFileSortingOption:option forCategory:fileCategory];
}




#pragma mark RefreshButton Action

- (void)handleRefresh:(id)sender
{
    //NSLog(@"handle refresh");
    [filesModel().files refreshMDArrayForCategory:fileCategory];
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UISegmentedControl actions
///////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)selectionChanged:(UISegmentedControl*)segmented
 {
    // iCloud
    if ([segmented selectedSegmentIndex] == 1) 
    {
        isICloud = YES;
        
        
        
//        [segmented setEnabled:NO];
        
//        [[navItem rightBarButtonItem] setEnabled:NO];
//        [navItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)] autorelease]];
        
//        [self refresh];
    } 
    else 
    {
        isICloud = NO;
        if (iCloudResults) iCloudResults = nil;
        
//        [navItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)] autorelease]];
    }
    [self establishReloadButton];
//    [documents reloadData];
}



//#if !(__IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)

#pragma mark UIToolbarItem actions

////---------------------------------------------------------------------------------------------
//- (void)refreshAction7:(UIBarButtonItem *)toolBarItem
//{
//    [self maybeDismissActionSheetAnimated:YES];
//    UIActionSheet *actSheet = [[UIActionSheet alloc] 
//            initWithTitle:NSLocalizedString(@"MessageRefreshAction" ,nil)
//            delegate:self
//            cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
////            destructiveButtonTitle:NSLocalizedString( @"Remove Examples", nil )
//            destructiveButtonTitle:nil
//            otherButtonTitles:NSLocalizedString( @"Download Examples", nil ), nil ];
//
//    [actSheet setTag:actionRefreshAction];
//    [actSheet showFromBarButtonItem:toolBarItem animated:YES];
//    _actionSheet = actSheet;
//}
//




////---------------------------------------------------------------------------------------------
//- (void)shareAction7:(id)sender
//{
//    SWCellButtonItem *sourceCellItem = nil;
//    UIBarButtonItem *sourceBarItem = nil;
//    if ( [sender isKindOfClass:[UIBarButtonItem class]]) sourceBarItem = sender;
//    else if ( [sender isKindOfClass:[SWCellButtonItem class]] ) sourceCellItem = sender;
//
//
//    [self maybeDismissActionSheetAnimated:YES];
//    NSString *title = NSLocalizedString(@"MessageShareAction" ,nil);
//    
//    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:title
//                delegate:self
//                cancelButtonTitle:nil
//                destructiveButtonTitle:nil
//                otherButtonTitles:nil ];
//    
//    switch ( fileCategory )
//    {
//        case kFileCategorySourceFile:
//        case kFileCategoryRecipe:
//        case kFileCategoryAssetFile:
//        case kFileCategoryDatabase:
//        {
//           // [actSheet addButtonWithTitle:NSLocalizedString( @"Send To Integrators Server", nil )];
//            if ( fileCategory == kFileCategoryAssetFile )
//                [actSheet addButtonWithTitle:NSLocalizedString( @"Upload to HMI Pad Server", nil )];
//            
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Send Email", nil )];
//            
//#if SWITunesFileSharing
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Send to iTunes", nil )];
//#endif
//            NSArray *indexPaths = sourceBarItem ? [self indexPathsForSelectedRows] : sourceCellItem ? @[_revealedIndexPath] : nil;
//            if ( indexPaths.count == 1 )
//            {
//                [actSheet addButtonWithTitle:NSLocalizedString( @"Rename", nil )];
//                
//                if ( fileCategory == kFileCategoryAssetFile ||
//                     fileCategory == kFileCategoryDatabase )
//                    [actSheet addButtonWithTitle:NSLocalizedString( @"Duplicate", nil )];
//            }
//            
//            break;
//        }
//            
//        case kFileCategoryRemoteSourceFile:
//        {
//            NSArray *indexPaths = sourceBarItem ? [self indexPathsForSelectedRows] : sourceCellItem ? @[_revealedIndexPath] : nil;
//            if ( indexPaths.count == 1 )
//            {
//                [actSheet addButtonWithTitle:NSLocalizedString( @"Download Project File", nil )];
//                [actSheet addButtonWithTitle:NSLocalizedString( @"Download Project+Assets", nil )];
//                [actSheet addButtonWithTitle:NSLocalizedString( @"Download For Testing", nil )];
//            }
//            else
//            {
//                [actSheet addButtonWithTitle:NSLocalizedString( @"Download Project Files", nil )];
//            }
//            break;
//        }
//        
//        case kFileCategoryRemoteAssetFile:
//        {
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Download Assets", nil )];
//            break;
//        }
//        
//        case kExtFileCategoryITunes:
//        {
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Send Email", nil )];
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Move to Local Storage", nil )];
////            [actSheet addButtonWithTitle:NSLocalizedString( @"Move to Projects", nil )];
////            //[actSheet addButtonWithTitle:NSLocalizedString( @"Move to Recipes", nil ) ];
////            [actSheet addButtonWithTitle:NSLocalizedString( @"Move to Assets", nil )];
//            break;
//        }
//    }
//    
//    // cancel
//    [actSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil )];
//    [actSheet setCancelButtonIndex:actSheet.numberOfButtons-1];
//    
//    [actSheet setTag:actionShareAction];
//    
//    if ( sourceBarItem ) [actSheet showFromBarButtonItem:sourceBarItem animated:YES];
//    else if ( sourceCellItem ) [actSheet showFromCellButtonItem:sourceCellItem animated:YES];
//    
//    _actionSheet = actSheet;
//}
//
//

//- (void)closeAction7:(id)sender
//{
//    SWCellButtonItem *sourceCellItem = nil;
//    UIBarButtonItem *sourceBarItem = nil;
//    if ( [sender isKindOfClass:[UIBarButtonItem class]]) sourceBarItem = sender;
//    else if ( [sender isKindOfClass:[SWCellButtonItem class]] ) sourceCellItem = sender;
//
//
//    [self maybeDismissActionSheetAnimated:YES];
//    UIActionSheet *actSheet = [[UIActionSheet alloc] 
//            initWithTitle:NSLocalizedString(@"Close Project" ,nil)
//            delegate:self
//            cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
//            destructiveButtonTitle:NSLocalizedString( @"Yes, Please", nil )
//            otherButtonTitles:nil ];
//    
//    [actSheet setTag:actionCloseAction];
//        
//    if ( sourceBarItem ) [actSheet showFromBarButtonItem:sourceBarItem animated:YES];
//    else if ( sourceCellItem ) [actSheet showFromCellButtonItem:sourceCellItem animated:YES];
//        
//    _actionSheet = actSheet;
//}
//


//- (void)trashAction7:(id)sender
//{
//    SWCellButtonItem *sourceCellItem = nil;
//    UIBarButtonItem *sourceBarItem = nil;
//    if ( [sender isKindOfClass:[UIBarButtonItem class]]) sourceBarItem = sender;
//    else if ( [sender isKindOfClass:[SWCellButtonItem class]] ) sourceCellItem = sender;
//
//
//    [self maybeDismissActionSheetAnimated:YES];
//    UIActionSheet *actSheet = [[UIActionSheet alloc] 
//            initWithTitle:[self _messageTrashAction]
//            delegate:self
//            cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
//            destructiveButtonTitle:NSLocalizedString( @"Yes, Please Delete", nil )
//            otherButtonTitles:nil ];
//    
////    NSString *title = NSLocalizedString(@"Delete", nil);
////    [self _performTrashBlockIfNeededWithWarningTitle:title block:^
////    {
//        [actSheet setTag:actionTrashAction];
//        
//        if ( sourceBarItem ) [actSheet showFromBarButtonItem:sourceBarItem animated:YES];
//        else if ( sourceCellItem ) [actSheet showFromCellButtonItem:sourceCellItem animated:YES];
//        
//        _actionSheet = actSheet;
////    }];
//}
//

- (NSString*)_messageTrashAction
{
    NSString *text = nil;
    
    if ( fileCategory == kFileCategoryRemoteRedemption )
        text = @"MessageTrashRedemptionAction";
    
    if ( text == nil )
        text = @"MessageTrashAction";
    
    return NSLocalizedString(text ,nil);

}


////---------------------------------------------------------------------------------------------
//- (void)addAction7:(UIBarButtonItem *)toolBarItem
//{
//    [self maybeDismissActionSheetAnimated:YES];
//    UIActionSheet *actSheet = nil;
//    NSString *title = NSLocalizedString(@"MessageAddAction" ,nil);
//    //NSString *cancel = NSLocalizedString( @"Cancel", nil );
//    
//    actSheet = [[UIActionSheet alloc] initWithTitle:title 
//        delegate:self
//        cancelButtonTitle:nil
//        destructiveButtonTitle:nil
//        otherButtonTitles:nil];
//        
//    switch ((int)fileCategory)
//    {
//        case kFileCategorySourceFile:
//            [actSheet addButtonWithTitle:NSLocalizedString( @"New Empty Project", nil)];
//            [actSheet addButtonWithTitle:NSLocalizedString( @"New From Template", nil)];
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Download from Server", nil)];
//            break;
//            
//        case kFileCategoryAssetFile:
//            [actSheet addButtonWithTitle:NSLocalizedString( @"From Photo Library (scaled)", nil)];
//            [actSheet addButtonWithTitle:NSLocalizedString( @"From Photo Library (multiple)", nil)];
//            [actSheet addButtonWithTitle:NSLocalizedString( @"From External Server", nil)];
//            break;
//        
//        default:
//            [actSheet addButtonWithTitle:NSLocalizedString( @"Download from Server", nil)];
//            break;
//    }
//    
//    [actSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil )];
//    [actSheet setCancelButtonIndex:actSheet.numberOfButtons-1];
//                
//    [actSheet setTag:actionAddAction];
//    [actSheet showFromBarButtonItem:toolBarItem animated:YES];
//    _actionSheet = actSheet;
//}

//#endif





#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#pragma mark UIToolbarItem actions 8


- (void)refreshAction8:(UIBarButtonItem *)toolBarItem
{
    [self maybeDismissActionSheetAnimated:YES];
    
    NSString *title = NSLocalizedString(@"MessageRefreshAction" ,nil);
    UIAlertController *actSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *anAction = nil;
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download Examples", nil ) style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action) { [self _doReloadExamples]; _revealedIndexPath = nil;}];
    [actSheet addAction:anAction];
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil ) style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) { _revealedIndexPath = nil; }];
    [actSheet addAction:anAction];
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Remove Examples", nil ) style:UIAlertActionStyleDestructive
    handler:^(UIAlertAction *action) { [self _doRemoveExamples]; _revealedIndexPath = nil;}];
    [actSheet addAction:anAction];
    
    UIPopoverPresentationController *popoverPresentationController = actSheet.popoverPresentationController;
    popoverPresentationController.barButtonItem = toolBarItem;
    
    [self presentViewController:actSheet animated:YES completion:nil];
    
    _alertController = actSheet;
}


- (void)shareAction8:(id)sender
{
    SWCellButtonItem *sourceCellItem = nil;
    UIBarButtonItem *sourceBarItem = nil;
    if ( [sender isKindOfClass:[UIBarButtonItem class]]) sourceBarItem = sender;
    else if ( [sender isKindOfClass:[SWCellButtonItem class]] ) sourceCellItem = sender;


    [self maybeDismissActionSheetAnimated:YES];
    NSString *title = NSLocalizedString(@"MessageShareAction" ,nil);
    
    UIAlertController *actSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *anAction = nil;
    
    switch ( fileCategory )
    {
        case kFileCategorySourceFile:
        case kFileCategoryRecipe:
        case kFileCategoryAssetFile:
        case kFileCategoryDatabase:
        {
            if ( fileCategory == kFileCategoryAssetFile )
            {
                anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Upload to HMI Pad Server", nil ) style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) { [self _doUploadFiles]; _revealedIndexPath = nil;}];
                [actSheet addAction:anAction];
             }
            
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Send Email", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doSendMail]; _revealedIndexPath = nil;}];
            [actSheet addAction:anAction];
            
            
#if SWITunesFileSharing
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Send to iTunes", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doSendToITunes]; }];
            [actSheet addAction:anAction];
#endif
            NSArray *indexPaths = sourceBarItem ? [self indexPathsForSelectedRows] : sourceCellItem ? @[_revealedIndexPath] : nil;
            if ( indexPaths.count == 1 )
            {
                anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Rename", nil ) style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) { [self _doRename]; _revealedIndexPath = nil;}];
                [actSheet addAction:anAction];
 
                if ( fileCategory == kFileCategoryAssetFile ||
                     fileCategory == kFileCategoryDatabase )
                {
                    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Duplicate", nil ) style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) { [self _doDuplicate]; _revealedIndexPath = nil;}];
                    [actSheet addAction:anAction];
                }
            }
            
            break;
        }
            
        case kFileCategoryRemoteSourceFile:
        {
            NSArray *indexPaths = sourceBarItem ? [self indexPathsForSelectedRows] : sourceCellItem ? @[_revealedIndexPath] : nil;
            if ( indexPaths.count == 1 )
            {
                anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download Project File", nil ) style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) { [self _doDownloadFiles]; _revealedIndexPath = nil;}];
                [actSheet addAction:anAction];
                
                anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download Project+Assets", nil ) style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) { [self _doDownloadProjectAndAssets]; _revealedIndexPath = nil;}];
                [actSheet addAction:anAction];
                
                anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download For Testing", nil ) style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {[self _doDownloadForTesting]; _revealedIndexPath = nil;}];
                [actSheet addAction:anAction];
            }
            else
            {
                anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download Project Files", nil ) style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) { [self _doDownloadFiles]; _revealedIndexPath = nil;}];
                [actSheet addAction:anAction];
            }
            break;
        }
        
        case kFileCategoryRemoteAssetFile:
        {
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download Assets", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doDownloadFiles]; _revealedIndexPath = nil;}];
            [actSheet addAction:anAction];
            
            break;
        }
        
        case kExtFileCategoryITunes:
        {
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Send Email", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doSendMail]; _revealedIndexPath = nil;}];
            [actSheet addAction:anAction];
            
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Move to Local Storage", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doMoveToDestination]; _revealedIndexPath = nil;}];
            [actSheet addAction:anAction];
            
            break;
        }
    }
    
    // cancel
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil ) style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) { _revealedIndexPath = nil; }];
    [actSheet addAction:anAction];
    
    UIPopoverPresentationController *popoverPresentationController = actSheet.popoverPresentationController;
    if ( sourceBarItem ) popoverPresentationController.barButtonItem = sourceBarItem;
    else if ( sourceCellItem ) popoverPresentationController.cellButtonItem = sourceCellItem;
    
    [self presentViewController:actSheet animated:YES completion:nil];
    
    _alertController = actSheet;
}


- (void)closeAction8:(id)sender
{
    SWCellButtonItem *sourceCellItem = nil;
    UIBarButtonItem *sourceBarItem = nil;
    if ( [sender isKindOfClass:[UIBarButtonItem class]]) sourceBarItem = sender;
    else if ( [sender isKindOfClass:[SWCellButtonItem class]] ) sourceCellItem = sender;

    [self maybeDismissActionSheetAnimated:YES];
    
    NSString *title = NSLocalizedString(@"Close Project" ,nil);

    UIAlertController *actSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *anAction = nil;
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil ) style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) { _revealedIndexPath = nil; }];
    [actSheet addAction:anAction];
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Yes, Please", nil ) style:UIAlertActionStyleDestructive
    handler:^(UIAlertAction *action) { [self _doClose]; _revealedIndexPath = nil; }];
    [actSheet addAction:anAction];
    
    UIPopoverPresentationController *popoverPresentationController = actSheet.popoverPresentationController;
    if ( sourceBarItem ) popoverPresentationController.barButtonItem = sourceBarItem;
    else if ( sourceCellItem ) popoverPresentationController.cellButtonItem = sourceCellItem;
    
    [self presentViewController:actSheet animated:YES completion:nil];
    
    _alertController = actSheet;
}


- (void)trashAction8:(id)sender
{
    SWCellButtonItem *sourceCellItem = nil;
    UIBarButtonItem *sourceBarItem = nil;
    if ( [sender isKindOfClass:[UIBarButtonItem class]]) sourceBarItem = sender;
    else if ( [sender isKindOfClass:[SWCellButtonItem class]] ) sourceCellItem = sender;

    [self maybeDismissActionSheetAnimated:YES];
    
    NSString *title = NSLocalizedString(@"MessageTrashAction" ,nil);
    
    UIAlertController *actSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *anAction = nil;
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil ) style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) { _revealedIndexPath = nil; }];
    [actSheet addAction:anAction];
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Yes, Please Delete", nil ) style:UIAlertActionStyleDestructive
    handler:^(UIAlertAction *action) { [self _doTrash]; _revealedIndexPath = nil;}];
    [actSheet addAction:anAction];

    UIPopoverPresentationController *popoverPresentationController = actSheet.popoverPresentationController;
    if ( sourceBarItem ) popoverPresentationController.barButtonItem = sourceBarItem;
    else if ( sourceCellItem ) popoverPresentationController.cellButtonItem = sourceCellItem;
    
    [self presentViewController:actSheet animated:YES completion:nil];
    
    _alertController = actSheet;
}


#define DownloadFromServerSupported 0


- (void)addAction8:(UIBarButtonItem *)toolBarItem
{
    [self maybeDismissActionSheetAnimated:YES];
    NSString *title = NSLocalizedString(@"MessageAddAction" ,nil);
    
    UIAlertController *actSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *anAction = nil;
    
    switch ((int)fileCategory)
    {
        case kFileCategorySourceFile:
        {
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"New Empty Project", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [filesModel().fileDocument addNewEmptyDocument]; _revealedIndexPath = nil; }];
            [actSheet addAction:anAction];
            
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"New From Template", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self presentExamplesController]; _revealedIndexPath = nil; }];
            [actSheet addAction:anAction];
            
#if DownloadFromServerSupported
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download from Server", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self presentDownloadFromServerControllerForFileCategory:fileCategory]; _revealedIndexPath = nil; }];
            [actSheet addAction:anAction];
#endif
            
            break;
        }
            
        case kFileCategoryAssetFile:
        {
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"From Photo Library (scaled)", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doAddFromImagePicker]; _revealedIndexPath = nil; }];
            [actSheet addAction:anAction];
            
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"From Photo Library (multiple)", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self _doAddFromQBImagePicker]; _revealedIndexPath = nil; }];
            [actSheet addAction:anAction];
            
#if DownloadFromServerSupported
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"From External Server", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self presentDownloadFromServerControllerForFileCategory:fileCategory]; _revealedIndexPath = nil;}];
            [actSheet addAction:anAction];
#endif
            
            break;
        }
        
        default:
        {
        
#if DownloadFromServerSupported
            anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Download from Server", nil ) style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self presentDownloadFromServerControllerForFileCategory:fileCategory]; _revealedIndexPath = nil; }];
            [actSheet addAction:anAction];
#endif
            break;
        }
    }
    
    anAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", nil ) style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) { _revealedIndexPath = nil; }];
    [actSheet addAction:anAction];
    
    [self presentViewController:actSheet animated:YES completion:nil];
    
    UIPopoverPresentationController *popoverPresentationController = actSheet.popoverPresentationController;
    popoverPresentationController.barButtonItem = toolBarItem;
    
    _alertController = actSheet;
}


#endif


//- (void)refreshAction:(UIBarButtonItem *)toolBarItem
//{
//    if ( [self respondsToSelector:@selector(refreshAction8:)] )
//        [self performSelector:@selector(refreshAction8:) withObject:toolBarItem];
//
//    else [self refreshAction7:toolBarItem];
//}
//
//
//- (void)shareAction:(id)sender
//{
//    if ( [self respondsToSelector:@selector(shareAction8:)] )
//        [self performSelector:@selector(shareAction8:) withObject:sender];
//
//    else [self shareAction7:sender];
//}
//
//
//- (void)closeAction:(id)sender
//{
//
//    if ( [self respondsToSelector:@selector(closeAction8:)] )
//        [self performSelector:@selector(closeAction8:) withObject:sender];
//
//    else [self closeAction7:sender];
//}
//
//
//- (void)trashAction:(id)sender
//{
//    if ( [self respondsToSelector:@selector(trashAction8:)] )
//        [self performSelector:@selector(trashAction8:) withObject:sender];
//
//    else [self trashAction7:sender];
//}
//
//
//- (void)addAction:(UIBarButtonItem *)toolBarItem
//{
//    if ( [self respondsToSelector:@selector(addAction8:)] )
//        [self performSelector:@selector(addAction8:) withObject:toolBarItem];
//
//    else [self addAction7:toolBarItem];
//
//}


- (void)refreshAction:(UIBarButtonItem *)toolBarItem
{
    [self refreshAction8:toolBarItem];
}


- (void)shareAction:(id)sender
{
    [self shareAction8:sender];
}


- (void)closeAction:(id)sender
{
    [self closeAction8:sender];
}


- (void)trashAction:(id)sender
{
    [self trashAction8:sender];
}


- (void)addAction:(UIBarButtonItem *)toolBarItem
{
    [self addAction8:toolBarItem];
}



//#pragma mark UIActionSheet Delegate
//
////---------------------------------------------------------------------------------------------
//- (void)actionSheet:(UIActionSheet *)anActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    //NSLog( @"clickedButtonAtIndex: %d", buttonIndex );
//    
//    SWRevealTableViewCell *cell = (id)[_tableView cellForRowAtIndexPath:_revealedIndexPath];
//    [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
//    
//    if ( buttonIndex == [anActionSheet cancelButtonIndex] )
//    {
//        _revealedIndexPath = nil;
//        _actionSheet = nil;
//        return;
//    }
//    
//    NSInteger firstButtonIndex = 0;
//    NSInteger firstOtherButtonIndex = [anActionSheet firstOtherButtonIndex];
//    NSInteger destructiveButtonIndex = [anActionSheet destructiveButtonIndex];
//    
//    NSInteger tag = [anActionSheet tag];
//    
//    // refresh
//    if ( tag == actionRefreshAction )
//    {
//        if ( fileCategory == kFileCategorySourceFile )
//        {
//            if ( buttonIndex == destructiveButtonIndex ) [self _doRemoveExamples];
//            else if ( buttonIndex == firstOtherButtonIndex ) [self _doReloadExamples];
//        }
//    }
//    
//    // share
//    else if ( tag == actionShareAction )
//    {
//        switch ( fileCategory )
//        {
//            case kFileCategorySourceFile:
//            case kFileCategoryRecipe:
//            case kFileCategoryAssetFile:
//            case kFileCategoryDatabase:
//                if ( fileCategory == kFileCategoryAssetFile )
//                {
//                    if ( buttonIndex == firstButtonIndex+0 ) [self _doUploadFiles];
//                    firstButtonIndex += 1;
//                }
//                
//                //if ( buttonIndex == firstButtonIndex ) [self _doSendToCloud];
//                int idx = 0;
//                if ( buttonIndex == firstButtonIndex + idx++ ) [self _doSendMail];
//#if SWITunesFileSharing
//                else if ( buttonIndex == firstButtonIndex + idx++ ) [self _doSendToITunes];
//#endif
//                else if ( buttonIndex == firstButtonIndex + idx++ ) [self _doRename];
//                else
//                {
//                    if ( fileCategory == kFileCategoryAssetFile ||
//                     fileCategory == kFileCategoryDatabase )
//                    {
//                        if ( buttonIndex == firstButtonIndex + idx++ ) [self _doDuplicate];
//                    }
//                }
//                break;
//                
//            case kFileCategoryRemoteSourceFile:
//                if ( buttonIndex == firstButtonIndex+0 ) [self _doDownloadFiles];
//                else if ( buttonIndex == firstButtonIndex+1 ) [self _doDownloadProjectAndAssets];
//                else if ( buttonIndex == firstButtonIndex+2 ) [self _doDownloadForTesting];
//                break;
//                
//            case kFileCategoryRemoteAssetFile:
//                if ( buttonIndex == firstButtonIndex+0 ) [self _doDownloadFiles];
//                break;
//    
//            case kExtFileCategoryITunes:
//                if ( buttonIndex == firstButtonIndex+0 ) [self _doSendMail];
//                else if ( buttonIndex == firstButtonIndex+1 ) [self _doMoveToDestination];
////                else if ( buttonIndex == firstButtonIndex+1 ) [self _doMoveToSources];
////                /*else if ( buttonIndex == firstOtherButtonIndex+2 ) [self doMoveToRecipes];*/
////                else if ( buttonIndex == firstButtonIndex+2 ) [self _doMoveToDocuments];
//                break;
//        }
//    }
//    
//    // trash
//    else if ( tag == actionTrashAction )
//    {
//        if ( buttonIndex == destructiveButtonIndex ) [self _doTrash];
//    }
//    
//    // close
//    else if ( tag == actionCloseAction )
//    {
//        if ( buttonIndex == destructiveButtonIndex ) [self _doClose];
//    }
//    
//    // add
//    else if ( tag == actionAddAction )
//    {
//        switch ((int)fileCategory)
//        {
//            case kFileCategorySourceFile:
//                if (buttonIndex == firstButtonIndex)
//                {
//                    [filesModel().fileDocument addNewEmptyDocument];
//                }
//                else if ( buttonIndex == firstButtonIndex + 1 )
//                {
//                    [self presentExamplesController];
//                }
//                else if ( buttonIndex == firstButtonIndex + 2 )
//                {
//                    [self presentDownloadFromServerControllerForFileCategory:fileCategory]; //[self _doDownloadFromServer];
//                }
//                break;
//                
//            case kFileCategoryAssetFile:
//                if (buttonIndex == firstButtonIndex)
//                {
//                    [self _doAddFromImagePicker];
//                }
//                
//                else if ( buttonIndex == firstButtonIndex + 1)
//                {
//                    [self _doAddFromQBImagePicker];
//                }
//                
//                else if ( buttonIndex == firstButtonIndex + 2 )
//                {
//                    [self presentDownloadFromServerControllerForFileCategory:fileCategory];
//                }
//                break;
//                
//            default:
//                if ( buttonIndex == firstButtonIndex )
//                {
//                    [self presentDownloadFromServerControllerForFileCategory:fileCategory]; //[self _doDownloadFromServer];
//                }
//                break;
//        }
//    }
//    
//    _revealedIndexPath = nil;
//    _actionSheet = nil;
//}
//
//
////---------------------------------------------------------------------------------------------
//- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    _actionSheet = nil;
//}


- (void)_dismisPresentedController:(id)sender
{
    UIViewController *presented = [self presentedViewController];
    [presented dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Execution

- (void)_doAddFromImagePicker
{
    UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init] ;
    [pickerViewController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary] ;
    [pickerViewController setAllowsEditing:YES] ;
    [pickerViewController setDelegate:self];
                    
    if ( IS_IPHONE )
    {
        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:pickerViewController animated:YES completion:^
        {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
            target:self action:@selector(_dismisPresentedController:)];
            [pickerViewController.navigationItem setLeftBarButtonItem:buttonItem];
        }];
    }
    else
    {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:pickerViewController];
        [_popoverController setDelegate:self];
        [_popoverController presentPopoverFromBarButtonItem:addButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //NSLog( @"Image Picker" ) ;
    }
}

- (void)_doAddFromQBImagePicker
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = QBImagePickerFilterTypeAllPhotos;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.fullScreenLayoutEnabled = NO;
    imagePickerController.allowsMultipleSelection = YES;

    imagePickerController.limitsMaximumNumberOfSelection = NO;
    //imagePickerController.maximumNumberOfSelection = 6;

    //imagePickerController.contentSizeForViewInPopover = CGSizeMake(320, 480-44);
    imagePickerController.preferredContentSize = CGSizeMake(320, 480-44);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
                    
    //navigationController.contentSizeForViewInPopover = CGSizeMake(320, 480);
                    
    if ( IS_IPHONE )
    {
        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:navigationController animated:YES completion:^
        {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
            target:self action:@selector(_dismisPresentedController:)];
            [imagePickerController.navigationItem setLeftBarButtonItem:buttonItem];
        }];
    }
    else
    {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        //_popoverController.popoverContentSize = CGSizeMake(320, 480);
        [_popoverController setDelegate:self];
        [_popoverController presentPopoverFromBarButtonItem:addButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


- (void)_doIncludeButtonForCell:(SWFileViewerCell*)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
   // [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if ( section == _sourceFilesSection )
    {  
        BOOL supportsSourceSelection = [self supportsSourceFileSelection];
        BOOL supportsMultipleSourceSelection = [self supportsMultipleSourceFileSelection];
        
        if ( supportsSourceSelection )
        {
            FileMD *fileMD = [self fileMDAtIndex:row];
            NSString *name = fileMD.fileName;
            if ( name == nil ) name = fileMD.accessCode;
            
            BOOL selected = [pendingSelectedSet containsObject:name];
            if ( supportsMultipleSourceSelection )
            {
                if ( selected )
                    [pendingSelectedSet removeObject:name]; // unselect
                else
                    [pendingSelectedSet addObject:name];   // select
                
                
                [self setupCellSelection:cell atIndexPath:indexPath];    // nomes ha canviat aquesta celda

                // marquem per veure els butons si cal
                if ( buttonsAreShown == NO )
                {
                    [self establishConfirmButton:YES animated:NO];
                    [self establishUndoButton:YES animated:NO];
                    buttonsAreShown = YES;
                }
                // ^ en el cas de multiple selection el pas al model el fa en el boto confirm
                
            }
            else
            {
                [pendingSelectedSet removeAllObjects]; // unselect all
                [pendingSelectedSet addObject:name];   // select

                [self setupVisibleCellsSelection];
                
                [self performActionUponSelectingFileMD:fileMD];
            }
        }
    }
}


- (void)_doRename
{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSArray *selectedFileMDs = [self fileMDsForSelectedRows];
    if ( selectedFileMDs.count > 0 )
    {
        FileMD *renamingMD = [selectedFileMDs objectAtIndex:0];
        NSString *renamingFileName = renamingMD.fileName;
        BOOL enabled = !renamingMD.isDisabled;
        
        NSString *title = NSLocalizedString(renamingFileName?@"AlertRenameTitle":@"AlertRenameTitle2", nil);
        [self _performActionBlockIfNeededWithWarningTitle:title enabled:enabled block:^
        {
            [self _doRenameFile:renamingFileName placeholderText:renamingFileName];
        }];
    }
}


- (void)_doRenameFile:(NSString*)renamingFileName placeholderText:(NSString*)placeholder
{

        //NSString *shortName = [filesModel() shrinkProjectName:renamingFileName forCategory:fileCategory];
    
        NSString *title = NSLocalizedString(placeholder?@"AlertRenameTitle":@"AlertRenameTitle2", nil);
        NSString *message = NSLocalizedString(placeholder?@"AlertRenameMessage":@"AlertRenameMessage2", nil);
    
        SWBlockAlertView *alertView = [[SWBlockAlertView alloc] initWithTitle:title
            message:message delegate:nil
            cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
            otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.font = [UIFont systemFontOfSize:17];
        textField.textColor = UIColorWithRgb(TextDefaultColor);
        textField.text = [filesModel() shrinkProjectName:placeholder forCategory:fileCategory];;
        
        [alertView setResultBlock:^(BOOL success, NSInteger buttonIndex)
        {
            if ( success )
            {
                NSString *longName = [filesModel() expandProjectName:textField.text forCategory:fileCategory];
                [filesModel().files renameFileWithFileName:renamingFileName toFileName:longName forCategory:fileCategory error:nil];
            }
        }];
        
        //[self _performActionBlockIfNeededWithWarningTitle:title block:^
        //{
            [alertView show];
        //}];
}




- (void)_performActionBlockIfNeededWithWarningTitle:(NSString*)title enabled:(BOOL)enabled block:(void (^)(void))block
{
    if ( block == nil )
        return;
    
    if ( enabled || [self supportsActionWhenOpen] )
        block();
    else
        [self _performBlockIfNeededWithWarningTitle:title block:block];
}

- (void)_performTrashBlockIfNeededWithWarningTitle:(NSString*)title enabled:(BOOL)enabled block:(void (^)(void))block
{
    if ( block == nil )
        return;
    
    if ( enabled || [self supportsTrashWhenOpen] )
        block();
    else
        [self _performBlockIfNeededWithWarningTitle:title block:block];
}


- (void)_performBlockIfNeededWithWarningTitle:(NSString*)title block:(void (^)(void))block
{
    if ( _docModel==nil )
    {
        block();
    }
    else
    {
        NSString *message = NSLocalizedString(@"AlertPerformActionWarning", nil);
        SWBlockAlertView *warningAlert = [[SWBlockAlertView alloc] initWithTitle:title
            message:message delegate:nil
            cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
            otherButtonTitles:NSLocalizedString(@"Close & Perform",nil), nil];
    
        [warningAlert setResultBlock:^(BOOL success0, NSInteger buttonIndex)
        {
            if ( success0 )
            {                
                [filesModel().fileSource setProjectSources:nil];
                block();
            }
        }];

        [warningAlert show];
    }
}


//---------------------------------------------------------------------------------------------
- (void)_doDuplicate
{
    //NSArray *selectedFiles = [self filesForSelectedRows];
    
    NSArray *selectedFileMDs = [self fileMDsForSelectedRows];
    if ( selectedFileMDs.count > 0 )
    {
        NSString *title = NSLocalizedString(@"Duplicate", nil);
        FileMD *selectedMD = [selectedFileMDs objectAtIndex:0];
        NSString *selectedFileName = selectedMD.fileName;
        BOOL enabled = !selectedMD.isDisabled;
    
        [self _performActionBlockIfNeededWithWarningTitle:title enabled:enabled block:^
        {
            [filesModel().files duplicateFileWithFileName:selectedFileName forCategory:fileCategory error:nil];
        }];
    }
}

//---------------------------------------------------------------------------------------------
- (void)_doSendMail
{
    NSArray *attachmentMDs = [self fileMDsForSelectedRows];
    [self presentMailControllerForFiles:attachmentMDs forCategory:fileCategory];
}



//---------------------------------------------------------------------------------------------
- (void)_doSendToICloud
{
// copy to iCloud NO TREURE EL COMENTARI SEGUENT, ARREGLAR !
        /*
        else if ( buttonIndex == firstOtherButtonIndex+1 )
        {
            NSLog ( @"Copy to icloud" );
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *containerID = @"RPSCED3286.com.SweetWilliam.ScadaMobile"; // @"<TEAMID>.<CONTAINER>"; // declared in the com.apple.developer.ubiquity-container-identifiers entitlement
            
            NSURL *iCloudURL = [fileManager URLForUbiquityContainerIdentifier:containerID];
            NSURL *iCloudURLDir = [iCloudURL URLByAppendingPathComponent:@"Sources" isDirectory:YES];
        
        
            
            // cu-cut 
            for ( NSString *fileName in [self fileNames] )
            {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                
                NSString *fullFileName = [self fullPathForFileName:fileName];
                NSURL *fullFileNameURL = [NSURL URLWithString:fullFileName];
                NSURL *iCloudFileURL = [iCloudURLDir URLByAppendingPathComponent:fileName];
            
                //SourceDocument *soDoc = [[SourceDocument alloc] initWithFileURL:fullFileNameURL];  // no va per aqui
        
                SourceDocument *soDoc = nil;
                NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:soDoc];
                //[NSFileCoordinator addFilePresenter:soDoc];
                
                __block NSError *error;
                __block BOOL done = NO;
                [fc coordinateWritingItemAtURL:iCloudFileURL options:NSFileCoordinatorWritingForReplacing error:&error 
                byAccessor:^(NSURL *newURL) 
                {
                    NSFileManager *fm = [NSFileManager defaultManager];
                    done = [fm copyItemAtURL:fullFileNameURL toURL:newURL error:&error];
                } ];
                
                    
                     // s'ha de cridar en una dispatch_queue (no main) i el fitxer ha d'estar monitoritzat per un file presenter ? (o no?)
                     //[fileManager setUbiquitous:YES itemAtURL:fullFileNameURL destinationURL:iCloudFileURL error:&error];
                    
                
                NSLog( @"Done: %d error: %@", done, [error localizedDescription] );
                
                //[NSFileCoordinator removeFilePresenter:soDoc];
                
                //[soDoc release];
                [pool drain];
            
            }
            
            
            
            
            NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            NSArray *sourceURLs = [[NSArray alloc] init];  // han de ser els full paths
            
            __block NSError *error;
            __block BOOL done = NO;
    
            [fc prepareForReadingItemsAtURLs:sourceURLs options:(NSFileCoordinatorReadingWithoutChanges) 
            writingItemsAtURLs:nil options:(0) error:&error 
            byAccessor:^( void (^completionHandler)(void) ) 
            {
                //code
                //NSError *innerError;

                for ( NSURL *sourceURL in sourceURLs )
                {
                    done = NO;
                    [fc coordinateReadingItemAtURL:sourceURL options:(NSFileCoordinatorReadingWithoutChanges) error:&error 
                    byAccessor:^(NSURL *newURL) 
                    {
                        //code
                        
                     //   NSFileManager *fm = [NSFileManager defaultManager];                           
                     //   done = [fm copyItemAtURL:fullFileNameURL toURL:newURL error:&error];  // arreglar
                        
                        done = YES;
                    } ];
                    if ( done == NO ) break;
                }
        
                if ( done )
                {
                    completionHandler();
                }
        
            } ]; 
            
        }
        */
}


//
//- (FileCategory)categoryForFileName:(NSString*)fileName
//{
//    if ( fileExtensionIsProject(fileName) )
//        return kFileCategorySourceFile;
//    
//    return kFileCategoryAssetFile;
//}



//---------------------------------------------------------------------------------------------
- (void)_doSendToCategory:(FileCategory)toCategory wantsCopy:(BOOL)wantsCopy
{    
    AppModel *theModel = filesModel();
    NSArray *fileMDsToMove = [self fileMDsForSelectedRows];
    for ( FileMD *fileMD in fileMDsToMove )
    {
        NSString *fileName = fileMD.fileName;
        if ( toCategory == kFileCategoryUnknown )
        {
            toCategory = fileExtensionIsProject(fileName) ? kFileCategorySourceFile : kFileCategoryAssetFile;
            //toCategory = [self categoryForFileName:fileName];
        }

        [theModel.files sendFileWithFileName:fileName withCategory:fileCategory toCategory:toCategory outError:nil];
    }
}


- (void)_doDownloadFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory
{

}


- (void)_doDownloadFiles
{
    AppModel *theModel = filesModel();
    NSArray *fileMDsToDownload = [self fileMDsForSelectedRows];
    
    [theModel.files downloadRemoteFileMDs:fileMDsToDownload forCategory:fileCategory];
}


- (FileMD *)_uniqueSelectedProjectMD
{
    FileMD *projectMD = nil;
    NSArray *fileMDsToDownload = [self fileMDsForSelectedRows];
    if ( fileMDsToDownload.count > 0 ) projectMD = [fileMDsToDownload objectAtIndex:0];
 
    return projectMD;
}


- (void)_doDownloadProjectAndAssets
{
    FileMD *projectMD = [self _uniqueSelectedProjectMD];
    
    if ( projectMD )
    {
        [filesModel().files downloadRemoteProjectMD:projectMD];
    }
}


- (void)_doDownloadForTesting
{
    FileMD *projectMD = [self _uniqueSelectedProjectMD];
    
    if ( projectMD )
    {
        [filesModel().files downloadEmbeddedRemoteProjectMD:projectMD];
    }
    
}

//---------------------------------------------------------------------------------------------
- (void)_doUploadFiles
{
    AppModel *theModel = filesModel();
    NSArray *fileMDsToUpload = [self fileMDsForSelectedRows];
    
    [theModel.files uploadRemoteFileMDs:fileMDsToUpload forCategory:fileCategory];
}

//---------------------------------------------------------------------------------------------
- (void)_doMoveToDestination
{
    [self _performDropEffectWithImageNamed:@"configprofileicon.png"];
    [self _doSendToCategory:kFileCategoryUnknown wantsCopy:NO];
}

////---------------------------------------------------------------------------------------------
//- (void)_doMoveToSources
//{
//    [self _performDropEffectWithImageNamed:@"configprofileicon.png"];
//    [self _doSendToCategory:kFileCategorySourceFile wantsCopy:NO];
//}

//---------------------------------------------------------------------------------------------
- (void)_doMoveToRecipes
{
    [self _performDropEffectWithImageNamed:@"configprofileicon.png"];
    [self _doSendToCategory:kFileCategoryRecipe wantsCopy:NO];
}

////---------------------------------------------------------------------------------------------
//- (void)_doMoveToDocuments
//{
//    [self _performDropEffectWithImageNamed:@"texticon.png"];
//    [self _doSendToCategory:kFileCategoryAssetFile wantsCopy:NO];
//}

//---------------------------------------------------------------------------------------------
- (void)_doSendToITunes
{
    [self _performDropEffectWithImageNamed:@"texticon.png"];
    //[self performDropEffectWithImageNamed:@"genericfile.png"];
    [self _doSendToCategory:kExtFileCategoryITunes wantsCopy:YES];
}



////---------------------------------------------------------------------------------------------
//- (void)_doSendToCloud
//{
//    [self _performDropEffectWithImageNamed:@"texticon.png"];
//    //[self performDropEffectWithImageNamed:@"genericfile.png"];
//    
//    FileCategory toCategory = kFileCategoryUnknown;
//    if ( fileCategory == kFileCategorySourceFile ) toCategory = kFileCategoryRemoteSourceFile;
//    else if ( fileCategory == kFileCategoryAssetFile ) toCategory = kFileCategoryRemoteAssetFile;
//    
//    [self _doSendToCategory:toCategory wantsCopy:YES];
//}


//---------------------------------------------------------------------------------------------
- (void)_doReloadExamples
{
    AppModel *theModel = filesModel();
    [theModel.amDownloadExamples downloadRemoteExamples];
}


//---------------------------------------------------------------------------------------------
- (void)_doRemoveExamples
{
//    AppFilesModel *theModel = filesModel();
//    [theModel deleteFileTemplates];
}


- (void)_doClose
{
    if ( fileCategory == kFileCategorySourceFile)
        [filesModel().fileSource setProjectSources:nil];   // close
}


//---------------------------------------------------------------------------------------------
- (void)_doTrash
{
    NSArray *fileMDsToDelete = [self fileMDsForSelectedRows];
    for ( FileMD *fileMD in fileMDsToDelete )
    {
//        NSString *fileName = fileMD.fileName;
//        [self deleteFileWithFileName:fileName];
        NSString *title = NSLocalizedString(@"Delete", nil);
        BOOL enabled = !fileMD.isDisabled;
        [self _performTrashBlockIfNeededWithWarningTitle:title enabled:enabled block:^
        {
            [self deleteFileWithFileMD:fileMD];
        }];
    }
}


//---------------------------------------------------------------------------------------------
- (void)_performDropEffectWithImageNamed:(NSString*)imageName
{
    if ( NO )  // dont!
    {
        SWDropCenter *dropCenter = [SWDropCenter defaultCenter];
        UIImage *image = [UIImage imageNamed:imageName];
        //UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    
        UINavigationController *navController = [self navigationController];
        UIView *eView = [navController navigationBar];
        CGRect eRect = [eView bounds];
        CGPoint eePoint = CGPointMake(eRect.origin.x+40, eRect.size.height/2);
    
        UIView *bView = [[self tableView] cellForRowAtIndexPath:selectedIndexPath];
        CGRect bRect = [bView bounds];
        CGPoint bbPoint = CGPointMake(bRect.size.width-40, bRect.size.height/2);
    
        [dropCenter dropImage:image fromView:bView point:bbPoint toView:eView point:eePoint];
    }
}


@end

