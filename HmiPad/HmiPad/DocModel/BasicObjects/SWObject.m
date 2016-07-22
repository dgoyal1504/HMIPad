//
//  SWItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWObject.h"

#import "SWExpression.h"
#import "RpnBuilder.h"
#import "QuickCoder.h"
#import "SWPropertyDescriptor.h"
#import "SWObjectDescription.h"
#import "SWDocumentModel.h"
//#import "SWSourceItem.h"

NSString * const SWObjectIdentifierKey = @"identifier";

#pragma mark - Class Implementation

@interface SWObject()
@end

@implementation SWObject

#pragma mark - C Methods

BOOL BitFromIntAtIndex(NSInteger integer, NSUInteger index) 
{    
    if ((integer & ( 1 << index ))) {
        return YES;
    }
    
    return NO;
}

void SetBitFromIntAtIndex(NSInteger *integer, NSUInteger index, BOOL bit) 
{       
    NSInteger mask = (1 << index);
    
    if (bit) 
        *integer = *integer | mask;
    else
        *integer = *integer & (~mask);
}

void SetAllBitsTo(NSInteger *integer, BOOL bit) 
{
    if (bit)
        *integer = ~0;
    else
        *integer = 0;
}

#pragma mark - SWObjectDescriptionDataSource Protocol

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (Class)defaultControllerClass
{
    return NULL;
}

+ (NSString*)defaultIdentifier
{
    return @"item";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"BASIC PROPERTIES", nil);
}


+ (NSArray*)propertyDescriptions
{
    return [NSArray array];
}

+ (void)initialize
{    
    [[self class] objectDescription];
}

+ (SWValue*)overridenDefaultValueForPropertyName:(NSString*)propertyName
{
    return nil;
}

+ (BOOL)isValidIdentifier:(NSString*)ident outErrString:(NSString**)outErrStr
{
    BOOL valid = NO;
    if ( ident )
    {
        char buff[81];
        const char *ch = buff;
        valid = CFStringGetCString( (__bridge CFStringRef)ident, buff, sizeof(buff), kCFStringEncodingASCII);
        
        if ( valid && *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) 
            || (*ch >= 'A' && *ch <='Z') || ( *ch == '_' ) /*|| ( *ch == '$' ) */) )
        {
            ch++;
            while ( *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) ||
                (*ch >= 'A' && *ch <='Z') || (*ch >= '0' && *ch <= '9' ) || ( *ch == '_' )  ) ) ch++;
        }
        else valid = NO;
        
        valid = valid && *ch == '\0';
    }
    
    if ( !valid )
    {
        if ( outErrStr ) *outErrStr = NSLocalizedString(@"Invalid Identifier Name", nil);
    }
    
    return valid;
}


#pragma mark propertyDescriptions de la instancia

// override in subclases
- (NSArray*)propertyDescriptions
{
    return nil;
}



#pragma mark Properties

@synthesize configurationTag = _configurationTag;

// -- Coding Properties -- //
@synthesize identifier = _identifier;
@synthesize docModel = _docModel;
//@synthesize uuid = _uuid;
@synthesize properties = _properties;

// -- AsleepCapable Properties -- //
@synthesize asleep = _asleep;

- (void)_doSWObjectInit
{
    _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
    _asleep = NO;
 
    _configurationTag = 0;
    SetBitFromIntAtIndex(&_configurationTag, 0, YES);
    
//    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
//    _uuid = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
//    CFRelease(uuidRef);
}


- (void)_initValuesForItem:(SWObject*)item class:(Class)itemClass
{    
    // si hem superat la base clase tornem
    if ( [itemClass isSubclassOfClass:[SWObject class]] )
    {
        // inicialitzem recursivament les expressions de les superclases
        [self _initValuesForItem:item class:[itemClass superclass]];
        
        SWObjectDescription *objDesc = [itemClass objectDescription];
        NSArray *propertyDescriptions = [objDesc propertyDescriptions];
        
        for (SWPropertyDescriptor *descriptor in propertyDescriptions)
        {
//            SWValue *defaultValue = [descriptor defaultValueForObject:self];
//            
//            SWValue *value = nil;
//            SWPropertyType propertyType = descriptor.propertyType;
//            
//            if (propertyType == SWPropertyTypeValue || propertyType == SWPropertyTypeNoEditableValue)
//            {
//                value = [[SWValue alloc] initWithValue:defaultValue];
//            } 
//            else if (propertyType == SWPropertyTypeExpression) 
//            {
//                value = [[SWExpression alloc] initWithValue:defaultValue];
//            }
            
            SWValue *value = [self newValueWithPropertyDescriptor:descriptor];
            
            value.holder = self;
            [_properties addObject:value];
        }
    }
}


- (SWValue*)newValueWithPropertyDescriptor:(SWPropertyDescriptor*)descriptor
{
    SWValue *defaultValue = [descriptor defaultValueForObject:self];
            
    SWValue *value = nil;
    SWPropertyType propertyType = descriptor.propertyType;
            
    if (propertyType == SWPropertyTypeValue || propertyType == SWPropertyTypeNoEditableValue)
    {
        value = [[SWValue alloc] initWithValue:defaultValue];
    }
    else if (propertyType == SWPropertyTypeExpression)
    {
        value = [[SWExpression alloc] initWithValue:defaultValue];
    }
    return value;
}





- (id)initInDocument:(SWDocumentModel*)docModel
{
    self = [super init];
    if (self) 
    {
        [self _doSWObjectInit];
        
        _docModel = docModel;
        _properties = [NSMutableArray array];
        
        RpnBuilder *builder = _docModel.builder;
        
        NSString *defaultIdent = [[self.class objectDescription] defaultIdentifier];
        NSString *newIdentifier = [builder replaceGlobalSymbol:nil withHolder:self bySymbol:defaultIdent];   
        _identifier = newIdentifier;
        
        [self _initValuesForItem:self class:[self class]];
    }
    return self;
}

- (NSString*)redeemedName
{
    return _docModel.redeemedName;
}


- (void)dealloc
{
    if (!_asleep)
    {
        [_docModel.builder replaceGlobalSymbol:self.identifier withHolder:self bySymbol:NULL /*outError:NULL*/];
    }

    for ( SWValue *value in _properties )
    {
        [value invalidate];
//        [value setHolder:nil];
//        [value promoteSymbol];
//        [value evalWithForcedState:ExpressionStateInvalidSource];
    }
    
//    [_properties makeObjectsPerformSelector:@selector(setHolder:) withObject:nil];
//    [_properties makeObjectsPerformSelector:@selector(promoteSymbol)];
}


//- (id)copyWithZone:(NSZone *)zone
//{
//    return self;
//}


#pragma mark Group Methods

- (BOOL)isGroupItem
{
    return NO;
}

- (NSInteger)groupCount
{
    return 0;
}


#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) {
        _docModel = [decoder decodeObject];
        _identifier = [decoder decodeObject];
        //_uuid = [decoder decodeObject];
        _properties = [decoder decodeObject];
        _asleep = [decoder decodeInt];
        //_observers = [NSMutableArray array];
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _configurationTag = 0;
        SetBitFromIntAtIndex(&_configurationTag, 0, YES);
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_docModel];
    [encoder encodeObject:_identifier];
    //[encoder encodeObject:_uuid];
    [encoder encodeObject:_properties];
    [encoder encodeInt:_asleep];
}


- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    NSArray *propertyDescriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger propertyCount = propertyDescriptions.count;
    
    for ( NSInteger i=0; i<propertyCount; i++ )
    {
        SWPropertyDescriptor *descriptor = [propertyDescriptions objectAtIndex:i];
        SWPropertyType propertyType = descriptor.propertyType;
        if ( propertyType == SWPropertyTypeExpression )
        {
            SWValue *value = [_properties objectAtIndex:i];
            [decoder retrieveForObject:value];
        }
    }
}

- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger count = descriptions.count;
    for (NSInteger i=0; i<count; i++) 
    {
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:i];
        SWPropertyType propertyType = descriptor.propertyType;
        if ( propertyType == SWPropertyTypeExpression )
        {
            SWValue *value = [_properties objectAtIndex:i];
            [encoder encodeObject:value];
        }
    }
}


#pragma mark - SymbolicCoding

//-(id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)docModel
- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)docModel
{    
    self = [super init];
    if (self) 
    {
        [self _doSWObjectInit];
        
        _docModel = docModel;
        _identifier = ident;
        
        NSArray *propertyDescriptions = [self.class objectDescription].allPropertyDescriptions;
        NSMutableArray *values = [NSMutableArray array];
        
        for (SWPropertyDescriptor *descriptor in propertyDescriptions) 
        {
            SWValue *value = nil;
            SWPropertyType propertyType = descriptor.propertyType;
            
            if (propertyType == SWPropertyTypeExpression) 
            {
                SWExpression *exp = [decoder decodeExpressionForKey:descriptor.name];
                
                if (exp == nil)
                {
                    //exp = [[SWExpression alloc] initWithValue:[descriptor defaultValueForObject:self]];
                    exp = (id)[self newValueWithPropertyDescriptor:descriptor];
                    exp.holder = self;
                    [self.builder registerExpressionForCommit:(SWExpression*)exp];
                }
                
                value = exp;
            }
            else if (propertyType == SWPropertyTypeValue || propertyType == SWPropertyTypeNoEditableValue) 
            {
                value = [decoder decodeValueForKey:descriptor.name];
                
                if (value == nil) 
                {
                    //value = [[SWValue alloc] initWithValue:[descriptor defaultValueForObject:self]];
                    value = [self newValueWithPropertyDescriptor:descriptor];
                    value.holder = self;
                }
            }
            
            [values addObject:value];
        }
        
        _properties = values;
    }
    return self;
}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{    
    //NSInteger count = _properties.count;
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger count = descriptions.count;
    
    for (NSInteger i=0; i<count; i++) 
    {
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:i];
        SWValue *value = [_properties objectAtIndex:i];
        [encoder encodeValue:value forKey:descriptor.name];
    }
}

- (NSString*)symbolicIdentifier
{
    return _identifier;
}


- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent
{
    NSArray *propertyDescriptions = [self.class objectDescription].allPropertyDescriptions;
 
    NSInteger propertyCount = propertyDescriptions.count;
    NSInteger valuesCount = _properties.count;
    
    if ( propertyCount == valuesCount )
    {
        for ( NSInteger i=0; i<propertyCount; i++ )
        {
            SWPropertyDescriptor *descriptor = [propertyDescriptions objectAtIndex:i];
            SWPropertyType propertyType = descriptor.propertyType;
            if ( propertyType == SWPropertyTypeExpression )
            {
                SWValue *value = [_properties objectAtIndex:i];
                [decoder retrieveForValue:value forKey:descriptor.name];
            }
        }
    }
}


- (void)storeWithSymbolicCoder:(SymbolicArchiver*)encoder
{
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger count = descriptions.count;
    
    for (NSInteger i=0; i<count; i++) 
    {
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:i];
        SWPropertyType propertyType = descriptor.propertyType;
        if ( propertyType == SWPropertyTypeExpression )
        {
            SWValue *value = [_properties objectAtIndex:i];
            [encoder encodeValue:value forKey:descriptor.name];
        }
    }
}

#pragma mark - Properties

- (void)setIdentifier:(NSString *)identifier
{
    NSString *oldIdentifier = self.identifier;
    if (![self _setIdentifierInternal:identifier])
        return;

    NSUndoManager *undoManager = [_docModel undoManager];

    [[undoManager prepareWithInvocationTarget:self] setIdentifier:oldIdentifier];
    [undoManager setActionName:@"Identifier Changed"];
}


- (BOOL)_setIdentifierInternal:(NSString*)identifier
{
    if ([identifier isEqualToString:self.identifier]) 
        return NO; 
    
    RpnBuilder *builder = _docModel.builder;
    NSString *symbol = [builder replaceGlobalSymbol:self.identifier withHolder:self bySymbol:identifier /*outError:error*/];
    
    _identifier = symbol;
    
    NSArray *observersCopy = [_observers copy];
    for (id<SWObjectObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(identifierDidChangeForObject:)])
            [observer identifierDidChangeForObject:self];
    }
    
//    [_properties makeObjectsPerformSelector:@selector(promoteSymbol)];
    
    for ( SWValue *value in _properties )
    {
        [value promoteSymbol];
    }
    
    return YES;
}

#pragma mark - Item Methods

- (void)addObjectObserver:(id<SWObjectObserver>)itemObserver
{
    [_observers addObject:itemObserver];
}

- (void)removeObjectObserver:(id<SWObjectObserver>)itemObserver
{
    [_observers removeObjectIdenticalTo:itemObserver];
}

//- (void)addAsleepObserver:(id<SWAsleepObserver>)observer
//{
//    [_asleepObservers addObject:observer];
//}
//
//- (void)removeAsleepObserver:(id<SWAsleepObserver>)observer
//{
//    [_asleepObservers removeObjectIdenticalTo:observer];
//}

//#warning aquest metode i el seguent els hauriem de treure, fan massa i es massa facil de utilitzarlos sense pensar, en general hem de observar nomes els values rellevants en cada cas. Si en un controlador realment necesitem observar totes les propietats de un objecte (que no hauria de ser mai) sempre podem accedir a la propietat properties.
//- (void)addPropertiesObserver:(id<ValueObserver>)observer
//{
//    [_properties makeObjectsPerformSelector:@selector(addObserver:) withObject:observer];
//}
//
//- (void)removePropertiesObserver:(id<ValueObserver>)observer
//{
//    [_properties makeObjectsPerformSelector:@selector(removeObserver:) withObject:observer];
//}

- (BOOL)matchesSearchWithString:(NSString*)searchString
{    
    NSString *string = _identifier;
    NSComparisonResult result = [string compare:searchString
                                        options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                          range:NSMakeRange(0, [searchString length])];
    
    return result == NSOrderedSame;
}

- (RpnBuilder*)builder
{
    return _docModel.builder;
}

- (BOOL)isCommitingWithMoveToGlobal
{
    return [_docModel.builder isCommitingWithMoveToGlobal];
}

- (void)updateExpression:(SWExpression*)expression fromString:(NSString*)string
{
//    if (![_properties containsObject:expression])
//        NSLog(@"[jduiw1] WARNING: Updating item expression not contained in used item.");
    
    NSString *oldSourceString = [expression getSourceString];
    //NSLog(@"Replacing expression: %@, by: %@", oldExpressionSourceString, string );
    
    int observerCount = expression.observerCount;
    [expression observerCountReleaseBy:observerCount];
    
    NSError *error = nil;
    BOOL succeed = [_docModel.builder updateExpression:expression fromString:string outError:&error];
    (void)succeed;
    
    [expression observerCountRetainBy:observerCount];
    
        
    NSUndoManager *undo = _docModel.undoManager;
    //NSLog( @"undo %@", undo ) ;

    [[undo prepareWithInvocationTarget:self] updateExpression:expression fromString:oldSourceString];
    [undo setActionName:NSLocalizedString(@"Expression Change",nil)];
    
    return;
}

/* Atencio. No va per les clases derivades (dificil de resoldre degut a la no relacio 
        entre el objectDescription apropiat i la clase de la instancia) (Una Pena)

- (SWExpression*)selfExpressionAtIndex:(NSInteger)indx
{
    SWObjectDescription *objectDescription = [[self class] objectDescription];
    return [_properties objectAtIndex:objectDescription.firstClassPropertyIndex + indx];
}
*/



#pragma mark - Sleep Capable


- (void)putToSleep
{
    if (!_asleep) 
    {
        _asleep = YES;
        
        NSArray *observersCopy = [_observers copy];
        for (id <SWObjectObserver> observer in observersCopy)
        {
            if ([observer respondsToSelector:@selector(willRemoveObject:)])
                [observer willRemoveObject:self];
        }
        
        //[_properties makeObjectsPerformSelector:@selector(disablePromotions)];
        
        for ( SWValue *value in _properties )
        {
            [value evalWithDisconnectedSource];
            [value disablePromotions];
        }
        
        [_docModel.builder replaceGlobalSymbol:self.identifier withHolder:self bySymbol:nil];
    }
}

- (void)awakeFromSleepIfNeeded
{
    if (_asleep)
    {
        _asleep = NO;
        [_docModel.builder replaceGlobalSymbol:nil withHolder:self bySymbol:self.identifier];
        //[_properties makeObjectsPerformSelector:@selector(enablePromotions)];
        
        for ( SWValue *value in _properties )
        {
            [value enablePromotions];
            [value eval];
        }
    }
}

#pragma mark - SWValueHolder

//- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)property
//{
//    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;    
//    
//    NSInteger index = NSNotFound;
//    NSInteger i = 0;
//    
//    for (SWPropertyDescriptor *descriptor in descriptions) 
//    {
//        if ([descriptor.name isEqualToString:property]) 
//        {
//            index = i;
//            break;
//        }
//        ++i;
//    }
//    
//    if (index != NSNotFound) 
//        return [_properties objectAtIndex:index];
//    
//    return nil;
//}

- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    
    NSInteger i = 0;
    for (SWPropertyDescriptor *descriptor in descriptions) 
    {
        if ([descriptor.name isEqualToString:property]) 
        {
            return [_properties objectAtIndex:i];
        }
        ++i;
    }
    
    return nil;
}

- (SWPropertyDescriptor*)valueDescriptionForValue:(SWValue*)value
{
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger index = [_properties indexOfObjectIdenticalTo:value];
    
    if (index != NSNotFound) 
    {
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:index];
        return descriptor;
    }
    
    return nil;
}

- (SWValue*)defaultValueForValue:(SWValue*)value
{
//    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
//    NSInteger index = [_properties indexOfObjectIdenticalTo:value];
//    
//    if (index != NSNotFound) 
//    {
//        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:index];
//        return [descriptor defaultValueForObject:self];
//    }
//    
//    return nil;
    
    SWPropertyDescriptor *descriptor = [self valueDescriptionForValue:value];
    if ( descriptor )
        return [descriptor defaultValueForObject:self];
    
    return nil;
}




- (NSString *)symbolForValue:(SWValue*)value
{
    return _identifier;
}

- (NSString *)propertyForValue:(SWValue*)value
{
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger index = [_properties indexOfObjectIdenticalTo:value];
    
    if (index != NSNotFound) 
    {
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:index];
        return descriptor.name;
    }
    
    return nil;
}

- (void)setGlobalIdentifier:(NSString*)ident
{
   _identifier = ident;
}

- (void)expression:(SWExpression*)expression didTriggerWithChange:(BOOL)changed
{
    // To Override
}

- (void)registerToUndoManagerCurrentValue:(SWValue *)value
{    
    NSArray *descriptions = [self.class objectDescription].allPropertyDescriptions;
    NSInteger index = [_properties indexOfObjectIdenticalTo:value];
    
    if (index != NSNotFound) 
    {    
        NSUndoManager *undoManager = self.docModel.undoManager;
        id target = [undoManager prepareWithInvocationTarget:value];

        SWValue *undoValue = [[SWValue alloc] initWithValue:value];
        [target setValueFromValue:undoValue]; // <-------------------------------------------------------- Molt hàbil això!
        
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:index];
        
        NSString *undoText = [NSString stringWithFormat:@"Change %@",descriptor.typeAsString];
        [undoManager setActionName:undoText];
    }
}

@end
