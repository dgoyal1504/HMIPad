//
//  SWSplitViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSplitViewController : UIViewController {
    BOOL _rightControllerLoaded;
    BOOL _leftControllerLoaded;
}

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@end


@interface UIViewController (SWSplitViewController) 

- (SWSplitViewController *)parentSWSplitViewController;
@end