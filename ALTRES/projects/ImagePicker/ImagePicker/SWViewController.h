//
//  SWViewController.h
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWViewController : UIViewController
{
    UIPopoverController *_popover;
}

- (IBAction)foo:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
