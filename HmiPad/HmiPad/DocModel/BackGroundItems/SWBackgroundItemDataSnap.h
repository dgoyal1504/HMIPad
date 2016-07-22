//
//  SWBackgroundItemDataSnap.h
//  HmiPad
//
//  Created by Joan on 26/05/14.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItem.h"

@interface SWBackgroundItemDataSnap : SWBackgroundItem

@property (nonatomic,readonly) SWValue *snapValue;
@property (nonatomic,readonly) SWExpression *snap;
@property (nonatomic,readonly) SWExpression *inputValue;

@end
