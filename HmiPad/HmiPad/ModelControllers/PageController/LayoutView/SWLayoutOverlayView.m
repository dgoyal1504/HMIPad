//
//  SWRulerView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutOverlayView.h"
#import "SWLayoutOverlayViewCell.h"

#import "SWLayoutView.h"
#import "SWLayoutViewCell.h"

#import "SWColor.h"

#import "CGGeometry+Additions.h"
#import "UIImage+Resize.h"

#define DEBUGGING 0

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif


//#define kLineWidth 4
#define kLineWidth 0


@interface SWLayoutOverlayTouchInfo : NSObject

@property (nonatomic) SWLayoutViewCell *layoutCell;
@property (nonatomic) SWLayoutOverlayViewCell *touchCell;
@property (nonatomic) SWLayoutViewCellEventType eventType;

@end

@implementation SWLayoutOverlayTouchInfo
@end


@interface SWLayoutOverlayView()<UIGestureRecognizerDelegate,SWLayoutOverlayViewCellDelegate>
{
    __weak SWLayoutView *_layoutView;
    
    NSMutableData *_rulersData;
    NSMutableSet *_overlayCells;
    
    SWLayoutOverlayViewCell *_touchingOverlayCell;
    SWLayoutOverlayViewCell *_searchOverlayCell;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UILongPressGestureRecognizer *_longPressureRecognizer;
    UILongPressGestureRecognizer *_firstLongPressureRecognizer;
    
//    NSMutableSet *_touches;
    
    unsigned int _ignoreGestures:1;
    unsigned int _ignoreTouches:1;
    unsigned int _ignoreEndSelection:1;
    unsigned int _needsFrameCommit:1;
}
@end


@implementation SWLayoutOverlayView

- (void)doInit
{
    _showAlignmentRulers = YES;
    _autoAlignCells = YES;
    _rulersTintColor = [UIColor blueColor];
    _phoneIdiomRulerColor = [UIColor blackColor];
    //_phoneIdiomRulerColor = UIColorWithRgb(TangerineSelectionColor);
    _rulersData = [NSMutableData data];
    _overlayCells = [NSMutableSet set];
    _searchOverlayCell = [[SWLayoutOverlayViewCell alloc] initWithLayoutViewCell:nil];
    _zoomScaleFactor = 1.0f;
    
//    _touches = [NSMutableSet set];
//    self.multipleTouchEnabled = YES;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self doInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInit];
    }
    return self;
}


#pragma mark - Properties

- (void)setAllowFrameEditing:(BOOL)allowFrameEditing
{
    _allowFrameEditing = allowFrameEditing;
    
    for (SWLayoutOverlayViewCell *cell in _overlayCells)
        [cell reloadButtons];
    
    [self setNeedsDisplay];
}


- (void)setShowAlignmentRulers:(BOOL)showAlignmentRulers
{
    _showAlignmentRulers = showAlignmentRulers;
    [self setNeedsDisplay];
}


//- (void)setPhoneIdiomRulerPosition:(CGFloat)phoneIdiomRulerPosition
//{
//    _phoneIdiomRulerPosition = phoneIdiomRulerPosition;
//    [self setNeedsDisplay];
//}

- (void)setPhoneIdiomRulerSize:(CGSize)phoneIdiomRulerSize
{
    _phoneIdiomRulerSize = phoneIdiomRulerSize;
    [self setNeedsDisplay];
}


- (void)setAutoAlignCells:(BOOL)autoAlignCells
{
    _autoAlignCells = autoAlignCells;
}


- (void)setRulersTintColor:(UIColor *)rulersTintColor
{
    _rulersTintColor = rulersTintColor;
    [self setNeedsDisplay];
}


- (void)setPhoneIdiomRulerColor:(UIColor *)phoneIdiomRulerColor
{
    _phoneIdiomRulerColor = phoneIdiomRulerColor;
    [self setNeedsDisplay];
}

- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    _zoomScaleFactor = zoomScaleFactor;
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]*zoomScaleFactor];
}

//- (NSInteger)numberOfRulers
//{
//    return _rulersData.length/sizeof(SWRuler);
//}

- (void)setEditMode:(BOOL)editing
{
    _editMode = editing;
    self.userInteractionEnabled = editing;
        
    if (editing)
    {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
        _tapGestureRecognizer.delegate = self;
        _tapGestureRecognizer.cancelsTouchesInView = NO;  // <--- permetem el behaviour normal dels touch events a fora dels recognizers
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        _doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
        _doubleTapGestureRecognizer.delegate = self;
        _doubleTapGestureRecognizer.cancelsTouchesInView = NO;  // <--- permetem el behaviour normal dels touch events a fora dels recognizers
        [self addGestureRecognizer:_doubleTapGestureRecognizer];
        
        _longPressureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        _longPressureRecognizer.delegate = self;
        _longPressureRecognizer.minimumPressDuration = 0.5;
        _longPressureRecognizer.cancelsTouchesInView = NO; // <--- permetem el behaviour normal dels touch events a fora dels recognizers
        [self addGestureRecognizer:_longPressureRecognizer];
        
        _firstLongPressureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        _firstLongPressureRecognizer.delegate = self;
        _firstLongPressureRecognizer.minimumPressDuration = 0.15;
        _firstLongPressureRecognizer.cancelsTouchesInView = NO; // <--- permetem el behaviour normal dels touch events a fora dels recognizers
        [self addGestureRecognizer:_firstLongPressureRecognizer];
    }
    else
    {
        [self removeGestureRecognizer:_tapGestureRecognizer];
        _tapGestureRecognizer = nil;
        
        [self removeGestureRecognizer:_doubleTapGestureRecognizer];
        _doubleTapGestureRecognizer = nil;
        
        [self removeGestureRecognizer:_longPressureRecognizer];
        _longPressureRecognizer = nil;
        
        [self removeGestureRecognizer:_firstLongPressureRecognizer];
        _firstLongPressureRecognizer = nil;
    }
}


#pragma mark - Main Methods




//- (BOOL)containsRuler:(SWRuler)ruler
//{    
//    NSInteger count = [_rulersData length] / sizeof(SWRuler);
//    const SWRuler *c_rulersData = [_rulersData bytes];
//    
//    for (int i=0; i<count; ++i)
//    {
//        if (SWRulerEqualToRuler(ruler, c_rulersData[i]))
//        {
//            return YES;
//        }
//    }
//    
//    return NO;
//}


- (void)reloadOverlayFrames
{
    [_overlayCells makeObjectsPerformSelector:@selector(reloadFromCellFrame)];
    
    [self setNeedsDisplay];
}


- (void)reloadOverlayFrameForCell:(SWLayoutViewCell*)cell
{
    SWLayoutOverlayViewCell *overlayCell = [self _memberOverlayCellWithCell:cell];
    
    if ( overlayCell )
    {
        [overlayCell reloadFromCellFrame];
        [self setNeedsDisplay];
    }
}


- (void)updateEnabledEstateForCell:(SWLayoutViewCell *)cell
{
    [self _updateEnabledEstateForCell:cell];
}


- (void)updateLockStateForCells:(NSArray *)cells animated:(BOOL)animated
{
    for ( SWLayoutViewCell *cell in cells )
    {
        [self _updateLockStateForCell:cell animated:animated];
    }
}


- (void)markCells:(NSArray*)cells animated:(BOOL)animated
{
    for ( SWLayoutViewCell *cell in cells )
    {
        [self _markCell:cell animated:YES];
    }
}


- (void)unmarkCells:(NSArray*)cells animated:(BOOL)animated
{
    for ( SWLayoutViewCell *cell in cells )
    {
        [self _unmarkCell:cell animated:animated];
    }
    
    [self _removeAllRulers];
    [self setNeedsDisplay];
}


- (void)unmarkAllAnimated:(BOOL)animated
{
    [self _unmarkAllAnimated:animated];
}


- (void)moveToDirection:(SWLayoutResizerViewDirection)direction
{
    SWLayoutViewCell *uniqueCell = nil;
    
    if (_overlayCells.count == 1 )
        uniqueCell = [[_overlayCells anyObject] layoutViewCell];
    
    for ( SWLayoutOverlayViewCell *overlayCell in _overlayCells )
    {
        //SWLayoutViewCell *cell = overlayCell.layoutViewCell;
        //CGRect frame = cell.frame;
        CGRect frame = overlayCell.frame;
        switch (direction)
        {
            case SWLayoutResizerViewDirectionUp:
                frame.origin.y -= 1;
                break;
            case SWLayoutResizerViewDirectionLeft:
                frame.origin.x -= 1;
                break;
            case SWLayoutResizerViewDirectionDown:
                frame.origin.y += 1;
                break;
            case SWLayoutResizerViewDirectionRight:
                frame.origin.x += 1;
                break;
            default:
                break;
        }
        
        SWLayoutViewCell *cell = overlayCell.layoutViewCell;
        
        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:cell:didMoveToFrame:eventType:)] )
            [_delegate layoutOverlayView:self cell:cell didMoveToFrame:frame eventType:SWLayoutViewCellEventTypeZeroProximity];
        
        [overlayCell reloadFromCellFrame];
    }
    
    if ( _overlayCells.count > 0 )
        [self setNeedsDisplay];

    if ( uniqueCell )
        [self _snapshotRulersForLayoutCell:uniqueCell];

    if ( [_delegate respondsToSelector:@selector(layoutOverlayView:commitEditionForEventType:)] )
        [_delegate layoutOverlayView:self commitEditionForEventType:SWLayoutViewCellEventTypeZeroProximity];
}

- (void)resizeToDirection:(SWLayoutResizerViewDirection)direction
{
    SWLayoutViewCell *uniqueCell = nil;
    
    if (_overlayCells.count == 1 )
        uniqueCell = [[_overlayCells anyObject] layoutViewCell];
    
    for ( SWLayoutOverlayViewCell *overlayCell in _overlayCells )
    {
        SWLayoutViewCell *cell = overlayCell.layoutViewCell;
        
        SWLayoutViewCellResizingStyle resisingStyle = cell.resizingStyle;
        
        BOOL allowsHorizontalResizing = (resisingStyle & SWLayoutViewCellResizingStyleHorizontal);
        BOOL allowsVerticalResizing = (resisingStyle & SWLayoutViewCellResizingStyleVertical);
        
        BOOL canAdjust = YES;
        
        CGRect frame = cell.frame;
        CGSize minimalSize = CGSizeMake(8, 8);

        if ( _autoAlignCells )
            minimalSize = cell.minimalSize;
        
        switch (direction)
        {
            case SWLayoutResizerViewDirectionUp:  // expand
                frame.origin.y -= 1;
                frame.size.height += 2 ;
                canAdjust = allowsVerticalResizing;
                break;
            case SWLayoutResizerViewDirectionDown:  // shrink
                frame.origin.y += 1;
                frame.size.height -= 2 ;
                canAdjust = allowsVerticalResizing && (frame.size.height >= minimalSize.height);
                break;
            case SWLayoutResizerViewDirectionRight:  // expand
                frame.origin.x -= 1;
                frame.size.width += 2;
                canAdjust = allowsHorizontalResizing;
                break;
            case SWLayoutResizerViewDirectionLeft:   // shrink
                frame.origin.x += 1;
                frame.size.width -= 2;
                canAdjust = allowsHorizontalResizing && (frame.size.width >= minimalSize.width) ;
                break;
            default:
                break;
        }
        
        if ( canAdjust )
        {
            if ( [_delegate respondsToSelector:@selector(layoutOverlayView:cell:didMoveToFrame:eventType:)] )
                [_delegate layoutOverlayView:self cell:cell didMoveToFrame:frame eventType:SWLayoutViewCellEventTypeZeroProximity];
        
            [overlayCell reloadFromCellFrame];
        }
    }
    
    if ( _overlayCells.count > 0 )
        [self setNeedsDisplay];

    if ( uniqueCell )
        [self _snapshotRulersForLayoutCell:uniqueCell];

    if ( [_delegate respondsToSelector:@selector(layoutOverlayView:commitEditionForEventType:)] )
        [_delegate layoutOverlayView:self commitEditionForEventType:SWLayoutViewCellEventTypeZeroProximity];
}


- (void)snapshotRulersForCell:(SWLayoutViewCell*)cell
{
    [self _snapshotRulersForLayoutCell:cell];
}

- (NSInteger)numberOfCells
{
    return _overlayCells.count;
}


#pragma mark - Drawing


- (void)drawRect:(CGRect)rect
{
//    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    CGFloat contentScale = self.contentScaleFactor;
//    CGFloat multiplyFactor = screenScale/contentScale;
    
    CGFloat zoomScale = _zoomScaleFactor;
    CGFloat multiplyFactor = 1/zoomScale;
    
    
    if ( multiplyFactor > 1 ) multiplyFactor = 1;

    if (_phoneIdiomRulerSize.width>0)
    {
        [self _drawPhoneRulerWithfactor:multiplyFactor];
    }

    for (SWLayoutOverlayViewCell *overlayCell in _overlayCells)
    {
        [self _drawSelectionForOverlayCell:overlayCell factor:multiplyFactor];
        // ^-- dibuixem les linees aqui -no en els overLayCells- per assegurar que sempre queden per sota dels punts de seleccio.
    }

    if (_showAlignmentRulers)
    {
        [self _drawRulesWithFactor:multiplyFactor];
    }
    
    UIImage *buttonNormal=nil, *buttonClear=nil;
    for ( SWLayoutOverlayViewCell *overlayCell in _overlayCells )
    {
        [self _drawButtonsForOverlayCell:overlayCell factor:multiplyFactor
            buttonNormal:&buttonNormal buttonClear:&buttonClear];
    }
}


- (void)_drawPhoneRulerWithfactor:(CGFloat)multiplyFactor
{
    const CGFloat lengths[2] = {4*multiplyFactor,2*multiplyFactor}; // ####--####--####--####--####...
    //const NSInteger phase = 6*multiplyFactor; // 6 = 4 + 2 Each 6 points, the pattern is repeating.

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor( context, _phoneIdiomRulerColor.CGColor );
    CGContextSetLineDash(context, 0, lengths, 2); // Setting the dashed drawing pattern
    CGContextSetLineWidth( context, 1*multiplyFactor );
    
    CGSize size = self.bounds.size;
    CGContextMoveToPoint(context, _phoneIdiomRulerSize.width+0.5, 0);
    CGContextAddLineToPoint(context, _phoneIdiomRulerSize.width+0.5, size.height);
    
    CGContextMoveToPoint(context, 0, _phoneIdiomRulerSize.height+0.5);
    CGContextAddLineToPoint(context, _phoneIdiomRulerSize.width, _phoneIdiomRulerSize.height+0.5);

    CGContextStrokePath(context);
}


- (void)_drawRulesWithFactor:(CGFloat)multiplyFactor
{
    const CGFloat lengths[2] = {4*multiplyFactor,2*multiplyFactor}; // ####--####--####--####--####...
    const NSInteger phase = 6*multiplyFactor; // 6 = 4 + 2 Each 6 points, the pattern is repeating.
    
    // Getting the rulers
    NSInteger count = [_rulersData length] / sizeof(SWRuler);
    const SWRuler *c_rulersData = [_rulersData bytes];
    
    // We set the tintColor to stroke the drawed lines
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor( context, _rulersTintColor.CGColor );
    CGContextSetLineDash(context, 0, lengths, 2); // Setting the dashed drawing pattern
    CGContextSetLineWidth( context, 1*multiplyFactor );
    //CGContextSetAllowsAntialiasing(context, false); // Removing antialising
    
    for (int i=0; i<count; ++i) 
    {     
        CGContextSaveGState( context );
        
        SWRuler ruler = c_rulersData[i];
        CGPoint fromPoint = ruler.fromPoint;
        CGPoint toPoint = ruler.toPoint;
        
        if ( fromPoint.x == toPoint.x ) // vertical
        {
            CGContextClipToRect( context, CGRectMake( fromPoint.x-1, fromPoint.y, toPoint.x-fromPoint.x+2, toPoint.y-fromPoint.y ) );
            fromPoint.y = phase * floorf( fromPoint.y/phase );
        } 
        else if ( fromPoint.y == toPoint.y ) // horizontal
        {
            CGContextClipToRect( context, CGRectMake( fromPoint.x, fromPoint.y-1, toPoint.x-fromPoint.x, toPoint.y-fromPoint.y+2 ) );
            fromPoint.x = phase * floorf( fromPoint.x/phase );
        }
        
        // Draw the line
        CGContextMoveToPoint( context, fromPoint.x, fromPoint.y );
        CGContextAddLineToPoint( context, toPoint.x, toPoint.y );
        CGContextStrokePath( context );
    
        // Restore context
        CGContextRestoreGState( context );
    }
}


- (void)_drawSelectionForOverlayCell:(SWLayoutOverlayViewCell*)overlayCell factor:(CGFloat)multiplyFactor
{
    //const CGFloat lengths[2] = {2*multiplyFactor,4*multiplyFactor}; // ####--####--####--####--####...

    CGFloat editPadd = _allowFrameEditing && overlayCell.enableEditing ? 0.0f : kLineWidth;
    
    CGRect contentFrame = [overlayCell contentFrame];
    CGRect overlayCellFrame = overlayCell.frame;
    
    CGRect frame = CGRectInset( contentFrame, -0.5f-editPadd/2, -0.5f-editPadd/2 ) ;
    frame.origin.x += overlayCellFrame.origin.x;
    frame.origin.y += overlayCellFrame.origin.y;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:editPadd];
    [path setLineWidth:(1.0f + editPadd)*multiplyFactor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor( context, _phoneIdiomRulerColor.CGColor );
    CGContextSetLineDash(context, 0, NULL, 0);
    
    UIColor *lineColor = overlayCell.innerEditing ? [UIColor darkGrayColor] : [UIColor blueColor] ;
    CGContextSetStrokeColorWithColor( context, lineColor.CGColor );
    
    [path stroke];
    
    // quadre blanc adicional
//    frame = CGRectInset( contentFrame, -1.5f-editPadd, -1.5f-editPadd ) ;
//    frame.origin.x += helperCellFrame.origin.x;
//    frame.origin.y += helperCellFrame.origin.y;
//    
//    path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:editPadd];
//    path.lineWidth = 1.0f;
//    [[UIColor whiteColor] setStroke];
//    [path stroke];
}

#define kButtonRadius 9   // posicio per el centratge dels butons
#define kSelectionImage @"selection_blank_inside.png"
#define kButtonImage @"SelectionKnob.png"
#define kButtonImage2 @"SelectionKnobClear.png"


- (void)_drawButtonsForOverlayCell:(SWLayoutOverlayViewCell*)overlayCell factor:(CGFloat)multiplyFactor
    buttonNormal:(UIImage**)buttonNormal buttonClear:(UIImage**)buttonClear
{

    BOOL bool1 = _allowFrameEditing;
    BOOL bool2 = overlayCell.enableEditing;
    //BOOL bool3 = !overlayCell.layoutViewCell.contentLayoutView.normalTouchesEnabled;
    BOOL bool3 = !overlayCell.innerEditing;

//    if ( _allowFrameEditing && overlayCell.enableEditing && !overlayCell.layoutViewCell.contentLayoutView.normalTouchesEnabled )
    if ( bool1 && bool2 && bool3 )
    {
        CGFloat contentScale = self.contentScaleFactor;  // already premultiplied by zoom
        //if ( multiplyFactor > 1 ) multiplyFactor = 1;
        
        if ( *buttonNormal == nil )
        {
            *buttonNormal = [UIImage imageNamed:kButtonImage];
            if ( multiplyFactor != 1 )
            {
                CGSize imageBounds = [*buttonNormal size];
                imageBounds.width *= multiplyFactor;
                imageBounds.height *= multiplyFactor;
        
                *buttonNormal = [*buttonNormal resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageBounds contentScale:contentScale interpolationQuality:kCGInterpolationDefault cropped:NO];
            }
        }
        
        if ( *buttonClear == nil )
        {
            *buttonClear = [UIImage imageNamed:kButtonImage2];
            if ( multiplyFactor != 1 )
            {
                CGSize imageBounds = [*buttonClear size];
                imageBounds.width *= multiplyFactor;
                imageBounds.height *= multiplyFactor;
        
                *buttonClear = [*buttonClear resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageBounds contentScale:contentScale interpolationQuality:kCGInterpolationDefault cropped:NO];
            }
        }
        
        UIImage *button = nil;
        SWLayoutViewCellResizingStyle resizeStyle = overlayCell.resizeStyle;
        
        CGFloat offset =  -kButtonRadius*multiplyFactor;

        //CGRect rect = overlayCell.frame;
        
        CGRect rect = [overlayCell contentFrame];
        CGRect overlayCellFrame = overlayCell.frame;
        rect.origin.x += overlayCellFrame.origin.x;
        rect.origin.y += overlayCellFrame.origin.y;

        button = (SWLayoutViewCellResizingStyleVertical & resizeStyle) ? *buttonNormal : *buttonClear;
        
        [button drawAtPoint:CGPointMake(roundf(rect.origin.x+rect.size.width/2.0f-button.size.width/2.0f), rect.origin.y+offset)];
        [button drawAtPoint:CGPointMake(roundf(rect.origin.x+rect.size.width/2.0f-button.size.width/2.0f), rect.origin.y+rect.size.height-button.size.height-offset)];
    
        button = (SWLayoutViewCellResizingStyleHorizontal & resizeStyle) ? *buttonNormal : *buttonClear;
        
        [button drawAtPoint:CGPointMake(rect.origin.x+offset, roundf(rect.origin.y+rect.size.height/2.0-button.size.height/2.0))];
        [button drawAtPoint:CGPointMake(rect.origin.x+rect.size.width-button.size.width-offset, roundf(rect.origin.y+rect.size.height/2.0-button.size.height/2.0))];
        
        button = (SWLayoutViewCellResizingStyleAll == resizeStyle) ? *buttonNormal : *buttonClear;
        
        [button drawAtPoint:CGPointMake(rect.origin.x+offset, rect.origin.y+offset)];
        [button drawAtPoint:CGPointMake(rect.origin.x+offset, rect.origin.y+rect.size.height-button.size.height-offset)];
        [button drawAtPoint:CGPointMake(rect.origin.x+rect.size.width-button.size.width-offset, rect.origin.y+offset)];
        [button drawAtPoint:CGPointMake(rect.origin.x+rect.size.width-button.size.width-offset, rect.origin.y+rect.size.height-button.size.height-offset)];
    }
}



#pragma mark - Private


- (void)_addRuler:(SWRuler)ruler
{
    [_rulersData appendBytes:&ruler length:sizeof(SWRuler)];
}


- (void)_addRulers:(NSData*)rulers
{
    [_rulersData appendData:rulers];
}


- (void)_removeAllRulers
{
    [_rulersData setLength:0];
}


- (SWLayoutOverlayTouchInfo*)_overlayTouchInfoAtPoint:(CGPoint)point
{
    NSInteger topCellIndex = -1;
    
    SWLayoutOverlayTouchInfo *overlayTouchInfo = [[SWLayoutOverlayTouchInfo alloc] init];
    SWLayoutViewCell *layoutCell = [_dataSource layoutOverlayView:self cellAtPoint:point];
    SWLayoutOverlayViewCell *touchCell = nil;
    SWLayoutViewCellEventType eventType = SWLayoutViewCellEventTypeUnknown;

    for (SWLayoutOverlayViewCell *overlayCell in _overlayCells)
    {
        NSInteger cellIndex = [_dataSource layoutOverlayView:self indexOfCell:overlayCell.layoutViewCell];
        SWLayoutViewCellEventType overlayEventType = [overlayCell eventTypeAtPoint:point];
        
        if (overlayEventType & SWLayoutViewCellEventTypeButtons) cellIndex += INT_MAX/2;   // <- donem prioritat als ...EventTypeButtons
        
        if ( cellIndex > topCellIndex )
        {
            if ( overlayEventType & SWLayoutViewCellEventTypeButtons ||
                (overlayEventType & SWLayoutViewCellEventTypeInside && overlayCell.layoutViewCell == layoutCell) )
            {
                topCellIndex = cellIndex;
                touchCell = overlayCell;
                eventType = overlayEventType;
            }
        }
        
    }

    overlayTouchInfo.layoutCell = layoutCell;
    overlayTouchInfo.touchCell = touchCell;
    overlayTouchInfo.eventType = eventType;
    return overlayTouchInfo;
}


// torna el overlayViewCell en el punt sense tenir en compte la transparencia
- (SWLayoutOverlayViewCell*)_layoutOverlayViewCellWithBoundsAtPoint:(CGPoint)point
{
    NSInteger topCellIndex = -1;
    SWLayoutOverlayViewCell *touchCell = nil;

    for (SWLayoutOverlayViewCell *overlayCell in _overlayCells)
    {
        BOOL pointInside = CGRectContainsPoint( overlayCell.frame, point );
        if ( pointInside )
        {
            NSInteger cellIndex = [_dataSource layoutOverlayView:self indexOfCell:overlayCell.layoutViewCell];
            if ( cellIndex > topCellIndex )
            {
                topCellIndex = cellIndex;
                touchCell = overlayCell;
            }
        }
    }
    return touchCell;
}


- (SWLayoutOverlayViewCell*)_memberOverlayCellWithCell:(SWLayoutViewCell*)cell
{
    _searchOverlayCell.layoutViewCell = cell;
    SWLayoutOverlayViewCell *overlayCell = [_overlayCells member:_searchOverlayCell];
    return overlayCell;
}


- (void)_selectionChange
{
    if ( [_delegate respondsToSelector:@selector(layoutOverlayView:selectionDidChange:)] )
            [_delegate layoutOverlayView:self selectionDidChange:_overlayCells];
}

- (void)_markCell:(SWLayoutViewCell*)cell animated:(BOOL)animated
{
    SWLayoutOverlayViewCell *overlayCell = [self _memberOverlayCellWithCell:cell];
        
    if (!overlayCell)
    {
        overlayCell = [[SWLayoutOverlayViewCell alloc] initWithLayoutViewCell:cell];
        //overlayCell.userInteractionEnabled = NO;   // <-- necesari per no interferir en els touches del self
        overlayCell.delegate = self;
        overlayCell.enableEditing = !cell.locked;
        overlayCell.innerEditing = cell.enabled;
        [_overlayCells addObject:overlayCell];
        //[self addSubview:overlayCell];
        [self setNeedsDisplay];
        
        [self _selectionChange];
    }
}


- (void)_unmarkCell:(SWLayoutViewCell*)cell animated:(BOOL)animated
{
    SWLayoutOverlayViewCell *overlayCell = [self _memberOverlayCellWithCell:cell];
    if (overlayCell)
    {
        //[overlayCell removeFromSuperview];
        [_overlayCells removeObject:overlayCell];
        [self setNeedsDisplay];
        
        [self _selectionChange];
    }
}

- (void)_unmarkAllAnimated:(BOOL)animated
{
    [_overlayCells removeAllObjects];
    [self setNeedsDisplay];

    [self _selectionChange];
}


- (void)_updateEnabledEstateForCell:(SWLayoutViewCell*)cell
{
    SWLayoutOverlayViewCell *overlayCell = [self _memberOverlayCellWithCell:cell];
    if ( overlayCell )
    {
        BOOL innerEditing = cell.enabled;
        if ( overlayCell.innerEditing != innerEditing )
        {
            overlayCell.innerEditing = innerEditing;
            [self setNeedsDisplay];
        }
    }
}


- (void)_updateLockStateForCell:(SWLayoutViewCell*)cell animated:(BOOL)animated
{
    SWLayoutOverlayViewCell *overlayCell = [self _memberOverlayCellWithCell:cell];
    if ( overlayCell )
    {
        BOOL enableEditing = !cell.locked;
        if ( overlayCell.enableEditing != enableEditing )
        {
            overlayCell.enableEditing = enableEditing;
            [self setNeedsDisplay];
        }
    }
}


- (void)_selectLayoutCell:(SWLayoutViewCell*)cell animated:(BOOL)animated
{
    BOOL shouldSelect = YES;
    if ( [_delegate respondsToSelector:@selector(layoutOverlayView:shouldSelectCell:)] )
        shouldSelect = [_delegate layoutOverlayView:self shouldSelectCell:cell];

    if ( shouldSelect )
    {
        [self _markCell:cell animated:animated];
        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:didSelectCell:)] )
            [_delegate layoutOverlayView:self didSelectCell:cell];
    }
}


- (void)_selectSingleSelectionLayoutCell:(SWLayoutViewCell*)aCell animated:(BOOL)animated
{
    [self _selectLayoutCell:aCell animated:animated];
    
    NSArray *allObjects = [_overlayCells allObjects];
    for ( SWLayoutOverlayViewCell *overlayCell in allObjects )
    {
        SWLayoutViewCell *cell = overlayCell.layoutViewCell;
        if ( cell != aCell )
        {
            [self _deselectLayoutCell:cell animated:animated];
        }
    }
    
}


- (void)_deselectLayoutCell:(SWLayoutViewCell*)cell animated:(BOOL)animated
{
    [self _unmarkCell:cell animated:animated];
    
    if ( [_delegate respondsToSelector:@selector(layoutOverlayView:didDeselectCell:)] )
        [_delegate layoutOverlayView:self didDeselectCell:cell];
}


- (void)_deselectAllCellsAnimated:(BOOL)animated
{
    [self _unmarkAllAnimated:animated];
    
    if ( [_delegate respondsToSelector:@selector(layoutOverlayViewDidDeselectAll:)] )
        [_delegate layoutOverlayViewDidDeselectAll:self];
}


- (void)_endSelectionForOverlayCell:(SWLayoutOverlayViewCell*)overlayCell animated:(BOOL)animated
{
    if ( overlayCell == nil )
        return;

    SWLayoutViewCell *cell = overlayCell.layoutViewCell;
    [self _deselectLayoutCell:cell animated:animated];
}


//- (void)_beginSelectionAtPoint:(CGPoint)point forOverlayCell:(SWLayoutOverlayViewCell*)overlayCell animated:(BOOL)animated
//{
//    SWLayoutViewCell *cell = overlayCell.layoutViewCell;
//    
//    if ( cell == nil )
//        cell = [_dataSource layoutOverlayView:self cellAtPoint:point];
//    
//    
//    if ( cell == nil )
//    {
//        [self _deselectAllCellsAnimated:animated];
//    }
//
//    else
//    {
//        if (_allowsMultipleSelection)
//        {
//            if (overlayCell == nil)
//            {
//                [self _selectLayoutCell:cell animated:animated];
//            }
//            // les deseleccions les fem al reconeixedor del tapGesture
//        }
//        else
//        {
//            [self _selectSingleSelectionLayoutCell:cell animated:animated];
//        }
//    }
//}


- (void)_beginSelectionOfLayoutViewCell:(SWLayoutViewCell*)cell withOverlayCell:(SWLayoutOverlayViewCell*)overlayCell animated:(BOOL)animated
{
    if ( cell == nil )
    {
        [self _deselectAllCellsAnimated:animated];
    }

    else
    {
        if (_allowsMultipleSelection)
        {
            if (overlayCell == nil)
            {
                [self _selectLayoutCell:cell animated:animated];
            }
            // les deseleccions les fem al reconeixedor del tapGesture
        }
        else
        {
            [self _selectSingleSelectionLayoutCell:cell animated:animated];
        }
    }
}

- (void)_endSnapshotRulers
{
    [self _removeAllRulers];
    [self setNeedsDisplay];
}

- (void)_snapshotRulersForLayoutCell:(SWLayoutViewCell*)layoutViewCell
{
    [self _removeAllRulers];
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(_endSnapshotRulers) object:nil];

    if ( _showAlignmentRulers )
    {
        NSData *data = [_dataSource layoutOverlayView:self rulersForCell:layoutViewCell
            movingToFrame:layoutViewCell.frame correctedFrame:NULL eventType:SWLayoutViewCellEventTypeZeroProximity];
        
        [self _addRulers:data];
        [self setNeedsDisplay];
        
        [self performSelector:@selector(_endSnapshotRulers) withObject:nil afterDelay:1.0];
    }
}



#pragma mark SWLayoutOverlayViewCellDelegate Delegate

- (void)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell didBeginEventType:(SWLayoutViewCellEventType)eventType
{
    if ( _showAlignmentRulers )
    {
        SWLayoutViewCell *layoutViewCell = overlayCell.layoutViewCell;
        NSData *data = [_dataSource layoutOverlayView:self rulersForCell:layoutViewCell
            movingToFrame:layoutViewCell.frame correctedFrame:NULL eventType:eventType];
        
        [self _addRulers:data];
        [self setNeedsDisplay];
    }
}


- (CGRect)layoutOverlayViewCell:(SWLayoutOverlayViewCell *)overlayCell willMoveToFrame:(CGRect)frame eventType:(SWLayoutViewCellEventType)eventType
{
    [self _removeAllRulers];
    
    CGRect newFrame = CGRectZero;
    
    if ( _showAlignmentRulers || _autoAlignCells )
    {
        SWLayoutViewCell *layoutViewCell = overlayCell.layoutViewCell;
        NSData *data = [_dataSource layoutOverlayView:self rulersForCell:layoutViewCell
            movingToFrame:frame correctedFrame:&newFrame eventType:eventType];
        
        [self _addRulers:data];
        [self setNeedsDisplay];
    }
    
    if ( !_autoAlignCells )
        newFrame = frame;
    
    return newFrame;
}


- (void)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell didMoveToFrame:(CGRect)frame eventType:(SWLayoutViewCellEventType)eventType
{
    SWLayoutViewCell *movingCell = overlayCell.layoutViewCell;
    
    // moure: les movem totes
    if ( eventType & SWLayoutViewCellEventTypeInsideZeroProximity )
    {
        CGRect movingCellFrame = movingCell.frame;
        CGPoint offsetPoint;
        offsetPoint.x = frame.origin.x - movingCellFrame.origin.x;
        offsetPoint.y = frame.origin.y - movingCellFrame.origin.y;
    
        for ( SWLayoutOverlayViewCell *movingOverCell in _overlayCells )
        {
            if ( movingOverCell.enableEditing ) // <- no volem moure les celdes bloquejades
            {
                SWLayoutViewCell *cell = movingOverCell.layoutViewCell;
                CGRect newFrame = cell.frame;
                newFrame.origin.x += offsetPoint.x;
                newFrame.origin.y += offsetPoint.y;
    
                if ( [_delegate respondsToSelector:@selector(layoutOverlayView:cell:didMoveToFrame:eventType:)] )
                    [_delegate layoutOverlayView:self cell:cell didMoveToFrame:newFrame eventType:eventType];

                [movingOverCell reloadFromCellFrame];
            }
        }
    }
    
    // resize: resizem nomes la actual
    else
    {
        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:cell:didMoveToFrame:eventType:)] )
            [_delegate layoutOverlayView:self cell:movingCell didMoveToFrame:frame eventType:eventType];
    }

    _needsFrameCommit = YES;
    [self setNeedsDisplay];
}


- (void)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell didEndEventType:(SWLayoutViewCellEventType)eventType
{
    [self _removeAllRulers];
    [self setNeedsDisplay];
    
    if ( _needsFrameCommit )
    {
        _needsFrameCommit = NO;
        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:commitEditionForEventType:)] )
            [_delegate layoutOverlayView:self commitEditionForEventType:eventType];
    }
}


//- (CGSize)layoutOverlayViewCellMinimalSize:(SWLayoutOverlayViewCell *)overlayCell
//{
//    return overlayCell.layoutViewCell.minimalSize;
//}


- (BOOL)layoutOverlayViewCellAllowsFrameEditing:(SWLayoutOverlayViewCell*)overlayCell
{
    BOOL allow = _allowFrameEditing;
    return allow;
}


- (CGFloat)layoutOverlayViewCellZoomScaleFactor:(SWLayoutOverlayViewCell*)overlayCell
{
    return _zoomScaleFactor;
    //return self.contentScaleFactor;
}


#pragma mark - Content scale


//- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
//{
//    [super setContentScaleFactor:contentScaleFactor];
//}


#pragma mark - UIGestureRecognizer Delegate and action


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( recognizer == _doubleTapGestureRecognizer )
    {
        CGPoint point = [touch locationInView:self];
        SWLayoutViewCell *cell = [_dataSource layoutOverlayView:self cellAtPoint:point];
        return cell.contentLayoutView != nil ;
    }
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( gestureRecognizer == _tapGestureRecognizer || gestureRecognizer == _doubleTapGestureRecognizer )
        return NO;
    
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if (_ignoreGestures)
            return NO;

    if ( recognizer == _longPressureRecognizer )
    {
        CGPoint point = [recognizer locationInView:self];
        SWLayoutViewCell *cell = [_dataSource layoutOverlayView:self cellAtPoint:point];
    
        return cell==nil;
    }
    
    return YES;
}


- (void)_prepareInitialTouchAtPoint:(CGPoint)point onlyIfSelected:(BOOL)onlyIfSelected
{
    SWLayoutOverlayTouchInfo *overlayTouchInfo = [self _overlayTouchInfoAtPoint:point];
    SWLayoutOverlayViewCell *touchCell = overlayTouchInfo.touchCell;
    
    if ( onlyIfSelected==NO || touchCell )
    {
        NSLog1(@"FIRST GESTURE (Tap or first)");
        SWLayoutViewCellEventType eventType = overlayTouchInfo.eventType;
    
        BOOL touchInButton = ((eventType&SWLayoutViewCellEventTypeButtons) != 0);   // si touchCell es nil sera NO
    
        _ignoreTouches = NO;
        _ignoreGestures = touchInButton;
        _ignoreEndSelection = (_allowsMultipleSelection == NO || touchCell == nil || touchInButton );
        
        if ( ! touchInButton )
        {
            [self _beginSelectionOfLayoutViewCell:overlayTouchInfo.layoutCell withOverlayCell:touchCell animated:YES];
            overlayTouchInfo = [self _overlayTouchInfoAtPoint:point];
        }
    
        _touchingOverlayCell = overlayTouchInfo.touchCell;    // <-- overlayTouchInfo pot haver canviat.
        [_touchingOverlayCell beginTouchAtPoint:point];
    }
}

//- (void)logRecognizer:(UIGestureRecognizer*)recognizer
//{
//    if ( recognizer == _doubleTapGestureRecognizer ) NSLog(@"Double");
//    if ( recognizer == _tapGestureRecognizer ) NSLog(@"Tap");
//    if ( recognizer == _longPressureRecognizer ) NSLog(@"Long");
//    if ( recognizer == _firstLongPressureRecognizer ) NSLog(@"FirstLong");
//}


- (void)_gestureRecognized:(UIGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    //[self logRecognizer:recognizer];
    
    if ( recognizer == _doubleTapGestureRecognizer )
    {
        NSLog1( @"DOUBLE TAP GESTURE" );
        SWLayoutViewCell *cell = [_dataSource layoutOverlayView:self cellAtPoint:point];
        SWLayoutView *contentLayoutView = cell.contentLayoutView;
        if ( contentLayoutView != nil )
        {
            CGPoint ppoint = [contentLayoutView convertPoint:point fromView:self];
            
            NSLog1(@"%ld call normalTouchesEnabled", (long)self);
            [contentLayoutView performSelectionAtPoint:ppoint];
        }
        
        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:didPerformDoubleTapAtPoint:)] )
            [_delegate layoutOverlayView:self didPerformDoubleTapAtPoint:point];
    }
    
    if ( (recognizer == _firstLongPressureRecognizer && _ignoreTouches && recognizer.state == UIGestureRecognizerStateBegan) ||
         (recognizer == _tapGestureRecognizer  && !_touchingOverlayCell) /* ||
         recognizer == _doubleTapGestureRecognizer*/ )
    {
    
        NSLog1(@"%ld call _prepareInitialTouchAtPoint", (long)self);
        [self _prepareInitialTouchAtPoint:point onlyIfSelected:NO];
    }
    
    if ( recognizer == _tapGestureRecognizer )
    {
        NSLog1(@"TAP GESTURE");
        
        if (  !_ignoreEndSelection )
        {
            NSLog1(@"%ld call _endSelectionForOverlayCell", (long)self);
            [self _endSelectionForOverlayCell:_touchingOverlayCell animated:YES];
        }

        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:didPerformTapAtPoint:)] )
            [_delegate layoutOverlayView:self didPerformTapAtPoint:point];
    }
    
    if ( recognizer == _longPressureRecognizer && recognizer.state == UIGestureRecognizerStateBegan )
    {
        NSLog1(@"LONG GESTURE");
        
        //[self _cancelSelectionForOverlayCell:_currentOverlayCell animated:YES];
        if ( [_delegate respondsToSelector:@selector(layoutOverlayView:didPerformLongPresureAtPoint:)] )
            [_delegate layoutOverlayView:self didPerformLongPresureAtPoint:point];
    }
}

#pragma marc Point Inside behavior

// considerem que el punt es dins si el punt esta en una celda o un overlay
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [super pointInside:point withEvent:event];
    if ( isInside && !_isBottomPosition )
    {
        SWLayoutOverlayTouchInfo *overlayTouchInfo = [self _overlayTouchInfoAtPoint:point];
        isInside = overlayTouchInfo.layoutCell != nil || overlayTouchInfo.touchCell != nil;
    }
    return isInside;
}


#pragma mark Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog1(@"BEGAN!");
    _ignoreTouches = YES;   // <-- els touches s'ignoren fins que un dels recognizers diu lo contrari
    
    NSLog1( @"Touch Count :%d", touches.count );
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self _prepareInitialTouchAtPoint:point onlyIfSelected:YES];    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog1(@"MOVED!");
    
    
    //NSLog( @"Touch Count :%d", touches.count );
    if ( _ignoreTouches )
        return;
    
    _ignoreGestures = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [_touchingOverlayCell moveTouchToPoint:point];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog1(@"ENDED");
    
    if ( _ignoreTouches )
        return;
    
    _ignoreGestures = NO;
    
    [_touchingOverlayCell endTouch];
    _touchingOverlayCell = nil;
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog1(@"CANCELLED");
    if ( _ignoreTouches )
        return;
    
    _ignoreGestures = NO;
    
    [_touchingOverlayCell endTouch];
    _touchingOverlayCell = nil;
}

@end
