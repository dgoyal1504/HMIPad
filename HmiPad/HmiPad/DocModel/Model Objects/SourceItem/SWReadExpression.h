//
//  SWReadExpression.h
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWExpression.h"

@class SWSourceNode;
@interface SWReadExpression : SWExpression

@property (nonatomic, weak) SWSourceNode *node;

@end
