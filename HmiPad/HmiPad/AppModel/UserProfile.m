//
//  UserProfile.m
//  HmiPad
//
//  Created by joan on 12/08/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "UserProfile.h"

//------------------------------------------------------------------------------------
// Objecte que conté un perfil de usuari
//
@implementation UserProfile

@synthesize username = _username;
@synthesize email = _email;
@synthesize password = _password;
@synthesize userId = _userId;
@synthesize token = _token;
@synthesize isLocal = _isLocal;
//@synthesize enabled = _enabled;
@synthesize level = _level;
//@synthesize updated = _updated;
//@synthesize unlocked = _unlocked;
@synthesize integrator = _integrator;

//------------------------------------------------------------------------------------
- (void)dealloc
{
}

- (id)initWithUserName:(NSString*)user
{
    self = [super init];
    if ( self )
    {
        _username = user;
        _password = @"";
        _email = @"";
        _token = @"";
        _level = 9;
    }
    return self;
}

//------------------------------------------------------------------------------------
- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init] ;
    _username = [decoder decodeObject];
    _email = [decoder decodeObject];
    _password = [decoder decodeObject];
    _userId = [decoder decodeInt];
    _token = [decoder decodeObject];
    _isLocal = [decoder decodeInt];
    _enabled = [decoder decodeInt];
    _level = [decoder decodeInt];
    _updated = [decoder decodeInt];
    _migrated = [decoder decodeInt];
    _integrator = [decoder decodeInt];
    return self ;
}

//------------------------------------------------------------------------------------
- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    //[super encodeWithCoder:encoder] commented out because NSObject does not implement NSCoding
    [encoder encodeObject:_username];
    [encoder encodeObject:_email];
    [encoder encodeObject:_password];
    [encoder encodeInt:_userId];
    [encoder encodeObject:_token];
    [encoder encodeInt:_isLocal ];
    [encoder encodeInt:_enabled];
    [encoder encodeInt:_level];
    [encoder encodeInt:_updated];
    [encoder encodeInt:_migrated];
    [encoder encodeInt:_integrator];
}

- (UserProfile*)getProfileCopy
{
    UserProfile *profileCopy = [[UserProfile alloc] initWithUserName:nil];
    [profileCopy copyWithProfile:self];
    return profileCopy;
}

- (void)copyWithProfile:(UserProfile*)aProfile
{
    NSAssert( aProfile != nil, @"cucut" );
    _username = [aProfile->_username copy];
    _email = [aProfile->_email copy];
    _password = [aProfile->_password copy];
    _userId = aProfile->_userId;
    _token = aProfile->_token;
    _isLocal = aProfile->_isLocal;
    _enabled = aProfile->_enabled;
    _level = aProfile->_level;
    _updated = aProfile->_updated;
    _migrated = aProfile->_migrated;
    _integrator = aProfile->_integrator;
}

- (BOOL)isEqual:(id)object
{
    if ( object == nil )
        return NO;
    
    UserProfile *profile = object;
    
    if ( _userId==0 || profile->_userId==0 )
    {
        return [_username isEqualToString:profile->_username];
    }
    
    return ( _userId == profile->_userId );
    
    //return [_username isEqualToString:profile->_username];
}

- (NSUInteger)hash
{
    return 0;
////    return [_username hash];
//    
//    if ( _userId == 0 ) return [_username hash];
//    return _userId;
}





//------------------------------------------------------------------------------------
- (void)print
{
    NSLog( @"UserProfile print:" );
    NSLog( @"username: %@", _username );
    NSLog( @"email: %@", _email );
    NSLog( @"password: %@", _password );
    NSLog( @"userId:%u", (unsigned int)_userId );
    NSLog( @"token:%@", _token );
    NSLog( @"enabled: %d", _enabled );
    NSLog( @"level: %d", _level );
    NSLog( @"migrated: %d", _migrated );
    NSLog( @"updated: %d", _updated );
    NSLog( @"integrator: %d", _integrator );
}


@end

