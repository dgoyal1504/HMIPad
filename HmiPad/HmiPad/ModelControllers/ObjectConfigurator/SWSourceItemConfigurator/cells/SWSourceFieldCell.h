//
//  SWSourceFieldCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWDrawRectCell.h"

@class SWTextField;

extern NSString * const SWSourceFieldCellIdentifier;
extern NSString * const SWSourceFieldCellNibName;

@interface SWSourceFieldCell : SWDrawRectCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet SWTextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
