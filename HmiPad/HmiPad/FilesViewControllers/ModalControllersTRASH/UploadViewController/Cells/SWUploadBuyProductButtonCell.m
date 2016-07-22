//
//  SWUploadUploadButtonCell.m
//  HmiPad
//
//  Created by Joan on 02/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWUploadBuyProductButtonCell.h"
#import "SWColor.h"

@implementation SWUploadBuyProductButtonCell



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


- (void)buyProductAction:(id)sender
{
    [_delegate buyProductCellDidTouchBuy:self];
}

@end
