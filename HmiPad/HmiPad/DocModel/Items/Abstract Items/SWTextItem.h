//
//  SWTextItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWTextItem : SWItem

@property (nonatomic, readonly) SWValue *textAlignment;
@property (nonatomic, readonly) SWValue *verticalTextAlignment;
@property (nonatomic, readonly) SWExpression *textColor;
@property (nonatomic, readonly) SWExpression *font;
@property (nonatomic, readonly) SWExpression *fontSize;

@end
