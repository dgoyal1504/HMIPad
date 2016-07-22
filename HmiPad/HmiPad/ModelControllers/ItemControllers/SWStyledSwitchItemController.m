//
//  SWStyledSwitchItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWStyledSwitchItemController.h"
#import "RoundedLabel.h"
#import "ColoredButton.h"
#import "SWStyledSwitchItem.h"
#import "SWEnumTypes.h"

#import "SWColor.h"


@implementation SWStyledSwitchItemController
{
}

@synthesize switchView = _switchView;
@synthesize labelView = _labelView;
@synthesize buttonView = _buttonView;


- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _switchView = nil;
    _labelView = nil;
    [super viewDidUnload];
}

#pragma mark Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateActiveStateAndStyle];
    [self _updateView];
    
    // SHOULD CALL [self _updateSwitchStyle];
}


//- (void)refreshZoomScaleFactor:(CGFloat)contentScale
//{
//    // per el switchView no funciona el escalat recursiu dels subviews (Bug de Apple)
//    if ( _switchView )
//    {
//        [_switchView setContentScaleFactor:contentScale];
//        // no cridem el super
//    }
//    else
//    {
//        [super refreshZoomScaleFactor:contentScale];
//    }
//}


#pragma mark Actions


- (void)_checkPointForValue:(double)value
{
    SWStyledSwitchItem *item = [self _switchItem];
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
            [theSelf _updateValueAnimated:YES];    // updatem el view
        }
    }];
}


- (void)switchValueChanged:(id)sender
{
    BOOL state = _switchView.on;
    double value = state?1.0:0.0;
    SWStyledSwitchItem *item = [self _switchItem];
    
    [item.continuousValue evalWithDouble:value];
    [self _checkPointForValue:value];
}


//- (void)buttonTouchDown:(id)sender
//{
////    SWStyledSwitchItem *item = [self _switchItem];
////    double value = item.value.valueAsBool?0.0:1.0;
////    
////    [item.continuousValue evalWithDouble:value];
//}

- (void)buttonTouchUpInside:(id)sender
{
    SWStyledSwitchItem *item = [self _switchItem];
    
    BOOL bvalue = !(item.value.valueAsBool);
    double value = bvalue?1.0:0.0;
    
    [item.continuousValue evalWithDouble:value];   // posem el valor temporal
    [self _setViewValue:bvalue animated:NO];   // updatem el view amb el valor temporal
    
    [self _checkPointForValue:value];  // check validation
}


- (void)buttonTouchUpOutside:(id)sender
{
    SWStyledSwitchItem *item = [self _switchItem];
    
    [item.continuousValue evalWithValue:item.value];   // tornem al valor original
    [self _updateValueAnimated:YES];    // updatem el view
}

#pragma mark Private Methods

- (SWStyledSwitchItem*)_switchItem
{
    return (SWStyledSwitchItem*)self.item;
}

- (void)_updateView
{
    [self _updateEnabledState];
    [self _updateValueAnimated:NO];
    [self _updateColor];
}


- (void)_setViewValue:(BOOL)bvalue animated:(BOOL)animated
{
    if ( _switchView )
    {
        [_switchView setOn:bvalue animated:animated];
        return;
    }
    
    NSString *text = bvalue?@"ON":@"OFF";
    
    if ( _labelView )
    {
        [self _updateColor];
        _labelView.text = text;
        return;
    }
    
    if ( _buttonView )
    {
        [_buttonView setTitle:text forState:UIControlStateNormal];
        UIButton *btn = _buttonView;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [btn setHighlighted:bvalue];
        });
    }
}



- (void)_updateValueAnimated:(BOOL)animated
{
    SWStyledSwitchItem *item = [self _switchItem];
    BOOL bvalue = item.value.valueAsBool;
    [self _setViewValue:bvalue animated:animated];
}


- (void)_updateColor
{
    SWStyledSwitchItem *item = [self _switchItem];
    UInt32 rgbColor = item.color.valueAsRGBColor; 
    
    if ( _switchView )
    {
        UIColor *color = UIColorWithRgb(rgbColor);
        [_switchView setOnTintColor:color];
    }
    
    if ( _labelView )
    {
        BOOL value = item.value.valueAsBool;
        if ( ! value ) rgbColor = SystemClearWhiteColor;
        [_labelView setRgbTintColor:rgbColor];
    }
    
    if ( _buttonView )
    {
        [_buttonView setRgbTintColor:rgbColor overWhite:NO];
    }
}


- (void)_updateEnabledState
{
    SWStyledSwitchItem *item = [self _switchItem];
    BOOL enabled = item.enabled.valueAsBool;
    
    if ( _switchView )
    {
        [_switchView setEnabled:enabled];
    }
    
    if ( _labelView )
    {
        [_labelView setEnabled:enabled];
    }
    
    if ( _buttonView )
    {
        [_buttonView setEnabled:enabled];
    }
}


- (void)_updateActiveStateAndStyle
{
    SWStyledSwitchItem *item = [self _switchItem];
    SWSwitchStyle style = item.switchStyle.valueAsInteger;
    BOOL active = item.active.valueAsBool;
    BOOL update = NO;
    
    UIView *view = self.view;
    CGRect bounds = view.bounds;
    
    if (active && style==SWSwitchStyleApple)
    {
        [_labelView removeFromSuperview];
        [_buttonView removeFromSuperview];
        _labelView = nil;
        _buttonView = nil;
        if ( _switchView == nil ) 
        {
            _switchView = [[UISwitch alloc] init];
            [_switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [_switchView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
            CGRect frame = _switchView.frame;
            frame.origin.x = roundf((bounds.size.width-frame.size.width)/2);
            frame.origin.y = roundf((bounds.size.height-frame.size.height)/2);
            _switchView.frame = frame;
            
            [view addSubview:_switchView];
            update = YES;
        }
    }
    
    else if ( active && style==SWSwitchStyleButton)
    {
        [_labelView removeFromSuperview];
        [_switchView removeFromSuperview];
        _labelView = nil;
        _switchView = nil;
        if ( _buttonView == nil )
        {
            _buttonView = [[ColoredButton alloc] init];
            
            [_buttonView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
            [_buttonView.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            //[_buttonView setAutoresizingMask:(UIViewAutoresizingNone)];
            //[_buttonView addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
            
            [_buttonView addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonView addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside];
            //[_buttonView addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
            _buttonView.frame = bounds;
            [view addSubview:_buttonView];
            update = YES;
        }

    }
    
    else 
    {
        [_buttonView removeFromSuperview];
        [_switchView removeFromSuperview];
        _buttonView = nil;
        _switchView = nil;
        if ( _labelView == nil ) 
        {
            _labelView = [[RoundedLabel alloc] init];
            [_labelView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [_labelView setFont:[UIFont boldSystemFontOfSize:15]];
            [_labelView setTextAlignment:NSTextAlignmentCenter];
            [_labelView setBackgroundColor:[UIColor clearColor]];
            _labelView.frame = bounds;
            [view addSubview:_labelView];
            update = YES;
        }
    }
    
    if ( update )
        [self _updateValueAnimated:NO];
}


//- (void)_updateSwitchStyle
//{
//    SWStyledSwitchItem *item = [self _switchItem];
//    SWSwitchStyle style = item.switchStyle.valueAsInteger;
//    
//    switch (style)
//    {
//        case SWSwitchStyleApple:
//            [self _updateEditableStateAndStyle];
//            break;
//        case SWSwitchStyleButton:
//            
//            break;
//        default:
//            break;
//    }
//}







#pragma mark Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWStyledSwitchItem *item = [self _switchItem];
    
    if (value == item.value) 
    {
        [self _updateValueAnimated:YES];
    }
    else if (value == item.color)
    {
        [self _updateColor];
    }
    else if (value == item.active)
    {
        [self _updateActiveStateAndStyle];
        [self _updateView];
    }
    else if (value == item.switchStyle) 
    {
        [self _updateActiveStateAndStyle];
        [self _updateView];
    }
    
    else if (value == item.enabled)
    {
        [self _updateEnabledState];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
