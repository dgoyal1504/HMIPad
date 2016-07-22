//
//  SWSystemItemPlayer.h
//  HmiPad
//
//  Created by Joan on 29/05/13.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

@interface SWSystemItemPlayer : SWSystemItem

@property (nonatomic,readonly) SWExpression *play;
@property (nonatomic,readonly) SWExpression *stop;
@property (nonatomic,readonly) SWExpression *repeat;
@property (nonatomic,readonly) SWExpression *title;
@property (nonatomic,readonly) SWExpression *url;

@end
