//
//  SWExpressionProtocols.h
//  HmiPad_101010SJ
//
//  Created by Joan on 04/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "SWValueProtocols.h"

@class SWExpression;

@protocol ExpressionObserver <ValueObserver>

@optional
//- (void)expression:(SWExpression*)expression didChangeState:(UInt8)oldState;
- (void)expressionStateDidChange:(SWExpression*)expression;
- (void)expressionSourceStringDidChange:(SWExpression*)expression;

@end



//@protocol ExpressionHolder <NSObject>

//@required
//- (SWExpression*)expressionWithSymbol:(NSString *)sym property:(NSString *)prop ; // requerit per rpnBuilder
//- (NSString *)symbolForExpression:(SWExpression*)expr ;
//- (NSString *)identifier ;  // identifica el holder
//
//@optional
//- (NSString *)propertyForExpression:(SWExpression*)expr ;
//- (void)setGlobalIdentifier:(NSString*)ident ;  // requerit per rpnBuilder a commitExpressionsByConvertingLocalSymbolsToGlobalOutError
//
//@optional
//- (void)expression:(SWExpression*)expression didTriggerWithState:(UInt8)state change:(BOOL)changed;
//
//
//
//@optional
//- (ExpressionBase *)selfValueWExpressionWithId:(id)obj ;
//
//- (void)addSourceExpression:(ExpressionBase*)sourceExpr toExpressionWithId:(id)obj ;  // id es un cluster
//- (void)removeSourceExpression:(ExpressionBase*)sourceExpr fromExpressionWithId:(id)obj ;  // id es un cluster
//// ^ potser substituir selfValueWExpressionWithId per aquestes 2 (?) pero comprovant que id correspongui a un cluster o una expressio no inicialitzada
//
//@end





