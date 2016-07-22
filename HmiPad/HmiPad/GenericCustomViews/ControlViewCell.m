/*

File: DisplayCell.m
Abstract: UITableView utility cell that holds a UIView.

*/

#import <QuartzCore/QuartzCore.h>

#import "ControlViewCell.h"
#import "SWTableFieldsController.h"

#import "RoundedTextView.h"

#import "SWColor.h"
#import "Drawing.h"


/*
//////////////////////////////////////////////////////////////////////////////
#pragma mark VerticallyAlignedLabel
//////////////////////////////////////////////////////////////////////////////

@implementation VerticallyAlignedLabel
 
@synthesize verticalAlignment = verticalAlignment_;
 
- (id)initWithFrame:(CGRect)frame 
{
    if ( (self = [super initWithFrame:frame]) )
    {
        self.verticalAlignment = VerticalAlignmentMiddle;
    }
    return self;
}
 
- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment 
{
    verticalAlignment_ = verticalAlignment;
    [self setNeedsDisplay];
}
 
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines 
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) 
    {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0f;
    }
    return textRect;
}
 
-(void)drawTextInRect:(CGRect)requestedRect
{
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}
 
@end
*/
//
////////////////////////////////////////////////////////////////////////////////
//#pragma mark MessageView
////////////////////////////////////////////////////////////////////////////////
//
//
////----------------------------------------------------------------------------
//@implementation MessageView
//
//#define kHOffset 14
////#define kVOffset 8 
//#define kTopOffset 8 
//#define kBotOffset 8
//
////----------------------------------------------------------------------------
//- (id)initWithTableView:(UITableView*)theOwner
//{
//    //if ( (self = [super init] ) )
//    CGRect tableRect = [theOwner bounds] ;
//    if ( (self = [super initWithFrame:CGRectMake(0, 0, tableRect.size.width, 200)] ) )
//    {
//        tableView = theOwner ;
//        messageViewLabel = [[UILabel alloc] init] ;
//                
//        //    [messageViewLabel setAutoresizingMask:( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight )];
//        [messageViewLabel setTextAlignment:UITextAlignmentCenter] ;
//        [messageViewLabel setBackgroundColor:[UIColor clearColor]];
//        [messageViewLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)] ;
//        [messageViewLabel setFont:[UIFont systemFontOfSize:13]];
//        [messageViewLabel setShadowOffset:CGSizeMake(0,1)] ;
//        [messageViewLabel setShadowColor:[UIColor whiteColor]] ;   // joan lluch
//        [messageViewLabel setNumberOfLines:0] ;
//    
//        [self setBackgroundColor:[UIColor clearColor] ];
//        [self setAutoresizesSubviews:YES];
//        
//        [self setAutoresizingMask:( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin )];
//        [self addSubview:messageViewLabel];
//    }
//    return self ;
//}
//
//
////----------------------------------------------------------------------------
//- (void)drawRect:(CGRect)rect 
//{
//    UITableViewStyle style = [tableView style] ;
//    if ( style == UITableViewStylePlain )
//    {
//        CGContextRef theContext = UIGraphicsGetCurrentContext();
//    
//        CGRect theRect = CGRectInset( [self bounds], 0, 0 ) ;
//        UIColor *shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f] ;
//        CGContextSetShadowWithColor( theContext, CGSizeMake(0,2), 8, shadowColor.CGColor ) ;
//        
//        CGContextSetLineWidth(theContext, 4 );
//     
//        UIColor *strokeColor = [UIColor colorWithWhite:1.0f alpha:1.0f] ;
//        CGContextSetStrokeColorWithColor( theContext, strokeColor.CGColor ) ;
//    
//        // dibuxem a una part no visible, pero la sombra es formara en part visible
//        CGContextMoveToPoint(theContext, 0.0f, -2.0f );
//        CGContextAddLineToPoint(theContext, theRect.size.width, -2.0f);
//    
//        //setPathToRoundedRect(theRect, 8, 0, theContext) ;
//        CGContextStrokePath(theContext);
//    }
//    
//    [super drawRect:rect];
//}
//
//
////----------------------------------------------------------------------------
//- (void)layoutSubviews
//{
//    CGRect mrect = [self bounds] ;
//    mrect.origin.x = kHOffset ;
//    mrect.origin.y = kTopOffset ; //kVOffset ;
//    mrect.size.width -= 2*kHOffset ;
//    mrect.size.height -= kTopOffset+kBotOffset ;      //     2*kVOffset ;
//    [messageViewLabel setFrame:mrect] ;
//}
//
////----------------------------------------------------------------------------
//- (void)dealloc
//{
//
//}
//
////----------------------------------------------------------------------------
//- (CGFloat)_getMessageHeight
//{
//    CGRect tableRect = [tableView bounds] ;
//    
//    CGSize superSize = CGSizeMake( tableRect.size.width-2*kHOffset, 500 ) ;
//    UIFont *font = [messageViewLabel font] ;
//    CGSize textSize = message ? [message sizeWithFont:font constrainedToSize:superSize] : CGSizeZero;
//    return textSize.height + kTopOffset+kBotOffset ; // 2*kVOffset ;
//}
//
//
////----------------------------------------------------------------------------
//- (void)setMessage:(NSString*)msg
//{
//    if ( message == msg ) return ;
//    message = msg ;
//    
//    [messageViewLabel setText:message] ;
//    
//    CGFloat height = [self _getMessageHeight];
//        
//    CGRect rect = [self frame] ;
//    rect.size.height = height;
//    [self setFrame:rect] ;
//}
//
//
////----------------------------------------------------------------------------
//- (NSString*)message
//{
//    return message ;
//}
//
//
////----------------------------------------------------------------------------
//- (CGFloat)messageHeight
//{
////    CGRect tableRect = [tableView bounds] ;
//    if ( [message length] > 0 )
//    {
////        CGSize superSize = CGSizeMake( tableRect.size.width-2*kHOffset, 500 ) ;
////        UIFont *font = [messageViewLabel font] ;
////        CGSize textSize = message ? [message sizeWithFont:font constrainedToSize:superSize] : CGSizeZero;
////        messageHeight = textSize.height + kTopOffset+kBotOffset ; // 2*kVOffset ;
//        messageHeight = [self _getMessageHeight];
//    }
//    else
//    {
//        messageHeight = 0.0f ;
//    } 
//
//    return messageHeight ;
//}
//
////----------------------------------------------------------------------------
//- (UILabel*)messageViewLabel
//{
//    return messageViewLabel ;
//}
//
//@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark ControlViewGradientBackgroundView
//////////////////////////////////////////////////////////////////////////////

@implementation ControlViewGradientBackgroundView

//----------------------------------------------------------------------------
+ (GradientBackgroundData *)gradientBackgroundData
{
    static GradientBackgroundData bgnd =
    {
        76.0f/255.0f, 86.0f/255.0f, 108.0f/255.0f, 0.7f,     // r,g,b,a
        1.8f, 1.3f,                   // i,e
        0.5f, 0.5f, 0.5f, 1.0f,     // lr,lg,lb,la
        YES, YES, YES, NO,               // left, top, right, bottom
        1.00f,                          // l_width
        11.0f,                          // round_size
        0.0f,                           // px_size
        0.0f                           // py_size
        //0.0f,                           // px
        //NO                              // onTop
    } ;
    
    return &bgnd ;
}

//----------------------------------------------------------------------------
+ (GradientBackgroundData *)gradientBackgroundData6
{
    static GradientBackgroundData bgnd =
    {
        76.0f/255.0f, 86.0f/255.0f, 108.0f/255.0f, 0.7f,     // r,g,b,a
        1.8f, 1.3f,                   // i,e
        0.5f, 0.5f, 0.5f, 1.0f,     // lr,lg,lb,la
        YES, YES, YES, NO,               // left, top, right, bottom
        1.00f,                          // l_width
        11.0f,                          // round_size
        0.0f,                           // px_size
        0.0f                           // py_size
        //0.0f,                           // px
        //NO                              // onTop
    } ;
    
    return &bgnd ;
}


//----------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame] ) )
    {
        [self setBackgroundColor:[UIColor clearColor]] ;
    }
    return self ;
}

@end

//////////////////////////////////////////////////////////////////////////////
#pragma mark ControlViewCellContentView
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
@implementation ControlViewCellContentView

@synthesize parentCell ;
@synthesize mainText, mainTextFont, mainTextColor, shadowColor, mainTextHighlightColor ;
@synthesize bottomText, bottomTextFont, bottomTextColor, bottomTextHighlightColor ;
@synthesize multilineMainText, shadowedMainText, centeredMainText ;
//@synthesize lateralBottomText ;


//----------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame parentCell:(ControlViewCell *)cell
{
    if ( (self = [super initWithFrame:frame]) ) 
    {
        parentCell = cell;
    }
    
    return self;
}


//----------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    CGRect bounds = [self bounds] ;

    if ( mainText )
    {
        CGFloat mainX = 0.0f ;      
        CGFloat mainY = 0.0f ;
        CGSize actualMSize = bounds.size ;
        actualMSize.width -= mainX ;
        BOOL hasBottom = bottomText && [bottomText length] ;
        
        if ( hasBottom ) 
        {
            CGFloat bottomX = mainX ;
            CGFloat bottomY = roundf(bounds.size.height/2.0f + 2.0f) ; // 22.0f ;
            CGFloat bottomHeight = ceil(bottomTextFont.lineHeight);
            CGFloat bottomWidth = actualMSize.width ;
            
            //actualMSize.height = bottomY ;
            actualMSize.height = ceil(mainTextFont.lineHeight);
            mainY = bottomY - actualMSize.height;
            
            NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
                textStyle.lineBreakMode = NSLineBreakByWordWrapping;
                textStyle.alignment = NSTextAlignmentLeft;
    
            UIColor *textColor = highlight ? bottomTextHighlightColor : bottomTextColor;
        
            NSDictionary *attrs = @{
                NSFontAttributeName:bottomTextFont,
                NSParagraphStyleAttributeName:textStyle,
                NSForegroundColorAttributeName:textColor
            };
            
            CGRect textRect = CGRectMake(bottomX, bottomY, bottomWidth, bottomHeight);
            [bottomText drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                attributes:attrs context:nil];
        }
    
        highlight ? [mainTextHighlightColor set] : [mainTextColor set];
        
        if ( shadowedMainText )
        {
            CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0,1), 0, shadowColor.CGColor) ;
        }

        UIFont *font = mainTextFont;
        if ( multilineMainText || centeredMainText || !hasBottom  )
        {
            CGSize boundsSuperSize = bounds.size ;
            boundsSuperSize.height *= 2.0f ;
            
            CGFloat fontSize = [font pointSize] ;
            //actualMSize=[mainText sizeWithFont:font constrainedToSize:boundsSuperSize lineBreakMode:NSLineBreakByTruncatingTail] ;
            actualMSize=[mainText boundingRectWithSize:boundsSuperSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size;
            
            while ( actualMSize.height > bounds.size.height
                    && fontSize > 11 )
            {
                fontSize -- ;
                font = [font fontWithSize:fontSize];
                //actualMSize=[mainText sizeWithFont:font constrainedToSize:boundsSuperSize lineBreakMode:NSLineBreakByTruncatingTail] ;
                actualMSize=[mainText boundingRectWithSize:boundsSuperSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                    attributes:@{NSFontAttributeName:font} context:nil].size;
            }
            
            actualMSize.height = ceilf(actualMSize.height);
            actualMSize.width = ceilf(actualMSize.width);
        
            mainY = roundf( (bounds.size.height-actualMSize.height)/2.0f ) ;
            if ( centeredMainText )
            {
                mainX = truncf( (bounds.size.width-actualMSize.width)/2.0f ) ;
            }
        }
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
            textStyle.lineBreakMode = NSLineBreakByWordWrapping;
            textStyle.alignment = NSTextAlignmentLeft;
    
        UIColor *textColor = highlight ? mainTextHighlightColor : mainTextColor;
        
        NSDictionary *attrs = @{
            NSFontAttributeName:font,
            NSParagraphStyleAttributeName:textStyle,
            NSForegroundColorAttributeName:textColor
        };
            
        CGRect textRect = CGRectMake(mainX, mainY, actualMSize.width, actualMSize.height);
        [mainText drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
            attributes:attrs context:nil];
    }
    
    //DDLogVerbose( @"TIMING DR1: %f", CFAbsoluteTimeGetCurrent()-globaltime ) ;
    //globaltime = CFAbsoluteTimeGetCurrent() ;
    
//    highlight ? [[UIColor whiteColor] set] : [[UIColor colorWithWhite:0.23f alpha:1.0f] set];
//    [parentCell.bottomText drawAtPoint:CGPointMake(81.0f, 8.0f) withFont:[UIFont boldSystemFontOfSize:11.0f]];
    
    /*
    [[NSString stringWithFormat:@"%d Ratings", _cell.numRatings] drawAtPoint:CGPointMake(157.0, 46.0) withFont:[UIFont systemFontOfSize:11.0]];
    
    CGPoint ratingImageOrigin = CGPointMake(81.0, 45.0);
    UIImage *ratingBackgroundImage = [UIImage imageNamed:@"StarsBackground.png"];
    [ratingBackgroundImage drawAtPoint:ratingImageOrigin];
    UIImage *ratingForegroundImage = [UIImage imageNamed:@"StarsForeground.png"];
    UIRectClip(CGRectMake(ratingImageOrigin.x, ratingImageOrigin.y, ratingForegroundImage.size.width * (_cell.rating / MAX_RATING), ratingForegroundImage.size.height));
    [ratingForegroundImage drawAtPoint:ratingImageOrigin];
    */
}


//----------------------------------------------------------------------------
- (void)setFrame:(CGRect)rect
{
    CGRect frame = [self frame] ;
    if (    frame.origin.x != rect.origin.x ||
            frame.origin.y != rect.origin.y ||
            frame.size.width != rect.size.width ||
            frame.size.height != rect.size.height ) [self setNeedsDisplay] ;
    [super setFrame:rect] ;
}


//----------------------------------------------------------------------------
// El iOS l'utiliza quan seleccionem la celda (Suposo que pel simple fet de ser un subView del contentView)
- (void)setHighlighted:(BOOL)highlighted
{
    highlight = highlighted;
    [self setNeedsDisplay];
}

//----------------------------------------------------------------------------
- (BOOL)isHighlighted
{
    return highlight;
}

//----------------------------------------------------------------------------
- (void)dealloc
{

}


@end 


//////////////////////////////////////////////////////////////////////////////
#pragma mark ControlViewCell
//////////////////////////////////////////////////////////////////////////////

@implementation ControlViewCell

//-------------------------------------------------------------------------------

@synthesize cellContentView, leftView, rightView, selectedRightView;
@synthesize tabWidth;
@synthesize leadingTabWidth, maxTabbingWidth, minRightViewSize;



//-------------------------------------------------------------------------------
- (id)initWithReuseIdentifier:(NSString *)identifier
{
    //if ( (self = [super initWithFrame:CGRectZero reuseIdentifier:identifier]) ) 
    if ( (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) ) 
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self setBackgroundColor:[UIColor whiteColor]] ;
		[self setOpaque:YES] ;
        
        maxTabbingWidth = 1000 ;  // numero molt gran per defecte
        
        cellContentView = [[ControlViewCellContentView alloc] initWithFrame:CGRectZero parentCell:self] ; 
        
        [cellContentView setOpaque:YES] ;
        //[cellContentView setBackgroundColor:[self backgroundColor]] ;  // ara
        [cellContentView setBackgroundColor:[UIColor clearColor]] ;  // ara
        //[cellContentView setBackgroundColor:[UIColor redColor]] ;
        [cellContentView setAutoresizesSubviews:NO] ;
        [cellContentView setContentMode:UIViewContentModeLeft];
        
        // valors per defecte
        [cellContentView setMainTextColor:[UIColor blackColor]] ;
        if ( IS_IOS7 )
        {
            //[cellContentView setMainTextFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            [cellContentView setMainTextFont:[UIFont systemFontOfSize:17]];
            [cellContentView setMainTextHighlightColor:[UIColor blackColor]] ;
        }
        else
        {
            [cellContentView setMainTextFont:[UIFont boldSystemFontOfSize:17]];
            [cellContentView setMainTextHighlightColor:[UIColor whiteColor]] ;
        }

        
        [cellContentView setBottomTextColor:[UIColor grayColor]] ;
        [cellContentView setBottomTextHighlightColor:[UIColor grayColor]];
        if ( IS_IOS7 )
        {
            //[cellContentView setBottomTextFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]] ;
            [cellContentView setBottomTextFont:[UIFont systemFontOfSize:12]] ;
        }
        else
        {
            [cellContentView setBottomTextFont:[UIFont boldSystemFontOfSize:12]] ;
        }
        
        UIView *actualContentView = [self contentView] ;
        [actualContentView setAutoresizesSubviews:NO] ;
        [actualContentView addSubview:cellContentView];
    }
    return self ;
}

//-------------------------------------------------------------------------------
- (void)dealloc
{
}

//-------------------------------------------------------------------------------
- (void)setView:(UIView*)inView toSelfViewByRef:(UIView*__strong*)selfView
{
    if ( inView != *selfView )
    {
        [*selfView removeFromSuperview];
        *selfView = inView ;
        [[self contentView] addSubview:inView];
        [self setNeedsLayout];
    } 
}


//-------------------------------------------------------------------------------
- (NSString *)mainText
{
    return [cellContentView mainText] ;
}

//-------------------------------------------------------------------------------
- (void)setMainText:(NSString *)text
{
    NSString *oldText = [cellContentView mainText] ;
    if ( oldText != text )
    {
        [cellContentView setMainText:text];
        [self setNeedsLayout];
        [cellContentView setNeedsDisplay];
    }
}


//-------------------------------------------------------------------------------
- (NSString *)bottomText
{
    return [cellContentView bottomText] ;
}

//-------------------------------------------------------------------------------
- (void)setBottomText:(NSString *)text
{
    NSString *oldText = [cellContentView bottomText] ;
    if ( oldText != text )
    {
        [cellContentView setBottomText:text];
        [self setNeedsLayout];
        [cellContentView setNeedsDisplay];
    }
}

//-------------------------------------------------------------------------------
- (void)setLeftView:(UIView *)inView
{
    [self setView:inView toSelfViewByRef:&leftView];
}

//-------------------------------------------------------------------------------
- (void)setRightView:(UIView *)inView
{
    //[inView setBackgroundColor:[UIColor greenColor]];
    [self setView:inView toSelfViewByRef:&rightView];
}


// table view cell content offsets

//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000    //7.0 supported and required

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000   // 7.0 supported
    #define kHorizLeftOffset	16.0f
    #define kHorizRightOffset	12.0f
#else
    #define kHorizLeftOffset	7.0f
    #define kHorizRightOffset	8.0f
#endif

#define kHorizInnerGap      8.0f
#define kHorizTextOffset    8.0f
#define kVertOffset         2.0f
#define kMinHorizRightViewWidth   60.0f

//-------------------------------------------------------------------------------
- (void)setInitialDecorationLayout:(UIView*)decorationView
{
    CGRect contentRect, decorationViewRect, decorationViewFrame ;
    
    contentRect = [[self contentView] bounds];
    CGFloat horizIndent = contentRect.origin.x ;
    
    decorationViewRect = CGRectZero;
    if ( decorationView ) decorationViewRect = [decorationView bounds] ;
    decorationViewFrame = CGRectMake( horizIndent + kHorizLeftOffset,
                                roundf( (contentRect.size.height - decorationViewRect.size.height) / 2.0f),
                                decorationViewRect.size.width,
                                decorationViewRect.size.height );
    
    if ( isRightDecoration )
    { 
        decorationViewFrame.origin.x = contentRect.size.width - decorationViewRect.size.width - kHorizRightOffset ;
    }
                
    [decorationView setFrame:decorationViewFrame] ;
}


//-------------------------------------------------------------------------------
- (void)layoutSubviews
{	
    [super layoutSubviews];
    
    CGFloat labelOrigin ;

    CGRect contentRect = [[self contentView] bounds];
    CGFloat horizIndent = contentRect.origin.x ;
    
    // a partir de OS 3.0 el contentView no esta indentat 
    NSInteger indentationLevel = [self indentationLevel] ;
    if ( indentationLevel > 0 ) horizIndent += [self indentationWidth] * indentationLevel ;
    
    // frame per el view de la esquerra
    if ( leftView )
    {
        CGSize leftViewSize = [leftView bounds].size ;
        CGRect leftViewFrame = CGRectMake( horizIndent + kHorizLeftOffset,
                                    roundf( (contentRect.size.height - leftViewSize.height) / 2.0f),
                                    leftViewSize.width,
                                    leftViewSize.height );
        
        [leftView setFrame:leftViewFrame] ;
        labelOrigin = leftViewFrame.origin.x + leftViewFrame.size.width + kHorizInnerGap ;
    }
    else
    {
        labelOrigin = horizIndent + kHorizLeftOffset ;
    }
    
    
    // si tabWidth és zero calculem el frame del label a partir del posicionament del rightView
    if ( tabWidth == 0 )
    { 
        CGFloat originY = 0.0f ;  // zero vol dir centrat
        CGSize rightViewSize ;
    
        // calculem un valor tentatiu de Rect per el rightView
        if ( rightView )
        {
            if ( [rightView respondsToSelector:@selector(sizeThatFitsWidth:)] )
            {
                CGFloat maxWidth = contentRect.size.width-leadingTabWidth-kHorizTextOffset ;
                rightViewSize = [(id)rightView sizeThatFitsWidth:maxWidth] ;
                
                if ( rightViewSize.width < minRightViewSize.width ) rightViewSize.width = minRightViewSize.width ;  // si minRightViewSize es molt gran es pot menjar el leadingTabWidth
                if ( rightViewSize.height < minRightViewSize.height ) rightViewSize.height = minRightViewSize.height ;
            }
            
            else
            {
                CGRect rightViewBounds = [rightView bounds] ;
                rightViewSize = rightViewBounds.size;
            }
        }
        else rightViewSize = CGSizeZero ;
        
        // frame per el view de la dreta
        if ( rightView )
        {
            CGRect rightViewFrame = CGRectMake(   contentRect.size.width - rightViewSize.width - kHorizRightOffset,
                                            (originY ? originY : trunc( (contentRect.size.height - rightViewSize.height) / 2.0f)),
                                            rightViewSize.width,
                                            rightViewSize.height );
                
            [rightView setFrame:rightViewFrame];
        }

        // frame per el cellContentView
        if ( cellContentView )
        {
            //CGFloat labelOrigin = leftViewFrame.origin.x + leftViewFrame.size.width + kHorizInnerGap ;
            CGFloat rightSize = rightViewSize.width + kHorizInnerGap ;
            if ( (rightView && [rightView isHidden]) || originY != 0.0f ) rightSize = 0.0f ;
        
            CGRect labelFrame = CGRectMake( labelOrigin, 
                                        kVertOffset,
                                        contentRect.size.width - labelOrigin - rightSize - kHorizRightOffset,
                                        contentRect.size.height - kVertOffset*2.0f );
            [cellContentView setFrame:labelFrame] ;
        }
    }
    
    // si tabWidth no és zero calculem el frame del rightView a partir del posicionament del label
    else 
    {
        // el texte principal del mainView
        NSString *text = [cellContentView mainText] ;

        // frame per el label
        CGFloat tabbedOrigin = 0 ;
        //CGFloat labelOrigin = leftViewFrame.origin.x + leftViewFrame.size.width + kHorizInnerGap ;
        if ( cellContentView )
        {
            CGRect labelFrame ;
            //CGSize labelRectSize = text ? [text sizeWithFont:[cellContentView mainTextFont]] : CGSizeZero ;
            
            CGSize labelRectSize = text ? [text sizeWithAttributes:@{NSFontAttributeName:cellContentView.mainTextFont}] : CGSizeZero ;
            labelRectSize.width = ceil(labelRectSize.width);
            labelRectSize.height = ceil(labelRectSize.height);
            
            CGFloat maxLabelSize = maxTabbingWidth ;
            CGFloat absolutMaxLabelSize = contentRect.size.width - labelOrigin - tabWidth - (kHorizInnerGap + kHorizRightOffset + kMinHorizRightViewWidth);
            if ( maxLabelSize > absolutMaxLabelSize ) maxLabelSize = absolutMaxLabelSize ;
            if ( labelRectSize.width > maxLabelSize ) labelRectSize.width = maxLabelSize ;
            
            CGFloat minRightOrigin = labelOrigin + labelRectSize.width + trunc(tabWidth/2.0f) + (labelRectSize.width>0?kHorizInnerGap:0.0f) ; //truncf
            CGFloat tailingTabsWidth = 0 ;
            if ( minRightOrigin > leadingTabWidth ) tailingTabsWidth = tabWidth * ( 1 + roundf( (minRightOrigin-leadingTabWidth)/tabWidth ) ) ;   //truncf
            tabbedOrigin = leadingTabWidth + tailingTabsWidth ;
            
            if ( labelOrigin+labelRectSize.width < tabbedOrigin ) labelRectSize.width = tabbedOrigin-labelOrigin ;
            if ( labelRectSize.width == 0 ) labelRectSize.width = 1 ;// no em facis dir perque pero si es cero la posterior 
                                                                     // crida a setNeedsDisplay no fa res i el drawRect ni es crida
            labelFrame.origin = CGPointMake( labelOrigin, kVertOffset ) ;                                     			
            labelFrame.size = CGSizeMake( labelRectSize.width, contentRect.size.height-kVertOffset*2.0f ) ;
            [cellContentView setFrame:labelFrame] ;
        }
        
        // frame per el view de la dreta
        if ( rightView )
        {
            CGRect rightViewFrame = CGRectMake( tabbedOrigin,
                                            kVertOffset,
                                            contentRect.size.width - kHorizRightOffset - tabbedOrigin,
                                            contentRect.size.height - 2.0f*kVertOffset );
                                            
            if ( [rightView respondsToSelector:@selector(sizeThatFitsWidth:)] )
            {
                CGSize rightViewSize = [(id)rightView sizeThatFitsWidth:rightViewFrame.size.width] ;
                //NSLog( @"rightViewSize2:%g,%g", rightViewSize.width, rightViewSize.height) ;
                rightViewFrame.size.height = rightViewSize.height ;
                rightViewFrame.origin.y = trunc((contentRect.size.height - rightViewSize.height)/2) ;
                if ( rightViewSize.width < minRightViewSize.width ) rightViewSize.width = minRightViewSize.width ;
                if ( rightViewSize.height < minRightViewSize.height ) rightViewSize.height = minRightViewSize.height ;
            }
        
            [rightView setFrame:rightViewFrame];
        }
    }
}


//-------------------------------------------------------------------------------
- (void)setDecorationType:(ItemDecorationType)type right:(BOOL)right animated:(BOOL)animated
{
    if ( decorationType == type && isRightDecoration == right ) return ;
    
    decorationType = type ;
    isRightDecoration = right ;
    
    CGRect decoFrame = CGRectMake(0, 0, 22, 22) ;
        
    UIView *decoratorView = [UIView decoratedViewWithFrame:decoFrame forSourceItemDecoration:type animated:animated] ;
    [self setInitialDecorationLayout:decoratorView] ;

    if ( isRightDecoration ) [self setRightView:decoratorView];
    else [self setLeftView:decoratorView] ;
    
    void (^block)() = ^()
    {
        [decoratorView setAlpha:1.0f];
        [self layoutSubviews];
    };
    
    if ( animated )
    {
        [decoratorView setAlpha:0.0f];
        [UIView animateWithDuration:0.25 animations:block];
    }
    else
    {
        block();
    }
}


//-------------------------------------------------------------------------------
- (void)setIndentationWidthForDecorationType:(ItemDecorationType)type right:(BOOL)right
{
    if ( right ) return ;
    
    CGFloat indentation = 0.0f ;
    if ( type != ItemDecorationTypeNone ) indentation = 22 + kHorizInnerGap ;
    
    [self setIndentationWidth:indentation];
}


@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark SwitchViewCell
//////////////////////////////////////////////////////////////////////////////

@implementation SwitchViewCell

//----------------------------------------------------------------------------
@synthesize switchv ;

//----------------------------------------------------------------------------
- (id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithReuseIdentifier:identifier];
    if ( self )
    {
        switchv = [[UISwitch alloc] initWithFrame:CGRectZero] ;
        [self setRightView:switchv] ;
    }
    return self ;
}
    
//-------------------------------------------------------------------------------
- (void)dealloc
{
}

@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark TextFieldCellLabel
//////////////////////////////////////////////////////////////////////////////

@implementation TextFieldCellTextField

//-------------------------------------------------------------------------------
-(void)setText:(NSString*)newText
{
    [[[self superview ] superview] setNeedsLayout];  //  self <-contentView  <-cell
    
    // simplement estableix la necesitat de layout i passa al super
    /*id view = self ;
    Class cellClass = [ControlViewCell class] ;
    while ( ![view isKindOfClass:cellClass] && view != nil ) view = [view superview] ;
    [view setNeedsLayout] ;*/
    
    [super setText:newText];
}

//-------------------------------------------------------------------------------
- (void)dealloc
{
}

@end

    
    
//////////////////////////////////////////////////////////////////////////////
#pragma mark TextFieldCell
//////////////////////////////////////////////////////////////////////////////

@implementation TextFieldCell

//----------------------------------------------------------------------------
@synthesize textField ;

//----------------------------------------------------------------------------
- (id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithReuseIdentifier:identifier];
    if ( self )
    {
        //int textFieldWidth = 120 ; 
        textField = [[TextFieldCellTextField alloc] initWithFrame:CGRectZero] ; // CGRectMake(0,0,0,31)] ;
        textField.borderStyle = UITextBorderStyleRoundedRect;
            
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        textField.textColor = UIColorWithRgb(TextDefaultColor) ;
        if ( IS_IOS7 )
        {
            textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        }
        else
        {
            textField.font = [UIFont systemFontOfSize:17.0f];
        }
        //textField.backgroundColor = [UIColor clearColor]; //091025
        //textField.backgroundColor = [self backgroundColor]; //091025    // ara
        
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        textField.keyboardType = UIKeyboardTypeDefault ; //UIKeyboardTypeNumbersAndPunctuation
        textField.returnKeyType = UIReturnKeyDone;
            
        //[textField setDelegate:self] ;
            
        [self setTabWidth:20] ;
        [self setLeadingTabWidth:100];
        [self setRightView:textField] ;
    }
    return self ;
}
    
//-------------------------------------------------------------------------------
- (void)dealloc
{
}

@end
    

//////////////////////////////////////////////////////////////////////////////
#pragma mark ManagedTextFieldCell
//////////////////////////////////////////////////////////////////////////////

@implementation ManagedTextFieldCell

//----------------------------------------------------------------------------
//- (id)initWithNavigationButtonController:(id<UITextFieldDelegate>)navBController 
- (id)initWithSWTableFieldsController:(SWTableFieldsController*)navBController 
                           reuseIdentifier:(NSString*)identifier
{
    self = [super initWithReuseIdentifier:identifier];
    if ( self )
    {
        [textField setDelegate:self] ;
        [textField setText:@""] ; // hi ha d'haver algo o si no hi ha problemes en recordTextField  
        [textField setBorderStyle:UITextBorderStyleNone] ;
        navButtonController = navBController ;
        owner = (id)[navButtonController owner];
    }
    return self ;
}


#pragma mark UITextFieldDelegate methods

//-------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)txField
{
    BOOL doIt = YES ;
    if ( [owner respondsToSelector:@selector(textFieldShouldBeginEditing:)] )
    {
        doIt = [owner textFieldShouldBeginEditing:txField] ;
    }
    
    if ( doIt )   // he posat aixo el dia 9-7-10
    {
    	[navButtonController startAnimated:YES];
    }
    
    return doIt ;
}


//-------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)txField
{
    if ( [owner respondsToSelector:@selector(textFieldDidBeginEditing:)] )
    {
        [owner textFieldDidBeginEditing:txField] ;
    }
   // [navButtonController startAnimated:YES];    // he tret aixo el dia 9-7-10
    [navButtonController recordTextResponder:txField];
    [self setNeedsLayout] ;
}


//-------------------------------------------------------------------------------
- (BOOL)textFieldShouldEndEditing:(UITextField *)txField
{
    if ( [owner respondsToSelector:@selector(textFieldShouldEndEditing:)] )
    {
        return [owner textFieldShouldEndEditing:txField] ;
    }
    
    return YES ;
}

//-------------------------------------------------------------------------------
- (void)textFieldDidEndEditing:(UITextField *)txField
{
    if ( [owner respondsToSelector:@selector(textFieldDidEndEditing:)] )
    {
        [owner textFieldDidEndEditing:txField] ;
    }
}

//-------------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)txField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [owner respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] )
    {
        BOOL result = [owner textField:txField shouldChangeCharactersInRange:range replacementString:string] ;
        if ( result ) [self setNeedsLayout] ;
        return result ;
    }
    
    return YES ;
}

//-------------------------------------------------------------------------------
- (BOOL)textFieldShouldClear:(UITextField *)txField
{
    if ( [owner respondsToSelector:@selector(textFieldShouldClear:)] )
    {
        return [owner textFieldShouldClear:txField] ;
    }
    
    return YES ;
}

//-------------------------------------------------------------------------------
// En aquest cas interpretem el retorn de la funció delegada com referint-se
// al conjunt de textFields que estem tractant amb el navigationButtonController
// associat. Es a dir, si ens tornen YES  o el delegat no està implementat, 
// vol dir que volem resignar de tots ells. Si torna NO, vol dir que encara volem continuar.
// Per tant, segons aquesta implementació no és possible evitar la resignació
// del textField actual. El métode aqui implementat torna doncs sempre YES
- (BOOL)textFieldShouldReturn:(UITextField *)txField
{
    BOOL shouldReturn = NO ;
    BOOL responds ;
    
    responds = [owner respondsToSelector:@selector(textFieldShouldReturn:)] ;
    if ( responds ) shouldReturn = [owner textFieldShouldReturn:txField] ;
    
    if ( !responds || ( responds && shouldReturn ) ) [navButtonController stopWithCancel:NO animated:YES];
    
    return YES ;
}
    
//-------------------------------------------------------------------------------
- (void)dealloc
{
}

@end


    
//////////////////////////////////////////////////////////////////////////////
#pragma mark LabelViewCellLabel
//////////////////////////////////////////////////////////////////////////////

@implementation LabelViewCellLabel

//-------------------------------------------------------------------------------
-(void)setText:(NSString*)newText
{
    //CGSize size = [newText sizeWithFont:[self font]] ;
    //[self setFrame:CGRectMake( 0, 0, size.width, size.height )] ;
    
    // simplement estableix la necesitat de layout i passa al super
    [[[self superview  /*contentView*/] superview /*theCell*/ ] setNeedsLayout];
    [super setText:newText];
}

//-------------------------------------------------------------------------------
- (void)dealloc
{
}

@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark LabelViewCell
//////////////////////////////////////////////////////////////////////////////
@implementation LabelViewCell

//------------------------------------------------------------------------------------------
@synthesize secondLabel ;

//------------------------------------------------------------------------------------------
- (id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithReuseIdentifier:identifier];
    if ( self )
    {
        secondLabel = [[LabelViewCellLabel alloc] initWithFrame:CGRectZero] ; // CGRectMake(0,0,0,31)] ;
        //secondLabel.backgroundColor = [self backgroundColor]; //091025   // ara
        secondLabel.backgroundColor = [UIColor clearColor]; //091025   // ara
        secondLabel.textColor = UIColorWithRgb(TextDefaultColor);
        if ( IS_IOS7 )
        {
            //secondLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            secondLabel.font = [UIFont systemFontOfSize:17];;
            secondLabel.highlightedTextColor = [UIColor darkGrayColor];
        }
        else
        {
            secondLabel.font = [UIFont systemFontOfSize:17];
            secondLabel.highlightedTextColor = [UIColor whiteColor];
        }
        secondLabel.textAlignment = NSTextAlignmentRight;
        //[self setTabWidth:1] ;
        [self setRightView:secondLabel];
    }
    return self ;
}
       
//-------------------------------------------------------------------------------
- (void)dealloc
{
}

//-------------------------------------------------------------------------------
- (void)setIsButtonLikeCell:(BOOL)isButtonLikeCell
{
    if ( IS_IOS7 )
    {
        [cellContentView setMainTextFont:[UIFont systemFontOfSize:17]] ;
        UIColor *tintColor = [self tintColor];
        [cellContentView setMainTextColor:tintColor];
        [cellContentView setMainTextHighlightColor:[tintColor colorWithAlphaComponent:0.2]];
    }
    else
    {
        [cellContentView setMainTextFont:[UIFont boldSystemFontOfSize:15]] ;
        [cellContentView setMainTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
    }
    [cellContentView setCenteredMainText:YES] ;

}


@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark InfoViewCell
//////////////////////////////////////////////////////////////////////////////

@implementation InfoViewCell


//------------------------------------------------------------------------------------------
- (id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithReuseIdentifier:identifier];
    if ( self )
    {
        UIFont *font = [UIFont systemFontOfSize:13] ;
        [cellContentView setMainTextColor:UIColorWithRgb(SystemDarkerBlueColor)] ;
        [cellContentView setMainTextHighlightColor:[UIColor blackColor]];
        [cellContentView setMainTextFont:font];
        [cellContentView setMultilineMainText:YES] ;
    }
    return self ;
}


@end

	










