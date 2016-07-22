//
//  SWSourceFieldCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSourceFieldCell.h"
#import "RoundedTextView.h"
#import "SWColor.h"

NSString * const SWSourceFieldCellIdentifier = @"SourceFieldCellIdentifier";
NSString * const SWSourceFieldCellNibName = @"SWSourceFieldCell";

@implementation SWSourceFieldCell
@synthesize textField = _textField;
@synthesize detailLabel = _detailLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
//    if ( IS_IOS7 )
//    {
//        [_detailLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
//    }
}



- (void)_setHighLight
{
    UIColor *color = nil;
    if ( (self.selected || self.highlighted) && self.selectionStyle!=UITableViewCellSelectionStyleNone)
    {
        color = IS_IOS7 ? [UIColor darkGrayColor] : [UIColor whiteColor];
    }
    else
    {
        color = UIColorWithRgb(TextDefaultColor);
    }
    [_textField setTextColor:color];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self _setHighLight];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self _setHighLight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectName = _detailLabel.frame;
    CGRect rectExpr = _textField.frame;
    //CGSize size = [_detailLabel.text sizeWithFont:_detailLabel.font];
    CGSize size = CGSizeZero;
    if ( _detailLabel )
    {
        size = [_detailLabel.text sizeWithAttributes:@{NSFontAttributeName:_detailLabel.font}];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
    }
    rectName.size.width = size.width;
    
    _detailLabel.frame = rectName;
    
    CGFloat maxAtLeft = rectName.origin.x + size.width;
    rectExpr.size.width = rectExpr.origin.x + rectExpr.size.width - maxAtLeft;
    rectExpr.origin.x = maxAtLeft;
    
    _textField.frame = rectExpr;
}

@end
