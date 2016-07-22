//
//  IncidentView.m
//  ScadaMobile_090721
//
//  Created by Joan on 28/07/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "IncidentView.h"
#import "SWColor.h"


/*
@implementation UIView (TKEmptyViewCategory)

+ (void) drawGradientInRect:(CGRect)rect withColors:(NSArray*)colors{
	
	NSMutableArray *ar = [NSMutableArray array];
	for(UIColor *c in colors) [ar addObject:(id)c.CGColor];
	
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	
	CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)ar, NULL);
	
	
	CGContextClipToRect(context, rect);
	
	CGPoint start = CGPointMake(0.0, 0.0);
	CGPoint end = CGPointMake(0.0, rect.size.height);
	
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);
	
}

@end
*/
/*
@implementation UIImage (TKEmptyViewCategory)

- (void) drawMaskedGradientInRect:(CGRect)rect withColors:(NSArray*)colors{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, self.CGImage);
	
	[UIView drawGradientInRect:rect withColors:colors];
	
	CGContextRestoreGState(context);
}

@end
*/


@implementation IncidentView

@synthesize mainLabel, secondaryLabel ;


/*
//-------------------------------------------------------------------------------
- (UIImage *)maskedImageWithImage:(UIImage*)m
{	
	if(m==nil) return nil;

	UIGraphicsBeginImageContext(CGSizeMake((m.size.width)*m.scale , (m.size.height+2)*m.scale));
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	NSArray *colors = [NSArray arrayWithObjects:
				   [UIColor colorWithRed:174/255.0 green:182/255.0 blue:195/255.0 alpha:1],
				   [UIColor colorWithRed:197/255.0 green:202/255.0 blue:211/255.0 alpha:1],nil];
    
    //    Jlz per proves           
	//NSArray *colors = [NSArray arrayWithObjects:
	//			   [UIColor redColor],
	//			   [UIColor greenColor],nil];
	

	CGContextSetShadowWithColor(context, CGSizeMake(1, 4),4, [UIColor colorWithWhite:0 alpha:0.1].CGColor);
	[m drawInRect:CGRectMake(0, 0+(1*m.scale),m.size.width*m.scale, m.size.height*m.scale)];
	[m drawMaskedGradientInRect:CGRectMake(0, 0, m.size.width*m.scale, m.size.height*m.scale) withColors:colors];
	
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:m.scale orientation:UIImageOrientationUp];
	
	return scaledImage;
}
*/


//-------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame 
{
    if ( (self = [super initWithFrame:frame] ) ) 
    {
        //CGRect bounds = [self bounds] ;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
        CGFloat grayS = 0.95f ;
        [self setBackgroundColor:[UIColor colorWithRed:grayS green:grayS blue:grayS alpha:1.0f]];
        //[self setBackgroundColor:[UIColor whiteColor]];
        [self setOpaque:YES] ;
        
        // mascara de autoresize per tots els subviews
        //UIViewAutoresizing autoresizing = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|
        //                                UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
                                        
        //UIViewAutoresizing autoresizing2 = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|
        //                                UIViewAutoresizingFlexibleWidth ; 
        
        // imatge
        UIImage *image = [UIImage imageNamed:@"bubbleSplash.png"] ;
        
        //UIImage *image = [UIImage imageNamed:@"chatbubble.png"] ;
        //image = [self maskedImageWithImage:image] ;
        
        imageView = [[UIImageView alloc] initWithImage:image];
        
        //CGRect iVBounds = [imageView bounds] ;
        //CGRect iVFrame = CGRectMake( roundf((bounds.size.width-iVBounds.size.width)/2.0f), 
        //                                roundf((bounds.size.height-iVBounds.size.height)*0.2f), 
        //                                iVBounds.size.width, iVBounds.size.height) ;
        //[imageView setFrame:iVFrame];
        //[imageView setAutoresizingMask:autoresizing] ;
        [self addSubview:imageView] ;
       

        
        
        // label principal
        //float mainLWidth = bounds.size.width - 40.0f ;    // 140
        //float mainLHeight = 62.0f ;
        UIColor *theColor = UIColorWithRgb(SystemDarkerBlueColor) ;
        
        mainLabel = [[UILabel alloc] init] ;
        //WithFrame:CGRectMake( roundf((bounds.size.width-mainLWidth)/2.0f), 
        //                                roundf((bounds.size.height-mainLHeight)*0.75f),   //0.6
        //                                mainLWidth, mainLHeight)];
        //[mainLabel setAutoresizingMask:autoresizing2] ;
                                        
        //mainLabel = [[UILabel alloc] initWithFrame:iVFrame];
        //[mainLabel setAutoresizingMask:autoresizing] ;
        
        [mainLabel setNumberOfLines:0] ;
        //[mainLabel setTextColor:[IncidentView theDarkerSystemDarkBlueColor]] ;
        [mainLabel setTextColor:theColor] ;
        [mainLabel setBackgroundColor:[UIColor clearColor]] ;
        [mainLabel setTextAlignment:NSTextAlignmentCenter] ;
        [mainLabel setFont:[UIFont boldSystemFontOfSize:17]] ;
        [self addSubview:mainLabel] ;
        
        
        // label secundari
        //float secLWidth = bounds.size.width - 40.0f ;
        //float secLHeight = 100.0f ;
        secondaryLabel = [[UILabel alloc] init] ;
        //WithFrame:CGRectMake( roundf((bounds.size.width-secLWidth)/2.0f), 
        //                                roundf((bounds.size.height-secLHeight)*1.0f), // 0.9
        //                                secLWidth, secLHeight)];
        //[secondaryLabel setAutoresizingMask:autoresizing2] ;
        [secondaryLabel setNumberOfLines:0] ;
        //[secondaryLabel setTextColor:[IncidentView theDarkerSystemDarkBlueColor]] ;
        [secondaryLabel setTextColor:theColor] ;
        [secondaryLabel setBackgroundColor:[UIColor clearColor]] ;
        [secondaryLabel setTextAlignment:NSTextAlignmentCenter] ;
        [secondaryLabel setFont:[UIFont systemFontOfSize:13]] ;
        [self addSubview:secondaryLabel] ;
        
        // Initialization code
    }
    return self;
}


//-------------------------------------------------------------------------------
- (void)layoutSubviews
{
    CGRect bounds = [self bounds] ;
    CGRect iVBounds = [imageView bounds] ;

    CGRect iVFrame = CGRectMake( roundf((bounds.size.width-iVBounds.size.width)/2.0f), 
                                        roundf((bounds.size.height-iVBounds.size.height)*0.3f), 
                                        iVBounds.size.width, iVBounds.size.height) ;

    CGFloat mainLWidth = bounds.size.width - 40.0f ;    // 140
    CGFloat mainLHeight = 48.0f ;
    CGRect mLFrame = CGRectMake( roundf((bounds.size.width-mainLWidth)/2.0f), 
                                        iVFrame.origin.y+iVFrame.size.height+0,   //0.6
                                        mainLWidth, mainLHeight) ;
    
    CGFloat secLWidth = bounds.size.width - 40.0f ;
    CGFloat secLHeight = 48.0f ;
    CGRect sLFrame = CGRectMake( roundf((bounds.size.width-secLWidth)/2.0f), 
                                        mLFrame.origin.y+mLFrame.size.height+0, // 0.9
                                        secLWidth, secLHeight) ;
    [imageView setFrame:iVFrame] ;
    [mainLabel setFrame:mLFrame] ;
    [secondaryLabel setFrame:sLFrame] ;
}




/*
- (void)drawRect:(CGRect)rect 
{
    // Drawing code
}
*/



@end
