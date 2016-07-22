//
//  SWKeyboardTouchAndHoldKey.h
//  HmiPad
//
//  Created by Hermes Pique on 5/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWKeyboardKey.h"

@interface SWKeyboardTouchAndHoldKey : SWKeyboardKey

- (void)addTouchAndHoldTarget:(id)target action:(SEL)action;
- (void)cancelHold;

@end
