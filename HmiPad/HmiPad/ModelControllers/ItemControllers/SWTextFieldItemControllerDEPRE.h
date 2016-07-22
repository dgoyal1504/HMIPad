//
//  SWTextFieldController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItemController.h"

//typedef enum {
//    SWTextFieldInputTypeNumeric = 0,
//    SWTextFieldInputTypeString  = 1
//} SWEnumInputType;

@interface SWTextFieldItemController : SWItemController <UITextFieldDelegate>

//@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) UITextField *textField;

@end
