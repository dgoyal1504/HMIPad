//
//  NSData+SWCrypto.m
//  HmiPad
//
//  Created by Joan on 22/09/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "NSData+CommonCrypto.h"
#import "NSData+SWCrypto.h"

//#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"

@implementation NSData (SWCrypto)

//+ (NSString*)defaultEncryptionKey
//{
//    NSString *key = [usersModel() identifierForApp];
//    
//    NSInteger start = [key characterAtIndex:0] % key.length;
//    key = [key stringByAppendingString:key];
//    key = [key substringFromIndex:start];
//    return key;
//}

//- (NSData*)encrypt
//{
//    NSString *key = [NSData defaultEncryptionKey];
//    NSError *error = nil;
//    NSData *data = [self AES256EncryptedDataUsingKey:key error:&error];
//    if (error)
//    {
//        NSLog(@"%@", [error localizedDescription]);
//    }
//    return data;
//}
//
//- (NSData*)decrypt
//{
//    NSString *key = [NSData defaultEncryptionKey];
//    NSError *error = nil;
//    NSData *data = [self decryptedAES256DataUsingKey:key error:&error];
//    if (error)
//    {
//        NSLog(@"%@", [error localizedDescription]);
//    }
//    return data;
//}


static NSString *mangle(NSString *key)
{
    NSInteger start = [key characterAtIndex:0] % key.length;
    key = [key stringByAppendingString:key];
    key = [key substringFromIndex:start];
    return key;
}

- (NSData*)encrypt
{
    return [self encryptWithKey:[cloudKitUser() identifierForApp]];
}

- (NSData*)decrypt
{
    return [self decryptWithKey:[cloudKitUser() identifierForApp]];
}


- (NSData*)encryptWithKey:(NSString*)key
{
    NSAssert(key.length>0, @"");

    key = mangle(key);
    
    NSError *error = nil;
    NSData *data = [self AES256EncryptedDataUsingKey:key error:&error];
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    return data;
}

- (NSData*)decryptWithKey:(NSString*)key
{
    NSAssert(key.length>0, @"");

    key = mangle(key);

    NSError *error = nil;
    NSData *data = [self decryptedAES256DataUsingKey:key error:&error];
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    return data;
}








@end
