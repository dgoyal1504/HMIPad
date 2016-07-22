//
//  NSData+SWCrypto.h
//  HmiPad
//
//  Created by Joan on 22/09/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SWCrypto)

- (NSData*)encrypt;
- (NSData*)decrypt;

- (NSData*)encryptWithKey:(NSString*)key;
- (NSData*)decryptWithKey:(NSString*)key;

@end
