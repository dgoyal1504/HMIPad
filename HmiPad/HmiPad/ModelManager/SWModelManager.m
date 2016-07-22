//
//  SWModelManager.m
//  HmiPad
//
//  Created by Joan Martin on 8/28/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWModelManager.h"

#import "AppModelFilesEx.h"
#import "AppModelFilePaths.h"

#import "SWDocument.h"
#import "SWPage.h"
#import "SWGroupItem.h"
#import "SWItem.h"
#import "SWSourceItem.h"
#import "SWSourceNode.h"
#import "SWAlarm.h"
#import "SWSystemItem.h"
#import "SWBackgroundItem.h"

#import "SWPropertyDescriptor.h"
#import "SWValue.h"
#import "SWReadExpression.h"

#import "SWRevealController.h"
#import "SWModelBrowserController.h"

#import "SWArrayTypeBrowserController.h"
#import "SWPageBrowserController.h"
#import "SWGroupItemBrowserController.h"
#import "SWObjectBroswerController.h"
#import "SWSourceVariablesBrowserController.h"

#import "SWSegmentController.h"
#import "SWConfigurationController.h"

#import "SWFloatingPopoverManager.h"

#import "SWColorListBrowserController.h"
#import "SWColorPickerBrowserController.h"
#import "SWFontPickerBrowserController.h"
#import "SWImagePickerBrowserController.h"
#import "SWAssetFilePickerBrowserController.h"

#import "SWExpressionInputController.h"

#import "SWColor.h"


@interface SWModelManager()<SWFloatingPopoverManagerDataSource,SWFloatingPopoverManagerDelegate>
@end

@interface SWModelManager (Delegates) <SWModelBrowserDelegate, SWColorPickerDelegate, SWFontPickerDelegate, SWImagePickerControllerDelegate, SWAssetFilePickerDelegate>
@end



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


- (void)addManagerWithDocumentModel:(SWDocumentModel*)documentModel defaultPresentingController:(UIViewController*)presentingController
{
    if ( !documentModel )
        return ;

    if (!_modelManagers)
        _modelManagers = [NSMutableArray array];
    
    SWModelManager *modelManager = [[SWModelManager alloc] initWithDocumentModel:documentModel defaultPresentingController:presentingController];
    [_modelManagers addObject:modelManager];
}


- (void)removeManagerWithDocumentModel:(SWDocumentModel*)documentModel // <----- S'ha de cridar aquest mètode quan es vulgui eliminar el projecte, 
{
    if ( !documentModel )
        return ;
    
    SWModelManager *modelManager = [self managerForDocumentModel:documentModel];
    [_modelManagers removeObjectIdenticalTo:modelManager];
    //[modelManager removeAllModelPopoversAnimated:NO presentingControllerKey:nil];
    [modelManager removeAllModelPopoversFromControllerWithIdentifier:nil animated:NO];
}


@end


// Objecte per crear keys per configuradors de tipus seeker
@interface SWSeekerKey : NSObject

@property (nonatomic) BOOL isRootSeeker;
@property (nonatomic,strong) NSObject *object;
@property (nonatomic,strong) SWValue *objectValue;
@property (nonatomic,strong) id contextObject;
@property (nonatomic,weak) id<SWModelManagerDelegate> objectDelegate;
@property (nonatomic,weak) id<SWModelManagerDataSource> objectDataSource;
@end

@implementation SWSeekerKey

- (id)init
{
    self = [self initWithObject:nil value:nil presentFromRoot:YES];
    return self;
}


- (id)initWithObject:(id)object value:(SWValue*)value presentFromRoot:(BOOL)isRootSeeker
{
    self = [super init];
    if ( self )
    {
        _isRootSeeker = isRootSeeker;
        _object = object;
        _objectValue = value;
    }
    return self;
}

- (void)reset
{
    _isRootSeeker = YES;
    _object = nil;
    _objectValue = nil;
    _contextObject = nil;
    _objectDelegate = nil;
    _objectDataSource = nil;
}

- (BOOL)isEqual:(id)other
{
    // ens poden comparar amb qualsevol altre, no podem assumir que other.object funcionara
    if ( ![other isKindOfClass:[self class]] )
        return NO;
    
    SWSeekerKey *otherSeeker = (id)other;
    return [_object isEqual:otherSeeker.object];
}

- (NSUInteger)hash
{
    return _object.hash ;
}

@end;


NSString * const SWModelManagerDidChangeAcceptedTypesNotification = @"SWModelManagerDidChangeAcceptedTypesNotification";
NSString * const SWModelManagerDefaultPresentingControllerKey = @"SWModelManagerDefaultPresentingControllerKey";
static NSString * SWRootPickerObjectIdentifier = @"SWRootPickerObjectIdentifier";

@implementation SWModelManager
{
    NSMutableDictionary *_floatingPopoverManagers;
    BOOL _showsInFullScreen;

    // Model Seeker Stuff
    /*__weak */ SWValue *_seekedValue;
    NSIndexSet *_acceptedTypes;
    SWSeekerKey *_pickerKey;
    
    // Model Browser Stuff
    id _modelBrowserIdentifyingObject;
    FrontViewPosition _browserRevealPosition;
    BOOL _searchActiveInModelBrowser;
    NSString *_searchTextInModelBrowser;
    
    // Model Picker Stuff
    id _objectPickerIdentifyingObject;
    FrontViewPosition _pickerRevealPosition;
    BOOL _searchActiveInObjectPicker;
    NSString *_searchTextInObjectPicker;
    
    // ExpressionInput
    SWExpressionInputController *_inputController;
}

//@synthesize documentModel = _documentModel;
//@synthesize contentSizeInPopover = _contentSizeInPopover;


- (id)initWithDocumentModel:(SWDocumentModel*)documentModel defaultPresentingController:(UIViewController*)defaultPresentingController
{
    self = [super init];
    if (self)
    {
        _documentModel = documentModel;
        _pickerKey = [[SWSeekerKey alloc] init];
        _contentSizeInPopover = CGSizeMake(320, 460+88);
        _seekerContentSizeInPopover = CGSizeMake(320, 460);
        _modelBrowserIdentifyingObject = _documentModel;
        _objectPickerIdentifyingObject = _documentModel;
        
        _showsInFullScreen = NO;
        _floatingPopoverManagers = [NSMutableDictionary dictionary];
        
        if ( defaultPresentingController == nil )
        {
            id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
            defaultPresentingController = [[appDelegate window] rootViewController];
            _showsInFullScreen = YES;
        }

        [self registerPresentingController:defaultPresentingController withIdentifier:SWModelManagerDefaultPresentingControllerKey];
    }
    return self;
}


- (SWExpressionInputController*)inputController
{
    if ( _inputController == nil )
    {
        _inputController = [[SWExpressionInputController alloc] initWithModelManager:self];
    }
    return _inputController;
}


- (void)dealloc
{
    //NSLog( @"ModelManager dealloc");
}


#pragma mark Private Methods

/**
 * Arbre de pares-fills:
 *
 * <nil>  <documentModel>     <SWArrayTypeSystemItems>        <SWSystemItem>  
 *                            <SWArrayTypePages>              <SWPage>              <SWItem>
 *                            <SWArrayTypeBackgroundItems>    <SWBackgroundItem>
 *                            <SWArrayTypeAlarm>              <SWAlarm>  
 *                            <SWArrayTypeSources>            <SWSourceItem>
 *
 */


- (id)_frontParentObjectForObject:(id)idObject forShortPath:(BOOL)shortPath
{
    id parent = nil;
    
//    if ([object isKindOfClass:[SWDocumentModel class]])
//        parent = nil;
//    else
    if ([idObject isKindOfClass:[NSNumber class]] || shortPath)
        parent = nil;
    
    else if ([idObject isKindOfClass:[SWPage class]])
        parent = [NSNumber numberWithInteger:SWArrayTypePages];
    
    else if ([idObject isKindOfClass:[SWItem class]])
        //parent = [(SWItem*)idObject page];
        parent = [(SWItem*)idObject parentObject];
    
    else if ([idObject isKindOfClass:[SWSourceItem class]])
        parent = [NSNumber numberWithInteger:SWArrayTypeSources];
    
    else if ([idObject isKindOfClass:[SWSystemItem class]])
        parent = [NSNumber numberWithInteger:SWArrayTypeSystemItems];
    
    else if ([idObject isKindOfClass:[SWAlarm class]])
        parent = [NSNumber numberWithInteger:SWArrayTypeAlarms];
    
    else if ([idObject isKindOfClass:[SWBackgroundItem class]])
        parent = [NSNumber numberWithInteger:SWArrayTypeBackgroundItems];
    
    else if ([idObject isKindOfClass:[SWValue class]])
    {
        parent = [(SWValue*)idObject holder];  // el pare es el propi holder
        if ([parent isKindOfClass:[SWItem class]] ||
            [parent isKindOfClass:[SWSourceItem class]] ||
            [parent isKindOfClass:[SWSystemItem class]] ||
            [parent isKindOfClass:[SWAlarm class]] ||
            [parent isKindOfClass:[SWBackgroundItem class]])
        {
            parent = [self _frontParentObjectForObject:parent forShortPath:shortPath];
        }
    }
    
    else
    {
        NSLog( @"Ha entrat un tipus no contemplat: %@", NSStringFromClass([idObject class]));
        NSAssert(false, nil );
    }
    
    return parent;
}



- (UIViewController<SWModelBrowserViewController>*)_newViewControllerForObject:(id)idObject browsingStyle:(SWModelBrowsingStyle)browsingStyle
{
    UIViewController <SWModelBrowserViewController> *vc = nil;
    Class controllerClass = NULL;
    id object = idObject;
        
    if ([idObject isKindOfClass:[SWDocumentModel class]])
        controllerClass = [SWModelBrowserController class];
    
    else if ([idObject isKindOfClass:[NSNumber class]])
    {
        controllerClass = [SWArrayTypeBrowserController class];
        object = _documentModel;
    }
    
    else if ([idObject isKindOfClass:[SWPage class]])
        controllerClass = [SWPageBrowserController class];
    
    else if ([idObject isKindOfClass:[SWGroupItem class]])
        controllerClass = [SWGroupItemBrowserController class];
    
    else if ([idObject isKindOfClass:[SWSourceItem class]])
        controllerClass = [SWSourceVariablesBrowserController class];
    
    else if ([idObject isKindOfClass:[SWObject class]])
        controllerClass = [SWObjectBroswerController class];
    
    else if ([idObject isKindOfClass:[SWValue class]])
    {
        object = [(SWValue*)idObject holder];
        if ( [(SWObject*)object isAsleep] )
            object = nil;
        
        if ([object isKindOfClass:[SWSourceItem class]])
            controllerClass = [SWSourceVariablesBrowserController class];
        
        else if ([object isKindOfClass:[SWObject class]])
            controllerClass = [SWObjectBroswerController class];
        
//        else
//        {
//            NSLog( @"Ha entrat un tipus no contemplat: %@", NSStringFromClass([idObject class]));
//            NSAssert(false, nil );
//        }
    }
    
    if ( object )
    {
        if ( controllerClass != nil )
            vc = [[controllerClass alloc] initWithObject:object classIdentifierObject:idObject];
        
        if ( vc == nil )
        {
            NSLog( @"Ha entrat un tipus no contemplat: %@", NSStringFromClass([idObject class]));
            NSAssert(false, nil );
        }
    
        if (browsingStyle == SWModelBrowsingStyleManagement)
            //vc.contentSizeForViewInPopover = _contentSizeInPopover;
            vc.preferredContentSize = _contentSizeInPopover;
        
        else if (browsingStyle == SWModelBrowsingStyleSeeker)
            //vc.contentSizeForViewInPopover = _seekerContentSizeInPopover;
            vc.preferredContentSize = _seekerContentSizeInPopover;
        
        vc.browsingStyle = browsingStyle;
        //vc.acceptedTypes = acceptedTypes;
    }
    
    return vc;
}


- (id)_objectForViewController:(UIViewController<SWModelBrowserViewController>*)viewController
{
    id object = [viewController identifiyingObject];
    return object;
}



- (NSMutableArray*)_arrayWithFrontViewControllersForObject:(id)object browsingStyle:(SWModelBrowsingStyle)browsingStyle shortPath:(BOOL)shortPath
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ( object == _documentModel )
        return array;
    
    id objectIterator = object;
    
    while (objectIterator != nil)
    {
        UIViewController<SWModelBrowserViewController> *vc = [self _newViewControllerForObject:objectIterator browsingStyle:browsingStyle];
        
        if ( vc )
            [array insertObject:vc atIndex:0];
            
        objectIterator = [self _frontParentObjectForObject:objectIterator forShortPath:shortPath];
    }
    
    return array;
}


- (NSArray*)_helperControllersForStartingObject:(id)value

{
    NSMutableArray *array = [NSMutableArray array];
    
    id defaultValue = nil;
    SWType type = SWTypeAny;
    if ( [value isKindOfClass:[SWValue class]] )
    {
        SWValue *v = (SWValue*)value;
        type = [v.valueDescription type];
    
        // default value per els controladors helper
        if (type == SWTypeColor)
            defaultValue = v.valueAsColor;
        else if (type == SWTypeFont)
            defaultValue = v.valueAsString;
        else if (type == SWTypeImagePath || type == SWTypeRecipeSheetPath  || type == SWTypePath || type == SWTypeUrl )
            defaultValue = v.valueAsString;
    }
    
    if (type == SWTypeColor || type == SWTypeAny )
    {
        UIColor *color = defaultValue;
        
        SWColorPickerBrowserController *colorPicker = [[SWColorPickerBrowserController alloc] initWithColor:color];
        colorPicker.delegate = self;
        colorPicker.title = NSLocalizedString(@"Color Picker", nil);
        //colorPicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        colorPicker.preferredContentSize = _seekerContentSizeInPopover;
        
        [array addObject:colorPicker];
        
        SWColorListBrowserController *colorListPicker = [[SWColorListBrowserController alloc] initWithStyle:UITableViewStylePlain andColor:color];
        colorListPicker.delegate = self;
        colorListPicker.title = NSLocalizedString(@"Color List", nil);
        //colorListPicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        colorListPicker.preferredContentSize = _seekerContentSizeInPopover;
        
        [array addObject:colorListPicker];
        
        colorPicker.colorPicker = colorListPicker;
        colorListPicker.colorPicker = colorPicker;
    }
    
    if (type == SWTypeFont || type == SWTypeAny)
    {
        SWFontPickerBrowserController *fontPicker = [[SWFontPickerBrowserController alloc] initWithStyle:UITableViewStylePlain];
        fontPicker.selectedFontName = defaultValue;
        fontPicker.delegate = self;
        fontPicker.title = NSLocalizedString(@"Font Picker", nil);
        //fontPicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        fontPicker.preferredContentSize = _seekerContentSizeInPopover;
        [array addObject:fontPicker];
    }
    
    if (type == SWTypeImagePath || type == SWTypeAny)
    {
        NSString *path = [filesModel().filePaths filesRootDirectoryForCategory:kFileCategoryAssetFile];
        SWImagePickerBrowserController *imagePicker = [[SWImagePickerBrowserController alloc] initWithContentsAtPath:path];
        imagePicker.selectedFileName = defaultValue;
        imagePicker.delegate = self;
        imagePicker.allowsDeletion = NO;
        imagePicker.title = NSLocalizedString(@"Image Picker",nil);
        //imagePicker.contentSizeForViewInPopover = _seekerContentSizeInPopover;
        imagePicker.preferredContentSize = _seekerContentSizeInPopover;
        
        [array addObject:imagePicker];
    }
    
    if ( type == SWTypeRecipeSheetPath  || type == SWTypePath || type == SWTypeUrl || type == SWTypeAny )
    {
        NSString *path = [filesModel().filePaths filesRootDirectoryForCategory:kFileCategoryAssetFile];
        SWAssetFilePickerBrowserController *assetFilePicker = [[SWAssetFilePickerBrowserController alloc] initWithContentsAtPath:path];
        assetFilePicker.selectedFileName = defaultValue;
        assetFilePicker.delegate = self;
        assetFilePicker.title = NSLocalizedString(@"Asset File Picker",nil);
        assetFilePicker.preferredContentSize = _seekerContentSizeInPopover;
        
        [array addObject:assetFilePicker];
    }
    return array;
}


- (SWFloatingPopoverManager*) floatingPopoverManagerForKey:(NSString*)key
{
    if (key == nil)
        key = SWModelManagerDefaultPresentingControllerKey;
    
    return [_floatingPopoverManagers objectForKey:key];
}


#pragma mark Private Methods (other)

//static NSIndexSet* _acceptedTypesForValueV(SWValue *value)
//{
//    SWType type = value != nil ? [value.valueDescription type] : SWTypeAny;
//    NSIndexSet *acceptedTypes = compatibleTypesForType(type);
//    return acceptedTypes;
//}

static NSIndexSet* _acceptedTypesForStartingObject(id value)
{
    SWType type = SWTypeAny;
    if ( [value isKindOfClass:[SWValue class]] )
        type = [((SWValue*)value).valueDescription type];
    
    NSIndexSet *acceptedTypes = compatibleTypesForType(type);

    return acceptedTypes;
}

static SWValue *_pickerObjectForValue(SWValue *value)
{
    id object = nil;
    
    if ([value isKindOfClass:[SWExpression class]])
        object = [(SWExpression*)value getExclusiveSource];

    return object;
}


- (SWRevealController*)_newModelBrowserController
{
    id object = _modelBrowserIdentifyingObject;

    // controlador de darrera
    SWModelBrowserController *rearController = (id)[self _newViewControllerForObject:_documentModel browsingStyle:SWModelBrowsingStyleManagement];

    NSMutableArray *frontControllers = [self _arrayWithFrontViewControllersForObject:object browsingStyle:SWModelBrowsingStyleManagement shortPath:_searchActiveInModelBrowser];
    
    UIViewController<SWModelBrowserViewController> *defaultFrontController = nil;
    if ( frontControllers.count == 0 )
    {
        defaultFrontController = [self _newViewControllerForObject:@(SWArrayTypePages) browsingStyle:SWModelBrowsingStyleManagement];
        [frontControllers addObject:defaultFrontController];
    }
    
    SWRevealController *revealController = [[SWRevealController alloc]
        initWithRearViewController:rearController frontViewControllers:frontControllers];
    
    CGSize size = _contentSizeInPopover;
    
    CGFloat overDraw = 54;
    CGFloat padding = 0;
    if ( _showsInFullScreen ) padding = 2*[SWFloatingPopoverController framePadding];

    [revealController setRearViewRevealWidth:size.width-overDraw-padding];
    [revealController setRearViewRevealOverdraw:overDraw];
    [revealController setFrontViewShadowRadius:1.5];
    
    if ( IS_IOS7 ) revealController.presentFrontViewHierarchically = YES;
    //revealController.contentSizeForViewInPopover = size;
    revealController.preferredContentSize = size;

    if (_searchActiveInModelBrowser)
        [rearController setSearchText:_searchTextInModelBrowser];
    
    if ( defaultFrontController != nil)
        _browserRevealPosition = FrontViewPositionRightMost;
    
    if ( revealController.topViewController == rearController )
        _browserRevealPosition = FrontViewPositionRightMostRemoved;
    
    [revealController setFrontViewPosition:_browserRevealPosition animated:NO];
    
    return revealController;
}


- (void)_updateRevealController:(SWRevealController *)revealController withControllersForSeekerKey:(SWSeekerKey*)seekerKey
{
    id object = nil;
    SWValue *value = nil;
    BOOL isRootSeeker = (seekerKey.object == SWRootPickerObjectIdentifier);
    
    SWModelBrowserController *rearController = (id)revealController.rearViewController;
    
    if ( isRootSeeker )
    {
        if (_searchActiveInObjectPicker)
            [rearController setSearchText:_searchTextInObjectPicker];
        
        [rearController setSearchDisabled:!_searchActiveInObjectPicker];
        
        value = nil;
        object = _objectPickerIdentifyingObject;
    }
    else
    {
        [rearController setSearchText:nil];
        
        value = seekerKey.objectValue;
        object = _pickerObjectForValue(value);
    }
    
    _seekedValue = object;
    
    _acceptedTypes = _acceptedTypesForStartingObject(value);

    [rearController setDelegate:self];

    // controladors tipus helper
    NSArray *extraControllers = [self _helperControllersForStartingObject:value];
    [rearController setExtraViewControllers:extraControllers animated:NO];
    
    if ( object )
    {
        // controladors tipus browser
        NSMutableArray * frontControllers = [self _arrayWithFrontViewControllersForObject:object
                browsingStyle:SWModelBrowsingStyleSeeker shortPath:_searchActiveInObjectPicker];
        
        
        [frontControllers makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    
        [revealController setFrontViewControllerWithControllers:frontControllers animated:YES];
        
        FrontViewPosition revealPosition = FrontViewPositionLeft;
        if ( isRootSeeker )
            revealPosition = _pickerRevealPosition;
        
        if ( revealController.topViewController == rearController )
            revealPosition = FrontViewPositionRightMostRemoved;
        
        [revealController setFrontViewPosition:revealPosition animated:NO];
    }
    else
    {
        // si no hi ha frontController en posem un per defecte
        if ( revealController.topViewController == rearController )
        {
            UIViewController<SWModelBrowserViewController> *defaultFrontController = nil;
            defaultFrontController = [self _newViewControllerForObject:@(SWArrayTypePages) browsingStyle:SWModelBrowsingStyleSeeker];
            [revealController setFrontViewControllerWithControllers:@[defaultFrontController] animated:YES];
            [revealController setFrontViewPosition:FrontViewPositionRightMost animated:NO];
        }
    
        // si no hi ha un picker object deixem la mateixa gerarquia pero actualitzem els accepted types
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:SWModelManagerDidChangeAcceptedTypesNotification object:nil];
    }
}


- (SWRevealController*)_newModelSeekerWithSeekerKey:(SWSeekerKey*)seekerKey
{    
    SWModelBrowserController *rearController = (id)[self _newViewControllerForObject:_documentModel browsingStyle:SWModelBrowsingStyleSeeker];
    [rearController setDelegate:self];
    
    // reveal controller
    SWRevealController *revealController = [[SWRevealController alloc]
        initWithRearViewController:rearController frontViewControllers:nil];
    
    [self _updateRevealController:revealController withControllersForSeekerKey:seekerKey];
        
    CGSize size = _seekerContentSizeInPopover;
    
    CGFloat overDraw = 54;
    CGFloat padding = 0;
    if ( _showsInFullScreen ) padding = 2*[SWFloatingPopoverController framePadding];
    
    [revealController setRearViewRevealWidth:size.width-overDraw-padding];
    [revealController setRearViewRevealOverdraw:overDraw];
    [revealController setFrontViewShadowRadius:1.5];
    
    if ( IS_IOS7 ) revealController.presentFrontViewHierarchically = YES;
    //revealController.contentSizeForViewInPopover = size;
    revealController.preferredContentSize = size;

    return revealController;
}


#pragma mark Public Methods (getting controllers)

- (SWValue*)currentSeekedValue
{
    return _seekedValue;
}

- (NSIndexSet*)currentAcceptedTypes
{
    return _acceptedTypes;
}

- (UIViewController*)modelConfiguratorForObject:(id)object
{
    UIViewController *vc = [SWConfigurationController configuratorForObject:object];
    return vc;
}


#pragma mark Public Methods (seeker management)

//- (void)dismissModelSeekerForObject:(id)object animated:(BOOL)animated presentingControllerKey:(NSString*)presentingControllerKey
//- (void)dismissModelSeekerFromControllerWithIdentifier:(NSString*)presentingControllerKey forObject:(id)object animated:(BOOL)animated
//{
//    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
//    if ( animated ) animationKind = SWFloatingPopoverAnimationGenie;
//    
//    SWSeekerKey *seekerKey = [[SWSeekerKey alloc] initWithObject:object value:nil presentFromRoot:NO];
//    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
//    [floatingPopoverManager removeFloatingPopoverWithKey:seekerKey animationKind:animationKind];
//}

- (void)dismissModelSeekerFromControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = IS_IPHONE?SWFloatingPopoverAnimationFade:SWFloatingPopoverAnimationGenie;
    
    SWSeekerKey *seekerKey = [[SWSeekerKey alloc] initWithObject:_pickerKey.object value:nil presentFromRoot:NO];
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager removeFloatingPopoverWithKey:seekerKey animationKind:animationKind];
}


#pragma mark Public Methods (model browser management)

- (void)toggleModelBrowserForControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    SWFloatingPopoverController *floatingPopover = [floatingPopoverManager floatingPopoverControllerWithKey:_documentModel];
    if ( floatingPopover )
    {
        [floatingPopoverManager dismissFloatingPopoverWithKey:_documentModel animationKind:animationKind];
    }
    else
    {
       [floatingPopoverManager presentFloatingPopoverWithKey:_documentModel animationKind:IS_IPHONE?animationKind:SWFloatingPopoverAnimationNone];
    }
}



- (void)updateModelPickerForPresentingControllerWithIdentifier:(NSString*)presentingControllerKey
                                forObject:(id)object
                                  withValue:(SWValue*)value
                                    context:(id)context
                                   delegate:(id<SWModelManagerDelegate>)delegate
                                 dataSource:(id<SWModelManagerDataSource>)dataSource
                                   animated:(BOOL)animated
{
    if ( [object isEqual:_pickerKey.object] && [context isEqual:_pickerKey.contextObject] )
    {
        SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
        SWFloatingPopoverController *floatingPopover = [floatingPopoverManager floatingPopoverControllerWithKey:_pickerKey];
        if ( floatingPopover )
        {
            [self showModelPickerOnPresentingControllerWithIdentifier:presentingControllerKey forObject:object withValue:value context:context delegate:delegate dataSource:dataSource animated:animated];
        }
    }
}



- (void)showConnectorsPickerOnPresentingControllerWithIdentifier:(NSString*)presentingControllerKey
                        context:(id)context
                        delegate:(id<SWModelManagerDelegate>)delegate
                      dataSource:(id<SWModelManagerDataSource>)dataSource
                 animated:(BOOL)animated
{
    _objectPickerIdentifyingObject = [NSNumber numberWithInt:SWArrayTypeSources];
    _pickerRevealPosition = FrontViewPositionLeft;
    _searchActiveInObjectPicker = NO;
    _searchTextInObjectPicker = nil;

    [self showRootModelPickerOnPresentingControllerWithIdentifier:presentingControllerKey context:context delegate:delegate dataSource:dataSource animated:animated];
}


- (void)showRootModelPickerOnPresentingControllerWithIdentifier:(NSString*)presentingControllerKey
                        context:(id)context
                        delegate:(id<SWModelManagerDelegate>)delegate
                      dataSource:(id<SWModelManagerDataSource>)dataSource
                 animated:(BOOL)animated
{    
    [self showModelPickerOnPresentingControllerWithIdentifier:presentingControllerKey
        forObject:SWRootPickerObjectIdentifier withValue:nil context:context delegate:delegate dataSource:dataSource animated:animated];
}


- (void)showModelPickerOnPresentingControllerWithIdentifier:(NSString *)presentingControllerKey
                    forObject:(id)object
                       withValue:(SWValue*)value
                         context:(id)context
                        delegate:(id<SWModelManagerDelegate>)delegate
                      dataSource:(id<SWModelManagerDataSource>)dataSource
                        animated:(BOOL)animated

{
    NSObject *oldObject = _pickerKey.object;

    id<SWModelManagerDelegate> pickerDelegate = _pickerKey.objectDelegate;
    if ( [pickerDelegate respondsToSelector:@selector(modelManager:willEndPickerForObject:value:context:)] )
        [pickerDelegate modelManager:self willEndPickerForObject:oldObject value:_pickerKey.objectValue context:_pickerKey.contextObject];

    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = IS_IPHONE?SWFloatingPopoverAnimationFade:SWFloatingPopoverAnimationGenie;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    
    NSArray *popManagers = [_floatingPopoverManagers allValues];
    for ( SWFloatingPopoverManager *aPopManager in popManagers )
    {
        if ( floatingPopoverManager != aPopManager /*|| ![oldObject isEqual:object]*/ )
        {
            SWFloatingPopoverController *aFloatingPopover = [aPopManager floatingPopoverControllerWithKey:_pickerKey];
            if ( aFloatingPopover )
            {
                SWSeekerKey *seekerKey = [[SWSeekerKey alloc] initWithObject:oldObject value:nil presentFromRoot:NO];
                [aPopManager removeFloatingPopoverWithKey:seekerKey animationKind:animationKind];
            }
        }
    }
    
    _pickerKey.object = object;
    _pickerKey.objectValue = value;
    _pickerKey.isRootSeeker = NO;
    _pickerKey.objectDelegate = delegate;
    _pickerKey.objectDataSource = dataSource;
    _pickerKey.contextObject = context;
    
    if ( [delegate respondsToSelector:@selector(modelManager:willBeginPickerForObject:value:context:)] )
        [delegate modelManager:self willBeginPickerForObject:object value:value context:context];
    
    SWFloatingPopoverController *floatingPopover = [floatingPopoverManager floatingPopoverControllerWithKey:_pickerKey];
    if ( floatingPopover )
    {
        SWRevealController *revealController = (id)floatingPopover.contentViewController;
        
        [self _updateRevealController:revealController withControllersForSeekerKey:_pickerKey];
        [floatingPopover bringToFront];
    }
    else
    {
        [floatingPopoverManager presentFloatingPopoverWithKey:_pickerKey animationKind:animationKind];
        floatingPopover = [floatingPopoverManager floatingPopoverControllerWithKey:_pickerKey];
    }
    
//    if ([dataSource respondsToSelector:@selector(modelManager:prepareModelBrowser:object:value:context:)])
//    {
//        SWRevealController *revealController = (SWRevealController*)floatingPopover.contentViewController;
//        SWModelBrowserController *modelBrowserController = (SWModelBrowserController*)revealController.rearViewController;
//        [dataSource modelManager:self prepareModelBrowser:modelBrowserController object:object value:value context:context];
//    }
}


#pragma mark Public Methods (object configurators management)

- (void)presentModelConfiguratorOnControllerWithIdentifier:(NSString*)presentingControllerKey
            forObject:(id)object animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager presentFloatingPopoverWithKey:object animationKind:animationKind];
}


- (void)dismissModelConfiguratorFromControllerWithIdentifier:(NSString*)presentingControllerKey
            forObject:(id)object animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager dismissFloatingPopoverWithKey:object animationKind:animationKind];
}


- (void)removeModelConfiguratorFromControllerWithIdentifier:(NSString*)presentingControllerKey
            forObject:(id)object animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager removeFloatingPopoverWithKey:object animationKind:animationKind];
}


#pragma mark Public Methods (presented popovers management)

- (void)registerPresentingController:(UIViewController*)controller withIdentifier:(NSString*)key
{
    SWFloatingPopoverManager *floatingPopoverManager = [[SWFloatingPopoverManager alloc] initWithPresentingController:controller];
    floatingPopoverManager.showsInFullScreen = _showsInFullScreen;
    floatingPopoverManager.delegate = self;
    floatingPopoverManager.dataSource = self;
    [_floatingPopoverManagers setObject:floatingPopoverManager forKey:key];
}

- (void)unregisterPresentingControllerWithIdentifier:(NSString*)key
{
    [_floatingPopoverManagers removeObjectForKey:key];
}

- (void)removeAllModelPopoversFromControllerWithIdentifier:(NSString*)presentingControllerKey  animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager removeAllPopoversAnimationKind:animationKind];
    [_pickerKey reset];
}

- (void)hidePresentedPopoversForControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager removeFloatingPopoverWithKey:_pickerKey animationKind:animationKind];
    [floatingPopoverManager hidePresentedPopoversAnimationKind:animationKind];
}

- (void)presentHiddenPopoversForControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated
{
    SWFloatingPopoverAnimationKind animationKind = SWFloatingPopoverAnimationNone;
    if ( animated ) animationKind = SWFloatingPopoverAnimationFade;
    
    SWFloatingPopoverManager *floatingPopoverManager = [self floatingPopoverManagerForKey:presentingControllerKey];
    [floatingPopoverManager presentHiddenPopoversAnimationKind:animationKind];
}



#pragma mark Protocol Floating Popover Manager Data Source

- (id)floatingPopoverManager:(SWFloatingPopoverManager *)floatingPopoverManager parentKeyForViewControllerWithKey:(id)key
{
    if ( key == _pickerKey )
        return _pickerKey.object;

    return nil;
}


- (UIViewController*)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager viewControllerForKey:(id)key;
{
    UIViewController *vc = nil;
    
    if ( key == _documentModel )  // es el model browser
    {
        vc = [self _newModelBrowserController];
    }
    
    else if ( [key isKindOfClass:[SWSeekerKey class]] )  // es un seeker
    {
       vc = [self _newModelSeekerWithSeekerKey:key];
    }
    
    else  // es un object configurator
    {
        vc = [self modelConfiguratorForObject:key];
    }
    
    return vc;
}



- (UIView*)floatingPopoverManager:(SWFloatingPopoverManager *)floatingPopoverManager revealViewForKey:(id)key
{
    UIView *revealView = nil;
    
    if ( [key isKindOfClass:[SWSeekerKey class]] )
    {
        SWSeekerKey *seekerKey = (id)key;
        
        id<SWModelManagerDataSource> dataSource = seekerKey.objectDataSource;
        if ( [dataSource respondsToSelector:@selector(modelManager:revealViewForObject:value:context:)] )
        {
            revealView = [dataSource modelManager:self revealViewForObject:seekerKey.object value:seekerKey.objectValue context:seekerKey.contextObject];
        }
    }
    else
    {
        // TO DO
        //   revealView = [dataSource modelManager:self revealViewForObject:key value:nil];
    }
    
    return revealView;
}


- (CGRect)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager centerRectForKey:(id)key
{
    CGRect rect = CGRectNull;
    if ([key isKindOfClass:[SWSeekerKey class]])
    {
        SWSeekerKey *seekerKey = key;
        id<SWModelManagerDataSource> dataSource = seekerKey.objectDataSource;

        if ( [dataSource respondsToSelector:@selector(modelManager:popoverCenterRectForObject:value:context:)] )
            rect = [dataSource modelManager:self popoverCenterRectForObject:seekerKey.object value:seekerKey.objectValue context:seekerKey.contextObject];
    }
    return rect;
}

//- (BOOL)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager needsCenterForKey:(id)key
//{
//    if ([key isKindOfClass:[SWSeekerKey class]])
//    {
//        SWSeekerKey *seekerKey = key;
//        
//        id<SWModelManagerDataSource> dataSource = seekerKey.objectDataSource;
//        return [dataSource respondsToSelector:@selector(modelManager:popoverCenterForObject:value:context:)];
//    }
//    return NO;
//}

#pragma mark Protocol Floating Popover Manager Delegate


- (void)floatingPopoverManager:(SWFloatingPopoverManager *)floatingPopoverManager
    closeViewController:(UIViewController *)viewController withKey:(id)key
{
    [floatingPopoverManager dismissFloatingPopoverWithKey:key animationKind:SWFloatingPopoverAnimationFade];
}



- (void)floatingPopoverManager:(SWFloatingPopoverManager *)floatingPopoverManager
    willDismissViewController:(UIViewController *)viewController withKey:(id)key
{

    if ( key == _documentModel )
    {
        SWRevealController *revealController = (id)viewController;
        _modelBrowserIdentifyingObject = [self _objectForViewController:(id)revealController.topViewController];
        
        SWModelBrowserController *modelBrowser = (id)[revealController rearViewController];
        _browserRevealPosition = revealController.frontViewPosition;
        _searchActiveInModelBrowser = [modelBrowser isSearchActive];
        _searchTextInModelBrowser = [modelBrowser searchText];
    }

    if ( key == _pickerKey )
    {
        SWRevealController *revealController = (id)viewController;
        _objectPickerIdentifyingObject = [self _objectForViewController:(id)revealController.topViewController];
        
        _pickerRevealPosition = revealController.frontViewPosition;
        _searchActiveInObjectPicker = NO;
        _searchTextInObjectPicker = nil;
        
        id<SWModelManagerDelegate> delegate = _pickerKey.objectDelegate;
        
        if ( [delegate respondsToSelector:@selector(modelManager:willEndPickerForObject:value:context:)] )
            [delegate modelManager:self willEndPickerForObject:_pickerKey.object value:_pickerKey.objectValue context:_pickerKey.contextObject];
        
        [_pickerKey reset];
    }
//    else if ( key == _pickerKey.object )
//    {
//        if ( [delegate respondsToSelector:@selector(modelManager:willDismissControllerForObject:value:context:)] )
//            [delegate modelManager:self willDismissControllerForObject:_pickerKey.object
//                value:_pickerKey.objectValue context:_pickerKey.contextObject];
//    }
}

- (void)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager
    didDismissViewController:(UIViewController*)viewController withKey:(id)key
{
}

@end




@implementation SWModelManager (Delegates)

#pragma mark Protocol ColorPickerDelegate

- (void)colorPicker:(SWColorPickerViewController *)colorPicker didPickColor:(UIColor *)color
{
    UInt32 rgbColor = rgbColorForUIcolor(color);
    NSString *colorStr = getColorStrForRgbValue(rgbColor);
    
    _seekedValue = nil;
    SWValue *value = [SWValue valueWithString:colorStr];
    
    [self _viewController:colorPicker didSelectValue:value];
}

#pragma mark Protocol FontPickerDelegate

- (void)fontPicker:(SWFontPickerViewController *)picker didSelectFontName:(NSString *)fontName
{
    _seekedValue = nil;
    SWValue *value = [SWValue valueWithString:fontName];
    
    [self _viewController:picker didSelectValue:value];
}

#pragma mark Protocol ImagePickerDelegate

- (void)imagePickerController:(SWImagePickerController *)imagePicker didSelectImageAtPath:(NSString *)path
{
    NSString *imageName = [path lastPathComponent];

    _seekedValue = nil;
    SWValue *value = [SWValue valueWithString:imageName];
    
    [self _viewController:imagePicker didSelectValue:value];
}

#pragma mark Protocol AssetFilePickerPickerDelegate

- (void)assetFilePicker:(SWAssetFilePickerViewController *)picker didSelectAssetAtPath:(NSString *)path
{
    NSString *fileName = [path lastPathComponent];

    _seekedValue = nil;
    SWValue *value = [SWValue valueWithString:fileName];
    
    [self _viewController:picker didSelectValue:value];
}


#pragma mark Protocol SWModelBrowserDelegate 

- (void)modelBrowser:(UIViewController<SWModelBrowserViewController> *)controller didSelectValue:(SWValue *)value
{
    _seekedValue = value;
    [self _viewController:controller didSelectValue:value];
}


#pragma mark Private

- (void)_viewController:(UIViewController*)viewController didSelectValue:(SWValue*)value
{
    SWFloatingPopoverController *fpc = viewController.floatingPopoverController;
    id key = fpc.key;
    
    if ( [key isKindOfClass:[SWSeekerKey class]] )
    {
        SWSeekerKey *seekerKey = (id)key;
    
        id<SWModelManagerDelegate> delegate = seekerKey.objectDelegate;
        if ([delegate respondsToSelector:@selector(modelManager:didSelectValue:context:)])
            [delegate modelManager:self didSelectValue:value context:seekerKey.contextObject];
        
        if ( fpc.showsInFullScreen )
        {
            [fpc dismissFloatingPopoverWithAnimation:SWFloatingPopoverAnimationFade];
        }
    }
    
}

@end
