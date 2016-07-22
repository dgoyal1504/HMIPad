//
//  SWAlarm.m
//  HmiPad
//
//  Created by Lluch Joan on 04/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWAlarm.h"

#import "SWEvent.h"
#import "SWEventCenter.h"
#import "SWHistoAlarms.h"

#import "SWPropertyDescriptor.h"

#import "AppModelFilePaths.h"

#import "SWEnumTypes.h"
#import "SWDocumentModel.h"


@implementation SWAlarm

#pragma mark ObjectDescription

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
    return @"alarm";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"ALARM", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
       
        [SWPropertyDescriptor propertyDescriptorWithName:@"active" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"group" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Group"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"comment" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Alarm"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"playSound" type:SWTypeEnumAlarmPlayDefaultSound
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWAlarmPlayDefaultSoundNo]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"url" type:SWTypeUrl
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"showAlert" type:SWTypeEnumAlarmShowAlert
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWAlarmShowAlertNo]],
            
        nil];
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {        
        [self _alarmObserverRetainAfterDecode];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
}


- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    [super retrieveWithQuickCoder:decoder];
}


- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    [super storeWithQuickCoder:encoder];
}


#pragma mark - Symbolic coding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        [self _alarmObserverRetainAfterDecode];
    }
    return self;
}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder];
    // Nothing to do
}

- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
{
    [super retrieveWithSymbolicCoder:decoder identifier:ident parentObject:parent];
}

- (void)storeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super storeWithSymbolicCoder:encoder];
}

- (NSString*)replacementKeyForKey:(NSString *)key
{
    if ( [key isEqualToString:@"group"] )
        return @"label";  // <-- provem "label" si "group" no el troba.

    return nil;
}

#pragma mark Observer/Retain release

- (void)_alarmObserverRelease
{
    [self.active observerCountReleaseBy:1];
    [self.group observerCountReleaseBy:1];
    [self.comment observerCountReleaseBy:1];
    
    //NSLog( @"alarm observer Release observerCount: %d", self.comment.observerCount);
}

- (void)_alarmObserverRetain
{
    [self.active observerCountRetainBy:1];
    [self.group observerCountRetainBy:1];
    [self.comment observerCountRetainBy:1];
    
    //NSLog( @"alarm observer Retain  observerCount: %d", self.comment.observerCount);
}

- (void)_alarmObserverRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self _alarmObserverRetain];
    });
}

#pragma mark - Init

- (id)initInDocument:(SWDocumentModel*)docModel
{
    self = [super initInDocument:docModel];
    if (self)
    {
        [self _alarmObserverRetain];
    }
    return self;
}

- (void)putToSleep
{
    if ( !_asleep )
        [self _alarmObserverRelease];
    
    [super putToSleep];
    
}

- (void)awakeFromSleepIfNeeded
{
    BOOL wasAsleep = _asleep;
    [super awakeFromSleepIfNeeded];
    
    if (wasAsleep)
        [self _alarmObserverRetain];
}

// No funciona perque aquest dealloc es crida durant la descodificacio binaria de objectes que estaven adormits, provocant un release de mes que no toca.

// Ok, *si* funciona perque el _isAsleep es codifica en el SWObject i per tant al descodificar tot queda normal

#pragma mark - Overriden Methods

- (void)dealloc
{
    //NSLog( @"Alarm dealloc :%@", [self identifier] ) ;
    if (!self.isAsleep)
        [self _alarmObserverRelease];
}

- (BOOL)matchesSearchWithString:(NSString*)searchString
{
    NSComparisonResult result1 = [self.group.valueAsString compare:searchString
                                                           options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                             range:NSMakeRange(0, [searchString length])];
    
    NSComparisonResult result2 = [self.comment.valueAsString compare:searchString
                                                             options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                               range:NSMakeRange(0, [searchString length])];
    
    return  (result1 == NSOrderedSame) ||
            (result2 == NSOrderedSame) ||
            [super matchesSearchWithString:searchString];
}

#pragma mark - Properties

- (SWExpression*)active
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)group
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)comment
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)playDefaultSound
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

-(SWExpression*)url
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)showAlert
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

#pragma mark - SWValueHolder

- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.active )
    {
        if ( changed )
        {
            [_docModel.eventCenter updateEventsForHolder:self];
            //[_docModel.histoAlarms addEventForHolder:self];
            
            SWEvent *event = [[SWEvent alloc] initWithHolder:self];
            [_docModel.histoAlarms addEvent:event];
        }
    }
}

#pragma mark - SWEventHolder

- (NSString*)titleForEvent
{
    return [self.group.valueAsString copy];
}

- (NSString*)commentForEvent
{
    return [self.comment.valueAsString copy];
}

- (BOOL)activeStateForEvent
{
    return self.active.valueAsBool;
}

- (NSString *)fullSoundUrlTextForEvent
{
   if ( _docModel.editMode )
        return nil;
    
    NSString *fullSoundUrl = nil;

    BOOL shouldPlayDefault = [self.playDefaultSound valueAsBool];
    NSString *playSound = shouldPlayDefault ? @"system://Alarm.caf" : self.url.valueAsString;
    
    if ( playSound.length )
    {
        fullSoundUrl = [filesModel().filePaths fullPlayerUrlPathForTextUrl:playSound inDocumentName:_docModel.redeemedName];
    }
    
    return fullSoundUrl;
}

- (BOOL)shouldShowAlertForEvent
{
    if ( _docModel.editMode )
        return NO;
    
    return self.showAlert.valueAsBool;
}


@end







