//
//  SWSourceItem.m
//  HmiPad
//
//  Created by Joan on 14/03/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWSourceItem.h"
#import "SWDocumentModel.h"
#import "UserDefaults.h"

#import "SWExpression.h"
#import "SWPlcDevice.h"
#import "SWPlcTag.h"
#import "SWSourceNode.h"
#import "SWReadExpression.h"

//#import "SWEventCenter.h"
//#import "SWEvent.h"
//#import "SWHistoAlarms.h"

#import "PlcCommsObject.h"
#import "CommsObjectDelegate.h"

#import "SWPropertyDescriptor.h"

#import "SWColor.h"
#import "PrimitiveParser.h"
#import "Pair.h"

// Uncomment to cause logs
// #define SOURCE_ITEM_LOGS

#ifdef SOURCE_ITEM_LOGS
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif 

NSString *kFinsMonitorDidChangeNotification = @"FinsMonitorDidChangeNotification"; 
NSString *kFinsWillConnectNotification = @"FinsWillConnectNotification"; 
NSString *kFinsDidLinkNotification = @"FinsDidLinkNotification";
NSString *kFinsErrorOccurredNotification = @"FinsErrorOccurredNotification";
NSString *kFinsWarningNotification = @"FinsWarningNotification";
NSString *kFinsDidCloseNotification = @"FinsDidCloseNotification"; 
NSString *kFinsDidClausureNotification = @"FinsDidClausureNotification";
NSString *kFinsStateDidChangeNotification = @"FinsStateDidChangeNotification";
NSString *kFinsPollUpdateNotification = @"FinsPollUpdateNotification";
NSString *kFinsNumberOfTagsDidChangeNotification = @"FinsNumberOfTagsDidChangeNotification";

static NSString *PollContext = @"PollCtx";

@interface SWSourceItem()<CommsObjectDelegate>
@end

@implementation SWSourceItem

@synthesize plcDevice = _plcDevice;
@synthesize plcObject = _plcObject;
@synthesize error = _error;
@synthesize monitorOn  = _monitorOn;
@synthesize altHost  = _altHost;
@synthesize plcObjectIgnited  = _plcObjectIgnited;
@synthesize plcObjectStarted = _plcObjectStarted;
@synthesize plcObjectLinked = _plcObjectLinked;
@synthesize plcObjectRoute = _plcObjectRoute;
@synthesize numberOfTags = _numberOfTags;
@synthesize commandsPerSecond = _commandsPerSecond;
@synthesize readsPerSecond = _readsPerSecond;

@dynamic protocol;
@dynamic pollInterval;
@dynamic decorationType;
@dynamic statusDescription;
@dynamic statusColor;

#pragma mark - Class stuff


static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"source";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"PLC CONNECTOR", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
       
        [SWPropertyDescriptor propertyDescriptorWithName:@"localIP" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"remoteHost" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
//        [SWPropertyDescriptor propertyDescriptorWithName:@"localPort" type:SWTypeInteger
//            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]],
//            
//        [SWPropertyDescriptor propertyDescriptorWithName:@"remotePort" type:SWTypeInteger
//            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]],
            
        nil];
}


//static SWPropertyDescriptor *_localIPExpressionDescriptor = nil;
//static SWPropertyDescriptor *_remoteHostExpressionDescriptor = nil;
//
//+ (void)initialize
//{
//    _localIPExpressionDescriptor = [SWPropertyDescriptor propertyDescriptorWithName:@"localIP" type:SWTypeAny
//        propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]];
//    
//    _remoteHostExpressionDescriptor = [SWPropertyDescriptor propertyDescriptorWithName:@"remoteHost" type:SWTypeAny
//        propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]];
//}


#pragma mark - instance property descriptions

- (NSArray*)propertyDescriptions
{    
    NSMutableArray *propertyDescriptions = [NSMutableArray array];
    
    for ( SWSourceNode *node in _sourceNodes )
    {
        SWPropertyDescriptor *descriptor = [SWPropertyDescriptor propertyDescriptorWithName:node.name
        type:SWTypeAny propertyType:SWPropertyTypeNoEditableValue defaultValue:nil];
        
        [propertyDescriptions addObject:descriptor];
    }
    
    return propertyDescriptions;
}


- (SWExpression*)localIPExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)remoteHostExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}


//- (SWPropertyDescriptor*)valueDescriptionForValue:(SWValue *)value
//{
//    if ( value == _localIPExpression )
//        return _localIPExpressionDescriptor; // description
//    
//    else if ( value == _remoteHostExpression )
//        return _remoteHostExpressionDescriptor;
//        
//    return [super valueDescriptionForValue:value];
//}



#pragma mark - Inits

//- (id)initInDocument:(SWDocumentModel*)docModel
- (id)initInDocument:(SWDocumentModel*)docModel protocolString:(NSString*)protocolString;
{
    self = [super initInDocument:docModel];
    if (self) 
    {
        _plcDevice = [[SWPlcDevice alloc] init];
        [_plcDevice setProtocolAsString:protocolString];
        //_plcDevice.sourceItem = self;
        _sourceNodes = [NSMutableArray array];
        _sourceNodesDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    NSLog1( @"SourceItem:%08x dealloc", (int)self ) ;
    
    [_plcObject setDelegate:nil];    // 8-05-2013
}

- (void)putToSleep
{
    if ( !_asleep )
    {
        for ( SWSourceNode *node in _sourceNodes )
        {
            SWExpression *readExp = node.readExpression;
            SWExpression *writeExp = node.writeExpression;
            
            [readExp evalWithDisconnectedSource];
            [readExp disablePromotions];
            
            [writeExp disablePromotions];
            //[node.writeExpression evalWithDisconnectedSource];
            // faltaria treure els simbols del diccionari pero igualment no podem canviarlos per un source item adormit
        }
    }
    [super putToSleep];
}

- (void)awakeFromSleepIfNeeded
{
    if ( _asleep )
    {
        for ( SWSourceNode *node in _sourceNodes )
        {
            [node.readExpression enablePromotions];
            [node.readExpression evalWithForcedState:ExpressionStateBadQualitySource];
            
            [node.writeExpression enablePromotions];
            //[node.writeExpression evalWithForcedState:ExpressionStateBadQualitySource];
            
            // faltaria afegir els simbols pero com que no els hem tret...
        }
    }
    [super awakeFromSleepIfNeeded];
}

#pragma mark - Overriden Methods

- (BOOL)matchesSearchWithString:(NSString*)searchString
{
    BOOL validSearch = NO;
    
    if ([_plcDevice->remoteHost length] > 0)
    {
        NSComparisonResult result = [_plcDevice->remoteHost compare:searchString
                                          options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                            range:NSMakeRange(0, [searchString length])];
        
        validSearch = validSearch || (result == NSOrderedSame);
    }
    
    if ([_plcDevice->localHost length] > 0)
    {
        NSComparisonResult result = [_plcDevice->localHost compare:searchString
                                                           options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                             range:NSMakeRange(0, [searchString length])];
        
        validSearch = validSearch || (result == NSOrderedSame);
    }
    
    return validSearch || [super matchesSearchWithString:searchString];
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        _plcDevice = [decoder decodeObject];
        _plcDevice->validationCode = [decoder decodeInt];
        _monitorOn = [decoder decodeInt];
        _sourceNodes = [decoder decodeObject];
        _sourceNodesDic = [decoder decodeObject];
        [self _invalidateAfterDecode];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    [encoder encodeObject:_plcDevice];
    [encoder encodeInt:_plcDevice->validationCode];   // ATENCIO TO DO aquest no sembla el millor lloc per la persistencia
    [encoder encodeInt:_monitorOn];                   // ATENCIO TO DO aquest no sembla el millor lloc per la persistencia
    [encoder encodeObject:_sourceNodes];
    [encoder encodeObject:_sourceNodesDic];
}

- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    _monitorOn = [decoder decodeInt];
    _altHost = [decoder decodeInt];
}

- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeInt:_monitorOn];
    [encoder encodeInt:_altHost];
}


- (void)_invalidateAfterDecode
{
    // dispatchem el invalidate per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if ( !_monitorOn )
            [self _invalidateTagSet];
    }) ;
}


#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        _plcDevice = [decoder decodeObjectForKey:@"device"];
        
        
        // former HMI Pad version test (<=2.0)
        BOOL gotSourceFromDevice = /*_plcDevice->localPort != 0 || _plcDevice->remotePort != 0 || */
            _plcDevice->localHost != nil || _plcDevice->remoteHost != nil ;
        
        
        SWExpression *localIpExp = self.localIPExpression;
        SWExpression *remoteHostExp = self.remoteHostExpression;
        
        if ( gotSourceFromDevice )
        {
            NSString *localHostExt = [_plcDevice localHostExtAsString];
            [localIpExp evalWithStringConstant:(__bridge CFStringRef)(localHostExt)];
            
            NSString *remoteHostExt = [_plcDevice remoteHostExtAsString];
            [remoteHostExp evalWithStringConstant:(__bridge CFStringRef)(remoteHostExt)];
        }
        else
        {
            [_plcDevice setLocalHostExtAsString:[localIpExp valueAsString]];
            [_plcDevice setRemoteHostExtAsString:[remoteHostExp valueAsString]];
        }
            
        
        _sourceNodes = [decoder decodeCollectionOfObjectsForKey:@"tags"];
        _sourceNodesDic = [[NSMutableDictionary alloc] init];
        
        for ( SWSourceNode *node in _sourceNodes )
        {
            NSString *nodeName = node.name;
            NSString *newName = [self _getNameFromName:nodeName];
            if ( ![newName isEqualToString:nodeName] )
            {
                NSString *formatStr = NSLocalizedString(@"Duplicated Tag Name: '%@.%@'", nil);
                NSString *errorStr = [NSString stringWithFormat:formatStr, ident, nodeName];
                [decoder setErrorWithString:errorStr];
            }
            node.name = newName;
            [_sourceNodesDic setObject:node forKey:newName];
        }
        
        //int vaCode = [decoder decodeIntForKey:@"id"];
        
        UInt16 code = [SWPlcDevice encriptCode:0];
        NSString *vaCode = [decoder decodeStringForKey:@"id"];
        if ( vaCode ) code = [vaCode intValue];
        
        if ( _plcDevice ) _plcDevice->validationCode = code;
        
        [self _invalidateAfterDecode];
    }
    return self;
}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [super encodeWithSymbolicCoder:encoder];
    
    [encoder encodeObject:_plcDevice forKey:@"device"];
    [encoder encodeCollectionOfObjects:_sourceNodes forKey:@"tags"];
    
    NSString *vaCode = [NSString stringWithFormat:@"%d", _plcDevice->validationCode];
    [encoder encodeString:vaCode forKey:@"id"];
}


- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent
{
    _monitorOn = [decoder decodeIntForKey:@"monitor"];
    _altHost = [decoder decodeIntForKey:@"altHost"];
}

- (void)storeWithSymbolicCoder:(SymbolicArchiver*)encoder
{
    [encoder encodeInt:_monitorOn forKey:@"monitor"];
    [encoder encodeInt:_altHost forKey:@"altHost"];
}

#pragma mark - Dynamic properties

- (ProtocolType)protocol
{
    return _plcDevice->plcProtocol;
}

- (ItemDecorationType)decorationType
{
    //SWSourceItem *sourceItem = self;
        
    ItemDecorationType decorationStyle = ItemDecorationTypeNone;
    
    if ( _monitorOn ) 
    {
        NSError *error = [self error];
        if (error) 
        {
            decorationStyle = ItemDecorationTypeRed;
        } 
        else 
        {
            if (_plcObjectStarted) 
            {
                if (_plcObjectLinked) 
                    decorationStyle = ItemDecorationTypeGreen;
                else
                    decorationStyle = ItemDecorationTypeGrayActivityIndicator;
            }
            else if (_plcObjectIgnited) 
            {
                decorationStyle = ItemDecorationTypeGrayActivityIndicator;
            } 
            else 
            {
                decorationStyle = ItemDecorationTypeNone;
            }
        }
    } 
    else 
    {
        decorationStyle = ItemDecorationTypeGray;
    }
    
    return decorationStyle;
}

//- (ItemDecorationType)decorationTypeV
//{
//    //SWSourceItem *sourceItem = self;
//        
//    ItemDecorationType decorationStyle = ItemDecorationTypeNone;
//    
//    if ( _monitorOn ) 
//    {
//        NSError *error = [self error];
//        if (error) 
//        {
//            decorationStyle = ItemDecorationTypeAlert;
//        } 
//        else 
//        {
//            if (_plcObjectStarted) 
//            {
//                if (_plcObjectLinked) 
//                    decorationStyle = ItemDecorationTypeGreen;
//                else
//                    decorationStyle = ItemDecorationTypeWhiteActivityIndicator;
//            }
//            else if (_plcObjectIgnited) 
//            {
//                decorationStyle = ItemDecorationTypeWhiteActivityIndicator;
//            } 
//            else 
//            {
//                decorationStyle = ItemDecorationTypeNone;
//            }
//        }
//    } 
//    else 
//    {
//        decorationStyle = ItemDecorationTypeRed;
//    }
//    
//    return decorationStyle;
//}


- (NSString*)statusDescription
{    
    NSString *fullMessage;
    NSString *prefixStr = @"";
    NSString *textStr = @"";
    
    if ( _monitorOn ) 
    {
        NSError *error = [self error];
        if ( error ) 
        {            
            prefixStr = [error localizedDescription];
        } 
        else 
        {
            if ( _plcObjectStarted )
            {
//                if ( _plcObjectLinked )
//                    textStr = [NSString stringWithFormat:NSLocalizedString(@"Connected to %@",nil), [self _plcObjectConnectedString]];
//                else 
//                    textStr = [NSString stringWithFormat:NSLocalizedString(@"Trying %@ ...",nil), [self _plcObjectConnectingString]];
                
                if ( _plcObjectLinked )
                    textStr = [self _plcObjectConnectedString];
                else 
                    textStr = [self _plcObjectConnectingString];
            } 
            else if ( _plcObjectIgnited ) 
            {
                textStr = NSLocalizedString(@"Waiting for connection...",nil);
            } 
            else 
            {
                textStr = NSLocalizedString(@"Disconnected",nil);
            }
        }
    } 
    else 
    {
        textStr = NSLocalizedString(@"Stopped",nil); 
    }
    
    fullMessage = [NSString stringWithFormat:@"%@%@", prefixStr, textStr];
    
    return fullMessage;
}

- (UIColor*)statusColor
{
    SWSourceItem *sourceItem = self;
    
    UIColor *color = nil;
    
    if ( sourceItem.monitorOn )
    {
        NSError *error = [sourceItem error];
        if ( error )
        {
            color = [UIColor colorWithRed:0.75f green:0.0f blue:0.0f alpha:1.0f];  // almost red
        }
        else
        {
            //color = UIColorWithRgb(TextDefaultColor);
            //color = [UIColor lightGrayColor];
            color = IS_IOS7 ? [UIColor blackColor] : [UIColor whiteColor];
            
        }
    }
    else
    {
        //color = UIColorWithRgb(TextDefaultColor);
        //color = [UIColor lightGrayColor];
        color = IS_IOS7 ? [UIColor blackColor] : [UIColor whiteColor];
    }
    
    return color;
}


// torna el interval de poll expressat en segons (float)
- (float)pollInterval
{
    UInt16 pollRate = _plcDevice->pollRate;
    if ( pollRate == 0xffff ) pollRate = 2000;
    return pollRate/1000.0f;
}


//- (NSString*)plcObjectConnectedString
//{
//    NSString *str = nil;
//    if ( _plcObject && _plcObjectLinked )
//    {
//        str = [_plcObject connectedHost];
//    }
//    return str;
//}
//
//- (NSString*)plcObjectConnectingString
//{
//    NSString *str = [_plcObject connectingHost];
//    return str;
//}


- (NSString*)_plcObjectConnectedString
{
    NSString *str = nil;
    if ( _plcObject && _plcObjectLinked )
    {
        if ( HMiPadDev )
            str = [NSString stringWithFormat:NSLocalizedString(@"Connected to %@",nil), [_plcObject connectedHost]];
        else
            str = NSLocalizedString( @"Connected", nil );
    }
    return str;
}


- (NSString*)_plcObjectConnectingString
{
    NSString *str = nil;
    if ( HMiPadDev )
        str = [NSString stringWithFormat:NSLocalizedString(@"Trying %@ ...",nil), [_plcObject connectingHost]];
    else
        str = NSLocalizedString( @"Trying connection", nil );

    return str;
}


#pragma mark - Private Methods (plcObject reading tags)

// actualitzacio despres de lectura
- (void)_updateTag:(PlcTagElement *)plcTag
{
    SWSourceNode *node = [plcTag item];
    
    if ( node )
    {
        UInt8 errN = [plcTag errNum];
        node.tagErrNum = errN;
        node.timeStamp = [plcTag timeStamp];
        //[node setPolling:YES];
        SWExpression *readExpr = node.readExpression;
        
        if ( errN > 0 )
        {
            //[readExpr invalidatee];
            [readExpr evalWithForcedState:ExpressionStateBadQualitySource];
        }
        else
        {
            int collectionCount = [plcTag collectionCount];
            if ( [plcTag isNumeric] )
            {
                if ( collectionCount == 1 )
                {
                    double engValue = [plcTag engValueAtIndex:0];
                    
                    NSLog1( @"Node Read Tag, Name:%@ Value:%g", node.name, engValue );
                    [readExpr evalWithConstantValue:engValue];
                }
                else
                {
                    CFDataRef dataValues = [plcTag engValuesDataCreate];
                    [readExpr evalWithConstantValuesFromData:dataValues];
                    if ( dataValues ) CFRelease( dataValues );
                }
            }
            else if ( [plcTag isString] )
            {
                CFStringEncoding stringEncoding = _plcDevice->stringEncoding;
                if ( collectionCount == 1 )
                {
                    CFStringRef string = [plcTag engStringAtIndexCreate:0 encoding:stringEncoding];
                    [readExpr evalWithStringConstant:string];
                    if ( string ) CFRelease( string );
                }
                else
                {
                    CFArrayRef strArray = [plcTag engStringsArrayCreateWithEncoding:stringEncoding];
                    [readExpr evalWithStringConstantsFromCFArray:strArray];
                    if ( strArray ) CFRelease( strArray );
                }
            }
        }
    }
}




//------------------------------------------------------------------------------------
- (void)_tagsSetCommitRead
{
    [[self _commsObject] restoreMonitoredTagElementsByAdding:_addTagsArray removing:_removeTagsArray contextObj:PollContext];
    NSLog1( @"_tagsSetCommitRead PlcObject: %@", _plcObject );
    _addTagsArray = nil;
    _removeTagsArray = nil;
}


//------------------------------------------------------------------------------------
- (void)_tagSetPrepareCommit
{
    if ( _pendingCommitTagsSet == NO && (_removeTagsArray || _addTagsArray) )
    {
        _pendingCommitTagsSet = YES;
        dispatch_async(dispatch_get_main_queue(), 
        ^{
            @autoreleasepool 
            { 
                [self _tagsSetCommitRead];
                _pendingCommitTagsSet = NO;
            }
        });
    }
}

//----------------------------------------------------------------------------------------
- (void)_tagsSetAddTag:(SWPlcTag *)plcTag
{
    if ( _addTagsArray == nil ) _addTagsArray = [[NSMutableArray alloc] init];
    
    [_addTagsArray addObject:plcTag];
    [self _tagSetPrepareCommit];
}


//----------------------------------------------------------------------------------------
- (void)_tagsSetRemoveTag:(SWPlcTag *)plcTag
{
    if ( _removeTagsArray == nil ) _removeTagsArray = [[NSMutableArray alloc] init];
    
    [_removeTagsArray addObject:plcTag];
    [self _tagSetPrepareCommit];
}

////----------------------------------------------------------------------------------------
//- (void)_tagsSetRemoveAll
//{
//    _addTagsArray = nil;
//    _removeTagsArray = nil;
//    [_plcObject removeAllMonitoredTagElements];
//}
//
////----------------------------------------------------------------------------------------
//- (void)_tagsSetSetAll
//{
//    [self _tagsSetRemoveAll];
//    for ( SWSourceNode *node in _sourceNodes )
//    {
//        [self _tagsSetAddTag:node.plcTag];
//    }
//}


////----------------------------------------------------------------------------------------
//- (void)_tagsSetRemoveAll
//{
//    for ( SWSourceNode *node in _sourceNodes )
//    {
//        [node commRelease];
//    }
//}
//
////----------------------------------------------------------------------------------------
//- (void)_tagsSetSetAll
//{
//    [self _tagsSetRemoveAll];
//    for ( SWSourceNode *node in _sourceNodes )
//    {
//        [node commRetain];
//    }
//}

//----------------------------------------------------------------------------------------
// invalidacio degut a desconexio o error global de comunicacio
- (void)_invalidateTagSet
{    
    for ( SWSourceNode *node in _sourceNodes )
    {
        SWExpression *readExp = node.readExpression;
//        if ( readExp.observerCount > 0 )
//        {
//            NSLog( @"invalidating tag set:%@", readExp.fullReference ) ;
//        }
        [readExp evalWithForcedState:ExpressionStateDisconnectedSource];
    }
}


#pragma mark - Private Methods (plcObject writting tags)

// actualitzacio despres de escritura
- (void)_updateWTag:(PlcTagElement *)plcTag
{
    SWSourceNode *node = [plcTag item];
    if ( node )
    {
        UInt8 errN = [plcTag errNum];  // es conceptualment incorrecte pero suposem que no causa mai cap problema
                                        // perque el plcObject nomes ho pot matxacar en la seguent lectura que requereix
                                        // un cicle de enviament de comanda i recepcio de resposta
        if ( errN > 0 )
        {
            //SWEventCenter *eventCenter = _docModel.eventCenter;
            NSString *comment = [plcTag infoStringForErrNum:errN];
            NSString *label = NSLocalizedString(@"TAG WRITE", nil);
            //[eventCenter eventsAddSystemEventWithLabel:label comment:comment];
            
//            SWEvent *event = [[SWEvent alloc] initWithLabel:label comment:comment active:NO];
//            [_docModel.eventCenter eventsAddSystemEvent:event];
//            [_docModel.histoAlarms addEvent:event];
            
            [_docModel addSystemEventWithLabel:label comment:comment];
        }
    }
}


//----------------------------------------------------------------------------------------
- (void)_wTagsSetCommitWrite
{
    if ( _wTagsArray )
    {
        [_plcObject writeTagElementsInArray:_wTagsArray contextObj:nil];
        _wTagsArray = nil;
    }
}

//------------------------------------------------------------------------------------
- (void)_wTagSetPrepareCommit
{
    if ( _wPendingCommitTagsSet == NO && _wTagsArray )
    {
        _wPendingCommitTagsSet = YES;
        dispatch_async(dispatch_get_main_queue(),
        ^{
            @autoreleasepool 
            {
                [self _wTagsSetCommitWrite];
                _wPendingCommitTagsSet = NO;
            }
        });
    
    }
}


//----------------------------------------------------------------------------------------
- (void)_wTagsSetAddTag:(SWPlcTag *)plcTag values:(CFDataRef)values texts:(CFArrayRef)texts
{
    BOOL plcOn = _plcObject && _plcObjectLinked;  
    NSAssert( values || texts, @"values o texts no pot ser NULL");
    
    if ( plcOn )
    {
        if ( values )
        {
            int count = CFDataGetLength(values)/sizeof(double);
            [_plcObject setEngWValues:values maxCount:count forTagElement:plcTag];
        }
        else if ( texts )
        {
            int count = CFArrayGetCount(texts);
            [_plcObject setEngWStrings:texts encoding:_plcDevice->stringEncoding maxCount:count forTagElement:plcTag];
        }
        
        if ( _wTagsArray == nil ) _wTagsArray = [[NSMutableArray alloc] init];
        [_wTagsArray addObject:plcTag];
        [self _wTagSetPrepareCommit];
    }
}



#pragma mark - Private Methods (plcObject communications)

// Obra per comunicació un objecteOmron ja inicialitzat. Torna NO si hi ha error.
- (BOOL)_openCommsObject:(PlcCommsObject *)commsObj
{
    ProtocolType protocol = [_plcDevice plcProtocol];
    
    
    // TODO agafar el validation code del model/defauls
    /*
    plcDevice->validationCode = [model() validationCodeForPlcDevice:plcDevice];
    */
    
    _plcDevice->altIsFirst = _altHost;
    
    BOOL done = NO;
    if ( protocol != kProtocolTypeNone )
    {
        [_plcDevice normalize];
        done = [commsObj openWithPlcDevice:_plcDevice contextObj:nil];
    }

    return done;
}


// inicialitzem un nou objecte de comunicacions si no el tenim
 - (PlcCommsObject *)_commsObject
{
    if ( _plcObject == nil ) 
    {
        _plcObject = [[PlcCommsObject alloc] init];
        [_plcObject setDelegate:self];
        //[self _tagsSetSetAll];
    }
    return _plcObject;
}


- (void)_plcDeviceChangeNotify
{
    NSArray *observersCopy = [_observers copy];
    for (id<SourceItemObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(plcDeviceDidChange:)])
            [observer plcDeviceDidChange:_plcDevice];
    }
}

// setError
- (void)_setError:(NSError*)anError
{
    if ( anError != _error )
    {
        _error = anError;
        _errorTimeStamp = CFAbsoluteTimeGetCurrent();
        
        // TODO generar o resetejar alarma de desconexio si esta habilitada
        
        if ( anError && [defaults() disconnectAlertState] )
        {
            //SWEventCenter *eventCenter = _docModel.eventCenter;
            NSString *comment = anError.localizedDescription;
            NSString *label = NSLocalizedString(@"COMMS", nil);
            //[_docModel.eventCenter eventsAddSystemEventWithLabel:label comment:comment];  x
            
//            SWEvent *event = [[SWEvent alloc] initWithLabel:label comment:comment active:NO];
//            [_docModel.eventCenter eventsAddSystemEvent:event];
//            [_docModel.histoAlarms addEvent:event];
            
            [_docModel addSystemEventWithLabel:label comment:comment];
        }
        
    }
}

#pragma mark - plcObject methods


- (void)_primitiveSetPlcDevice:(SWPlcDevice*)device
{
    BOOL wasIgnited = _plcObjectIgnited;

    if ( wasIgnited )
        [self closeCommunications];
    
    [device normalize];
    _plcDevice = device;
    
    [self _plcDeviceChangeNotify];
    
    if ( wasIgnited )   // <- nomes volem ignite si ja ho estava
        [self igniteCommunications];
}


- (void)setPlcDevice:(SWPlcDevice*)device
{
    SWPlcDevice *currentPlcDevice = _plcDevice;
    
    [self _primitiveSetPlcDevice:device];
    
    NSUndoManager *undoManager = _docModel.undoManager;
    [[undoManager prepareWithInvocationTarget:self] setPlcDevice:currentPlcDevice];
    [undoManager setActionName:NSLocalizedString(@"Change Source Settings", nil)];
}


- (void)setPollRate:(UInt16)rate
{
    UInt16 currentPollRate = _plcDevice->pollRate;

    [_plcDevice setPollRate:rate]; // <-- Aquest mètode provoca la crida als observadors
    [_plcObject setPollInterval:(CFTimeInterval)rate/1000];
    
    [self _plcDeviceChangeNotify];
    
    NSUndoManager *undoManager = _docModel.undoManager;
    [[undoManager prepareWithInvocationTarget:self] setPollRate:currentPollRate];
    [undoManager setActionName:NSLocalizedString(@"Change Poll Rate", nil)];
}


// arranca les comunicacions, la primera vegada creem un objecte de comunicacions
- (void)igniteCommunications
{
   // _monitorOn = YES;
    if ( _monitorOn == NO ) return;   // nomes permetem estar ignited si monitorOn es YES
    if ( _plcObjectIgnited ) return;

    // si no estava iniciat el creem i ja comecara el polling a didLink    
    if ( [self _openCommsObject:[self _commsObject]] ) 
    {
        _plcObjectIgnited = YES;
    }

//    [self _openCommsObject:[self _commsObject]];
//    _plcObjectIgnited = YES;
}

- (void)closeCommunications
{
    if ( _plcObjectIgnited )
    {
        [_plcObject close];
        _plcObjectIgnited = NO;
    }
    /*
    else 
    {
        [self finsDidClausure:_plcObject];
    }
    */
}

- (void)setMonitorState:(BOOL)value
{
    if ( _monitorOn != value )
    {
        _monitorOn = value;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinsMonitorDidChangeNotification object:self];
        [self _prepareStateDidChangeNotification];
    }

    if ( _monitorOn ) [self igniteCommunications];
    else [self closeCommunications];
}

#pragma mark - Private methods (sourceNodes)

//- (NSString *)_getNameFromName:(NSString*)newSymbol //outError:(NSError**)outError
//{
//    if (newSymbol == nil)
//        return nil;
//    
//    /*
//    char buff[81];
//    char *ch = buff;
//    
//    // en principi tornara NO si no es ascii, o no NULL si es ascii
//    BOOL valid = [newSymbol getCString:buff maxLength:sizeof(buff) encoding:NSASCIIStringEncoding];
//        
//    if ( valid && *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) 
//        || (*ch >= 'A' && *ch <='Z') || ( *ch == '_' ) ) )
//    {
//        ch++;
//        while ( *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) ||
//                (*ch >= 'A' && *ch <='Z') || (*ch >= '0' && *ch <= '9' ) || ( *ch == '_' )  ) ) ch++;
//    }
//    else valid = NO;
//        
//    if ( !valid || *ch != '\0' )
//    {
//        if ( outError )
//        {
//            NSString *errMsg = [[NSString alloc] initWithFormat:NSLocalizedString(@"InvalidName%@", nil), newSymbol];
//            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//            *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
//        }
//        return nil;
//    }
//    */
//     
//    int iter = 1;
//    NSString *tryString = newSymbol;
//    while ( [_sourceNodesDic objectForKey:tryString] != nil )
//    {
//        tryString = [NSString stringWithFormat:@"%@_%d", newSymbol, iter++];
//    }
//    return tryString;
//}
//



- (NSString *)_getNameFromName:(NSString*)newSymbol //outError:(NSError**)outError
{
    if (newSymbol == nil)
        return nil;
    
    if ( [_sourceNodesDic objectForKey:newSymbol] == nil )
        return newSymbol;
    
    int length = newSymbol.length;
    int position = length-1;
    int suffix = 0;
    for ( ; position>=0 ; position-- )
    {
        unichar ch = [newSymbol characterAtIndex:position];
        if ( ch >= '0' && ch <= '9' )
            suffix = suffix*10 + (ch -'0');
            
        else break;
    }
        
    if ( length > position+1 )
        newSymbol = [newSymbol substringToIndex:position+1];
    
    NSString *tryString = nil;
    while ( YES )
    {
        suffix += 1;
        tryString = [NSString stringWithFormat:@"%@%d", newSymbol, suffix];
        if ( [_sourceNodesDic objectForKey:tryString] == nil )
            break;
        
        //suffix += 1;
    }
    
    return tryString;
}


- (BOOL)_setPlcTag:(PlcTagElement*)plcTag tagName:(NSString*)tagName 
            type:(NSString*)varType count:(int)count outError:(NSError **)outError
{
    plcTag->varType = kFloatVarType;
    plcTag->area = kAreaCodeDM;
    [plcTag setAddr:4 withBit:0];
    return YES;
}

#pragma mark - SourceNode methods

- (NSArray *)sourceNodes
{
    return _sourceNodes;
}

- (void)moveNodeAtIndex:(NSInteger)originIndex toIndex:(NSInteger)finalIndex
{
    SWSourceNode *originNode = [_sourceNodes objectAtIndex:originIndex];

    [_sourceNodes removeObjectAtIndex:originIndex];
    [_sourceNodes insertObject:originNode atIndex:finalIndex];
        
    NSUndoManager *undoManager = [_docModel undoManager];
    [[undoManager prepareWithInvocationTarget:self] moveNodeAtIndex:finalIndex toIndex:originIndex];
    [undoManager setActionName:NSLocalizedString(@"Move Tag", nil)];
    
    NSArray *observers = [_observers copy];
    for (id<SourceItemObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(sourceItem:didMoveSourceNodeAtIndex:toIndex:)])
            [observer sourceItem:self didMoveSourceNodeAtIndex:originIndex toIndex:finalIndex];
    }
}

- (SWPlcTag*)plcTagCopyAtIndex:(NSInteger)indx
{
    SWSourceNode *node = [_sourceNodes objectAtIndex:indx];
    
    SWPlcTag *newTag = [node.plcTag newTag];
    //[newTag setItem:node];                           // BUGGY, treure d'aqui

    return newTag;
}

- (BOOL)insertNewVariablesAtIndexes:(NSIndexSet*)indexes
{
    NSString *varName = @"var";
    
    ProtocolType protocol = [_plcDevice plcProtocol];
    
    __block BOOL succeed = YES;
    
    NSMutableArray *sourceNodes = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        SWPlcTag *plcTag = [[SWPlcTag alloc] initAsDefaultForProtocol:protocol];
        if (plcTag == nil)
        {
            succeed = NO;
            return;
        }
        
        //SWPlcTag *plcTag = [[SWPlcTag alloc] init];
        //BOOL tagResult = [self _setPlcTag:plcTag tagName:tagName type:varType count:tagCount outError:NULL];
        //if ( tagResult == NO ) return;
        
        SWSourceNode *node = [[SWSourceNode alloc] initWithSourceItem:self];
        node.name = varName;
        
        [node setPlcTag:plcTag];
        //[plcTag setItem:node];
        
        SWReadExpression *readExp = [[SWReadExpression alloc] initWithDouble:0];
        [readExp setHolder:self];  // per reads el holder es self
        [node setReadExpression:readExp];
        
        SWExpression *writeExp = [[SWExpression alloc] initWithDouble:0];
        [writeExp setHolder:node];   // per writes el holder es el node
        node.writeExpression = writeExp;
        
        [sourceNodes addObject:node];
    }];
    
    if ( succeed )
        [self insertSourceNodes:sourceNodes atIndexes:indexes];
    
    return succeed;
}

- (void)insertSourceNodes:(NSArray*)nodes atIndexes:(NSIndexSet*)indexes
{
    if (indexes == nil)
    {
        NSInteger count = nodes.count;
        NSInteger size = _sourceNodes.count;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSInteger i=0; i<count; ++i)
            [indexSet addIndex:size+i];
        
        indexes = [indexSet copy];
    }

    [_sourceNodes insertObjects:nodes atIndexes:indexes];
    
    for (SWSourceNode *node in nodes)
    {
        NSString *newName = [self _getNameFromName:node.name];
        node.name = newName;
        
        [_sourceNodesDic setObject:node forKey:newName];
        
        SWReadExpression *readExpr = node.readExpression;
        if (readExpr.observerCount > 0)
        {
            SWPlcTag *plcTag = node.plcTag;
            [self _tagsSetAddTag:plcTag];
        }
        
        [node.readExpression enablePromotions];  // expressions become alive
        [node.readExpression evalWithForcedState:ExpressionStateBadQualitySource];
        
        [node.writeExpression enablePromotions];
        //[node.writeExpression evalWithForcedState:ExpressionStateBadQualitySource];  // AQUI
    }

    NSUndoManager *undoManager = [_docModel undoManager];
    [[undoManager prepareWithInvocationTarget:self] removeVariablesAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Insert Tag", nil)];
    
    NSArray *observers = [_observers copy];
    for (id<SourceItemObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(sourceItem:didInsertSourceNodesAtIndexes:)])
            [observer sourceItem:self didInsertSourceNodesAtIndexes:indexes];
    }
}

- (void)removeVariablesAtIndexes:(NSIndexSet*)indexes
{
    NSArray *sourceNodes = [_sourceNodes objectsAtIndexes:indexes];
    
    for (id<SourceItemObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(sourceItem:willRemoveSourceNodesAtIndexes:)])
            [observer sourceItem:self willRemoveSourceNodesAtIndexes:indexes];
    }
    
    for (SWSourceNode *node in sourceNodes)
    {
        SWExpression *readExpr = node.readExpression;
        SWExpression *writeExpr = node.writeExpression;
        
        if (readExpr.observerCount > 0)
        {
            SWPlcTag *plcTag = node.plcTag;
            [self _tagsSetRemoveTag:plcTag];
        }
        
        [readExpr evalWithDisconnectedSource];
        [readExpr disablePromotions];  // expressions become zombie
        
        [writeExpr disablePromotions];
        //[writeExpr evalWithDisconnectedSource];
        
        [_sourceNodesDic removeObjectForKey:node.name];
    }
    
    [_sourceNodes removeObjectsAtIndexes:indexes];
    
    NSUndoManager *undoManager = [_docModel undoManager];
    [[undoManager prepareWithInvocationTarget:self] insertSourceNodes:sourceNodes atIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Remove Tag", nil)];
    
    NSArray *observers = [_observers copy];
    for (id<SourceItemObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(sourceItem:didRemoveSourceNodesAtIndexes:)])
            [observer sourceItem:self didRemoveSourceNodesAtIndexes:indexes];
    }
}

- (void)replaceNameAtIndex:(NSInteger)indx byName:(NSString*)varName
{
    SWSourceNode *node = [_sourceNodes objectAtIndex:indx];
    
    NSString *currentName = node.name;
    if ([currentName isEqualToString:varName])
        return;
    
    NSString *newName = [self _getNameFromName:varName];
    node.name = newName;
    
    [_sourceNodesDic removeObjectForKey:currentName];
    [_sourceNodesDic setObject:node forKey:newName];
    
    [node.readExpression promoteSymbol];
    [node.writeExpression promoteSymbol];
    
    NSArray *observersCopy = [_observers copy];
    for (id<SourceItemObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(nodeNameDidChange:atIndex:)])
            [observer nodeNameDidChange:newName atIndex:indx];
    }
    
    NSUndoManager *undoManager = [_docModel undoManager];
    [[undoManager prepareWithInvocationTarget:self] replaceNameAtIndex:indx byName:currentName];
    [undoManager setActionName:NSLocalizedString(@"Change Tag Name", nil)];
    
    return;
}

//- (void)updateWExpressionAtIndex:(NSInteger)indx withString:(NSString*)string
//{
//    SWSourceNode *node = [_sourceNodes objectAtIndex:indx];
//    SWExpression *writeExpression = node.writeExpression;
//
//    NSString *oldSourceString = [writeExpression getSourceString];
//    
//    int observerCount = writeExpression.observerCount;
//    [writeExpression observerCountReleaseBy:observerCount];
//    
//    NSError *error = nil;
//    BOOL succeed = [_docModel.builder updateExpression:writeExpression fromString:string outError:&error];
//    (void)succeed;
//    
//    [writeExpression observerCountRetainBy:observerCount];
//    
//    NSUndoManager *undo = [_docModel undoManager];
//    
//    [[undo prepareWithInvocationTarget:self] updateWExpressionAtIndex:indx withString:oldSourceString];
//    [undo setActionName:NSLocalizedString(@"Change Writting Expression", nil)];
//}


- (void)updateWExpressionAtIndex:(NSInteger)indx withString:(NSString*)string
{
    SWSourceNode *node = [_sourceNodes objectAtIndex:indx];
    SWExpression *writeExpression = node.writeExpression;
    
    [self updateExpression:writeExpression fromString:string];
}



- (void)replacePlcTagAtIndex:(NSInteger)indx byPlcTag:(SWPlcTag*)plcTag
{
    SWSourceNode *node = [_sourceNodes objectAtIndex:indx];
    
    SWPlcTag *currentPlcTag = node.plcTag;
    
    [node setPlcTag:plcTag]; 

    SWReadExpression *readExpr = node.readExpression;
    if ( readExpr.observerCount>0 )
    {
        [self _tagsSetRemoveTag:currentPlcTag];
        [self _tagsSetAddTag:plcTag];
    }
    
    NSArray *observersCopy = [_observers copy];
    for (id<SourceItemObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(sourceItem:plcTagDidChange:atIndex:)])
            [observer sourceItem:self plcTagDidChange:plcTag atIndex:indx];
    }
    
    NSUndoManager *undoManager = [_docModel undoManager];
    [[undoManager prepareWithInvocationTarget:self] replacePlcTagAtIndex:indx byPlcTag:currentPlcTag];
    [undoManager setActionName:NSLocalizedString(@"Change PLC Tag", nil)];
}


#pragma mark - SWExpressionHolder (read expressions)

- (SWValue*)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if (property == nil)
        return nil;
    
    SWSourceNode *node = [_sourceNodesDic objectForKey:property];
    if ( node )
        return node.readExpression;
    
    return [super valueWithSymbol:sym property:property];
}

// symbolForExpression: implementat per SWObject, torna _identifier

- (NSString *)propertyForValue:(SWValue*)expr
{
    NSInteger count = [_sourceNodes count];
    for ( NSInteger i=0; i<count; i++ )
    {
         SWSourceNode *node = [_sourceNodes objectAtIndex:i];
         if ( node.readExpression == expr ) return node.name;
    }
    
    return [super propertyForValue:expr];
}

- (void)valuePerformRetain:(SWExpression *)expr
{
    if ( expr == self.localIPExpression)
        return;
    
    if ( expr == self.remoteHostExpression )
        return;
    
    // un cop arribat aqui ha de ser una SWReadExpression
    
    NSAssert( [expr isKindOfClass:[SWReadExpression class]], @"cucut" );
    NSLog1( @"readExpression retain" ) ;
    SWReadExpression *readExpr = (id)expr;
    
    [self _tagsSetAddTag:readExpr.node.plcTag];
}

- (void)valuePerformRelease:(SWExpression *)expr
{
    if ( expr == self.localIPExpression)
        return;
    
    if ( expr == self.remoteHostExpression )
        return;
    
    // un cop arribat aqui ha de ser una SWReadExpression
    
    NSAssert( [expr isKindOfClass:[SWReadExpression class]], @"cucut" );
    NSLog1( @"readExpression release" ) ;
    SWReadExpression *readExpr = (id)expr;
    
    [self _tagsSetRemoveTag:readExpr.node.plcTag];
    ExpressionStateCode state = (_plcObjectLinked?ExpressionStatePendingSource:ExpressionStateDisconnectedSource);
    [readExpr evalWithForcedState:state];
}


#pragma mark - SWExpressionObserver (write expressions)

// El holder hauria de ser el Node (sense implementar cap metode)
// i aqui convertirnos en observadors de les de escritura. Al rebre una
// observacio sabem que el holder es de fet un SWSourceNode.

- (void)value:(SWExpression*)expression didEvaluateWithChange:(BOOL)changed
{
    //SWSourceNode *node = (id)[expression holder];
    
    //NSLog( @"Node Name : %@", node.name );
    
}


- (void)value:(SWValue*)value didTriggerWithChange:(BOOL)changed
{
    SWExpression *localIpExp = self.localIPExpression;
    SWExpression *remoteHostExp = self.remoteHostExpression;
    
    if ( (value == localIpExp || value == remoteHostExp) && changed )
    {
        SWPlcDevice *plcDevice = [_plcDevice newDevice];
        NSString *valueAsString = [value valueAsString];
    
        if ( value == localIpExp )
            [plcDevice setLocalHostExtAsString:valueAsString];
        else
            [plcDevice setRemoteHostExtAsString:valueAsString];
    
        [self _primitiveSetPlcDevice:plcDevice];
    }
}


//- (NSString *)identifier
//{
//    return nil;
//}

//#define SOURCE_ITEM_LOGS

#pragma mark - Private methods (CommsObjectDelegate)

// El commObject pot encuar rapidament varies notificacions seguides, per exemple didClose despres d'error.
// Aquest métode (potencialment) consolida l'enviament de varies notificacions de canvi en una de sola

- (void)_prepareStateDidChangeNotification
{
    if ( _pendingCommsChangeNotification ) return;
    _pendingCommsChangeNotification = YES;
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        NSLog1( @"SourceItem:%08x StateDidChangeNotification", (int)self ) ;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinsStateDidChangeNotification object:self];
        _pendingCommsChangeNotification = NO ;
    });
}



#pragma mark - CommsObjectDelegate

// Avis de que estem esperant que hi hagi access a xarxa (WiFi o Mobil)
- (void)finsSocketWillReach:(PlcCommsObject*)plcObj
{
    NSLog1( @"SourceItem:%08x SocketWillReach", (int)self );
    
    [self _setError:nil];
    _plcObjectStarted = YES;
    _plcObjectIgnited = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsWillConnectNotification object:self];
    [self _prepareStateDidChangeNotification];
}

// Tenim access a xarxa
- (void)finsSocketDidReach:(PlcCommsObject*)plcObj
{
    NSLog1( @"SourceItem:%08x SocketDidReach", (int)self );
}

// Estem esperant la conexio del socket
- (void)finsSocketWillConnect:(PlcCommsObject*)plcObj
{
    NSLog1( @"SourceItem:%08x SocketWillConnect", (int)self );
}

// El socket s'ha conectat
- (void)finsSocketDidConnect:(PlcCommsObject*)plcObj
{
    NSLog1( @"SourceItem:%08x SocketDidConnect", (int)self );
}

// El objecte ha enllacat am el PLC incluint la configuracio inicial i el validation tag
- (void)finsDidLink:(PlcCommsObject*)plcObj altHost:(BOOL)altHost
{
    NSLog1( @"SourceItem:%08x CommObjectDidLink", (int)self );

    _altHost = altHost;
    _plcObjectLinked = YES;
    _plcObjectRoute = altHost?2:1;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsDidLinkNotification object:self];
    [self _prepareStateDidChangeNotification];
}

// S'ha completat el procesament de una peticio de lectura amb canvi en al menys un plcTagElement
- (void)finsMonitoredTagsDidChange:(PlcCommsObject*)plcObj plcTagElements:(NSArray*)elements contextObj:(id)obj
{
    NSLog1( @"SourceItem:%08x MonitoredTagsDidChange", (int)self );
    
    for ( PlcTagElement *plcTag in elements )
    {
        [self _updateTag:plcTag];
    }
    [_plcObject publish];
}

// S'ha completat el procesament de una peticio de escritura amb resultat que no afecta les comunicacions
- (void)finsDidCompleteWrite:(PlcCommsObject*)plcObj plcTagElements:(NSArray*)elements contextObj:(id)obj 
{
    NSLog1( @"SourceItem:%08x DidCompleteWrite", (int)self );

    for ( PlcTagElement *plcTag in elements )
    {
        [self _updateWTag:plcTag];
    }
}

// Despres de una lectura o escritura. Hi ha algun avis que no provoca desconexio
- (void)finsDidReportIssue:(PlcCommsObject*)plcObj error:(NSError*)error
{
    NSLog1( @"SourceItem:%08x DidReportIssue", (int)self );

    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsWarningNotification object:self];
    [self _prepareStateDidChangeNotification];
}

// Notificacio del nombre de comandes per segon enviades i el nombre de lectures per segon.
// Es crida com a maxim 2 cops per segon 
- (void)finsPollingProgress:(PlcCommsObject*)plcObj cps:(float)cps rps:(float)rps
{
    NSLog1( @"SourceItem:%08x PollingProgress cps:%g rps:%g", (int)self, cps, rps );

    _commandsPerSecond = cps;
    _readsPerSecond = rps;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsPollUpdateNotification object:self];
}

- (void)finsPollingTagsCountDidChange:(PlcCommsObject *)plcObj count:(int)count
{
    _numberOfTags = count;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsNumberOfTagsDidChangeNotification object:self];
}

     
// El socket s'ha tancat
- (void)finsDidClose:(PlcCommsObject*)plcObj
{
    NSLog1( @"SourceItem:%08x DidClose", (int)self );
    
    // l'objecte ha deixat d'estar started
    _plcObjectStarted = NO;
    
    // necesari en el cas de tancament sense error
    if ( _plcObjectLinked )
    {
        _plcObjectLinked = NO;
        _plcObjectRoute = 0;
        [self _invalidateTagSet];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsDidCloseNotification object:self];    
    [self _prepareStateDidChangeNotification];
}

// S'ha produit un error que afecta les comunicacions en qualsevol dels estadis de l'objecte. Els errors estan 
// generalment adaptats dels que torna AsyncSocket o autogenerats.
// (Veure el codi font per mes informacio)
- (void)finsErrorOcurred:(PlcCommsObject*)plcObj error:(NSError*)err
{
    NSLog1( @"SourceItem:%08x ErrorOcurred %@", (int)self, [err localizedDescription] );

    _plcObjectLinked = NO;
    _plcObjectRoute = 0;
    [self _setError:err];
    [self _invalidateTagSet];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsErrorOccurredNotification object:self];
    [self _prepareStateDidChangeNotification];
}

// El objecte PlcCommObject ha estat clausurat, i ja no fara mes intents de conexio
- (void)finsDidClausure:(PlcCommsObject*)plcObj
{
    NSLog1( @"SourceItem:%08x DidClausure", (int)self );
    
    _plcObjectStarted = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinsDidClausureNotification object:self];
    [self _prepareStateDidChangeNotification];
}


@end
