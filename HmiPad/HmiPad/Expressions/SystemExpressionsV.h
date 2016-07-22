//
//  SystemExpressions.h
//  HmiPad_101120
//
//  Created by Joan on 20/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickCoder.h"
#import "SWExpressionProtocols.h"
//#import "SWExpression.h"


//------------------------------------------------------------------------------------
//extern NSString *kAckChangedNotification ;


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark SysExpressionsNotificationCenter
//////////////////////////////////////////////////////////////////////////////////////

/*
@interface SysExpressionsNotificationCenter : NSNotificationCenter
{ 
}

+ (SysExpressionsNotificationCenter *)defaultCenter ;

@end
*/



//////////////////////////////////////////////////////////////////////////////////////
#pragma mark SysExpressionsDelegate
//////////////////////////////////////////////////////////////////////////////////////

/*
@protocol SystemExpressionsDelegate
@optional

- (void)pageNameChangedTo:(NSString*)newName ;

@end 
*/


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark SystemExpressions
//////////////////////////////////////////////////////////////////////////////////////



//------------------------------------------------------------------------------------
@interface SystemExpressions : NSObject<QuickCoding,ValueHolder>

{
    //ExpressionBase *systemExpression ; // no s'utilitza
    SWExpression *ackExpression ;
    SWExpression *commStateExpression ;
    SWExpression *currentPageNameExpression ;
    SWExpression *currentUserAccessLevelExpression ;
    SWExpression *currentUserNameExpression ;
    SWExpression *activeAlarmCountExpression ;
    SWExpression *unacknowledgedAlarmCountExpression ;
    
    //SWExpression *currentPageNameWExpression ;
    
    //CFRunLoopTimerRef pulse1Timer ;
    dispatch_source_t pulse1Source ;
    
    int pulse1Count ;
    SWExpression *pulse1Expression ;
    SWExpression *pulse10Expression ;
    SWExpression *pulse30Expression ;
    SWExpression *pulse60Expression ;
    
    CFDateFormatterRef dateFormatter ;
    SWExpression *dateTimeExpression ;
    
    
    //ExpressionBase *math_sinExpression ;
    
    
//    CFArrayRef globalKeys ;
    CFDictionaryRef symbolTable ; // conte parelles CFStringRef, ExpressionHolder
 //   CFDictionaryRef selectorTable ; // conte parelles CFStringRef, index
}


@property (nonatomic,readonly) SWExpression *ackExpression ;
@property (nonatomic,readonly) SWExpression *commStateExpression ;
@property (nonatomic,readonly) SWExpression *currentPageNameExpression ;
@property (nonatomic,readonly) SWExpression *currentUserAccessLevelExpression ;
@property (nonatomic,readonly) SWExpression *currentUserNameExpression ;
@property (nonatomic,readonly) SWExpression *activeAlarmCountExpression ;
@property (nonatomic,readonly) SWExpression *unacknowledgedAlarmCountExpression ;
//@property (nonatomic,readonly) ExpressionBase *pulse10Expression ;
//@property (nonatomic,readonly) ExpressionBase *pulse30Expression ;
//@property (nonatomic,readonly) ExpressionBase *pulse60Expression ;


- (CFDictionaryRef)symbolTable ;

@end
