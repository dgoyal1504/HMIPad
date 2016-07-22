//
//  SWLayer.m
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLayer.h"


@implementation SWLayer

@synthesize view = _v ;
@synthesize animated = _isAnimated ;


- (void)_doSWLayerInit
{
    _isAligned = YES ;
    _isAnimated = NO ;
    CGFloat scale = [UIScreen mainScreen].scale ;
    self.contentsScale = scale;
    //self.contentsGravity = kCAGravityResize    ;
    [self setNeedsDisplayOnBoundsChange:YES] ;
}


- (id)init
{
    self = [super init] ;
    if ( self )
    {
        [self _doSWLayerInit] ;
    }
    return self ;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder] ;
    if ( self )
    {
        [self _doSWLayerInit] ;
    }
    return self ;
}


- (id)initWithLayer:(SWLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        _isAligned = NO ;
        _isAnimated = layer.animated ;
        _v = layer.view ;
    }
    return self ;
}

- (void)setAnimated:(BOOL)animated
{
    if ( animated == NO ) [self removeAllAnimations] ;
    _isAnimated = animated ;
}


+ (BOOL)needsDisplayForKey:(NSString *)key 
{
//    if ( [key isEqualToString:@"bounds"] )
//    {
//        return YES;
//    }
    
    return [super needsDisplayForKey:key];
}



-(id<CAAction>)actionForKey:(NSString *)key 
{
    CALayer *superlayer = [self superlayer] ;
    if ( [superlayer isKindOfClass:[SWLayer class]] )
    {
        //if ( [key isEqualToString:@"position"] ) return nil ;
        //if ( [key isEqualToString:@"bounds"] ) return nil ;
        //if ( [key isEqualToString:@"onLayout"] ) return nil ;
        //if ( [key isEqualToString:@"contents"] ) return nil ;
        
        CABasicAnimation *theAnimation = nil ;
        CAAnimation *animation = [superlayer animationForKey:key] ;
        if ( animation )
        {
            theAnimation = [CABasicAnimation animationWithKeyPath:key] ;
            theAnimation.fromValue = [[self presentationLayer] valueForKey:key] ;
            theAnimation.timingFunction = animation.timingFunction ;
            theAnimation.duration = animation.duration ;
            //theAnimation.duration = 20.0;
        }
        return theAnimation;
    }
    return [super actionForKey:key] ;
}


- (void)setContentsScale:(CGFloat)contentsScale
{
    [super setContentsScale:contentsScale];
    //if ( self.contents == nil )
        [self setNeedsDisplay];
    
    for ( CALayer *layer in self.sublayers )
        [layer setContentsScale:contentsScale];
}

@end