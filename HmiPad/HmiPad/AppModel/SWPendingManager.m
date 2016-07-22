//
//  AppFilesModel+PendingManager.m
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWPendingManager.h"

#import "AppModelFilePaths.h"

#import "QuickCoder.h"




@interface SWPendingISReceipt()<QuickCoding>
@end

@implementation SWPendingISReceipt

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if ( self )
    {
        _name = [decoder decodeObject];
        _receipt64_ = [decoder decodeObject];
        _productID = [decoder decodeObject];
        _receiptID = [decoder decodeObject];
        _projectUUID = [decoder decodeObject];
        //_userID = [decoder decodeInt];
        _userUUID = [decoder decodeObject];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_name];
    [encoder encodeObject:_receipt64_];
    [encoder encodeObject:_productID];
    [encoder encodeObject:_receiptID];
    [encoder encodeObject:_projectUUID];
//    [encoder encodeInt:_userID];
    [encoder encodeObject:_userUUID];
}

@end



@implementation SWPendingManager
{
    NSMutableSet *_preparingProducts;  // no es codifica
//    NSMutableArray *_pendingIASProducts;
    NSMutableArray *_pendingISReceipts;
}


- (id)init
{
    self = [super init];
    if ( self )
    {
        _preparingProducts = [NSMutableSet set];
    }
    return self;
}


- (NSString *)_pendingStoreObjectsFilePath
{
    NSString *rootPath = [filesModel().filePaths internalFilesDirectory];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"store.swq"];
    return filePath ;
}


- (BOOL)_save
{
    NSString *fileName = [self _pendingStoreObjectsFilePath];
    if ( fileName != nil )
    {
        NSMutableData *dataArchive = [NSMutableData data];
        
        QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:dataArchive version:SWVersion];
//        [archiver encodeObject:_pendingIASProducts];
        [archiver encodeObject:_pendingISReceipts];
        [archiver finishEncoding];
    
        BOOL didWrite = [dataArchive writeToFile:fileName options:NSAtomicWrite error:nil] ;
        if ( didWrite )
        {
            return YES;
        }
    }
    
    return NO;
}


- (void)_load
{
    NSString *fileName = [self _pendingStoreObjectsFilePath];
    
    if ( fileName != nil )
    {  
        NSData *dataArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0 error:nil];
        
        if ( dataArchive )
        {
            QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:dataArchive];
            int version = [unarchiver version];
            if ( version == SWVersion )
            {
//                _pendingIASProducts = [unarchiver decodeObject];
                _pendingISReceipts = [unarchiver decodeObject];
            }
        }
    }
    
    //if ( _pendingIASProducts == nil ) _pendingIASProducts = [NSMutableArray array];
    if ( _pendingISReceipts == nil ) _pendingISReceipts = [NSMutableArray array];
}


//- (NSMutableArray*)_pendingIASProducts
//{
//    if ( _pendingIASProducts == nil )
//        [self _load];
//
//    return _pendingIASProducts;
//}

- (NSMutableArray*)_pendingISReceipts
{
    if ( _pendingISReceipts == nil )
        [self _load];

    return _pendingISReceipts;
}


//- (NSInteger)_isReceiptIndexForReceipt64:(NSString*)receipt64
//{
//    NSArray *theReceipts = [self _pendingISReceipts];
//    NSInteger count = theReceipts.count;
//    for ( NSInteger i=0 ; i<count ; i++ )
//    {
//        SWPendingISReceipt *isReceipt = [theReceipts objectAtIndex:i];
//        if ( [isReceipt.receipt64 isEqualToString:receipt64] )
//        {
//            return i;
//        }
//    }
//    return NSNotFound;
//}


- (NSInteger)_isReceiptIndexForReceiptID:(NSString*)receiptID
{
    NSArray *theReceipts = [self _pendingISReceipts];
    NSInteger count = theReceipts.count;
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        SWPendingISReceipt *isReceipt = [theReceipts objectAtIndex:i];
        if ( [isReceipt.receiptID isEqualToString:receiptID] )
        {
            return i;
        }
    }
    return NSNotFound;
}


//- (NSInteger)_isReceiptIndexForProduct:(NSString*)product userID:(UInt32)userID
//{
//    NSArray *theReceipts = [self _pendingISReceipts];
//    NSInteger count = theReceipts.count;
//    for ( NSInteger i=0 ; i<count ; i++ )
//    {
//        SWPendingISReceipt *isReceipt = [theReceipts objectAtIndex:i];
//        if ( [isReceipt.productID isEqualToString:product] && isReceipt.userID == userID && isReceipt.receipt64 != nil)
//        {
//            return i;
//        }
//    }
//    return NSNotFound;
//}


- (NSInteger)_isReceiptIndexForProduct:(NSString*)product userUUID:(NSString*)userUUID
{
    NSArray *theReceipts = [self _pendingISReceipts];
    NSInteger count = theReceipts.count;
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        SWPendingISReceipt *isReceipt = [theReceipts objectAtIndex:i];

        if ( [isReceipt.productID isEqualToString:product] && [isReceipt.userUUID isEqualToString:userUUID] && isReceipt.receiptID != nil)
        {
            return i;
        }
    }
    return NSNotFound;
}


//- (NSInteger)_isReceiptIndexForNilReceipt64WithProduct:(NSString*)product userID:(UInt32)userID
//{
//    NSArray *theReceipts = [self _pendingISReceipts];
//    NSInteger count = theReceipts.count;
//    for ( NSInteger i=0 ; i<count ; i++ )
//    {
//        SWPendingISReceipt *isReceipt = [theReceipts objectAtIndex:i];
//        if ( [isReceipt.productID isEqualToString:product] && isReceipt.userID == userID && isReceipt.receipt64 == nil)
//        {
//            return i;
//        }
//    }
//    return NSNotFound;
//}


- (NSInteger)_isReceiptIndexForNilReceiptIDWithProduct:(NSString*)product userUUID:(NSString*)userUUID
{
    NSArray *theReceipts = [self _pendingISReceipts];
    NSInteger count = theReceipts.count;
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        SWPendingISReceipt *isReceipt = [theReceipts objectAtIndex:i];
        if ( [isReceipt.productID isEqualToString:product] && [isReceipt.userUUID isEqualToString:userUUID] && isReceipt.receiptID == nil)
        {
            return i;
        }
    }
    return NSNotFound;
}


//- (void)setPendingProduct:(NSString *)productID withProjectUUID:(NSString*)projectID withName:(NSString*)name userID:(UInt32)userID
//{
//    NSInteger idx = [self _isReceiptIndexForNilReceipt64WithProduct:productID userID:userID];
//
//    if ( idx == NSNotFound )
//    {
//        SWPendingISReceipt *isReceipt = [[SWPendingISReceipt alloc] init];
//        isReceipt.productID = productID;
//        isReceipt.name = name;
//        isReceipt.projectUUID = projectID;
//        isReceipt.userID = userID;
//        
//        [_pendingISReceipts addObject:isReceipt];
//        [self _save];
//        return;
//    }
//    
//    SWPendingISReceipt *isReceipt = [_pendingISReceipts objectAtIndex:idx];
//    isReceipt.name = name;
//    isReceipt.projectUUID = projectID;
//    isReceipt.userID = userID;
//    [self _save];
//}


- (void)setPendingProduct:(NSString *)productID withProjectUUID:(NSString*)projectID withName:(NSString*)name userUUID:(NSString*)userUUID
{
    NSInteger idx = [self _isReceiptIndexForNilReceiptIDWithProduct:productID userUUID:userUUID];

    if ( idx == NSNotFound )
    {
        SWPendingISReceipt *isReceipt = [[SWPendingISReceipt alloc] init];
        isReceipt.productID = productID;
        isReceipt.name = name;
        isReceipt.projectUUID = projectID;
        isReceipt.userUUID = userUUID;
        
        [_pendingISReceipts addObject:isReceipt];
        [self _save];
        return;
    }
    
    SWPendingISReceipt *isReceipt = [_pendingISReceipts objectAtIndex:idx];
    isReceipt.name = name;
    isReceipt.projectUUID = projectID;
    isReceipt.userUUID = userUUID;
    [self _save];
}



- (BOOL)isPreparingProduct:(NSString*)productID
{
    return [_preparingProducts containsObject:productID];
}

- (void)prepareProduct:(NSString*)productID
{
    [_preparingProducts addObject:productID];
}

- (void)removePreparedProduct:(NSString*)productID
{
    [_preparingProducts removeObject:productID];
}


//- (BOOL)setPendingReceipt64:(NSString*)receipt64 toPendingProduct:(NSString*)productID forUserID:(UInt32)userID
//{
//    BOOL ok = NO;
//    NSInteger idx = [self _isReceiptIndexForNilReceipt64WithProduct:productID userID:userID];
//    if ( idx != NSNotFound )
//    {
//        SWPendingISReceipt *isReceipt = [_pendingISReceipts objectAtIndex:idx];
//        isReceipt.receipt64 = receipt64;
//        [self _save];
//        ok = YES;
//    }
//    else
//    {
//        idx = [self _isReceiptIndexForReceipt64:receipt64];
//        if ( idx != NSNotFound )
//        {
//            SWPendingISReceipt *isReceipt = [_pendingISReceipts objectAtIndex:idx];
//            ok = [isReceipt.productID isEqualToString:productID];
//            ok = ok && (isReceipt.userID == userID);
//        }
//        else
//        {
//            ok = NO;
//        }
//    }
//    
//    return ok;
//}


- (BOOL)setPendingReceipt64:(NSString*)receipt64 withReceiptID:(NSString*)receiptID  toPendingProduct:(NSString*)productID forUserUUID:(NSString*)userUUID
{
    BOOL ok = NO;
    NSInteger idx = [self _isReceiptIndexForNilReceiptIDWithProduct:productID userUUID:userUUID];
    if ( idx != NSNotFound ) // l'ha trobat vuit per aquest usuari i producte
    {
        SWPendingISReceipt *isReceipt = [_pendingISReceipts objectAtIndex:idx];
        isReceipt.receipt64_ = receipt64;
        isReceipt.receiptID = receiptID;    // hi afegeix el receipt ID
        [self _save];
        ok = YES;
    }
    else
    {
        idx = [self _isReceiptIndexForReceiptID:receiptID];
        if ( idx != NSNotFound )  // l'ha trobat
        {
            SWPendingISReceipt *isReceipt = [_pendingISReceipts objectAtIndex:idx];
            ok = [isReceipt.productID isEqualToString:productID];   // ha de tenir el mateix producte
            ok = ok && [isReceipt.userUUID isEqualToString:userUUID];  // i usuari
        }
        else
        {
            ok = NO;
        }
    }
    
    // acaba tornant NO si no l'ha trobat
    return ok;
}


//- (void)removePendingReceipt64:(NSString *)receipt64
//{
//    NSInteger idxx = [self _isReceiptIndexForReceipt64:receipt64];
//    if ( idxx != NSNotFound )
//    {
//        [_pendingISReceipts removeObjectAtIndex:idxx];
//        [self _save];
//    }
//}

- (void)removePendingReceiptID:(NSString *)receiptID
{
    NSInteger idxx = [self _isReceiptIndexForReceiptID:receiptID];
    if ( idxx != NSNotFound )
    {
        [_pendingISReceipts removeObjectAtIndex:idxx];
        [self _save];
    }
}


//- (SWPendingISReceipt *)pendingIsReceiptForReceipt64:(NSString*)receipt64
//{
//    SWPendingISReceipt *isReceipt = nil;
//    NSInteger idxx = [self _isReceiptIndexForReceipt64:receipt64];
//    if ( idxx != NSNotFound )
//    {
//        isReceipt = [_pendingISReceipts objectAtIndex:idxx];
//    }
//    return isReceipt;
//}


- (SWPendingISReceipt *)pendingIsReceiptForReceiptID:(NSString*)receiptID
{
    SWPendingISReceipt *isReceipt = nil;
    NSInteger idxx = [self _isReceiptIndexForReceiptID:receiptID];
    if ( idxx != NSNotFound )
    {
        isReceipt = [_pendingISReceipts objectAtIndex:idxx];
    }
    return isReceipt;
}


- (NSArray*)pendingISReceipts
{
    return [self _pendingISReceipts];
}

- (BOOL)isWaitingActivationForProduct:(NSString*)product userUUID:(NSString*)userUUID
{
    NSInteger idxxx = [self _isReceiptIndexForProduct:product userUUID:userUUID];
    return (idxxx != NSNotFound );    
}


- (void)removeAllPendingReceiptsForUserID:(NSString*)userUUID
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    NSInteger count = _pendingISReceipts.count;
    for ( NSInteger i = 0 ; i<count ; i++ )
    {
        SWPendingISReceipt *iSReceipt = [_pendingISReceipts objectAtIndex:i];
        if ( [iSReceipt.userUUID isEqualToString:userUUID] )
            [indexSet addIndex:i];
    }
    
    [_pendingISReceipts removeObjectsAtIndexes:indexSet];
    [self _save];
}


- (void)removeAllPendingReceipts
{
    [_pendingISReceipts removeAllObjects];
    [self _save];
}


@end



