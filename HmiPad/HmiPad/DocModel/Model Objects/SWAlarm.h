//
//  SWAlarm.h
//  HmiPad
//
//  Created by Lluch Joan on 04/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObject.h"

#import "SWEventHolder.h"

@interface SWAlarm : SWObject <SWEventHolder>

@property (nonatomic, readonly) SWExpression *active;
@property (nonatomic, readonly) SWExpression *group;
@property (nonatomic, readonly) SWExpression *comment;

@property (nonatomic, readonly) SWValue *playDefaultSound;
@property (nonatomic, readonly) SWExpression *url;
@property (nonatomic, readonly) SWValue *showAlert;

@end