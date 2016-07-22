//
//  SWTableViewMessage.m
//  HmiPad
//
//  Created by Joan on 25/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTableViewMessage.h"
#import "SWColor.h"



@implementation SWTableViewMessage
{
    TableViewMessageStyle _style;
    NSString *_internalEmptyMessage;
    BOOL _empty;
}

#define kHOffset 14
#define kTopOffset 8
#define kBotOffset 8
#define kPlainVGap 4 



- (id)initWithFooterStyle:(TableViewMessageStyle)style initialWidth:(CGFloat)width
{
    const int InitHeight = 300 ;
    self = [super initWithFrame:CGRectMake(0,0,width,InitHeight)];
    if (self )
    {
        _style = style;
        _empty = NO;
        CGRect messageFrame = CGRectMake(kHOffset, kTopOffset, width-2*kHOffset, InitHeight-kBotOffset-kTopOffset);
        _messageViewLabel = [[UILabel alloc] initWithFrame:messageFrame];
        [_messageViewLabel setTextAlignment:NSTextAlignmentCenter];
        [_messageViewLabel setBackgroundColor:[UIColor clearColor]];
       // [_messageViewLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
       
       
        if ( IS_IOS7 )
        {
            //[_messageViewLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
            [_messageViewLabel setFont:[UIFont systemFontOfSize:13]];
        }
        else
        {
            [_messageViewLabel setFont:[UIFont systemFontOfSize:13]];
        }
        [_messageViewLabel setShadowOffset:CGSizeMake(0,1)];
        //[_messageViewLabel setShadowColor:[UIColor whiteColor]];
        [_messageViewLabel setNumberOfLines:0];
    
        [self setDarkContext:NO];
        [self setBackgroundColor:[UIColor clearColor] ];
        [self setAutoresizesSubviews:YES];
        
        //[self setAutoresizingMask:( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin )];
        //[self setAutoresizingMask:( UIViewAutoresizingNone)];
        [self addSubview:_messageViewLabel];

    }
    return self;
}


- (id)initForSectionFooter
{
    return [self initWithFooterStyle:TableViewMessageStyleSectionFooter initialWidth:320];
}


- (id)initForPlainSectionFooter
{
    return [self initWithFooterStyle:TableViewMessageStylePlainSectionFooter initialWidth:320];
}


- (id)initForTableFooter
{
    return [self initWithFooterStyle:TableViewMessageStyleTableFooter initialWidth:320];
}

- (id)initForTableHeader
{
    return [self initWithFooterStyle:TableViewMessageStyleTableHeader initialWidth:320];
}


- (void)drawRect:(CGRect)rect 
{
    if ( (_style == TableViewMessageStyleTableFooter || _style == TableViewMessageStyleTableHeader) && _empty == NO )
    {
        CGContextRef theContext = UIGraphicsGetCurrentContext();
        CGRect theRect = CGRectInset( [self bounds], 0, 0 );
    
        CGFloat lineWidth = 20;
        CGFloat shadowBlur = 0;  // 2.5
        
//        UIColor *shadowColor = [UIColor colorWithWhite:0.0f alpha:0.333f];
//        CGContextSetShadowWithColor( theContext, CGSizeMake(0,lineWidth/4), lineWidth/4, shadowColor.CGColor );
        
        
        UIColor *shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), shadowBlur, shadowColor.CGColor );
        
        CGContextSetLineWidth(theContext, lineWidth );
     
        UIColor *strokeColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        //UIColor *strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        CGContextSetStrokeColorWithColor( theContext, strokeColor.CGColor );
    
        // dibuxem a una part no visible, pero una linea de 1 punt (NO) + la sombra es formara en part visible
        CGContextMoveToPoint(theContext, 0.0f, /*0.5f*/-lineWidth/2 );
        CGContextAddLineToPoint(theContext, theRect.size.width, /*0.5f*/-lineWidth/2);   //2
    
        //setPathToRoundedRect(theRect, 8, 0, theContext);
        CGContextStrokePath(theContext);
        
//        CGContextSetShadowWithColor(theContext, CGSizeMake(0,0), 0, NULL);
//        CGContextSetLineWidth(theContext, 1 );
//        strokeColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
//        CGContextSetStrokeColorWithColor( theContext, strokeColor.CGColor );
//        
//        CGContextMoveToPoint(theContext, 0.0f, 0.5f );
//        CGContextAddLineToPoint(theContext, theRect.size.width, 0.5f);
//        
//        CGContextStrokePath(theContext);
        
    }
    else if ( _style == TableViewMessageStylePlainSectionFooter )
    {
    
        CGContextRef theContext = UIGraphicsGetCurrentContext();
        CGRect theRect = CGRectInset( [self bounds], 0, 0 );
    
        CGFloat lineWidth = 1;
        CGContextSetLineWidth(theContext, lineWidth );
        
        // linea fosca
        UIColor *strokeColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        CGContextSetStrokeColorWithColor( theContext, strokeColor.CGColor );
        CGContextMoveToPoint(theContext, 0.0f, 0.5f );
        CGContextAddLineToPoint(theContext, theRect.size.width, 0.5f);   //2
        CGContextStrokePath(theContext);
        
        // linea clara
        strokeColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        CGContextSetStrokeColorWithColor( theContext, strokeColor.CGColor );
        CGContextMoveToPoint(theContext, 0.0f, 1.5f );
        CGContextAddLineToPoint(theContext, theRect.size.width, 1.5f);   //2
        CGContextStrokePath(theContext);
    }
    
    [super drawRect:rect];
}


//- (void)layoutSubviewsV
//{
//    CGRect mrect = [self bounds];
//    mrect.origin.x = kHOffset;
//    mrect.origin.y = kTopOffset; 
//    mrect.size.width -= 2*kHOffset;
//    mrect.size.height -= kTopOffset+kBotOffset;
//    [_messageViewLabel setFrame:mrect];
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( (_style == TableViewMessageStyleTableFooter || _style == TableViewMessageStyleTableHeader) && _empty )
    {
        UIScrollView *superView = (id)[self superview];
        CGRect superBounds = [superView bounds];
        //CGRect superBounds = [self bounds];
        if ( [superView isKindOfClass:[UIScrollView class]] )
        {
            // atencio nomes suportem/tenim en compte els insets verticals
            UIEdgeInsets insets = [superView contentInset];  // sempre es zero, bua.
            superBounds.origin.y = insets.top;
            superBounds.size.height -= insets.top+insets.bottom;
        }
        
        const int hgap = 10;
        const int emptyLabelHeight = 30;
        const int magicNumber = superBounds.size.height/660.0f*60.0f;
        const int messageHeight = [self _getMessageHeightForWidth:superBounds.size.width];
        CGRect imageRect = [_imageView bounds];
        CGFloat totalHeight = imageRect.size.height + hgap + emptyLabelHeight + hgap + messageHeight;
    
        imageRect.origin.x = roundf((superBounds.size.width-imageRect.size.width)/2.0f);
        imageRect.origin.y = superBounds.origin.y + roundf((superBounds.size.height-totalHeight)/2.0f) - magicNumber;
        [_imageView setFrame:imageRect];
        
        CGRect emptyLabelFrame = CGRectZero;
        emptyLabelFrame.origin.y = imageRect.origin.y+imageRect.size.height+hgap;
        emptyLabelFrame.size.width = superBounds.size.width;
        emptyLabelFrame.size.height = emptyLabelHeight;
        [_emptyLabel setFrame:emptyLabelFrame];
        
        //const int hgap2 = 10;
        CGRect mrect = [self bounds];
        mrect.size.height = messageHeight;
        mrect.origin.x = kHOffset;
        mrect.origin.y = kTopOffset + emptyLabelFrame.origin.y + emptyLabelFrame.size.height+hgap;
        mrect.size.width -= 2*kHOffset;
        [_messageViewLabel setFrame:mrect];
    }
    
    else
    {
        CGRect mrect = [self bounds];
        mrect.size.height = [self _getMessageHeightForWidth:mrect.size.width];
        mrect.origin.x = kHOffset;
        mrect.origin.y = kTopOffset;
        mrect.size.width -= 2*kHOffset;
        [_messageViewLabel setFrame:mrect];
    }
}

- (void)dealloc
{

}


- (CGFloat)_getMessageHeightForWidth:(CGFloat)width
{
    CGFloat height = 0;
    NSString *text = [_messageViewLabel text];
    if ( text.length )
    {
        //CGRect bounds = [self bounds];
        //CGFloat width = self.bounds.size.width;
        CGSize superSize = CGSizeMake( width-2*kHOffset, 500 );
        UIFont *font = [_messageViewLabel font];
        //height = [text sizeWithFont:font constrainedToSize:superSize].height;
        
        height = [text boundingRectWithSize:superSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height;
        
        height = ceil(height);
        if ( _style == TableViewMessageStyleTableFooter ) height += kPlainVGap;
        if ( _style == TableViewMessageStyleTableHeader ) height += kPlainVGap*6;
    }
    return height;
}


- (void)setDarkContext:(BOOL)darkContext
{
    _darkContext = darkContext;
    if ( darkContext)
    {
        [_messageViewLabel setTextColor:[UIColor whiteColor]];
        [_messageViewLabel setShadowOffset:CGSizeMake(0,-1)];
        [_messageViewLabel setShadowColor:[UIColor blackColor]];
    }
    else
    {
        [_messageViewLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
        [_messageViewLabel setShadowOffset:CGSizeMake(0,1)];
        [_messageViewLabel setShadowColor:[UIColor whiteColor]];
    }

}


- (void)_updateMessageViewLabel
{
    NSString *text = _empty?_emptyMessage:_message;
    if ( text == nil ) text = _message;

    [_messageViewLabel setText:text];
    
    CGRect rect = [self frame];
    CGFloat width = rect.size.width;
    CGFloat height = [self _getMessageHeightForWidth:width];
        
    rect.size.height = height+kTopOffset+kBotOffset;
    [self setFrame:rect];
    [self setNeedsLayout];
}

- (void)setMessage:(NSString*)msg
{
    if ( _message == msg ) return;
    _message = msg;
    
    [self _updateMessageViewLabel];
}


- (void)setEmptyMessage:(NSString *)emptyMessage
{
    if ( _emptyMessage == emptyMessage ) return;
    _emptyMessage = emptyMessage;
    
    [self _updateMessageViewLabel];
}

- (void)showForEmptyTable:(BOOL)empty
{
    if ( (!empty) == (!_empty) )
        return ;
        
    _empty = empty;
    [self _updateMessageViewLabel];
    
    if ( empty )
    {
        //_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubbleSplash.png"]];
        _imageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] init]];
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,30)];
        
        [_emptyLabel setBackgroundColor:[UIColor clearColor]];
        [_emptyLabel setShadowOffset:CGSizeMake(0,1)];
        [_emptyLabel setShadowColor:[UIColor whiteColor]];
        _emptyLabel.text = _emptyTitle;
        if ( IS_IOS7 )
        {
            //_emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            _emptyLabel.font = [UIFont boldSystemFontOfSize:17];
        }
        else
        {
            _emptyLabel.font = [UIFont boldSystemFontOfSize:17];
        }
        _emptyLabel.textColor = UIColorWithRgb(SystemDarkerBlueColor);
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_imageView];
        [self addSubview:_emptyLabel];
    }
    else
    {
        [_imageView removeFromSuperview];
        [_emptyLabel removeFromSuperview];
        _imageView = nil;
        _emptyLabel = nil;
    }
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}


- (NSString*)message
{
    return _message;
}


- (UILabel*)messageViewLabel
{
    return _messageViewLabel;
}


- (CGFloat)getMessageHeight
{
//    UIScrollView *superView = (id)[self superview];
//    CGRect superBounds = [superView bounds];
//    
//    CGFloat width = self.bounds.size.width;
    
    CGRect rect = _messageViewLabel.bounds;
    CGFloat width = rect.size.width + 2*kHOffset;

    NSString *text = _messageViewLabel.text;
    CGFloat height = [text length]?[self _getMessageHeightForWidth:width]+kTopOffset+kBotOffset:0;
    return height;
}


//- (CGFloat)getMessageHeightForWidth
//{
//    return [_message length]?[self _getMessageHeight]+kTopOffset+kBotOffset:0;
//}




@end
