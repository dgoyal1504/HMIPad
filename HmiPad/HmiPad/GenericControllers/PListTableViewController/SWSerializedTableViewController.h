//
//  SWPListTableViewController.h
//  HmiPad
//
//  Created by Joan Martin on 8/22/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

static NSString * const kDataSourceKey = @"dataSource";
static NSString * const kTitleHeaderKey = @"headerTitle";
static NSString * const kTitleFooterKey = @"footerTitle";
static NSString * const kMetaDataKey = @"metaData";
static NSString * const kObjectTypeKey = @"objectType";
static NSString * const kReturnKey = @"return";
static NSString * const kSectionsKey = @"sections";
static NSString * const kRowsKey = @"rows";
static NSString * const kTextLabelTextKey = @"text";
static NSString * const kDetailTextLabelTextKey = @"detailText";
static NSString * const kImageNameKey = @"image";
static NSString * const kRowHeight = @"rowHeight";

@class SWSerializedTableViewController;
@class SWThumbnail;

//@protocol SWSerializedTableViewControllerDelegate <NSObject>
//
//@optional
//- (void)serializedController:(SWSerializedTableViewController*)controller commitReturnString:(NSString*)string sectionMetaData:(NSDictionary*)sectionMetaData;
//
//@end


@interface SWSerializedTableViewController : SWTableViewController

@property (nonatomic, readonly) NSIndexPath *indexPath;   // si es arrel es nil, sino conte la section/row respecte al pare

- (id)initWithPropertyList:(NSString*)propertyListFileName inBundle:(NSBundle*)bundle style:(UITableViewStyle)style;
- (id)initWithDataSource:(NSDictionary*)dataSource style:(UITableViewStyle)style parentController:(SWSerializedTableViewController*)parent indexPath:(NSIndexPath*)indexPath;

- (void)setDataSource:(NSDictionary*)dataSource animated:(BOOL)animated;
@property (nonatomic) BOOL applyImageBorder;

- (void)pushControllersToIndexPathPaths:(NSArray*)paths;  // cridar en el rootController
- (NSArray*)indexPathPaths; // cridar per a qualsevol controlador

// to override
- (void)commitReturnObject:(id)value sectionMetaData:(NSDictionary*)sectionMetaData;
- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block;
@end
