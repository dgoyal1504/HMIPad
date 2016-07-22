//
//  SKProduct+priceString.h
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <StoreKit/StoreKit.h>

extern NSString *kMyFeatureIdentifierQ_Prefix;
extern NSString *kMyFeatureIdentifierQ_001;

extern NSString *kMyFeatureIdentifierP_001;
extern NSString *kMyFeatureIdentifierP_005;
extern NSString *kMyFeatureIdentifierP_010;
//extern NSString *kMyFeatureIdentifierP_100;

extern NSInteger maxRedemptionsForProductIdentifier( NSString* productId );

@interface SKProduct(priceString)

+ (BOOL)isQProduct:(NSString*)productIdentifier;
- (BOOL)isQProduct;
@property (nonatomic,readonly) NSString *priceString;


@end