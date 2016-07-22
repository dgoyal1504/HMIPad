//
//  SWValueTypeRectCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/8/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueTypeRectCell.h"
#import "RoundedTextView.h"
#import "SWColor.h"

NSString * const SWValueTypeRectCellIdentifier = @"ValueTypeRectCellIdentifier";
NSString * const SWValueTypeRectCellNibName = @"SWValueTypeRectCell";

@implementation SWValueTypeRectCell

@synthesize fieldX = _fieldX;
@synthesize fieldY = _fieldY;
@synthesize fieldWidth = _fieldWidth;
@synthesize fieldHeight = _fieldHeight;

@synthesize resizeMask = _resizeMask;

#pragma mark Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _resizeMask = SWItemResizeMaskFlexibleHeight | SWItemResizeMaskFlexibleWidth;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
//    _fieldX.textView.scrollEnabled = NO;
//    _fieldY.textView.scrollEnabled = NO;
//    _fieldWidth.textView.scrollEnabled = NO;
//    _fieldHeight.textView.scrollEnabled = NO;
    
//    [_originLabel setTextColor:UIColorWithRgb(TextDefaultColor)];
//    [_sizeLabel setTextColor:UIColorWithRgb(TextDefaultColor)];
}

#pragma mark Overriden Methods

- (void)setResizeMask:(SWItemResizeMask)resizeMask
{
    _resizeMask = resizeMask;
    BOOL heightEnabled = NO;
    BOOL widthEnabled = NO;
    
    if (resizeMask & SWItemResizeMaskFlexibleHeight) 
        heightEnabled = YES;
        
    if (resizeMask & SWItemResizeMaskFlexibleWidth)
        widthEnabled = YES;
    
    [(id)_fieldHeight setEnabled:heightEnabled];
    [(id)_fieldWidth setEnabled:widthEnabled];
}

- (void)refreshValue
{
    [super refreshValue];
    
    if (self.value.valueType == SWValueTypeRect)
    {
        CGRect rect = self.value.valueAsCGRect;
        
        _fieldX.smartText = [NSString stringWithFormat:@"%.0f",rect.origin.x];
        _fieldY.smartText = [NSString stringWithFormat:@"%.0f",rect.origin.y];
        _fieldWidth.smartText = [NSString stringWithFormat:@"%.0f",rect.size.width];
        _fieldHeight.smartText = [NSString stringWithFormat:@"%.0f",rect.size.height];
    } 
    else 
    {
        NSString *string = NSLocalizedString(@"Undefined", nil);
        _fieldX.smartText = string;
        _fieldY.smartText = string;
        _fieldWidth.smartText = string;
        _fieldHeight.smartText = string;
    }
}

#pragma mark Public Methods

- (CGRect)rect
{
    return CGRectMake(_fieldX.text.integerValue, _fieldY.text.integerValue, 
                      _fieldWidth.text.integerValue, _fieldHeight.text.integerValue);
}

@end
