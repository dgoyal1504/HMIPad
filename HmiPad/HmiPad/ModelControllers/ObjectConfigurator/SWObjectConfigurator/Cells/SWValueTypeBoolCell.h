//
//  SWValueTypeBoolCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/8/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueCell.h"

extern NSString * const SWValueTypeBoolCellIdentifier;
extern NSString * const SWValueTypeBoolCellNibName;

@interface SWValueTypeBoolCell : SWValueCell

@property (weak, nonatomic) IBOutlet UISwitch *switchView;

- (IBAction)switchValueAction;

@end
