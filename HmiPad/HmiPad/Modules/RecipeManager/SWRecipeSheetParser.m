//
//  SWRecipeSheetParser.m
//  HmiPad
//
//  Created by Joan Lluch on 31/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWRecipeSheetParser.h"


@implementation SWRecipeSheetParser
{
    BOOL _firstRow;
    BOOL _firstColumn;
    char _delimiter;
    SWRecipeSheetParserErrCode _errCode;
    UInt32 _sourceOffset;
    id _object;
    //NSMutableArray *_ingredients;
    //NSMutableDictionary *_rowDict;
}

//#define obtainDelimiter ( c<end && (_delimiter=*c) && ( *c==',' || *c==';' || *c=='\t' ))
#define obtainDelimiter ( (_delimiter=',') && c<end  && ( *c==',' || *c==';' || *c=='\t' ) && (_delimiter=*c))

- (id)initWithCsvData:(NSData*)data
{
    self = [super init];
    {
        _sheetDict = [NSMutableDictionary dictionary];
        _ingredientKeys = [NSMutableArray array];
        _recipeKeys = [NSMutableArray array];
        _stringEncoding = kCFStringEncodingUTF8;
        _data = data;
    }
    return self;
}

#pragma mark - methods and properties

- (BOOL)parse
{

    c = [_data bytes];
    end = c + [_data length];
    [_sheetDict removeAllObjects];
    [_ingredientKeys removeAllObjects];
    [_recipeKeys removeAllObjects];

    //if ( ! (c < end) ) return NO;
    
    //_ingredients = [NSMutableArray array];
    //_rowDict = [NSMutableDictionary dictionary];
    _line = 1;
    _errCode = 0;
    
    BOOL done = [self _parseAll] && _errCode == 0;
    return done;
}


- (NSDictionary*)sheetDict
{
    return _sheetDict;
}


- (NSArray*)ingredientKeys
{
    return _ingredientKeys;
}


- (NSArray*)recipeKeys
{
    return _recipeKeys;
}


- (NSString*)errorString
{
    NSString *errDescr = nil;
    NSString *errStr = nil;
    
    switch (_errCode)
    {
        case SWRecipeSheetParserErrSevere:
            errDescr = @"Column could not be parsed.";
            break;
          
        case SWRecipeSheetParserErrInvalidChar:
            errDescr = @"Invalid Character.";
            break;

        case SWRecipeSheetParserErrExtraRowChars:
            errDescr = @"Extra characters at end of column.";
            break;

        case SWRecipeSheetParserErrExtraChars:
            errDescr = @"Extra characters after end of file.";
            break;
          
        case SWRecipeSheetParserErrNone:
            errDescr = nil;
            break;
    }
    
    if ( errDescr )
    {
        NSString *format = NSLocalizedString(@"[Line %d]: %@", nil);
        errStr = [NSString stringWithFormat:format, _line, errDescr];
    }

    return errStr;
}


#pragma mark - private

- (void)_error:(SWRecipeSheetParserErrCode)code
{
    // nomes apuntem el primer que trobem
    if ( _errCode != 0 ) return ;
    
    _errCode = code ;
    _sourceOffset = c - beg;
}


- (BOOL)_constant
{
    double num ;
    if ( [self parseNumber:&num isTime:NULL] )
    {
        _object = @(num);
        return YES ;
    }
    
    return NO ;
}


//- (BOOL)_stringConstantV
//{
//    const unsigned char *cstr ;
//    size_t len ;
//    if ( [ self parseConstantString:&cstr length:&len doubleQuote:NO dollarCom:NO] )
//    {
//        NSString *string = CFBridgingRelease(CFStringCreateWithBytes(NULL, cstr, len, _stringEncoding, false )) ;
//        if ( string != nil )
//        {
//            _object = string;
//            return YES ;
//        }
//    }
//    return NO ;
//}

- (BOOL)_stringConstant
{
    CFStringRef string = [self parseEscapedCreateStringWithEncoding:_stringEncoding];
    if ( string == NULL )
        return NO;
    
    _object = CFBridgingRelease(string);
    return YES ;
}


- (BOOL)_simbolicToken
{
    const unsigned char *cstr ;
    size_t len ;
    if ( [self parseToken:&cstr length:&len] )
    {
        NSString *string = CFBridgingRelease(CFStringCreateWithBytes(NULL, cstr, len, _stringEncoding, false )) ;
        if ( string != nil )
        {
            _object = string;
            return YES ;
        }
    }
    return NO ;
}


- (BOOL)_parseColumn
{
    // constants
    if ( [self _constant] ) // abans que simbolic per supportar true, false
    {
        return YES ;
    }
    
    // simbols
    else if ( [self _simbolicToken] )
    {
        return YES ;
    }
    
    // string constants
    else if ( [self _stringConstant] )
    {
        return YES ;
    }
    
//    // admetem columnes vuides excepte per la primera
//    else if ( _firstColumn == NO && (*c == _delimiter || *c == '\r' || *c == '\n' || c==end) )
//    {
//        _object = @"";
//        return YES;
//    }
    
    else
    {
        if ( _firstColumn == NO )
        {
            if ( (*c == _delimiter || *c == '\r' || *c == '\n' || c==end) )
            {
                _object = @"";
                return YES;
            }
            else [self _error:SWRecipeSheetParserErrInvalidChar];
        }
    }

    return NO;
}


- (BOOL)_parseRowColumns
{
    _firstColumn = YES;
    if ( [self _parseColumn] )
    {
        _firstColumn = NO;
        
        NSString *rowKey = _object;
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionary];
    
        _skipSp;
        obtainDelimiter;
    
        int ingredientIndex = 0;
        while ( YES )
        {
            _skipSp;
            if ( _parseChar( _delimiter ) )
            {
                _skipSp;
                if ( [self _parseColumn] )
                {
                    if ( _firstRow )
                    {
                        [_ingredientKeys addObject:_object];
                    }
                    else
                    {
                        NSString *ingredientKey = nil;
                        if ( ingredientIndex < _ingredientKeys.count ) ingredientKey = [_ingredientKeys objectAtIndex:ingredientIndex];
                        if ( ingredientKey != nil ) [rowDict setObject:_object forKey:ingredientKey];
                    }
                    ingredientIndex += 1;
                    continue;
                }
                else
                {
                    [self _error:SWRecipeSheetParserErrSevere];
                    return NO;
                }
            }
            break;
        }
        
        _skipSp;
        if ( _parseChar( '\r' ) || ( _parseChar( '\n' ) && (_line+=1) ) || c==end )
        {
            if ( _firstRow )
            {
                _sheetIdentifier = rowKey;
            }
            else
            {
                [_recipeKeys addObject:rowKey];
                [_sheetDict setObject:rowDict forKey:rowKey];
            }
            return YES ;
        }
        else [self _error:SWRecipeSheetParserErrExtraRowChars];
    }
    return NO;
}


- (BOOL)_parseCsvComment
{
    if ( _parseChar( '#' ) )
    {
        [self skipToAnyCharIn:"\r\n"] ;
        return YES ;
    }
    return NO;
}


- (BOOL)_parseCsvRow
{
    if ( [self _parseRowColumns])
    {
        return YES;
    }

    return NO;
}


- (BOOL)_parseCsvBody
{
    _firstRow = YES;
    while ( YES )
    {
        _skip ;
        if ( [self _parseCsvComment] )
        {
            continue;
        }
        else if ( [self _parseCsvRow] )
        {
            _firstRow = NO;
            continue;
        }
        break ;
    }
    return YES;
}


- (BOOL)_parseAll
{
    _skip ;
    if ( [self _parseCsvBody] )
    {
        // ens assegurem que som al final
        _skip
        if ( c == end ) return YES ;
        else [self _error:SWRecipeSheetParserErrExtraChars];
    }
    return NO ;
}


@end
