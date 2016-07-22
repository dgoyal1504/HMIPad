//
//  SWLabelItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTextItem.h"

@interface SWLabelItem : SWTextItem

@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *format;
//@property (nonatomic, readonly) SWValue *verticalTextAlignment;

@end
