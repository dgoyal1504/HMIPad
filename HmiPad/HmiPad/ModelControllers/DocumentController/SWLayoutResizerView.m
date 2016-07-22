//
//  SWLayoutOverlayResizerView.m
//  HmiPad
//
//  Created by Joan Lluch on 15/10/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutResizerView.h"

@class SWLayoutResizerViewButton;



#pragma mark SWLayoutResizerViewButtonDelegate

@protocol SWLayoutResizerViewButtonDelegate <NSObject>

- (void)resizerViewButton:(SWLayoutResizerViewButton*)resizerButton touchBeganAtPoint:(CGPoint)point;
- (void)resizerViewButton:(SWLayoutResizerViewButton*)resizerButton touchMovedToPoint:(CGPoint)point;
- (void)resizerViewButtonTouchEnded:(SWLayoutResizerViewButton*)resizerButton;
- (void)resizerViewButtonTouchCancelled:(SWLayoutResizerViewButton*)resizerButton;

@end


#pragma mark SWLayoutResizerViewButton

@interface SWLayoutResizerViewButton: UIImageView

@property (nonatomic,weak) id<SWLayoutResizerViewButtonDelegate> delegate;

@end


#define BackgroundColor [UIColor colorWithWhite:0.0 alpha:0.9]
#define SelectedBackgroundColor [UIColor colorWithWhite:0.0 alpha:0.4]


@implementation SWLayoutResizerViewButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        self.backgroundColor = BackgroundColor;
        self.userInteractionEnabled = YES;
        [self setContentMode:UIViewContentModeCenter];
        self.tintColor = [UIColor whiteColor];
        
        CALayer *layer = self.layer;
        [layer setCornerRadius:8];
        [layer setBorderWidth:1.0];
        [layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"RESIZER VIEW BEGAN!");

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    self.backgroundColor = SelectedBackgroundColor;
    [_delegate resizerViewButton:self touchBeganAtPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"RESIZER VIEW MOVED!");
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    [_delegate resizerViewButton:self touchMovedToPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"RESIZER VIEW ENDED");
    
    self.backgroundColor = BackgroundColor;
    [_delegate resizerViewButtonTouchEnded:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"RESIZER VIEW CANCELLED");
    
    self.backgroundColor = BackgroundColor;
    [_delegate resizerViewButtonTouchCancelled:self];
}


@end


#pragma mark SWLayoutResizerView

@interface SWLayoutResizerView()<SWLayoutResizerViewButtonDelegate>
{
    SWLayoutResizerViewButton *_top;
    SWLayoutResizerViewButton *_left;
    SWLayoutResizerViewButton *_bottom;
    SWLayoutResizerViewButton *_right;
    SWLayoutResizerViewButton *_center;
    SWLayoutResizerViewButton *_shift;
    BOOL _isPresented;
    BOOL _isTouchingShift;
    CGPoint _firstTouchPosition;
    CGRect _firstTouchFrame;
}
@end

@implementation SWLayoutResizerView

#define Side 50
//#define Size 192
#define Size 200
#define Edge 10


- (id)init
{
    self = [super initWithFrame:CGRectMake(0,0,Size,Size)];
    if (self)
    {
    }
    return self;
}


#pragma mark point inside override

// considerem que el punt es dins si el punt es estrictament dins de un dels seus subviews
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for ( UIView *sub in [self.subviews reverseObjectEnumerator] )
    {
        CGPoint pt = [self convertPoint:point toView:sub];
        BOOL isInside = [sub pointInside:pt withEvent:event];
        if ( isInside )
            return isInside;
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark public methods

//- (void)setEditMode:(BOOL)editing
//{
//    _editMode = editing;
//    self.userInteractionEnabled = editing;
//}


//- (void)presentResizerV
//{
//    if ( _isPresented )
//        return;
//    
//    _isPresented = YES;
//    
//    CGSize size = self.bounds.size;
//    CGPoint center = CGPointMake(size.width/2, size.height/2);
//    
//    _top = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(center.x-Side/2, 0, Side, Side)];
//    _left = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(0, center.y-Side/2, Side, Side)];
//    _bottom = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(center.x-Side/2, size.height-Side, Side, Side)];
//    _right = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(size.width-Side, center.y-Side/2, Side, Side)];
//    _center = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(center.x-Side/2, center.y-Side/2, Side, Side)];
//    
//    [_top setImage:[[UIImage imageNamed:@"up4-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    [_left setImage:[[UIImage imageNamed:@"back-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    [_bottom setImage:[[UIImage imageNamed:@"down4-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    [_right setImage:[[UIImage imageNamed:@"forward-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    [_center setImage:[[UIImage imageNamed:@"1099-list-1-toolbar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    //[_center setImage:[[UIImage imageNamed:@"727-more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    
//    _top.delegate = self;
//    _left.delegate = self;
//    _bottom.delegate = self;
//    _right.delegate = self;
//    _center.delegate = self;
//    
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self addSubview:_top];
//    [self addSubview:_left];
//    [self addSubview:_bottom];
//    [self addSubview:_right];
//    [self addSubview:_center];
//    [self setAlpha:1];
//}

//- (void)dismissResizerAnimatedV:(BOOL)animated
//{
//    if ( !_isPresented )
//        return;
//    
//    _isPresented = NO;
//    _top = _left = _bottom = _right = _center = nil;
//    
//    void (^final)(BOOL) = ^(BOOL finished)
//    {
//        if ( _isPresented == NO )
//            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    };
//    
//    if ( animated ) [UIView animateWithDuration:0.3 animations:^{[self setAlpha:0];} completion:final];
//    else final(YES);
//}


- (void)presentResizer
{
    if ( _isPresented )
        return;
    
    _isPresented = YES;
    
    if ( _top == nil )
    {
        CGSize size = self.bounds.size;
        CGPoint center = CGPointMake(size.width/2, size.height/2);
    
        _top = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(center.x-Side/2, Edge, Side, Side)];
        _left = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(Edge, center.y-Side/2, Side, Side)];
        _bottom = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(center.x-Side/2, size.height-Side-Edge, Side, Side)];
        _right = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(size.width-Side-Edge, center.y-Side/2, Side, Side)];
        _center = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(center.x-Side/2, center.y-Side/2, Side, Side)];
        _shift = [[SWLayoutResizerViewButton alloc] initWithFrame:CGRectMake(0, size.height-Side, Side, Side)];
    
        [self setImagesWithShift:_isTouchingShift];
        [_center setImage:[[UIImage imageNamed:@"1099-list-1-toolbar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_shift setImage:[[UIImage imageNamed:@"727-more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        //[_center setImage:[[UIImage imageNamed:@"727-more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
        _top.delegate = self;
        _left.delegate = self;
        _bottom.delegate = self;
        _right.delegate = self;
        _center.delegate = self;
        _shift.delegate = self;
    
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self addSubview:_top];
        [self addSubview:_left];
        [self addSubview:_bottom];
        [self addSubview:_right];
        [self addSubview:_center];
        [self addSubview:_shift];
    }
    
    [self setAlpha:1];
    [self setUserInteractionEnabled:YES];
}



- (void)setImagesWithShift:(BOOL)shift
{
        [_top setImage:[[UIImage imageNamed:shift?@"plus-25.png":@"up4-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_left setImage:[[UIImage imageNamed:shift?@"minus-25.png":@"back-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_bottom setImage:[[UIImage imageNamed:shift?@"minus-25.png":@"down4-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_right setImage:[[UIImage imageNamed:shift?@"plus-25.png":@"forward-25.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)dismissResizerAnimated:(BOOL)animated
{
    if ( !_isPresented )
        return;
    
    _isPresented = NO;
    
    void (^action)(void) = ^()
    {
        if ( _isPresented == NO )
        {
            [self setAlpha:0];
            [self setUserInteractionEnabled:NO];
        }
    };
    
    
    if ( animated ) [UIView animateWithDuration:0.3 animations:action completion:nil];
    else action();
}


#pragma mark SWLayoutResizerViewButtonDelegate

- (void)resizerViewButton:(SWLayoutResizerViewButton*)resizerButton touchBeganAtPoint:(CGPoint)point
{
    if ( resizerButton == _center )
    {
        _firstTouchFrame = self.frame;
        CGPoint aPoint = [self convertPoint:point toView:self.superview];
        _firstTouchPosition = aPoint;
    }
    else if ( resizerButton == _shift )
    {
        _isTouchingShift = YES;
        [self setImagesWithShift:_isTouchingShift];
    }
    else
    {
        SWLayoutResizerViewDirection direction;
        if ( resizerButton == _top ) direction = SWLayoutResizerViewDirectionUp;
        else if ( resizerButton == _left ) direction = SWLayoutResizerViewDirectionLeft;
        else if ( resizerButton == _bottom ) direction = SWLayoutResizerViewDirectionDown;
        else if ( resizerButton == _right ) direction = SWLayoutResizerViewDirectionRight;
    
        if ( _isTouchingShift )
        {
            if ( [_delegate respondsToSelector:@selector(resizerView:moveToDirection:)] )
                [_delegate resizerView:self resizeToDirection:direction];
        }
        else
        {
            if ( [_delegate respondsToSelector:@selector(resizerView:moveToDirection:)] )
                [_delegate resizerView:self moveToDirection:direction];
        }
    }
}


- (void)resizerViewButton:(SWLayoutResizerViewButton*)resizerButton touchMovedToPoint:(CGPoint)point
{
    if ( resizerButton == _center )
    {
        CGRect frame = self.frame;
        CGPoint aPoint = [self convertPoint:point toView:self.superview];
        frame.origin.x = _firstTouchFrame.origin.x + aPoint.x - _firstTouchPosition.x,
        frame.origin.y = _firstTouchFrame.origin.y + aPoint.y - _firstTouchPosition.y;
        self.frame = frame;
        
        if ( [_delegate respondsToSelector:@selector(resizerView:didChangedPosition:)] )
            [_delegate resizerView:self didChangedPosition:self.center];
    }
}

- (void)resizerViewButtonTouchEnded:(SWLayoutResizerViewButton*)resizerButton
{
    if ( resizerButton == _shift )
    {
        _isTouchingShift = NO;
        [self setImagesWithShift:_isTouchingShift];
    }
}

- (void)resizerViewButtonTouchCancelled:(SWLayoutResizerViewButton*)resizerButton
{
    if ( resizerButton == _center )
    {
        _isTouchingShift = NO;
        [self setImagesWithShift:_isTouchingShift];
    }
}

@end
