//
//  AppFilesModelActivationCodes.m
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "AppModelActivationCodes.h"

#import "AppModelFilesEx.h"

//#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"

//#import "HMiPadServerAPIClient.h"

#import "SWPendingManager.h"
#import "SKProduct+priceString.h"


//#import "QuickCoder.h"
//#import "NSData+SWCrypto.h"


#define SWSupportLocalActivation 0



@interface AppModelActivationCodes()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    __weak AppModel *_filesModel;
    NSMutableArray *_observers; // List of observers
    NSArray *_productsArray;
    NSInteger _qProductsCount;
    SWPendingManager *_pendingManager;
    BOOL _isObservingTransactions;
    BOOL _waitingProductListing;
    BOOL _isProcessingReceipt;
}


@end



@implementation AppModelActivationCodes

- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _pendingManager = [[SWPendingManager alloc] init];
    }
    return self;
}


#pragma mark Model Notification

- (void)_notifyDidGetProductsListingAndCanMakePayments:(BOOL)yesWeCan
{
    for ( id<AppModelActivationCodesObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didGetProductsListingAndCanMakePayments:)])
        {
            [observer appFilesModel:self didGetProductsListingAndCanMakePayments:yesWeCan];
        }
    }
}

- (void)_notifyProvideContentForProduct:(NSString*)productId activation:(NSString*)activationId success:(BOOL)success
{
    for ( id<AppModelActivationCodesObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didProvideContentForProduct:activation:success:)])
        {
            [observer appFilesModel:self didProvideContentForProduct:productId activation:activationId success:success];
        }
    }
}

- (void)_notifyFinishTransaction:(BOOL)success
{
    for ( id<AppModelActivationCodesObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didFinishTransactionWithSuccess:)])
        {
            [observer appFilesModel:self didFinishTransactionWithSuccess:success];
        }
    }
}


#pragma mark - File Document observation

- (void)addObserver:(id<AppModelActivationCodesObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<AppModelActivationCodesObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}


#pragma mark Products

////---------------------------------------------------------------------------------------------
//- (void)subscribeToIntegratorService
//{
//    [self _doSubscribe];
//}



- (NSInteger)qProductsCount
{
    if ( _productsArray == nil ) return 0;
    return _qProductsCount;
}


- (NSArray*)productsMDArray
{
    if ( _productsArray == nil )
    {        
        [self _listProductsMD];
    }

    NSArray *result = _productsArray;
    if ( result == nil )
    {
        result = [NSArray array];
    }

    return result;
}

- (void)resetProductsMDArray
{
    _productsArray = nil;
    _qProductsCount = 0;
}



//- (NSArray*)pendingProductIds
//{
//    return [self _pendingProductIds];
//}

- (BOOL)isPreparingProduct:(NSString*)product
{
    return [_pendingManager isPreparingProduct:product];
}


- (BOOL)isWaitingReceiptForProduct:(NSString*)productId
{
    return [self _isProductWaitingReceipt:productId];
}

- (BOOL)isWaitingActivationForProduct:(NSString *)product userUUID:(NSString*)userUUID
{
    return [_pendingManager isWaitingActivationForProduct:product userUUID:userUUID];
}


- (void)_delayedNotifyCanNotMakePayments
{
    [self _notifyDidGetProductsListingAndCanMakePayments:NO];

}

- (void)_listProductsMD
{
    if ( [SKPaymentQueue canMakePayments])
    {
        if ( _waitingProductListing )
            return;

        //[self _processPendingISReceipts];
    
        _waitingProductListing = YES;
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:
                kMyFeatureIdentifierP_001,
                kMyFeatureIdentifierP_005,
                kMyFeatureIdentifierP_010,
                //kMyFeatureIdentifierP_100,
#if SWSupportLocalActivation
                kMyFeatureIdentifierQ_001,
#endif
                nil]];
        request.delegate = self;      // cridara productsRequest:didReceiveResponse
        [request start];
    }
    else
    {
        // Warn the user that purchases are disabled.
        [self performSelector:@selector(_delayedNotifyCanNotMakePayments) withObject:nil afterDelay:0.0];
    }
    
}


- (BOOL)_isProductWaitingReceipt:(NSString*)product;
{
    SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
    for ( SKPaymentTransaction *transaction in paymentQueue.transactions )
    {
        SKPaymentTransactionState state = transaction.transactionState;
        if ( state == SKPaymentTransactionStatePurchasing )
        {
            NSString *productId = transaction.payment.productIdentifier;
            if ( [productId isEqualToString:product] )
                return YES;
        }
    }
    return NO;
}




//- (NSArray*)_pendingProductIds
//{
//    SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
//    NSMutableArray *products = [NSMutableArray array];
//    for ( SKPaymentTransaction *transaction in paymentQueue.transactions )
//    {
//        SKPaymentTransactionState state = transaction.transactionState;
//        if ( state == SKPaymentTransactionStatePurchasing )
//        {
//            NSString *productId = transaction.payment.productIdentifier;
//            [products addObject:productId];
//        }
//    }
//    return products;
//}



#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _waitingProductListing = NO;
    //_productsArray = response.products;

    NSLog1( @"myProducts : %@", response.products );
    NSLog1( @"myInvalidProducts : %@", response.invalidProductIdentifiers);
    
    NSMutableArray *qProducts = [NSMutableArray array];
    NSMutableArray *dProducts = [NSMutableArray array];
    
    for ( SKProduct *skProduct in response.products )  // <--- Array de SKProducts
    {
        if ( skProduct.isQProduct ) [qProducts addObject:skProduct];
        else [dProducts addObject:skProduct];
    }
    
    _qProductsCount = qProducts.count;
    _productsArray = [qProducts arrayByAddingObjectsFromArray:dProducts];    // qProducts son els primers
    
    [self _notifyDidGetProductsListingAndCanMakePayments:YES];
    
    // Populate your UI from the products list.
    // Save a reference to the products list.
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    _completeErrorWithError_title( error, NSLocalizedString(@"Apple Store", nil) );
    _waitingProductListing = NO;
}

- (void)requestDidFinish:(SKRequest *)request
{
    _waitingProductListing = NO;
}


#pragma mark Payment / Activations


- (void)beginTransactionObservations
{
    if ( _isObservingTransactions == NO )
    {
        _isObservingTransactions = YES;
        [self _addTransactionObserver];
        
        // [self _processPendingISReceipts];     // Ho he tret per Cloud Kit, se suposa que Apple fa correctament les transaccions
        
    }
}


- (void)endTransactionObservations
{
    if ( _isObservingTransactions )
    {
        _isObservingTransactions = NO;
        [self _removeTransactionObserver];
    }
}




- (void)_addTransactionObserver
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self]; // cridara paymentQueue:updatedTransactions: si cal
}

- (void)_removeTransactionObserver
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)addPaymentForProduct:(SKProduct*)product forProjectWithUUID:(NSString*)uuid withActivationCodeName:(NSString*)name
{
    [self _addPaymentForProduct:product forProjectWithUUID:uuid withName:name];
}

#pragma mark - no ck
#if !UseCloudKit
- (void)_addPaymentForProduct:(SKProduct*)product forProjectWithUUID:(NSString*)uuid withName:(NSString*)name
{
    NSString *productId = product.productIdentifier;
    if ( [self _isProductWaitingReceipt:productId] )
        return;
    
    [_pendingManager prepareProduct:productId];
    
    UserProfile *profile = [usersModel() currentUserProfile];
    
    void (^payBlock)() = ^()
    {
        //[_pendingManager addPendingIASProduct:productId withProjectUUID:uuid withName:name profile:profile];
        //SKPayment *payment = [SKPayment paymentWithProduct:product];
        //[[SKPaymentQueue defaultQueue] addPayment:payment];    // fara que la paymentQueue cridi paymentQueue:updatedTransactions
        
        [_pendingManager setPendingProduct:productId withProjectUUID:uuid withName:name userID:profile.userId];
        
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        [payment setApplicationUsername:[NSString stringWithFormat:@"%u", (unsigned int)profile.userId]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];    // fara que la paymentQueue cridi paymentQueue:updatedTransactions
    };
    
    if ( [SKProduct isQProduct:productId] )
    {
        [_filesModel.files _primitiveUploadProjectWithFileName:@"Project" uuid:uuid fileData:nil thumbnailData:nil fileSize:0 profile:profile
        completion:^(BOOL success, NSString *projectUUID)
        {
            if ( success ) payBlock();
            [_pendingManager removePreparedProduct:productId];
        }];
    }
    else
    {
        payBlock();
        [_pendingManager removePreparedProduct:productId];
    }
}
#endif
#pragma mark endif

#pragma mark ck
#if UseCloudKit
- (void)_addPaymentForProduct:(SKProduct*)product forProjectWithUUID:(NSString*)uuid withName:(NSString*)name
{
    NSString *productId = product.productIdentifier;
    if ( [self _isProductWaitingReceipt:productId] )
        return;
    
    [_pendingManager prepareProduct:productId];
    
    NSString *userUUID = [cloudKitUser() currentUserUUID];
    
    void (^payBlock)() = ^()
    {
        [_pendingManager setPendingProduct:productId withProjectUUID:uuid withName:name userUUID:userUUID];
        
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        [payment setApplicationUsername:userUUID];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];    // fara que la paymentQueue cridi paymentQueue:updatedTransactions
    };
    
    if ( [SKProduct isQProduct:productId] )
    {
//        [_filesModel.files _primitiveUploadProjectWithFileName:@"Project" uuid:uuid fileData:nil thumbnailData:nil fileSize:0 profile:profile
//        completion:^(BOOL success, NSString *projectUUID)
//        {
//            if ( success ) payBlock();
//            [_pendingManager removePreparedProduct:productId];
//        }];
    }
    else
    {
        payBlock();
        [_pendingManager removePreparedProduct:productId];
    }
}
#endif
#pragma mark endif



#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        SKPaymentTransactionState state = transaction.transactionState;
        switch (state)
        {
            case SKPaymentTransactionStatePurchased:
                [self _completeTransaction:transaction paymentQueue:queue];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self _restoreTransaction:transaction paymentQueue:queue];
                break;
                
            case SKPaymentTransactionStateFailed:
                /////////////////////////////////////////////////////////////////////
                //[self _completeTransaction:transaction paymentQueue:queue];
                [self _failedTransaction:transaction paymentQueue:queue];
                break;

            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:
                break;
        }
        
        if ( state != SKPaymentTransactionStatePurchasing )
        {
            // Remove the transaction from the payment queue.
            //[queue finishTransaction:transaction];
            
            // remove the product identifier from our list ( NOT!)
            //
            // aparentment si iTunes demana la revisio dels 'purchasing terms' es cancel.la la transacció
            // (SKPaymentTransactionStateFailed amb SKErrorPaymentCancelled)
            // eventualment la transaccio es pot tornar a activar i encara podem rebre un SKPaymentTransactionStatePurchased
            // (amb previ SKPaymentTransactionStatePurchasing?) sobre la mateixa transacció. Si eliminem el IASProduct
            // aqui perdem qualsevol rastre de que hi ha una transaccio pendent. Per tant deixem el producte. La consequencia es que
            // si la cancelacio es definitiva quedara com a pendingIASProduct, pero no es problema perque quan hi hagi una compra nova
            // ja es cambiara per el bo
            
            // Deixem aquestes linees comentades !!
            //    NSString *productID = transaction.payment.productIdentifier;
            //    [_pendingManager removePendingIASProduct:productID];
        
            // avisa als observadors
          //  BOOL success = (state!=SKPaymentTransactionStateFailed && transaction.error.code != SKErrorPaymentCancelled);
          //  [self _notifyFinishTransaction:success];
        }
    }
}


- (void)processPendingreceipts
{
     [self _processPendingISReceipts];  // Ho he tret per Cloud Kit, se suposa que Apple fa correctament les transaccions
}

- (void)removeAllPendingReceipts
{
    NSArray *pendingReceipts = [_pendingManager pendingISReceipts];
    if ( pendingReceipts.count == 0 )
        return;

    NSString *title = NSLocalizedString(@"Removing Receipts", nil);
    NSString *message = NSLocalizedString(@"Any pending receipts will be removed from the local records. This may lead to loosing activation codes after having payed for them. Please only do so upon request of our support team. Do you still want to proceed?", nil);

    _errorWithLocalizedDescription_title_resultBlock(message, title, ^(NSError *error)
    {
        if ( error == nil )
            [_pendingManager removeAllPendingReceipts];
    });
}


- (void)_completeTransaction:(SKPaymentTransaction *)transaction paymentQueue:(SKPaymentQueue*)queue
{
    // Your application should implement these two methods.
    BOOL done = [self _recordTransaction:transaction paymentQueue:queue];
    if ( done ) [self _provideContent:transaction paymentQueue:queue];
    
    // Donem per finalitzada la transacció immediatament i en tots els casos, perque des del punt de vista de in app purchase no podem fer res mes,
    // a partir d'ara es responsabilitat nostra que el codi d'activacio es doni realment
    [self _finalizeTransaction:transaction paymentQueue:queue withSuccess:YES];
}

- (void)_restoreTransaction:(SKPaymentTransaction *)transaction paymentQueue:(SKPaymentQueue*)queue
{
    BOOL done = [self _recordTransaction:transaction paymentQueue:queue];
    if ( done ) [self _provideContent:transaction paymentQueue:queue];
    
    // Donem per finalitzada la transacció immediatament i en tots els casos, perque des del punt de vista de in app purchase no podem fer res mes,
    // a partir d'ara es responsabilitat  nostra que el codi d'activacio es doni realment
    [self _finalizeTransaction:transaction paymentQueue:queue withSuccess:YES];
}


//- (void)_failedTransactionV:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue
//{
//    NSError *error = transaction.error;
//    NSLog( @"Transaction Error: %@", error );
//    
//    BOOL isError = (error.code != SKErrorPaymentCancelled);
//    
//    if ( isError)
//    {
//        // Optionally, display an error here.
//        NSString *title = NSLocalizedString(@"Transaction Failed", nil);
//        NSString *format = NSLocalizedString(@"Transaction failed before being registered to the server.\nReason: \"%@\".\nNo purchase was made", nil);
//        NSString *description = [NSString stringWithFormat:format, error.localizedDescription];
//        _errorWithLocalizedDescription_title(description,title);
//    }
//    
//    [self _finalizeTransaction:transaction paymentQueue:queue completed:NO withSuccess:!isError];
//}

- (void)_failedTransaction:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue
{
    NSError *error = transaction.error;
    NSLog( @"Transaction Error: %@", error );
    
    BOOL isError = (error.code != SKErrorPaymentCancelled);
    
    if ( isError)
    {
        // Optionally, display an error here.
        NSString *title = NSLocalizedString(@"Transaction Failed", nil);
        NSString *format = NSLocalizedString(@"Transaction failed before being registered to the server.\nReason: \"%@\".\nNo purchase was made", nil);
        NSString *description = [NSString stringWithFormat:format, error.localizedDescription];
        _errorWithLocalizedDescription_title(description,title);
    }
    
    // donem per finalizada la transaccio
    [self _finalizeTransaction:transaction paymentQueue:queue withSuccess:!isError];
}




#pragma mark activation codes (private)


- (BOOL)_recordTransaction:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue
{
    SKPayment *payment = transaction.payment;
    NSString *productID = payment.productIdentifier;
    
//    NSString *applicationUser = payment.applicationUsername;
//    NSString *userUUID = applicationUser;
    
    NSString *userUUID = [cloudKitUser() currentUserUUID];               // iOS8
    NSString *transactionID = transaction.transactionIdentifier;
    
    NSString *base64Receipt = @"";
    
    //[_pendingManager setPendingReceipt:base64Receipt toPendingProduct:productID forUserID:userID];
    BOOL done = [_pendingManager setPendingReceipt64:base64Receipt withReceiptID:transactionID toPendingProduct:productID forUserUUID:userUUID];
    
    
    if ( done == NO )
    {
        // aqui si no s'ha pogut registrar, pot ser per canvi de usuari.
        [self _alertActivationNotDeliveredWrongUser];
    }
    
    return done;
    
}

//- (void)_provideContentV:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue
//{
//    NSLog1( @"Provide Content " );
//    
//    NSString *transactionID = transaction.transactionIdentifier;
//    
//    [self _processPendingReceiptID:transactionID completion:^(BOOL success)
//    {
//        [self _finalizeTransaction:transaction paymentQueue:queue completed:success withSuccess:success];
//    }];
//}


- (void)_provideContent:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue
{
    NSLog1( @"Provide Content " );
    
    NSString *transactionID = transaction.transactionIdentifier;
    
    [self _processPendingReceiptID:transactionID completion:^(BOOL success)
    {
        [self _finalizeProvideContentWithTransactionID:transactionID withSuccess:success];
    }];
}


//
//- (void)_finalizeTransactionV:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue
//    completed:(BOOL) completed withSuccess:(BOOL)success
//{
//    if ( completed )
//    {
//        NSString *transactionID = transaction.transactionIdentifier;
//        [_pendingManager removePendingReceiptID:transactionID];
//    }
//    
//    NSString *transactionID = transaction.transactionIdentifier;
//    NSLog( @"transaction ID %@", transactionID );
//    
//    [queue finishTransaction:transaction];
//    [self _notifyFinishTransaction:success];
//}


- (void)_finalizeTransaction:(SKPaymentTransaction*)transaction paymentQueue:(SKPaymentQueue*)queue withSuccess:(BOOL)success
{
    NSString *transactionID = transaction.transactionIdentifier;
    NSLog( @"transaction ID %@", transactionID );
    
    [queue finishTransaction:transaction];
    [self _notifyFinishTransaction:success];
}


- (void)_finalizeProvideContentWithTransactionID:(NSString*)transactionID withSuccess:(BOOL)success
{
    [self _notifyFinishTransaction:success];
}




- (void)_primitiveProcessISReceipt:(SWPendingISReceipt*)isReceipt completion:(void(^)(BOOL))completion
{
    NSString *productID = isReceipt.productID;
        
    // el el cas de activacio local pujem primer un projecte dummy
    if ( [SKProduct isQProduct:productID] )
    {
//        NSString *projectID = [@"*" stringByAppendingString:isReceipt.projectUUID];
//        UserProfile *profile = [usersModel() profileForUserId:isReceipt.userID];
////           char *bytes = "empty";
////           NSData *data = [NSData dataWithBytes:&bytes length:strlen(bytes)];
//        NSData *data = nil;
//        [_filesModel.files _primitiveUploadProjectWithFileName:@"Project" uuid:projectID fileData:data thumbnailData:nil fileSize:0 profile:profile
//        completion:^(BOOL success, NSString *tprojectID)
//        {
//            if (success )
//            {
//                [self _createActivationForISReceipt:isReceipt completion:completion];
//            }
//            else
//            {
//                if ( completion )
//                    completion( NO );
//            }
//        }];
    }
        
    // si no, processem el producte directament
    else
    {
        [self _createActivationForISReceipt_ck:isReceipt completion:completion];
    }
}


//- (void)_processPendingReceipt:(NSString*)receipt64 completion:(void(^)(BOOL))completion
//{
//    SWPendingISReceipt *isReceipt = [_pendingManager pendingIsReceiptForReceipt:receipt64];
//    
//    [self _processISReceipt:isReceipt completion:completion];
//}



- (void)_processISReceipt:(SWPendingISReceipt*)isReceipt completion:(void(^)(BOOL success))completion
{
    if ( [isReceipt.receiptID length] > 0 )  // se suposa que lo contrari no passa mai
    {
        if ( _isProcessingReceipt )  // nomes processem un receipt a l'hora
        {
            completion( NO );
            return;
        }
        
        _isProcessingReceipt = YES;
        [self _primitiveProcessISReceipt:isReceipt completion:^(BOOL success )
        {
            _isProcessingReceipt = NO;
            if ( success )
            {
                [_pendingManager removePendingReceiptID:isReceipt.receiptID];
            }
            completion ( success );
        }];
    }
    else
    {
        completion(NO);  ////
    }
}


- (void)_processPendingReceiptID:(NSString*)receiptID completion:(void(^)(BOOL success))completion
{
    SWPendingISReceipt *isReceipt = [_pendingManager pendingIsReceiptForReceiptID:receiptID];
    
    [self _processISReceipt:isReceipt completion:completion];
}


- (void)_processPendingISReceipts
{
    NSArray *pendingReceipts = [_pendingManager pendingISReceipts];
    NSArray *pendingReceiptsCopy = [pendingReceipts copy];
    
//    __block BOOL done = YES;
    for ( SWPendingISReceipt *isReceipt in pendingReceiptsCopy)
    {
        [self _processISReceipt:isReceipt completion:^(BOOL success)  // nomes en processara un !
        {
            [self _notifyFinishTransaction:success];
        }];
    }
    
    
//        if ( [isReceipt.receiptID length] > 0 )
//        {
//            [self _processISReceipt:isReceipt completion:^(BOOL success)
//            {
//                if ( success )
//                {
//                    [_pendingManager removePendingReceiptID:isReceipt.receiptID];
//                }
//                done = done && success;
//            }];
//        }
    
//    [self _notifyFinishTransaction:done];
}



#pragma mark no ck
#if !UseCloudKit

- (void)_createActivationForISReceipt:(SWPendingISReceipt*)receipt completion:(void(^)(BOOL))completion
{
    
    NSString *base64Receipt = receipt.receipt64_;
    NSString *receiptID = receipt.receiptID;
    NSString *productID = receipt.productID;
    NSString *projectID = receipt.projectUUID;
    NSString *name = receipt.name;
    UInt32 userID = receipt.userID;
    
    if ( [SKProduct isQProduct:productID] )
    {
        projectID = [@"*" stringByAppendingString:projectID];
    }
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    UserProfile *profile = [usersModel() profileForUserId:userID];
    if ( profile == nil )
    {
        // si aquest usuari no hi es ho sentim molt pero eliminem el receip de la llista de pendents
        //[_pendingManager removePendingISReceipt:receipt.receipt64];
        if ( completion )
            completion( YES );
        
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"receipts/"];
    
//    NSDictionary *parameters = @
//    {
//        @"project_identifier":projectID,
//        @"signed_transaction_receipt":base64Receipt, /*[NSString stringWithFormat:@"%@", base64Receipt]*/
//        @"access_code_label":name,
//        @"is_sandbox":SWISSandBox?@"true":@"false",
//    };
    
        NSDictionary *parameters = @
    {
        @"transaction_id":receiptID,
        @"product_sku":productID,
        @"is_sandbox":SWISSandBox?@"true":@"false",
    
        @"signed_transaction_receipt":base64Receipt, /*[NSString stringWithFormat:@"%@", base64Receipt]*/
        @"project_identifier":projectID,
        @"access_code_label":name,
        
        //@"product_info":@"",
    };

    
//    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:profile.token parameters:parameters ];

    NSString *locationEnabled = @"Are you sure you want to delete the current project";
    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:profile.token locationEnabled:locationEnabled parameters:parameters ];
    LogRequest;
    LogBody;
    
    NSString *productId = receipt.productID;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        NSDictionary *responseDict = JSON;
        
    
        
//        uuid_t uuidBytes;
//        NSUUID *acuuid = [[NSUUID alloc] initWithUUIDString:accessCode];
//        [acuuid getUUIDBytes:uuidBytes];
//        NSData *data = [[NSData data] initWithBytes:uuidBytes length:sizeof(uuid_t)];
//        NSString *shortCode = [data base64Encoded];
//        NSLog1( @"ShortCode :%@", shortCode);
        
       // NSString *productId = _dict_objectForKey(responseDict, @"product");
        //NSString *transactionReceipt = _dict_objectForKey(responseDict, @"signed_transaction_receipt");
        
        NSString *activationCodeUrl = _dict_objectForKey(responseDict, @"access_code");
    
        NSString *activationCode = [activationCodeUrl lastPathComponent];
        
        BOOL success = YES;
        if ( activationCode == nil )
        {
            success = NO;
            [self _alertActivationNotDelivered];
        }
        else
        {
            //[_pendingManager removePendingISReceipt:transactionReceipt];
            [_filesModel.files _listRemoteFilesForCategory:kFileCategoryRemoteActivationCode];
            
            NSString *project_identifier = _dict_objectForKey(JSON, @"project_identifier");
            NSString *title = NSLocalizedString(@"Activation Code Creation", nil);
            NSString *format = NSLocalizedString(@"A New Activation Code was successfully generated for Project ID:\n%@", nil);
            NSString *message = [NSString stringWithFormat:format,project_identifier] ;
            _errorWithLocalizedDescription_title(message,title);  // no es un error pero fem servir el mateix
        }
        [self _notifyProvideContentForProduct:productId activation:activationCode success:YES];
        if ( completion ) completion( success );
        
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        [self _alertActivationNotDelivered];
        NSString *title = NSLocalizedString(@"Receipt Processing Error", nil );
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title];
        error = _completeErrorFromResponse_json_withError_title(response, JSON, error, title);
        [self _notifyProvideContentForProduct:productId activation:nil success:NO];
        if ( completion ) completion( NO );
    }];
}

#endif
#pragma mark endif

#pragma mark ck
#if UseCloudKit


static NSString *_generateAccessCode(int len)
{
    NSMutableString *accessCode = [NSMutableString string];

    NSString *charSet = @"ABCDEFGHJKLMNPQRSTUWXZYZabcdefghijkmnopqrstuvwxyz0123456789";  // atencio falten la 'I', 'O', 'l' per evitar confussions
    NSInteger charSetLen = charSet.length;
    
    for ( int i=0 ; i<len ; i++ )
    {
        int pickIndex = arc4random_uniform((int)charSetLen);
        NSString *pickChar = [charSet substringWithRange:NSMakeRange(pickIndex, 1)];
        [accessCode appendString:pickChar];
    }
    
    return [accessCode copy];
}




- (void)_createActivationForISReceipt_ck:(SWPendingISReceipt*)receipt completion:(void(^)(BOOL))completion
{
    NSString *receiptID = receipt.receiptID;
    
    // busca activacio amb el mateix receiptID
    [self _searchActivationForReceiptID:receiptID completion:^(BOOL success, CKRecord *record0)
    {
        if ( success == NO )
        {
            completion( NO );
            return;
        }
        
        // si una activacio amb el mateix receipID hi es, utilitza aquesta, si no hi en crea una de nova
        if ( record0 != nil )
        {
            [self _putActivationForISReceipt:receipt forRecord:record0 completion:completion];
            return;
        }
        
        [self _newActivationRecordCompletion:^(CKRecord *record)
        {
            if ( record != nil )
            {
                [record setObject:receiptID forKey:@"receiptID"];
                [self _putActivationForISReceipt:receipt forRecord:record completion:completion];
            }
            else
            {
                completion( NO );
            }
        }];
    }];
}


- (void)_searchActivationForReceiptID:(NSString *)receiptID completion:(void(^)(BOOL success, CKRecord *record))completion
{
    if ( receiptID.length == 0 )
    {
        completion( YES, nil );
        return;
    }

    NSString *recordType = @"Activations";
    NSArray *desiredKeys = @[@"identifier"];
    
    // receiptID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"receiptID", receiptID];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    queryOperation.desiredKeys = desiredKeys;
    
    void (^queryFinishBlock)(NSArray *, NSError *) = ^(NSArray *results, NSError *queryCompletionError)
    {
        if ( queryCompletionError == nil )
        {
            CKRecord *record = [results firstObject];
            completion( YES, record );
        }
        else
        {
            NSString *title = NSLocalizedString(@"Activation Code Error", nil);
            NSString *format = NSLocalizedString(@"Could not access activation codes database", nil);
            NSString *message = [NSString stringWithFormat:format, nil] ;
            _completeErrorFromCloudKitError_message_title(queryCompletionError, message, title);
            completion( NO, nil);
        }
    };
    
    NSMutableArray *results = [NSMutableArray array];
    [queryOperation setRecordFetchedBlock:^(CKRecord *ckRecord)
    {
        [results addObject:ckRecord];
    }];
    
    [queryOperation setQueryCompletionBlock:^(CKQueryCursor *cursor, NSError *queryCompletionError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            queryFinishBlock( results, queryCompletionError );
        });
    }];
    
    [[_filesModel ckDatabase] addOperation:queryOperation];
}



- (void)_newActivationRecordCompletion:(void(^)(CKRecord *record))completion
{
    NSString *recordType = @"Activations";
    CKRecord *record0 = [[CKRecord alloc] initWithRecordType:recordType];
   
    // identifier
    NSString *identifier = _generateAccessCode(12);
    [record0 setObject:identifier forKey:@"identifier"];

    NSArray *desiredKeys = @[@"identifier"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"identifier", identifier];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    queryOperation.desiredKeys = desiredKeys;
    
    void (^queryFinishBlock)(NSArray *, NSError *) = ^(NSArray *results, NSError *queryCompletionError)
    {
        if ( queryCompletionError == nil )
        {
            CKRecord *record = [results firstObject];
            if ( record == nil )
            {
                // si no l'em trobat tornem el nou
                completion( record0 );
                return;
            }
            // si l'hem trovat, en busquem un altre
            [self _newActivationRecordCompletion:completion];
        }
        else
        {
            // si no hem pogut accedir a la database tornem nil
            NSString *title = NSLocalizedString(@"Activation Code Error", nil);
            NSString *format = NSLocalizedString(@"Could not create a new unique activation code", nil);
            NSString *message = [NSString stringWithFormat:format, nil] ;
            _completeErrorFromCloudKitError_message_title(queryCompletionError, message, title);
            completion( nil );
        }
    };
    
    NSMutableArray *results = [NSMutableArray array];
    [queryOperation setRecordFetchedBlock:^(CKRecord *ckRecord)
    {
        [results addObject:ckRecord];
    }];
    
    [queryOperation setQueryCompletionBlock:^(CKQueryCursor *cursor, NSError *queryCompletionError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            queryFinishBlock( results, queryCompletionError );
        });
    }];
    
    [[_filesModel ckDatabase] addOperation:queryOperation];
}


// Creació de un codi d'activació
- (void)_putActivationForISReceipt:(SWPendingISReceipt*)receipt forRecord:(CKRecord*)record completion:(void(^)(BOOL))completion
{
    //NSString *base64Receipt = receipt.receipt64_;
    // NSString *receiptID = receipt.receiptID;
    NSString *productID = receipt.productID;
    NSString *projectID = receipt.projectUUID;
    NSString *name = receipt.name;
    NSString *ownerID = receipt.userUUID;
    
    if ( [SKProduct isQProduct:productID] )
    {
        projectID = [@"*" stringByAppendingString:projectID];
    }
    
    UserProfile *profile = [cloudKitUser() currentUserProfile];
//    if ( profile.isLocal )
//    {
//        // si aquest usuari no hi es ho sentim molt pero eliminem el receip de la llista de pendents
//        //[_pendingManager removePendingISReceipt:receipt.receipt64];
//        if ( completion )
//            completion( YES );
//        
//        return;
//    }
//    NSString *ownerIdentifier = profile.token;


    if ( profile.isLocal || ![profile.token isEqualToString:ownerID] )
    {
        [self _alertActivationNotDeliveredWrongUser];
        completion( NO );
        return;
    }

    NSString *ownerIdentifier = ownerID;
    
//    NSString *recordType = @"Activations";
//    NSString *recordName = _generateAccessCode(12);
//    
//    // record id
//    CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
//    CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType recordID:recordId];
//   
//    // identifier
//    [record setObject:recordName forKey:@"identifier"];
    
    // name
    [record setObject:name forKey:@"name"];
    
    // owner
    CKRecordID *ownerRecordId = [[CKRecordID alloc] initWithRecordName:ownerIdentifier];
    CKReference *owner = [[CKReference alloc] initWithRecordID:ownerRecordId action:CKReferenceActionDeleteSelf];
    [record setObject:owner forKey:@"owner"];
    
    // maxRedemptions
    NSInteger maxRedemptions = maxRedemptionsForProductIdentifier(productID);
    [record setObject:@(maxRedemptions) forKey:@"maxRedemptions"];
    
    // productSKU
    [record setObject:productID forKey:@"productSKU"];
    
    // productInfo
    [record setObject:nil forKey:@"productInfo"];
    
    // projectIdentifier
    [record setObject:projectID forKey:@"projectIdentifier"];
    
    // touchDate
    [record setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"touchDate"];
    

    CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:nil];
        
    [modifyOperation setSavePolicy:CKRecordSaveChangedKeys];
//    [modifyOperation setSavePolicy:CKRecordSaveAllKeys];
//    [modifyOperation setSavePolicy:CKRecordSaveIfServerRecordUnchanged];
    
    [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords,
        NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
    {
        //final end
        
        NSLog( @"final end: %@", operationError );
        dispatch_async(dispatch_get_main_queue(), ^
        {
            BOOL success = (operationError == nil);
        
            if ( operationError != nil )
            {
                [self _alertActivationNotDelivered];
//                NSString *title = NSLocalizedString(@"Activation Code Error", nil );
//                NSString *message = NSLocalizedString(@"Could not create Activation Code", nil );
//                _completeErrorFromCloudKitError_message_title(operationError, message, title);
                [self _notifyProvideContentForProduct:productID activation:nil success:NO];
            }
            else
            {
                NSString *title = NSLocalizedString(@"Activation Code Creation", nil);
                NSString *format = NSLocalizedString(@"A New Activation Code was successfully generated for Project ID:\n%@", nil);
                NSString *message = [NSString stringWithFormat:format,projectID] ;
                _errorWithLocalizedDescription_title(message, title); // no es un error pero fem servir el mateix
                
                CKRecord *theRecord = savedRecords.firstObject;
                NSString *activationCode = [theRecord objectForKey:@"identifier"];
                
                [_filesModel.files _listRemoteFilesForCategory:kFileCategoryRemoteActivationCode];
                [self _notifyProvideContentForProduct:productID activation:activationCode success:YES];
            }
            
            if ( completion ) completion( success );
        });
    }];

    [[_filesModel ckDatabase] addOperation:modifyOperation];
}

#endif
#pragma mark endif


- (void)_alertActivationNotDelivered
{
    NSString *title = NSLocalizedString(@"Activation Code Creation", nil);
    NSString *message = NSLocalizedString(@" \nAn Activation Code for a pending Purchase Receipt could not be processed. We are working to recover from this issue.\n\nPlease contact SweetWilliam Support for assistance", nil);
    _errorWithLocalizedDescription_title(message,title);
}

- (void)_alertActivationNotDeliveredWrongUser
{
    NSString *title = NSLocalizedString(@"Activation Code Creation", nil);
    NSString *message = NSLocalizedString(@" \nAn Activation Code for a pending Purchase Receipt could not be processed because a different user was logged in at the time of purchase.\n\nLog into the correct user to allow the purchase to be processed", nil);
    _errorWithLocalizedDescription_title(message,title);
}

//// Creació de un codi d'activació
//- (void)_processReceipt:(SWPendingISReceipt*)receipt
//{
//    
//    NSString *base64Receipt = receipt.receipt64;
//    NSString *productID = receipt.productID;
//    NSString *projectID = receipt.projectUUID;
//    NSString *name = receipt.name;
//    UInt32 userID = receipt.userID;
//    
//    if ( [SKProduct isQProduct:productID] )
//    {
//        projectID = [@"*" stringByAppendingString:projectID];
//    }
//    
//    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
//    
//    UserProfile *profile = [usersModel() profileForUserId:userID];
//    if ( profile == nil )
//    {
//        // si aquest usuari no hi es ho sentim molt pero eliminem el receip de la llista de pendents
//        [_pendingManager removePendingISReceipt:receipt.receipt64];
//        return;
//    }
//    
//    NSString *path = [NSString stringWithFormat:@"receipts/"];
//    
//    NSDictionary *parameters = @
//    {
//        @"project_identifier":projectID,
//        @"signed_transaction_receipt":base64Receipt, /*[NSString stringWithFormat:@"%@", base64Receipt]*/
//        @"access_code_label":name,
//        @"is_sandbox":SWISSandBox?@"true":@"false",
//    };
//    
//    NSURLRequest *trequest = [client requestWithMethod:@"POST" path:path token:profile.token parameters:parameters ];
//    LogRequest;
//    LogBody;
//    
//    NSString *productId = receipt.productID;
//    
//    [client enqueueRequest:trequest
//    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
//    {
//        LogSuccess;
//        NSDictionary *responseDict = JSON;
//        
//    
//        
////        uuid_t uuidBytes;
////        NSUUID *acuuid = [[NSUUID alloc] initWithUUIDString:accessCode];
////        [acuuid getUUIDBytes:uuidBytes];
////        NSData *data = [[NSData data] initWithBytes:uuidBytes length:sizeof(uuid_t)];
////        NSString *shortCode = [data base64Encoded];
////        NSLog1( @"ShortCode :%@", shortCode);
//        
//        //NSString *transactionReceipt = [responseDict objectForKey:@"signed_transaction_receipt"];
//       // NSString *productId = _dict_objectForKey(responseDict, @"product");
//        NSString *transactionReceipt = _dict_objectForKey(responseDict, @"signed_transaction_receipt");
//        NSString *activationCodeUrl = _dict_objectForKey(responseDict, @"access_code");
//    
//        NSString *activationCode = [activationCodeUrl lastPathComponent];
//        
//        BOOL success = YES;
//        if ( activationCode == nil )
//        {
//            success = NO;
//            NSString *title = NSLocalizedString(@"Activation Code Creation", nil);
//            NSString *message = NSLocalizedString(@"An Activation Code for a pending purchase receipt could not be processed. We are working to recover from this issue. Please contact us in case you need some assistance", nil);
//            _errorWithLocalizedDescription_title(message,title);
//        }
//        else
//        {
//            [_pendingManager removePendingISReceipt:transactionReceipt];
//            [self _listRemoteFilesForCategory:kFileCategoryRemoteActivationCode];
//            
//            NSString *project_identifier = _dict_objectForKey(JSON, @"project_identifier");
//            NSString *title = NSLocalizedString(@"Activation Code Creation", nil);
//            NSString *format = NSLocalizedString(@"A New Activation Code was successfully generated for Project ID:\n%@", nil);
//            NSString *message = [NSString stringWithFormat:format,project_identifier] ;
//            _errorWithLocalizedDescription_title(message,title);  // no es un error pero fem servir el mateix
//        }
//        [self _notifyProvideContentForProduct:productId activation:activationCode success:YES];
//        
//    }
//    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
//    {
//        LogFailure;
//        NSString *title = NSLocalizedString(@"Receipt Processing Error", nil );
//        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title];
//        error = _completeErrorFromResponse_json_withError_title(response, JSON, error, title);
//        [self _notifyProvideContentForProduct:nil activation:nil success:NO];
//    }];
//    
//}











@end
