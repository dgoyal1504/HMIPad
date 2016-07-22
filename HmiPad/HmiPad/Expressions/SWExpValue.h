//
//  SWExpValue.h
//  HmiPad
//
//  Created by Lluch Joan on 25/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPNValue.h"

/*

#if __cplusplus
extern "C" {   // no volem que el compilador de c++ mutili els noms de les funcions !
#endif
//
//typedef enum
//{
//    ExpressionValueTypeUnknown = 0,
//    ExpressionValueTypeNumber,
//    ExpressionValueTypeString,
//    ExpressionValueTypeArray,
//} ExpressionValueType ;



 
//------------------------------------------------------------------------------------
// Representa un wrapper de un RPNValue que respon a alguns metodes de conveniencia per
// obtenir valors del seu contingut
// Es pot obtenir amb el metode value de una expressio.
//
// Atencio: el objecte deixa de ser valid si el objecte representat
// deixa de ser valid o canvia.

@interface SWExpValue : NSProxy<NSFastEnumeration>

extern NSString *stringForDouble_withFormat( double d, NSString *format ) ;

//- (ExpressionValueType)valueType ;
- (NSString *)valueTypeString ;
- (NSInteger)valuesCount ;                      // torna 1 com a minim
- (SWExpValue*)valueAtIndex:(NSInteger)index ;    // tornara ell mateix per index==0 si no es un array, nil si es out of bounds
- (double)valueAsDouble ;
- (NSString *)valueAsStringWithFormat:(NSString*)format ;
- (UIColor*)valueAsColor ;

@end


@interface SWExpValue (Expression)

//extern ExpressionValueType valueTypeForSWValueType(SWValueType typ) ;
extern NSString *valueTypeStringForSWValueType(SWValueType typ) ;

#if __cplusplus
- (id)initWithRPNValue:( const RPNValue& )rpnVal ;
#endif

@end

#if __cplusplus
}
#endif
 */

