//
//  SWSliderItemController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItemController.h"

@interface SWSliderItemController : SWControlItemController

@property (strong, nonatomic) UIProgressView *progressBar;
@property (strong, nonatomic) UISlider *sliderBar;

//- (IBAction)sliderValueChanged:(id)sender;

@end
