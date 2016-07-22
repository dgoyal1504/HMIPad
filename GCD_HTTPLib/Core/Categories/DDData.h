#import <Foundation/Foundation.h>

@interface NSData (DDData)

- (NSData *)md5Digest;

- (NSData *)sha1Digest;

- (NSString *)hexStringValue;

+ (NSData*)dataWithHexString:(NSString*)hexString;

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

@end
