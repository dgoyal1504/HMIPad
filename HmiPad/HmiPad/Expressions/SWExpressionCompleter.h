//
//  SWExpressionCompleter.h
//  HmiPad
//
//  Created by Joan on 26/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "PrimitiveParser.h"

@class SWExpressionCompleter;
@class RpnBuilder;
@class RpnInterpreter;

@protocol SWExpressionCompleterDelegate<NSObject>

- (void)expressionCompleter:(SWExpressionCompleter*)completer
    didSuggestSymbols:(NSArray*)symbols
    properties:(NSArray*)properties
    classes:(NSArray*)classes
    methods:(NSArray*)methods
    atCharPosition:(NSInteger)charPosition;

@end



@interface SWExpressionCompleter : PrimitiveParser

- (id)initWithBuilder:(RpnBuilder*)builder interpreter:(RpnInterpreter*)interpreter;
@property (nonatomic, weak) id<SWExpressionCompleterDelegate>delegate;
- (void)processSourceString:(NSString*)sourceString;

@end
