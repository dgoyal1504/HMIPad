//
//  RoundedTextView.m
//  ScadaMobile
//
//  Created by Joan on 02/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SWColor.h"
#import "Drawing.h"

#import "RoundedTextViewDelegate.h"
#import "RoundedTextView.h"
#import "SWViewSelectionLayer.h"




//-------------------------------------------------------------------------------
static CGSize sizeWithText_font_max(NSString *txt, UIFont *font, CGFloat maxWidth)
{
    CGSize size = CGSizeZero;
    if ( txt && font) 
    {
        // aquesta es l'ampada que tenim disponible
        //CGFloat maxWidth = contentRect.size.width-leadingTabWidth-kHorizTextOffset;
                 
        // primer provem de fer-ho cabre en una linea
        //size = [txt sizeWithFont:font];
        size = [txt sizeWithAttributes:@{NSFontAttributeName:font}];
        size.height = ceil(size.height);
        size.width = ceil(size.width);
                    
        // si no hi cap provem de fer-ho cabre en dos linees a la mitad d'espai
        if ( size.width > maxWidth )
        {
            CGFloat height = size.height;
            CGFloat tryWidth = maxWidth;
            CGFloat width0 = maxWidth;
            CGFloat width1 = 0;
                        
            // fem una busqueda binaria fins que la alzada coincideix amb dues linees
            while ( size.height != height*2 && width0 > width1 )
            {
                tryWidth = ((width0 + width1) / 2.0f );
                //size = [txt sizeWithFont:font constrainedToSize:CGSizeMake(tryWidth, height*3) lineBreakMode:NSLineBreakByTruncatingTail];
                size = [txt boundingRectWithSize:CGSizeMake(tryWidth, height*3) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size;
                
                if ( size.height > height*2 )  width1 = ceil(tryWidth);  // no hi cap en dues linees
                else width0 = floor(tryWidth); // hi cap
            }
            
            size.height = ceil(size.height);
            size.width = ceil(size.width);
            
            //size.width = ceilf(tryWidth);
            size.height = height*2;
        }
        
        size.width += 8;
    }
    return size;
}



///////////////////////////////////////////////////////////////////////////////////
#pragma mark Label
///////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------
@implementation UILabel(sizeThatFitsExtensions)

//---------------------------------------------------------------------------------
- (CGSize)sizeThatFitsWidth:(CGFloat)width
{
    NSString *text = [self text];
    UIFont *font = [self font];
    CGSize newSize = sizeWithText_font_max(text, font, width);
    
    
    //NSLog( @"UILabel size:%g,%g", newSize.width, newSize.height);
    return newSize;
}

@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextField
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@implementation UITextField(sizeThatFitsExtensions)

//---------------------------------------------------------------------------------
- (CGSize)sizeThatFitsWidth:(CGFloat)width
{
    NSString *text = [self text];
    UIFont *font = [self font];
    CGSize newSize = sizeWithText_font_max(text, font, width);
    
    newSize.width += 8; // 16; 
    //newSize.width += 64; // 16; 
    //newSize.height += 1;
    if ( [self tag] == 1 ) newSize.width += 10 + 8;
    
    if ( newSize.width < 72 ) newSize.width = 72;
    if ( newSize.height < 31 ) newSize.height = 31;
    
    //NSLog( @"UITextField size:%g,%g", newSize.width, newSize.height);
    return newSize;
}

@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark InnerTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface InnerTextView : UITextView
{
}
@property (nonatomic,assign) BOOL wantsFixedOffset;
@property (nonatomic,assign) BOOL singleLine;
@property (nonatomic,retain) UILabel *suggestionLabel;
@property (nonatomic,retain) NSString *suggestionString;

@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark InnerTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@implementation InnerTextView


//---------------------------------------------------------------------------------
// Override de seth per forcar un offset fixe. Espero que no es trenqui en el futur
- (void)setContentOffset:(CGPoint)contentOffset
{
    CGPoint offsetPoint = contentOffset;
    if ( _wantsFixedOffset )
    {
        offsetPoint = CGPointMake(0,0);
    }
    [super setContentOffset:offsetPoint];
}


//---------------------------------------------------------------------------------
// Override de seth per forcar un offset fixe. Espero que no es trenqui en el futur
- (void)adjustLineOffset
{
    CGPoint offsetPoint = self.contentOffset;
    CGSize boundsSize = self.bounds.size;
    CGFloat fontHeight = [[self font] lineHeight];
    if ( boundsSize.height > 0 && fontHeight > 0 )
    {
        //CGSize contentSize = [self contentSize];
        //contentSize.width -= 16;   // Magic Number. No he trobat cap manera de determinarlo no-empiricament

        //CGSize textSize = [self.text sizeWithFont:self.font constrainedToSize:contentSize];
        
        CGFloat hOffset = 8 - truncf((boundsSize.height - fontHeight)/2);
        offsetPoint.y = hOffset;
        //if ( [self tag] == 0 && [self textAlignment] == UITextAlignmentRight ) offsetPoint.x = -8; 
    }
    [self setContentOffset:offsetPoint];
}





//-------------------------------------------------------------------------------
// Override de setFrame per forcar el contingut al frame
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
   // [self setContentSize:frame.size];
   // [self setContentOffset:CGPointZero];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    if ( _suggestionLabel )
        [self setNeedsLayout];
}


- (NSString*)suggestionString
{
    return _suggestionLabel.text;
}


- (void)setSuggestionString:(NSString *)suggestionString
{
    if ( suggestionString )
    {
        if ( _suggestionLabel == nil )
        {
            _suggestionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,50,20)];
            _suggestionLabel.text = suggestionString;
            _suggestionLabel.backgroundColor = [UIColor clearColor];
            _suggestionLabel.font = self.font;
            _suggestionLabel.textColor = [UIColor grayColor];
            [self insertSubview:_suggestionLabel atIndex:0];
        }
        _suggestionLabel.text = suggestionString;
        [self setNeedsLayout];
    }
    else
    {
        [_suggestionLabel removeFromSuperview];
        _suggestionLabel = nil;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( _singleLine )
    {
        [self adjustLineOffset];
    }
    
    if ( _suggestionLabel )
    {
        CGRect rect = [self caretRectForPosition:self.endOfDocument];
        //_suggestionLabel.font = self.font;
        //CGFloat width = [_suggestionLabel.text sizeWithFont:_suggestionLabel.font].width;
        
        CGFloat width = [_suggestionLabel.text sizeWithAttributes:@{NSFontAttributeName:_suggestionLabel.font}].width;
        rect.size.width = ceil(width);
        
        rect.origin.x = roundf(rect.origin.x);
        rect.origin.y = roundf(rect.origin.y+1);
        rect.size.width = ceilf(rect.size.width);
        rect.size.height = ceilf(rect.size.height);
        
        _suggestionLabel.frame = rect;
    }

}

@end





/////////////////////////////////////////////////////////////////////////////////////
//#pragma mark OverLayer
/////////////////////////////////////////////////////////////////////////////////////
//
//@interface OverLayer  :CALayer
//
//- (void)addToView:(UIView*)view;
//- (void)removeFromSuperview;
//- (void)layoutInSuperview;
//
//@end
//
//
//
//@implementation OverLayer
//
//- (void)addToView:(UIView*)view
//{
//    if ( view == nil )
//        return;
//    
//    [[view layer] addSublayer:self];
//    [self layoutInSuperview];
//}
//
//- (void)removeFromSuperview
//{
//    [self removeFromSuperlayer];
//}
//
//#define OverlayerWidth 2
//
//- (void)layoutInSuperview
//{
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    
//    CALayer *superlayer = self.superlayer;
//    CGRect bounds = superlayer.bounds;
//    [self setFrame:CGRectInset(bounds,-OverlayerWidth,-OverlayerWidth)];
//    [self setNeedsDisplay];
//
//    [CATransaction commit];
//}
//
//
////---------------------------------------------------------------------------------
//- (void)drawInContext:(CGContextRef)theContext
//{
//    CGRect theRect = CGRectInset( [self bounds], OverlayerWidth/2, OverlayerWidth/2 );
//    //UIColor *color = UIColorWithRgb(TheSystemDarkBlueTheme);
//    UIColor *color = UIColorWithRgb(BlueSelectionColor);
//    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), OverlayerWidth, color.CGColor );
//    CGContextSetLineWidth(theContext, OverlayerWidth );
//    CGContextSetStrokeColorWithColor( theContext, color.CGColor );
//    addRoundedRectPath(theContext, theRect, 8, 0);
//    CGContextStrokePath(theContext);
//}
//
//
//@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark RoundedTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@implementation RoundedTextView
{
    SWViewSelectionLayer *_overlay ;
}

//---------------------------------------------------------------------------------
//@synthesize borderStyle=_borderStyle;
@synthesize delegate=_deleg;
@synthesize backgroundColor=_backgroundColor;


-(void)_doInit
{
    [self setContentMode:UIViewContentModeRedraw];
    [self setAutoresizesSubviews:NO];
    _textView = [[InnerTextView alloc] initWithFrame:self.bounds];
    [_textView setBackgroundColor:[UIColor clearColor]];
    //[_textView setBackgroundColor:[UIColor lightGrayColor]];
    [_textView setDelegate:self];
    [_textView setScrollsToTop:NO];
    //[_textView setScrollEnabled:NO];
    //[_textView setExclusiveTouch:YES];
    //[_textView setUserInteractionEnabled:NO];  // USER INTERACTION FORA !
    [_textView setShowsVerticalScrollIndicator:NO];
    [_textView setShowsHorizontalScrollIndicator:NO];
    [_textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
   // [super setBackgroundColor:[UIColor clearColor]];
    [self setBorderStyle:UITextBorderStyleNone];
    [self addSubview:_textView];
    //[_textView release];
}


//---------------------------------------------------------------------------------
// inicialitzador des del xib
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self _doInit];
    return self;
}


//---------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)aRect
{
    if ( (self = [super initWithFrame:aRect]) )
    {
        [self _doInit];
    }
    return self;
}

/*
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self doInit];
}
*/


//---------------------------------------------------------------------------------
// dibuixa un borde al voltant
//- (void)setOverlayV:(BOOL)show
//{
//    if ( show )
//    {
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
//        if ( _overlay == nil )
//        {
//            _overlay = [[OverLayer alloc] init];
//            [[self layer] addSublayer:_overlay];
//        }
//        [_overlay setFrame:CGRectInset([self bounds],-OverlayerWidth,-OverlayerWidth)];
//        [CATransaction commit];
//        [_overlay setNeedsDisplay];
//    }
//    else
//    {
//        if ( _overlay )
//        {
//            [_overlay removeFromSuperlayer];
//            _overlay = nil;
//        }
//    }
//}

- (void)setDelegate:(id<RoundedTextViewDelegate>)delegate
{
    _deleg = delegate;
}

- (void)setOverlay:(BOOL)show
{
    if ( show )
    {
        if ( _overlay == nil )
        {
            _overlay = [[SWViewSelectionLayer alloc] init];
            [_overlay addToView:self];
        }
    }
    else
    {
        [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(_delayedHide:) object:nil];
        [self performSelector:@selector(_delayedHide:) withObject:_overlay afterDelay:0.6];
        _overlay = nil;
    }
}

- (void)_delayedHide:(id)obj
{
    SWViewSelectionLayer *overlay = (id)obj;
    [overlay remove];
}



//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    [_overlay removeAnimationForKey:@"opacity"];
//    [_overlay removeFromSuperview];
//    _overlay = nil;
//}

//---------------------------------------------------------------------------------
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect selfBounds = [self bounds];
    
    CGRect textViewFrame = selfBounds;
    CGRect rightViewFrame = CGRectZero;
    CGRect leftViewFrame = CGRectZero;
    
    
    if ( _rightView )
    {
        rightViewFrame = [_rightView bounds];
        rightViewFrame.origin.y = truncf((selfBounds.size.height - rightViewFrame.size.height)/2);   
        rightViewFrame.origin.x = truncf(selfBounds.size.width - rightViewFrame.size.width-5);
        [_rightView setFrame:rightViewFrame];
    }
    
    if ( _leftView )
    {
        leftViewFrame = [_leftView bounds];
        leftViewFrame.origin.y = truncf((selfBounds.size.height - leftViewFrame.size.height)/2);   
        leftViewFrame.origin.x = 5;
        [_leftView setFrame:leftViewFrame];
    }
    textViewFrame.origin.x = /*leftViewFrame.origin.x +*/ leftViewFrame.size.width;
    textViewFrame.size.width -= (rightViewFrame.size.width + leftViewFrame.size.width);
    [_textView setFrame:textViewFrame];
    //if ( _overlay ) [self setOverlay:YES];
    [_overlay layoutInSuperview];
}

//---------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect 
{
    if ( _borderStyle == UITextBorderStyleBezel || _borderStyle == UITextBorderStyleRoundedRect )
    {
        CGRect theRect = rect;
        CGContextRef context = UIGraphicsGetCurrentContext();
        
       // CGContextSetInterpolationQuality ( context, kCGInterpolationHigh );
        CGFloat const radius = 6;
        addRoundedRectPath(context, theRect, radius, 0);
        CGContextClip(context);

        //CGColorRef begcolor = [DarkenedUIColorWithRgb(TextDefaultColor,4.0f) CGColor]; // +clar
        //CGColorRef endcolor = [DarkenedUIColorWithRgb(TextDefaultColor,5.0f) CGColor]; // +fosc
        //drawLinearGradientRect( context, theRect, begcolor, endcolor );

        UIColor *backColor = _backgroundColor;
        if ( backColor == nil ) backColor = [UIColor whiteColor];
    
        CGContextSetFillColorWithColor(context, [backColor CGColor]);
        
        CGContextFillRect(context, theRect);
        
        CGContextSetShadow ( context, CGSizeMake(0,1), 3 );
        
        CGContextSetLineWidth(context, 2.0f);
        
        UIColor *borderColor = _borderColor;
        if ( borderColor == nil ) borderColor = [UIColor lightGrayColor];
        
        CGContextSetStrokeColorWithColor( context, [borderColor CGColor] );
        //CGContextSetLineWidth(context, 4.0f);
        //CGContextSetStrokeColorWithColor( context, [[UIColor cyanColor] CGColor] );
        addRoundedRectPath(context, theRect, radius, 0);
        CGContextStrokePath(context);
        
        /*
        theRect.origin.y += 2.0f;
        theRect.size.height -= 2.0f;
        CGContextSetLineWidth(context, 2.0f);
        CGContextSetStrokeColorWithColor( context, [[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor] );
        setPathToRoundedRect(theRect, 7, 0, context);
        CGContextStrokePath(context);*/
    }
    [super drawRect:rect];
}


//---------------------------------------------------------------------------------
- (CGSize)sizeThatFitsWidth:(CGFloat)width
{
    NSString *text = [_textView text];
    UIFont *font = [_textView font];
    CGSize newSize = sizeWithText_font_max(text, font, width);
    
    //newSize.width += 8; // 16;
    newSize.width += [font lineHeight];
     
    //newSize.height += 1;
    if ( _rightView ) 
    {
        CGRect bounds = [_rightView bounds];
        CGFloat rightWidth = bounds.size.width;
        //newSize.width += rightWidth + 8;   // 
        newSize.width += rightWidth;   // 
    }
    
    if ( _leftView ) 
    {
        CGRect bounds = [_leftView bounds];
        CGFloat leftWidth = bounds.size.width;
        //newSize.width += rightWidth + 8;   // 
        newSize.width += leftWidth;   // 
    }
    
    
    if ( newSize.width < 72 ) newSize.width = 72;
    if ( newSize.height < 31 ) newSize.height = 31;
    
    //NSLog( @"RoundedTextView size:%g,%g", newSize.width, newSize.height);
    return newSize;
}


//---------------------------------------------------------------------------------
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

//---------------------------------------------------------------------------------
- (NSString*)text
{
    return [_textView text];
}

- (void)setText:(NSString *)text
{
    _textView.text = text;
}

- (NSRange)selectedRange
{
    return [_textView selectedRange];
}

- (void)setSelectedRange:(NSRange)range
{
    [_textView setSelectedRange:range];
}

- (UITextView*)textView
{
    return _textView;
}


- (NSString*)suggestionString
{
    return _textView.suggestionString;
}

- (void)setSuggestionString:(NSString *)suggestionString
{
    _textView.suggestionString = suggestionString;
}

////---------------------------------------------------------------------------------
//- (void)setText:(NSString*)newText
//{
//    [_textView setText:newText];
//    [self setNeedsLayout];
//}

//---------------------------------------------------------------------------------
- (void)setSmartText:(NSString*)newText
{
    if ( self.hasBullet ) return;
    [_textView setText:newText];
    [self setNeedsLayout];
}


- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

//---------------------------------------------------------------------------------
- (UITextBorderStyle)borderStyle
{
    return _borderStyle;
}

- (void)setBorderStyle:(UITextBorderStyle)bStyle
{
    _borderStyle = bStyle;
    [self setBackgroundColor:_backgroundColor];
    
    [self setNeedsDisplay];
}

//---------------------------------------------------------------------------------
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    
    UIColor *baseBackColor = backgroundColor;
    if ( baseBackColor == nil || _borderStyle != UITextBorderStyleNone )
        baseBackColor = [UIColor clearColor];
    
    [super setBackgroundColor:baseBackColor];
    
    [self setNeedsDisplay];
}


- (BOOL)wantsFixedOffset
{
    return _textView.wantsFixedOffset;
}

- (void)setWantsFixedOffset:(BOOL)wantsFixedOffset
{
    _textView.wantsFixedOffset = wantsFixedOffset;
}

- (BOOL)singleLine
{
    return _textView.singleLine;
}

- (void)setSingleLine:(BOOL)singleLine
{
    _textView.singleLine = singleLine;
    [_textView setScrollEnabled:!singleLine];
}

////---------------------------------------------------------------------------------
//- (void)setTag:(NSInteger)number
//{
//    [_textView setTag:number];  // l'hem de posar explicitament perque el forward invocation no ho faria
//}
//
////---------------------------------------------------------------------------------
//- (NSInteger)tag
//{
//    return [_textView tag];
//}

//---------------------------------------------------------------------------------
- (void)setHasBullet:(BOOL)value
{
    [_textView setTag:value!=0];
}

//---------------------------------------------------------------------------------
- (BOOL)hasBullet
{
    return [_textView tag]!=0;
}

//---------------------------------------------------------------------------------
- (UIView*)rightView
{
    return _rightView;
}

//---------------------------------------------------------------------------------
- (void)setRightView:(UIView*)right
{
    if ( _rightView != right )
    {
        [_rightView removeFromSuperview];
        _rightView = right;
        
        [_rightView setAlpha:0];
        if ( _rightView ) 
        {
            [self addSubview:_rightView];
            [UIView animateWithDuration:0.1f animations:^(void) { [_rightView setAlpha:1]; }];
        }
        
        [self setNeedsLayout];
    }
}

//---------------------------------------------------------------------------------
- (UIView*)leftView
{
    return _leftView;
}

//---------------------------------------------------------------------------------
- (void)setLeftView:(UIView*)left
{
    if ( _leftView != left )
    {
        [_leftView removeFromSuperview];
        _leftView = left;
        
        [_leftView setAlpha:0];
        if ( _leftView ) 
        {
            [self addSubview:_leftView];
            [UIView animateWithDuration:0.1f animations:^(void) { [_leftView setAlpha:1]; }];
        }
        
        [self setNeedsLayout];
    }
}


//---------------------------------------------------------------------------------
// Transferencia dels metodes de UIResponder al textView. 
// El forward no funciona en aquests doncs self es tambe un UIResponder.
//---------------------------------------------------------------------------------

// Transferencia dels metodes de UIResponder al textView. 
// El forward no funciona en aquests doncs self es tambe un UIResponder.


//777//---------------------------------------------------------------------------------
//- (UIView*)inputView
//{
//    return [_textView inputView];
//}


//777//---------------------------------------------------------------------------------
//- (void)setInputView:(UIView*)view
//{
//    [_textView setInputView:view];
//}


//777//---------------------------------------------------------------------------------
//- (UIView*)inputAccessoryView
//{
//    if ( _isCallingMe ) return nil;
//    _isCallingMe = YES;
//    UIView *view = [_textView inputAccessoryView];
//    _isCallingMe = NO;
//    return view;
//}

//777//---------------------------------------------------------------------------------
//- (void)setInputAccessoryView:(UIView*)view
//{
////    if ( _callingMe ) return;
////    _callingMe = YES;
//    [_textView setInputAccessoryView:view];
////    _callingMe = NO;
//}


//777- (BOOL)isFirstResponder { return [_textView isFirstResponder]; }
//777- (BOOL)canBecomeFirstResponder { return [_textView canBecomeFirstResponder]; }
//777- (BOOL)becomeFirstResponder { return [_textView becomeFirstResponder]; }
//777- (BOOL)canResignFirstResponder { return [_textView canResignFirstResponder]; }
//777- (void)reloadInputViews
//{
//    //[super reloadInputViews];
//    [_textView reloadInputViews];
//}
//777- (BOOL)resignFirstResponder { return [_textView resignFirstResponder]; }


////-------------------------------------------------------------------------------
//// signatura per forward al textView
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
//{
//    return [_textView methodSignatureForSelector:aSelector];
//}
//
////-------------------------------------------------------------------------------
//// forward al textView
//- (void)forwardInvocation:(NSInvocation *)invocation
//{
//    SEL aSelector = [invocation selector];
// 
//    if ([_textView respondsToSelector:aSelector]) [invocation invokeWithTarget:_textView];
//    else [self doesNotRecognizeSelector:aSelector];
//}

//-------------------------------------------------------------------------------
- (void)dealloc
{
}


///////////////////////////////////////////////////////////////////////////////////
#pragma mark TextView deteccio del primer touch
///////////////////////////////////////////////////////////////////////////////////

// USER INTERACTION FORA !
////-------------------------------------------------------------------------------
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if ( [_deleg respondsToSelector:@selector(roundedTextViewControlTouched:)] )
//    {
//        [_deleg roundedTextViewControlTouched:self];
//    }
//    
//    [_textView becomeFirstResponder];
//    [_textView setUserInteractionEnabled:YES];
//}


///////////////////////////////////////////////////////////////////////////////////
#pragma mark TextView delegates
///////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( _textView.suggestionLabel )
        [_textView setNeedsLayout];

    if (!_acceptNewlines)
    {
        if ( [text isEqualToString:@"\n"] )
        {
            if ( [_deleg respondsToSelector:@selector(roundedTextViewShouldReturn:)] )
            {
                BOOL shouldReturn = [_deleg roundedTextViewShouldReturn:self];
                //777 if ( shouldReturn ) [self resignFirstResponder];
                if ( shouldReturn ) [textView resignFirstResponder];
            }
            return NO;
        }
    }
    
    if ( [_deleg respondsToSelector:@selector(roundedTextView:shouldChangeCharactersInRange:replacementString:)] )
    {
        return [_deleg roundedTextView:self shouldChangeCharactersInRange:range replacementString:text];
    }
    return YES;
}

//-------------------------------------------------------------------------------
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ( [_deleg respondsToSelector:@selector(roundedTextViewShouldBeginEditing:)] )
    {
        return [_deleg roundedTextViewShouldBeginEditing:self];
    }
    return YES;
}

//-------------------------------------------------------------------------------
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ( [_deleg respondsToSelector:@selector(roundedTextViewDidBeginEditing:)] )
    {
        [_deleg roundedTextViewDidBeginEditing:self];
    }
}

//-------------------------------------------------------------------------------
- (void)textViewDidChange:(UITextView *)textView
{
    if ( [_deleg respondsToSelector:@selector(roundedTextViewDidChange:)] )
    {
        [_deleg roundedTextViewDidChange:self];
    }
}

//-------------------------------------------------------------------------------
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if ( [_deleg respondsToSelector:@selector(roundedTextViewDidChangeSelection:)] )
        [_deleg roundedTextViewDidChangeSelection:self];
}


//-------------------------------------------------------------------------------
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ( [_deleg respondsToSelector:@selector(roundedTextViewShouldEndEditing:)] )
    {
        return [_deleg roundedTextViewShouldEndEditing:self];
    }
    return YES;
}


//-------------------------------------------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //[_textView setUserInteractionEnabled:NO];  // USER INTERACTION FORA !
    if ( [_deleg respondsToSelector:@selector(roundedTextViewDidEndEditing:)] )
    {
        [_deleg roundedTextViewDidEndEditing:self];
    }
}


/*
//-------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_textView setContentOffset:(CGPointMake(0,0))];
}
*/

@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark ExpressionTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@implementation ExpressionTextView

- (void)_doInit
{
    [super _doInit];
    // [self setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:0.96f alpha:1.0f]];
    [self setBorderStyle:UITextBorderStyleBezel];
    [_textView setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [_textView setTextColor:UIColorWithRgb(TextDefaultColor)];
}


@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark ValueTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@implementation ValueTextView


- (void)_doInit
{
    [super _doInit];

    [self setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    [self setBorderStyle:UITextBorderStyleBezel];
    [_textView setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [_textView setTextColor:UIColorWithRgb(TextDefaultColor)];
    self.singleLine = YES;
    //[_textView adjustLineOffset];
}

////-------------------------------------------------------------------------------
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    [super textViewDidEndEditing:textView];
//    //[_textView adjustLineOffset];
//}



@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark SMTextField
///////////////////////////////////////////////////////////////////////////////////


@implementation SWTextField

@synthesize hasBullet=_hasBullet;

- (void)setSmartText:(NSString *)text
{
    if ( _hasBullet )
        return;
    [self setText:text];
}


@end

