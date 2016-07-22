//
//  BubbleView.h
//  iPhoneDomusSwitch_090409
//
//  Created by Joan on 09/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.

#import "BubbleView.h"
#import "SWColor.h"


//////////////////////////////////////////////////////////////////////////////
#pragma mark BubbleView
//////////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------------
@implementation BubbleView

#define ROUND_SIZE  11.0f
#define PX_SIZE 8.0f
#define PY_SIZE 10.0f

#define kPXHOffset (PX_SIZE+ROUND_SIZE)
#define kHOffset 14.0f 
#define kVOffset 12.0f

@synthesize delegate ;

//----------------------------------------------------------------------------
+ (GradientBackgroundData *)gradientBackgroundData
{
    static GradientBackgroundData bgnd =
    {
        1.00f, 1.00f, 1.00f, 0.90f,     // r,g,b,a
        //0.25f, 0.25f, 0.25f, 0.90f,     // r,g,b,a
        0.96f, 1.00f,                   // i,e
        //1.00f, 0.00f,                   // i,e
        80.0f/255.0f, 80.0f/255.0f, 80.0f/255.0f, 0.90f,     // lr,lg,lb,la
        YES, YES, YES, YES,             // left, top, right, bottom
        2.00f,                          // l_width
        ROUND_SIZE,                     // round_size
        PX_SIZE,                        // px_size
        PY_SIZE,                        // py_size
    } ;
    
    return &bgnd ;
}

//----------------------------------------------------------------------------
+ (GradientBackgroundData *)gradientBackgroundData6
{
    static GradientBackgroundData bgnd =
    {
        1.00f, 1.00f, 1.00f, 0.90f,     // r,g,b,a
        //0.25f, 0.25f, 0.25f, 0.90f,     // r,g,b,a
        1.00f, 0.80f,                   // i,e
        //1.00f, 0.00f,                   // i,e
        76.0f/255.0f, 86.0f/255.0f, 108.0f/255.0f, 0.70f,     // lr,lg,lb,la
        YES, YES, YES, YES,             // left, top, right, bottom
        3.00f,                          // l_width
        ROUND_SIZE,                     // round_size
        PX_SIZE,                        // px_size
        PY_SIZE,                        // py_size
    } ;
    
    return &bgnd ;
}





//----------------------------------------------------------------------------
- (id)initWithView:(UIView*)theOwner atPoint:(CGPoint)point vGap:(CGFloat)vGap message:(NSString*)msg
{
    if ( (self = [super init] ) )
    {
        owner = theOwner ;
        UIFont *font = [UIFont boldSystemFontOfSize:13];
        CGRect bounds = [owner bounds] ;
        CGRect bounds2 = bounds ;
        bounds2.size.width -= kHOffset*5.8f ;
        point.x = round( point.x ) ;
        point.y = round( point.y ) ;
        
        //CGSize labelSize = msg ? [msg sizeWithFont:font constrainedToSize:bounds2.size
        //    lineBreakMode:NSLineBreakByTruncatingTail] : CGSizeZero ;
        
        CGSize labelSize = msg ? [msg boundingRectWithSize:bounds2.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero ;
        
        
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);
        
        CGRect frame = CGRectMake( 0, 0, labelSize.width+kHOffset*2, labelSize.height+kVOffset*2+PY_SIZE ) ;
        
        BOOL pointOnTop = ( point.y-vGap - bounds.origin.y < frame.size.height ) ;
        point.y += pointOnTop ? +vGap : -vGap ;
        
        CGRect labelFrame = CGRectMake( kHOffset, pointOnTop ? kVOffset+PY_SIZE : kVOffset, labelSize.width, labelSize.height ) ;
      
        /*  
        CGRect selfFrame = frame ;
        selfFrame.origin.x = fmax( point.x - round(frame.size.width/2.0f), kHOffset) ;
        selfFrame.origin.y = pointOnTop ? point.y : point.y-frame.size.height ;
        
        pointX = point.x-selfFrame.origin.x ;
    */
    
        point.x = fmax( point.x, bounds.origin.x + kHOffset ) ;
        point.x = fmin( point.x, bounds.origin.x + bounds.size.width - kHOffset ) ;
        
        CGRect selfFrame = frame ;
        selfFrame.origin.x = round((bounds.size.width - frame.size.width)/2) ;
        
        selfFrame.origin.x = fmin( point.x-kPXHOffset, selfFrame.origin.x ) ;
        selfFrame.origin.x = fmax( point.x+kPXHOffset-frame.size.width, selfFrame.origin.x ) ;
        selfFrame.origin.y = pointOnTop ? point.y : point.y-frame.size.height ;
        
        pointX = point.x-selfFrame.origin.x ;
        //pointX = point.x ;    // nou
        
        onTop = pointOnTop ;
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setFrame:selfFrame];
       // [self setCenter:point];
        
        messageViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [messageViewLabel setAutoresizingMask:( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight )];
        //[messageViewLabel setTextAlignment:UITextAlignmentCenter] ;
        [messageViewLabel setBackgroundColor:[UIColor clearColor]];
        [messageViewLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
        //[messageViewLabel setTextColor:[UIColor whiteColor]];
        [messageViewLabel setFont:font];
        [messageViewLabel setText:msg] ;
        [messageViewLabel setNumberOfLines:0] ;
        [self addSubview:messageViewLabel];
    }
    return self ;
}



//----------------------------------------------------------------------------
- (id)initWithPresentingView:(UIView*)theOwner
{
    if ( (self = [super init] ) )
    {
        owner = theOwner ;
    }
    return self ;
}


//----------------------------------------------------------------------------
- (void)dealloc
{
}


//----------------------------------------------------------------------------
- (UILabel*)messageViewLabel
{
    return messageViewLabel ;
}

//----------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [delegate respondsToSelector:@selector(bubbleViewTouched:)] )
    {
        [delegate bubbleViewTouched:self] ;
    }
}



//---------------------------------------------------------------------------------------------------
- (void)presentFromView:(UIView*)view vGap:(CGFloat)vGap message:(NSString*)msg animated:(BOOL)animated
{
    // si arribem aqui amb un missatge crearem un bubbleview nou
    if ( view && owner )
    {
        CGRect viewBounds = [view bounds] ;
        CGPoint point ; 
        point.x = round(viewBounds.size.width/2.0f) ;
        point.y = round(viewBounds.size.height/2.0f) ;
        point = [owner convertPoint:point fromView:view] ;           
        
        CGRect bounds = [owner bounds] ;
        CGRect bounds2 = bounds ;
        bounds2.size.width -= kHOffset*5.8f ;
    
        UIFont *font = [UIFont boldSystemFontOfSize:13];
        
//        CGSize labelSize = msg ? [msg sizeWithFont:font constrainedToSize:bounds2.size
//            lineBreakMode:NSLineBreakByTruncatingTail] : CGSizeZero ;
        CGSize labelSize = msg ? [msg boundingRectWithSize:bounds2.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero ;
        
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);
        
        CGRect frame = CGRectMake( 0, 0, labelSize.width+kHOffset*2, labelSize.height+kVOffset*2+PY_SIZE ) ;
    
        BOOL pointOnTop = ( point.y-vGap - bounds.origin.y < frame.size.height ) ;
        point.y += pointOnTop ? +vGap : -vGap ;
    
        CGRect labelFrame = CGRectMake( kHOffset, pointOnTop ? kVOffset+PY_SIZE : kVOffset, labelSize.width, labelSize.height ) ;
      
        point.x = fmax( point.x, bounds.origin.x + kHOffset ) ;
        point.x = fmin( point.x, bounds.origin.x + bounds.size.width - kHOffset ) ;
    
        CGRect selfFrame = frame ;
        selfFrame.origin.x = round((bounds.size.width - frame.size.width)/2) ;
    
        selfFrame.origin.x = fmin( point.x-kPXHOffset, selfFrame.origin.x ) ;
        selfFrame.origin.x = fmax( point.x+kPXHOffset-frame.size.width, selfFrame.origin.x ) ;
        selfFrame.origin.y = pointOnTop ? point.y : point.y-frame.size.height ;
    
        pointX = point.x-selfFrame.origin.x ;
    
        onTop = pointOnTop ;
        [self setBackgroundColor:[UIColor clearColor]];
    
        [self setFrame:selfFrame];
        
        messageViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [messageViewLabel setAutoresizingMask:( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight )];
        //[messageViewLabel setTextAlignment:UITextAlignmentCenter] ;
        [messageViewLabel setBackgroundColor:[UIColor clearColor]];
        
        UIColor *textColor;
        if ( IS_IOS7 ) textColor = [view tintColor];
        else textColor = UIColorWithRgb(SystemDarkerBlueColor);
        [messageViewLabel setTextColor:textColor];
        
        //[messageViewLabel setTextColor:[UIColor whiteColor]];
        [messageViewLabel setFont:font];
        [messageViewLabel setText:msg] ;
        [messageViewLabel setNumberOfLines:0] ;
        [self addSubview:messageViewLabel];
    
        [owner addSubview:self] ;
        
        if ( animated )
        {
            BubbleView *bubble = self ;
            [bubble setAlpha:0.0f] ;
            [UIView animateWithDuration:0.3 animations:^
            {
                [bubble setAlpha:1.0f] ;
            }];
        }
    }
}


//---------------------------------------------------------------------------------------------------
- (void)dismissAnimated:(BOOL)animated
{
    BubbleView *bubble = self ;
    if ( animated )
    {
        [UIView animateWithDuration:0.3 
        animations:
        ^{
            [bubble setAlpha:0.0f] ;
        } 
        completion:^(BOOL finished) 
        {
            [bubble removeFromSuperview] ;
        }] ;
    }
    else
    {
        [bubble removeFromSuperview] ;
    }
}


//----------------------------------------------------------------------------------
- (UITableView *)_tableViewForView:(UIView *)aView
{
    Class cellClass = [UITableView class] ;
    id view = aView ;
    while ( ![view isKindOfClass:cellClass] && view != nil ) view = [view superview] ;
    return view ;
}

@end



