//
//  AppModel+DatabaseManager.h
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModel.h"
#import "SWRecipeManagerKeys.h"

@class SWRecipeManager;

@interface AppModelRecipeSheet : NSObject
{
    __weak AppModel *_filesModel;
    SWRecipeManager *_recipeManager;
}

- (id)initWithLocalFilesModel:(AppModel*)filesModel;

- (void)getRecipeSheetWithTextUrl:(NSString*)sheetName completionBlock:(void (^)(NSDictionary* sheetInfo))completionBlock;
- (void)getRecipeSheetWithTextUrl:(NSString*)sheetName inDocumentName:(NSString*)docName completionBlock:(void (^)(NSDictionary* sheetInfo))completionBlock;

@end
