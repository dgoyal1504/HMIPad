//
//  SystemExpressions.m
//  HmiPad_101120
//
//  Created by Joan on 20/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//
#import <objc/message.h>

#import "SystemExpressions.h"
#import "SWExpression.h"


/*
enum
{
    SystemAckButton,
    SystemPulse10s,
    
    SystemKeysTotal
} ;
*/

//------------------------------------------------------------------------------------
//const CFStringRef System = CFSTR( "system" ) ;

/*

#define SystemKeysTotal 6

const CFStringRef SystemAckButton = CFSTR( "$SMAckButton" ) ;
const CFStringRef SystemCommState = CFSTR( "$SMCommState" ) ;
const CFStringRef SystemCurrentPageName = CFSTR( "$SMCurrentPageName" ) ;
const CFStringRef SystemPulse10s = CFSTR( "$SMPulse10s" ) ;
const CFStringRef SystemPulse30s = CFSTR( "$SMPulse30s" ) ;
const CFStringRef SystemPulse60s = CFSTR( "$SMPulse60s" ) ;

*/


//------------------------------------------------------------------------------------

NSString *kAckChangedNotification = @"AckChangedNotification" ;


/*
////////////////////////////////////////////////////////////////////////////////////
#pragma mark SysExpressionsNotificationCenter
////////////////////////////////////////////////////////////////////////////////////

// utilitzem un centre de notificacions especific per diferenciar les notificacions
// del model de les de caracter general

@implementation SysExpressionsNotificationCenter : NSNotificationCenter
{ 
}

//----------------------------------------------------------------------------------
+ (SysExpressionsNotificationCenter *)defaultCenter ;
{
    static SysExpressionsNotificationCenter *snc = nil ;
    if ( snc == nil )
    {
        snc = [[SysExpressionsNotificationCenter alloc] init] ;
    }
    return snc ;
}

@end
*/


////////////////////////////////////////////////////////////////////////////////////
#pragma mark SystemExpressions
////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
typedef struct
{
    CFStringRef name ;
    SEL getSel ;
    SEL refSel ;
    SEL makeSel ;

} SystemExpressionsStruct ;

//------------------------------------------------------------------------------------

static const SystemExpressionsStruct Expressions[] = 
{ 
    { 
        CFSTR( "$SMAckButton" ), 
        @selector( ackExpression ), 
        @selector( ackExpressionRef ), 
        @selector( ackExpressionMake ) 
    },
    { 
        CFSTR( "$SMCommState" ), 
        @selector( commStateExpression ), 
        @selector( commStateExpressionRef ), 
        @selector( commStateExpressionMake )
    },
    { 
        CFSTR( "$SMCurrentPageName" ), 
        @selector( currentPageNameExpression ), 
        @selector( currentPageNameExpressionRef ), 
        @selector( currentPageNameExpressionMake ) 
    },
    { 
        CFSTR( "$SMCurrentUserAccessLevel" ), 
        @selector( currentUserAccessLevelExpression ), 
        @selector( currentUserAccessLevelExpressionRef ), 
        @selector( currentUserAccessLevelExpressionMake ) 
    },
    { 
        CFSTR( "$SMCurrentUserName" ), 
        @selector( currentUserNameExpression ), 
        @selector( currentUserNameExpressionRef ), 
        @selector( currentUserNameExpressionMake )
    },
    { 
        CFSTR( "$SMPulse1s" ), 
        @selector( pulse1Expression ), 
        @selector( pulse1ExpressionRef ), 
        @selector( pulse1ExpressionMake ) 
    },
    { 
        CFSTR( "$SMPulse10s" ), 
        @selector( pulse10Expression ), 
        @selector( pulse10ExpressionRef ), 
        @selector( pulse10ExpressionMake ) 
    },
    { 
        CFSTR( "$SMPulse30s" ), 
        @selector( pulse30Expression ), 
        @selector( pulse30ExpressionRef ),
        @selector( pulse30ExpressionMake )
    },
    { 
        CFSTR( "$SMPulse60s" ), 
        @selector( pulse60Expression ), 
        @selector( pulse60ExpressionRef ), 
        @selector( pulse60ExpressionMake ),
    },
    { 
        CFSTR( "$SMDate" ), 
        @selector( dateTimeExpression ), 
        @selector( dateTimeExpressionRef ), 
        @selector( dateTimeExpressionMake ),
    },
    { 
        CFSTR( "$SMActiveAlarmCount" ), 
        @selector( activeAlarmCountExpression ), 
        @selector( activeAlarmCountExpressionRef ), 
        @selector( activeAlarmCountExpressionMake ),
    },
    { 
        CFSTR( "$SMUnacknowledgedAlarmCount" ), 
        @selector( unacknowledgedAlarmCountExpression ), 
        @selector( unacknowledgedAlarmCountExpressionRef ), 
        @selector( unacknowledgedAlarmCountExpressionMake ),
    },
    
    
    /*{ 
        CFSTR( "Math.sin" ), 
        @selector( math_sinExpression ),
        @selector( math_sinExpressionRef ),
        @selector( math_sinExpressionMake ) 
    },
    */
} ;

const int ExpressionsCount = sizeof(Expressions)/sizeof(Expressions[0]) ;

//------------------------------------------------------------------------------------

static const SystemExpressionsStruct WExpressions[] = 
{ 
    { 
        CFSTR( "$SMCurrentPageName" ), 
        @selector( currentPageNameExpression ), 
        @selector( currentPageNameExpressionRef ), 
        @selector( currentPageNameExpressionMake ) 
    },
} ;

const int WExpressionsCount = sizeof(WExpressions)/sizeof(WExpressions[0]) ;

//------------------------------------------------------------------------------------
@interface SystemExpressions()

- (void)mayBeStartPulse1Timer ;

@end


//------------------------------------------------------------------------------------
@implementation SystemExpressions


//------------------------------------------------------------------------------------
- (CFDictionaryRef)symbolTable
{
    if ( symbolTable == nil )
    {
        CFStringRef keys[ExpressionsCount] ; 
        CFTypeRef values[ExpressionsCount] ;
        
        for ( int i=0 ; i<ExpressionsCount ; i++ ) 
        {
            keys[i] = Expressions[i].name ;
            values[i] = (__bridge CFTypeRef)self ;
        }
        
        symbolTable = CFDictionaryCreate( NULL, (const void **)keys, values, ExpressionsCount, &kCFTypeDictionaryKeyCallBacks, NULL) ;
    }
    
    return symbolTable ;
}


//------------------------------------------------------------------------------------
- (void)dealloc
{
    NSLog( @"system expressions dealloc" ) ;
    if ( pulse1Source ) dispatch_source_cancel( pulse1Source ) ;
    if ( dateFormatter ) CFRelease( dateFormatter ) ;
    
    for ( int i=0; i<ExpressionsCount ; i++ )
    {
        SEL getSel = Expressions[i].getSel ;
        //SWExpression *expr = [self performSelector:getSel] ;   // aixo crea un warning amb ARC !
        SWExpression *expr = objc_msgSend( self, getSel ) ;
        [expr setHolder:nil] ;   /*, [expr release] ;*/
    }
    
    if ( symbolTable ) CFRelease( symbolTable ) ;
//    [super dealloc] ;
}




////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark systemExpression
////////////////////////////////////////////////////////////////////////////////////////////

/*
//------------------------------------------------------------------------------------
- (ExpressionBase *)systemExpression
{
    if ( systemExpression == nil )
    {
        systemExpression = [[ExpressionBase alloc] initWithIndirectValue:self] ;
        [systemExpression setHolder:self] ;
    }
    return systemExpression ;
}
*/


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ackExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)ackExpressionMake
{
    if ( ackExpression == nil )
    {
        ackExpression = [[SWExpression alloc] initWithDouble:0] ;
        [ackExpression setHolder:self] ;
    }
    return ackExpression ;
}

- ( __unsafe_unretained SWExpression ** )ackExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &ackExpression ;
}

- (SWExpression*)ackExpression
{
    return ackExpression ;
}



////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark commStateExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)commStateExpressionMake
{
    if ( commStateExpression == nil )
    {
        commStateExpression = [[SWExpression alloc] initWithDouble:0] ;
        [commStateExpression setHolder:self] ;
    }
    return commStateExpression ;
}

- (__unsafe_unretained SWExpression **)commStateExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &commStateExpression ;
}

- (SWExpression*)commStateExpression
{
    return commStateExpression ;
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark currentPageNameExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)currentPageNameExpressionMake
{
    if ( currentPageNameExpression == nil )
    {
        currentPageNameExpression = [[SWExpression alloc] initAsMutableCluster] ;
        [currentPageNameExpression setHolder:self] ;
    }
    return currentPageNameExpression ;
}

- (__unsafe_unretained SWExpression **)currentPageNameExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &currentPageNameExpression ;
}

- (SWExpression*)currentPageNameExpression
{
    return currentPageNameExpression ;
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark currentUserAccessLevelExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)currentUserAccessLevelExpressionMake
{
    if ( currentUserAccessLevelExpression == nil )
    {
        currentUserAccessLevelExpression = [[SWExpression alloc] initWithDouble:0] ;
        [currentUserAccessLevelExpression setHolder:self] ;
    }
    return currentUserAccessLevelExpression ;
}

- (__unsafe_unretained SWExpression **)currentUserAccessLevelExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &currentUserAccessLevelExpression ;
}

- (SWExpression*)currentUserAccessLevelExpression
{
    return currentUserAccessLevelExpression ;
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark currentUserNameExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)currentUserNameExpressionMake
{
    if ( currentUserNameExpression == nil )
    {
        currentUserNameExpression = [[SWExpression alloc] initWithString:@""] ;
        [currentUserNameExpression setHolder:self] ;
    }
    return currentUserNameExpression ;
}

- (__unsafe_unretained SWExpression **)currentUserNameExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &currentUserNameExpression ;
}

- (SWExpression*)currentUserNameExpression
{
    return currentUserNameExpression ;
}





////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark activeAlarmCountExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)activeAlarmCountExpressionMake
{
    if ( activeAlarmCountExpression == nil )
    {
        activeAlarmCountExpression = [[SWExpression alloc] initWithDouble:0] ;
        [activeAlarmCountExpression setHolder:self] ;
    }
    return activeAlarmCountExpression ;
}

- (__unsafe_unretained SWExpression **)activeAlarmCountExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &activeAlarmCountExpression ;
}

- (SWExpression*)activeAlarmCountExpression
{
    return activeAlarmCountExpression ;
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark unacknowledgedAlarmCountExpression
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)unacknowledgedAlarmCountExpressionMake
{
    if ( unacknowledgedAlarmCountExpression == nil )
    {
        unacknowledgedAlarmCountExpression = [[SWExpression alloc] initWithDouble:0] ;
        [unacknowledgedAlarmCountExpression setHolder:self] ;
    }
    return unacknowledgedAlarmCountExpression ;
}

- (__unsafe_unretained SWExpression **)unacknowledgedAlarmCountExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &unacknowledgedAlarmCountExpression ;
}

- (SWExpression*)unacknowledgedAlarmCountExpression
{
    return unacknowledgedAlarmCountExpression ;
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark pulseExpressions
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (SWExpression*)pulse1ExpressionMake
{
    if ( pulse1Expression == nil )
    {
        pulse1Expression = [[SWExpression alloc] initWithDouble:0] ;
        p1ea = (UInt32)pulse1Expression ;
        [pulse1Expression setHolder:self] ;
        [self mayBeStartPulse1Timer] ;
    }

    return pulse1Expression ;
}

- (__unsafe_unretained SWExpression **)pulse1ExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &pulse1Expression ;
}

- (SWExpression*)pulse1Expression
{
    return pulse1Expression ;
}

//------------------------------------------------------------------------------------
- (SWExpression*)pulse10ExpressionMake
{
    if ( pulse10Expression == nil )
    {
        pulse10Expression = [[SWExpression alloc] initWithDouble:0] ;
        [pulse10Expression setHolder:self] ;
        [self mayBeStartPulse1Timer] ;
    }

    return pulse10Expression ;
}

- (__unsafe_unretained SWExpression **)pulse10ExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &pulse10Expression ;
}

- (SWExpression*)pulse10Expression
{
    return pulse10Expression ;
}

//------------------------------------------------------------------------------------
- (SWExpression*)pulse30ExpressionMake
{
    if ( pulse30Expression == nil )
    {
        pulse30Expression = [[SWExpression alloc] initWithDouble:0] ;
        [pulse30Expression setHolder:self] ;
        [self mayBeStartPulse1Timer] ;
    }

    return pulse30Expression ;
}

- (__unsafe_unretained SWExpression **)pulse30ExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &pulse30Expression ;
}

- (SWExpression*)pulse30Expression
{
    return pulse30Expression ;
}

//------------------------------------------------------------------------------------
- (SWExpression*)pulse60ExpressionMake
{
    if ( pulse60Expression == nil )
    {
        pulse60Expression = [[SWExpression alloc] initWithDouble:0] ;
        [pulse60Expression setHolder:self] ;
        [self mayBeStartPulse1Timer] ;
    }

    return pulse60Expression ;
}

- (__unsafe_unretained SWExpression **)pulse60ExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &pulse60Expression ;
}

- (SWExpression*)pulse60Expression
{
    return pulse60Expression ;
}





//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark time/date Expressions
//////////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (CFDateFormatterRef)dateFormatter
{
    if ( dateFormatter == NULL )
    {
        dateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle ) ;
        //CFDateFormatterSetFormat( dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss ZZ") ) ;
        CFDateFormatterSetFormat( dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss") ) ;
    }
    return dateFormatter ;
}

//------------------------------------------------------------------------------------
- (SWExpression*)dateTimeExpressionMake
{
    if ( dateTimeExpression == nil )
    {
        dateTimeExpression = [[SWExpression alloc] initWithString:@""] ;
        [dateTimeExpression setHolder:self] ;
        [self mayBeStartPulse1Timer] ;
    }

    return dateTimeExpression ;
}

- (__unsafe_unretained SWExpression **)dateTimeExpressionRef
{
    return (__unsafe_unretained SWExpression **)(void*) &dateTimeExpression ;
}

- (SWExpression*)dateTimeExpression
{
    return dateTimeExpression ;
}


/*
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark math Expressions
//////////////////////////////////////////////////////////////////////////////////////////////////

- (ExpressionBase *)math_sinExpressionMake
{
    if ( math_sinExpression == nil )
    {
        RPNValue rpnValue((UInt32)0) ;
        math_sinExpression = [[ExpressionBase alloc] initWithConstantRpnValue:rpnValue] ;
        [math_sinExpression setHolder:self] ;
    }
    return math_sinExpression ;
}

- (ExpressionBase **)math_sinExpressionRef
{
    return &math_sinExpression ;
}

- (ExpressionBase *)math_sinExpression
{
    return math_sinExpression ;
}

*/


//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark pulse Expressions
//////////////////////////////////////////////////////////////////////////////////////////////////



- (void)evalPulseExpressionsIfNeeded
{
    pulse1Count += 5 ;    // decimes de segon
    
    // pulse 1
    if ( pulse1Expression && pulse1Count%5 == 0 ) // cada 0.5 segons fa un canvi, es a dir el periode es 1
    {
        [pulse1Expression evalWithConstantValue:(pulse1Count%10)!=0] ;
    }
    
    // pulse 10
    if ( pulse10Expression && pulse1Count%50 == 0 ) // cada 5 segons fa un canvi, es a dir el periode es 10
    {
        [pulse10Expression evalWithConstantValue:(pulse1Count%100)!=0] ;
    }

    // pulse 30
    if ( pulse30Expression && pulse1Count%150 == 0 ) 
    {
        [pulse30Expression evalWithConstantValue:(pulse1Count%300)!=0] ;
    }
    
    // pulse 60
    if ( pulse60Expression && pulse1Count%300 == 0 ) 
    {
        [pulse60Expression evalWithConstantValue:(pulse1Count%600)!=0] ;
    }
    
    // date/time
    if ( dateTimeExpression && pulse1Count%10 == 0) 
    {
        CFAbsoluteTime timeStamp = CFAbsoluteTimeGetCurrent() ;
        CFDateRef date = CFDateCreate( NULL, timeStamp ) ;
        CFStringRef dateFormatedStr = CFDateFormatterCreateStringWithDate( NULL, [self dateFormatter], date ) ;    
    
        [dateTimeExpression evalWithStringConstant:dateFormatedStr] ;

        CFRelease( dateFormatedStr ) ;
        CFRelease( date ) ; 
    }
}


/*
//---------------------------------------------------------------------------------------
// El temps de polling ha acabat, cridem el delegat
//
static void PollingTimerCallback ( CFRunLoopTimerRef timer, void *info )
{
    SystemExpressions *tis = (SystemExpressions *)info ;
    [tis evalPulseExpressionsIfNeeded] ;
}
*/

/*
//------------------------------------------------------------------------------------
- (void)mayBeStartPulse1Timer
{
    if ( ! ( pulse1Expression || pulse10Expression || pulse30Expression || pulse60Expression || dateTimeExpression ) ) return ;
    
    if ( pulse1Timer == NULL )
    {
        CFTimeInterval fTime = 0.5 ; // 0.5 segons ;
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent() ;
        CFRunLoopTimerContext tContext = { 0, self, NULL, NULL, NULL } ;    

        pulse1Timer = CFRunLoopTimerCreate( 
            NULL,                     // CFAllocatorRef allocator,
            now+fTime,                    // CFAbsoluteTime
            fTime,                    // CFTimeInterval, 1e10 són més de 300 anys
            0, 0,                     // CFOptionFlags, CFIndex
            PollingTimerCallback,     // CFRunLoopTimerCallBack
            &tContext ) ;             // CFRunLoopTimerContext

        CFRunLoopAddTimer (
            CFRunLoopGetCurrent(),      //  CFRunLoopRef rl
            pulse1Timer,               //  CFRunLoopTimerRef timer,
            kCFRunLoopDefaultMode ) ;   //  CFStringRef mode
        
        if ( pulse1Timer ) CFRelease( pulse1Timer ) ; // es retingut per el runLoop, per tant no cal retenirlo nosaltres
        pulse1Count = 0 ;
    }
}
*/


- (void)mayBeStartPulse1Timer
{
    if ( ! ( pulse1Expression || pulse10Expression || pulse30Expression || pulse60Expression || dateTimeExpression ) ) return ;
    
    if ( pulse1Source == NULL )
    {
        pulse1Source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_current_queue());
    
        dispatch_source_t thePulse1Source = pulse1Source;
        __unsafe_unretained id theSelf = self ;// evitem el retain cycle entre pulse1Source i el self, en el dealloc eliminem el pulse1Source

        dispatch_source_set_event_handler( pulse1Source, 
        ^{
            @autoreleasepool {
                [theSelf evalPulseExpressionsIfNeeded] ;
            }
        });

        dispatch_source_set_cancel_handler( pulse1Source, 
        ^{
            dispatch_release( thePulse1Source );
        });
    

        dispatch_resume( pulse1Source );
        dispatch_source_set_timer( pulse1Source, DISPATCH_TIME_NOW, NSEC_PER_SEC/2, 0 );      // 0.5 seg
        pulse1Count = 0 ;
    }
}







////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark protocol ExpressionHolder
////////////////////////////////////////////////////////////////////////////////////////////


//-----------------------------------------------------------------------------
// Torna la expressio corresponent segons el id que es un NSSTring
//- (ExpressionBase *)selfValueExpressionWithId:(id)strId
- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)prop
{
    for ( int i=0 ; i<ExpressionsCount ; i++ )
    {
        CFStringRef name = Expressions[i].name ;
        if ( CFEqual( (__bridge CFStringRef)sym, name ) )
        {
            SEL makeSel = Expressions[i].makeSel ;
            //return [self performSelector:makeSel] ;
            SWExpression *expr = objc_msgSend( self, makeSel ) ;
            NSLog( @"valueWithSymbol: %@", expr ) ;
            return expr ;
        }
    }
    return nil ;
}

//-----------------------------------------------------------------------------
- (NSString *)symbolForValue:(SWValue*)value
{
    for ( int i=0 ; i<ExpressionsCount ; i++ )
    {
        SEL getSel = Expressions[i].getSel ;
        __unsafe_unretained SWExpression *expr = objc_msgSend( self, getSel ) ;
        //NSLog( @"symbolForValue: %@", expr ) ;
        //SWExpression *expr = [self performSelector:getSel] ;
        if ( value == expr )
        {
            return (__bridge id)Expressions[i].name ;
        }
    }
    return @"<UnknownSystemExpr>" ;
}

//-----------------------------------------------------------------------------
- (NSString *)propertyForExpression:(SWExpression*)theExpr
{
    return nil ;
}

//-----------------------------------------------------------------------------
// Torna la expressio per escriure corresponent segons el id que es un NSSTring
- (SWExpression*)selfValueWExpressionWithId:(id)strId
{
    
    for ( int i=0 ; i<WExpressionsCount ; i++ )
    {
        CFStringRef name = WExpressions[i].name ;
        if ( CFEqual( (__bridge CFTypeRef)strId, name ) )
        {
            SEL makeSel = WExpressions[i].makeSel ;
            //return [self performSelector:makeSel] ;
            return objc_msgSend( self, makeSel ) ;
        }
    }
    return nil ;
}


//-----------------------------------------------------------------------------
- (NSString *)identifier
{
    // l'objecte globalExpression no conte en si mateix cap valor
    return @"System Value" ;   // localitzar
}




////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark protocol QuickCoder
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init] ;
    
    for ( int i=0; i<ExpressionsCount ; i++ )
    {
        SEL refSel = Expressions[i].refSel ;
        //SWExpression **expr = (SWExpression **)[self performSelector:refSel] ;
//        SWExpression * __strong *expr = (SWExpression * __strong *)(__bridge void*)objc_msgSend( self, refSel ) ;
//        *expr = [decoder decodeObject] ; // retain] ;
    
        
        __unsafe_unretained SWExpression** e = (__unsafe_unretained SWExpression **)(__bridge void*)objc_msgSend( self, refSel ) ;
        SWExpression *theExpr = [decoder decodeObject] ;
        NSLog( @"theExpr %@", theExpr ) ;
        if ( theExpr ) CFRetain( (__bridge CFTypeRef)theExpr ) ;
        *e = theExpr ;
        
        
    }
    
    [self mayBeStartPulse1Timer] ; // forcem la inicialitzacio del timer

    return self ;
}

//------------------------------------------------------------------------------------
- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    //[super encodeWithCoder:encoder] commented out because NSObject does not implement NSCoding

/*
    [encoder encodeObject:ackExpression] ;
    [encoder encodeObject:commStateExpression] ;
    [encoder encodeObject:pulse10Expression] ;
    [encoder encodeObject:pulse30Expression] ;
    [encoder encodeObject:pulse60Expression] ; */
    
    for ( int i=0; i<ExpressionsCount ; i++ )
    {
        SEL getSel = Expressions[i].getSel ;
        //SWExpression *expr = [self performSelector:getSel] ;
//        SWExpression *expr = objc_msgSend( self, getSel ) ;
//        [encoder encodeObject:expr] ;
        
        
        __unsafe_unretained SWExpression *expr = objc_msgSend( self, getSel ) ;
        [encoder encodeObject:expr] ;
    }
    
}

@end
