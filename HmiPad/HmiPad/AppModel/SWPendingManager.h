//
//  PendingManager.h
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <Foundation/Foundation.h>

//#import <StoreKit/StoreKit.h>
//
//#pragma mark SKProduct category
//
//@interface SKProduct(priceString)
//
//+ (BOOL)isQProduct:(NSString*)productIdentifier;
//- (BOOL)isQProduct;
//@property (nonatomic,readonly) NSString *priceString;
//
//@end

#pragma mark SWPendingIsReceipt

@interface SWPendingISReceipt : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *receiptID;
@property (nonatomic, retain) NSString *receipt64_;
@property (nonatomic, retain) NSString *projectUUID;
//@property (nonatomic, assign) UInt32 userID;
@property (nonatomic, retain) NSString *userUUID;

@end


#pragma mark SWPendingManager

@interface SWPendingManager : NSObject 

//- (NSArray*)pendingIASProducts;
- (void)setPendingProduct:(NSString*)product withProjectUUID:(NSString*)projectID withName:(NSString*)name userUUID:(NSString*)userUUID;

//- (BOOL)setPendingReceipt:(NSString*)receipt toPendingProduct:(NSString*)productID forUserID:(UInt32)userID;
- (BOOL)setPendingReceipt64:(NSString*)receipt64 withReceiptID:(NSString*)receiptID  toPendingProduct:(NSString*)productID forUserUUID:(NSString*)userUUID;

//- (SWPendingISReceipt *)pendingIsReceiptForReceipt64:(NSString*)receipt64;
//- (void)removePendingReceipt64:(NSString *)receipt64;
- (SWPendingISReceipt *)pendingIsReceiptForReceiptID:(NSString*)receiptID;
- (void)removePendingReceiptID:(NSString *)receiptID;


- (NSArray*)pendingISReceipts;
- (void)removeAllPendingReceipts;

- (BOOL)isWaitingActivationForProduct:(NSString*)product userUUID:(NSString*)userUUID;

- (void)prepareProduct:(NSString*)productID;
- (BOOL)isPreparingProduct:(NSString*)productID;
- (void)removePreparedProduct:(NSString*)productID;

@end


