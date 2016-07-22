//
//  SWPropertyBasicEditableCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueEditableCell.h"
#import "RoundedTextView.h"

NSString * const SWValueEditableCellIdentifier = @"ValueEditableCellIdentifier";
NSString * const SWValueEditableCellNibName = @"SWValueEditableCell";

@implementation SWValueEditableCell

@synthesize textField = _textField;

#pragma mark Overriden Methods

- (void)doInit
{
    [super doInit];
    [(id)_textField setTextAlignment:UITextAlignmentRight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectName = _valuePropertyLabel.frame;
    CGRect rectExpr = _textField.frame;
    
    CGSize size = [_valuePropertyLabel.text sizeWithFont:_valuePropertyLabel.font];
    rectName.size.width = size.width;
    
    _valuePropertyLabel.frame = rectName;
    
    const CGFloat gap = 10;
    CGFloat maxAtLeft = rectName.origin.x + size.width + gap;
    rectExpr.size.width = rectExpr.origin.x + rectExpr.size.width - maxAtLeft;
    rectExpr.origin.x = maxAtLeft;
    
    _textField.frame = rectExpr;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    CGRect leftRect = _valuePropertyLabel.frame;
//    CGRect rightRect = _textField.frame;
//    
//    CGFloat boundsWidth = self.contentView.bounds.size.width;
//    CGFloat rightWidth = [_textField sizeThatFitsWidth:boundsWidth].width;
//    CGFloat leftWidth = [_valuePropertyLabel.text sizeWithFont:_valuePropertyLabel.font].width;
//    
//    
//    
//    leftRect.size.width = leftWidth;
//    _valuePropertyLabel.frame = leftRect;
//    
//    
//    rightRect.origin.x = rightRect.origin.x + rightRect.size.width - rightWidth;
//    rightRect.size.width = rightWidth;
//    
////    const CGFloat gap = 10;
////    CGFloat maxAtLeft = leftRect.origin.x + leftWidth + gap;
////    rightRect.size.width = rightRect.origin.x + rightRect.size.width - maxAtLeft;
////    rightRect.origin.x = maxAtLeft;
//    
//    _textField.frame = rightRect;
//}

- (void)refreshValue
{
    [super refreshValue];
    
    NSString *string = [_value getSourceString];
    
    if ( _textField.tag != 1 )     // ooo         <-------- (JMH) ¿¿¿¿¿?????
    {
        _textField.text = string;
    }
    [self setNeedsLayout];
}

@end
