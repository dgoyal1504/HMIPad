//
//  AppModel+DatabaseManager.m
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelRecipeSheet.h"
#import "AppModelFilesEx.h"

#import "AppModelFilePaths.h"

#import "SWRecipeManager.h"

@implementation AppModelRecipeSheet


- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        _recipeManager = [SWRecipeManager defaultManager];
        [_recipeManager setDispatchQueue:_filesModel.dQueue key:_filesModel.queueKey];
    }
    return self;
}


- (void)getRecipeSheetWithTextUrl:(NSString*)sheetName completionBlock:(void (^)(NSDictionary* sheetInfo))completionBlock
{
    [self getRecipeSheetWithTextUrl:sheetName inDocumentName:nil completionBlock:completionBlock];
}


- (void)getRecipeSheetWithTextUrl:(NSString*)sheetName inDocumentName:(NSString*)documentName completionBlock:(void (^)(NSDictionary* sheetInfo))completionBlock
{
    NSString *recipePath = nil;
    
    recipePath = [_filesModel.filePaths fullRecipeSheetUrlPathForTextUrl:sheetName inDocumentName:documentName];
    
    [_recipeManager getRecipeSheetAtPath:recipePath completionBlock:completionBlock];
}

@end

