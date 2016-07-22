//
//  SWRecipeManager.m
//  HmiPad
//
//  Created by Joan Lluch on 31/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWRecipeManager.h"

#import "SWRecipeSheetParser.h"

NSString *SWRecipeManagerSheetIdentifierKey = @"sheetIdentifier";
NSString *SWRecipeManagerSheetKey = @"sheet";
NSString *SWRecipeManagerRecipeKeysKey = @"recipeKeys";
NSString *SWRecipeManagerIngredientKeysKey = @"ingredientKeys";
NSString *SWRecipeManagerErrorStringKey = @"errorString";

@implementation SWRecipeManager
{
	dispatch_queue_t _cQueue;
    const char *_queueKey ; // key for the dispatch queue
    void *_queueContext ; // context for the dispatch queue
}


+ (SWRecipeManager*)defaultManager
{
    static SWRecipeManager *instance = nil;

    if (!instance)
    {
        instance = [[SWRecipeManager alloc] init];
    }
    
    return instance;
}


- (id)init
{
    self = [super init];
    if ( self )
    {
    
    }
    return self;
}


- (void)getRecipeSheetAtPath:(NSString*)path completionBlock:(void (^)(NSDictionary* sheetInfo))completionBlock
{
    [self _reloadFromPath:path completion:completionBlock];
}


#pragma mark Serial Queue

- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key
{
    _queueKey = key;
    _queueContext = dispatch_queue_get_specific(cQueue, key);
    _cQueue = cQueue;
}


- (dispatch_queue_t)cQueue
{
    if ( _cQueue == NULL )
    {
        _queueKey = "SWRecipeManagerQueue";
        _queueContext = (void*)_queueKey;
        
        _cQueue = dispatch_queue_create( _queueKey, NULL );
        dispatch_queue_set_specific( _cQueue, _queueKey, _queueContext, NULL);
    }
    return _cQueue;
}


- (void)dispatchBlockNow:(void (^)(void))block
{
    if (dispatch_get_specific(_queueKey) == _queueContext) block();
    else dispatch_sync( self.cQueue, block );
}


#pragma mark - Load


- (void)_reloadFromPath:(NSString*)path completion:(void (^)(NSDictionary* sheetInfo))completionBlock
{
    dispatch_async([self cQueue], ^
    {
        NSDictionary *sheetInfo = nil;
        NSData *csvData = [NSData dataWithContentsOfFile:path];
        
        if ( csvData )
        {
            SWRecipeSheetParser *parser = [[SWRecipeSheetParser alloc] initWithCsvData:csvData];
            BOOL done = [parser parse];
            if ( done )
            {
                sheetInfo = @{
                    SWRecipeManagerSheetIdentifierKey:parser.sheetIdentifier,
                    SWRecipeManagerSheetKey:parser.sheetDict,
                    SWRecipeManagerRecipeKeysKey:parser.recipeKeys,
                    SWRecipeManagerIngredientKeysKey:parser.ingredientKeys,
                };
            }
            else
            {
                sheetInfo = @{
                    SWRecipeManagerErrorStringKey:parser.errorString
                };
            }
        }
        else
        {
            NSString *errorString = NSLocalizedString(@"File not found.", nil);
            sheetInfo = @{
                SWRecipeManagerErrorStringKey:errorString
            };
        }
    
        dispatch_async( dispatch_get_main_queue(), ^
        {
            completionBlock( sheetInfo );
        });
    });
}



//
//- (void)_reloadSimulateWithCompletion:(void (^)(NSDictionary* sheet))completionBlock
//{
//    dispatch_async([self cQueue], ^
//    {
//        NSDictionary *recipe1 = @{ @"item1": @11, @"item2": @12, @"item3": @13};
//        NSDictionary *recipe2 = @{ @"item1": @21, @"item2": @22, @"item3": @23};
//        NSDictionary *recipe3 = @{ @"item1": @31, @"item2": @32, @"item3": @33};
//        NSDictionary *recipe4 = @{ @"item1": @41, @"item2": @42, @"item3": @43};
//    
//        NSDictionary *sheetDict = @{@"recipe1":recipe1, @"recipe2":recipe2, @"recipe3":recipe3, @"recipe4":recipe4};
//
//        dispatch_async( dispatch_get_main_queue(), ^
//        {
//            completionBlock( sheetDict );
//        });
//    });
//}

@end
