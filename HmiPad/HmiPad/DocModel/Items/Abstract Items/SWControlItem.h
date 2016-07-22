//
//  SWControlItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/18/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWControlItem : SWItem

@property (nonatomic, readonly) SWExpression *enabled;
@property (nonatomic, readonly) SWExpression *verificationText;
@property (nonatomic, readonly) SWValue *continuousValue;

@end
