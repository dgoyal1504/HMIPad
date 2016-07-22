//
//  SWEventsViewController.h
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

@class SWEventCenter;
@class ColoredButton;

@interface SWEventsViewController : SWTableViewController
{
    UILabel *infoLabel;
    ColoredButton *ackButton;
}

@property (nonatomic, strong) SWEventCenter *eventCenter;

@end


