//
//  SWSystemItemUsersManager.m
//  HmiPad
//
//  Created by Joan Lluch on 25/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemUsersManager.h"
#import "SWPropertyDescriptor.h"
#import "SWDocumentModel.h"
#import "SWProjectUser.h"
#import "SWLoginWindowControllerP.h"

@interface SWSystemItemUsersManager()<LoginWindowControllerDelegate>

@end



@implementation SWSystemItemUsersManager
{
    struct
    {
        unsigned int currentUserName:1;
        unsigned int currentUserLevel:1;
    } _active;

    BOOL _isObservingUserName;
    BOOL _isObservingLevel;
    BOOL _isPerformingLogin;
    BOOL _isPerformingForcedLogin;
    
    SWLoginWindowControllerP *_loginWindow;
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
    return @"$UsersManager";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"USERS MANAGER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"login" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"enableAutoLogin" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1.0]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"adminUserPassword" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"admin"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"currentUserName" type:SWTypeString
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"currentUserLevel" type:SWTypeInteger
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:9.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"backgroundColor" type:SWTypeColor
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"backgroundImage" type:SWTypeImagePath
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
     
        [SWPropertyDescriptor propertyDescriptorWithName:@"companyTitle" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"Company Title"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"companyLogo" type:SWTypeImagePath
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
        nil
    ];
}



#pragma mark init / dealloc / observer retain


- (void)_commonInit
{
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
    
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
}

- (void)_performObserverRetain
{
    [self.login observerCountRetainBy:1];
    [self.enableAutoLogin observerCountRetainBy:1];
    [self.adminUserPassword observerCountRetainBy:1];
}

- (void)_performObserverRelease
{
    [self.login observerCountReleaseBy:1];
    [self.enableAutoLogin observerCountReleaseBy:1];
    [self.adminUserPassword observerCountReleaseBy:1];
}


#pragma mark - Properties

- (SWExpression*)login
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWExpression*)enableAutoLogin
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWExpression*)adminUserPassword
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWValue*)currentUserName
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWValue*)currentUserLevel
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}

- (SWValue*)backgroundColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+5];
}

- (SWValue*)backgroundImage
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+6];
}

- (SWValue*)companyTitle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+7];
}

- (SWValue*)companyLogo
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+8];
}


#pragma mark - Private

- (void)_performLogin
{
    BOOL login = [self.login valueAsBool];

    // actua en el flanc de pujada de login
    if ( login == NO )
        return;
    
    // no volem presentar-lo dues vegades
    if ( _isPerformingLogin )
        return;

    _isPerformingLogin = YES;
    
//    SWLoginWindowControllerP *loginWindow = [[SWLoginWindowControllerP alloc] initWithUsersManager:self];
//    [loginWindow setDelegate:self];
//    [loginWindow setCancelForbiden:_isPerformingForcedLogin];
//    [loginWindow showAnimated:YES];
    
     _loginWindow = [[SWLoginWindowControllerP alloc] initWithUsersManager:self];
    [_loginWindow setDelegate:self];
    [_loginWindow setCancelForbiden:_isPerformingForcedLogin];
    [_loginWindow showAnimated:YES completion:nil];
}


- (void)_performDismissLogin
{
    if ( _loginWindow )
    {
        SWProjectUser *user = [_docModel selectedProjectUser];
        [_docModel selectProjectUser:user];
        [_loginWindow dismiss];
    }
}


#pragma mark - SWLoginViewControllerDelegate

- (void)loginWindowDidClose:(SWLoginWindowControllerBase *)sender
{
    _isPerformingLogin = NO;
    _loginWindow = nil;
}




#pragma mark - SWValueHolder


- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.login )
    {
        [self _performLogin];
    }
}


- (void)valuePerformRetain:(SWValue *)value
{
    if( _active.currentUserLevel == 0 && value == self.currentUserLevel ) _active.currentUserLevel = 1;
    [self _maybeStartObservingCurrentUserLevel];
    
    if( _active.currentUserName == 0 && value == self.currentUserName ) _active.currentUserName = 1;
    [self _maybeStartObservingCurrentUserName];
}


- (void)valuePerformRelease:(SWValue *)value
{
    if(_active.currentUserLevel && value == self.currentUserLevel) _active.currentUserLevel = 0;
    [self _maybeStopObservingCurrentUserLevel];
    
    if( _active.currentUserName && value == self.currentUserName ) _active.currentUserName = 0;
    [self _maybeStopObservingCurrentUserName];
}



#pragma mark - current project user

- (void)updateCurrentProjectUserIfNeeded
{
    if ( _isObservingLevel )
        [self _updateCurrentUserLevelExpression];
    
    if ( _isObservingUserName )
        [self _updateCurrentUserNameExpression];
}

#pragma mark - external login

- (void)performForcedLogin
{
    SWExpression *login = self.login;
    _isPerformingForcedLogin = YES;
    [login evalWithConstantValue:1];
    [login evalWithConstantValue:0];
    _isPerformingForcedLogin = NO;
}


- (void)performOptionalLogin
{
    SWExpression *login = self.login;
    [login evalWithConstantValue:1];
    [login evalWithConstantValue:0];
}


- (void)performDismissLogin
{
    [self _performDismissLogin];
}

#pragma mark - current user level

- (void)_updateCurrentUserLevelExpression
{
    SWProjectUser *user = [_docModel selectedProjectUser];
    NSInteger level = user!=nil ? [user.userL valueAsInteger] : 9;
    [self.currentUserLevel evalWithDouble:(double)level];
}

- (void)_maybeStartObservingCurrentUserLevel
{
    if ( !(_active.currentUserLevel ) ) return;
    if ( !_isObservingLevel )
    {
        [self _updateCurrentUserLevelExpression];
        _isObservingLevel = YES;
    }
}

- (void)_maybeStopObservingCurrentUserLevel
{
    if ( _active.currentUserLevel) return;
    if ( _isObservingLevel )
    {
        _isObservingLevel = NO;
    }
}


#pragma mark - current user name

- (void)_updateCurrentUserNameExpression
{
    SWProjectUser *user = [_docModel selectedProjectUser];
    NSString *userName = user!=nil ? [user.userName valueAsString] : @"";
    [self.currentUserName evalWithString:userName];
}


- (void)_maybeStartObservingCurrentUserName
{
    if ( !(_active.currentUserName ) ) return;
    if ( !_isObservingUserName )
    {
        [self _updateCurrentUserNameExpression];
        _isObservingUserName = YES;
    }
}


- (void)_maybeStopObservingCurrentUserName
{
    if ( _active.currentUserName ) return;
    if ( _isObservingUserName )
    {
        _isObservingUserName = NO;
    }
}


#pragma mark - Symbolic Coding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        SWExpression *exp = [decoder decodeExpressionForKey:@"login"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+0 withObject:exp];
        
        SWExpression *exp1 = [decoder decodeExpressionForKey:@"enableAutoLogin"];
        if ( exp1 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+1 withObject:exp1];
        
//        SWValue *va0 = [decoder decodeValueForKey:@"currentUserName"];
//        if ( va0 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+1 withObject:va0];
//        
//        SWValue *va1 = [decoder decodeValueForKey:@"currentUserLevel"];
//        if ( va1 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+2 withObject:va1];
        
        SWExpression *exp2 = [decoder decodeExpressionForKey:@"adminUserPassword"];
        if ( exp2 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+2 withObject:exp2];
        
        SWValue *va5 = [decoder decodeValueForKey:@"backgroundColor"];
        if ( va5 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+5 withObject:va5];
        
        SWValue *va6 = [decoder decodeValueForKey:@"backgroundImage"];
        if ( va6 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+6 withObject:va6];
        
        SWValue *va7 = [decoder decodeValueForKey:@"companyTitle"];
        if ( va7 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+7 withObject:va7];
        
        SWValue *va8 = [decoder decodeValueForKey:@"companyLogo"];
        if ( va8 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+8 withObject:va8];
        
        [self _observerRetainAfterDecode];
        
    }
    return self;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder];

    [encoder encodeValue:self.login forKey:@"login"];
    [encoder encodeValue:self.enableAutoLogin forKey:@"enableAutoLogin"];
    [encoder encodeValue:self.adminUserPassword forKey:@"adminUserPassword"];
    [encoder encodeValue:self.backgroundColor forKey:@"backgroundColor"];
    [encoder encodeValue:self.backgroundImage forKey:@"backgroundImage"];
    [encoder encodeValue:self.companyTitle forKey:@"companyTitle"];
    [encoder encodeValue:self.companyLogo forKey:@"companyLogo"];
    
//    [encoder encodeValue:self.currentUserName forKey:@"currentUserName"];
//    [encoder encodeValue:self.currentUserLevel forKey:@"currentUserLevel"];
}





@end
