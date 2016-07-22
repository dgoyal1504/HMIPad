//
//  SWLayoutOverlayViewCell.m
//  HmiPad
//
//  Created by Joan Martin on 9/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutOverlayViewCell.h"
#import "SWLayoutOverlayView.h"
#import "SWLayoutViewCell.h"

#import "CGGeometry+Additions.h"
#import "UIImage+Resize.h"


#define kPadding 0       // espai que deixem al costat
#define kTouchOffset 3    // descentrament cap a l'exterior de la deteccio de touch


@implementation SWLayoutOverlayViewCell
{
    SWLayoutViewCellEventType _eventType;
    
    CGPoint _firstTouchPosition;
    CGRect _firstTouchFrame;
}


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithLayoutViewCell:nil];
}


- (id)initWithLayoutViewCell:(SWLayoutViewCell*)cell
{
    CGRect frame = [cell layoutViewConvertedFrame];
    
    frame = _frameFromContentFrame(frame);
    
    self = [super init];
    if (self)
    {
        _layoutViewCell = cell;
        _frame = frame;
        _enableEditing = NO;
    }
    return self;
}


#define kLineWidth 4

//- (void)drawRect:(CGRect)rect
//{
//
//// NO TREURE, DEIXAR PER REFERENCIA
////
////    CGRect contentFrame = CGRectMake(kPadding, kPadding, rect.size.width - 2*kPadding, rect.size.height - 2*kPadding);
////    
////    CGFloat editPadd = _allowsEditing?0.0f:kLineWidth;
////    CGRect contentFrame = [self contentFrame];
////    CGRect frame = CGRectInset( contentFrame, -0.5f-editPadd/2, -0.5f-editPadd/2 ) ;
////    
////    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:editPadd];
////    path.lineWidth = 1.0f + editPadd;
////    [[UIColor blueColor] setStroke];
////    [path stroke];
////    
////    // quadre blanc adicional
//////    frame = CGRectInset( contentFrame, -1.5f-editPadd, -1.5f-editPadd ) ;
//////    frame.origin.x += helperCellFrame.origin.x;
//////    frame.origin.y += helperCellFrame.origin.y;
//////    
//////    path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:editPadd];
//////    path.lineWidth = 1.0f;
//////    [[UIColor whiteColor] setStroke];
//////    [path stroke];
//
//    if ( [self _allowsEditing] && ![self _hideButtons] )
//    {
//        UIImage *buttonNormal = [UIImage imageNamed:kButtonImage];
//        UIImage *buttonClear = [UIImage imageNamed:kButtonImage2];
//        
//        CGFloat screenScale = [[UIScreen mainScreen] scale];
//        CGFloat contentScale = self.contentScaleFactor;
//        CGFloat multiplyFactor = screenScale/contentScale;
//        if ( multiplyFactor > 1 ) multiplyFactor = 1;
//    
//        if ( multiplyFactor != 1 )
//        {
//            CGSize imageBounds = [buttonNormal size];
//            imageBounds.width *= multiplyFactor;
//            imageBounds.height *= multiplyFactor;
//        
//            buttonNormal = [buttonNormal resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageBounds contentScale:contentScale interpolationQuality:kCGInterpolationDefault cropped:NO];
//        
//            imageBounds = [buttonClear size];
//            imageBounds.width *= multiplyFactor;
//            imageBounds.height *= multiplyFactor;
//        
//            buttonClear = [buttonClear resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageBounds contentScale:contentScale interpolationQuality:kCGInterpolationDefault cropped:NO];
//        }
//        
//        UIImage *button = nil;
//        SWLayoutViewCellResizingStyle resizeStyle = self.resizeStyle;
//        
//        CGFloat offset = kPadding - kButtonRadius*multiplyFactor;
//
//        button = (SWLayoutViewCellResizingStyleVertical & resizeStyle) ? buttonNormal : buttonClear;
//        
//        [button drawAtPoint:CGPointMake(roundf(rect.size.width/2.0f-button.size.width/2.0f), offset)];
//        [button drawAtPoint:CGPointMake(roundf(rect.size.width/2.0f-button.size.width/2.0f), rect.size.height-button.size.height-offset)];
//    
//        button = (SWLayoutViewCellResizingStyleHorizontal & resizeStyle) ? buttonNormal : buttonClear;
//        
//        [button drawAtPoint:CGPointMake(offset, roundf(rect.size.height/2.0-button.size.height/2.0))];
//        [button drawAtPoint:CGPointMake(rect.size.width-button.size.width-offset, roundf(rect.size.height/2.0-button.size.height/2.0))];
//        
//        button = (SWLayoutViewCellResizingStyleAll == resizeStyle) ? buttonNormal : buttonClear;
//        
//        [button drawAtPoint:CGPointMake(offset, offset)];
//        [button drawAtPoint:CGPointMake(offset, rect.size.height-button.size.height-offset)];
//        [button drawAtPoint:CGPointMake(rect.size.width-button.size.width-offset, offset)];
//        [button drawAtPoint:CGPointMake(rect.size.width-button.size.width-offset, rect.size.height-button.size.height-offset)];
//    }
//}


#pragma mark Storage in collections

- (BOOL)isEqual:(SWLayoutOverlayViewCell*)overlayCell
{
    return _layoutViewCell == overlayCell.layoutViewCell;
}

- (NSUInteger)hash
{
    return _layoutViewCell.hash;
}


#pragma mark Properties

- (SWLayoutViewCellResizingStyle)resizeStyle
{
    if (_layoutViewCell)
        return _layoutViewCell.resizingStyle;
    
    return SWLayoutViewCellResizingStyleNone;
}


- (CGRect)contentFrame
{
    CGRect frame = CGRectMake(0, 0, _frame.size.width, _frame.size.height);
    return _contentFrameFromFrame(frame);
}


#pragma mark Public Methods

- (void)reloadFromCellFrame
{
    CGRect frame = [_layoutViewCell layoutViewConvertedFrame];
    self.frame = _frameFromContentFrame(frame);
}


- (void)reloadButtons
{
}


#pragma mark Private Methods

- (SWLayoutViewCellEventType)_layoutViewCellEventTypeForPoint:(CGPoint)aPoint //inView:(UIView*)view
{
    CGRect frame = self.frame;
    CGSize size = frame.size;
    CGPoint center = CGPointMake(size.width/2.0, size.height/2.0);
    CGPoint point = CGPointMake( aPoint.x - frame.origin.x, aPoint.y - frame.origin.y );

    SWLayoutViewCellResizingStyle resisingStyle = self.resizeStyle;
    
    BOOL allowsHorizontalResizing = (resisingStyle & SWLayoutViewCellResizingStyleHorizontal);
    BOOL allowsVerticalResizing = (resisingStyle & SWLayoutViewCellResizingStyleVertical);
    BOOL allowsAllResizing = (resisingStyle == SWLayoutViewCellResizingStyleAll);
    
    SWLayoutViewCellEventType eventType = SWLayoutViewCellEventTypeUnknown;
    
    CGRect contentFrame = CGRectMake(kPadding, kPadding, frame.size.width - 2*kPadding, frame.size.height - 2*kPadding);
    
    BOOL touchInside = CGRectContainsPoint(contentFrame, point);
    if (touchInside)
        eventType = SWLayoutViewCellEventTypeInside;
    
//    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    CGFloat zoomScale = [self _zoomScaleFactor];
//    CGFloat multiplyFactor = screenScale/zoomScale;
    
    CGFloat zoomScale = [self _zoomScaleFactor];
    CGFloat multiplyFactor = 1/zoomScale;
    
    CGFloat radius = 20*multiplyFactor;
    CGFloat offset = kPadding - kTouchOffset*multiplyFactor;
    
    CGPoint topLeft = CGPointMake(offset, offset);
    CGPoint topCenter = CGPointMake(center.x, offset);
    CGPoint topRight = CGPointMake(size.width-offset, offset);
    CGPoint middleLeft = CGPointMake(offset, center.y);
    CGPoint middleRight = CGPointMake(size.width-offset, center.y);
    CGPoint bottomLeft = CGPointMake(offset, size.height-offset);
    CGPoint bottomCenter = CGPointMake(center.x, size.height-offset);
    CGPoint bottomRight = CGPointMake(size.width-offset, size.height-offset);
    
    SWLayoutViewCellEventType buttonEvent = SWLayoutViewCellEventTypeUnknown;
    CGFloat smallerDistance = MAXFLOAT;
    CGFloat value;
    
    value = CGPointDistanceToPoint(point, topLeft);
    if (value < smallerDistance && allowsAllResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeTopLeft;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, topCenter);
    if (value < smallerDistance && allowsVerticalResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeTopCenter;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, topRight);
    if (value < smallerDistance && allowsAllResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeTopRight;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, middleLeft);
    if (value < smallerDistance && allowsHorizontalResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeMidleLeft;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, middleRight);
    if (value < smallerDistance && allowsHorizontalResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeMidleRight;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, bottomLeft);
    if (value < smallerDistance && allowsAllResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeBottomLeft;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, bottomCenter);
    if (value < smallerDistance && allowsVerticalResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeBottomCenter;
        smallerDistance = value;
    }
    
    value = CGPointDistanceToPoint(point, bottomRight);
    if (value < smallerDistance && allowsAllResizing)
    {
        buttonEvent = SWLayoutViewCellEventTypeBottomRight;
        smallerDistance = value;
    }
    
    // afegim una comprovacio de la distancia al centre per facilitar el moviment en casos de frame molt petita
    value = CGPointDistanceToPoint(point, center);
    if ( value < smallerDistance )
    {
        buttonEvent = SWLayoutViewCellEventTypeInside;
        smallerDistance = value;
    }
    
    if (smallerDistance < radius)
        eventType = buttonEvent;
    
    return eventType;
}


static CGRect _contentFrameFromFrame(CGRect frame)
{
    CGRect rect = frame;
    rect.origin.x += kPadding;
    rect.origin.y += kPadding;
    rect.size.width -= 2*kPadding;
    rect.size.height -= 2*kPadding;
    
    return rect;
}


static CGRect _frameFromContentFrame(CGRect frame)
{
    CGRect rect = frame;
    rect.origin.x -= kPadding;
    rect.origin.y -= kPadding;
    rect.size.width += 2*kPadding;
    rect.size.height += 2*kPadding;
    
    return rect;
}


- (CGRect)_computeRectForResizeForPoint:(CGPoint)aPoint eventType:(SWLayoutViewCellEventType)eventType
{
    CGPoint offset = CGPointMake(aPoint.x - _firstTouchPosition.x, aPoint.y - _firstTouchPosition.y);
    
    CGPoint origin = _firstTouchFrame.origin;
    CGSize size = _firstTouchFrame.size;
    
    if ( eventType & SWLayoutViewCellEventTypeTop)
    {
        CGFloat newHeight = 2*roundf((size.height-offset.y)/2);    // <- forcem mides multiples de 2
        origin.y = origin.y+size.height - newHeight;
        size.height = newHeight;
    }
    
    if ( eventType & SWLayoutViewCellEventTypeBottom )
    {
        CGFloat newHeight = 2*roundf((size.height+offset.y)/2);    // <- forcem mides multiples de 2
        size.height = newHeight;
    }
    
    if ( eventType & SWLayoutViewCellEventTypeLeft )
    {
        CGFloat newWidth = 2*roundf((size.width-offset.x)/2);
        origin.x = origin.x+size.width - newWidth;
        size.width = newWidth;
    }
    
    if ( eventType & SWLayoutViewCellEventTypeRight )
    {
        CGFloat newWidth = 2*roundf((size.width+offset.x)/2);
        size.width = newWidth;
    }
    
    if (size.width < 0)
    {
        size.width = 0;
        
        if (offset.x > 0)
            origin.x = _firstTouchFrame.origin.x + _firstTouchFrame.size.width;
    }
    
    if (size.height < 0)
    {
        size.height = 0;
        
        if (offset.y > 0)
            origin.y = _firstTouchFrame.origin.y + _firstTouchFrame.size.height;
    }
    
    CGRect frame;
    frame.origin = origin;
    frame.size = size;

    return frame;
}


#pragma mark - Private

- (CGFloat)_zoomScaleFactor
{
    CGFloat zoomScaleFactor = [_delegate layoutOverlayViewCellZoomScaleFactor:self];
    return zoomScaleFactor;
}


- (BOOL)_allowsEditing
{
    BOOL allowsFrameEditing = [_delegate layoutOverlayViewCellAllowsFrameEditing:self];
    return _enableEditing && allowsFrameEditing;
}


#pragma mark Events


- (SWLayoutViewCellEventType)eventTypeAtPoint:(CGPoint)aPoint
{
    return [self _layoutViewCellEventTypeForPoint:aPoint];
}


- (void)beginTouchAtPoint:(CGPoint)aPoint
{
    if ( ![self _allowsEditing] )
        return;
    
    _eventType = [self _layoutViewCellEventTypeForPoint:aPoint];
    
    _firstTouchFrame = self.frame;
    _firstTouchPosition = aPoint;
    
    if ([_delegate respondsToSelector:@selector(layoutOverlayViewCell:didBeginEventType:)])
        [_delegate layoutOverlayViewCell:self didBeginEventType:_eventType];
}


- (void)moveTouchToPoint:(CGPoint)aPoint
{
    if ( ![self _allowsEditing] )
        return;
    
    if (_eventType == SWLayoutViewCellEventTypeUnknown)
        return;
    
    //CGPoint superviewPosition = aPoint;
    CGRect frame = CGRectZero;
    CGRect contentFrame = CGRectZero;
    
    if (_eventType == SWLayoutViewCellEventTypeInside) // <---- Cas en el que mourem la cel·la!
    {
        frame = self.frame;
        frame.origin.x = _firstTouchFrame.origin.x + aPoint.x - _firstTouchPosition.x,
        frame.origin.y = _firstTouchFrame.origin.y + aPoint.y - _firstTouchPosition.y;
        contentFrame = _contentFrameFromFrame(frame);
    }
    
    else // <--------------- Altrament, es tracta d'un resize!
    {
        frame = [self _computeRectForResizeForPoint:aPoint eventType:_eventType];
        contentFrame = _contentFrameFromFrame(frame);
        CGRect firstContentFrame = _contentFrameFromFrame(_firstTouchFrame);
//        CGSize minimalSize = [_delegate layoutOverlayViewCellMinimalSize:self];
        CGSize minimalSize = _layoutViewCell.minimalSize;
        contentFrame = correctRect_fromRect_usingMinimalSize(contentFrame, firstContentFrame, minimalSize);
    }
    
    //nnn;
    //NSLog( @"frame %@", NSStringFromCGRect(frame) );
    //NSLog( @"right Before %g", frame.origin.x+frame.size.width) ;
    
    if ([_delegate respondsToSelector:@selector(layoutOverlayViewCell:willMoveToFrame:eventType:)])
    {
        contentFrame = [_delegate layoutOverlayViewCell:self willMoveToFrame:contentFrame eventType:_eventType];
        frame = _frameFromContentFrame(contentFrame);
    }
        
    self.frame = frame;
    
    //NSLog( @"frame %@", NSStringFromCGRect(frame) );
    //NSLog( @"right After %g", frame.origin.x+frame.size.width) ;
        
    if ([_delegate respondsToSelector:@selector(layoutOverlayViewCell:didMoveToFrame:eventType:)])
        [_delegate layoutOverlayViewCell:self didMoveToFrame:contentFrame eventType:_eventType];
}


- (void)endTouch
{
    if ( ![self _allowsEditing] )
        return;
    
    if (_eventType == SWLayoutViewCellEventTypeUnknown)
        return;

    if ([_delegate respondsToSelector:@selector(layoutOverlayViewCell:didEndEventType:)])
        [_delegate layoutOverlayViewCell:self didEndEventType:_eventType];
        
    _eventType = SWLayoutViewCellEventTypeUnknown;
}


@end
