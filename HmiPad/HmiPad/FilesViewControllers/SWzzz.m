//
//  SWAuxiliarFilesViewController.m
//  HmiPad
//
//  Created by Joan on 08/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SWAuxiliarFilesViewController.h"

//#import "ControlViewCell.h"
#import "SWFileViewerCell.h"
//#import "SWFileViewerCurrentProjectCell.h"
#import "SWFileViewerCurrentProjectView.h"
#import "SWFileViewerProjectCell.h"
#import "SWFileViewerRemoteProjectCell.h"
#import "SWFileViewerRemoteAssetCell.h"
#import "SWFileViewerRemoteActivationCodeCell.h"
#import "SWFileViewerProgressView.h"


#import "SWFileViewerHeaderView.h"
#import "ColoredButton.h"
#import "SWTableViewMessage.h"
#import "SWTableSectionHeaderView.h"
//#import "PdfViewController.h"
#import "SWNavBarTitleView.h"

//#import "SWErrorPresenterViewController.h"
#import "SWUploadViewController.h"
#import "SWUpdateViewController.h"

#import "DownloadFromServerController.h"
#import "URLDownloadObject.h"

#import "AppFilesModel.h"

#import "SWColor.h"
#import "Drawing.h"

#import "SWImageManager.h"

//#import "SendMailController.h"
#import "UIViewController+SWSendMailControllerPresenter.h"
#import "SWDropCenter.h"

//#import "SWModelTypes.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"


#import "UIImage+Resize.h"

#pragma mark
#pragma mark FilesViewController
#pragma mark


NSString *const SWFileViewerNibName = @"SWFileViewerXib";

//---------------------------------------------------------------------------------------------
@interface SWAuxiliarFilesViewController() <UITableViewDelegate, UITableViewDataSource,
    UIActionSheetDelegate, UIAlertViewDelegate,
    AppFilesModelObserver, DocumentModelObserver,
    SWFileViewCellDelegate, SWFileViewerHeaderViewDelegate, SWFileViewerCurrentProjectViewDelegate>
{
    SWTableViewMessage *messageView;
    SWFileViewerHeaderView *headerView;
    //SWFileViewerCurrentProjectCell *_topFileViewerCell;
    UIImage *backImage;
    UIActionSheet *actionSheet;
    NSArray *iCloudResults;
    NSMutableSet *tmpSourcesArray;
    NSMutableSet *pendingSourcesArray;
    NSIndexPath *selectedIndexPath;
    
    BOOL isOpeningDocument;
    BOOL buttonsAreShown;
    BOOL _sectionProjectShown;
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
    BOOL isICloud;
    NSString *_renamingFileName;
    UIImage *_placeholderImage;
    UINib *_nib;
    SWFileViewerCurrentProjectView *_currentProjectView;
}

@property (nonatomic,retain) UIActionSheet *actionSheet;

@end




//---------------------------------------------------------------------------------------------
@implementation SWAuxiliarFilesViewController
{
   // NSInteger _leadingFileSection;
    NSInteger _sourceFilesSection;
    NSInteger _totalSectionsInTable;
}

@synthesize actionSheet;

#pragma mark Constants

#define RowHeight 70
#define RowHeightLeading 124
#define RowHeightRemoteProject 84
#define RowHeightActivationCode 124

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
    actionAddAction,
};


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
        NSString *txt = [self footerText];
        [messageView setMessage:txt];
        [messageView setEmptyTitle:NSLocalizedString(@"No Files", nil)];
    }
    return messageView;
}


#pragma mark Metodes depenents de categoria

//---------------------------------------------------------------------------------------------
- (NSString*)baseTitle
{
    if ( fileCategory == kFileCategorySourceFile ||
        fileCategory == kFileCategoryRecipe ||
        fileCategory == kFileCategoryAssetFile)
            return NSLocalizedString(@"Local Files",nil);
    
    else if ( fileCategory == kFileCategoryRedeemedSourceFile )
        return NSLocalizedString(@"Redeemed Files",nil);

    else if ( fileCategory == kFileCategoryRemoteSourceFile ||
        fileCategory == kFileCategoryRemoteAssetFile ||
        fileCategory == kFileCategoryRemoteActivationCode )
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
    
    else if ( fileCategory == kFileCategoryRedeemedSourceFile ) return NSLocalizedString(@"Projects",nil); 
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return NSLocalizedString(@"Projects",nil);
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return NSLocalizedString(@"Assets",nil);
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return NSLocalizedString(@"Activation Codes",nil);
    
    else if ( fileCategory == kExtFileCategoryITunes ) return NSLocalizedString(@"Files",nil);
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)footerText
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"SelectSourceFiles" ,nil); 
    else if ( fileCategory == kFileCategoryRecipe ) return NSLocalizedString(@"SelectRecipeFiles",nil);     // localitzar ?
    else if ( fileCategory == kFileCategoryAssetFile ) return NSLocalizedString(@"SelectDocumentFiles",nil);
    
    else if ( fileCategory == kFileCategoryRedeemedSourceFile) return NSLocalizedString(@"SelectRedeemedSourceFiles" ,nil); 
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return NSLocalizedString(@"SelectRemoteSourceFiles",nil);
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return NSLocalizedString(@"SelectRemoteAssetsFiles",nil);
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return NSLocalizedString(@"SelectRemoteActivationCodes",nil);
    
    else if ( fileCategory == kExtFileCategoryITunes ) return NSLocalizedString(@"SelectITunesFiles",nil); 
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)mainSectionTitle
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"CURRENT PROJECT" ,nil);
    if ( fileCategory == kFileCategoryRedeemedSourceFile ) return NSLocalizedString(@"CURRENT PROJECT" ,nil);
    return nil;
}

//---------------------------------------------------------------------------------------------
- (NSString*)secundarySectionTitle
{
    if ( fileCategory == kFileCategorySourceFile ) return NSLocalizedString(@"PROJECT FILES" ,nil);
    if ( fileCategory == kFileCategoryRedeemedSourceFile ) return NSLocalizedString(@"PROJECT FILES" ,nil);
    return nil;
}


//---------------------------------------------------------------------------------------------
- (void)setSourceFilesArray:(NSArray*)sourceFiles
{
    if ( fileCategory == kFileCategorySourceFile ) [filesModel() setProjectSources:sourceFiles redeemed:NO];
    else if ( fileCategory == kFileCategoryRedeemedSourceFile ) [filesModel() setProjectSources:sourceFiles redeemed:YES];
    else if ( fileCategory == kFileCategoryAssetFile) [_docModel setFileList:sourceFiles];
}


//---------------------------------------------------------------------------------------------
- (NSArray*)sourceFilesArray
{
    if ( fileCategory == kFileCategorySourceFile ) return [filesModel() getProjectSourcesRedeemed:NO];
    else if ( fileCategory == kFileCategoryRedeemedSourceFile) return [filesModel() getProjectSourcesRedeemed:YES];
    else if ( fileCategory == kFileCategoryAssetFile ) return [_docModel fileList];
    return nil;
}


//---------------------------------------------------------------------------------------------
- (void)performActionUponSelectingFileMD:(FileMD*)fileMD
{
    if ( fileCategory == kFileCategoryRemoteActivationCode)
        [self presentMailControllerForActivationCode:fileMD];
}

////---------------------------------------------------------------------------------------------
//- (NSArray*)fileNames
//{
//    return [filesModel() filesArrayForCategory:fileCategory];
//}

//---------------------------------------------------------------------------------------------
- (NSArray*)fileMDs
{
    return [filesModel() filesMDArrayForCategory:fileCategory];
}

////---------------------------------------------------------------------------------------------
//- (NSString*)fileNameAtIndex:(int)indx
//{
//    return [[filesModel() filesArrayForCategory:fileCategory] objectAtIndex:indx];
//}


//---------------------------------------------------------------------------------------------
- (FileMD*)mainFileMD
{
//    return [filesModel() getExclusiveMDProjectSource];
    return [filesModel() currentDocumentFileMDWithCategory:fileCategory];
}


//---------------------------------------------------------------------------------------------
- (FileMD*)fileMDAtIndex:(int)indx
{
    return [[self fileMDs] objectAtIndex:indx];
}

//---------------------------------------------------------------------------------------------
- (NSString*)originPathForFileName:(NSString*)fileName
{
    //NSString *originPath = [filesModel() fileFullPathForFileName:fileName forCategory:fileCategory];
    NSString *originPath = [filesModel() originPathForFilename:fileName forCategory:fileCategory];
    return originPath;
}

////---------------------------------------------------------------------------------------------
//- (NSString*)fileDateStringForFileName:(NSString*)fileName
//{
//    return [filesModel() fileDateStrForFileName:fileName forCategory:fileCategory];
//}
//
////---------------------------------------------------------------------------------------------
//- (NSString*)fileSizeStringForFileName:(NSString*)fileName
//{
//    return [filesModel() fileSizeStrForFileName:fileName forCategory:fileCategory];
//}

////---------------------------------------------------------------------------------------------
//- (BOOL)deleteFileWithFileName:(NSString*)fileName
//{
//    return [filesModel() deleteFileWithFileName:fileName forCategory:fileCategory error:nil];
//}

- (void)deleteFileWithFileMD:(FileMD*)fileMD
{
    return [filesModel() deleteFileWithFileMD:fileMD forCategory:fileCategory];
}


//- (NSString *)fileViewerNibName
//{
//    if ( fileCategory == kFileCategorySourceFile ) return @"Joquese";
//    else if ( fileCategory == kFileCategoryRecipe ) return @"Joquese";
//    else if ( fileCategory == kFileCategoryAssetFile ) return SWFileViewerNibName;
//    else if ( fileCategory == kExtFileCategoryITunes ) return @"Joquese"; 
//    return nil;
//}



- (NSString *)cellIdentifier
{
    if ( fileCategory == kFileCategorySourceFile ) return SWFileViewerProjectCellIdentifier;
    else if ( fileCategory == kFileCategoryRecipe ) return @"Joquese";
    else if ( fileCategory == kFileCategoryAssetFile ) return SWFileViewerCellIdentifier;
    
    else if ( fileCategory == kFileCategoryRedeemedSourceFile ) return SWFileViewerProjectCellIdentifier;
    else if ( fileCategory == kFileCategoryRedeemedAssetFile ) return SWFileViewerCellIdentifier;
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile ) return SWFileViewerRemoteProjectCellIdentifier;
    else if ( fileCategory == kFileCategoryRemoteAssetFile ) return SWFileViewerRemoteAssetCellIdentifier;
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) return SWFileViewerRemoteActivationCodeCellIdentifier;
    else if ( fileCategory == kExtFileCategoryITunes ) return SWFileViewerCellIdentifier; 
    return nil;
}

- (NSString*)nibNameForCellWithReuseIdentifier:(NSString*)reuseIdentifier
{
    if ( reuseIdentifier == SWFileViewerProjectCellIdentifier ) return @"SWFileViewerProjectCell";
    else if ( reuseIdentifier == SWFileViewerCurrentProjectCellIdentifier ) return @"SWFileViewerCurrentProjectCell";
    else if ( reuseIdentifier == SWFileViewerCellIdentifier ) return @"SWFileViewerCell";
    else if ( reuseIdentifier == SWFileViewerRemoteProjectCellIdentifier ) return @"SWFileViewerRemoteProjectCell";
    else if ( reuseIdentifier == SWFileViewerRemoteAssetCellIdentifier ) return @"SWFileViewerRemoteAssetCell";
    else if ( reuseIdentifier == SWFileViewerRemoteActivationCodeCellIdentifier ) return @"SWFileViewerRemoteActivationCodeCell";
    else if ( reuseIdentifier == SWFileViewerCellIdentifier ) return @"SWFileViewerCell";
    return nil;
}

- (NSString*)nibNameForObjectWithClass:(Class)class
{
    if ( class == [SWFileViewerHeaderView class] ) return @"SWFileViewerHeaderView";
    else if ( class == [SWFileViewerProgressView class] ) return @"SWFileViewerProgressView";
    else if ( class == [SWFileViewerCurrentProjectView class] ) return @"SWFileViewerCurrentProjectView";
    return nil;
}



- (void)configureUploadButon:(ColoredButton*)button forContext:(NSInteger)context
{

    NSString *str1 = nil;
    if ( fileCategory == kFileCategorySourceFile ) str1 = @"DISTRIBUTE";
    else if ( fileCategory == kFileCategoryRedeemedSourceFile ) str1 = @"UPDATE";
    
    if ( context == 0 )
    {
        [button setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
        [button setTitle:str1 forState:UIControlStateNormal];
        [button setAlpha:1.0];
    }
}



- (void)configureColoredButton:(ColoredButton*)button forContext:(NSInteger)context
{
    NSString *str0 = nil;
    NSString *str1 = nil;
    NSString *str2 = nil;
    
    if ( fileCategory == kFileCategorySourceFile ) str0 = @"SELECTED", str1 = @"CLOSE", str2 = @"OPEN";
    else if ( fileCategory == kFileCategoryRedeemedSourceFile ) str0 = @"SELECTED", str1 = @"CLOSE", str2 = @"OPEN";

    else if ( fileCategory == kFileCategoryRecipe ) str0 = @"SELECTED", str1 = str0, str2 = @"SELECT";
    else if ( fileCategory == kFileCategoryAssetFile ) str0 = @"SELECTED", str1 = str0, str2 = @"SELECT";
    else if ( fileCategory == kFileCategoryRemoteActivationCode ) str0 = @"SELECTED", str1 = str0, str2 = @"SEND EMAIL";
    
    else if ( fileCategory == kExtFileCategoryITunes ) str0 = @"SELECTED", str1 = str0, str2 = @"SELECT";

    str0 = NSLocalizedString( str0, nil );
    str1 = NSLocalizedString( str1, nil );
    str2 = NSLocalizedString( str2, nil );
    
    if ( context == 0 )
    {
        [button setRgbTintColor:TheNiceGreenColor overWhite:YES];
        [button setTitle:str0 forState:UIControlStateNormal];
        //[button setImage:[UIImage imageNamed:@"checkWhiteShadow"] forState:UIControlStateNormal];
        //[button setAlpha:1.0];
    }
    else if ( context == 1 )
    {
        //[button setRgbTintColor:TheNiceGreenColor];
        //[button setRgbTintColor:DarkenedRgbColor(TheNiceGreenColor, 2.0f)];
        [button setRgbTintColor:Theme_RGB(0, 192, 192, 192) overWhite:YES];
        [button setTitle:str1 forState:UIControlStateNormal];
        //[button setImage:nil forState:UIControlStateNormal];
        //[button setAlpha:0.6];
    }
    else if ( context == 2 )
    {
        //[button setRgbTintColor:Theme_RGB(0, 192, 192, 192)];
        [button setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
        [button setTitle:str2 forState:UIControlStateNormal];
        //[button setImage:nil forState:UIControlStateNormal];
        //[button setAlpha:0.6];
    }
    else if ( context == 3 )
    {
        [button setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
        [button setTitle:str1 forState:UIControlStateNormal];
    }
}

#pragma mark supporting methods

//---------------------------------------------------------------------------------------------
- (BOOL)supportsSourceFileSelection
{
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    if ( fileCategory == kFileCategoryRedeemedSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRecipe ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteActivationCode ) return YES;

    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsMultipleSourceFileSelection
{
    if ( fileCategory == kFileCategoryRecipe ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
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
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsRefreshGesture
{
    if ( fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteAssetFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteActivationCode ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsLeadingFileSection
{
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    if ( fileCategory == kFileCategoryRedeemedSourceFile ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsAddToolButton
{
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    if ( fileCategory == kFileCategoryRecipe ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    return NO;
}


//---------------------------------------------------------------------------------------------
- (BOOL)supportsActionToolButton
{
    if ( fileCategory == kFileCategorySourceFile ) return YES;
    if ( fileCategory == kFileCategoryAssetFile ) return YES;
    
    if ( fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteAssetFile ) return YES;
    
    if ( fileCategory == kExtFileCategoryITunes ) return YES;
    
    //if ( fileCategory == kFileCategoryRemoteActivationCode ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsTrashToolButton
{
    if ( fileCategory != kFileCategoryRemoteActivationCode ) return YES;
    return NO;
}

//---------------------------------------------------------------------------------------------
- (BOOL)supportsProgressToolView
{
    if ( fileCategory == kFileCategoryAssetFile ) return YES;

    if ( fileCategory == kFileCategoryRemoteAssetFile ||
        fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    
    return NO;
}


//---------------------------------------------------------------------------------------------
- (BOOL)supportsMultipleSelectionNow
{
    if ( [[self tableView] isEditing] ) return [self supportsMultipleSelectionWhileEditing];
    return [self supportsMultipleSelection]; 
}

//---------------------------------------------------------------------------------------------
- (BOOL)shouldHideSelectionButton
{
    if ( fileCategory == kFileCategoryRemoteSourceFile ) return YES;
    if ( fileCategory == kFileCategoryRemoteAssetFile ) return YES;
    //if ( fileCategory == kFileCategoryRemoteActivationCode ) return YES;
    
    if ( fileCategory == kExtFileCategoryITunes ) return YES;
    return NO;
}




#pragma mark Metodes Privats


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
    return [self _newFileViewerObjectWithClass:[SWFileViewerHeaderView class]];
}

- (SWFileViewerProgressView *)newProgressView
{
    SWFileViewerProgressView *view = [self _newFileViewerObjectWithClass:[SWFileViewerProgressView class]];
    view.frame = CGRectMake(0, 0, 250, 40);
    view.backgroundColor = [UIColor clearColor];
    return view;
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


- (UIImage *)placeholderImage
{
    if ( _placeholderImage == nil )
    {
        CGFloat radius = 1; 
        UIColor *color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        UIImage *image = glossyImageWithSizeAndColor( CGSizeMake(RowHeight, RowHeight), [color CGColor], NO, NO, radius, 1 );
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, radius+1, 0, radius+1)];
        _placeholderImage = image;
    }
    return _placeholderImage;
}


//-----------------------------------------------------------------------------
- (void)setSelectedBackgroundWithMultipleSelection:(BOOL)multipleSelect forCell:(UITableViewCell *)cell
{
    if ( multipleSelect )
    {
        UIImageView *selView = [[UIImageView alloc] initWithImage:[self backImage]];
        [cell setMultipleSelectionBackgroundView:selView];
    }
}


//---------------------------------------------------------------------------------------------
- (NSArray *)indexPathsForSelectedRows
{
    NSArray *indexPaths = nil;
    UITableView *table = [self tableView];
    if ( [table respondsToSelector:@selector(indexPathsForSelectedRows)] ) 
    {
        indexPaths = [table indexPathsForSelectedRows];
    }
    else 
    {
        NSIndexPath *indexPath = [table indexPathForSelectedRow];
        if ( indexPath ) indexPaths = [NSArray arrayWithObject:indexPath];  // < iOS 5.0
    }
    return indexPaths;
}

////---------------------------------------------------------------------------------------------
//- (NSArray *)filesForSelectedRows
//{
//    NSMutableArray *files = [[NSMutableArray alloc] init];
//    NSArray *filenames = [self fileNames];
//    NSArray *indexPaths = [self indexPathsForSelectedRows];
//    
//    for ( NSIndexPath *indexPath in indexPaths )
//    {
//        NSInteger section = [indexPath section];
//        if ( section == kSourceFilesSection )
//        {
//            NSInteger row = [indexPath row];
//            NSString *fileName = [filenames objectAtIndex:row];
//            [files addObject:fileName];
//        }
//    }
//    return files;
//}

//---------------------------------------------------------------------------------------------
- (NSArray *)fileMDsForSelectedRows   // inSourceFilesSection
{
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSArray *fileMDs = [self fileMDs];
    NSArray *indexPaths = [self indexPathsForSelectedRows];
    
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


//---------------------------------------------------------------------------------------------
- (void)establishActionButtons
{
    BOOL enable = NO;
    if ( [self isEditing] )
    {
        NSArray *indexPaths = [self indexPathsForSelectedRows];
        enable = [indexPaths count]>0;
    }
    [trashButtonItem setEnabled:enable];
    [actionButtonItem setEnabled:enable];

}

//---------------------------------------------------------------------------------------------
- (void)establishSegmentedOptionHeader
{
    FileSortingOption sorting = [filesModel() fileSortingOptionForCategory:fileCategory];

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
- (void)resetTmpSourcesArray
{
    NSArray *selected = [self sourceFilesArray];
    
    tmpSourcesArray = nil;
    tmpSourcesArray = [[NSMutableSet alloc] initWithArray:selected];
    
    pendingSourcesArray = nil;
    pendingSourcesArray = [[NSMutableSet alloc] initWithArray:selected];
}

//---------------------------------------------------------------------------------------------
- (void)updateSourcesArray
{
    NSArray *selected = [pendingSourcesArray allObjects];
    [self setSourceFilesArray:selected];
}




//---------------------------------------------------------------------------------------------
// recupera i visualitza els fitxers a partir del model
- (void)resetFilesSectionAnimated:(BOOL)animated animateButtons:(BOOL)bAnimated              //**
{
    //recuperem els sources
    [self resetTmpSourcesArray];
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
//

    [table endUpdates];
    
  //  [[self tableView] reloadData];
    
    
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
    if ( actionSheet )
    {
        [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:animated];
        [self setActionSheet:nil];
    }
}



#pragma mark FilesViewController methods

//---------------------------------------------------------------------------------------------
- (id)initWithFileCategory:(int)aCategory forDocument:(SWDocument *)document
{
    self = [super init];
    if ( self )
    {
        fileCategory = aCategory;
        _docModel = document.docModel;
       // [self setTitle:[self baseTitle]];
        
       // [self setHidesBottomBarWhenPushed:[defaults() hiddenFilesTabBar]];
       
//       _leadingFileSection = -1;
////       if ( [self supportsLeadingFileSection] )
////            _leadingFileSection += 1;
//    
//       _sourceFilesSection = _leadingFileSection+1;
       
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
    NSLog( @"SWAuxiliarFilesViewController: dealloc");
}


//---------------------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
}


////---------------------------------------------------------------------------------------------
//- (void)viewDidLoadV
//{
//    [super viewDidLoad];
//    
//    UIView *view = [self view];
//    CGRect rect = [view bounds];
//    
//    CGFloat toolbarHeight = 44;
//    
//    // crea la taula
//    rect.size.height -= toolbarHeight;
//    //rect.origin.y = toolbarHeight;
//    
//     ////
//    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
//    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [_tableView setDelegate:self];
//    [_tableView setDataSource:self];
////    [_tableView setBackgroundColor:DarkenedUIColorWithRgb(SystemDarkerBlueColor,3.0f)];
////    [_tableView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
//   // [_tableView setBackgroundColor:[UIColor underPageBackgroundColor]];
//   
//    [_tableView setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
//    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    
//    [_tableView setTableFooterView:[self messageView]];
////    [_tableView setSeparatorColor:[UIColor colorWithWhite:0.83 alpha:1.0]];    // 0.83
////    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
////    [_tableView setBackgroundColor:[UIColor underPageBackgroundColor]];
//    
//    headerView = [self newHeaderView];
//    [headerView setDelegate:self];
//    [_tableView setTableHeaderView:headerView];
//    
//    // creem el toolbar
//    rect.origin.y = rect.size.height;
//    rect.size.height = toolbarHeight;
//    _toolbar = [[UIToolbar alloc] initWithFrame:rect];
//    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
//    //[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
//    
//    // afegim els items al toolbar
//    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
//    reloadButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
//    actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
//    trashButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashAction:)];
//    addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
//    //[share setStyle:UIBarButtonItemStylePlain];
//    NSArray *toolBarItems;
//    
//    toolBarItems = [NSArray arrayWithObjects:reloadButtonItem, space, actionButtonItem, space, trashButtonItem, space, addButtonItem, nil];
//        
//    [_toolbar setItems:toolBarItems];
//    
//    // per ara desabilitem alguns els buttonItems
//    [self establishActionButtons];
//    [self establishReloadButton];
//    
//    // afegim com subviews
//    [view addSubview:_tableView];
//    [view addSubview:_toolbar];
//    
//    //[self setDeviceBasedTintColor];
//    //[toolbar setDeviceBasedTintColor];
//
//    isICloud = NO;
//    
//    [self establishRightBarButtonItemsAnimated:NO];
//    [self setSelectionSettings];
//}



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
        tableViewController.refreshControl = _refreshControl;
        [tableViewController.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
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
   
    [_tableView setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [_tableView setTableFooterView:[self messageView]];
//    [_tableView setSeparatorColor:[UIColor colorWithWhite:0.83 alpha:1.0]];    // 0.83
//    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
//    [_tableView setBackgroundColor:[UIColor underPageBackgroundColor]];
    
    headerView = [self newHeaderView];
    [headerView setDelegate:self];
    [_tableView setTableHeaderView:headerView];
    
    if ( [self supportsLeadingFileSection] )
    {
        _currentProjectView = [self _newFileViewerObjectWithClass:[SWFileViewerCurrentProjectView class]];
        
        CALayer *layer = _currentProjectView.layer;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:_currentProjectView.bounds];
        layer.shadowPath = path.CGPath;
        layer.shadowOffset = CGSizeMake(0, 1);
        layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
        layer.shadowRadius = 5 ;
        layer.shadowOpacity = 1;
        
        
        [_currentProjectView setDelegate:self];
        [self setupCellData:_currentProjectView atIndexPath:nil];
        [self setupCurrentProjectViewSelection];
        
        CGRect tableBounds = _tableView.bounds;
        CGRect projectViewBounds = _currentProjectView.bounds;
        projectViewBounds.size.width = tableBounds.size.width;
        _currentProjectView.frame = projectViewBounds;
        
        [view addSubview:_currentProjectView];
        tableBounds.origin.y = projectViewBounds.size.height;
        tableBounds.size.height -= projectViewBounds.size.height;
        _tableView.frame = tableBounds;
        
//        [_tableView addSubview:_currentProjectView];
//        [_tableView setContentInset:UIEdgeInsetsMake(projectViewBounds.size.height, 0, 0, 0)];
//        [_tableView setContentOffset:CGPointMake(0,-projectViewBounds.size.height)];
    }
    
    
    // creem el toolbar
    rect.origin.y = rect.size.height;
    rect.size.height = toolbarHeight;
    _toolbar = [[UIToolbar alloc] initWithFrame:rect];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    //[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    // afegim els items al toolbar
    NSMutableArray *toolBarItems = [NSMutableArray array];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    if ( [self supportsAddToolButton] )
    {
        addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
        [toolBarItems addObjectsFromArray:@[addButtonItem, space]];
    }
    
    if ( [self supportsReloadTemplates] )
    {
        reloadButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
        [toolBarItems addObjectsFromArray:@[reloadButtonItem, space]];
    }
    
    if ( [self supportsActionToolButton] )
    {
        actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
        [toolBarItems addObjectsFromArray:@[actionButtonItem, space]];
    }
    
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
    
    [self resetTmpSourcesArray];
    [self establishSegmentedOptionHeader];
     progressViewItem.alpha = 0.0f;
    
    buttonsAreShown = NO;
    
    FileMD *fileMD = [self mainFileMD];
    _sectionProjectShown = ( fileMD != nil );

    [[self tableView] reloadData];

    
    [filesModel() addObserver:self];
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
    
    [filesModel() removeObserver:self];
    //[_docModel removeObserver:self];
    [self maybeDismissActionSheetAnimated:animated];
    
    //if ( fileCategory == kExtFileCategoryITunes ) [filesModel() filesArrayTouchForCategory:kExtFileCategoryITunes];
    
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



#pragma mark Cell Setup

//---------------------------------------------------------------------------------------------
- (void)setupVisibleCellsSelection
{
    NSArray *visibleCells = [_tableView visibleCells];
    for ( SWFileViewerCell *cell in visibleCells )
    {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        [self setupCellSelection:cell atIndexPath:indexPath];
    }
}


//---------------------------------------------------------------------------------------------
- (void)setupCurrentProjectViewSelection
{
    FileMD *fileMD = [self mainFileMD];
    SWFileViewerCurrentProjectView *topCell = _currentProjectView;
    [self configureUploadButon:[topCell buttonUpload] forContext:0];
    [self configureColoredButton:[topCell buttonInclude] forContext:3];
    [topCell setDisabled:(fileMD==nil)];
}


//---------------------------------------------------------------------------------------------
- (void)setupCellSelection:(SWFileViewerCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    FileMD *fileMD = nil;
//    if ( section == _leadingFileSection || indexPath==nil)
//    {
//        fileMD = [self mainFileMD];
//        SWFileViewerCurrentProjectView *topCell = (id)cell;
//        [self configureUploadButon:[topCell buttonUpload] forContext:0];
//        [self configureColoredButton:[topCell buttonInclude] forContext:3];
//        [(SWFileViewerCurrentProjectCell*)cell setDisabled:(fileMD==nil)];
//    }
//    
//    else
    if ( section == _sourceFilesSection )
    {
        fileMD = [self fileMDAtIndex:row];
        [self setSelectedBackgroundWithMultipleSelection:[self supportsMultipleSelectionWhileEditing] forCell:cell];
    
        NSString *name = fileMD.fileName;
        NSInteger context = -1;
        
        ColoredButton *button = [cell buttonInclude];
        
        if ( [pendingSourcesArray containsObject:name] )
        {
            if ( [tmpSourcesArray containsObject:name] )
                context = 0;   // verd
            else
                context = 1;   // gris fosc
        }
        else
        {
            context = 2;  // gris clar
        }
    
        [self configureColoredButton:button forContext:context];
    }
}







//---------------------------------------------------------------------------------------------
- (void)setupCellData:(id<SWFileViewerCellProtocol>)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    FileMD *fileMD = nil;
    
    if ( /*section == _leadingFileSection ||*/ indexPath == nil)
    {
        fileMD = [self mainFileMD];
    }
    
    else if ( section == _sourceFilesSection )
    {
        fileMD = [self fileMDAtIndex:row];
    }
    
    NSString *name = nil;
    NSString *ident = nil;
    NSString *date = nil;
    NSString *size = nil;
    
    if ( fileCategory == kFileCategoryRemoteActivationCode )
    {
        SWFileViewerRemoteActivationCodeCell *actCell = (SWFileViewerRemoteActivationCodeCell *)cell;

        name = fileMD.fileName;
        ident = fileMD.accessCode;
        //date = fileMD.created;
        date = fileMD.fileDateString;
        
        //NSString *totalsStringFmt = NSLocalizedString(@"%d Projects, %d Redemptions", nil);
        //NSString *totalsString = [NSString stringWithFormat:totalsStringFmt, fileMD.maxProjects, fileMD.maxRedemptions];
        
        NSString *projectIdString = [fileMD.projects lastObject];
        
        NSString *redemptionsStringFmt = NSLocalizedString(@"%d Used, %d Total", nil);
        NSString *redemptionsString = [NSString stringWithFormat:redemptionsStringFmt, fileMD.redemptions.count, fileMD.maxRedemptions];
        
        [actCell.labelProjectID setText:projectIdString];
        [actCell.labelRedemptions setText:redemptionsString];
    }
    
    else if ( fileCategory == kFileCategoryRemoteSourceFile )
    {
        name = fileMD.fileName;
        ident = fileMD.identifier;
        //date = fileMD.updated;    // a canviar
        date = fileMD.fileDateString;
        size = fileMD.fileSizeString;
    }
    
    else if ( fileCategory == kFileCategoryRemoteAssetFile )
    {
        name = fileMD.fileName;
        //date = fileMD.updated;    // a canviar
        date = fileMD.fileDateString;
        size = fileMD.fileSizeString;
    }
    
    else // categories locals
    {
        name = fileMD.fileName;
        ident = fileMD.identifier;
        date = fileMD.fileDateString;
        size = fileMD.fileSizeString;
    
    }
    
    [cell.labelFileName setText:name];
    [cell.labelFileIdent setText:ident];
    [cell.labelModDate setText:date];
    [cell.labelSize setText:size];
    
    
    UIButton *buttonImage = cell.buttonImage;
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
        
        image = [self _defaultImageForFileFullPath:imageFullPath];
        [buttonImage setImage:image forState:UIControlStateNormal];
        
        SWImageManager *imageManager = [SWImageManager defaultManager];
        [imageManager getImageWithOriginalPath:imageFullPath size:CGSizeMake(RowHeight,RowHeight) contentMode:UIViewContentModeScaleAspectFill completionBlock:^(UIImage *aImage)
        {
            if ( aImage != nil )
                [buttonImage setImage:aImage forState:UIControlStateNormal];
        }];
    }
    
    //image = [image resizedImageWithContentMode:UIViewContentModeCenter bounds:CGSizeMake(RowHeight,RowHeight) contentScale:image.scale interpolationQuality:kCGInterpolationDefault cropped:NO];

}

- (UIImage*)_defaultImageForFileFullPath:(NSString*)fileFullPath
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



//
//- (UIImage*)_imageForFile:(NSString*)fileName
//{
//    NSString *fileFullPath = [filesModel() fileFullPathForFileName:fileName forCategory:fileCategory];
//    if ( fileFullPath == nil )
//    {
//#warning To DO s'ha de Tornar placeholder per el tipus d'arxiu
//        return nil;
//    }
//    
//    NSURL *fileURL = [NSURL fileURLWithPath:fileFullPath];
//
//    UIDocumentInteractionController *interactionController =
//        [UIDocumentInteractionController interactionControllerWithURL:fileURL];
//    // interactionController.delegate = interactionDelegate;
//   
//    NSArray *icons = [interactionController icons];   // aparentment torna 64x64 i 320x320
//   
//    UIImage *firstIcon = nil;
//    if ( icons.count > 0 )
//        firstIcon = [icons objectAtIndex:0];
//
//
////   NO ESBORRAR, MANTENIR PER REFERENCIA aparentment torna 64x64 i 320x320
////    for ( UIImage *img in icons)
////    {
////        NSLog( @"iconSize %@", NSStringFromCGSize( img.size ));
////    }
// 
//    return firstIcon;
//}


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

////---------------------------------------------------------------------------------------------
//- (void)setupCell:(SWFileViewCell *)cell atIndexPath:(NSIndexPath*)indexPath
//{
//    //NSString *identifier = [cell reuseIdentifier];
//    NSInteger row = [indexPath row];
//    
//    NSString *name = nil;
//    NSString *size = nil;
//    NSString *date = nil;
//    
//    //if ( identifier == SourceFilesCellIdentifier )
//    {
//        name = [self fileNameAtIndex:row];
//        size = [self fileSizeStringForFileName:name];
//        date = [self fileDateStringForFileName:name];
//        
////        UIImageView *imageView = (id)[cell rightView];
//        ColoredButton *button = [cell buttonInclude];
//        
//        if ( [pendingSourcesArray containsObject:name] )
//        {            
//            if ( [tmpSourcesArray containsObject:name] )
//            {
////                [imageView setAlpha:1.0];
//                [button setAlpha:1.0];
//                [button setRgbTintColor:TheNiceGreenColor];
//                [button setTitle:@"CHOSEN" forState:UIControlStateNormal];
//            }
//            else
//            {
////                [imageView setAlpha:0.5];
//                [button setAlpha:0.6];
//                [button setRgbTintColor:TheNiceGreenColor];
//                [button setTitle:@"CHOSEN" forState:UIControlStateNormal];
//            }
//        }
//        else
//        {
////            [imageView setAlpha:0.1];
//
//            [button setRgbTintColor:Theme_RGB(0, 192, 192, 192)];
//            [button setTitle:@"CHOOSE" forState:UIControlStateNormal];
//            [button setAlpha:0.6];
//        }
//    }
//    
////    else if ( identifier == EmptyCellIdentifier )
////    {
////        name = NSLocalizedString( @"(No Files)", nil );
////        size = @"";
////    }
//
//    //[[cell textLabel] setText:name];
//    //[[cell detailTextLabel] setText:size];
//    
//    [self setSelectedBackgroundWithMultipleSelection:[self supportsMultipleSelectionWhileEditing] forCell:cell];
//    [cell.labelFileName setText:name];
//    [cell.labelModDate setText:date];
//    [cell.labelSize setText:size];
//    
////    [cell setMainText:name];
////    [cell setBottomText:size];
//}
//


//- (SWFileViewerCurrentProjectCell*)topFileViewerCell
//{
//    if ( _topFileViewerCell == nil )
//    {
//        _topFileViewerCell = [self newTopfileViewerCell];
//        [_topFileViewerCell setDelegate:self];
//    }
//    return _topFileViewerCell;
//}





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
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [cell setShouldHideButton:[self shouldHideSelectionButton]];
        }
    }
    
    [self setupCellData:cell atIndexPath:indexPath];
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
        if ( fileCategory == kFileCategorySourceFile ) height = RowHeight;
        else if ( fileCategory == kFileCategoryRedeemedSourceFile ) height = RowHeight;
        else if ( fileCategory == kFileCategoryAssetFile ) height = RowHeight;
        else if ( fileCategory == kFileCategoryRemoteSourceFile ) height = RowHeightRemoteProject;
        else if ( fileCategory == kFileCategoryRemoteAssetFile ) height = RowHeight;
        else if ( fileCategory == kFileCategoryRemoteActivationCode ) height = RowHeightActivationCode ;
        
    }
    return height;
}

//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayCell:(SWFileViewerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
}


//---------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
//    if ( section == _leadingFileSection )
//        return nil;
    
    return indexPath;
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
        BOOL isMultipleSelec = [self supportsMultipleSelectionNow];
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

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark UIScrollView delegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGRect frame = _currentProjectView.bounds;
//    CGPoint offset = scrollView.contentOffset;
//    frame.origin = offset;
//    
//    _currentProjectView.frame = frame;
//}


#pragma mark AppsFileModelObserver


- (void)appFilesModelCurrentDocumentChange:(AppFilesModel*)filesModel
{
    [_docModel removeObserver:self];
    
    SWDocument *document = filesModel.currentDocument;
    _docModel = document.docModel;

    [self setupCellData:_currentProjectView atIndexPath:nil];
    
    [_docModel addObserver:self];


//    UITableView *table = self.tableView;
//    //SWDocument *document = filesModel.currentDocument;
//    
//    if ( _leadingFileSection >= 0 )
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kFirstLeadingFileRow inSection:_leadingFileSection];
//        [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
    
//    
//    
//    [table beginUpdates];
//    if ( document == nil && _leadingFileSection >= 0 )
//    {
//        [table deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        [table reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if ( document && _leadingFileSection < 0 )
//    {
//        [table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        [table insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        //[table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//    }
//    [table endUpdates];
    
    
    
    
}



// canvis locals

- (void)appsFileModel:(AppFilesModel *)filesModel didChangeListingForCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        [self resetFilesSectionAnimated:YES animateButtons:NO];
        [self establishSegmentedOptionHeader];
        [self establishActionButtons];
    }
}

- (void)appsFileModelSourcesDidChange:(AppFilesModel *)filesModel
{

}

// canvis remots

- (void)appFilesModel:(AppFilesModel *)filesModel willChangeRemoteListingForCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        [self establishActivityIndicator:YES animated:YES];
    }
}


- (void)appFilesModel:(AppFilesModel *)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError *)error
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

- (void)appFilesModel:(AppFilesModel *)filesModel beginGroupUploadForCategory:(FileCategory)category
{
//    if ( category == fileCategory )
//    {
//        NSLog( @"Will upload %@", fileName );
//        [self establishActivityIndicator:YES animated:YES];
//    }
    if ( category == fileCategory )
    {
        NSString *text = NSLocalizedString( @"Upload", nil);
        [progressViewItem.labelFile setText:text];
        [progressViewItem.progresView setProgress:0.0f];
        progressViewItem.alpha = 1.0f;
        
        [_toolbar setItems:_toolbarItemsProgress animated:YES];
    }
}


- (void)appFilesModel:(AppFilesModel*)filesModel willUploadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        NSString *format = NSLocalizedString( @"Uploading: %@", nil);
        NSString *text = [NSString stringWithFormat:format, fileName];
        [progressViewItem.labelFile setText:text];
    }
}


- (void)appFilesModel:(AppFilesModel *)filesModel groupUploadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    if ( category == fileCategory )
    {
        float progressValue = (float)step/(float)stepCount;
        [progressViewItem.progresView setProgress:progressValue animated:YES];
    }
}


- (void)appFilesModel:(AppFilesModel*)filesModel fileUploadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
}


- (void)appFilesModel:(AppFilesModel*)filesModel didUploadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
//if ( category == fileCategory )
    {
        NSLog( @"Did upload %@", fileName );
        [self establishRightBarButtonItemsAnimated:YES];
//pep        if ( error )
//        {
//            NSString *title = NSLocalizedString(@"Integrators Service Upload", nil );
//            NSString *message = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//            [alert show];
//        }
    }
}


- (void)appFilesModel:(AppFilesModel *)filesModel endGroupUploadForCategory:(FileCategory)category
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

- (void)appFilesModel:(AppFilesModel *)filesModel beginGroupDownloadForCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        NSString *text = NSLocalizedString( @"Download", nil);
        [progressViewItem.labelFile setText:text];
        [progressViewItem.progresView setProgress:0.0f];
        progressViewItem.alpha = 1.0f;
        
        [_toolbar setItems:_toolbarItemsProgress animated:YES];
    }
}


- (void)appFilesModel:(AppFilesModel*)filesModel willDownloadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        NSString *format = NSLocalizedString( @"Downloading: %@", nil);
        NSString *text = [NSString stringWithFormat:format, fileName];
        [progressViewItem.labelFile setText:text];
    }
}


- (void)appFilesModel:(AppFilesModel *)filesModel groupDownloadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    if ( category == fileCategory )
    {
        float progressValue = (float)step/(float)stepCount;
        [progressViewItem.progresView setProgress:progressValue animated:YES];
    }
}


- (void)appFilesModel:(AppFilesModel*)filesModel fileDownloadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
}


- (void)appFilesModel:(AppFilesModel*)filesModel didDownloadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
}


- (void)appFilesModel:(AppFilesModel *)filesModel endGroupDownloadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{

    if ( category == fileCategory )
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


- (void)appFilesModel:(AppFilesModel*)filesModel willDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category
{
    if ( category == fileCategory )
    {
        NSLog( @"Will delete %@", fileName );
        [self establishActivityIndicator:YES animated:YES];
    }
}


- (void)appFilesModel:(AppFilesModel*)filesModel didDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error
{
    if ( category == fileCategory )
    {
        NSLog( @"Did delete %@", fileName );
        [self establishRightBarButtonItemsAnimated:YES];
//pep        if ( error )
//        {
//            [_refreshControl endRefreshing];    // <-- nomes si hi ha error, si no ja ho fara el didChangeRemoteListing
//            NSString *title = NSLocalizedString(@"Integrators Service Upload", nil );
//            NSString *message = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//            [alert show];
//        }
    }
}








#pragma mark SWDocumentModelObserver

// canvi de la seleccio d'arxius en el document
- (void)documentModelFileListDidChange:(SWDocumentModel*)docModel
{
    if ( fileCategory == kFileCategoryAssetFile )
    {
        [self resetFilesSectionAnimated:NO animateButtons:NO];
    }
}

- (void)documentModelThumbnailDidChange:(SWDocumentModel *)docModel
{
    if ( (fileCategory == kFileCategorySourceFile) || (fileCategory == kFileCategoryRemoteRedeemedSourceFile))
    {
        if ( _currentProjectView )
        {
            //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kFirstLeadingFileRow inSection:_leadingFileSection];
            NSIndexPath *indexPath = nil;
            [self setupCellData:_currentProjectView atIndexPath:indexPath];
        }
    }
}



#pragma mark SWFileViewCurrentProjectDelegate

- (void)currentProjectViewDidTouchImageButton:(SWFileViewerCurrentProjectView *)view
{

}


- (void)currentProjectViewDidTouchIncludeButton:(SWFileViewerCurrentProjectView *)view
{
    [filesModel() closeDocument];
        
    [pendingSourcesArray removeAllObjects]; // unselect all
    [self updateSourcesArray];
}


- (void)currentProjectViewDidTouchUploadButton:(SWFileViewerCurrentProjectView *)view
{
    if ( fileCategory == kFileCategorySourceFile )
        [self _presentUploadPresenter];
    
    else if ( fileCategory == kFileCategoryRedeemedSourceFile )
        [self _presentUpdatePresenter];
}



#pragma mark SWFileViewCellDelegate

// tocat en la cell el boto de seleccio d'arxius
-(void)fileViewCellDidTouchIncludeButton:(SWFileViewerCell*)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    
//    if ( section == _leadingFileSection || cell == _currentProjectCell)
//    {
//        [filesModel() closeDocument];
//        
//        [pendingSourcesArray removeAllObjects]; // unselect all
//        [self updateSourcesArray];
//    }
//    
//    else
    if ( section == _sourceFilesSection )
    {  
        BOOL supportsSourceSelection = [self supportsSourceFileSelection];
        BOOL supportsMultipleSourceSelection = [self supportsMultipleSourceFileSelection];
        
        if ( supportsSourceSelection )
        {
            FileMD *fileMD = [self fileMDAtIndex:row];
            NSString *name = fileMD.fileName;
            if ( name == nil ) name = fileMD.accessCode;
            
            BOOL selected = [pendingSourcesArray containsObject:name];
            if ( supportsMultipleSourceSelection )
            {
                if ( selected )
                    [pendingSourcesArray removeObject:name]; // unselect
                else
                    [pendingSourcesArray addObject:name];   // select
            }
            else
            {
                [pendingSourcesArray removeAllObjects]; // unselect all
                if ( !selected )
                    [pendingSourcesArray addObject:name];   // select
            }
            
//            if ( supportsMultipleSourceSelection )
//                [self setupCellSelection:cell atIndexPath:indexPath];    // nomes ha canviat aquesta
//            else
//                [self setupVisibleCellsSelection];        // poden haver canviat altres

            if ( supportsMultipleSourceSelection )
            {
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
                //[self setupVisibleCellsSelection];   // poden haver canviat altres celdes
                [self updateSourcesArray];
                // ^ en el cas de seleccio simple la actualitzacio la fem ara mateix

                [pendingSourcesArray removeAllObjects];
                [self setupVisibleCellsSelection];
                
                [self performActionUponSelectingFileMD:fileMD];
            }
        }
    }
}



-(void)fileViewCellDidTouchImageButton:(SWFileViewerCell*)cell
{
    NSLog( @"fileViewCellDidTouchImageButton" );
}



#pragma mark SWTopFileViewCellDelegate

//-(void)fileViewCellDidTouchUploadButton:(SWFileViewerCell*)cell
//{
//  //  [filesModel() uploadDocument];
//    if ( fileCategory == kFileCategorySourceFile )
//        [self _presentUploadPresenter];
//    
//    else if ( fileCategory == kFileCategoryRedeemedSourceFile )
//        [self _presentUpdatePresenter];
//}



#pragma mark SWFileViewerHeaderViewDelegate

- (void)fileViewerHeaderView:(SWFileViewerHeaderView *)viewerHeader didSelectSegmentAtIndex:(NSInteger)indx
{
    FileSortingOption option = kFileSortingOptionAny;
    if ( indx == 0 ) option = kFileSortingOptionDateDescending;
    if ( indx == 1 ) option = kFileSortingOptionNameAscending;
    [filesModel() setFileSortingOption:option forCategory:fileCategory];
}




#pragma mark RefreshButton Action

- (void)handleRefresh:(id)sender
{
    NSLog(@"handle refresh");
    [filesModel() refreshMDArrayForCategory:fileCategory];
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



#pragma mark UIToolbarItem actions

//---------------------------------------------------------------------------------------------
- (void)refreshAction:(UIBarButtonItem *)toolBarItem
{
    [self maybeDismissActionSheetAnimated:YES];
    UIActionSheet *actSheet = [[UIActionSheet alloc] 
            initWithTitle:NSLocalizedString(@"MessageRefreshAction" ,nil)
            delegate:self
            cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
            destructiveButtonTitle:NSLocalizedString( @"Remove Examples", nil )
            otherButtonTitles:NSLocalizedString( @"Load Examples", nil ), nil ];
                
    [actSheet setTag:actionRefreshAction];
    [actSheet showFromBarButtonItem:toolBarItem animated:YES];
    [self setActionSheet:actSheet];
}



//---------------------------------------------------------------------------------------------
- (void)shareAction:(UIBarButtonItem *)toolBarItem
{
    [self maybeDismissActionSheetAnimated:YES];
    NSString *title = NSLocalizedString(@"MessageShareAction" ,nil);
    
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:title
                delegate:self
                cancelButtonTitle:nil
                destructiveButtonTitle:nil
                otherButtonTitles:nil ];
    
    switch ( fileCategory )
    {
        case kFileCategorySourceFile:
        case kFileCategoryRecipe:
        case kFileCategoryAssetFile:
        {
           // [actSheet addButtonWithTitle:NSLocalizedString( @"Send To Integrators Server", nil )];
            if ( fileCategory == kFileCategoryAssetFile )
                [actSheet addButtonWithTitle:NSLocalizedString( @"Upload to HMI Pad Server", nil )];
            
            [actSheet addButtonWithTitle:NSLocalizedString( @"Send Email", nil )];
            [actSheet addButtonWithTitle:NSLocalizedString( @"Send to iTunes", nil )];
            
            NSArray *indexPaths = [self indexPathsForSelectedRows];
            if ( indexPaths.count == 1 )
            {
                [actSheet addButtonWithTitle:NSLocalizedString( @"Rename", nil )];
                [actSheet addButtonWithTitle:NSLocalizedString( @"Duplicate", nil )];
            }
            
            break;
        }
            
        case kFileCategoryRemoteSourceFile:
        {
            [actSheet addButtonWithTitle:NSLocalizedString( @"Download from HMiPad Server", nil )];
            break;
        }
        
        case kFileCategoryRemoteAssetFile:
        {
            [actSheet addButtonWithTitle:NSLocalizedString( @"Download from HMiPad Server", nil )];
            break;
        }
        
        case kExtFileCategoryITunes:
        {
            [actSheet addButtonWithTitle:NSLocalizedString( @"Send Email", nil )];
            [actSheet addButtonWithTitle:NSLocalizedString( @"Move to Projects", nil )];
            //[actSheet addButtonWithTitle:NSLocalizedString( @"Move to Recipes", nil ) ];
            [actSheet addButtonWithTitle:NSLocalizedString( @"Move to Assets", nil )];
            break;
        }
    }
    
    // cancel
    [actSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil )];
    [actSheet setCancelButtonIndex:actSheet.numberOfButtons-1];
    
    [actSheet setTag:actionShareAction];
    [actSheet showFromBarButtonItem:toolBarItem animated:YES];
    [self setActionSheet:actSheet];
}


//---------------------------------------------------------------------------------------------
- (void)trashAction:(UIBarButtonItem *)toolBarItem
{
    [self maybeDismissActionSheetAnimated:YES];
    UIActionSheet *actSheet = [[UIActionSheet alloc] 
            initWithTitle:NSLocalizedString(@"MessageTrashAction" ,nil)
            delegate:self
            cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
            destructiveButtonTitle:NSLocalizedString( @"Yes, Please Delete", nil )
            otherButtonTitles:nil ];

    [actSheet setTag:actionTrashAction];
    [actSheet showFromBarButtonItem:toolBarItem animated:YES];
    [self setActionSheet:actSheet];
}


//---------------------------------------------------------------------------------------------
- (void)addAction:(UIBarButtonItem *)toolBarItem
{
    [self maybeDismissActionSheetAnimated:YES];
    UIActionSheet *actSheet = nil;
    NSString *title = NSLocalizedString(@"MessageShareAction" ,nil);
    //NSString *cancel = NSLocalizedString( @"Cancel", nil );
    
    actSheet = [[UIActionSheet alloc] initWithTitle:title 
        delegate:self
        cancelButtonTitle:nil
        destructiveButtonTitle:nil
        otherButtonTitles:nil];
        
    switch ((int)fileCategory)
    {
            
        case kFileCategorySourceFile:
            [actSheet addButtonWithTitle:NSLocalizedString(@"New Project", nil)];
            [actSheet addButtonWithTitle:NSLocalizedString( @"Download from Server", nil)];
            break;
            
        default:
            [actSheet addButtonWithTitle:NSLocalizedString( @"Download from Server", nil)];
            break;
    }
    
    [actSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil )];
    [actSheet setCancelButtonIndex:actSheet.numberOfButtons-1];
                
    [actSheet setTag:actionAddAction];
    [actSheet showFromBarButtonItem:toolBarItem animated:YES];
    [self setActionSheet:actSheet];
}



#pragma mark UIActionSheet Delegate

//---------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)anActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog( @"clickedButtonAtIndex: %d", buttonIndex );
    
    if ( buttonIndex == [anActionSheet cancelButtonIndex] )
    {
        return;
    }
    
    NSInteger firstButtonIndex = 0;
    NSInteger firstOtherButtonIndex = [anActionSheet firstOtherButtonIndex];
    NSInteger destructiveButtonIndex = [anActionSheet destructiveButtonIndex];
    
    NSInteger tag = [anActionSheet tag];
    
    // refresh
    if ( tag == actionRefreshAction )
    {
        if ( fileCategory == kFileCategorySourceFile )
        {
            if ( buttonIndex == destructiveButtonIndex ) [self _doRemoveSources];
            else if ( buttonIndex == firstOtherButtonIndex ) [self _doReloadSources];
        }
    }
    
    // share
    else if ( tag == actionShareAction )
    {
        switch ( fileCategory )
        {
            case kFileCategorySourceFile:
            case kFileCategoryRecipe:
            case kFileCategoryAssetFile:
                if ( fileCategory == kFileCategoryAssetFile )
                {
                    if ( buttonIndex == firstButtonIndex+0 ) [self _doUploadFiles];
                    firstButtonIndex += 1;
                }
                
                //if ( buttonIndex == firstButtonIndex ) [self _doSendToCloud];
                if ( buttonIndex == firstButtonIndex+0 ) [self _doSendMail];
                else if ( buttonIndex == firstButtonIndex+1 ) [self _doSendToITunes];
                else if ( buttonIndex == firstButtonIndex+2 ) [self _doRename];
                else if ( buttonIndex == firstButtonIndex+3 ) [self _doDuplicate];
                break;
                
            case kFileCategoryRemoteSourceFile:
            case kFileCategoryRemoteAssetFile:
                if ( buttonIndex == firstButtonIndex+0 ) [self _doDownloadFiles];
                break;
    
            case kExtFileCategoryITunes:
                if ( buttonIndex == firstButtonIndex+0 ) [self _doSendMail];
                else if ( buttonIndex == firstButtonIndex+1 ) [self _doMoveToSources];
                /*else if ( buttonIndex == firstOtherButtonIndex+2 ) [self doMoveToRecipes];*/
                else if ( buttonIndex == firstButtonIndex+2 ) [self _doMoveToDocuments];
                break;
        }
    }
    
    // trash
    else if ( tag == actionTrashAction )
    {
        if ( buttonIndex == destructiveButtonIndex ) [self _doTrash];
    }
    
    // add
    else if ( tag == actionAddAction )
    {
        switch ((int)fileCategory)
        {
            case kFileCategorySourceFile:
                if (buttonIndex == firstButtonIndex) [filesModel() addNewEmptyDocument];
                else if ( buttonIndex == firstButtonIndex + 1 ) [self _doDownloadFromServer];
                break;
                
            default:
                if ( buttonIndex == firstButtonIndex ) [self _doDownloadFromServer];
                break;
        }
    }
    
    [self setActionSheet:nil];
}



//---------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setActionSheet:nil];
}



#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex];
    if ( buttonIndex == firstOtherButtonIndex )
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [filesModel() renameFileWithFileName:_renamingFileName toFileName:textField.text forCategory:fileCategory error:nil];
        _renamingFileName = nil;
    }
}


#pragma mark private methods

//---------------------------------------------------------------------------------------------
- (void)_doRename
{
    NSString *title = NSLocalizedString(@"AlertRenameTitle", nil);
    NSString *message = NSLocalizedString(@"AlertRenameMessage", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
        message:message
        delegate:nil
        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
        otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView setDelegate:self];
    
    //NSArray *selectedFiles = [self filesForSelectedRows];
    
    NSArray *selectedFileMDs = [self fileMDsForSelectedRows];

    if ( selectedFileMDs.count > 0 )
    {
        FileMD *renamingMD = [selectedFileMDs objectAtIndex:0];
        _renamingFileName = renamingMD.fileName;
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.font = [UIFont systemFontOfSize:17];
        textField.textColor = UIColorWithRgb(TextDefaultColor);
        textField.text = _renamingFileName;

        [alertView show];
    }
}



//---------------------------------------------------------------------------------------------
- (void)_doDuplicate
{
    //NSArray *selectedFiles = [self filesForSelectedRows];
    
    NSArray *selectedFileMDs = [self fileMDsForSelectedRows];
    if ( selectedFileMDs.count > 0 )
    {
        FileMD *selectedMD = [selectedFileMDs objectAtIndex:0];
        NSString *selectedFileName = selectedMD.fileName;
        [filesModel() duplicateFileWithFileName:selectedFileName forCategory:fileCategory error:nil];
    }
}

//---------------------------------------------------------------------------------------------
- (void)_doSendMail
{

    NSArray *attachmentMDs = [self fileMDsForSelectedRows];
    [self presentMailControllerForFiles:attachmentMDs forCategory:fileCategory];


//    SendMailController *mailController = [[SendMailController alloc] init];
//    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
//    
//    [mailController setSubject:NSLocalizedString(@"MailMessageSubject",nil)];
//
//    // Set up recipients
//    NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
//    [mailController setToRecipients:toRecipients];
//    
//    NSArray *attachmentMDs = [self fileMDsForSelectedRows];
//    
//    NSMutableString *emailBody;
//    if ( [attachmentMDs count] == 0 )
//    {
//        emailBody = [NSString stringWithString:NSLocalizedString(@"MailMessageFrom", nil)];
//    }
//    else
//    {
//        emailBody = [NSMutableString stringWithString:NSLocalizedString(@"MailPleaseFindAttached", nil)];
//        for ( FileMD *fileMD in attachmentMDs )
//        {
//            NSString *fileName = fileMD.fileName;
//            [emailBody appendFormat:@"\n%@",fileName];
//            NSString *originPath = [self originPathForFileName:fileName];
//            
//            NSData *myData = [[NSData alloc] initWithContentsOfFile:originPath];
//            //[mailController addAttachmentData:myData mimeType:@"text/csv" fileName:fileName];
//            [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:fileName];
//        }
//    }
//            
//    [mailController setMessageBody:emailBody isHTML:NO];
//    
//    [self presentModalViewController:mailController animated:YES];
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



//---------------------------------------------------------------------------------------------
- (void)_doSendToCategory:(FileCategory)toCategory wantsCopy:(BOOL)wantsCopy
{    
    AppFilesModel *theModel = filesModel();
    NSArray *fileMDsToMove = [self fileMDsForSelectedRows];
    for ( FileMD *fileMD in fileMDsToMove )
    {
        NSString *fileName = fileMD.fileName;
        [theModel sendFileWithFileName:fileName withCategory:fileCategory toCategory:toCategory outError:nil];
    }
}


- (void)_doDownloadFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory
{

}


- (void)_doDownloadFiles
{
    AppFilesModel *theModel = filesModel();
    NSArray *fileMDsToDownload = [self fileMDsForSelectedRows];
    
    [theModel downloadRemoteFileMDs:fileMDsToDownload forCategory:fileCategory];    
}

//---------------------------------------------------------------------------------------------
- (void)_doUploadFiles
{
    AppFilesModel *theModel = filesModel();
    NSArray *fileMDsToUpload = [self fileMDsForSelectedRows];
    
    [theModel uploadRemoteFileMDs:fileMDsToUpload forCategory:fileCategory];
}

//---------------------------------------------------------------------------------------------
- (void)_doMoveToSources
{
    [self _performDropEffectWithImageNamed:@"configprofileicon.png"];
    [self _doSendToCategory:kFileCategorySourceFile wantsCopy:NO];
}

//---------------------------------------------------------------------------------------------
- (void)_doMoveToRecipes
{
    [self _performDropEffectWithImageNamed:@"configprofileicon.png"];
    [self _doSendToCategory:kFileCategoryRecipe wantsCopy:NO];
}

//---------------------------------------------------------------------------------------------
- (void)_doMoveToDocuments
{
    [self _performDropEffectWithImageNamed:@"texticon.png"];
    [self _doSendToCategory:kFileCategoryAssetFile wantsCopy:NO];
}

//---------------------------------------------------------------------------------------------
- (void)_doSendToITunes
{
    [self _performDropEffectWithImageNamed:@"texticon.png"];
    //[self performDropEffectWithImageNamed:@"genericfile.png"];
    [self _doSendToCategory:kExtFileCategoryITunes wantsCopy:YES];
}



//---------------------------------------------------------------------------------------------
- (void)_doSendToCloud
{
    [self _performDropEffectWithImageNamed:@"texticon.png"];
    //[self performDropEffectWithImageNamed:@"genericfile.png"];
    
    FileCategory toCategory = kFileCategoryUnknown;
    if ( fileCategory == kFileCategorySourceFile ) toCategory = kFileCategoryRemoteSourceFile;
    else if ( fileCategory == kFileCategoryAssetFile ) toCategory = kFileCategoryRemoteAssetFile;
    
    [self _doSendToCategory:toCategory wantsCopy:YES];
}


//---------------------------------------------------------------------------------------------
- (void)_doReloadSources
{
    AppFilesModel *theModel = filesModel();
    [theModel copyFileTemplates];
}


//---------------------------------------------------------------------------------------------
- (void)_doRemoveSources
{
    AppFilesModel *theModel = filesModel();
    [theModel deleteFileTemplates];
}


//---------------------------------------------------------------------------------------------
- (void)_doTrash
{
    NSArray *fileMDsToDelete = [self fileMDsForSelectedRows];
    for ( FileMD *fileMD in fileMDsToDelete )
    {
//        NSString *fileName = fileMD.fileName;
//        [self deleteFileWithFileName:fileName];
        [self deleteFileWithFileMD:fileMD];
    }
}

//---------------------------------------------------------------------------------------------
- (void)_doDownloadFromServer
{
    DownloadFromServerController *viewController = [[DownloadFromServerController alloc] initWithFileCategory:fileCategory];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

////---------------------------------------------------------------------------------------------
//- (void)_doPresentErrorPresenterWithTitle:(NSString*)title message:(NSString*)message
//{
//    SWErrorPresenterViewController *errorPresenter = [[SWErrorPresenterViewController alloc] init];
//    [errorPresenter setTitle:title];
//    [errorPresenter setMessage:message];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:errorPresenter];
//    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
//    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    //[self presentModalViewController:navController animated:YES];
//    [self presentViewController:navController animated:YES completion:nil];
//}

//---------------------------------------------------------------------------------------------
- (void)_presentUploadPresenter // WithTitle:(NSString*)title
{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SWUploadViewController" bundle:nil];
    SWUploadViewController *uploadPresenter = [storyboard instantiateInitialViewController];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:uploadPresenter];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

//---------------------------------------------------------------------------------------------
- (void)_presentUpdatePresenter // WithTitle:(NSString*)title
{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SWUpdateViewController" bundle:nil];
    SWUpdateViewController *updatePresenter = [storyboard instantiateInitialViewController];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:updatePresenter];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

//---------------------------------------------------------------------------------------------
- (void)_performDropEffectWithImageNamed:(NSString*)imageName
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


@end

