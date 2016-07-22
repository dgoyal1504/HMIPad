//
//  SWValueViewerCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueViewerCell.h"

#import "SWModelTypes.h"
#import "SWEnumTypes.h"
#import "SWPropertyDescriptor.h"

#import "SWViewSelectionLayer.h"

#import "SWColor.h"
#import "Drawing.h"

@implementation SWValueViewerCell
{
    SWViewSelectionLayer *_selectionLayer;
}


//@synthesize valueTypeLabel = _valueTypeLabel;




//- (void)_setSelectionStyle
//{
//
////    CGFloat radius = 1;
////    //UIColor *color = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];                      // aqua
////    //UIColor *color = [UIColor colorWithRed:0.5 green:0.75 blue:1 alpha:1];                   // ~= sky
////    UIColor *color = [UIColor colorWithRed:181.0f/255 green:213.0f/255 blue:1 alpha:1];      // selected text
////            
////    //UIColor *color = [UIColor colorWithRed:0.88 green:0.92 blue:0.98 alpha:1];                 // selected text
////    UIImage *image = glossyImageWithRectAndColor( CGRectMake(0, 0, radius*2+2, 44), [color CGColor], NO, radius, 2 );
////    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, radius+1, 0, radius+1)];
////
////
////    UIImageView *selView = [[UIImageView alloc] initWithImage:image];
////    [self setSelectedBackgroundView:selView];
////    
////    _valuePropertyLabel.highlightedTextColor =  _valuePropertyLabel.textColor;
////    _valueTypeLabel.highlightedTextColor =  _valueTypeLabel.textColor;
////    _valueAsStringLabel.highlightedTextColor = _valueAsStringLabel.textColor;
//
//    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
//}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        UIColor *color = UIColorWithRgb(getRgbValueForString(@"lightblue"));
//        view.backgroundColor = color;
//        [self setSelectedBackgroundView:view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //[self _setSelectionStyle];
}



//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    NSLog( @"SWValueViewerCell Selected:%d", selected);
//    
//    BOOL isSelected = [self isSelected];
//    
//    if ( isSelected && !selected )
//    {
//        [_selectionLayer removeFromSuperview];
//    }
//    
//    if ( !isSelected && selected )
//    {
//        if ( _selectionLayer == nil )
//            _selectionLayer = [[SWViewSelectionLayer alloc] init];
//        
//        [self layoutSubviews];
//        [_selectionLayer addToView:self.valuePropertyLabel];
//    }
//    
//    [super setSelected:selected animated:animated];
//}
//
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    [super setHighlighted:highlighted animated:animated];
//    NSLog( @"SWValueViewerCell Highlighted:%d", highlighted);
//}

#pragma mark Overriden Methods

- (void)refreshValue
{
    [super refreshValue];
    
    SWType type = _value.valueDescription.type;
    
    NSString *stringValue = nil;
    
    // En cas de que el tipus semantic indiqui "enumeration", substituim el valor del SWValue per el tipus (en string) de enumeració.
    if (type & SWEnumerationTypeYes) 
    {
        NSInteger option = _value.valueAsInteger;
        stringValue = localizedNameForOption_type(option, type);
        self.valueAsStringLabel.text = stringValue;
    }
    
//    self.valueTypeLabel.text = NSLocalizedStringFromSWValueType(self.value.valueType); // <------- Si volem mostrar el tipus real
//    self.valueTypeLabel.text = NSLocalizedStringFromSWType(type); // <---------------------------- Si volem mostrar el tipus semàntic
}

@end
