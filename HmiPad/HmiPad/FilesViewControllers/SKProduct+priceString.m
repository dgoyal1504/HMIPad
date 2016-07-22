//
//  SKProduct+priceString.m
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SKProduct+priceString.h"

NSString *kMyFeatureIdentifierQ_Prefix = @"Q";
NSString *kMyFeatureIdentifierQ_001 = @"Q0001_D0001";

NSString *kMyFeatureIdentifierP_001 = @"P0001_D0001";
NSString *kMyFeatureIdentifierP_005 = @"P0001_D0005";
NSString *kMyFeatureIdentifierP_010 = @"P0001_D0010";
//static NSString *kMyFeatureIdentifierP_100 = @"P0001_D0100";



@implementation SKProduct(priceString)

+ (BOOL)isQProduct:(NSString*)productIdentifier
{
//    BOOL isQProduct = [productIdentifier isEqualToString:kMyFeatureIdentifierQ_001];
    BOOL isQProduct = [productIdentifier hasPrefix:kMyFeatureIdentifierQ_Prefix];
    return isQProduct;
}

- (NSString*)priceString
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    
    return formattedString;
}

- (BOOL)isQProduct
{
    BOOL isQProduct = [[self class] isQProduct:self.productIdentifier];
    return isQProduct;
}

NSInteger maxRedemptionsForProductIdentifier( NSString* productId )
{
    if ( [productId isEqualToString:kMyFeatureIdentifierQ_001] ) return 1;
    if ( [productId isEqualToString:kMyFeatureIdentifierP_001] ) return 1;
    if ( [productId isEqualToString:kMyFeatureIdentifierP_005] ) return 5;
    if ( [productId isEqualToString:kMyFeatureIdentifierP_010] ) return 10;
    return 0;
}

@end
