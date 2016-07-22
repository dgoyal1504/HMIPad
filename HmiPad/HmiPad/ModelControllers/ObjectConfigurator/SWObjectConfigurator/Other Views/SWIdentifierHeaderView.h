//
//  SWIdentifierHeaderView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWTextField;

//extern NSString * const SWIdentifierHeaderViewNibName;

@interface SWIdentifierHeaderView : UIView //<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet SWTextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic) BOOL darkContext;

@end
