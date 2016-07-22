//
//  SystemExpressions.h
//  HmiPad_101120
//
//  Created by Joan on 20/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SWObject.h"



// DEPRECATED, DO NOT USE //



//////////////////////////////////////////////////////////////////////////////////////
#pragma mark SystemExpressions
//////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
@interface SystemExpressions : SWObject<QuickCoding,ValueHolder>
//{
//    dispatch_source_t pulse1Source ;
//    
//    int pulse1Count ;
////    SWExpression *pulse1Expression ;
////    SWExpression *pulse10Expression ;
////    SWExpression *pulse30Expression ;
////    SWExpression *pulse60Expression ;
//    
//    CFDateFormatterRef dateFormatter ;
////    SWExpression *dateTimeExpression ;
//    
//    CFDictionaryRef symbolTable ; // conte parelles CFStringRef, ExpressionHolder
//    RpnBuilder *builder;
//}


@property (nonatomic,readonly) SWValue *pulse1Expression;
@property (nonatomic,readonly) SWValue *pulse10Expression;
@property (nonatomic,readonly) SWValue *pulse30Expression;
@property (nonatomic,readonly) SWValue *pulse60Expression;
@property (nonatomic,readonly) SWValue *ackExpression;
@property (nonatomic,readonly) SWValue *dateTimeExpression;
@property (nonatomic,readonly) SWValue *commStateExpression;
@property (nonatomic,readonly) SWValue *currentUserAccessLevelExpression;
@property (nonatomic,readonly) SWValue *activeAlarmCountExpression;
@property (nonatomic,readonly) SWValue *unacknowledgedAlarmCountExpression;
@property (nonatomic,readonly) SWValue *currentPageNameExpression;
@property (nonatomic,readonly) SWValue *currentUserNameExpression;


- (id)initWithBuilder:(RpnBuilder *)builder;
- (CFDictionaryRef)symbolTable ;

@end
