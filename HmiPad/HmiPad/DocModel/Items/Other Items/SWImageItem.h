//
//  SWImageItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@class Expression;

@interface SWImageItem : SWItem

@property (nonatomic, readonly) SWValue *aspectRatioValue;
@property (nonatomic, readonly) SWExpression *imagePathExpression;
@property (nonatomic, readonly) SWExpression *animationDurationExpression;
@property (nonatomic, readonly) SWExpression *tintColorExpression;

@end
