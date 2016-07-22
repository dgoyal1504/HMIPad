//
//  SWDocument.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWDocument.h"
#import "SWPage.h"
#import "SWSourceItem.h"
#import "SWModelTypes.h"
#import "NSFileManager+Directories.h"

@interface SWDocumentModel (Private)


@end


@implementation SWDocumentModel

@synthesize document = _document;
@synthesize delegate = _delegate;
@synthesize builder = _builder;
@synthesize sysExpressions = _sysExpressions;
@synthesize pages = _pages;
@synthesize name = _name;
@synthesize about = _about;
@synthesize sourceItems = _sourceItems;
@synthesize selectedPageIndex = _selectedPageIndex;
@synthesize uuid = _uuid;


#pragma mark - Methods

- (void)doInit
{
    _observers = [NSMutableArray array];
        
    _pages = [NSMutableArray array];
    _sourceItems = [NSMutableArray array];
        
    _name = @"New Document";
    _about = @"You've just created a new document. Now you can customize it.";
        
    _selectedPageIndex = NSNotFound;
        
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    _uuid = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        [self doInit] ;
        
//        _sysExpressions = [[SystemExpressions alloc] init];
//        _builder = [[RpnBuilder alloc] init];
//        [_builder setSystemTable:[_sysExpressions symbolTable]];
        
        _builder = [[RpnBuilder alloc] init];
        _sysExpressions = [[SystemExpressions alloc] initWithBuilder:_builder];
    }
    return self;
}

- (NSUndoManager*)undoManager
{

    NSLog( @"undo %@", [_document undoManager] ) ;
    return [_document undoManager];
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)unarchiver
{
    self = [super init];
    if (self) 
    {
        _sysExpressions = [unarchiver decodeObject];
        _builder = [unarchiver decodeObject];
        //[_builder setSystemTable:[_sysExpressions symbolTable]];
        _pages = [unarchiver decodeObject];
        _selectedPageIndex = [unarchiver decodeInt];
        _sourceItems = [unarchiver decodeObject];
        _name = [unarchiver decodeObject];
        _about = [unarchiver decodeObject];
        _uuid = [unarchiver decodeObject];
        
        _observers = [NSMutableArray array];
        
        NSLog(@"Awaked document %@",_uuid);
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)archiver
{
//    NSInteger selectedPageIndex = _selectedPageIndex;
//    if (_pages.count == 0 && _selectedPageIndex != NSNotFound) {
//        selectedPageIndex = NSNotFound;
//        NSLog(@"[is8223] WARNING: while coding _selectedPageIndex, found error! %d bounds [0..%d]",_selectedPageIndex, _pages.count);
//    } else if (_selectedPageIndex >= _pages.count) {
//        selectedPageIndex = 0;
//        NSLog(@"[is8222] WARNING: while coding _selectedPageIndex, found error! %d bounds [0..%d]",_selectedPageIndex, _pages.count);
//    }
    
    [archiver encodeObject:_sysExpressions];
    [archiver encodeObject:_builder];
    [archiver encodeObject:_pages];
    [archiver encodeInt:_selectedPageIndex];
    [archiver encodeObject:_sourceItems];
    [archiver encodeObject:_name];
    [archiver encodeObject:_about];
    [archiver encodeObject:_uuid];
}

#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id)parent
{
    self = [super init];
    if (self) 
    {
        [self doInit] ;
    
        _builder = [decoder builder] ;
//        
//        _sysExpressions = [[SystemExpressions alloc] init];
//        [_builder setSystemTable:[_sysExpressions symbolTable]];

        _sysExpressions = [[SystemExpressions alloc] initWithBuilder:_builder];
    
        _name = [decoder decodeStringForKey:@"name"] ;
        _about = [decoder decodeStringForKey:@"about"] ;
        _sourceItems = [decoder decodeCollectionOfObjectsForKey:@"sources"] ;
        _pages = [decoder decodeCollectionOfObjectsForKey:@"pages"] ;
        if ( [_pages count] > 0 ) _selectedPageIndex = 0 ;
    }
    return self;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [encoder encodeString:_name forKey:@"name"] ;
    [encoder encodeString:_about forKey:@"about"] ;
    [encoder encodeCollectionOfObjects:_sourceItems forKey:@"sources"] ;
    [encoder encodeCollectionOfObjects:_pages forKey:@"pages"] ;
}


#pragma mark - Properties

- (void)setSelectedPageIndex:(NSInteger)selectedPageIndex
{    
    if (selectedPageIndex == _selectedPageIndex)
        return;
    
    if (selectedPageIndex >= _pages.count && selectedPageIndex != NSNotFound) {
        NSLog(@"[olp023] WARNING: Requesting to select page at index %d out of pages array bounds [0..%d]",selectedPageIndex, _pages.count);
        return;
    }
    
    _selectedPageIndex = selectedPageIndex;
    
    for (id <DocumentModelObserver> observer in _observers) {
        if ([observer respondsToSelector:@selector(documentModel:didChangeSelectedPage:)]) {
            [observer documentModel:self didChangeSelectedPage:_selectedPageIndex];
        }
    }
}

- (void)setSelectedPageIndex:(NSInteger)selectedPageIndex registerIntoUndoManager:(BOOL)undo
{
    if (undo) {
        [self.undoManager setActionIsDiscardable:YES];
        [[self.undoManager prepareWithInvocationTarget:self] setSelectedPageIndex:_selectedPageIndex registerIntoUndoManager:YES];
    }
    
    self.selectedPageIndex = selectedPageIndex;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ : %d pages, %d selected page",[super description], _pages.count, _selectedPageIndex];
}

#pragma mark - Main Methods

- (void)addPage:(SWPage*)page
{
    [self insertPage:page atIndex:_pages.count];
}

- (void)insertPage:(SWPage*)page atIndex:(NSInteger)index
{    
    NSAssert(![_pages containsObject:page], @"Intent d'afegir la mateixa pagina!") ;
    NSAssert(index <= _pages.count,@"INSERTED INDEX %d IS OUT OF BOUNDS [0..%d]",index, _pages.count);
    NSAssert(page != nil, @"INSERTED PAGE IS NIL");
    
    [page awakeFromSleepIfNeeded] ;
        
    [_pages insertObject:page atIndex:index];
    
    if (index <= _selectedPageIndex && _selectedPageIndex != NSNotFound)
        _selectedPageIndex++;

    [[_document.undoManager prepareWithInvocationTarget:self] removePageAtIndex:index];
    [_document.undoManager setActionName:@"Add Page"];
    
    for (id<DocumentModelObserver> observer in _observers) {
        if ([observer respondsToSelector:@selector(documentModel:didInsertPageAtIndex:)]) {
            [observer documentModel:self didInsertPageAtIndex:index];
        }
    }
}

- (void)removePageAtIndex:(NSUInteger)index
{    
    NSLog(@"Removing page at index: %d",index);
    NSAssert(index < _pages.count,@"REMOVING PAGE AT INDEX %d IS OUT OF BOUNDS [0..%d]",index, _pages.count);
    
    SWPage *page = [_pages objectAtIndex:index];
    
    // Putin item to sleep
    [page putToSleep] ;

    [[_document.undoManager prepareWithInvocationTarget:self] insertPage:page atIndex:index];
    [_document.undoManager setActionName:@"Remove Page"];
    
    [_pages removeObjectAtIndex:index];
    
    if (index == _selectedPageIndex) {
        if (index >= _pages.count) {
            _selectedPageIndex = NSNotFound;
        }
    } else if (index < _selectedPageIndex && _selectedPageIndex != NSNotFound) {
        _selectedPageIndex = _selectedPageIndex - 1;
    }
        
    for (id<DocumentModelObserver> observer in _observers) {
        if ([observer respondsToSelector:@selector(documentModel:didRemovePageAtIndex:)]) {
            [observer documentModel:self didRemovePageAtIndex:index];
        }
    }
}

- (void)movePageAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    SWPage *page = [_pages objectAtIndex:sourceIndex];
    [_pages removeObjectIdenticalTo:page];
    [_pages insertObject:page atIndex:destinationIndex];
    
    if (_selectedPageIndex == sourceIndex) {
        _selectedPageIndex = destinationIndex;
    } else if (_selectedPageIndex == destinationIndex) {
        if (sourceIndex < destinationIndex) {
            _selectedPageIndex--;
        } else if (sourceIndex > destinationIndex) {
            _selectedPageIndex++;
        }
    } else if (!((_selectedPageIndex <= sourceIndex && _selectedPageIndex <= destinationIndex) ||
                 (_selectedPageIndex >= sourceIndex && _selectedPageIndex >= destinationIndex)) ) {
        if (sourceIndex < destinationIndex) {
            _selectedPageIndex--;
        } else if (sourceIndex > destinationIndex) {
            _selectedPageIndex++;
        }
    }
    
    [[_document.undoManager prepareWithInvocationTarget:self] movePageAtIndex:destinationIndex toIndex:sourceIndex];
    [_document.undoManager setActionName:@"Move Page"];
    
    for (id<DocumentModelObserver> observer in _observers) {
        if ([observer respondsToSelector:@selector(documentModel:didMovePageAtIndex:toIndex:)]) {
            [observer documentModel:self didMovePageAtIndex:sourceIndex toIndex:destinationIndex];
        }
    }
}

- (NSInteger)indexOfPageWithUUID:(NSString*)uuid
{
    for (NSInteger index = 0; index < _pages.count; ++index) {
        SWPage *page = [_pages objectAtIndex:index];
        if ([page.uuid isEqualToString:uuid]) {
            return index;
        }
    }
    
    return NSNotFound;
}

- (void)addObserver:(id<DocumentModelObserver>)observer
{
    if (![_observers containsObject:observer]) {
        [_observers addObject:observer];
    }
}

- (void)removeObserver:(id<DocumentModelObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}

- (void)igniteSources
{
    for ( SWSourceItem *source in _sourceItems )
    {
        if ( source.monitorOn ) [source igniteCommunications];
    }
}


- (void)clausureSources
{
    for ( SWSourceItem *source in _sourceItems )
    {
        [source closeCommunications];
    }
}

#pragma mark - Private Methods

@end 




#pragma mark - SWDocument Class

@interface SWDocument ()
@end

@implementation SWDocument

@synthesize documentState = _documentState;
@synthesize savingType = _savingType;


@synthesize docModel = _docModel;

- (id)initWithFileURL:(NSURL *)url
{    
    self = [super initWithFileURL:url];
    if (self) 
    {
    }
    return self;
}


-(void)dealloc
{
    NSLog( @"SWDocument dealloc" ) ;
}


#pragma mark - Main Methods

+ (void)convertToSymbolicDataDocumentModel:(SWDocumentModel*)documentModel completion:(void (^)(NSData *data))completion
{
//    dispatch_queue_t q_default;
//    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(q_default, ^{
        NSData * data = [self _symbolicDataForDocumentModel:documentModel];
//        
//        dispatch_queue_t q_main = dispatch_get_main_queue();
//        dispatch_async(q_main, ^{
            if (completion) {
                completion(data);
            }
//        });
//    });
}

+ (void)convertToBinaryDataDocumentModel:(SWDocumentModel*)documentModel completion:(void (^)(NSData *data))completion
{
//    dispatch_queue_t q_default;
//    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(q_default, ^{
        NSData * data = [self _binaryDataForDocumentModel:documentModel];
//        
//        dispatch_queue_t q_main = dispatch_get_main_queue();
//        dispatch_async(q_main, ^{
            if (completion) {
                completion(data);
            }
//        });
//    });
}

+ (void)convertToBinarySymbolicData:(NSData*)symbolicData completion:(void (^)(NSData *binaryData))completion
{
//    dispatch_queue_t q_default;
//    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(q_default, 
//    ^{
//        @autoreleasepool
//        {
//        
        SWDocumentModel *documentModel = [self _documentModelForSymbolicData:symbolicData] ;
        NSData *data = [self _binaryDataForDocumentModel:documentModel];
//        
//        dispatch_queue_t q_main = dispatch_get_main_queue();
//        dispatch_async(q_main, 
//        ^{
            if (completion) 
            {
                completion(data);
            }
//        });
//        }
//    });
}

+ (void)convertToSymbolicBinaryData:(NSData*)symbolicData completion:(void (^)(NSData *symbolicData))completion
{
//    dispatch_queue_t q_default;
//    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(q_default, ^{
        SWDocumentModel *documentModel = [self _documentModelForBinaryData:symbolicData];
        NSData * data = [self _symbolicDataForDocumentModel:documentModel];
//        
//        dispatch_queue_t q_main = dispatch_get_main_queue();
//        dispatch_async(q_main, ^{
            if (completion) {
                completion(data);
            }
//        });
//    });
}


#pragma mark - Overriden UIDocument Methods

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{            
    if ([typeName isEqualToString:binaryFileType]) {
        
        _docModel = [SWDocument _documentModelForBinaryData:contents];
        
        if (!_docModel)
            _docModel = [[SWDocumentModel alloc] init];

        _docModel.document = self;
        
    } else {
        NSLog(@"[uj7211] WARNING: Unknown file type: %@",typeName);
    }
    
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"[SWDocument] Saving Document: %@ ofType: %@",self.localizedName, typeName);
    
    NSData *data = [NSData data];
        
    if ([typeName isEqualToString:binaryFileType]) {
        
        data = [SWDocument _binaryDataForDocumentModel:_docModel];
        
    } else {
        NSLog(@"[ldo294] WARNING: Unknown file type: %@",typeName);
    }

    return data;
}

- (NSString*)fileType
{
    return binaryFileType;
}

//
//- (void)disableEditing
//{
//    [super disableEditing];
//    NSLog(@"DOCUMENT SHOULD DISABLE EDITING");
//}
//
//- (void)enableEditing
//{
//    [super enableEditing];
//    NSLog(@"DOCUMENT SHOULD ENABLE EDITING");
//}

#pragma mark - Private Methods

+ (SWDocumentModel*)_documentModelForSymbolicData:(NSData*)data
{
    // TO DO!

    RpnBuilder *builder = [[RpnBuilder alloc] init];
    SymbolicUnarchiver *unarchiver = [[SymbolicUnarchiver alloc] initWithRpnBuilder:builder parentObject:nil];
    
    NSError *error = nil;
    BOOL succeed = [unarchiver prepareForReadingWithData:data outError:&error];
    
    if (!succeed || error != nil) {
        NSLog(@"[8idkd1] Symbolic Unarchiver preparedForReadingWithData succeeded: %@\n%@",STRBOOL(succeed), [error localizedDescription]);
        return nil;
    }
    
    SWDocumentModel *documentModel = [unarchiver decodeObjectForKey:@"document"];
    
    NSError *finalError = nil;
    [unarchiver finishDecodingOutError:&finalError];
    
    if (finalError != nil) {
        NSLog(@"[111234] Symbolic Unarchiver finishDecodingOutError: %@", [finalError localizedDescription]);
        return nil;
    }
    
    // TODO : Què es fa amb el BUIDLER? Se li ha d'assignar al documentModel?
    
    return documentModel;

    return nil;
}

+ (SWDocumentModel*)_documentModelForBinaryData:(NSData*)data
{
    QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:data];

    NSInteger docVersion = [unarchiver version];
    
    SWDocumentModel *documentModel = nil;
    
    if (docVersion == CURRENT_MODEL_VERSION) {
        documentModel = [unarchiver decodeObject];        
    }
    
    return documentModel;
}

+ (NSData*)_symbolicDataForDocumentModel:(SWDocumentModel*)documentModel
{
    NSMutableData *data = [NSMutableData data];
    int version = (documentModel == nil) ? -1 : CURRENT_MODEL_VERSION;
    
    // TODO!!!
    
    SymbolicArchiver *archiver = [[SymbolicArchiver alloc] initForWritingWithMutableData:data version:version];     
    
    [archiver encodeObject:documentModel forKey:@"document"];
    
    [archiver finishEncoding];
    
    return [data copy];
}

+ (NSData*)_binaryDataForDocumentModel:(SWDocumentModel*)documentModel
{
    NSMutableData *data = [NSMutableData data];
    int version = (documentModel == nil) ? -1 : CURRENT_MODEL_VERSION;
            
    QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:data version:version];
        
    [archiver encodeObject:documentModel];
    [archiver finishEncoding];
    
    return [data copy];
}

@end
