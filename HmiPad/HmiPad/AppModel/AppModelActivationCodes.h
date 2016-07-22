//
//  AppFilesModelActivationCodes.h
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "AppModel.h"

@class SWPendingManager;
@class AppModelActivationCodes;

@protocol AppModelActivationCodesObserver<NSObject>

@optional

// products
- (void)appFilesModel:(AppModelActivationCodes*)appModelActivation didGetProductsListingAndCanMakePayments:(BOOL)yesWeCan;
- (void)appFilesModel:(AppModelActivationCodes*)appModelActivation didFinishTransactionWithSuccess:(BOOL)success;
- (void)appFilesModel:(AppModelActivationCodes*)appModelActivation didProvideContentForProduct:(NSString*)product activation:(NSString*)activationId success:(BOOL)success;

@end


@interface AppModelActivationCodes :NSObject  //<SKProductsRequestDelegate,SKPaymentTransactionObserver>
//{
//    __weak AppModel *_filesModel;
//    NSMutableArray *_observers; // List of observers
//    NSArray *_productsArray;
//    NSInteger _qProductsCount;
//    SWPendingManager *_pendingManager;
//    BOOL _isObservingTransactions;
//    BOOL _waitingProductListing;
//    BOOL _isProcessingReceipt;
//}

- (id)initWithLocalFilesModel:(AppModel*)filesModel;

- (void)addObserver:(id<AppModelActivationCodesObserver>)observer;
- (void)removeObserver:(id<AppModelActivationCodesObserver>)observer;

// Activation Codes
- (void)beginTransactionObservations;
- (void)endTransactionObservations;

- (NSArray*)productsMDArray;
- (NSInteger)qProductsCount;
- (void)resetProductsMDArray;
- (void)addPaymentForProduct:(SKProduct*)product forProjectWithUUID:(NSString*)uuid withActivationCodeName:(NSString*)name;
- (BOOL)isPreparingProduct:(NSString*)product;
- (BOOL)isWaitingReceiptForProduct:(NSString*)product;
- (BOOL)isWaitingActivationForProduct:(NSString*)product userUUID:(NSString*)userUUID;
- (void)processPendingreceipts;
- (void)removeAllPendingReceipts;

@end
