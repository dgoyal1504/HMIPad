//
//  SWAddObjectViewController.m
//  HmiPad
//
//  Created by Joan Martin on 8/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWAddObjectViewController.h"

#import "SWDocumentModel.h"
#import "SWPage.h"
#import "SWItem.h"
#import "SWAlarm.h"
#import "SWProjectUser.h"
#import "SWDataLoggerItem.h"
#import "SWSourceItem.h"
#import "SWThumbnail.h"

#import "SWModelManager.h"
//#import "SWConfigurationController.h"

#import "SWPlcDevice.h"
#import "SWColor.h"


#define DefaultRGB TextDefaultColor
//#define DefaultRGB (Theme_RGB(0, 128, 0, 0))

@implementation SWAddObjectViewController
{
    SWThumbnail *_thumbnail;
}

@synthesize delegate = _delegate;


+ (NSDictionary*)filterObjectTypesFromDataSource:(NSDictionary*)dataSource withAllowedObjectTypes:(SWObjectType)allowedObjectTypes
{
    NSMutableArray *sections = [dataSource valueForKey:kSectionsKey];
    NSArray *sectionsCopy = [sections copy];

    for (NSDictionary *section in sectionsCopy)
    {
        NSDictionary *metaData = [section valueForKey:kMetaDataKey];
        NSInteger objectType = [[metaData valueForKey:kObjectTypeKey] integerValue];
        
        if (!(objectType & allowedObjectTypes))
            [sections removeObject:section];
    }
    
    return dataSource;
}


- (id)initWithDataSource:(NSDictionary *)dataSource style:(UITableViewStyle)style parentController:(SWAddObjectViewController *)parent indexPath:(NSIndexPath*)indexPath
{
    self = [super initWithDataSource:dataSource style:style parentController:parent indexPath:indexPath];
    if ( self )
    {
        //[super setDelegate:self];
        _documentModel = parent.documentModel;
        _allowedObjectTypes = parent.allowedObjectTypes;
        _delegate = parent.delegate;
    }
    return self;
}


- (id)initWithDocument:(SWDocumentModel*)documentModel allowedObjectTypes:(SWObjectType)objectTypes
{
    NSDictionary *dic = [[NSDictionary dictionaryWithContentsOfFile:
        [[NSBundle mainBundle] pathForResource:@"AddMenu" ofType:@"plist"]] valueForKey:kDataSourceKey];
    
    NSMutableDictionary *mutableDataSource = (__bridge_transfer NSMutableDictionary *)
        CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFDictionaryRef)dic, kCFPropertyListMutableContainers);

    NSDictionary *dataSource = [self.class filterObjectTypesFromDataSource:mutableDataSource withAllowedObjectTypes:objectTypes];
    
    self.title = NSLocalizedString(@"Item Creation", nil);
    
// Create json representation
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    NSMutableString *output = [NSMutableString stringWithString:NSTemporaryDirectory()];
//    [output appendFormat:@"%@.json",@"AddMenu"];
//    [data writeToFile:output atomically:YES];
    
    self = [super initWithDataSource:dataSource style:UITableViewStyleGrouped parentController:nil indexPath:nil];
    if (self)
    {
        //[super setDelegate:self];
        _documentModel = documentModel;
        _allowedObjectTypes = objectTypes;
        _delegate = nil;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView *table = self.tableView;
    if ( table.style == UITableViewStylePlain )
        [table setSeparatorInset:UIEdgeInsetsZero];
    
    //[table setTintColor:[UIColor grayColor]];
    //[table setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
    [table setTintColor:UIColorWithRgb(DefaultRGB)];
}




#pragma mark SWSerializedTableViewController overrides

- (void)commitReturnObject:(id)value sectionMetaData:(NSDictionary *)sectionMetaData
{
    id addedObject = nil;
    
    NSString *string = value;
    if ( ![string isKindOfClass:[NSString class]] )
        return;
    
    Class objectClass = NSClassFromString(string);
    
    NSInteger objectType = [[sectionMetaData valueForKey:kObjectTypeKey] integerValue];
    objectType = objectType & _allowedObjectTypes;
    
    switch (objectType)
    {
        case SWObjectTypeVisibleItem:
        {
            NSInteger pageIndexInsertion = _documentModel.selectedPageIndex;
            
            if ([_delegate respondsToSelector:@selector(addObjectViewControllerPageIndexToInsertItems:)])
                pageIndexInsertion = [_delegate addObjectViewControllerPageIndexToInsertItems:self];
            
            // si encara no tenim un index bo, creem una pagina nova per el item
            if ( pageIndexInsertion == NSNotFound )
            {
                SWPage *page = [[SWPage alloc] initInDocument:_documentModel];
                pageIndexInsertion = _documentModel.pages.count;
                NSIndexSet *indexset = [NSIndexSet indexSetWithIndex:pageIndexInsertion];
                [_documentModel insertPages:@[page] atIndexes:indexset];
                [_documentModel selectPageAtIndex:pageIndexInsertion];
            }
            
            SWPage *page = [_documentModel.pages objectAtIndex:pageIndexInsertion];
            SWItem *item = [[objectClass alloc] initInPage:page];
            
            CGSize sizeP_pad = [page defaultSizePortraitWithDeviceIdiom:SWDeviceInterfaceIdiomPad];
            CGSize sizeL_pad = [page defaultSizeLandscapeWithDeviceIdiom:SWDeviceInterfaceIdiomPad];
            CGSize sizeP_pho = [page defaultSizePortraitWithDeviceIdiom:SWDeviceInterfaceIdiomPhone];
            CGSize sizeL_pho = [page defaultSizeLandscapeWithDeviceIdiom:SWDeviceInterfaceIdiomPhone];
            
            SWValue *valueP_pad = item.framePortrait;
            SWValue *valueL_pad = item.frameLandscape;
            SWValue *valueP_pho = item.framePortraitPhone;
            SWValue *valueL_pho = item.frameLandscapePhone;

            CGRect frameP_pad = valueP_pad.valueAsCGRect;
            CGRect frameL_pad = valueL_pad.valueAsCGRect;
            CGRect frameP_pho = valueP_pho.valueAsCGRect;
            CGRect frameL_pho = valueL_pho.valueAsCGRect;
            
            frameP_pad.origin = CGPointMake(roundf(sizeP_pad.width/2.0 - frameP_pad.size.width/2.0), roundf(sizeP_pad.height/2.0 - frameP_pad.size.height/2.0));
            frameL_pad.origin = CGPointMake(roundf(sizeL_pad.width/2.0 - frameL_pad.size.width/2.0), roundf(sizeL_pad.height/2.0 - frameL_pad.size.height/2.0));
            frameP_pho.origin = CGPointMake(roundf(sizeP_pho.width/2.0 - frameP_pho.size.width/2.0), roundf(sizeP_pho.height/2.0 - frameP_pho.size.height/2.0));
            frameL_pho.origin = CGPointMake(roundf(sizeL_pho.width/2.0 - frameL_pho.size.width/2.0), roundf(sizeL_pho.height/2.0 - frameL_pho.size.height/2.0));
            
            valueP_pad.valueAsCGRect = frameP_pad;
            valueL_pad.valueAsCGRect = frameL_pad;
            valueP_pho.valueAsCGRect = frameP_pho;
            valueL_pho.valueAsCGRect = frameL_pho;


//            CGRect frame = [[UIApplication sharedApplication].delegate window].bounds; // <----- es considera un "apanyo" ???
//            CGRect frameP = framePortrait.valueAsCGRect;
//            CGRect frameL = frameLandscape.valueAsCGRect;
//            
//            frameP.origin = CGPointMake(roundf(frame.size.width/2.0 - frameP.size.width/2.0), roundf(frame.size.height/2.0 - frameP.size.height/2.0));
//            frameL.origin = CGPointMake(roundf(frame.size.height/2.0 - frameL.size.height/2.0), roundf(frame.size.width/2.0 - frameL.size.width/2.0));
//            
//            framePortrait.valueAsCGRect = frameP;
//            frameLandscape.valueAsCGRect = frameL;
            
            [page addItem:item];
            
            addedObject = item;
            break;
        }
            
        case SWObjectTypePage:
        {
            SWPage *page = [[SWPage alloc] initInDocument:_documentModel];
            
            NSInteger pageIndexInsertion = _documentModel.selectedPageIndex;
            if (pageIndexInsertion == NSNotFound)
            {
                pageIndexInsertion = _documentModel.pages.count;
            }
            else
            {
                pageIndexInsertion++;
            }
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:pageIndexInsertion];
            
            [_documentModel insertPages:@[page] atIndexes:indexSet]; // La inserció de pàgina provoca el canvi!
            //[_documentModel selectPageAtIndex:pageIndexInsertion]; // No cal fer el canvi manualment
            
            addedObject = page;
            break;
        }
            
        case SWObjectTypeBackgroundItem:
        {
            SWBackgroundItem *backgroundItem = [[objectClass alloc] initInDocument:_documentModel];
            [_documentModel addBackgroundItem:backgroundItem];

            addedObject = backgroundItem;
            break;
        }
            
        case SWObjectTypeAlarm:
        {
            SWAlarm *alarm = [[SWAlarm alloc] initInDocument:_documentModel];
            [_documentModel addAlarmItem:alarm];
            
            addedObject = alarm;
            break;
        }
        
        case SWObjectTypeUser:
        {
            SWProjectUser *user = [[SWProjectUser alloc] initInDocument:_documentModel];
            [_documentModel addProjectUser:user];
            
            addedObject = user;
            break;
        }
        
        case SWObjectTypeDatabase:
        {
            SWDataLoggerItem *database = [[SWDataLoggerItem alloc] initInDocument:_documentModel];
            [_documentModel addDataLoggerItem:database];
            
            addedObject = database;
            break;
        }
            
        case SWObjectTypeSource:
        {
            SWSourceItem *source = [[SWSourceItem alloc] initInDocument:_documentModel protocolString:string];
            //[source.plcDevice setProtocolAsString:string];
            [_documentModel addSourceItem:source];
            
            addedObject = source;
            break;
        }
            
        default:
            break;
    }
    
//    if (_presentConfigurator && addedObject)
//    {
//    
//        SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
//        [manager presentModelConfiguratorForObject:addedObject animated:NO];
//    }
    
    if ([_delegate respondsToSelector:@selector(addObjectViewController:didAddObject:)])
        [_delegate addObjectViewController:self didAddObject:addedObject];
    
    if ( [self presentingViewController] != nil )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



//- (SWThumbnail*)thumbnailObject
//{
//    if ( _thumbnail == nil )
//    {
//        _thumbnail = [[SWThumbnail alloc] initWithDefaultSize:CGSizeMake(60,40) defaultRgb:DefaultRGB];
//        _thumbnail.delegate = nil;
//    }
//    return _thumbnail;
//}


- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block
{
    if ( block == nil )
        return;

    if ( _thumbnail == nil )
    {
        _thumbnail = [[SWThumbnail alloc] initWithDefaultSize:CGSizeMake(60,40) defaultRgb:DefaultRGB];
    }

    [_thumbnail imageWithKey:imageKey completion:block];
}



@end


