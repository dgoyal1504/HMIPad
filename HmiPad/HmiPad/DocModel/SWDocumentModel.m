//
//  SWDocumentModel.m
//  HmiPad
//
//  Created by Joan on 10/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWDocumentModel.h"

#import "SWDocument.h"
#import "SWPage.h"
#import "SWDataLoggerItem.h"
#import "SWRestApiItem.h"
#import "SWSourceItem.h"

#import "SWEventCenter.h"
#import "SWEvent.h"
#import "SWAlarm.h"

#import "SWHistoAlarms.h"
#import "SWHistoValues.h"
#import "SWRestApiSessions.h"

#import "SWSystemTable.h"
#import "SWSystemItemSystem.h"
#import "SWSystemItemLocation.h"
#import "SWSystemItemMotion.h"
#import "SWSystemItemProject.h"
#import "SWSystemItemPlayer.h"
#import "SWSystemItemScanner.h"
#import "SWSystemItemUsersManager.h"

#import "SWEnumTypes.h"

NSString *kProjectUserDidChangeNotification = @"kProjectUserDidChangeNotification";

@implementation SWDocumentModel

//@synthesize document = _document;
@synthesize uuid = _uuid;
@synthesize ownerID = _ownerID;

@synthesize builder = _builder;
@synthesize systemTable = _systemTable;

//@synthesize sysExpressions = _sysExpressions;

@synthesize systemItems = _systemItems;
@synthesize pages = _pages;
@synthesize selectedPageIndex = _selectedPageIndex;
@synthesize interfaceIdiom = _interfaceIdiom;
@synthesize visiblePages = _visiblePages;
@synthesize backgroundItems = _backgroundItems;
@synthesize enableConnections = _enableConnections;
@synthesize sourceItems = _sourceItems;
@synthesize alarmItems = _alarmItems;

@synthesize fileList = _fileList;
@synthesize embeededAssets = _embeededAssets;

@synthesize eventCenter = _eventCenter;
//@synthesize histoAlarms = _histoAlarms;
@dynamic undoManager;

#pragma mark - Methods



- (void)_setUuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    _uuid = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
}



- (void)_doDocModelInit
{
    //_observers = [NSMutableArray array];
    _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        
    _systemItems = [NSMutableArray array];
    _pages = [NSMutableArray array];
    _selectedPageIndex = NSNotFound;
    
    _backgroundItems = [NSMutableArray array];
    _sourceItems = [NSMutableArray array];
    _alarmItems = [NSMutableArray array];
    _projectUsers = [NSMutableArray array];
    _dataLoggerItems = [NSMutableArray array];
    _restApiItems = [NSMutableArray array];
    
    _eventCenter = [[SWEventCenter alloc] init];
    _histoAlarms = [[SWHistoAlarms alloc] initInDocumentModel:self];
    _histoValues = [[SWHistoValues alloc] initInDocumentModel:self];
    _restSessions = [[SWRestApiSessions alloc] initInDocumentModel:self];
    
    _portraitResizerPosition = CGPointMake(0, 0);
    _landscapeResizerPosition = CGPointMake(0, 0);
        
    [self _setUuid];
}


- (void)_doEditingToolInit
{
    _autoAlignItems = YES;
    _allowFrameEditing = YES;
    _showsErrorFrameInEditMode = YES;
    _showsHiddenItemsInEditMode = YES;
    _interfaceIdiom = SWDeviceInterfaceIdiomPad;
}


- (void)_initializeSystemItems
{
    _systemItemProject = [[SWSystemItemProject alloc] initInDocument:self];
    _systemItemSystem = [[SWSystemItemSystem alloc] initInDocument:self];
    SWSystemItemLocation *locationSystemItem = [[SWSystemItemLocation alloc] initInDocument:self];
    SWSystemItemMotion *motionSystemItem = [[SWSystemItemMotion alloc] initInDocument:self];
    SWSystemItemPlayer *systemItemPlayer = [[SWSystemItemPlayer alloc] initInDocument:self];
    SWSystemItemScanner *systemItemScanner = [[SWSystemItemScanner alloc] initInDocument:self];
    _systemItemUsersManager = [[SWSystemItemUsersManager alloc] initInDocument:self];
    
    [_systemItems addObject:_systemItemProject];
    //[_systemItems addObject:sysItemSystem];
    [_systemItems addObject:_systemItemSystem];
    [_systemItems addObject:locationSystemItem];
    [_systemItems addObject:motionSystemItem];
    [_systemItems addObject:systemItemPlayer];
    [_systemItems addObject:systemItemScanner];
    [_systemItems addObject:_systemItemUsersManager];
    
    for (SWSystemItem *systemItem in _systemItems)
        [systemItem addToSystemTable:_systemTable];
}

//- (id)init
//{
//    self = [super init];
//    if (self) 
//    {
//        [self _doDocModelInit];
//        _builder = [[RpnBuilder alloc] init];
//        _sysExpressions = [[SystemExpressions alloc] initWithBuilder:_builder];
//    }
//    return self;
//}

- (id)init
{
    self = [super init];
    if (self) 
    {
        [self _doDocModelInit];
        [self _doEditingToolInit];
        
        _systemTable = [[SWSystemTable alloc] init];  // la _systemTable queda associada al builder
       
         _builder = [[RpnBuilder alloc] init];
        [_builder setSystemTable:[_systemTable symbolTable]];
        
        [self _initializeSystemItems];
    }
    return self;
}

- (void)dealloc
{
    NSLog( @"SWDocumentModel dealloc" );
}


- (void)setDocument:(SWDocument *)document
{
    _document = document;
}


//- (id)copyWithZone:(NSZone *)zone
//{
//    return self;
//}

- (NSUndoManager*)undoManager
{
    return [_document undoManager];
}


#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];  // super!
    if (self) 
    {
        [self _doEditingToolInit];
        
        _uuid = [decoder decodeObject];
        _ownerID = [decoder decodeInt];
        
        _systemTable = [[SWSystemTable alloc] init];
        
        _eventCenter = [[SWEventCenter alloc] init];
        _histoAlarms = [[SWHistoAlarms alloc] initInDocumentModel:self];
        _histoValues = [[SWHistoValues alloc] initInDocumentModel:self];
        _restSessions = [[SWRestApiSessions alloc] initInDocumentModel:self];
        
        _builder = [decoder decodeObject];
        [_builder setSystemTable:[_systemTable symbolTable]];
        
        _systemItems = [decoder decodeObject];
        for ( SWSystemItem *systemItem in _systemItems )
            [systemItem addToSystemTable:_systemTable];
        
        _systemItemProject = [decoder decodeObject];
        _systemItemSystem = [decoder decodeObject];
        _systemItemUsersManager = [decoder decodeObject];
        
        _sourceItems = [decoder decodeObject];
        _pages = [decoder decodeObject];
        
        NSInteger iSelectedPageIndex = [decoder decodeInt];
        if ( iSelectedPageIndex == -1 ) iSelectedPageIndex = NSNotFound;
        _selectedPageIndex = iSelectedPageIndex;
        
        _backgroundItems = [decoder decodeObject];
        _alarmItems = [decoder decodeObject];
        
        // el eventCenter i events no els codifiquem, en generem una llista basica
        for ( SWAlarm *alarm in _alarmItems )
            [_eventCenter updateEventsForHolder:alarm];
        
        _projectUsers = [decoder decodeObject];
        //_selectedProjectUser = [decoder decodeObject];
        NSInteger iProjectUser = [decoder decodeInt];
        if ( iProjectUser >= 0 && iProjectUser < _projectUsers.count )
            _selectedProjectUser = [_projectUsers objectAtIndex:iProjectUser];
        
        _dataLoggerItems = [decoder decodeObject];
        _restApiItems = [decoder decodeObject];

        _embeededAssets = [decoder decodeInt];
        _fileList = [decoder decodeObject];
        
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _enableConnections = YES;    // per ara no ho codifiquem (ho fem en el retrieve)
        //NSLog(@"Awaked document %@",_uuid);
    }
    return self;
}


- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_uuid];
    [encoder encodeInt:_ownerID];
    
    [encoder encodeObject:_builder];
    
    [encoder encodeObject:_systemItems];
    
    [encoder encodeObject:_systemItemProject];
    [encoder encodeObject:_systemItemSystem];
    [encoder encodeObject:_systemItemUsersManager];
    
    [encoder encodeObject:_sourceItems];
    
    [encoder encodeObject:_pages];
    
    NSInteger iSelectedPageIndex = _selectedPageIndex;
    if ( _selectedPageIndex == NSNotFound ) iSelectedPageIndex = -1;
    [encoder encodeInt:iSelectedPageIndex];
    
    [encoder encodeObject:_backgroundItems];
    [encoder encodeObject:_alarmItems];
    
    [encoder encodeObject:_projectUsers];
    
    //[encoder encodeObject:_selectedProjectUser];
    NSInteger iProjectUser = [_projectUsers indexOfObjectIdenticalTo:_selectedProjectUser];
    if ( iProjectUser == NSNotFound ) iProjectUser = -1;
    [encoder encodeInt:iProjectUser];
    
    [encoder encodeObject:_dataLoggerItems];
    [encoder encodeObject:_restApiItems];
    
    [encoder encodeInt:_embeededAssets];
    [encoder encodeObject:_fileList];
}


- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    [decoder retrieveForObject:_systemItems];
    [decoder retrieveForObject:_sourceItems];
    [decoder retrieveForObject:_pages];
    
    NSInteger iSelectedPageIndex = [decoder decodeInt];
    if ( iSelectedPageIndex == -1 ) iSelectedPageIndex = NSNotFound;
    _selectedPageIndex = iSelectedPageIndex;
    
    _enableConnections = [decoder decodeInt];
    _interfaceIdiom = [decoder decodeInt];
    
    [decoder retrieveForObject:_backgroundItems];
    [decoder retrieveForObject:_alarmItems];
    
    [decoder retrieveForObject:_projectUsers];
    
    //[decoder retrieveForObject:_selectedProjectUser];
    NSInteger iProjectUser = [decoder decodeInt];
    if ( iProjectUser >= 0 && iProjectUser < _projectUsers.count )
        _selectedProjectUser = [_projectUsers objectAtIndex:iProjectUser];
    else _selectedProjectUser = nil;
    
    [decoder retrieveForObject:_dataLoggerItems];
    [decoder retrieveForObject:_restApiItems];
    
    // el eventCenter i events no els guardem, en generem una llista basica
    for ( SWAlarm *alarm in _alarmItems )
        [_eventCenter updateEventsForHolder:alarm];
}


- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_systemItems];
    [encoder encodeObject:_sourceItems];
    [encoder encodeObject:_pages];
    
    NSInteger iSelectedPageIndex = _selectedPageIndex;
    if ( _selectedPageIndex == NSNotFound ) iSelectedPageIndex = -1;
    [encoder encodeInt:iSelectedPageIndex];
    
    [encoder encodeInt:_enableConnections];
    [encoder encodeInt:_interfaceIdiom];
    
    [encoder encodeObject:_backgroundItems];
    [encoder encodeObject:_alarmItems];
    
    [encoder encodeObject:_projectUsers];
    
    //[encoder encodeObject:_selectedProjectUser];
    NSInteger iProjectUser = [_projectUsers indexOfObjectIdenticalTo:_selectedProjectUser];
    if ( iProjectUser == NSNotFound ) iProjectUser = -1;
    [encoder encodeInt:iProjectUser];
    
    [encoder encodeObject:_dataLoggerItems];
    [encoder encodeObject:_restApiItems];
}



#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id)parent
{
    self = [super init];  // super !
    if (self) 
    {
        [self _doDocModelInit];
        [self _doEditingToolInit];
    
        _builder = [decoder builder];  // el que se li passa a la inicialitzacio del symbolic decoder
        
        _systemTable = [[SWSystemTable alloc] init];
        [_builder setSystemTable:[_systemTable symbolTable]];
        
        [self _initializeSystemItems];
        
        NSInteger iSelectedPageIndex = [decoder decodeIntForKey:@"selectedPageIndex"];
        if ( iSelectedPageIndex == -1 ) iSelectedPageIndex = NSNotFound;
        _selectedPageIndex = iSelectedPageIndex;
        
        _interfaceIdiom = [decoder decodeIntForKey:@"interfaceIdiom"];
        
        
        NSMutableArray *systemObjKeys = [NSMutableArray array];
        for (SWSystemItem *systemItem in _systemItems)
        {
            [systemObjKeys addObject:systemItem.identifier];
        }
        
        // hem codificat el array pero ens interesa descodificar nomes les propietats de cada objecte
        [decoder decodeExistingCollection:_systemItems forKey:@"system" withObjectKeys:systemObjKeys];
        
        _sourceItems = [decoder decodeCollectionOfObjectsForKey:@"sources"];
        _pages = [decoder decodeCollectionOfObjectsForKey:@"pages"];
        
        _backgroundItems = [decoder decodeCollectionOfObjectsForKey:@"backgroundItems"];
        _alarmItems = [decoder decodeCollectionOfObjectsForKey:@"alarms"];
        
        _projectUsers = [decoder decodeCollectionOfObjectsForKey:@"users"];
        NSInteger iProjectUser = [decoder decodeIntForKey:@"projectUser"];
        if ( iProjectUser >= 0 && iProjectUser < _projectUsers.count )
            _selectedProjectUser = [_projectUsers objectAtIndex:iProjectUser];
        
        _dataLoggerItems = [decoder decodeCollectionOfObjectsForKey:@"dataLoggers"];
        _restApiItems = [decoder decodeCollectionOfObjectsForKey:@"restApiItems"];
        
        _embeededAssets = [decoder decodeIntForKey:@"embeddedAssets"];
        _fileList = [decoder decodeStringsArrayForKey:@"fileList"];
        
        _ownerID = [decoder decodeIntForKey:@"projectID"];  // deixem aquest nom per despistar una mica
        
        // si hi ha un uuid l'agafem sino en creem un de nou,
        // el uuid encara pot ser overridat per el SWDocument a partir del metaData del fitxer
        _uuid = [decoder decodeStringForKey:@"uuid"];
        if ( _uuid == nil )
            _uuid = [decoder decodeStringForKey:@"UUID"];
        
        if ( _uuid.length == 0 )
            [self _setUuid];   // en posem un de nou
        
        if (_selectedPageIndex >= [_pages count] )
            _selectedPageIndex = 0;
        
        if ( [_pages count] == 0 )
            _selectedPageIndex = NSNotFound;
    }
    return self;
}


- (NSString*)replacementKeyForKey:(NSString *)key
{
    if ( [key isEqualToString:@"$Project"] )
        return @"$Document";  // <-- provem "$Document" si "$Project" no el troba.
    
    if ( [key isEqualToString:@"backgroundItems"] )
        return @"invisibleItems";   // <-- provem "invisibleItems" si "backgroundItems" no el troba.

    return nil;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    NSInteger iSelectedPageIndex = _selectedPageIndex;
    if ( _selectedPageIndex == NSNotFound ) iSelectedPageIndex = -1;
    [encoder encodeInt:iSelectedPageIndex forKey:@"selectedPageIndex"];
    
    [encoder encodeInt:_interfaceIdiom forKey:@"interfaceIdiom"];
    
    [encoder encodeCollectionOfObjects:_systemItems forKey:@"system"];

    [encoder encodeCollectionOfObjects:_sourceItems forKey:@"sources"];
    [encoder encodeCollectionOfObjects:_pages forKey:@"pages"];
    [encoder encodeCollectionOfObjects:_backgroundItems forKey:@"backgroundItems"];
    [encoder encodeCollectionOfObjects:_alarmItems forKey:@"alarms"];
    [encoder encodeCollectionOfObjects:_projectUsers forKey:@"users"];
    
    NSInteger iProjectUser = [_projectUsers indexOfObjectIdenticalTo:_selectedProjectUser];
    if ( iProjectUser == NSNotFound ) iProjectUser = -1;
    [encoder encodeInt:iProjectUser forKey:@"projectUser"];
    
    [encoder encodeCollectionOfObjects:_dataLoggerItems forKey:@"dataLoggers"];
    [encoder encodeCollectionOfObjects:_restApiItems forKey:@"restApiItems"];
    
    [encoder encodeInt:_embeededAssets forKey:@"embeddedAssets"];
    [encoder encodeStringsArray:_fileList forKey:@"fileList"];
    [encoder encodeInt:_ownerID forKey:@"projectID"];    // deixem aquest nom per despistar una mica
    
    // a partir de 1.0.1 no codifiquem el uuid, el posa el SWDocument com a metaData del arxiu
    // [encoder encodeString:_uuid forKey:@"uuid"];
}



- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent
{
    NSInteger iSelectedPageIndex = [decoder decodeIntForKey:@"selectedPageIndex"];
    if ( iSelectedPageIndex == -1 ) iSelectedPageIndex = NSNotFound;
    _selectedPageIndex = iSelectedPageIndex;
    
    _enableConnections = [decoder decodeIntForKey:@"enableConnections"];
    
    [decoder retrieveForCollectionOfObjects:_systemItems forKey:@"system"];
    
    [decoder retrieveForCollectionOfObjects:_sourceItems forKey:@"sources"];
    [decoder retrieveForCollectionOfObjects:_pages forKey:@"pages"];
    [decoder retrieveForCollectionOfObjects:_backgroundItems forKey:@"backgroundItems"];
    [decoder retrieveForCollectionOfObjects:_alarmItems forKey:@"alarms"];
    [decoder retrieveForCollectionOfObjects:_projectUsers forKey:@"users"];
    [decoder retrieveForCollectionOfObjects:_dataLoggerItems forKey:@"dataLoggers"];
    [decoder retrieveForCollectionOfObjects:_restApiItems forKey:@"restApiItems"];
    
    NSInteger iProjectUser = [decoder decodeIntForKey:@"projectUser"];
    if ( iProjectUser >= 0 && iProjectUser < _projectUsers.count )
        _selectedProjectUser = [_projectUsers objectAtIndex:iProjectUser];
    else _selectedProjectUser = nil;
}


- (void)storeWithSymbolicCoder:(SymbolicArchiver*) encoder
{
    NSInteger iSelectedPageIndex = _selectedPageIndex;
    if ( _selectedPageIndex == NSNotFound ) iSelectedPageIndex = -1;
    [encoder encodeInt:iSelectedPageIndex forKey:@"selectedPageIndex"];
    
    [encoder encodeInt:_enableConnections forKey:@"enableConnections"];
    
    [encoder encodeCollectionOfObjects:_systemItems forKey:@"system"];
    
    [encoder encodeCollectionOfObjects:_sourceItems forKey:@"sources"];
    [encoder encodeCollectionOfObjects:_pages forKey:@"pages"];
    [encoder encodeCollectionOfObjects:_backgroundItems forKey:@"backgroundItems"];
    [encoder encodeCollectionOfObjects:_alarmItems forKey:@"alarms"];
    [encoder encodeCollectionOfObjects:_projectUsers forKey:@"users"];
    [encoder encodeCollectionOfObjects:_dataLoggerItems forKey:@"dataLoggers"];
    [encoder encodeCollectionOfObjects:_restApiItems forKey:@"restApiItems"];
    
    NSInteger iProjectUser = [_projectUsers indexOfObjectIdenticalTo:_selectedProjectUser];
    if ( iProjectUser == NSNotFound ) iProjectUser = -1;
    [encoder encodeInt:iProjectUser forKey:@"projectUser"];
}



- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ : %lu pages, %ld selected page",[super description], (unsigned long)_pages.count, (long)_selectedPageIndex];
}



#pragma mark - Thumbnail

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    _thumbnailImage = thumbnailImage;
    
    // la imatge no esta perseguida per el undo manager, o sigui que hem de fer aixo:
    [_document setHasUnsavedChangesForSavingType:SWDocumentSavingTypeThumbnail];
    
    // avisem els observers
    for (id<DocumentModelObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(documentModelThumbnailDidChange:)])
            [observer documentModelThumbnailDidChange:self];
    }
}


#pragma mark - Title

- (void)updateTitleNotification
{
    // avisem els observers
    for (id<DocumentModelObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(documentModelTitleDidChange:)])
            [observer documentModelTitleDidChange:self];
    }
}

- (NSString *)title
{
    NSString *title = [_systemItemProject.title valueAsString];
    return title;
}

- (NSString *)shortTitle
{
    NSString *title = [_systemItemProject.shortTitle valueAsString];
    return title;
}


#pragma mark - Supported Interface Orientation

- (void)updateAllowedOrientationNotification
{
    // avisem els observers
    for (id<DocumentModelObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(documentModelAllowedOrientationDidChange:)])
            [observer documentModelAllowedOrientationDidChange:self];
    }
}

- (SWProjectAllowedOrientation)allowedOrientation
{
    SWProjectAllowedOrientation allowedOrientation = [_systemItemProject.allowedOrientation valueAsInteger];
    return allowedOrientation;
}

- (SWProjectAllowedOrientation)allowedOrientationPhone
{
    SWProjectAllowedOrientation allowedOrientationPhone = [_systemItemProject.allowedOrientationPhone valueAsInteger];
    return allowedOrientationPhone;
}

- (SWProjectAllowedOrientation)allowedOrientationForCurrentIdiom
{
    SWProjectAllowedOrientation allowedOrientation = SWProjectAllowedOrientationAny;
    SWDeviceInterfaceIdiom interfaceIdiom = self.interfaceIdiom;
    if ( interfaceIdiom == SWDeviceInterfaceIdiomPad ) allowedOrientation = self.allowedOrientation;
    if ( interfaceIdiom == SWDeviceInterfaceIdiomPhone ) allowedOrientation = self.allowedOrientationPhone;
    return allowedOrientation;
}

#pragma mark - Page visibility


- (NSArray *)visiblePagesV
{
    if ( _editMode )
        return _pages;
    
    if ( _visiblePages == nil )
    {
        _visiblePages = [NSMutableArray array];
        for ( SWPage *page in _pages )
        {
            BOOL isHidden = [page.hidden valueAsBool];
            if ( !isHidden )
            {
                [_visiblePages addObject:page];
            }
        }
    }
    return _visiblePages;
}


- (NSArray *)visiblePages
{
    if ( _editMode )
        return _pages;
    
    if ( _visiblePages == nil )
    {
        _visiblePages = [NSMutableArray array];
        for ( SWPage *page in _pages )
        {
            BOOL show = [self pageIsVisible:page];
            if ( show )
            {
                [_visiblePages addObject:page];
            }
        }
    }
    return _visiblePages;
}


- (BOOL)pageIsVisible:(SWPage*)page
{
    BOOL visible = ! [page.hidden valueAsBool];
            
    if ( visible )
    {
        SWDeviceInterfaceIdiom deviceIdiom = [self interfaceIdiom] ;
        SWPageInterfaceIdiom enabledIdiom = [page.enabledInterfaceIdiom valueAsInteger];
        
        visible = ( enabledIdiom == SWPageInterfaceIdiomPadAndPhone ) ||
            ( enabledIdiom == SWPageInterfaceIdiomPad && deviceIdiom == SWDeviceInterfaceIdiomPad ) ||
            ( enabledIdiom == SWPageInterfaceIdiomPhone && deviceIdiom == SWDeviceInterfaceIdiomPhone ) ;
    }
    
    return visible;
}


- (void)setPagesVisibilityDirty
{
    _visiblePages = nil ;
    
    if ( _waitChangePageVisibility == NO )
    {
        NSArray *observersCopy = [_observers copy];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _waitChangePageVisibility = NO;
 
            // avisem els observers
            for (id<DocumentModelObserver> observer in observersCopy)
            {
                if ([observer respondsToSelector:@selector(documentModelPagesVisibilityDidChange:)])
                    [observer documentModelPagesVisibilityDidChange:self];
            }
        });
    }
    
    _waitChangePageVisibility = YES;
    
//    // avisem els observers
//    for (id<DocumentModelObserver> observer in _observers)
//    {
//        if ([observer respondsToSelector:@selector(documentModelPagesVisibilityDidChange:)])
//            [observer documentModelPagesVisibilityDidChange:self];
//    }

}





#pragma mark - Editing Properties


- (void)_notifyEditingPropertiesDidChange
{
    for (id <DocumentModelObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(documentModelEditingPropertiesDidChange:)])
            [observer documentModelEditingPropertiesDidChange:self];
    }
}


- (void)setAllowFrameEditing:(BOOL)allowFrameEditing
{
    if (allowFrameEditing == _allowFrameEditing)
        return;
    
    _allowFrameEditing = allowFrameEditing;
    
    [self _notifyEditingPropertiesDidChange];
}

- (void)setEnableFineFramePositioning:(BOOL)enableFineFramePositioning
{
    if (enableFineFramePositioning == _enableFineFramePositioning)
        return;
    
    _enableFineFramePositioning = enableFineFramePositioning;
    
    [self _notifyEditingPropertiesDidChange];
}


- (void)setAutoAlignItems:(BOOL)autoAlignItems
{
    if (autoAlignItems == _autoAlignItems)
        return;
    
    _autoAlignItems = autoAlignItems;
    
    [self _notifyEditingPropertiesDidChange];
}

- (void)setAllowsMultipleSelection:(BOOL)multipleSelection
{
    if (multipleSelection == _allowsMultipleSelection)
        return;
    
    // al passar a simple seleccio ho deseleccionem tot. Això es consistent amb el comportament de un UITableView
    if ( multipleSelection == NO )
    {
        for ( SWPage *page in _pages )
        {
            NSIndexSet *indexes = page.selectedItemIndexes;
            [page deselectItemsAtIndexes:indexes];
        }
    }
    
    _allowsMultipleSelection = multipleSelection;

    [self _notifyEditingPropertiesDidChange];
}


- (void)setShowsErrorFrameInEditMode:(BOOL)showsErrorFrameInEditMode
{
    if (showsErrorFrameInEditMode == _showsErrorFrameInEditMode)
        return;
    
    _showsErrorFrameInEditMode = showsErrorFrameInEditMode;
    
    [self _notifyEditingPropertiesDidChange];
}


- (void)setShowsHiddenItemsInEditMode:(BOOL)showsHiddenItemsInEditMode
{
    if (showsHiddenItemsInEditMode == _showsHiddenItemsInEditMode)
        return;
    
    _showsHiddenItemsInEditMode = showsHiddenItemsInEditMode;
    
    [self _notifyEditingPropertiesDidChange];
}


- (SWDeviceInterfaceIdiom)interfaceIdiom
{
    if ( HMiPadRun )
        return IS_IPHONE?SWDeviceInterfaceIdiomPhone:SWDeviceInterfaceIdiomPad;

    return _interfaceIdiom;
}

- (void)setInterfaceIdiom:(SWDeviceInterfaceIdiom)interfaceIdiom
{
    if ( HMiPadRun )
        return;
        
    if (interfaceIdiom == _interfaceIdiom )
        return;

    _interfaceIdiom = interfaceIdiom;
    [_systemItemSystem updateInterfaceIdiomIfNeeded];
    
    NSArray *observers = [_observers copy];
    for (id <DocumentModelObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(documentModelInterfaceIdiomDidChange:)])
            [observer documentModelInterfaceIdiomDidChange:self];
    }
    
    [self setPagesVisibilityDirty];
}



- (void)setEditMode:(BOOL)editMode animated:(BOOL)animated
{
    if (editMode == _editMode)
        return;
    
    _editMode = editMode;
    
    NSArray *observers = [_observers copy];
    for (id <DocumentModelObserver> observer in observers)
    {
//        NSLog( @"observer class: %@", [observer class] );
//        NSLog( @"observer: %@", observer );
        if ([observer respondsToSelector:@selector(documentModel:editingModeDidChangeAnimated:)])
            [observer documentModel:self editingModeDidChangeAnimated:animated];
    }
    
    [self setPagesVisibilityDirty];
}

- (void)setEditMode:(BOOL)editMode
{
    [self setEditMode:editMode animated:NO];
}


//#pragma mark - Current Project user properties

//- (void)setCurrentProjectUserName:(NSString *)currentProjectUserName
//{
//    if (currentProjectUserName == _currentProjectUserName )
//        return;
//
//    _currentProjectUserName = currentProjectUserName;
//    [_systemItemUsersManager updateCurrentUserNameIfNeeded];
//    
//    NSArray *observers = [_observers copy];
//    for (id <DocumentModelObserver> observer in observers)
//    {
//        if ([observer respondsToSelector:@selector(documentModelCurrentProjectUserNameDidChange:)])
//            [observer documentModelCurrentProjectUserNameDidChange:self];
//    }
//}


//- (void)setCurrentProjectUserLevel:(NSInteger)currentProjectUserLevel
//{
//    if (currentProjectUserLevel == _currentProjectUserLevel )
//        return;
//
//    _currentProjectUserLevel = currentProjectUserLevel;
//    [_systemItemUsersManager updateCurrentUserLevelIfNeeded];
//    
//    NSArray *observers = [_observers copy];
//    for (id <DocumentModelObserver> observer in observers)
//    {
//        if ([observer respondsToSelector:@selector(documentModelCurrentProjectUserLevelDidChange:)])
//            [observer documentModelCurrentProjectUserLevelDidChange:self];
//    }
//}


#pragma mark - Document Model observation

- (void)addObserver:(id<DocumentModelObserver>)observer
{
    //if (![_observers containsObject:observer])
        [_observers addObject:observer];
}

- (void)removeObserver:(id<DocumentModelObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}

#pragma mark - changeCheckpointNotification

- (void)changeCheckpointNotification
{
    NSArray *observersCopy = [_observers copy];
    for (id <DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModelChangeCheckpoint:)])
            [observer documentModelChangeCheckpoint:self];
    }
}

#pragma mark - saveCheckpointNotification
- (void)saveCheckpointNotification
{
    NSArray *observersCopy = [_observers copy];
    for (id <DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModelSaveCheckpoint:)])
            [observer documentModelSaveCheckpoint:self];
    }
}


#pragma mark - Generic insertion/deletion/selection

- (NSArray*)objectsOfType:(SWArrayType)type
{
    switch (type)
    {
        case SWArrayTypeSystemItems:
            return _systemItems;
            break;
    
        case SWArrayTypePages:
            return _pages;
            break;
            
        case SWArrayTypeBackgroundItems:
            return _backgroundItems;
            break;
        
        case SWArrayTypeSources:
            return _sourceItems;
            break;
            
        case SWArrayTypeAlarms:
            return _alarmItems;
            break;
            
        case SWArrayTypeProjectUsers:
            return _projectUsers;
            break;
            
        case SWArrayTypeDataLoggers:
            return _dataLoggerItems;
            break;
            
        case SWArrayTypeRestApiItems:
            return _restApiItems;
            break;
            
        case SWArrayTypeUnknown:
            return nil;
            break;
    }
}

- (void)addObject:(id)object ofType:(SWArrayType)type
{
    switch (type)
    {
        case SWArrayTypeSystemItems:
            // not allowed;
            break;
            
        case SWArrayTypePages:
            [self addPage:object];
            break;
            
        case SWArrayTypeBackgroundItems:
            [self addBackgroundItem:object];
            break;
        
        case SWArrayTypeSources:
            [self addSourceItem:object];
            break;
        
        case SWArrayTypeAlarms:
            [self addAlarmItem:object];
            break;
            
        case SWArrayTypeProjectUsers:
            [self addProjectUser:object];
            break;
            
        case SWArrayTypeDataLoggers:
            [self addDataLoggerItem:object];
            break;
            
        case SWArrayTypeRestApiItems:
            [self addRestApiItem:object];
            break;
            
        case SWArrayTypeUnknown:
            break;
    }
}

- (void)insertObjects:(NSArray*)array atIndexes:(NSIndexSet *)indexes ofType:(SWArrayType)type
{
    switch (type)
    {
        case SWArrayTypeSystemItems:
            // not allowed;
            break;
            
        case SWArrayTypePages:
            [self insertPages:array atIndexes:indexes];
            break;
            
        case SWArrayTypeBackgroundItems:
            [self insertBackgroundItems:array atIndexes:indexes];
            break;
            
        case SWArrayTypeSources:
            [self insertSourceItems:array atIndexes:indexes];
            break;
        
        case SWArrayTypeAlarms:
            [self insertAlarmItems:array atIndexes:indexes];
            break;
            
        case SWArrayTypeProjectUsers:
            [self insertProjectUsers:array atIndexes:indexes];
            break;
            
        case SWArrayTypeDataLoggers:
            [self insertDataLoggerItems:array atIndexes:indexes];
            break;
            
        case SWArrayTypeRestApiItems:
            [self insertRestApiItems:array atIndexes:indexes];
            break;
            
        case SWArrayTypeUnknown:
            break;
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes ofType:(SWArrayType)type
{
    switch (type)
    {
        case SWArrayTypeSystemItems:
            // not allowed;
            break;
    
        case SWArrayTypePages:
            [self removePagesAtIndexes:indexes];
            break;
            
        case SWArrayTypeBackgroundItems:
            [self removeBackgroundItemsAtIndexes:indexes];
            break;
            
        case SWArrayTypeSources:
            [self removeSourceItemsAtIndexes:indexes];
            break;
            
        case SWArrayTypeAlarms:
            [self removeAlarmItemsAtIndexes:indexes];
            break;
            
        case SWArrayTypeProjectUsers:
            [self removeProjectUsersAtIndexes:indexes];
            break;
            
        case SWArrayTypeDataLoggers:
            [self removeDataLoggerItemsAtIndexes:indexes];
            break;
            
        case SWArrayTypeRestApiItems:
            [self removeRestApiItemsAtIndexes:indexes];
            break;
            
        case SWArrayTypeUnknown:
            break;
    }
}

- (void)moveObjectAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex ofType:(SWArrayType)type
{
    switch (type)
    {
        case SWArrayTypeSystemItems:
            // not allowed;
            break;
            
        case SWArrayTypePages:
            [self movePageAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeBackgroundItems:
            [self moveBackgroundItemAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeSources:
            [self moveSourceItemAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeAlarms:
            [self moveAlarmItemAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeProjectUsers:
            [self moveProjectUserAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeDataLoggers:
            [self moveDataLoggerItemAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeRestApiItems:
            [self moveRestApiItemAtIndex:sourceIndex toIndex:destinationIndex];
            break;
            
        case SWArrayTypeUnknown:
            break;
    }
}

#pragma mark - Page insertion/deletion/selection

- (void)_doSelectPageAtIndex:(NSInteger)selectedPageIndex
{
    if (selectedPageIndex >= _pages.count && selectedPageIndex != NSNotFound)
    {
        NSLog(@"[olp023] WARNING: Requesting to select page at index %ld out of pages array bounds [0..%lu]",(long)selectedPageIndex, (long)_pages.count-1);
        NSAssert( NO, nil );
        return;
    }
    
    NSInteger direction = 0 ;
    if ( _selectedPageIndex != NSNotFound && selectedPageIndex != NSNotFound )
    {
        if ( selectedPageIndex > _selectedPageIndex ) direction = 1;
        if ( selectedPageIndex < _selectedPageIndex ) direction = -1;
    }
    
    _selectedPageIndex = selectedPageIndex;
    
    
    
    
    NSArray *observersCopy = [_observers copy];
    for (id <DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:selectedPageDidChange:direction:)])
            [observer documentModel:self selectedPageDidChange:_selectedPageIndex direction:direction];
    }
    
    [_systemItemProject updateCurrentPageIdentifierIfNeeded];
}

- (void)_doSelectedIndexChangeWithOldIndex:(NSInteger)oldIndex
{    
//    NSInteger direction = 0 ;
//    if ( oldIndex != _selectedPageIndex )
//    {
//        if ( _selectedPageIndex > oldIndex ) direction = 1;
//        if ( _selectedPageIndex < oldIndex ) direction = -1;
//    }
    
    // sempre cridem els observadors, pero es pot detectar si no hi ha hagut canvi si direction==0
    NSArray *observersCopy = [_observers copy];
    for (id <DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:selectedPageDidChangeToIndex:oldIndex:)])
            [observer documentModel:self selectedPageDidChangeToIndex:_selectedPageIndex oldIndex:oldIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didSelectObjectOfType:atIndex:oldIndex:)])
            [observer documentModel:self didSelectObjectOfType:SWArrayTypePages atIndex:_selectedPageIndex oldIndex:oldIndex];
    }
}

- (void)selectPageAtIndex:(NSInteger)selectedPageIndex
{
    if (selectedPageIndex == _selectedPageIndex)
        return;
    
    NSInteger currentSelectedIndex = _selectedPageIndex;
    
    SWPage *page = [_pages objectAtIndex:_selectedPageIndex];
    [page deselectItemsAtIndexes:[page selectedItemIndexes]];
    
    [self _doSelectPageAtIndex:selectedPageIndex];
    [self _doSelectedIndexChangeWithOldIndex:currentSelectedIndex];
}

//- (void)selectPageWithTitle:(NSString*)selectedTitle
//{
//    NSInteger indx = 0;
//    for ( SWPage *page in _pages )
//    {
//        if ( [selectedTitle isEqual:page.title.valueAsString] )
//        {
//            [self selectPageAtIndex:indx];
//            break;;
//        }
//        indx += 1;
//    }
//}


- (void)selectPageWithPageIdentifier:(NSString*)pageIdentifier
{
    NSInteger indx = 0;
    for ( SWPage *page in _pages )
    {
        if ( [pageIdentifier isEqualToString:[page.pageIdentifier valueAsString]] )
        {
            [self selectPageAtIndex:indx];
            break;;
        }
        indx += 1;
    }
}


//- (SWDataLoggerItem *)dataLoggerItemWithIdentifier:(NSString*)dbIdentifier
//{
//    for ( SWDataLoggerItem *dbItem in _dataLoggerItems )
//    {
//        if ( [dbIdentifier isEqualToString:[dbItem.databaseIdentifier valueAsString]] )
//        {
//            return dbItem;
//        }
//    }
//    return nil;
//}



- (void)addPage:(SWPage*)page
{
    [self insertPages:[NSArray arrayWithObject:page] atIndexes:[NSIndexSet indexSetWithIndex:_pages.count]];
}

- (void)insertPages:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{    
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
    
    NSInteger initialPageCount = _pages.count;
    
    // si indexes es nil assumim que volem afegir les pagines al final
    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:initialPageCount+i];
        
        indexes = [indexSet copy];
    }
    
    // observacio
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willInsertPagesAtIndexes:)])
            [observer documentModel:self willInsertPagesAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self willInsertObjectsOfType:SWArrayTypePages atIndexes:indexes];
    }
    
    // determinem el index seleccionat actual
    NSInteger currentSelectedIndex = _selectedPageIndex;
    
    // insertem en el array de pagines
    [_pages insertObjects:array atIndexes:indexes];
    
    // actualitzem el _selectedPageIndex apuntant al primer index insertat
    NSInteger newSelectedIndex = [indexes firstIndex];
    
    NSInteger outTransition = 1;  // cap a la dreta
    if ( newSelectedIndex < currentSelectedIndex ) outTransition = -1;
    
    NSInteger inTransition = 0;
    if ( newSelectedIndex < currentSelectedIndex ) inTransition = 1;
    if ( newSelectedIndex > currentSelectedIndex ) inTransition = -1;
    
    // undo
    NSUndoManager *undoManager = _document.undoManager;
    //[[undoManager prepareWithInvocationTarget:self] selectPageAtIndex:currentSelectedIndex];
    [[undoManager prepareWithInvocationTarget:self] removePagesAtIndexes:indexes];
    [undoManager setActionName:array.count>1?NSLocalizedString(@"Add Pages",nil):NSLocalizedString(@"Add Page",nil)];
    
    // observacio
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertPagesAtIndexes:)])
            [observer documentModel:self didInsertPagesAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypePages atIndexes:indexes];
    }
    
    [self _doSelectPageAtIndex:newSelectedIndex]; //el index pot haver canviat o no, pero la pagina segur que si!
    [self _doSelectedIndexChangeWithOldIndex:currentSelectedIndex];
    
    if ( initialPageCount == 0 )
        [self setPagesVisibilityDirty];
}

- (void)removePagesAtIndexes:(NSIndexSet *)indexes
{    
    NSArray *deletedPages = [_pages objectsAtIndexes:indexes];
    
    if (deletedPages.count == 0)
        return;
    
    // Observacio Will
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemovePagesAtIndexes:)])
            [observer documentModel:self willRemovePagesAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypePages atIndexes:indexes];
    }
    
    [deletedPages makeObjectsPerformSelector:@selector(putToSleep)];
    
    // determinem el index seleccionat actual
    NSInteger currentSelectedIndex = _selectedPageIndex;

    // determinem la pagina seleccionada actual
    SWPage *page = nil;
    if (_selectedPageIndex != NSNotFound)
        page = [_pages objectAtIndex:_selectedPageIndex];
        
    // eliminem en el array de pagines
    [_pages removeObjectsAtIndexes:indexes];
        
    // actualitzem el selectedPageIndex per apuntar a la mateixa pagina d'avans si existeix, en cas contrari
    // deixem seleccionada la pagina que estava en el primer index esborrat
    NSInteger newSelectedIndex = [_pages indexOfObjectIdenticalTo:page];
    if ( newSelectedIndex == NSNotFound )
    {
        newSelectedIndex = [indexes firstIndex];
        
        // Si la nova seleccio és massa "gran", sel·leccionem la darrera pàgina si n'hi ha alguna, altrament NSNotFound.
        NSInteger pagesCount = _pages.count;
        if (newSelectedIndex >= pagesCount)
            newSelectedIndex = pagesCount>0?pagesCount-1:NSNotFound;
            
        NSInteger outTransition = 0;
        if ( newSelectedIndex < currentSelectedIndex ) outTransition = 1;
        if ( newSelectedIndex > currentSelectedIndex ) outTransition = -1;
            
        NSInteger inTransition = 1;  // cap a la dreta
        if ( newSelectedIndex < currentSelectedIndex ) inTransition = -1;
            
        //el index pot haver canviat o no, pero la pagina segur que si!
        [self _doSelectPageAtIndex:newSelectedIndex];
    }
    else
    {
        // el index pot haver canviat, pero no la pagina per tant no cridem cap delegat
        _selectedPageIndex = newSelectedIndex;
    }
    
    //[self _doSelectedIndexChangeWithOldIndex:NSNotFound];
        
    // undo
    NSUndoManager *undoManager = _document.undoManager;
    //[[undoManager prepareWithInvocationTarget:self] selectPageAtIndex:currentSelectedIndex];
    [[undoManager prepareWithInvocationTarget:self] insertPages:deletedPages atIndexes:indexes];
    [undoManager setActionName:deletedPages.count>1?NSLocalizedString(@"Remove Pages",nil):NSLocalizedString(@"Remove Page",nil)];
        
    // Observacio Did
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemovePagesAtIndexes:)])
            [observer documentModel:self didRemovePagesAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypePages atIndexes:indexes];
    }
    
    [self _doSelectedIndexChangeWithOldIndex:NSNotFound];
    
    if ( _pages.count == 0 )
        [self setPagesVisibilityDirty];
}

- (void)movePageAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWPage *page = [_pages objectAtIndex:sourceIndex];

    [_pages removeObjectAtIndex:sourceIndex];
    [_pages insertObject:page atIndex:destinationIndex];
    
    NSInteger selectedIndex = _selectedPageIndex;
    if (selectedIndex == sourceIndex) 
    {
        _selectedPageIndex = destinationIndex;
    }
    else if ( sourceIndex < destinationIndex)
    {
        if (selectedIndex > sourceIndex)
            _selectedPageIndex--;
        if (selectedIndex > destinationIndex)
            _selectedPageIndex++;
    }
    else if ( sourceIndex > destinationIndex)
    {
        if (selectedIndex < sourceIndex)
            _selectedPageIndex++;
        if (selectedIndex < destinationIndex)
            _selectedPageIndex--;
    }
    
    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] movePageAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:NSLocalizedString(@"Move Page",nil)];
    
    NSArray *observersCopy = [_observers copy];  
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMovePageAtIndex:toIndex:)])
            [observer documentModel:self didMovePageAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypePages atIndex:sourceIndex toIndex:destinationIndex];
    }
    
    [self _doSelectedIndexChangeWithOldIndex:selectedIndex];
}

#pragma mark - Background items insertion/deletion/ignition

- (void)addBackgroundItem:(SWBackgroundItem*)object
{
    [self insertBackgroundItems:[NSArray arrayWithObject:object] atIndexes:[NSIndexSet indexSetWithIndex:_backgroundItems.count]];
}

- (void)insertBackgroundItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
    
    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSInteger size = _backgroundItems.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }
    
    [_backgroundItems insertObjects:array atIndexes:indexes];

    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] removeBackgroundItemsAtIndexes:indexes];
    [undoManager setActionName:@"Add Background Item"];
    
    NSArray *observersCopy = [_observers copy];  
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertBackgroundItemsAtIndexes:)])
            [observer documentModel:self didInsertBackgroundItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypeBackgroundItems atIndexes:indexes];
    }
}

- (void)removeBackgroundItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *deletedObjects = [_backgroundItems objectsAtIndexes:indexes];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemoveBackgroundItemsAtIndexes:)])
            [observer documentModel:self willRemoveBackgroundItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypeBackgroundItems atIndexes:indexes];
    }
    
    [deletedObjects makeObjectsPerformSelector:@selector(putToSleep)];
    
    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] insertBackgroundItems:deletedObjects atIndexes:indexes];
    [undoManager setActionName:@"Remove Background Item"];
    
    [_backgroundItems removeObjectsAtIndexes:indexes];
    
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemoveBackgroundItemsAtIndexes:)])
            [observer documentModel:self didRemoveBackgroundItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypeBackgroundItems atIndexes:indexes];
    }
}

- (void)moveBackgroundItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWObject *object = [_backgroundItems objectAtIndex:sourceIndex];
    [_backgroundItems removeObjectAtIndex:sourceIndex];
    [_backgroundItems insertObject:object atIndex:destinationIndex];
    
    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] moveBackgroundItemAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:@"Move Background Item"];
    
    NSArray *observersCopy = [_observers copy];  
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMoveBackgroundItemAtIndex:toIndex:)])
            [observer documentModel:self didMoveBackgroundItemAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypeBackgroundItems atIndex:sourceIndex toIndex:destinationIndex];
    }
}

#pragma mark - Source items insertion/deletion/ignition

- (void)addSourceItem:(SWSourceItem*)object
{
    [self insertSourceItems:[NSArray arrayWithObject:object] atIndexes:[NSIndexSet indexSetWithIndex:_sourceItems.count]];
}

- (void)insertSourceItems:(NSArray *)array atIndexes:(NSIndexSet*)indexes
{
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];

    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSInteger size = _sourceItems.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }
    
    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] removeSourceItemsAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Add Sources",nil)];
    
    [_sourceItems insertObjects:array atIndexes:indexes];

    // TODO : S'ha de fer quelcom amb els inserted sources?
    for (SWSourceItem *source in array)
    {
        if (source.monitorOn)
            [source igniteCommunications];
    }
    
    NSArray *observersCopy = [_observers copy];  
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertSourceItemsAtIndexes:)])
            [observer documentModel:self didInsertSourceItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypeSources atIndexes:indexes];
    }
}

- (void)removeSourceItemsAtIndexes:(NSIndexSet*)indexes
{
    NSArray *deletedSources = [_sourceItems objectsAtIndexes:indexes];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemoveSourceItemsAtIndexes:)])
            [observer documentModel:self willRemoveSourceItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypeSources atIndexes:indexes];
    }
    
    [deletedSources makeObjectsPerformSelector:@selector(putToSleep)];
    
    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] insertSourceItems:deletedSources atIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Remove Sources",nil)];
    
    [_sourceItems removeObjectsAtIndexes:indexes];
    
    [deletedSources makeObjectsPerformSelector:@selector(closeCommunications)]; // <---------------------------------- S'ha de fer quelcom amb els deleted sources?
    
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemoveSourceItemsAtIndexes:)])
            [observer documentModel:self didRemoveSourceItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypeSources atIndexes:indexes];
    }
}

- (void)moveSourceItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWObject *object = [_sourceItems objectAtIndex:sourceIndex];
    [_sourceItems removeObjectAtIndex:sourceIndex];
    [_sourceItems insertObject:object atIndex:destinationIndex];
    
    NSUndoManager *undoManager = _document.undoManager;
    [[undoManager prepareWithInvocationTarget:self] moveSourceItemAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:@"Move Source Item"];
    
    NSArray *observersCopy = [_observers copy];  
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMoveSourceItemAtIndex:toIndex:)])
            [observer documentModel:self didMoveSourceItemAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypeSources atIndex:sourceIndex toIndex:destinationIndex];
    }
}


- (void)igniteSources
{
    for ( SWSourceItem *source in _sourceItems )
    {
        if (source.monitorOn) 
            [source igniteCommunications];
    }
}

- (void)clausureSources
{
    [_sourceItems makeObjectsPerformSelector:@selector(closeCommunications)];
}

- (void)setEnableConnections:(BOOL)enableConnections
{
    if ( enableConnections == _enableConnections)
        return;
        
    _enableConnections = enableConnections;
    
    
    for (SWSourceItem *item in _sourceItems)
    {
        [item setMonitorState:enableConnections];
    }
    
    NSArray *observersCopy = [_observers copy];  
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModelEnableConnectionsDidChange:)])
            [observer documentModelEnableConnectionsDidChange:self];
    }

}

#pragma mark - AlarmItems

- (void)addAlarmItem:(SWAlarm*)item
{
    [self insertAlarmItems:[NSArray arrayWithObject:item] atIndexes:[NSIndexSet indexSetWithIndex:_alarmItems.count]];
}

- (void)insertAlarmItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSInteger size = _alarmItems.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }
    
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
    
    [_alarmItems insertObjects:array atIndexes:indexes];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] removeAlarmItemsAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Add Alarm Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertAlarmItemsAtIndexes:)])
            [observer documentModel:self didInsertAlarmItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypeAlarms atIndexes:indexes];
    }
}

- (void)removeAlarmItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *deletedObjects = [_alarmItems objectsAtIndexes:indexes];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemoveAlarmItemsAtIndexes:)])
            [observer documentModel:self willRemoveAlarmItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypeAlarms atIndexes:indexes];
    }
    
    [deletedObjects makeObjectsPerformSelector:@selector(putToSleep)];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] insertAlarmItems:deletedObjects atIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Remove Alarm Item",nil)];
    
    [_alarmItems removeObjectsAtIndexes:indexes];
    
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemoveAlarmItemsAtIndexes:)])
            [observer documentModel:self didRemoveAlarmItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypeAlarms atIndexes:indexes];
    }
}

- (void)moveAlarmItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWAlarm *object = [_alarmItems objectAtIndex:sourceIndex];
    [_alarmItems removeObjectAtIndex:sourceIndex];
    [_alarmItems insertObject:object atIndex:destinationIndex];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] moveAlarmItemAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:NSLocalizedString(@"Move Alarm Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMoveAlarmItemAtIndex:toIndex:)])
            [observer documentModel:self didMoveAlarmItemAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypeAlarms atIndex:sourceIndex toIndex:destinationIndex];
    }
}


#pragma mark - System Events

- (void)addSystemEventWithLabel:(NSString*)label comment:(NSString*)comment
{
    SWEvent *event = [[SWEvent alloc] initWithLabel:label comment:comment active:NO];
    [_eventCenter eventsAddSystemEvent:event];
    [_histoAlarms addEvent:event];
}

#pragma mark - ProjectUsers

- (void)_notifyProjectUsersAvailableChange
{
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModelUsersAvailableDidChange:)])
            [observer documentModelUsersAvailableDidChange:self];
    }
}





//- (void)setProjectUserEnabled:(BOOL)value
//{
//    if ( value == NO )
//        _selectedProjectUser = nil;
//}
//
//
//- (BOOL)projectUserEnabled
//{
//    BOOL enabled = (_selectedProjectUser != nil);
//    return enabled;
//}


- (void)addProjectUser:(SWProjectUser*)item
{
    [self insertProjectUsers:[NSArray arrayWithObject:item] atIndexes:[NSIndexSet indexSetWithIndex:_projectUsers.count]];
}

- (void)insertProjectUsers:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSInteger size = _projectUsers.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }
    
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
    
    [_projectUsers insertObjects:array atIndexes:indexes];
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] removeProjectUsersAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Add Project User",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertProjectUsersAtIndexes:)])
            [observer documentModel:self didInsertProjectUsersAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypeProjectUsers atIndexes:indexes];
    }
    
    [self _notifyProjectUsersAvailableChange];
}


- (void)removeProjectUsersAtIndexes:(NSIndexSet *)indexes
{
    NSArray *deletedObjects = [_projectUsers objectsAtIndexes:indexes];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemoveProjectUsersAtIndexes:)])
            [observer documentModel:self willRemoveProjectUsersAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypeProjectUsers atIndexes:indexes];
    }
    
    [deletedObjects makeObjectsPerformSelector:@selector(putToSleep)];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] insertProjectUsers:deletedObjects atIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Remove Project User",nil)];
    
    if ( [deletedObjects indexOfObjectIdenticalTo:_selectedProjectUser] != NSNotFound )
        [self selectProjectUser:nil];
    
    [_projectUsers removeObjectsAtIndexes:indexes];

    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemoveProjectUsersAtIndexes:)])
            [observer documentModel:self didRemoveProjectUsersAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypeProjectUsers atIndexes:indexes];
    }
    
    [self _notifyProjectUsersAvailableChange];
}


- (void)moveProjectUserAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWProjectUser *object = [_projectUsers objectAtIndex:sourceIndex];
    [_projectUsers removeObjectAtIndex:sourceIndex];
    [_projectUsers insertObject:object atIndex:destinationIndex];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] moveProjectUserAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:NSLocalizedString(@"Move Project User",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMoveProjectUserAtIndex:toIndex:)])
            [observer documentModel:self didMoveProjectUserAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypeProjectUsers atIndex:sourceIndex toIndex:destinationIndex];
    }
}


- (void)selectProjectUser:(SWProjectUser *)prjUser
{
    SWProjectUser *newSelected = nil;
    NSInteger index = [_projectUsers indexOfObjectIdenticalTo:prjUser];

    if ( index != NSNotFound )
        newSelected = prjUser;
    
    _selectedProjectUser = newSelected;
    
    // not undoable, saving right now !
    [_document saveWithCompletion:nil];

    [_systemItemUsersManager updateCurrentProjectUserIfNeeded];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:selectedProjectUserDidChange:)])
            [observer documentModel:self selectedProjectUserDidChange:_selectedProjectUser];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kProjectUserDidChangeNotification object:nil];
}


//- (void)showProjectUserLoginIfNeededB
//{
//    // mostra login si havent usuaris no n'hi ha cap de seleccionat o ho volem explicitament
//    if ( _projectUsers.count > 0 )
//    {
//        BOOL noUserSelected = HMiPadRun && (_selectedProjectUser == nil);
//        BOOL enableAutoLogin = [_systemItemUsersManager.enableAutoLogin valueAsBool];
//        if ( noUserSelected || enableAutoLogin==NO )
//        {
//            [_systemItemUsersManager performForcedLogin];
//        }
//    }
//}


- (void)showProjectUserLoginIfNeeded
{
    // mostra login si havent usuaris no n'hi ha cap de seleccionat o ho volem explicitament
    if ( _projectUsers.count > 0 )
    {
        BOOL enableAutoLogin = [_systemItemUsersManager.enableAutoLogin valueAsBool];
        if ( enableAutoLogin==NO )
        {
            [_systemItemUsersManager performForcedLogin];
        }
    }
}


- (void)showProjectUserLogin
{
    [_systemItemUsersManager performOptionalLogin];
}


- (void)dismissProjectUserLogin
{
    //[self selectProjectUser:_selectedProjectUser];
    [_systemItemUsersManager performDismissLogin];
}


#pragma mark - DatabaseItems

- (void)addDataLoggerItem:(SWDataLoggerItem*)item
{
    [self insertDataLoggerItems:[NSArray arrayWithObject:item] atIndexes:[NSIndexSet indexSetWithIndex:_dataLoggerItems.count]];
}


- (void)insertDataLoggerItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSInteger size = _dataLoggerItems.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }
    
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
    
    [_dataLoggerItems insertObjects:array atIndexes:indexes];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] removeDataLoggerItemsAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Add Database Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertDataLoggerItemsAtIndexes:)])
            [observer documentModel:self didInsertDataLoggerItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypeDataLoggers atIndexes:indexes];
    }
}


- (void)removeDataLoggerItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *deletedObjects = [_dataLoggerItems objectsAtIndexes:indexes];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemoveDataLoggerItemsAtIndexes:)])
            [observer documentModel:self willRemoveDataLoggerItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypeDataLoggers atIndexes:indexes];
    }
    
    [deletedObjects makeObjectsPerformSelector:@selector(putToSleep)];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] insertDataLoggerItems:deletedObjects atIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Remove Database Item",nil)];
    
    [_dataLoggerItems removeObjectsAtIndexes:indexes];
    
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemoveDataLoggerItemsAtIndexes:)])
            [observer documentModel:self didRemoveDataLoggerItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypeDataLoggers atIndexes:indexes];
    }
}


- (void)moveDataLoggerItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWDataLoggerItem *object = [_dataLoggerItems objectAtIndex:sourceIndex];
    [_dataLoggerItems removeObjectAtIndex:sourceIndex];
    [_dataLoggerItems insertObject:object atIndex:destinationIndex];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] moveDataLoggerItemAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:NSLocalizedString(@"Move Database Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMoveDataLoggerItemAtIndex:toIndex:)])
            [observer documentModel:self didMoveDataLoggerItemAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypeDataLoggers atIndex:sourceIndex toIndex:destinationIndex];
    }
}


#pragma mark - RestApiItems

- (void)addRestApiItem:(SWRestApiItem*)item
{
    [self insertRestApiItems:[NSArray arrayWithObject:item] atIndexes:[NSIndexSet indexSetWithIndex:_restApiItems.count]];
}


- (void)insertRestApiItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        NSInteger count = array.count;
        NSInteger size = _restApiItems.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }
    
    [array makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
    
    [_restApiItems insertObjects:array atIndexes:indexes];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] removeRestApiItemsAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Add Database Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didInsertRestApiItemsAtIndexes:)])
            [observer documentModel:self didInsertRestApiItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didInsertObjectsOfType:atIndexes:)])
            [observer documentModel:self didInsertObjectsOfType:SWArrayTypeRestApiItems atIndexes:indexes];
    }
}


- (void)removeRestApiItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *deletedObjects = [_restApiItems objectsAtIndexes:indexes];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:willRemoveRestApiItemsAtIndexes:)])
            [observer documentModel:self willRemoveRestApiItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:willRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self willRemoveObjectsOfType:SWArrayTypeRestApiItems atIndexes:indexes];
    }
    
    [deletedObjects makeObjectsPerformSelector:@selector(putToSleep)];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] insertRestApiItems:deletedObjects atIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Remove Database Item",nil)];
    
    [_restApiItems removeObjectsAtIndexes:indexes];
    
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didRemoveRestApiItemsAtIndexes:)])
            [observer documentModel:self didRemoveRestApiItemsAtIndexes:indexes];
        
        if ([observer respondsToSelector:@selector(documentModel:didRemoveObjectsOfType:atIndexes:)])
            [observer documentModel:self didRemoveObjectsOfType:SWArrayTypeRestApiItems atIndexes:indexes];
    }
}


- (void)moveRestApiItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWRestApiItem *object = [_restApiItems objectAtIndex:sourceIndex];
    [_restApiItems removeObjectAtIndex:sourceIndex];
    [_restApiItems insertObject:object atIndex:destinationIndex];
    
    NSUndoManager *undoManager = self.undoManager;
    [[undoManager prepareWithInvocationTarget:self] moveRestApiItemAtIndex:destinationIndex toIndex:sourceIndex];
    [undoManager setActionName:NSLocalizedString(@"Move Rest Api Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<DocumentModelObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(documentModel:didMoveRestApiItemAtIndex:toIndex:)])
            [observer documentModel:self didMoveRestApiItemAtIndex:sourceIndex toIndex:destinationIndex];
        
        if ([observer respondsToSelector:@selector(documentModel:didMoveObjectOfType:atIndex:toIndex:)])
            [observer documentModel:self didMoveObjectOfType:SWArrayTypeRestApiItems atIndex:sourceIndex toIndex:destinationIndex];
    }
}


#pragma mark - FileList

- (void)setFileList:(NSArray*)fileList
{
//    NSArray *oldFileList = _fileList;
    ///_fileList = [fileList copy];
    
    _fileList = [fileList sortedArrayUsingSelector:@selector(compare:)];
    
// undo pot anar pero decidim no suportar-ho
//    NSUndoManager *undoManager = _document.undoManager;
//    [[undoManager prepareWithInvocationTarget:self] setFileList:oldFileList];
    
    [_document updateChangeCount];  // <-- updatem el change count directament perque aquesta propietat no es undoable
    
    for (id<DocumentModelObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(documentModelFileListDidChange:)])
            [observer documentModelFileListDidChange:self];
    }
}


- (NSString*)redeemedName
{
    NSString *redeemedName = nil;

    if ( _embeededAssets || HMiPadRun) redeemedName = /*_document.redeemedName*/ [_document getFileName];

    return redeemedName;
}

- (NSString*)documentName
{
    return [_document getName];
}


- (BOOL)embeededAssets
{
    return _embeededAssets;
}

- (void)setEmbeededAssets:(BOOL)embeededAssets
{
    _embeededAssets = embeededAssets;
    
    [_document updateChangeCount];  // <-- updatem el change count directament perque aquesta propietat no es undoable
    
    for (id<DocumentModelObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(documentModelEmbeddedAssetsDidChange:)])
            [observer documentModelEmbeddedAssetsDidChange:self];
    }
}

@end 


@implementation SWDocumentModel(primitiveSetThumbnail)

- (void)primitiveSetThumbnail:(UIImage*)image
{
    _thumbnailImage = image;
}

@end
