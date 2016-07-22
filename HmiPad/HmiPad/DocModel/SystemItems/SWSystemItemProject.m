//
//  SWSysItmDocument.m
//  HmiPad
//
//  Created by Joan on 31/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemProject.h"
#import "SWPropertyDescriptor.h"
#import "SWDocument.h"
#import "SWPage.h"

#import "SWEnumTypes.h"

@implementation SWSystemItemProject
{
    struct
    {
        unsigned int currentPageIdentifier:1;
    } _active;

    BOOL _isObservingCurrentPageIdentifier;

    BOOL _ignoreTrigger;
}

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if(_objectDescription == nil) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"$Project";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"PROJECT EXPRESSIONS", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"currentPageIdentifier" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"title" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"My Project Title"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"shortTitle" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"Project"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"allowedOrientation" type:SWTypeEnumProjectAllowedOrientation
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWProjectAllowedOrientationAny]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"allowedOrientationPhone" type:SWTypeEnumProjectAllowedOrientation
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWProjectAllowedOrientationAny]],
    
        nil
    ];
}


#pragma mark init / dealloc / observer retain

// La expression pageTitle ha de partir de un retain count>0 per assegurar que qualsevol cosa que s'hi conecti
// sempre l'actualitzi, es un cas similar al trend item

- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self.currentPageIdentifier observerCountRetainBy:1];
    }
    return self;
}

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        [self _observerRetainAfterDecode];
    }
    return self;
}

- (void)_observerRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.currentPageIdentifier observerCountRetainBy:1];
    }) ;
}


- (void)putToSleep
{
    if ( !self.isAsleep )
        [self.currentPageIdentifier observerCountReleaseBy:1];
    
    [super putToSleep];
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self.currentPageIdentifier observerCountRetainBy:1];
}

- (void)dealloc
{
    if (!self.isAsleep)
        [self.currentPageIdentifier observerCountReleaseBy:1];
}


#pragma mark - Properties

- (SWExpression*)currentPageIdentifier
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)title
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWValue*)shortTitle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWValue*)allowedOrientation
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWValue*)allowedOrientationPhone
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}





#pragma mark - SWValueHolder


- (void)valuePerformRetain:(SWValue *)value
{
    //[_docModel addObserver:self];
    
    if ( value == self.currentPageIdentifier )
        NSLog( @"value retain" );
    
    if( _active.currentPageIdentifier == 0 && value == self.currentPageIdentifier ) _active.currentPageIdentifier = 1;
    [self _maybeStartObservingCurrentPageIdentifier];
}

- (void)valuePerformRelease:(SWValue*)value
{
    //[_docModel removeObserver:self];
    
    if ( value == self.currentPageIdentifier )
        NSLog( @"value release" );

    if(_active.currentPageIdentifier && value == self.currentPageIdentifier) _active.currentPageIdentifier = 0;
    [self _maybeStopObservingCurrentPageIdentifier];
}


- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.currentPageIdentifier )
    {
        if ( !_ignoreTrigger )
        {
            NSString *pageIdentifier = expression.valueAsString;
            if ( pageIdentifier.length > 0 )
            {
                _ignoreTrigger = YES;
                [_docModel selectPageWithPageIdentifier:expression.valueAsString];
                _ignoreTrigger = NO;
            }
        }
    }
    
    else if ( expression == self.title )
    {
        [_docModel updateTitleNotification];
    }
    
    else if ( expression == self.shortTitle )
    {
        [_docModel updateTitleNotification];
    }
    
    else if ( expression == self.allowedOrientation )
    {
        [_docModel updateAllowedOrientationNotification];
    }
    
    else if ( expression == self.allowedOrientationPhone )
    {
        [_docModel updateAllowedOrientationNotification];
    }
}



#pragma mark - current page identifier

- (void)updateCurrentPageIdentifierIfNeeded
{
    if ( _isObservingCurrentPageIdentifier )
        [self _updateCurrentPageIdentifierExpression];

}


#pragma mark - current page identifier

- (void)_updateCurrentPageIdentifierExpression
{
    SWPage *page = nil;
    NSString *pageIdentifier = @"";
    NSInteger selectedPageIndex = [_docModel selectedPageIndex];

    if ( selectedPageIndex != NSNotFound )
    {
        page = [_docModel.pages objectAtIndex:selectedPageIndex];
        pageIdentifier = [page.pageIdentifier valueAsString];
    }
    
    _ignoreTrigger = YES;
    [self.currentPageIdentifier evalWithStringConstant:(CFStringRef)pageIdentifier];
    _ignoreTrigger = NO;
}

- (void)_maybeStartObservingCurrentPageIdentifier
{
    if ( !(_active.currentPageIdentifier ) ) return;
    if ( !_isObservingCurrentPageIdentifier )
    {
        [self _updateCurrentPageIdentifierExpression];
        _isObservingCurrentPageIdentifier = YES;
    }
}

- (void)_maybeStopObservingCurrentPageIdentifier
{
    if ( _active.currentPageIdentifier) return;
    if ( _isObservingCurrentPageIdentifier )
    {
        _isObservingCurrentPageIdentifier = NO;
    }
}



//#pragma mark - DocumentModelObserver
//
//- (void)documentModel:(SWDocumentModel *)docModel selectedPageDidChange:(NSInteger)index direction:(NSInteger)direction
//{
//    if ( index == NSNotFound )
//        return;
//    
//    if ( !_ignoreTrigger )
//    {
//        _ignoreTrigger = YES;
//        SWPage *page = [docModel.pages objectAtIndex:index];
//        //NSString *pageTitle = page.title.valueAsString;
//        NSString *pageIdentifier = [page.pageIdentifier valueAsString];
//        [self.currentPageIdentifier evalWithStringConstant:(CFStringRef)pageIdentifier];
//        _ignoreTrigger = NO;
//    }
//}



#pragma mark - Symbolic Coding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        SWExpression *exp = [decoder decodeExpressionForKey:@"currentPageIdentifier"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+0 withObject:exp];
        
        SWValue *va0 = [decoder decodeValueForKey:@"title"];
        if ( va0 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+1 withObject:va0];
        
        SWValue *va1 = [decoder decodeValueForKey:@"shortTitle"];
        if ( va1 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+2 withObject:va1];
        
        SWValue *va2 = [decoder decodeValueForKey:@"allowedOrientation"];
        if ( va2 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+3 withObject:va2];
        
        SWValue *va3 = [decoder decodeValueForKey:@"allowedOrientationPhone"];
        if ( va3 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+4 withObject:va3];
        else [self.allowedOrientationPhone evalWithValue:self.allowedOrientationPhone];
        
        [self _observerRetainAfterDecode];
    }
    
    return self;
}


- (NSString*)replacementKeyForKey:(NSString *)key
{
    if ( [key isEqualToString:@"currentPageIdentifier"] )
        return @"pageIdentifier";  // <-- provem "pageIdentifier" si "currentPageIdentifier" no el troba.

    if ( [key isEqualToString:@"pageIdentifier"] )
        return @"pageTitle";  // <-- provem "pageTitle" si "pageIdentifier" no el troba.
        
    return nil;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder];

    [encoder encodeValue:self.currentPageIdentifier forKey:@"currentPageIdentifier"];
    [encoder encodeValue:self.title forKey:@"title"];
    [encoder encodeValue:self.shortTitle forKey:@"shortTitle"];
    [encoder encodeValue:self.allowedOrientation forKey:@"allowedOrientation"];
    [encoder encodeValue:self.allowedOrientationPhone forKey:@"allowedOrientationPhone"];
}



@end
