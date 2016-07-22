//
//  SWAlarmCell.m
//  HmiPad
//
//  Created by Joan Martin on 8/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWAlarmCell.h"
#import "SWColor.h"
#import "UIView+DecoratorView.h"

@implementation SWAlarmCell

#pragma mark Overriden Methods

- (void)reloadRightDetailTextLabel
{
    [super reloadRightDetailTextLabel];

    SWAlarm *alarm = self.modelObject;
    BOOL active = alarm.active.valueAsBool;
    
    ItemDecorationType type = (active?ItemDecorationTypeRed:ItemDecorationTypeGray);
    UIView *accessory = [UIView decoratedViewWithFrame:CGRectMake(0,0,12,12) forSourceItemDecoration:type animated:YES];
    
    [self setAccessoryView:accessory];
}


#pragma mark overrides

- (void)didStartObservation
{
    [super didStartObservation];
    SWAlarm *alarm = self.modelObject;
// mmmm
//    [alarm.label addObserver:self];
//    [alarm.comment addObserver:self];
    [alarm.active addObserver:self];
}

- (void)didEndObservation
{
    [super didEndObservation];
    SWAlarm *alarm = self.modelObject;
// mmmm
//    [alarm.label removeObserver:self];
//    [alarm.comment removeObserver:self];
    [alarm.active removeObserver:self];
}



#pragma mark ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWAlarm *alarm = self.modelObject;
  
// mmmm
//    if (value == alarm.label)
//        [self reloadDetailTextLabel];
//        
//    else if (value == alarm.comment)
//        [self reloadDetailTextLabel];
//
//    else
    if (value == alarm.active )
    {
        if ( changed )
            [self reloadRightDetailTextLabel];
    }
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
