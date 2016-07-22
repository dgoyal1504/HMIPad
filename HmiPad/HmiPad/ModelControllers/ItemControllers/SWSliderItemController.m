//
//  SWSliderItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSliderItemController.h"
#import "SWSliderItem.h"
#import "SWColor.h"
#import "SWEnumTypes.h"



@interface SWSliderItemController ()

//- (SWSliderItem*)_sliderItem;

//- (void)_updateProgressAnimated:(BOOL)animated;
//- (void)_updateColor;
//- (void)_updateViewAnimated:(BOOL)animated;

@property (nonatomic,readonly) SWSliderItem *item;

@end

@implementation SWSliderItemController
@synthesize sliderBar = _sliderBar;
@synthesize progressBar = _progressBar;


- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        
//    if (((SWSliderItem*)self.item).enabled) {
//        self.sliderBar.frame = self.view.bounds;
//        [self.view addSubview:self.sliderBar];
//    } else {
//        self.progressBar.frame = self.view.bounds;
//        self.progressBar.center = CGPointMake(roundf(self.view.frame.size.width/2.0), roundf(self.view.frame.size.height/2.0));
//        [self.view addSubview:self.progressBar];
//    }

}

- (void)viewDidUnload
{
    _sliderBar = nil;
    _progressBar = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateEnabledState];
    [self _updateOrientation];
    [self _updateProgressAnimated:NO];
    [self _updateColor];
}


//- (void)refreshZoomScaleFactor:(CGFloat)contentScale
//{
//    // per el switchView no funciona el escalat recursiu dels subviews (Bug de Apple).
//    if ( _sliderBar )
//    {
//        [_sliderBar setContentScaleFactor:contentScale];
//        // No cridem el super
//    }
//    else
//    {
//        [super refreshZoomScaleFactor:contentScale];
//    }
//}


#pragma mark - Main Methods

- (void)sliderValueChanged:(id)sender
{
    SWSliderItem *item = self.item; //[self _sliderItem];
    double value = [self _getEngSliderValue];

    [item.continuousValue evalWithDouble:value];
}

- (void)_checkPointForValue:(double)value
{
    SWSliderItem *item = self.item;
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL verified, BOOL success)
    {
        if ( success )
        {
            [item.value evalWithConstantValue:value];
        }
        else
        {
            [item.continuousValue evalWithValue:item.value];   // tornem al valor original
            [theSelf _updateProgressAnimated:YES];    // updatem el view
        }
    }];
}

- (void)sliderValueEnded:(id)sender
{
    double value = [self _getEngSliderValue];
    [self _checkPointForValue:value];
}








#pragma mark - Private Methods

//- (SWSliderItem*)_sliderItem
//{
//    if ([self.item isKindOfClass:[SWSliderItem class]]) {
//        return (SWSliderItem*)self.item;
//    }
//    return nil;
//}



- (double)_getEngSliderValue
{
    SWSliderItem *item = self.item; //[self _sliderItem];
    
    float progress = [_sliderBar value];
    double min = item.minValue.valueAsDouble;
    double max = item.maxValue.valueAsDouble;

    double value = min + progress*(max-min);
    return value;
}


- (float)_getRawProgressValue
{
    SWSliderItem *item = self.item; //[self _sliderItem];
    
    double min = item.minValue.valueAsDouble;
    double max = item.maxValue.valueAsDouble;
    double v = item.value.valueAsDouble;
    
    float progress = (float)((v-min)/(max-min));
    if ( progress != progress )     // <-- nan (resultant de 0/0)
        progress = 0.5f;

    return progress;
}


- (void)_updateProgressAnimated:(BOOL)animated
{    
    float progress = [self _getRawProgressValue];

    if ( _sliderBar )
        [_sliderBar setValue:progress animated:animated];
    
    if ( _progressBar )
        [_progressBar setProgress:progress animated:animated];
}

- (void)_updateColor
{
    SWSliderItem *item = self.item; //[self _sliderItem];
    UIColor *color = [item.color valueAsColor];
    
    if ( _sliderBar )
        _sliderBar.minimumTrackTintColor = color;
    
    if ( _progressBar)
        _progressBar.progressTintColor = color;
}



//- (void)_updateEditableState
//{
//    SWSliderItem *item = self.item; //[self _sliderItem];
//    BOOL editable = item.enabled.valueAsBool;
//    BOOL update = NO;
//    
//    UIView *view = self.view;
//    CGRect bounds = view.bounds;
//    CGPoint center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
//    
//    BOOL vertical = YES;
//    
//    if (editable)
//    {
//        [_progressBar removeFromSuperview];
//        _progressBar = nil;
//        if ( _sliderBar == nil)
//        {
//            //_sliderBar = [[UISlider alloc] initWithFrame:rotatedBounds];
//            
//            _sliderBar = [[UISlider alloc] init];
//            [_sliderBar setCenter:center];
//            [_sliderBar setBounds:bounds];
//            
//            [_sliderBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//            [_sliderBar addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//            [_sliderBar addTarget:self action:@selector(sliderValueEnded:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside   |UIControlEventTouchUpOutside];
//            [_sliderBar setContinuous:YES];
//            
//            if ( vertical )
//            {
//                CGRect rotatedBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
//                [_sliderBar setBounds:rotatedBounds];
//                CGAffineTransform transform = CGAffineTransformMakeRotation(-90 * M_PI / 180);
//                _sliderBar.transform = transform;
//            }
//            
//            [view addSubview:_sliderBar];
//            update = YES;
//        }
//    }
//    else
//    {
//        [_sliderBar removeFromSuperview];
//        _sliderBar = nil;
//        if ( _progressBar == nil )
//        {
//            _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//            [_progressBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//            
//            
//            [_progressBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|/*UIViewAutoresizingFlexibleHeight|*/UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
//            [_progressBar setCenter:center];
//            [_progressBar setBounds:bounds];
//            [_progressBar setBackgroundColor:[UIColor yellowColor]];
//            
//            if ( vertical )
//            {
//                CGRect rotatedBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
//                [_progressBar setBounds:rotatedBounds];
//                CGAffineTransform transform = CGAffineTransformMakeRotation(-90 * M_PI / 180);
//                _progressBar.transform = transform;
//            }
//            
////            _progressBar.frame = bounds;
////            _progressBar.center = CGPointMake(bounds.size.width/2.0f,bounds.size.height/2.0f);
//            [view addSubview:_progressBar];
//            update = YES;
//        }
//    }
//    
//    if ( update )
//        [self _updateProgressAnimated:NO];
//}
//



- (void)_updateOrientation
{
    SWSliderItem *item = self.item; //[self _sliderItem];
    SWOrientation2 orientation = [item.orientation valueAsInteger];
    
    UIView *view = self.view;
    CGRect bounds = view.bounds;
    CGAffineTransform transform;
    
    if ( orientation == SWOrientationVertical )
    {
        bounds = view.bounds;
        bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        transform = CGAffineTransformMakeRotation(-90 * M_PI / 180);
    }
    else
    {
        bounds = view.bounds;
        transform = CGAffineTransformIdentity;
    }
    
    [_sliderBar setTransform:transform];
    [_sliderBar setBounds:bounds];
}




- (void)_updateEnabledState
{
    SWSliderItem *item = self.item; //[self _sliderItem];
    BOOL enabled = item.enabled.valueAsBool;
    BOOL update = NO;
    
    UIView *view = self.view;
    CGRect bounds = view.bounds;
    CGPoint center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    
    [_progressBar removeFromSuperview];
    _progressBar = nil;
    if ( _sliderBar == nil)
    {
        _sliderBar = [[UISlider alloc] init];
        [_sliderBar setCenter:center];
        //[_sliderBar setBounds:bounds];
            
        [_sliderBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_sliderBar addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_sliderBar addTarget:self action:@selector(sliderValueEnded:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside   |UIControlEventTouchUpOutside];
        [_sliderBar setContinuous:YES];
            
        [view addSubview:_sliderBar];
        update = YES;
    }
    [_sliderBar setEnabled:enabled];
    
    if ( update )
        [self _updateProgressAnimated:NO];
}


#pragma mark - SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    //[super value:value didEvaluateWithChange:changed];
    
    SWSliderItem *item = self.item; //[self _sliderItem];
    
    if (value == item.value ||
        value == item.minValue ||
        value == item.maxValue)
    {
        [self _updateProgressAnimated:YES];
    }
    
    else if (value == item.color)
    {
        [self _updateColor];
    }
    
    else if (value == item.enabled)
    {
        [self _updateEnabledState];
    }
    
    else if ( value == item.orientation)
    {
        [self _updateOrientation];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
