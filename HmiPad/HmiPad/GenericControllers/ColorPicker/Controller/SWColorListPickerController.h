//
//  SWColorListPickerController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/25/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWColorPickerDelegate.h"
#import "SWTableViewController.h"

@interface SWColorListPickerController : SWTableViewController <SWColorPicker>
{
    NSArray *_colors;
    NSArray *_titles;
}

- (id)initWithStyle:(UITableViewStyle)style andColor:(UIColor*)color;

@property (nonatomic, weak) id <SWColorPickerDelegate> delegate;

@end
