//
//  SWUplodadProgressCell.m
//  HmiPad
//
//  Created by Joan on 02/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWUploadActivationCodeCell.h"

@implementation SWUploadActivationCodeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)emailActivationCodeAction:(id)sender
{
    [_delegate activationCodeCellDidTouchEmail:self];
}

@end
