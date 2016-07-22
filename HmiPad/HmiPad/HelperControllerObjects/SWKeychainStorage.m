//
//  SWKeychainStorage.m
//  HmiPad
//
//  Created by Joan on 04/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWKeychainStorage.h"
#import <Security/Security.h>

@implementation SWKeychainStorage



// -------------------------------------------------------------------------
-(NSString *)getSecureValueForKey:(NSString *)key
{
    /*

     Return a value from the keychain

     */

    // Retrieve a value from the keychain
    CFDictionaryRef result;
    NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge id)kSecClass, kSecAttrAccount, kSecReturnAttributes, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge id)kSecClassGenericPassword, key, kCFBooleanTrue, nil];
    NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];

    // Check if the value was found
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query,  (CFTypeRef*)(&result));
   
    if (status != noErr)
    {
        // Value not found
        return nil;
    }
    else
    {
        // Value was found so return it
        NSString *value = (NSString *) [(__bridge NSDictionary*)result objectForKey: (__bridge id)kSecAttrGeneric];
        return value;
    }
}




// -------------------------------------------------------------------------
-(bool)storeSecureValue:(NSString *)value forKey:(NSString *)key
{
    /*

     Store a value in the keychain

     */

    // Get the existing value for the key
    NSString *existingValue = [self getSecureValueForKey:key];

    // Check if a value already exists for this key
    OSStatus status;
    if (existingValue)
    {
        // Value already exists, so update it
        NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *)kSecClass, kSecAttrAccount, nil];
        NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *)kSecClassGenericPassword, key, nil];
        NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObject:value forKey: (__bridge NSString *) kSecAttrGeneric]);
    }
    else
    {
 // Value does not exist, so add it
        NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *)kSecClass, kSecAttrAccount, kSecAttrGeneric, nil];
        NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *)kSecClassGenericPassword, key, value, nil];
        NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
    }

    // Check if the value was stored
    if (status != noErr)
    {
        // Value was not stored
        return false;
    }
    else
    {
        // Value was stored
        return true;
    }
}















@end
