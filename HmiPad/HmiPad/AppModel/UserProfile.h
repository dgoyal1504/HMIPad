//
//  UserProfile.h
//  HmiPad
//
//  Created by joan on 12/08/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickCoder.h"


// Objecte que conté un perfil de usuari
@interface UserProfile : NSObject<QuickCoding>
{
}

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) UInt32 userId;     // userID en el servidor, o be un dels especials per locals
@property (nonatomic, strong) NSString *token;
@property (nonatomic) BOOL isLocal;     // indica que es un usuari sense presencia al servidor (integrator, enduser)
@property (nonatomic) BOOL enabled;
@property (nonatomic) UInt8 level;
@property (nonatomic) BOOL updated;     // indica que esta actualitzat amb el servidor
@property (nonatomic) BOOL migrated;    // indica que s'ha executat la migracio per aquest usuari
@property (nonatomic) BOOL integrator;
- (UserProfile*)getProfileCopy;
- (void)copyWithProfile:(UserProfile*)aProfile;

- (id)initWithUserName:(NSString*)user;

-(void)print;
@end