//
//  SWModelBrowserCell.m
//  HmiPad
//
//  Created by Joan Martin on 8/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "RoundedLabel.h"
#import "SWColor.h"

#import "SWModelBrowserCell.h"
#import <QuartzCore/QuartzCore.h>


#define kRightDetailTextRightOffset 10
#define kRightDetailTextHorizontalOffset 4

@implementation SWModelBrowserCell
{
    UITableViewCellStyle _style;
    CGRect _rightDetailLabelFrame;
    
   // UIView *_markView;
}

@synthesize rightDetailTextLabel = _rightDetailTextLabel;
//@synthesize accessory = _accessory;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSAssert((style != UITableViewCellStyleValue1 && style != UITableViewCellStyleValue2), @"SWModelBrowserCell no suporta estils Value1 o Value2");
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _style = style;
    
        _rightDetailTextLabel = [[RoundedLabel alloc] init];
        _rightDetailTextLabel.font = [UIFont systemFontOfSize:14];
        _rightDetailTextLabel.textAlignment = NSTextAlignmentCenter;
        _rightDetailTextLabel.backgroundColor = [UIColor clearColor];
        _rightDetailTextLabel.shadowOffset = CGSizeMake(0,0);
        [self setRightDetailTintColor:nil];
        
        [self.contentView addSubview:_rightDetailTextLabel];
        
        //_accessory = SWModelBrowserCellAccessoryTypeNone;
        
        UILabel *textLabel = self.textLabel;
        UILabel *detailTextLabel = self.detailTextLabel;
        
        textLabel.backgroundColor = [UIColor clearColor];
        detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if ( IS_IOS7 )
        {
            [textLabel setFont:[UIFont systemFontOfSize:17]];
            [detailTextLabel setFont:[UIFont systemFontOfSize:11]];
        }
        else
        {
            [textLabel setFont:[UIFont boldSystemFontOfSize:17]];
            [detailTextLabel setFont:[UIFont systemFontOfSize:12]];
        }
    }
    return self;
}



- (void)layoutSubviews
{

    [super layoutSubviews];
    
//    CGRect contentViewFrame = self.contentView.frame;
    CGSize contentSize = self.contentView.bounds.size;
    
    CGRect rightFrame = CGRectZero;
    //rightFrame.size = [_rightDetailTextLabel.text sizeWithFont:_rightDetailTextLabel.font];
    if ( _rightDetailTextLabel )
    {
        rightFrame.size = [_rightDetailTextLabel.text sizeWithAttributes:@{NSFontAttributeName:_rightDetailTextLabel.font}];
        rightFrame.size.width = ceil(rightFrame.size.width);
        rightFrame.size.height = ceil(rightFrame.size.height);
    }
    
    rightFrame.size.width += 2*kRightDetailTextHorizontalOffset;
    rightFrame.origin.y = roundf((contentSize.height - rightFrame.size.height) / 2.0);  // amb el roundf evitem desalineaments
    rightFrame.origin.x = contentSize.width - rightFrame.size.width - kRightDetailTextRightOffset - _rightOffset;
    _rightDetailTextLabel.frame = rightFrame;
    
    // funciona per tots els estils suportats
    {
        UILabel *textLabel = self.textLabel;
        if ( textLabel ) // <- evitem la obtencio de basura en el textLabelFrame en cas que textLabel sigui nil
        {
            CGRect textLabelFrame = textLabel.frame;
            textLabelFrame.size.width = fminf(textLabelFrame.size.width,rightFrame.origin.x-kRightDetailTextRightOffset); // donem prioritat a la visibilitat del _rightDetailTextLabel
            textLabel.frame = textLabelFrame;
        }
        
        UILabel *detailTextLabel = self.detailTextLabel;
        if ( detailTextLabel )
        {
            CGRect detailTextLabelFrame = detailTextLabel.frame;
            detailTextLabelFrame.size.width = fminf(detailTextLabelFrame.size.width,rightFrame.origin.x-kRightDetailTextRightOffset); // donem prioritat a la visibilitat del _rightDetailTextLabel

            detailTextLabel.frame = detailTextLabelFrame;
        }
    }    
}

- (void)setRightDetailTintColor:(UIColor *)color
{
//    UInt32 rgbColor = DarkenedRgbColor(SystemDarkerBlueColor, 1.4f);
    UInt32 rgbColor = OpacifiedRgbColor(0xffffff, 0.0f);  // clear white color
    if ( color ) rgbColor = rgbColorForUIcolor(color);
    
    [_rightDetailTextLabel setRgbTintColor:rgbColor];
}

- (void)setAccessory:(SWModelBrowserCellAccessoryType)accessory
{
    //_accessory = accessory;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    switch ( accessory )
    {
        case SWModelBrowserCellAccessoryTypeNone:
            break;
            
        case SWModelBrowserCellAccessoryTypeDisclosureIndicator:
        case SWModelBrowserCellAccessoryTypeGroupDisclosureIndicator:
            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    
        case SWModelBrowserCellAccessoryTypeGearIndicator:
            break;
            
        case SWModelBrowserCellAccessoryTypeSeekerIndicator:
            break;
    
    }
    self.accessoryType = accessoryType;
    
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];

    UILabel *textLabel = self.textLabel;
    UILabel *detailTextLabel = self.detailTextLabel;
    
    switch ( accessory )
    {
        case SWModelBrowserCellAccessoryTypeGearIndicator:
        case SWModelBrowserCellAccessoryTypeGroupDisclosureIndicator:
        
            selectionView.backgroundColor = UIColorWithRgb(MultipleSelectionColor);
            [self setSelectedBackgroundView:selectionView];  // <-- valid per simple i multiple seleccio
        
            textLabel.highlightedTextColor = textLabel.textColor;
            detailTextLabel.highlightedTextColor = detailTextLabel.textColor;
            break;
            
        case SWModelBrowserCellAccessoryTypeDisclosureIndicator:
        case SWModelBrowserCellAccessoryTypeNone:
            
            [self setSelectedBackgroundView:nil];
            
            selectionView.backgroundColor = UIColorWithRgb(MultipleSelectionColor);
            [self setMultipleSelectionBackgroundView:selectionView];  // <-- nomes multiple selection
        
            if ( IS_IOS7 )
            {
                textLabel.highlightedTextColor = textLabel.textColor;
                detailTextLabel.highlightedTextColor = detailTextLabel.textColor;
            }
            else
            {
                textLabel.highlightedTextColor = [UIColor whiteColor];
                detailTextLabel.highlightedTextColor = [UIColor whiteColor];
            }
            break;
            
        case SWModelBrowserCellAccessoryTypeSeekerIndicator:
        
            selectionView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];   // rgb white
            [self setSelectedBackgroundView:selectionView];  // <-- valid per simple i multiple seleccio
        
            textLabel.highlightedTextColor = UIColorWithRgb(TangerineSelectionColor);
            detailTextLabel.highlightedTextColor = detailTextLabel.textColor;
            break;
    }


//    
//    if ( _accessory == SWModelBrowserCellAccessoryTypeGearIndicator )
//    {
//        [self setSelectedBackgroundView:selectionView];  // <--valid per simple i multiple seleccio
//        
//        textLabel.highlightedTextColor = textLabel.textColor;
//        detailTextLabel.highlightedTextColor = detailTextLabel.textColor;
//    }
//    else if ( _accessory == SWModelBrowserCellAccessoryTypeNone || _accessory == SWModelBrowserCellAccessoryTypeDisclosureIndicator )
//    {
//        [self setSelectedBackgroundView:nil]; 
//        [self setMultipleSelectionBackgroundView:selectionView];
//        
//        if ( IS_IOS7 )
//        {
//            textLabel.highlightedTextColor = textLabel.textColor;
//            detailTextLabel.highlightedTextColor = detailTextLabel.textColor;
//        }
//        else
//        {
//            textLabel.highlightedTextColor = [UIColor whiteColor];
//            detailTextLabel.highlightedTextColor = [UIColor whiteColor];
//        }
//    }

}













//- (void)setMark:(BOOL)mark
//{
//    _mark = mark;
//    _markView.hidden = !mark;
//}
//
//- (void)setMarkTintColor:(UIColor *)markTintColor
//{
//    _markTintColor = markTintColor;
//    _markView.layer.borderColor = markTintColor.CGColor;
//}

@end
