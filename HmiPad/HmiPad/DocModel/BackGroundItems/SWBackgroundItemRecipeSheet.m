//
//  SWBackgroundItemExpression.m
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItemRecipeSheet.h"
#import "SWPropertyDescriptor.h"

#import "AppModelRecipeSheet.h"
#import "SWDocumentModel.h"

#import "SWRecipeManager.h"

@implementation SWBackgroundItemRecipeSheet


static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if(_objectDescription == nil) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"recipeSheet";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"RECIPE SHEET", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"recipeIdent" type:SWTypeAny
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"recipes" type:SWTypeDictionary
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDictionary:@{}]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"recipeKeys" type:SWTypeArray
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:@[]]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"ingredientKeys" type:SWTypeArray
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:@[]]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"sheetFilePath" type:SWTypeRecipeSheetPath
            propertyType:SWPropertyTypeExpression defaultValue:[SWExpression valueWithString:@""]],

        nil
    ];
}


// #pragma mark init / dealloc / observer retain

//- (id)initInDocument:(SWDocumentModel *)docModel
//{
//    self = [super initInDocument:docModel];
//    if ( self )
//    {
//        [self.value observerCountRetainBy:1];
//    }
//    return self;
//}

//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super initWithQuickCoder:decoder];
//    if (self) 
//    {
//        [self _observerRetainAfterDecode];
//    }
//    return self;
//}

//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
//    if ( self )
//    {
//        [self _observerRetainAfterDecode];
//    }
//    return self;
//}

//- (void)_observerRetainAfterDecode
//{
//    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        [self.value observerCountRetainBy:1];
//    }) ;
//}

//- (void)putToSleep
//{
//    if ( !self.isAsleep )
//        [self.value observerCountReleaseBy:1];
//    
//    [super putToSleep];
//}

//- (void)awakeFromSleepIfNeeded
//{
//    BOOL isAsleep = self.isAsleep;
//    [super awakeFromSleepIfNeeded];
//    
//    if (isAsleep)
//        [self.value observerCountRetainBy:1];
//}

//- (void)dealloc
//{
//    if (!self.isAsleep)
//        [self.value observerCountReleaseBy:1];
//}


#pragma mark - Properties

- (SWValue*)recipeIdent
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)recipes
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWValue*)recipeKeys
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWValue*)ingredientKeys
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWExpression*)sheetFilePath
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}


#pragma mark - Value Holder

- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
{
    if ( value == self.sheetFilePath )
    {
        BOOL isDecoding = [self isCommitingWithMoveToGlobal];
        if ( isDecoding )
            return;
    
        [self _reloadSheet];
    }
}


#pragma mark - Private

- (void)_reloadSheet
{
    NSString *sheetUrl = [self.sheetFilePath valueAsString];
    
    AppModelRecipeSheet *amRecipeSheet = [filesModel() amRecipeSheet];
    [amRecipeSheet getRecipeSheetWithTextUrl:sheetUrl completionBlock:^(NSDictionary *sheetInfo)
    {
        NSString *errStr = [sheetInfo objectForKey:SWRecipeManagerErrorStringKey];
    
        if ( errStr)
        {
            NSString *label = NSLocalizedString(@"RECIPE", nil);
            NSString *format = NSLocalizedString(@"Errors found while parsing recipe sheet file \"%@\". %@",nil);
            NSString *comment = [NSString stringWithFormat:format, sheetUrl, errStr];
            [_docModel addSystemEventWithLabel:label comment:comment];
        }
    
        id ident = [sheetInfo objectForKey:SWRecipeManagerSheetIdentifierKey];
        
        if ( [ident isKindOfClass:[NSNumber class]] )
            [self.recipeIdent evalWithDouble:[ident doubleValue]];
        else if ( [ident isKindOfClass:[NSString class]] )
            [self.recipeIdent evalWithString:ident];
        
        NSArray *ingredients = [sheetInfo objectForKey:SWRecipeManagerIngredientKeysKey];
        NSArray *recipes = [sheetInfo objectForKey:SWRecipeManagerRecipeKeysKey];
        NSDictionary *recipeDict = [sheetInfo objectForKey:SWRecipeManagerSheetKey];
    
        SWValue *dictValue = [SWValue valueWithDictionary:recipeDict];
        [self.recipes evalWithValue:dictValue];
        [self.ingredientKeys evalWithArray:ingredients];
        [self.recipeKeys evalWithArray:recipes];
    }];
}


- (void)_recipeSheetErrorOcurred:(NSString*)errorString
{
    NSString *label = NSLocalizedString(@"RECIPE", nil);
    [_docModel addSystemEventWithLabel:label comment:errorString];
}


@end
