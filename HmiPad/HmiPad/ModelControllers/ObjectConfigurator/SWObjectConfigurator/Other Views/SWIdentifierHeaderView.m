//
//  SWIdentifierHeaderView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWIdentifierHeaderView.h"
#import "RoundedTextView.h"
#import "SWColor.h"

//NSString * const SWIdentifierHeaderViewNibName = @"SWIdentifierHeaderView";

@implementation SWIdentifierHeaderView
@synthesize textField = _textField;
@synthesize detailLabel = _detailLabel;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self)
//    {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//    return self;
//}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self)
//    {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//    return self;
//}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [_textField setTextColor:UIColorWithRgb(TextDefaultColor)];
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
        
    rectName.size.width = size.width;  // alineat a l'esquerra amb la width nova
    
    _detailLabel.frame = rectName;
    
    CGFloat maxAtLeft = rectName.origin.x + size.width;
    rectExpr.size.width = rectExpr.origin.x + rectExpr.size.width - maxAtLeft;
    rectExpr.origin.x = maxAtLeft;
    
    _textField.frame = rectExpr;
    
//    CGSize selfSize = self.bounds.size;
//    CGFloat rightGap = selfSize.width - (rectExpr.origin.x + rectExpr.size.width);
//    rectExpr.size.width = selfSize.width-rightGap-maxAtLeft;
//    
//    rectExpr.origin.x = maxAtLeft;
//    _textField.frame = rectExpr;
    
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    
    UIColor *linecolor1 = nil;
    UIColor *linecolor2 = nil;
    if ( _darkContext )
    {
        linecolor1 = [UIColor colorWithWhite:1.0f alpha:0.1f];
        linecolor2 = [UIColor colorWithWhite:0.0f alpha:0.3f];
        
//        CGFloat h,s,b,a;
//
//        // Crec que aixo no funciona si el color no s'ha creat amb un dels metodes de color rgb
//        [self.backgroundColor getHue:&h saturation:&s brightness:&b alpha:&a];
//        
//        NSLog(@"HUE: %f, SAT: %f, BRIGH: %f, ALPHA: %f",h,s,b,a);
//    
//        linecolor1 = [UIColor colorWithHue:h saturation:(s*0.5f) brightness:(b*1.4f) alpha:a];  // + clar
//        linecolor2 = [UIColor colorWithHue:h saturation:s brightness:(b*0.7f) alpha:a];  // + fosc
    }
    else
    {
        linecolor1 = [UIColor colorWithWhite:1.0f alpha:1.0f];
        linecolor2 = [UIColor colorWithWhite:0.8f alpha:1.0f];
    }
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5 ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5 ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, [linecolor1 CGColor]) ;
    CGContextStrokePath( context ) ;
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5 ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5 ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, [linecolor2 CGColor]) ;
    CGContextStrokePath( context ) ;
    
    [super drawRect:rect] ;
}



@end
