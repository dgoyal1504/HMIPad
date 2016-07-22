//
//  SWTapRecognizerItem.h
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWGestureRecognizerItem.h"

@interface SWTapRecognizerItem : SWGestureRecognizerItem

@property (nonatomic, readonly) SWValue *tap;
@property (nonatomic, readonly) SWValue *numberOfTaps;
@property (nonatomic, readonly) SWValue *numberOfTouches;

@end
