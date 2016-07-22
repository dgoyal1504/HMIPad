//
//  SWPropertyBasicEditableCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueCell.h"

extern NSString * const SWValueEditableCellIdentifier;
extern NSString * const SWValueEditableCellNibName;

@interface SWValueEditableCell : SWValueCell

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
