//
//  SWAddObjectViewController.m
//  HmiPad
//
//  Created by Joan Martin on 8/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWExamplesViewController.h"

#import "AppModelFilesEx.h"
#import "AppModelDownloadExamples.h"

#import "SWModelManager.h"

#import "SWTableViewMessage.h"
#import "SWBlockAlertView.h"
#import "SWFileViewerProgressView.h"

#import "SWColor.h"




static NSString * const kProjectNameKey = @"projectName";
static NSString * const kAssetsKey = @"assets";
static NSString * const kBundledKey = @"bundledFiles";

@interface SWExamplesViewController()<AppFilesModelObserver, AppModelDownloadExamplesObserver>

@end



#define DefaultRGB TextDefaultColor

@implementation SWExamplesViewController
{
    UIActivityIndicatorView *_activity;
    SWFileViewerProgressView *_progressViewItem;
    SWTableViewMessage *_messageView;
    NSCache *_cache;
}


//+ (NSDictionary*)filterObjectTypesFromDataSource:(NSDictionary*)dataSource withAllowedObjectTypes:(SWObjectType)allowedObjectTypes
//{
//    NSMutableArray *sections = [dataSource valueForKey:kSectionsKey];
//    NSArray *sectionsCopy = [sections copy];
//
//    for (NSDictionary *section in sectionsCopy)
//    {
//        NSDictionary *metaData = [section valueForKey:kMetaDataKey];
//        NSInteger objectType = [[metaData valueForKey:kObjectTypeKey] integerValue];
//        
//        if (!(objectType & allowedObjectTypes))
//            [sections removeObject:section];
//    }
//    
//    return dataSource;
//}



//- (id)initWithDocument:(SWDocumentModel*)documentModel allowedObjectTypes:(SWObjectType)objectTypes
//{
//    NSDictionary *dic = [[NSDictionary dictionaryWithContentsOfFile:
//        [[NSBundle mainBundle] pathForResource:@"ExamplesMenu" ofType:@"plist"]] valueForKey:kDataSourceKey];
//    
//    NSMutableDictionary *mutableDataSource = (__bridge_transfer NSMutableDictionary *)
//        CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFDictionaryRef)dic, kCFPropertyListMutableContainers);
//
//    NSDictionary *dataSource = [self.class filterObjectTypesFromDataSource:mutableDataSource withAllowedObjectTypes:objectTypes];
//    
//    self.title = NSLocalizedString(@"Item Creation", nil);
//    
//// Create json representation
////    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
////    NSMutableString *output = [NSMutableString stringWithString:NSTemporaryDirectory()];
////    [output appendFormat:@"%@.json",@"AddMenu"];
////    [data writeToFile:output atomically:YES];
//    
//    self = [super initWithDataSource:dataSource style:UITableViewStyleGrouped parentController:nil indexPath:nil];
//    if (self)
//    {
//        _allowedObjectTypes = objectTypes;
//    }
//    
//    return self;
//}


- (id)init
{
    self = [super initWithDataSource:nil style:UITableViewStyleGrouped parentController:nil indexPath:nil];
    if (self )
    {
        _allowedObjectTypes = SWObjectTypeAny;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *table = self.tableView;
    
    BOOL isParent = (self.indexPath == nil);
    
    if ( isParent )
    {
        [self setTitle:NSLocalizedString(@"Example project templates", nil)];
        
        UINavigationItem *navItem = self.navigationItem;
       
        UIBarButtonItem *lbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(_doClose:)] ;
        [navItem setLeftBarButtonItem:lbutton animated:NO];
        
        UIBarButtonItem *rbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(_doReload:)] ;
        [navItem setRightBarButtonItem:rbutton animated:NO];
        
        _messageView = [[SWTableViewMessage alloc] initForTableFooter];
        [_messageView setMessage:NSLocalizedString(@"ExamplesViewControllerFooter", nil)];
//        [messageView setEmptyMessage:[self emptyFooterText]];
//        [messageView setEmptyTitle:[self emptyFooterTitile]];

        [table setTableFooterView:_messageView];
    }
    
    if ( !isParent )
    {
        _progressViewItem = [self _newProgressView];
        _progressViewItem.alpha = 0.0f;   // <<-- aqui no va, ho he posat tambe al will appear
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:_progressViewItem];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        NSArray *toolBarItems = [NSArray arrayWithObjects:space, barItem, space, nil];
        [self setToolbarItems:toolBarItems];
    }
    
    if ( table.style == UITableViewStylePlain )
        [table setSeparatorInset:UIEdgeInsetsZero];
    
    self.applyImageBorder = YES;
    
    [table setTintColor:UIColorWithRgb(DefaultRGB)];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isParent = (self.indexPath == nil);
    [[self navigationController] setToolbarHidden:isParent animated:animated];
    _progressViewItem.alpha = 0.0f;
    
    if ( isParent )
    {
        [self _reloadDataAnimated:animated];
    }
    
    [filesModel().files addObserver:self];
    [filesModel().amDownloadExamples addObserver:self];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [filesModel().files removeObserver:self];
    [filesModel().amDownloadExamples removeObserver:self];
}




- (void)viewDidLayoutSubviews
{
    CGSize size = self.view.bounds.size;
    //size.width = 320;  // !!
    [_progressViewItem setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _progressViewItem.frame = CGRectMake(0, 0, size.width, 44);
}





#pragma mark - private

- (void)_doClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)_doReload:(id)sender
{
    [filesModel().amDownloadExamples resetExamplesListing];
    [self _reloadDataAnimated:YES];
}


- (void)_reloadDataAnimated:(BOOL)animated
{
    NSDictionary *dictionary = [filesModel().amDownloadExamples getExamplesListing];
    NSDictionary *dataSource = [dictionary valueForKey:kDataSourceKey];

    [self _establishActivityIndicator:dataSource==nil];
    [_messageView setHidden:dataSource==nil];
    
    [self setDataSource:dataSource animated:animated];
}


- (void)_establishActivityIndicator:(BOOL)showIt
{
    if ( showIt )
    {
        if ( _activity == nil )
        {
            _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [_activity setColor:[UIColor grayColor]];
            [_activity setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|
                UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        
            UIView *selfView = self.view;
            CGSize size = selfView.bounds.size;
            CGPoint center = CGPointMake( size.width/2, size.height/2 );
            [_activity setCenter:center];
            [selfView addSubview:_activity];
        }
        [_activity startAnimating];
    }
    else
    {
        [_activity stopAnimating];
        [_activity removeFromSuperview];
        _activity = nil;
    }
}


- (id)_newFileViewerObjectWithClass:(Class)class
{
    NSString *nibName = NSStringFromClass(class);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    id anObject = [objects objectAtIndex:0];
    
    NSAssert( [anObject isMemberOfClass:class], @"Inconsistent Class from Nib" );   // Member!

    return anObject;
}

- (SWFileViewerProgressView *)_newProgressView
{
    SWFileViewerProgressView *view = [self _newFileViewerObjectWithClass:[SWFileViewerProgressView class]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


#pragma mark - SWSerializedTableViewController overrides



- (void)commitReturnObject:(id)value sectionMetaData:(NSDictionary *)sectionMetaData
{
   // NSLog( @"returnObject:%@", value );
   // NSLog( @"sectionmetadata:%@", sectionMetaData );
 
    NSDictionary *dict = value;
    if ( ![dict isKindOfClass:[NSDictionary class]] )
        return;
    
    NSString *projectName = [dict objectForKey:kProjectNameKey];
    NSArray *assets = [dict objectForKey:kAssetsKey];
    NSArray *bundled = [dict objectForKey:kBundledKey];
    
//    NSString *title = NSLocalizedString(@"Download Examples", nil);
//    SWBlockAlertView *alert = [SWBlockAlertView alloc] initWithTitle:<#(NSString *)#> message:<#(NSString *)#> delegate:<#(id)#> cancelButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil];
    
    
    [filesModel().amDownloadExamples downloadExampleNamed:projectName withBundled:bundled assets:assets];
}



//- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block
//{
//    if ( block == nil )
//        return;
//
//    if ( _thumbnail == nil )
//    {
//        _thumbnail = [[SWThumbnail alloc] initWithDefaultSize:CGSizeMake(60,40) defaultRgb:DefaultRGB];
//    }
//
//    [_thumbnail imageWithKey:imageKey completion:block];
//}




- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block
{
    if ( block == nil )
        return;
    
    if ( _cache == nil )
        _cache = [[NSCache alloc] init];
    
    UIImage *cachedImage = [_cache objectForKey:imageKey];
    if ( cachedImage )
    {
        block( cachedImage );  // call the block immediatelly
    }
    else
    {
        [filesModel().amDownloadExamples downloadThumbnailImageForExampleNamed:imageKey completion:^(UIImage *image)
        {
            if ( image != nil )
                [_cache setObject:image forKey:imageKey];
         
            block( image );
        }];
    }
}





#pragma mark - AppModelDownloadExamplesObserver

- (void)appFilesModelWillReceiveExamplesListing:(AppModelDownloadExamples *)amDownloadExamples
{

}

- (void)appFilesModel:(AppModelDownloadExamples *)amDownloadExamples didReceiveExamplesListingWithError:(NSError *)error
{
    if ( self.indexPath != nil )
        return;

    if ( error != nil )
    {
        [self _establishActivityIndicator:NO];
        return;
    }
    
    [self _reloadDataAnimated:YES];
}


#pragma mark - AppModelObserver (download)

- (void)appFilesModel:(AppModelFilesEx *)filesModel beginGroupDownloadForCategory:(FileCategory)category
{
    //if ( category == fileCategory )
    {
        NSString *text = NSLocalizedString( @"Download", nil);
        [_progressViewItem.labelFile setText:text];
        [_progressViewItem.progresView setProgress:0.0f];
        _progressViewItem.alpha = 1.0f;
        
        //[_toolbar setItems:_toolbarItemsProgress animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel willDownloadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    //if ( category == fileCategory )
    {
        NSString *format = NSLocalizedString( @"Downloading: %@", nil);
        NSString *text = [NSString stringWithFormat:format, fileName];
        [_progressViewItem.labelFile setText:text];
        
        //[_progressViewItem.progresView setProgress:0.5 animated:YES];
    }
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel groupDownloadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    //if ( category == fileCategory )
    {
        //float progressValue = (float)step/(float)stepCount;
        float progressValue = 0.1f + (float)step*(0.9f/(float)stepCount);
        [_progressViewItem.progresView setProgress:progressValue animated:YES];
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
        
        [_progressViewItem.labelFile setText:text];
    
    
        [_progressViewItem.progresView setProgress:1.0f];
        [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            _progressViewItem.alpha = 0.0f;
        }
        completion:^(BOOL finsh)
        {
            //[_toolbar setItems:_toolbarItems animated:YES];
        }];
    }
    
    if ( category == kFileCategoryAssetFile )
    {
        [self performSelector:@selector(delayedDismis:) withObject:nil afterDelay:1.0];
    }
}


- (void)delayedDismis:(id)dummy
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


