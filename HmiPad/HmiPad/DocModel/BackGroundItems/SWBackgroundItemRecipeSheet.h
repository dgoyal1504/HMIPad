//
//  SWBackgroundItemExpression.h
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItem.h"

@interface SWBackgroundItemRecipeSheet : SWBackgroundItem

@property (nonatomic,readonly) SWValue *recipes;
@property (nonatomic,readonly) SWValue *recipeIdent;
@property (nonatomic,readonly) SWValue *recipeKeys;
@property (nonatomic,readonly) SWValue *ingredientKeys;
@property (nonatomic,readonly) SWExpression *sheetFilePath;

@end
