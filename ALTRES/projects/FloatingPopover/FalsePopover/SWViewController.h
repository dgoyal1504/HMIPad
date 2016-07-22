//
//  AEViewController.h
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWFloatingPopoverController.h"

@interface SWViewController : UIViewController <SWFloatingPopoverControllerDelegate>
{
    NSMutableSet *_set;
}

- (IBAction)addFloatingPopover:(id)sender;

@end
