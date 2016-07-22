//
//  SWSystemItemPlayer.m
//  HmiPad
//
//  Created by Joan on 29/05/13.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemPlayer.h"

#import "SWPropertyDescriptor.h"

#import "AppModelFilePaths.h"

#import "SWDocumentModel.h"
//#import "SWHistoAlarms.h"
//#import "SWEventCenter.h"
//#import "SWEvent.h"

#import "SWPlayerCenter.h"


NSString *kViewerLabel = @"kViewerLabel";
NSString *kViewerTextURL = @"kViewerTextURL" ;
NSString *kPlayerRepeat = @"kPlayerRepeat" ;

@interface SWSystemItemPlayer()
{
    SWPlayerCenter *_player;
    struct
    {
        unsigned int play:1;
        unsigned int title:1;
        unsigned int url:1;
    } _active;

}
@end



@implementation SWSystemItemPlayer
{
    BOOL _pendingCommitDisplayPlayer;
    BOOL _pendingCommitRepeatPlayer;
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
    return @"$Player";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"AUDIO PLAYER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"play" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"stop" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"repeat" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"title" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"url" type:SWTypeUrl
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
     
        nil
    ];
}


#pragma mark init / dealloc / observer retain

// La expression pageTitle ha de partir de un retain count>0 per assegurar que qualsevol cosa que s'hi conecti
// sempre l'actualitzi, es un cas similar al trend item


- (void)_commonInit
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playerCenterErrorNotification:) name:SWPlayerCenterErrorNotification object:nil];
}


- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self _performObserverRetain];
        [self _commonInit];
    }
    return self;
}

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        [self _observerRetainAfterDecode];
        [self _commonInit];
    }
    return self;
}

- (void)_observerRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self _performObserverRetain];
    }) ;
}


- (void)putToSleep
{
    if ( !self.isAsleep )
        [self _performObserverRelease];
    
    [super putToSleep];
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self _performObserverRetain];
}

- (void)dealloc
{
    if (!self.isAsleep)
        [self _performObserverRelease];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)_performObserverRetain
{
    [self.play observerCountRetainBy:1];
    [self.url observerCountRetainBy:1];
}

- (void)_performObserverRelease
{
    [self.play observerCountReleaseBy:1];
    [self.url observerCountReleaseBy:1];
}


#pragma mark - Error notification

- (void)playerCenterErrorNotification:(NSNotification*)note
{
    NSDictionary *userInfo = [note userInfo];
    NSString *errorString = userInfo[SWPlayerCenterErrorKey];
    
//    SWEvent *event = [[SWEvent alloc] initWithLabel:@"AUDIO" comment:errorString active:NO];
//    [_docModel.eventCenter eventsAddSystemEvent:event];
//    [_docModel.histoAlarms addEvent:event];
    
    NSString *label = NSLocalizedString(@"AUDIO", nil);
    [_docModel addSystemEventWithLabel:label comment:errorString];
}

#pragma mark - Properties

- (SWExpression*)play
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWExpression*)stop
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWExpression*)repeat
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWExpression*)title
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWExpression*)url
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}



#pragma mark - private


- (void)_delayedCommitDisplayPlayerWithUserInfo:(NSDictionary*)userInfo
{
    NSString *text = [userInfo objectForKey:kViewerLabel];
    NSString *urlText = [userInfo objectForKey:kViewerTextURL];
    [_player playSoundTextUrl:urlText labelText:text];
    
    _pendingCommitDisplayPlayer = NO ;
}


- (void)_delayedCommitRepeatPlayerWithUserInfo:(NSDictionary*)userInfo
{
    BOOL repeat = [[userInfo objectForKey:kPlayerRepeat] boolValue] ;
    [[SWPlayerCenter defaultCenter] setRepeat:repeat] ;
    [_player setRepeat:repeat];
    
    _pendingCommitRepeatPlayer = NO ;
}


- (void)_displayPlayerWithLabel:(NSString*)text url:(NSString*)textUrl
{
    if ( _pendingCommitDisplayPlayer == NO )
    {
        //NSString *fullPath = [self _fullPlayerUrlPathForTextUrl:textUrl] ;
    
        NSString *fullPath = [filesModel().filePaths fullPlayerUrlPathForTextUrl:textUrl inDocumentName:_docModel.redeemedName] ;

        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
            text,kViewerLabel,
            fullPath,kViewerTextURL,
            nil] ;
    
        [self performSelector:@selector(_delayedCommitDisplayPlayerWithUserInfo:) withObject:userInfo afterDelay:0] ;
        _pendingCommitDisplayPlayer = YES ;
    }
}


- (void)_setPlayerRepeat:(BOOL)repeat
{
    if ( _pendingCommitRepeatPlayer == NO )
    {
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithBool:repeat],kPlayerRepeat,
            nil] ;

        [self performSelector:@selector(_delayedCommitRepeatPlayerWithUserInfo:) withObject:userInfo afterDelay:0] ;
        _pendingCommitRepeatPlayer = YES ;
    }
}





#pragma mark - SWValueHolder


//- (void)valuePerformRetain:(SWValue *)value
//{
//    // activate player
//    if ( _player == nil )
//        _player = [[SWPlayerCenter alloc] init];
//}
//
//- (void)valuePerformRelease:(SWValue*)value
//{
//    // disable player
//    _player = nil;
//}

- (void)_performPlayerActions
{
    BOOL play = [self.play valueAsBool];
    BOOL stop = [self.stop valueAsBool];
    
    if ( play )
    {
        if ( _player == nil )
            _player = [[SWPlayerCenter alloc] init];
        
        BOOL repeat = [self.repeat valueAsBool];
        [self _setPlayerRepeat:repeat];

        NSString *label = [self.title valueAsString];
        NSString *urlText = [self.url valueAsString];
        [self _displayPlayerWithLabel:label url:urlText];
    }

    if ( stop )
    {
        [self _displayPlayerWithLabel:nil url:nil];
    }
    
}


- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.play )
    {
        [self _performPlayerActions];
    }
    
    if ( expression == self.stop )
    {
        [self _performPlayerActions];
    }
    
    else if ( expression == self.repeat )
    {
        [self _performPlayerActions];
    }
    
    else if ( expression == self.title )
    {
        // posiblement res
    }
    
    else if ( expression == self.url )
    {
        [self _performPlayerActions];
    }
}



#pragma mark - Symbolic Coding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        SWExpression *exp = nil;
        
        exp = [decoder decodeExpressionForKey:@"play"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+0 withObject:exp];
        
        exp = [decoder decodeExpressionForKey:@"stop"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+1 withObject:exp];
        
        exp = [decoder decodeExpressionForKey:@"repeat"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+2 withObject:exp];
        
        exp = [decoder decodeExpressionForKey:@"title"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+3 withObject:exp];
        
        exp = [decoder decodeExpressionForKey:@"url"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+4 withObject:exp];
        
        [self _observerRetainAfterDecode];
        
    }
    return self;
}

//- (NSString*)replacementKeyForKey:(NSString *)key
//{
//    return nil;
//}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder];

    [encoder encodeValue:self.play forKey:@"play"];
    [encoder encodeValue:self.stop forKey:@"stop"];
    [encoder encodeValue:self.repeat forKey:@"repeat"];
    [encoder encodeValue:self.title forKey:@"title"];
    [encoder encodeValue:self.url forKey:@"url"];
}



@end
