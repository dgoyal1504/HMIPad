//
//  SWPListTableViewController.m
//  HmiPad
//
//  Created by Joan Martin on 8/22/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSerializedTableViewController.h"
#import "SWSerializedTableViewCell.h"

//#import "SWThumbnail.h"

//#import "SWImageManager.h"
//#import "ColoredButton.h"
//
//#import "CALayer+ScreenShot.h"
////#import "UIImage+Resize.h"
//#import "Drawing.h"


@implementation SWSerializedTableViewController
{
    NSDictionary *_dataSource;
    SWSerializedTableViewCell *_anyCell;
    UIImage *_placeholderImage;
    //SWThumbnail *_thumbnail;
}

//@synthesize delegate = _delegate;

- (id)initWithPropertyList:(NSString*)propertyListFileName inBundle:(NSBundle*)bundle style:(UITableViewStyle)style
{
    NSBundle *_bundle = bundle==nil?[NSBundle mainBundle]:bundle;
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[_bundle pathForResource:propertyListFileName ofType:@"plist"]];
    
    return [self initWithDataSource:[dictionary objectForKey:kDataSourceKey] style:style parentController:nil indexPath:nil];
}


- (id)initWithDataSource:(NSDictionary*)dataSource style:(UITableViewStyle)style parentController:(SWSerializedTableViewController*)parent indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithStyle:style];
    if (self)
    {
        _indexPath = indexPath;
        _dataSource = dataSource;
    }
    return self;
}


- (void)setDataSource:(NSDictionary *)dataSource animated:(BOOL)animated
{
    UITableView *table = self.tableView;
    
    NSInteger oldSectionsCount = [(NSArray*)[_dataSource objectForKey:kSectionsKey] count];
    NSIndexSet *removeSects = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldSectionsCount)];
    
    _dataSource = dataSource;
    
    NSInteger newSectionsCount = [(NSArray*)[_dataSource objectForKey:kSectionsKey] count];
    NSIndexSet *addSects = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newSectionsCount)];
    
    UITableViewRowAnimation animation = UITableViewRowAnimationNone;
    if ( animated )
        animation = UITableViewRowAnimationFade;
    
    [table beginUpdates];
    
    [table deleteSections:removeSects withRowAnimation:animation];
    [table insertSections:addSects withRowAnimation:animation];
    
    [table endUpdates];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *table = self.tableView;
    
    if ([_dataSource objectForKey:kRowHeight])
    {
        CGFloat rowHeight = [[_dataSource objectForKey:kRowHeight] floatValue];
        table.rowHeight = rowHeight;
    }
    
    NSString *nibName = IS_IOS7 ? SWSerializedTableViewCellNibName : SWSerializedTableViewCellNibName6;
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [table registerNib:nib forCellReuseIdentifier:SWSerializedTableViewCellIdentifier];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}


#pragma mark - override in subclasses

// to override
- (void)commitReturnObject:(id)object sectionMetaData:(NSDictionary*)sectionMetaData
{
}


// to override
- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block
{
    block( nil);
}


#pragma mark - IndexPaths

- (void)pushControllersToIndexPathPaths:(NSArray*)paths
{
    SWSerializedTableViewController *ctrll = self;
    for ( NSIndexPath *indexPath in paths )
    {
        NSDictionary *section = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:indexPath.section];
        NSDictionary *row = [[section objectForKey:kRowsKey] objectAtIndex:indexPath.row];
        NSDictionary *metaData = [row objectForKey:kMetaDataKey];
    
        NSDictionary *dataSource = [metaData objectForKey:kDataSourceKey];
        if ( dataSource )
        {
            UITableView *tableView = ctrll.tableView;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];

            ctrll = [[[self class] alloc] initWithDataSource:dataSource style:UITableViewStylePlain parentController:self indexPath:indexPath];
            //ctrll.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
            ctrll.preferredContentSize = self.preferredContentSize;
            ctrll.title = [row objectForKey:kTextLabelTextKey];
        
            [self.navigationController pushViewController:ctrll animated:NO];
        }
    }
}


- (NSArray*)indexPathPaths
{
    NSMutableArray *paths = [NSMutableArray array];
    UINavigationController *navController = self.navigationController;
    NSArray *controllers = navController.viewControllers;
    for ( SWSerializedTableViewController *svc in controllers )
    {
        NSIndexPath *indexPath = svc.indexPath;
        if ( indexPath == nil ) continue;
        [paths addObject:indexPath];
    }
    return paths;
}








#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [(NSArray*)[_dataSource objectForKey:kSectionsKey] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDic = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:section];
    NSArray *rows = [sectionDic objectForKey:kRowsKey];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionDict = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:indexPath.section];
    NSDictionary *rowDict = [[sectionDict objectForKey:kRowsKey] objectAtIndex:indexPath.row];
    
    NSString *label = [rowDict objectForKey:kTextLabelTextKey];
    NSString *detail =  [rowDict objectForKey:kDetailTextLabelTextKey];
    
    NSDictionary *metaData = [rowDict objectForKey:kMetaDataKey];
    NSDictionary *dataSource = [metaData objectForKey:kDataSourceKey];
    
    BOOL leafCell = (dataSource.count == 0);
    
    UITableViewCell *cell = nil;

    if ( leafCell )
    {

        SWSerializedTableViewCell *sCell = [tableView dequeueReusableCellWithIdentifier:SWSerializedTableViewCellIdentifier forIndexPath:indexPath];

        //sCell.imageViewThumbnail.image = [self.thumbnailObject placeholderImage];
    
        sCell.labelMain.text = label;
        sCell.labelDetail.text = detail;
    
        NSString *imageKey = [rowDict objectForKey:kImageNameKey];
        
        [sCell.imageViewThumbnail setImage:nil];
        [self imageWithKey:imageKey completion:^(UIImage *image)
        {
            [sCell.imageViewThumbnail setImage:image];
        }];
        
        sCell.shouldApplyImageBorder = _applyImageBorder;
        sCell.accessoryType = UITableViewCellAccessoryNone;
        cell = sCell;
    }
    else
    {
        static NSString *RCellIdentifier = @"RCell";
        UITableViewCell *rCell = [tableView dequeueReusableCellWithIdentifier:RCellIdentifier];
        if ( rCell == nil )
        {
            rCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RCellIdentifier];
        }
        [rCell.textLabel setText:label];
        rCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = rCell;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionDic = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:section];
    return [sectionDic valueForKey:kTitleHeaderKey];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary *sectionDic = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:section];
    return [sectionDic valueForKey:kTitleFooterKey];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    NSDictionary *sectionDict = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:indexPath.section];
    NSDictionary *rowDict = [[sectionDict objectForKey:kRowsKey] objectAtIndex:indexPath.row];
    NSDictionary *metaData = [rowDict objectForKey:kMetaDataKey];
    NSDictionary *dataSource = [metaData objectForKey:kDataSourceKey];
    
    BOOL leafCell = (dataSource.count == 0);

    if ( leafCell )
    {
        if ( _anyCell == nil )
            _anyCell = [tableView dequeueReusableCellWithIdentifier:SWSerializedTableViewCellIdentifier];
        
        CGRect cellFrame = _anyCell.frame;
        cellFrame.size.width = tableView.bounds.size.width;
        [_anyCell setFrame:cellFrame];
        [_anyCell layoutSubviews];
    
        NSString *detailText = [rowDict valueForKey:kDetailTextLabelTextKey];
    
        height = [_anyCell heightForComment:detailText];
    }
    
    return height;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *section = [[_dataSource objectForKey:kSectionsKey] objectAtIndex:indexPath.section];
    NSDictionary *row = [[section objectForKey:kRowsKey] objectAtIndex:indexPath.row];
    NSDictionary *metaData = [row objectForKey:kMetaDataKey];
    
    NSString *returnValue = nil;
    NSDictionary *dataSource = nil;
    
    if ( nil != (returnValue = [metaData objectForKey:kReturnKey]) )
    {
        NSDictionary *metadataDict = [section objectForKey:kMetaDataKey];
        [self commitReturnObject:returnValue sectionMetaData:metadataDict];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ( nil != (dataSource = [metaData objectForKey:kDataSourceKey]) )
    {
        SWSerializedTableViewController *ctrll = [[[self class] alloc]
            initWithDataSource:dataSource style:UITableViewStylePlain parentController:self indexPath:indexPath];
        //ctrll.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        ctrll.preferredContentSize = self.preferredContentSize;
        ctrll.title = [row objectForKey:kTextLabelTextKey];
        
        [self.navigationController pushViewController:ctrll animated:YES];
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ( [cell isKindOfClass:[SWSerializedTableViewCell class]] )
//        [(SWSerializedTableViewCell *)cell labelDetail].backgroundColor = [UIColor redColor];
//}


@end
