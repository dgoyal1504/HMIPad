//
//  SWModelManager.m
//  HmiPad
//
//  Created by Joan Martin on 8/28/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWModelManager.h"
//#import "SWAppDelegate.h"     // a eliminar, passar el controlador (el projectnavigator) a la inicialitzacio

// -- Controllers -- //
#import "SWModelBrowserController.h"
#import "SWArrayTypeBrowserController.h"
#import "SWPageBrowserController.h"
#import "SWObjectBroswerController.h"
#import "SWSourceVariablesListController.h"

#import "SWSegmentController.h"
#import "SWColorListPickerController.h"
#import "SWConfigurationController.h"
// ----------------- //

#import "SWDocument.h"
#import "SWPage.h"
#import "SWItem.h"
#import "SWSourceItem.h"
#import "SWSourceNode.h"
#import "SWAlarm.h"
#import "SWSystemItem.h"

#import "SWPropertyDescriptor.h"
#import "SWValue.h"
#import "SWReadExpression.h"

#import "AppModel.h"
#import "SWColor.h"

@interface _SWConfiguringPopoverInfo : NSObject
{
    @public
    CGPoint _position;
    id _configuringObject;
    CGPoint _offset;
}

- (id)initWithConfiguringObject:(id)object position:(CGPoint)position offset:(CGPoint)offset;
+ (_SWConfiguringPopoverInfo*)configuringPopoverInfoWithObject:(id)object position:(CGPoint)position offset:(CGPoint)offset;

@end

@implementation _SWConfiguringPopoverInfo

- (id)initWithConfiguringObject:(id)object position:(CGPoint)position offset:(CGPoint)offset
{
    self = [super init];
    if (self)
    {
        _configuringObject = object;
        _position = position;
        _offset = offset;
    }
    return self;
}

+ (_SWConfiguringPopoverInfo*)configuringPopoverInfoWithObject:(id)object position:(CGPoint)position offset:(CGPoint)offset
{
    return [[_SWConfiguringPopoverInfo alloc] initWithConfiguringObject:object position:position offset:offset];
}

@end

//static NSMutableArray *_modelManagers = nil;


static SWModelManagerCenter *_instance = nil;

@implementation SWModelManagerCenter
{
    NSMutableArray *_modelManagers;
}

+ (SWModelManagerCenter*)defaultCenter
{
    if (!_instance)
        _instance = [[SWModelManagerCenter alloc] init];
    
    return _instance;
}

- (SWModelManager*)managerForDocumentModel:(SWDocumentModel*)documentModel
{
    SWModelManager *modelManager = nil;
    
    for (SWModelManager *mm in _modelManagers)
    {
        if (mm.documentModel == documentModel) 
        {
            modelManager = mm;
            break;
        }
    }
    
    return modelManager;
}


- (void)addManagerWithDocumentModel:(SWDocumentModel*)documentModel forPresentingInController:(UIViewController*)presentingController
{
    if ( !documentModel )
        return ;

    if (!_modelManagers)
        _modelManagers = [NSMutableArray array];
    
    SWModelManager *modelManager = [[SWModelManager alloc] initWithDocumentModel:documentModel forPresentingInController:presentingController];
    [_modelManagers addObject:modelManager];
}


- (void)removeManagerWithDocumentModel:(SWDocumentModel*)documentModel // <----- S'ha de cridar aquest mètode quan es vulgui eliminar el projecte, 
{
    if ( !documentModel )
        return ;
    
    SWModelManager *modelManager = [self managerForDocumentModel:documentModel];
    [_modelManagers removeObjectIdenticalTo:modelManager];
    [modelManager dismissAllModelConfiguratorsAnimated:NO];
}


@end





@implementation SWModelManager
{
    // -- Model Manager -- //
    SWFloatingPopoverManager *_floatingPopoverManager;


    // -- Model Seeker Stuff -- //
    __weak id <SWModelManagerDelegate> _seekerDelegate;
    __weak id _seekedObject;
    __weak UIViewController *_presentingController;
    //__weak SWFloatingPopoverController *_modelBrowser;
    
    // -- Model Browser Stuff -- //
//    CGPoint _modelBrowserPosition;
//    CGPoint _modelBrowserOffset;
    _SWConfiguringPopoverInfo *_modelBrowserInfo;
    id _modelBrowserIdentifyingObject;
    
    // -- Persistence Stuff -- //
    NSMutableArray *_openedConfigurators;  // conte SW
    NSMutableArray *_storedConfiguriatorInfos;  // conte _SWConfiguringPopoverInfo
    //BOOL _wasModelBrowserPresented;
    
    BOOL _searchActiveInModelBrowser;
    NSString *_searchTextInModelBrowser;
}

@synthesize documentModel = _documentModel;
@synthesize contentSizeInPopover = _contentSizeInPopover;
//@synthesize delegate = _delegate;

//+ (SWModelManager*)managerForDocumentModel:(SWDocumentModel*)documentModel
//{
//    if (!_modelManagers)
//        _modelManagers = [NSMutableArray array];
//    
//    SWModelManager *modelManager = nil;
//
//    for (SWModelManager *mm in _modelManagers)
//    {
//        if (mm.documentModel == documentModel) 
//        {
//            modelManager = mm;
//            break;
//        }
//    }
//    
//    if (!modelManager)
//    {
//        modelManager = [[SWModelManager alloc] initWithDocumentModel:documentModel];
//        [_modelManagers addObject:modelManager];
//    }
//    
//    return modelManager;
//}

- (id)initWithDocumentModel:(SWDocumentModel*)documentModel forPresentingInController:(UIViewController *)presentingController
{
    self = [super init];
    if (self)
    {
        _documentModel = documentModel;
        _presentingController = presentingController;
        _contentSizeInPopover = CGSizeMake(320, 460);
        _seekerContentSizeInPopover = CGSizeMake(320, 320);
        _modelBrowserIdentifyingObject = _documentModel;
        _modelBrowserInfo = [_SWConfiguringPopoverInfo configuringPopoverInfoWithObject:_documentModel position:CGPointZero offset:CGPointZero];
        _floatingPopoverManager = [[SWFloatingPopoverManager alloc] init];
        _openedConfigurators = [NSMutableArray array];
        _storedConfiguriatorInfos = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    NSLog( @"ModelManager dealloc");
}


#pragma mark Private Methods

/**
 * Arbre de pares-fills:
 *
 * <nil>  <documentModel>     <SWArrayTypePages>              <SWPage>
 *                            <SWArrayTypeBackgroundItem>
 *                            <SWArrayTypeAlarm>
 *                            <SWArrayTypeSources>            <SWSourceItem>
 *
 */

- (id)_parentObjectForObject:(id)object
{
    id parent = nil;
    
    if ([object isKindOfClass:[SWDocumentModel class]])
        parent = nil;
    
    else if ([object isKindOfClass:[NSNumber class]])
        parent = _documentModel;
    
    else if ([object isKindOfClass:[SWPage class]])
        parent = [NSNumber numberWithInteger:SWArrayTypePages];
    
    else if ([object isKindOfClass:[SWItem class]])
        parent = [(SWItem*)object page];
    
    else if ([object isKindOfClass:[SWSourceItem class]])
        parent = [NSNumber numberWithInteger:SWArrayTypeSources];
    
    else if ([object isKindOfClass:[SWSystemItem class]])
        parent = [NSNumber numberWithInteger:SWArrayTypeSystemItems];
    
    else if ([object isKindOfClass:[SWValue class]])
    {
        parent = [(SWValue*)object holder];
        if ([parent isKindOfClass:[SWSourceItem class]] ||
            [parent isKindOfClass:[SWItem class]] ||
            [parent isKindOfClass:[SWSystemItem class]])
            parent = [self _parentObjectForObject:parent];
    }
    
    return parent;
}

- (UIViewController<SWModelBrowserViewController>*)_viewControllerForObject:(id)object
{
    UIViewController <SWModelBrowserViewController> *vc = nil;
    
    if ([object isKindOfClass:[SWDocumentModel class]])
        vc = [[SWModelBrowserController alloc] initWithModel:_documentModel];
    
    else if ([object isKindOfClass:[NSNumber class]])
        vc = [[SWArrayTypeBrowserController alloc] initWithDocumentModel:_documentModel andArrayType:[(NSNumber*)object integerValue]];
    
    else if ([object isKindOfClass:[SWPage class]])
        vc = [[SWPageBrowserController alloc] initWithPage:object];
    
    else if ([object isKindOfClass:[SWSourceItem class]])
        vc = [[SWSourceVariablesListController alloc] initWithSourceItem:object];
    
    else if ([object isKindOfClass:[SWObject class]])
        vc = [[SWObjectBroswerController alloc] initWithModelObject:object];
    
    else if ([object isKindOfClass:[SWValue class]])
    {
        id holder = [(SWValue*)object holder];
        
        if ([holder isKindOfClass:[SWSourceItem class]])
            vc = [[SWSourceVariablesListController alloc] initWithSourceItem:holder];
        
        else if ([holder isKindOfClass:[SWObject class]])
            vc = [[SWObjectBroswerController alloc] initWithModelObject:holder];
    }
        
    else
        NSLog(@"Unrecognized class: %@",[[object class] description]);
    
    return vc;
}

- (id)_objectForViewController:(UIViewController*)viewController
{    
    id object = nil;
    
    if ([viewController isKindOfClass:[SWModelBrowserController class]])
        object = _documentModel;
    
    else if ([viewController isKindOfClass:[SWArrayTypeBrowserController class]])
        object = [NSNumber numberWithInteger:[(SWArrayTypeBrowserController*)viewController arrayType]];

    else if ([viewController isKindOfClass:[SWPageBrowserController class]])
        object = [(SWPageBrowserController*)viewController page];
    
    else if ([viewController isKindOfClass:[SWSourceVariablesListController class]])
        object = [(SWSourceVariablesListController*)viewController sourceItem];
    
    return object;
}

- (NSMutableArray*)_arrayWithViewControllersForObject:(id)object browsingStyle:(SWModelBrowsingStyle)browsingStyle acceptedTypes:(NSIndexSet*)acceptedTypes
{
    NSMutableArray *array = [NSMutableArray array];
    
    id objectIterator = object;
    
    while (objectIterator != nil)
    {
        UIViewController <SWModelBrowserViewController> *vc = [self _viewControllerForObject:objectIterator];
        if (browsingStyle == SWModelBrowsingStyleManagement)
            vc.contentSizeForViewInPopover = _contentSizeInPopover;
        else if (browsingStyle == SWModelBrowsingStyleSeeker)
            vc.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        vc.browsingStyle = browsingStyle;
        vc.acceptedTypes = acceptedTypes;
        [array addObject:vc];
        objectIterator = [self _parentObjectForObject:objectIterator];
    }
    
    return array;
}

- (NSArray*)_helperControllersForType:(SWType)type defaultValue:(id)defaultValue
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (type == SWTypeColor)
    {
        UIColor *color = defaultValue;
        
        SWColorPickerViewController *colorPicker = [[SWColorPickerViewController alloc] initWithColor:color];
        colorPicker.delegate = self;
        colorPicker.title = NSLocalizedString(@"Color", nil);
        colorPicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        
        [array addObject:colorPicker];
        
        SWColorListPickerController *colorListPicker = [[SWColorListPickerController alloc] initWithStyle:UITableViewStylePlain andColor:color];
        colorListPicker.delegate = self;
        colorListPicker.title = NSLocalizedString(@"Color List", nil);
        colorListPicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        
        [array addObject:colorListPicker];
        
        colorPicker.colorPicker = colorListPicker;
        colorListPicker.colorPicker = colorPicker;
    }
    else if (type == SWTypeFont)
    {
        SWFontPickerViewController *fontPicker = [[SWFontPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        fontPicker.selectedFontName = defaultValue;
        fontPicker.delegate = self;
        fontPicker.title = NSLocalizedString(@"Font", nil);
        fontPicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        
        [array addObject:fontPicker];
    }
    else if (type == SWTypeImagePath)
    {
    
#warning TODO aqui faltaria afegir default value, en el ImagePickerController que la imatge es vegi seleccionada
        NSString *path = [model() filesRootDirectoryForCategory:kFileCategoryDocument];
        SWImagePickerController *imagePicker = [[SWImagePickerController alloc] initWithContentsAtPath:path];
        imagePicker.selectedFileName = defaultValue;
        imagePicker.delegate = self;
        imagePicker.allowsDeletion = NO;
        imagePicker.title = NSLocalizedString(@"Image",nil);
        imagePicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        
        [array addObject:imagePicker];
    }
    
    return array;
}

- (void)_presentConfiguratorForConfiguringPopoverInfo:(_SWConfiguringPopoverInfo*)scp animated:(BOOL)animated
{
    id object = scp->_configuringObject;
    //SWFloatingPopoverController *fpc = [[SWFloatingPopoverManager defaultManager] floatingPopoverControllerWithKey:object];
    SWFloatingPopoverController *fpc = [_floatingPopoverManager floatingPopoverControllerWithKey:object];
    
    if (fpc)
    {
        [fpc bringToFront];
    }
    else
    {
        UIViewController *vc = nil;
        if ( object == _documentModel )
        {
        
            SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
            UINavigationController *navigator = [manager modelBrowserAtStartingObject:_modelBrowserIdentifyingObject acceptedTypes:nil];
            for (UIViewController *controller in navigator.viewControllers)
            {
                if ([controller isKindOfClass:[SWModelBrowserController class]])
                    if (_searchActiveInModelBrowser)
                        [(SWModelBrowserController*)controller setSearchText:_searchTextInModelBrowser];
            }
            vc = navigator;
        }
        else
        {
            vc = [SWConfigurationController configuratorForObject:object];
        }
        
        if (!vc)
            return;
        
        vc.contentSizeForViewInPopover = CGSizeMake(320, 480);
        
        [self _prepareViewController:vc forContentOffset:scp->_offset];
        
//        SWAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//        UIViewController *dc = (id)appDelegate.documentController;
//
//        fpc = [[SWFloatingPopoverController alloc] initWithContentViewController:vc];
        fpc = [[SWFloatingPopoverController alloc] initWithContentViewController:vc
            withKey:object forPresentingInController:_presentingController];
        fpc.frameColor = DarkenedUIColorWithRgb(SystemDarkerBlueColor, 1.2f);
        fpc.showsCloseButton = YES;
        fpc.delegate = self;
        
        [_openedConfigurators addObject:fpc];
        
        if (CGPointEqualToPoint(scp->_position, CGPointZero))
            [_floatingPopoverManager /*[SWFloatingPopoverManager defaultManager]*/ presentFloatingPopover:fpc animated:animated /*withKey:object*/];
        else
            [_floatingPopoverManager /*[SWFloatingPopoverManager defaultManager]*/ presentFloatingPopover:fpc atPoint:scp->_position animated:animated /*withKey:object*/];
    }
}

- (CGPoint)_contentOffsetFromViewController:(UIViewController*)vc
{
    CGPoint offset;
    
    if ([vc isKindOfClass:[UINavigationController class]])
        vc = [(UINavigationController*)vc topViewController];
    
    if ([vc respondsToSelector:@selector(tableView)])
    {
        UITableView *tableView = [(id)vc tableView];
        offset = tableView.contentOffset;
    }
    
    return offset;
}

- (void)_prepareViewController:(UIViewController*)vc forContentOffset:(CGPoint)offset
{
    if (!vc.isViewLoaded)
        (void)vc.view; // <-------- En cas de que la vista no estigui creada, obliguem a que es crei, ja que necessitem interactuar amb el seu tableView.

    if ([vc isKindOfClass:[UINavigationController class]])
        vc = [(UINavigationController*)vc topViewController];
    
    if ([vc respondsToSelector:@selector(tableView)])
        [[(id)vc tableView] setContentOffset:offset];
}

#pragma mark Public Methods

- (UINavigationController*)modelBrowser
{
    return [self modelBrowserAtStartingObject:_documentModel acceptedTypes:nil];
}

- (UINavigationController*)modelBrowserAtStartingObject:(id)object acceptedTypes:(NSIndexSet*)acceptedTypes
{
    NSMutableArray *array = [self _arrayWithViewControllersForObject:object browsingStyle:SWModelBrowsingStyleManagement acceptedTypes:acceptedTypes];
    
//    UIViewController *firstVC = [array lastObject];
//    [array removeLastObject];
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:firstVC];
//    
//    while (array.count > 0)
//    {
//        UIViewController *nextVC = [array lastObject];
//        [array removeLastObject];
//        
//        [navigationController pushViewController:nextVC animated:NO];
//    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    
    for ( NSInteger i=array.count-1 ; i>=0 ; i-- )
    {
        UIViewController *nextVC = [array objectAtIndex:i];
        [navigationController pushViewController:nextVC animated:NO];
    }
    
    return navigationController;
}

//- (SWSegmentController*)modelSeekerAtStartingPoint_V:(id)object valueType:(SWType)type delegate:(id<SWModelManagerDelegate>)delegate
//{
//    _seekerDelegate = delegate;
//    _seekedObject = nil;
//    
//    NSIndexSet *acceptedTypes = compatibleTypesForType(type);
//    
//    NSMutableArray *array = [self _arrayWithViewControllersForObject:object browsingStyle:SWModelBrowsingStyleSeeker acceptedTypes:acceptedTypes];
//    [array makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
//    
//    NSMutableArray *controllers = [NSMutableArray array];
//    
//    [controllers addObject:[array lastObject]];
//    [array removeLastObject];
//        
//    NSArray *helperControllers = [self _helperControllersForType:type defaultValue:nil];
//    [controllers addObjectsFromArray:helperControllers];
//    
//    SWSegmentController *segmentController = [[SWSegmentController alloc] initWithTabbedViewControllers:controllers];
//    
//    while (array.count > 0)
//    {
//        UIViewController *nextVC = [array lastObject];
//        [array removeLastObject];
//        
//        [segmentController pushViewController:nextVC animated:NO];
//    }
//    
//    return segmentController;
//}
//
//- (SWSegmentController*)modelSeekerForValue_V:(SWValue*)value delegate:(id<SWModelManagerDelegate>)delegate
//{
//    if (value)
//        NSAssert([value isKindOfClass:[SWValue class]],nil);
//    
//    _seekerDelegate = delegate;
//    
//    SWPropertyDescriptor *descriptor = value.valueDescription;
//    SWType type = descriptor.type;
//    
//    _seekedObject = nil;
//    if ([value isKindOfClass:[SWExpression class]])
//        _seekedObject = [(SWExpression*)value getExclusiveSource];
//
//    _seekedObject = _seekedObject==nil?_documentModel:_seekedObject;
//    
//    NSIndexSet *acceptedTypes = value?compatibleTypesForType(type):nil;
//    
//    NSMutableArray *array = [self _arrayWithViewControllersForObject:_seekedObject browsingStyle:SWModelBrowsingStyleSeeker acceptedTypes:acceptedTypes];
//    [array makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
//    
//    NSMutableArray *controllers = [NSMutableArray array];
//        
//    [controllers addObject:[array lastObject]];
//    [array removeLastObject];
//    
//    id defaultValue = nil;
//    if (type == SWTypeColor)
//        defaultValue = value.valueAsColor;
//    else if (type == SWTypeFont)
//        defaultValue = value.valueAsString;
////    else if (type == SWTypeImagePath)
//        // Nothing to do
//    
//    NSArray *helperControllers = [self _helperControllersForType:type defaultValue:defaultValue];
//    [controllers addObjectsFromArray:helperControllers];
//    
//    SWSegmentController *segmentController = [[SWSegmentController alloc] initWithTabbedViewControllers:controllers];
//    
//    while (array.count > 0)
//    {
//        UIViewController *nextVC = [array lastObject];
//        [array removeLastObject];
//        
//        [segmentController pushViewController:nextVC animated:NO];
//    }
//    
//    return segmentController;
//}



- (SWSegmentController*)_modelSeekerWithStartingObject:(id)object acceptedTypes:(NSIndexSet*)acceptedTypes
            helperType:(SWType)helperType defaultValue:(id)defaultValue
{
    // array amb els controladors a presentar
    NSMutableArray *controllers = [NSMutableArray array];
    
    // controladors tipus browser
    NSMutableArray *array = [self _arrayWithViewControllersForObject:object browsingStyle:SWModelBrowsingStyleSeeker acceptedTypes:acceptedTypes];
    [array makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    
    [controllers addObject:[array lastObject]];
    [array removeLastObject];
    
    // controladors tipus helper
    NSArray *helperControllers = [self _helperControllersForType:helperType defaultValue:defaultValue];
    [controllers addObjectsFromArray:helperControllers];
    
#warning TODO, si no hi ha helperControllers tornar un UINavigationController en lloc de un SWSegmentController
    
    // un contolador nou amb els anteriors
    SWSegmentController *segmentController = [[SWSegmentController alloc] initWithTabbedViewControllers:controllers];
    
    while (array.count > 0)
    {
        UIViewController *nextVC = [array lastObject];
        [array removeLastObject];
        
        [segmentController pushViewController:nextVC animated:NO];
    }
    
    return segmentController;
}



- (SWSegmentController*)modelSeekerForValue:(SWValue*)value delegate:(id<SWModelManagerDelegate>)delegate
{
    if (value)
        NSAssert([value isKindOfClass:[SWValue class]],nil);
    
    _seekerDelegate = delegate;
    
    // seekedObject

    id object = nil;
    if ([value isKindOfClass:[SWExpression class]])
        object = [(SWExpression*)value getExclusiveSource];

    if ( object == nil )
        object = _documentModel;
    
    _seekedObject = object;
    
    // tipus i default value per els controladors helper

    SWPropertyDescriptor *descriptor = value.valueDescription;
    SWType type = descriptor.type;
    
    id defaultValue = nil;
    if (type == SWTypeColor)
        defaultValue = value.valueAsColor;
    else if (type == SWTypeFont)
        defaultValue = value.valueAsString;
    else if (type == SWTypeImagePath)
        defaultValue = value.valueAsString;
    
    // tipus acceptats per els controladors browser
    
    NSIndexSet *acceptedTypes = value?compatibleTypesForType(type):nil;
    
    // creem i tornem el segmentController
    
    SWSegmentController *segmentController = [self _modelSeekerWithStartingObject:object
            acceptedTypes:acceptedTypes helperType:type defaultValue:defaultValue];
    
    return segmentController;
}



- (SWSegmentController*)modelSeekerAtStartingObject:(id)object valueType:(SWType)type delegate:(id<SWModelManagerDelegate>)delegate
{
    _seekerDelegate = delegate;
    _seekedObject = nil;
    
    if ( object == nil )
        object = _documentModel;
    
    SWSegmentController *segmentController = [self _modelSeekerWithStartingObject:object
            acceptedTypes:nil helperType:type defaultValue:nil];
    
    return segmentController;
}



- (id)currentSeekedObject
{
    return _seekedObject;
}

//- (void)prepareForDeletion
//{
//    [_modelManagers removeObjectIdenticalTo:self];
//}

// -- Managing the default model browser -- //
/**
 * This model browser is presented in a floating popover and the position and the navigation is persistent
 */
 
//- (void)presentModelBrowserAnimatedV:(BOOL)animated
//{
//    SWFloatingPopoverController *floatingPopover = [[SWFloatingPopoverManager defaultManager] floatingPopoverControllerWithKey:_documentModel];
//    
//    if (floatingPopover)
//    {
//        [floatingPopover bringToFront];
//    }
//    else
//    {
//        SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_documentModel];
//        UINavigationController *vc = [manager modelBrowserAtStartingObject:_modelBrowserIdentifyingObject acceptedTypes:nil];
//        for (UIViewController *controller in vc.viewControllers)
//        {
//            if ([controller isKindOfClass:[SWModelBrowserController class]])
//                if (_searchActiveInModelBrowser)
//                     [(SWModelBrowserController*)controller setSearchText:_searchTextInModelBrowser];
//        }
//        
//        [self _prepareViewController:vc forContentOffset:_modelBrowserOffset];
//        
////        SWAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
////        UIViewController *dc = (id)appDelegate.documentController;
//        
////        floatingPopover = [[SWFloatingPopoverController alloc] initWithContentViewController:vc];
//        floatingPopover = [[SWFloatingPopoverController alloc] initWithContentViewController:vc forPresentingInController:_presentingController];
//        floatingPopover.frameColor = DarkenedUIColorWithRgb(SystemDarkerBlueColor, 1.2f);
//        floatingPopover.showsCloseButton = YES;
//        floatingPopover.delegate = self;
//        
//        _modelBrowser = floatingPopover;
//        
//        if (CGPointEqualToPoint(_modelBrowserPosition, CGPointZero))
//            [[SWFloatingPopoverManager defaultManager] presentFloatingPopover:floatingPopover animated:animated withKey:_documentModel];
//        else
//            [[SWFloatingPopoverManager defaultManager] presentFloatingPopover:floatingPopover atPoint:_modelBrowserPosition /*inView:nil*/ animated:animated withKey:_documentModel];
//    }
//}

- (void)presentModelBrowserAnimated:(BOOL)animated
{
    [self _presentConfiguratorForConfiguringPopoverInfo:_modelBrowserInfo animated:animated];
}

- (void)dismissModelBrowserAnimated:(BOOL)animated
{
//    SWFloatingPopoverController *floatingPopover = [[SWFloatingPopoverManager defaultManager] floatingPopoverControllerWithKey:_documentModel];
//    [floatingPopover dismissFloatingPopoverAnimated:animated];
    
    [self dismissModelConfiguratorForObject:_documentModel animated:animated];
}

- (BOOL)isModelBrowserPresented
{
    SWFloatingPopoverController *floatingPopover = [_floatingPopoverManager /*[SWFloatingPopoverManager defaultManager]*/ floatingPopoverControllerWithKey:_documentModel];
    return floatingPopover != nil;
}

- (void)presentModelConfiguratorForObject:(id)object animated:(BOOL)animated
{
    _SWConfiguringPopoverInfo *scp = [_SWConfiguringPopoverInfo configuringPopoverInfoWithObject:object position:CGPointZero offset:CGPointZero];
    [self _presentConfiguratorForConfiguringPopoverInfo:scp animated:animated];
}

- (void)dismissModelConfiguratorForObject:(id)object animated:(BOOL)animated
{
    SWFloatingPopoverController *fpc = [_floatingPopoverManager /*[SWFloatingPopoverManager defaultManager]*/ floatingPopoverControllerWithKey:object];
    
    [fpc dismissFloatingPopoverAnimated:animated];
}

- (void)dismissModelConfiguratorForObjects:(NSArray*)array animated:(BOOL)animated
{
    [_floatingPopoverManager /*[SWFloatingPopoverManager defaultManager]*/ dismissFloatingPopoversWithKeys:array animated:animated];
}

- (void)dismissAllModelConfiguratorsAnimated:(BOOL)animated
{
    [_floatingPopoverManager /*[SWFloatingPopoverManager defaultManager]*/ dismissAllPopoversAnimated:animated];
}

- (void)hidePresentedPopoversAnimated:(BOOL)animated
{
//    // Model Browser Stuff
//    SWFloatingPopoverController *browser = [[SWFloatingPopoverManager defaultManager] floatingPopoverControllerWithKey:_documentModel];
//    _wasModelBrowserPresented = browser != nil;
//    [browser dismissFloatingPopoverAnimated:animated];
    
    // Configurators Stuff
    for (SWFloatingPopoverController *fpc in _openedConfigurators)
    {
        //id object = [[SWFloatingPopoverManager defaultManager] keyForFloatingPopoverController:fpc];
        id object = fpc.key;
        
        CGPoint position = fpc.presentationPosition;
        CGPoint offset = [self _contentOffsetFromViewController:fpc.contentViewController];
                
        _SWConfiguringPopoverInfo *scp = [_SWConfiguringPopoverInfo configuringPopoverInfoWithObject:object position:position offset:offset];
        [_storedConfiguriatorInfos addObject:scp];
        
        [fpc dismissFloatingPopoverAnimated:animated];
    }
}

- (void)presentHiddenPopoversAnimated:(BOOL)animated
{
//    // Model Browser Stuff
//    if (_wasModelBrowserPresented)
//        [self presentModelBrowserAnimated:animated];
    
    // Configurators Stuff
    for (_SWConfiguringPopoverInfo *scp in _storedConfiguriatorInfos)
        [self _presentConfiguratorForConfiguringPopoverInfo:scp animated:animated];
    
    [_storedConfiguriatorInfos removeAllObjects];
}

@end

@implementation SWModelManager (Delegates)

#pragma mark Protocol ColorPickerDelegate

- (void)colorPicker:(SWColorPickerViewController *)colorPicker didPickColor:(UIColor *)color
{
    UInt32 rgbColor = rgbColorForUIcolor(color);
    NSString *colorStr = getColorStrForRgbValue(rgbColor);
    
//    if (colorStr)
//    {
//        colorStr = colorStr;
//    }
//    else
//    {
//    
//#warning, problemo! el delegat fa servir getBindableString, amb lo qual inserta "SM.color(...)" com a string (amb cometes i tot). El problema es que el getSourceString no te coneixement de que això es un color, una solucio seria tornar sempre una string del tipus "#9060ff", es podria implementar directament a dintre de getColorStrForRgbValue i prescindir de tot aquest codi
//        CGFloat alpha = ColorA(rgbColor);
//        if (alpha == 1.0)
//            colorStr = [NSString stringWithFormat:@"SM.color(%lu,%lu,%lu)", ThemeR(rgbColor), ThemeG(rgbColor), ThemeB(rgbColor)];
//        else
//            colorStr = [NSString stringWithFormat:@"SM.color(%lu,%lu,%lu,%1.3g)", ThemeR(rgbColor), ThemeG(rgbColor), ThemeB(rgbColor), alpha];
//    }

    SWValue *value = [SWValue valueWithString:colorStr];
    
    if ([_seekerDelegate respondsToSelector:@selector(modelManager:didSelectValue:)])
        [_seekerDelegate modelManager:self didSelectValue:value];
}

#pragma mark Protocol FontPickerDelegate

- (void)fontPicker:(SWFontPickerViewController *)picker didSelectFontName:(NSString *)fontName
{
    SWValue *value = [SWValue valueWithString:fontName];
    
    if ([_seekerDelegate respondsToSelector:@selector(modelManager:didSelectValue:)])
        [_seekerDelegate modelManager:self didSelectValue:value];
}

#pragma mark Protocol ImagePickerDelegate

- (void)imagePickerController:(SWImagePickerController *)imagePicker didSelectImageAtPath:(NSString *)path
{
    NSString *imageName = [path lastPathComponent];

    SWValue *value = [SWValue valueWithString:imageName];
    
    if ([_seekerDelegate respondsToSelector:@selector(modelManager:didSelectValue:)])
        [_seekerDelegate modelManager:self didSelectValue:value];
}

#pragma mark Protocol SWModelBrowserDelegate 

- (void)modelBrowser:(UIViewController<SWModelBrowserViewController> *)controller didSelectValue:(SWValue *)value
{
    _seekedObject = value;
    
    if ([_seekerDelegate respondsToSelector:@selector(modelManager:didSelectValue:)])
        [_seekerDelegate modelManager:self didSelectValue:value];
}

#pragma mark Protocol Floating Popover Delegate

- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
{
//    if (floatingPopoverController == _modelBrowser)
//    {
//        _modelBrowserInfo->_position /*_modelBrowserPosition*/ = floatingPopoverController.presentationPosition;
//        _modelBrowserInfo->_offset /*_modelBrowserOffset*/ = [self _contentOffsetFromViewController:floatingPopoverController.contentViewController];
//        
//        UINavigationController *contentCtrll = (id)floatingPopoverController.contentViewController;
//        
//        _modelBrowserIdentifyingObject = [self _objectForViewController:contentCtrll.topViewController];
//    
//        for (UIViewController *vc in contentCtrll.viewControllers)
//        {
//            if ([vc isKindOfClass:[SWModelBrowserController class]])
//            {
//                _searchActiveInModelBrowser = [(SWModelBrowserController*)vc isSearchActive];
//                _searchTextInModelBrowser = [(SWModelBrowserController*)vc searchText];
//            }
//        }
//        
//        _modelBrowser = nil;
//    }
//    else

#warning recuperar el codi anterior (no manté l'ultim estat del model browser si tanquem amb la creueta)

    
    //id object = [[SWFloatingPopoverManager defaultManager] keyForFloatingPopoverController:floatingPopoverController];
    id object = floatingPopoverController.key;
    if ( object == _documentModel )
    {
        _modelBrowserInfo->_position /*_modelBrowserPosition*/ = floatingPopoverController.presentationPosition;
        _modelBrowserInfo->_offset /*_modelBrowserOffset*/ = [self _contentOffsetFromViewController:floatingPopoverController.contentViewController];
        
        UINavigationController *contentCtrll = (id)floatingPopoverController.contentViewController;
        
        _modelBrowserIdentifyingObject = [self _objectForViewController:contentCtrll.topViewController];
    
        for (UIViewController *vc in contentCtrll.viewControllers)
        {
            if ([vc isKindOfClass:[SWModelBrowserController class]])
            {
                _searchActiveInModelBrowser = [(SWModelBrowserController*)vc isSearchActive];
                _searchTextInModelBrowser = [(SWModelBrowserController*)vc searchText];
            }
        }
    }


    
    [_openedConfigurators removeObjectIdenticalTo:floatingPopoverController];
}

@end
