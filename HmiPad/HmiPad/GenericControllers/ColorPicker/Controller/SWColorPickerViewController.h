//
//  SWColorPickerViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/15/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ILColorPickerView.h"
#import "SWColorPickerDelegate.h"

@class SWColorPickerViewController;

@interface SWColorPickerViewController : UIViewController <ILColorPickerViewDelegate, SWColorPicker>

- (id)initWithColor:(UIColor*)color;

@property (weak, nonatomic) IBOutlet ILColorPickerView *privateColorPickerView;
@property (weak, nonatomic) IBOutlet UIView *coloredView;
//@property (strong, nonatomic) IBOutlet UIView *colorPickerView;

@property (nonatomic, weak) id<SWColorPickerDelegate> delegate;

@end
