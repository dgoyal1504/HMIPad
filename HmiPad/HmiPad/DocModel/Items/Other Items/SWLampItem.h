//
//  SWLampItem.h
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWLampItem : SWItem

@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *blink;
@property (nonatomic, readonly) SWExpression *color;

@end
