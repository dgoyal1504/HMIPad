//
//  RpnBuilder.h
//  HmiPad_101114
//
//  Created by Joan on 15/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrimitiveParser.h"
#import "QuickCoder.h"

//#import "SWExpression.h"
#import "SWValueProtocols.h"
#import "SWExpressionCommonTypes.h"

@protocol ExpressionHolder;
@class SWExpression;
@class SymbolicTable;

//-------------------------------------------------------------------------------------------
@interface RpnBuilder : PrimitiveParser<QuickCoding>
{
    CFMutableArrayRef expressions;     // conte les expressions registrades pendents de comitar
    CFMutableDictionaryRef localTable;
    CFMutableDictionaryRef globalTable;
    CFMutableArrayRef localTables;          // conte els diccionaris de simbols locals pendents de traspasar a globals
    //CFMutableArrayRef localTableKeys;       // conte els simbols locals pendents de traspasar a globals
    //CFMutableArrayRef localTableValues;     // conte els simbols locals pendents de traspasar a globals
    CFDictionaryRef systemTable;
    CFDictionaryRef methodSelectors;   // method selectors de la clase 0 (creat dinamicament)
    CFMutableArrayRef methodSelectorDictionaries;  //(creat dinamicament)
    CFDictionaryRef classSelectors;  //(creat dinamicament)
    int classSelector;
    
    SymbolicTable *symbols;
    CFMutableArrayRef constStrings;
    CFStringEncoding stringEncoding;
    
    CFMutableDataRef data;  // per posar el rpnCode
    CFMutableDataRef dataS; // per posar el codi font
    
    UInt8 *p; // punter a data
    UInt8 *max;
    UInt8 *pS; // punter a dataS
    UInt8 *ppS;  // placeholder a dataS
    UInt8 *maxS;
    const UInt8 *cS;
    
    BOOL doubleQuoted;
    BOOL skipDependencies;
    
    ExpressionErrorCode errCode;
    ExpressionErrorInfo errInfo;
}


// metodes de clase
+ (BOOL)isValidExpressionSource:(NSString*)source forBuilderInstance:(RpnBuilder*)builder outErrString:(NSString**)outErrStr;

// Metode primitiu per crear una nova expressio a partir de un buffer de caracters representat 
// en el encoding que se li passa
// El encoding ha de ser de 8 bits compatible amb ASCII, per exemple UTF8 o ISO_LATIN
// Torna nil i un error en cas de error.
// La expresio es crea en termes simbolics i no queda per tant enllacada amb altres
// expresions.
- (SWExpression*)newExpressionFromBytes:(const UInt8*)ptr 
            maxLength:(int)length                       // longitud maxima de bytes disponible en *ptr
            stringEncoding:(CFStringEncoding)encoding   // encoding
            usedLength:(int*)length                     // torna la longitud de bytes utilitzada
            doubleQuoted:(BOOL)quoted                   // indica si les strings constants es representen amb dobles parelles de cometes
            outError:(NSError**)outError;  // error 
            

// Estableix una taula de simbols prioritaria. Els simbols en aquesta taula s'enllacen primer.
// El diccionari ha de contenir parelles CFStringRef, id<ExpressionHolder> per key, value respectivament 
- (void)setSystemTable:(CFDictionaryRef)table;

// afageix simbols a les tables de simbols, aquest simbols son els que es
// tindran en compte per enllacar les expressions durant el commit
- (void)addLocalSymbol:(NSString*)symbol withHolder:(id<ValueHolder>)holder;
- (void)addGlobalSymbol:(NSString*)symbol withHolder:(id<ValueHolder>)holder;

// access a la taula global
- (void)enumerateGlobalTableUsingBlock:( void (^)(NSString *symbol, __unsafe_unretained id<ValueHolder>holder ) )block;
- (__unsafe_unretained id<ValueHolder>)globalTableObjectForSymbol:(NSString*)symbol;

// Les expressions que torna newExpression han de ser sotmeses a la substitucio dels
// simbols per les expressions rellevants. Nomes les expressions registrades es tindran
// en compte per commitExpressions.
- (void)registerExpressionForCommit:(SWExpression*)expression;

// Enllaca les expressions registrades tenin en compte la informacio simbolica
// vigent proporcionada a la clase.
// El metode es pot cridar repetides vegades a mida que es
// registren noves expressions o es completen les taules de simbols.
// Les expressions que s'han pogut processar s'eliminen del registre, la resta queda pendent per
// futurs commits.
// Els simbols locals afegits des de l'ulim commit s'eliminen i no interfereixen en futurs commits,
// es a dir podem commitar expresions en un determinat scope o namespace.
// Els simbols globals permaneixen disponibles durant la vida de la clase
// L'ordre de preferencia en la busqueda de simbols es Sistema, Locals, Globals.
// Torna NO si queden expressions pendents de comitar degut a simbols no trobats
//- (BOOL)commitExpressionsOutError:( NSError**)outError;
- (BOOL)commitExpressions;

// Igual que l'anterior pero Converteix els simbols locals registrats en globals.
// Permet efectuar un comit parcial (o total) d'expressions interconectades entre si
// a traves dels simbols locals, pero resultant amb les expressions enllacades a traves
// de la taula global. Requereix el metode setGlobalIdentifier implementat en els holders
// de la expressio, en cas contrari genera una excepcio de unrecognized selector.
// Torna NO si queden expressions pendents de comitar degut a simbols no trobats
//- (BOOL)commitExpressionsByConvertingLocalSymbolsToGlobalOutError:( NSError**)outError;
- (BOOL)commitExpressionsByConvertingLocalSymbolsToGlobal;

// Torna YES durant el commit d'expressions. Es pot utilitzar per els holders d'expressions
// per detectar el tipus de commit. El dos metodes son mutualment exclusius
- (BOOL)isCommiting;
- (BOOL)isCommitingWithMoveToGlobal;

// torna les expressions registrades que queden pendents de commit, pot tornar un objecte diferent
// despres de un commit
- (NSMutableArray*)expressions;

// quan hem acabat de comitar expressions hem de cridar aquest metode, el parametre ignore indica
// que volem substituir les referencies no trobades per values vuits sense holder
- (BOOL)finishCommitOutError:(NSError**)outError ignoreMissingSymbols:(BOOL)ignore;

// Substitueix el nom de un simbol la taula de simbols.
// Podem passar NULL en oldSymbol per afegir-ne un de nou
// Podem passar NULL en el newSymbol per eliminar el vell
// Torna NO i un error si el newSymbol ja hi es a la taula ( NOR) 
// Inserta i torna un simbol modificat a partir del newSymbol, si ja hi es a la taula
// Causa una excepcio si el oldSimbol es a la taula pero no correspon al holder que se li passa
- (NSString *)replaceGlobalSymbol:(NSString*)oldSymbol withHolder:(id<ValueHolder>)holder 
        bySymbol:(NSString*)newSymbol; //outError:(NSError**)error;


// Metode de conveniencia per canviar i comitar una expressio a partir d'una string
- (BOOL)updateExpression:(SWExpression*)expr fromString:(NSString*)string outError:(NSError**)error;

// Metode de conveniencia per crear una expressio comitada a partir d'una string
- (SWExpression *)expressionWithSource:(NSString*)string outErrString:(NSString**)outErrStr;

// Metode de conveniencia per crear un SWValue simple a partir del resultat d'evaluar una string
- (SWValue*)valueWithSourceString:(NSString*)string outErrString:(NSString**)outErrStr;



- (int)selectorForMethod:(CFStringRef)name inClassWithSelector:(int)clSel;
- (int)selectorForClass:(CFStringRef)name;

@end






