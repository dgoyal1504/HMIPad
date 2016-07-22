//
//  TKAlertCenter.m
//  Created by Devin Ross on 9/29/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "SWDropCenter.h"

    #import <QuartzCore/QuartzCore.h>


@interface SWDropCenter() 
{
    UIWindow *_window ;
    BOOL animating ;
}
@end


@implementation SWDropCenter

+ (SWDropCenter*) defaultCenter
{
    static SWDropCenter *defaultCenter = nil;
	if ( defaultCenter == nil ) defaultCenter = [[self alloc] init];
	return defaultCenter;
}

- (id)init
{
    self = [super init] ;
	if( self )
    {
        NSArray *windows = [[UIApplication sharedApplication] windows] ;
        if ( [windows count] > 0 ) _window = [windows objectAtIndex:0] ;
        else self = nil ;   // ARC
    }
	return self;
}


//- (void)dropView:(UIView*)theView fromPoint:(CGPoint)bPoint toPoint:(CGPoint)ePoint
- (void)dropImage:(UIImage*)image fromView:(UIView*)bView point:(CGPoint)bbPoint toView:(UIView*)eView point:(CGPoint)eePoint
{
    // si esta animant tornem
    if ( animating ) return ;
    animating = YES ;

    // determinem el punt inicial i final de la animacio
    if ( bView == nil || eView == nil ) return  ;
    CGPoint bPoint = [_window convertPoint:bbPoint fromView:bView] ;
    CGPoint ePoint = [_window convertPoint:eePoint fromView:eView] ;

    // determinem la transformacio inicial i final de la animacio
    CGFloat degrees ;
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation ; 
    if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90 ;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90 ;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180 ;
    else degrees = 0 ;
    CATransform3D oTransform = CATransform3DRotate( CATransform3DIdentity, degrees*M_PI/180, 0.0f, 0.0f, 1.0f ) ;
    CATransform3D bTransform = CATransform3DScale( oTransform, 1.5f, 1.5f, 1.0f) ;
    CATransform3D eTrandform = CATransform3DScale( oTransform, 0.2f, 0.2f, 1.0f) ;
    
    // determinem el path pel moviment
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    CGPoint ctlPoint = CGPointMake( (ePoint.x+3*bPoint.x)/4, (3*ePoint.y+bPoint.y)/4 );
    [movePath moveToPoint:bPoint];
    [movePath addQuadCurveToPoint:ePoint controlPoint:ctlPoint];
    
    // determinem la duracio de la animacio
    CGFloat dx = ePoint.x - bPoint.x;
    CGFloat dy = ePoint.y - bPoint.y;
    CGFloat distance = sqrtf(dx*dx + dy*dy );
    CGFloat duration = distance/500 ;   // 500 punts per segon
    
    // animacio per l'escalat
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:bTransform];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:eTrandform];
    scaleAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn] ;
    scaleAnim.duration = duration;
    //scaleAnim.fillMode = kCAFillModeForwards ;

    // animacio per la opacitat
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.5];
    opacityAnim.duration = duration;
    //opacityAnim.fillMode = kCAFillModeForwards ;

    // animacio pel moviment
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ;
    moveAnim.duration = duration;
    //moveAnim.fillMode = kCAFillModeForwards ;
    
    // grup amb les tres animacions
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:moveAnim, scaleAnim, opacityAnim, nil];
    animGroup.duration = duration;
    animGroup.fillMode = kCAFillModeForwards ;
    animGroup.removedOnCompletion = NO ;

    // posem el layer del view en el main window
    UIView *theImageView = [[UIImageView alloc] initWithImage:image] ;
    CALayer *theLayer = [theImageView layer] ;
    [_window.layer addSublayer:theLayer] ;
    
    // iniciem l'animacio
    animGroup.delegate = self ;
    [animGroup setValue:theLayer forKey:@"AnimationLayer"] ;
    [theLayer addAnimation:animGroup forKey:nil];
}


- (void)dropImage:(UIImage*)image fromView:(UIView*)bView toView:(UIView*)eView
{
    if ( bView == nil || eView == nil ) return  ;
    CGPoint bbPoint = [bView center] ;
    CGPoint eePoint = [eView center] ;
    [self dropImage:image fromView:bView point:bbPoint toView:eView point:eePoint] ;
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	CALayer *theLayer = [theAnimation valueForKey:@"AnimationLayer"] ;
    [theLayer removeAllAnimations] ;
	[theLayer removeFromSuperlayer] ;
    animating = NO ;
}


- (void)dealloc
{
}

@end

