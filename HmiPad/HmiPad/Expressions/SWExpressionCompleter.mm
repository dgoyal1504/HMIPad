//
//  SWExpressionCompleter.m
//  HmiPad
//
//  Created by Joan on 26/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWExpressionCompleter.h"
#import "RpnBuilder.h"
#import "RpnInterpreter.h"
#import "SWValue.h"
#import "SWObject.h"
//#import "SWObject.h"
#import "SWPropertyDescriptor.h"
#import "SWObjectDescription.h"


@interface SWExpressionCompleter()
{
    RpnBuilder *_builder;
    RpnInterpreter *_interpreter;
}

@end



@implementation SWExpressionCompleter
{
    __weak NSTimer *_timer;
    NSString *_sourceString;
}


- (id)initWithBuilder:(RpnBuilder*)builder interpreter:(RpnInterpreter*)interpreter
{
    self = [super init];
    if ( self )
    {
        _builder = builder;
        //if ( interpreter == nil ) interpreter = [RpnInterpreter sharedRpnInterpreter];
        //_interpreter = interpreter;
    }
    return self;
}


- (void)processSourceString:(NSString*)sourceString
{
    if ( _timer == nil )
        _timer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_processSourceNow:) userInfo:nil repeats:YES];

    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    _sourceString = sourceString;
}


static inline BOOL _hasPrefix( NSString* string, NSString* token)
{
    return NSOrderedSame == [string compare:token options:NSAnchoredSearch|NSCaseInsensitiveSearch range:NSMakeRange(0,token.length)];
}


- (BOOL)_parseTokenList:(NSArray**)outTokenList
{
    NSMutableArray *tokenList = nil;
    //if ( _parseChar( '.' ) )
    if ( _parseExclusiveChar( '.' ) )
    {
        if ( tokenList == nil ) tokenList = [NSMutableArray array];
        [tokenList addObject:@"+"];
    }
    
    while ( 1 )
    {
        _skip;
        const unsigned char *cstr;
        size_t tokenLen = 0;
        if ( [self parseToken:&cstr length:&tokenLen] )
        {
            NSString *token = [[NSString alloc] initWithBytes:cstr length:tokenLen encoding:NSUTF8StringEncoding];
            
            if ( tokenList == nil ) tokenList = [NSMutableArray array];
            [tokenList addObject:token];
            
            const UInt8 *svc = c;   // <-- si no hi ha un . no volem saltar
            _skip;
            //if ( _parseChar( '.' ) )
            if ( _parseExclusiveChar( '.' ) )
            {
                continue;
            }
            c = svc;
        }
        else
        {
            // si token list no esta creada no afagira res
            if ( tokenList )
                [tokenList addObject:@""];
        }
        
        break;
    }

    *outTokenList = tokenList;
    return tokenList != nil;
}


- (BOOL)_parseConstantString
{
    if ( _parseChar( '\"' ) )
    {
        _skipPastChar( '\"' );
        return YES;  // <-- Pel fet d'haver trobat la primera cometa tornem sempre YES
    }
    return NO;
}


// considerem voidPropertyHolder si valueWithSymbol:property torna un valor per property nil, pero aquest
// valor te una property string nulla
static BOOL _holder_hasVoidPropertiesForSymbol(__unsafe_unretained id<ValueHolder> holder, NSString* symbol)
{
    if ( holder==nil)
        return YES;
    
    BOOL isVoid = NO;
    
    SWValue *defValue = [holder valueWithSymbol:symbol property:nil];
    if ( defValue )
    {
        isVoid = YES; // si no respon al selector considerem que isVoid
        if ( [holder respondsToSelector:@selector(propertyForValue:)])
        {
            NSString *property = [holder propertyForValue:defValue];
            isVoid = (property==nil);
        }
    }
    return isVoid;
}


- (void)_processSourceNow:(id)sender
{
    [_timer invalidate];
    _timer = nil;

    const char *ptr = [_sourceString UTF8String];
    beg = (UInt8*)ptr;
    end = beg + strlen(ptr);
    c = beg;
    
    NSArray *tokenList = nil;
    while ( c < end && YES )
    {
        //const unsigned char *svsc = c;
        tokenList = nil;
        _skip;
        if ( [self parseNumber:NULL isTime:NULL] ) continue;
        if ( [self _parseConstantString] ) continue;
        if ( _parseCString("..", 2) ) continue;
        if ( [self _parseTokenList:&tokenList]) continue;
        c++;
    }
    
    NSString *lastToken = [tokenList lastObject];
    //NSLog( @"\n------------------------\ntokenList:\n%@", tokenList);

    NSInteger position = _sourceString.length - lastToken.length;
    NSMutableArray *symbols = [NSMutableArray array];
    NSMutableArray *properties = [NSMutableArray array];
    NSMutableArray *classes = [NSMutableArray array];
    NSMutableArray *methods = [NSMutableArray array];
    
    NSInteger tokenCount = tokenList.count;
    
    // cap token
    if ( tokenCount == 0 )
    {
        // res;
    }
    
    // un token
    else if ( tokenCount == 1 )
    {
        NSString *token = [tokenList objectAtIndex:0];
        int tokenLen = token.length;
        
        // llistem directament tots els simbols i funcions disponibles
        [_builder enumerateGlobalTableUsingBlock:^(NSString *symbol, __unsafe_unretained id<ValueHolder> holder)
        {
            if ( tokenLen==0 || _hasPrefix(symbol,token) )
                [symbols addObject:symbol];
        }];
        if ( symbols.count == 1 && [(NSString*)symbols[0] length] == tokenLen)
            [symbols removeAllObjects];
        
        // llistem les classes
        RPNValue::enumerateClassesUsingBlock(^(NSString *name)
        {
            if ( tokenLen==0 || _hasPrefix(name,token) )
                [classes addObject:name];
        });
        if ( classes.count == 1 && [(NSString*)classes[0] length] == tokenLen)
            [classes removeAllObjects];
        
        // llistem les funcions (root methods)
        RPNValue::enumerateRootMethodsUsingBlock(^(NSString *name)
        {
            if ( tokenLen==0 || _hasPrefix(name,token) )
                [methods addObject:name];
        });
        if ( methods.count == 1 && [(NSString*)methods[0] length] == tokenLen)
            [methods removeAllObjects];
        
    }
    
    // dos o mes tokens
    else
    {
        __unsafe_unretained id<ValueHolder> holder = nil;
        //SWValueType valueType = SWValueTypeError;
        int classSelector = -1;
        int methodSelector = -1;
        
        NSString *firstToken = nil;
        
        for ( NSInteger i=0; i<tokenCount; i++ )
        {
            NSString *token = [tokenList objectAtIndex:i];
            NSInteger tokenLen = token.length;
            
            // primer token
            if ( i == 0 )
            {
                firstToken = token;
                
                // mirem si es una classe
                classSelector = RPNValue::selectorForClass( firstToken );
                if ( classSelector < 0 )
                {
                    // mirem si es un metode de la classe root (funcio)
                    methodSelector = RPNValue::selectorForMethod_inClassWithSelector(firstToken, RPNClSelRootClass);
                    if ( methodSelector < 0 )
                    {
                        // mirem si es una variable
                        holder = [_builder globalTableObjectForSymbol:firstToken];
                        if ( holder )
                        {
                            classSelector = RPNClSelGenericClass;
                        }
                    }
                    else
                    {
                        classSelector = RPNClSelGenericClass;
                    }
                }
                
                // ara volem passar a la seguent iteracio
                continue;
            }
            
            // no primer i no ultim
            if ( i > 0 && i+1 < tokenCount)
            {
                // variable
                if ( holder )
                {
                    // determinem si tenim una propietat (o el holder pot anar sense propietat)
                    SWValue *value = [holder valueWithSymbol:firstToken property:token];
                    if ( value == nil )
                    {
                        // encara pot ser un metode de clase generica
                        classSelector = -1;  // <-- tentativament invalidem classSelector
                        BOOL doTestMethod = _holder_hasVoidPropertiesForSymbol(holder, firstToken);
                        if ( doTestMethod )
                        {
                            methodSelector = RPNValue::selectorForMethod_inClassWithSelector(token, RPNClSelGenericClass);
                            classSelector = methodSelector >= 0 ? RPNClSelGenericClass : -1;
                        }
                    }
                }
  
                // els futurs metodes nomes poden ser de tipus generic, pero nomes si el actual es valid
                else if ( classSelector >= 0 )
                {
                    methodSelector = RPNValue::selectorForMethod_inClassWithSelector(token, classSelector);
                    classSelector = methodSelector >= 0 ? RPNClSelGenericClass : -1;
                }
                
                // una variable nomes pot apareixer en el primer token, posem holder a nil
                holder = nil;
            }
            
            // ultim token
            if ( i+1 == tokenCount )
            {
                BOOL doTestMethod = _holder_hasVoidPropertiesForSymbol(holder, firstToken);
                
                // possibles propietats
                if ( holder && !doTestMethod )
                {                    
                    if ( [holder.class respondsToSelector:@selector(objectDescription)])
                    {
                        NSArray *descriptions = [holder.class objectDescription].allPropertyDescriptions;
                        for ( SWPropertyDescriptor *propertyDescr in descriptions )
                        {
                            NSString *name = propertyDescr.name;
                            if ( tokenLen==0 || _hasPrefix(name, token) )
                                [properties addObject:name];
                        }
                        if ( properties.count == 1 && [(NSString*)properties[0] length] == tokenLen)
                            [properties removeAllObjects];
                    }
                    
                    if ( [holder respondsToSelector:@selector(propertyDescriptions)])
                    {
                        NSArray *descriptions = [(id)holder propertyDescriptions];
                        for ( SWPropertyDescriptor *propertyDescr in descriptions )
                        {
                            NSString *name = propertyDescr.name;
                            if ( tokenLen==0 || _hasPrefix(name, token) )
                                [properties addObject:name];
                        }
                        if ( properties.count == 1 && [(NSString*)properties[0] length] == tokenLen)
                            [properties removeAllObjects];

                    }
                }
                
                // posibles metodes
                if ( classSelector >= 0 && doTestMethod )
                {
                    RPNValue::enumerateMethodsForClassSelector_usingBlock(classSelector, ^(NSString *name)
                    {
                        if ( tokenLen==0 || _hasPrefix(name,token) )
                            [methods addObject:name];
                    });
                    if ( methods.count == 1 && [(NSString*)methods[0] length] == tokenLen)
                        [methods removeAllObjects];
                }
            }
        }
    }
    


    //NSLog( @"Expression Completer: %@", _sourceString);
    [_delegate expressionCompleter:self didSuggestSymbols:symbols
        properties:properties classes:classes methods:methods atCharPosition:position];
    
    _sourceString = nil;
}


//- (BOOL)matchesSearchWithString:(NSString*)searchString
//{    
//    NSString *string = _identifier;
//    NSComparisonResult result = [string compare:searchString
//                                        options:NSLiteralSearch
//                                          range:NSMakeRange(0, [searchString length])];
//    
//    return result == NSOrderedSame;
//}



@end
