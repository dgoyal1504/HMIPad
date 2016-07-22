//
//  SWWebItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWWebItem : SWItem

@property (nonatomic, readonly, strong) SWExpression *urlExpression;
@property (nonatomic, readonly, strong) SWExpression *goBackExpression;
@property (nonatomic, readonly, strong) SWExpression *goForwardExpression;

@end
