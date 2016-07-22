//
//  SWButtonItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 03/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWButtonItemController.h"
#import "RoundedLabel.h"
#import "ColoredButton.h"
#import "SWButtonItem.h"
#import "SWEnumTypes.h"

#import "SWColor.h"


@implementation SWButtonItemController
{
    BOOL _pendingNormalUp;
}

@synthesize buttonView = _buttonView;
//@synthesize labelView = _labelView;

- (void)loadView
{
//    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    _buttonView = [[ColoredButton alloc] initWithFrame:CGRectMake(0,0,100,100)];
    //[_buttonView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_buttonView addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_buttonView addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addTarget:self action:@selector(buttonTouchUpOther:) forControlEvents:UIControlEventTouchUpOutside];
    [_buttonView addTarget:self action:@selector(buttonTouchUpOther:) forControlEvents:UIControlEventTouchCancel];
    self.view = _buttonView;
}

- (void)viewDidUnload
{
    _buttonView = nil;
    //_labelView = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateEditableState];
    [self _updateView];
}

#pragma mark - Main Methods


- (void)_delayedNormalEnd:(id)dummy
{
    SWButtonItem *item = [self _buttonItem];
    [item.value evalWithConstantValue:0.0];
}


- (void)_checkPointForValue:(double)value
{
    SWButtonItem *item = [self _buttonItem];
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL success)
    {
        if ( success )
        {
            [item.value evalWithConstantValue:value];
            if ( _pendingNormalUp )  // si el block torna inmediatament es perque no es requereix verificacio, i el if no s'executara
                                     // si el block torna despres de confirmacio executarem la part final ara
            {
                [self performSelector:@selector(_delayedNormalEnd:) withObject:nil afterDelay:0.0];
            }
        }
        else
        {
            [item.continuousValue evalWithValue:item.value];   // tornem al valor original
            [theSelf _updateValue];    // updatem el view
            
        }
        _pendingNormalUp = NO;
    }];
}




- (void)buttonTouchDown:(id)sender
{
    SWButtonItem *item = [self _buttonItem];
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    if ( style == SWButtonStyleNormal )
    {
        [item.continuousValue evalWithDouble:1.0];   // posem el valor temporal
        [self _setViewValue:YES];   // updatem el view amb el valor temporal
        
        [self _checkPointForValue:1.0];
        _pendingNormalUp = YES;   // despres de cridar checkPoint
    }
}


- (void)buttonTouchUpInside:(id)sender
{
    SWButtonItem *item = [self _buttonItem];
    
    BOOL bvalue = !(item.value.valueAsBool);
    double value = bvalue?1.0:0.0;
    
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    
    if ( style == SWButtonStyleToogle )
    {
        [item.continuousValue evalWithDouble:value];   // posem el valor temporal
        [self _setViewValue:bvalue];   // updatem el view amb el valor temporal
    
        [self _checkPointForValue:value];
    }
    else // SWButtonStyleNormal
    {
        [self buttonTouchUpOther:sender];
    }
}

- (void)buttonTouchUpOther:(id)sender
{
    SWButtonItem *item = [self _buttonItem];
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    
    if ( style == SWButtonStyleToogle )
    {
        [item.continuousValue evalWithValue:item.value];   // tornem al valor original
        [self _updateValue];    // updatem el view
    }
    
    else // SWButtonStyleNormal
    {
        if ( _pendingNormalUp )   // pot arribar aqui degut a un cancel provocat per el checkpoint verification, en aquest cas _pendingNormalUp encara es false i el if no s'executa.
        {
            _pendingNormalUp = NO;
            [item.value evalWithConstantValue:0.0];
        }
    }
}

#pragma mark - Private Methods

- (SWButtonItem*)_buttonItem
{
    return (SWButtonItem*)self.item;
}

- (void)_updateView
{
    [self _updateLabel];
    [self _updateTextAlignement];
    [self _updateValue];
    [self _updateColor];
    [self _updateFont];
}


- (void)_setViewValue:(BOOL)bvalue
{
    SWButtonItem *item = [self _buttonItem];
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    if ( style == SWButtonStyleToogle )
    {
        UIButton *btn = _buttonView;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [btn setHighlighted:bvalue];
        });
    }
}


- (void)_updateValue
{
    SWButtonItem *item = [self _buttonItem];
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    BOOL value = item.value.valueAsBool;

    if ( style == SWButtonStyleToogle )
    {
        UIButton *btn = _buttonView;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [btn setHighlighted:value];
        });
    }
}


- (void)_updateTextAlignement
{
    SWButtonItem *item = [self _buttonItem];
    SWTextAlignment textAlignment = [item.textAlignment valueAsInteger];
    
    UITextAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWTextAlignmentLeft:
            aligment = NSTextAlignmentLeft;
            break;
            
        default:
        case SWTextAlignmentCenter:
            aligment = NSTextAlignmentCenter;
            break;
            
        case SWTextAlignmentRight:
            aligment = NSTextAlignmentRight;
            break;
    }
    
    //[_labelView setTextAlignment:aligment];
    [_buttonView setTextAlignment:aligment];
}


- (void)_updateLabel
{
    SWButtonItem *item = [self _buttonItem];
    NSString *text = item.title.valueAsString;
    //_labelView.text = text;
    [_buttonView setTitle:text forState:UIControlStateNormal];
}

- (void)_updateFont
{
    SWButtonItem *item = [self _buttonItem];
    
    UIFont *font = [UIFont fontWithName:[item.font valueAsString] size:[item.fontSize valueAsDouble]];
    //_labelView.font = font;
    _buttonView.font = font;
}

- (void)_updateColor
{
    SWButtonItem *item = [self _buttonItem];
    
    UInt32 rgbColor = item.color.valueAsRGBColor;

   // [_labelView setRgbTintColor:rgbColor];
    [_buttonView setRgbTintColor:rgbColor overWhite:NO];
}


//- (void)_updateEditableState
//{
//    BOOL editable = ((SWButtonItem*)self.item).enabled.valueAsBool;
//    UIView *view = self.view;
//    CGRect bounds = view.bounds;
//    
//    if (editable) 
//    {
//        [_labelView removeFromSuperview];
//        _labelView = nil;
//        if ( _buttonView == nil )
//        {
//            _buttonView = [[ColoredButton alloc] init];
//            [_buttonView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
//            [_buttonView addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
//            [_buttonView addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//            [_buttonView addTarget:self action:@selector(buttonTouchUpOther:) forControlEvents:UIControlEventTouchUpOutside];
//            [_buttonView addTarget:self action:@selector(buttonTouchUpOther:) forControlEvents:UIControlEventTouchCancel];
//            _buttonView.frame = bounds;
//            [view addSubview:_buttonView];
//        }
//    } 
//    else 
//    {
//        [_buttonView removeFromSuperview];
//        _buttonView = nil;
//        if (_labelView == nil) 
//        {
//            _labelView = [[RoundedLabel alloc] init];
//            [_labelView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//            [_labelView setFont:[UIFont boldSystemFontOfSize:15]];
//            [_labelView setTextAlignment:NSTextAlignmentCenter];
//            [_labelView setBackgroundColor:[UIColor clearColor]];
//            _labelView.frame = bounds;
//            [view addSubview:_labelView];
//        }
//    }
//}


- (void)_updateEditableState
{
    BOOL editable = ((SWButtonItem*)self.item).enabled.valueAsBool;
    [_buttonView setEnabled:editable];
}


#pragma mark - SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWButtonItem *item = [self _buttonItem];

    if (value == item.value || value == item.buttonStyle)
    {
        [self _updateValue];
    } 
    else if (value == item.color)
    {
        [self _updateColor];
    }
    
    else if (value == item.title) 
    {
        [self _updateLabel];
    }
    
    else if ( value == item.textAlignment)
    {
        [self _updateTextAlignement];
    }
    
    else if (value == item.font || value == item.fontSize) 
    {
        [self _updateFont];
    }
    else if (value == item.enabled) 
    {
        [self _updateEditableState];
        //[self _updateView];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
