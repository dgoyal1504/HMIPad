//
//  SWRecipeSheetParser.h
//  HmiPad
//
//  Created by Joan Lluch on 31/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "PrimitiveParser.h"


typedef enum
{
    SWRecipeSheetParserErrNone = 0,
    SWRecipeSheetParserErrSevere,
    SWRecipeSheetParserErrInvalidChar,
    SWRecipeSheetParserErrExtraRowChars,
    SWRecipeSheetParserErrExtraChars,
} SWRecipeSheetParserErrCode;



@interface SWRecipeSheetParser : PrimitiveParser
{
    id _sheetIdentifier;
    NSMutableDictionary *_sheetDict;
    NSMutableArray *_recipeKeys;
    NSMutableArray *_ingredientKeys;
    NSData *_data;
    CFStringEncoding _stringEncoding;
}

// initialize with a csv file data encoded as UTF8
- (id)initWithCsvData:(NSData*)data;

// start parsing the provided data
- (BOOL)parse;

// after unsuccesful parsing returns a string description of an error, nil otherwise
- (NSString *)errorString;

// after succesful parsing the following properties contain parsed data, undefined on error
@property (nonatomic,readonly) id sheetIdentifier;
@property (nonatomic,readonly) NSDictionary *sheetDict;
@property (nonatomic,readonly) NSArray* recipeKeys;
@property (nonatomic,readonly) NSArray* ingredientKeys;

@end
