//
//  SWControlTextItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/18/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItem.h"

@interface SWControlTextItem : SWControlItem

@property (nonatomic, readonly) SWValue *textSelectionStyle;
@property (nonatomic, readonly) SWValue *textAlignment;
@property (nonatomic, readonly) SWExpression *textColor;
@property (nonatomic, readonly) SWExpression *font;
@property (nonatomic, readonly) SWExpression *fontSize;

@end
