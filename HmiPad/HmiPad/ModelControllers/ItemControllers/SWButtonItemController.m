//
//  SWButtonItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 03/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWButtonItemController.h"

//#import "SWImageManager.h"
#import "AppModel.h"
#import "AppModelImage.h"

#import "RoundedLabel.h"
#import "ColoredButton.h"
#import "SWButtonItem.h"
#import "SWEnumTypes.h"

#import "SWColor.h"


@implementation SWButtonItemController
{
    BOOL _pendingNormalUp;
    //NSString* _imageName;
}

@synthesize buttonView = _buttonView;
//@synthesize labelView = _labelView;

- (void)loadView
{
    _buttonView = [[ColoredButton alloc] init];
    [_buttonView setFrame:CGRectMake(0,0,100,100)];
    [_buttonView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_buttonView addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_buttonView addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    self.view = _buttonView;
}

- (void)viewDidUnload
{
    _buttonView = nil;
    [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //[self _updateWithResizedImageIfNeededWithOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self _updateWithResizedImageIfNeeded];
}

#pragma mark - Overriden Methods

- (void)refreshInterfaceIdiomFromModel
{
    [super refreshInterfaceIdiomFromModel];
    [self _updateWithResizedImageIfNeeded];
}


- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateActivedState];
    [self _updateView];
}

- (void)refreshZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    [super refreshZoomScaleFactor:zoomScaleFactor];
    //[self _updateWithResizedImageIfNeeded];
    [self _updateImage];
}

- (void)refreshFrameEditingState:(BOOL)frameEditing
{
    [super refreshFrameEditingState:frameEditing];
    //[self _updateWithResizedImageIfNeeded];
    [self _updateImage];
}


#pragma mark - Main Methods


- (void)_delayedNormalEnd:(id)dummy
{
    _pendingNormalUp = NO;  //$$$
    SWButtonItem *item = [self _buttonItem];
    [item.value evalWithConstantValue:0.0];
}



- (void)_checkPointForValue:(double)value
{
    SWButtonItem *item = [self _buttonItem];
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL verified, BOOL success)
    {
        if ( success )
        {
            SWButtonStyle style = item.buttonStyle.valueAsInteger;
            if ( style == SWButtonStyleNormal || style == SWButtonStyleTouchUp )
                _pendingNormalUp = YES;   // aband
            
            [item.value evalWithConstantValue:value];   // canviem el valor actual
            if ( (verified || style == SWButtonStyleTouchUp) && _pendingNormalUp )  // si el block torna inmediatament es perque no es requereix verificacio, i el if no s'executara
                                     // si el block torna despres de confirmacio executarem la part final ara
            {
                [self performSelector:@selector(_delayedNormalEnd:) withObject:nil afterDelay:0.0];
            }
        }
        else
        {
            [item.continuousValue evalWithValue:item.value];   // tornem al valor original
            [theSelf _updateValue];    // updatem el view amb el valor actual (el original)
        }
        //$$$ _pendingNormalUp = NO;
    }];
}




- (void)buttonTouchDown:(id)sender
{
    SWButtonItem *item = [self _buttonItem];
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    if ( style == SWButtonStyleNormal )
    {
        [item.continuousValue evalWithDouble:1.0];   // posem el valor temporal
        [self _setViewValue:1];   // updatem el view amb el valor temporal
        
        [self _checkPointForValue:1.0];
        //$$$ _pendingNormalUp = YES;   // despres de cridar checkPoint
    }
}


- (void)buttonTouchUpInside:(id)sender
{
    SWButtonItem *item = [self _buttonItem];
    
//    BOOL bvalue = !(item.value.valueAsBool);
//    double value = bvalue?1.0:0.0;
    
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    
    if ( style == SWButtonStyleToggle )
    {
        BOOL bvalue = !(item.value.valueAsBool);
        double value = bvalue?1.0:0.0;
        
        [item.continuousValue evalWithDouble:value];   // posem el valor temporal
        [self _setViewValue:bvalue];   // updatem el view amb el valor temporal
    
        [self _checkPointForValue:value];
    }
    
    else if ( style == SWButtonStyleTouchUp )
    {
        [item.continuousValue evalWithDouble:1.0];   // posem el valor temporal
        [self _setViewValue:1];   // updatem el view amb el valor temporal
        
        //$$$ _pendingNormalUp = YES;   // abans de cridar checkPoint
        [self _checkPointForValue:1.0];
    }

    else // SWButtonStyleNormal o
    {
        [self buttonTouchUpOutside:sender];
    }
}

- (void)buttonTouchUpOutside:(id)sender
{
    SWButtonItem *item = [self _buttonItem];
    SWButtonStyle style = item.buttonStyle.valueAsInteger;
    
    if ( style == SWButtonStyleToggle )
    {
        [item.continuousValue evalWithValue:item.value];   // tornem al valor original
        [self _updateValue];    // updatem el view
    }
    
    else // if ( style == SWButtonStyleNormal )
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
    [self _updateEnabledState];
    [self _updateAspectRatio];
//    [self _updateViewWithImageName];
    [self _updateImage];
    [self _updateLabel];
    [self _updateColor];
    [self _updateFont];
    [self _updateTextAlignement];
    [self _updateVerticalTextAlignment];
    [self _updateValue];
    
}


- (void)_setImage:(UIImage*)image
{
    if ( image /*&& _imageName*/ )  // aqui ens hauriem d'asegurar que quan arribem aqui encara hi ha una imatgeName
    {
        [_buttonView setImage:image forState:UIControlStateNormal];
        [_buttonView.imageView setContentScaleFactor:[[UIScreen mainScreen]scale]];
        // ^ Hack, el setImage implicitament posa el contentScale, ho overridem al valor normal.
    }
    else
    {
        [_buttonView setImage:nil forState:UIControlStateNormal];
    }
}


- (void)_updateImage
{
    if (self.frameEditing)
        [self _updateWithOriginalImage];
    else
        [self _updateWithResizedImageIfNeeded];
}


- (void)_updateWithOriginalImage
{    
    SWButtonItem *item = [self _buttonItem];
    SWExpression *imageExp = item.imagePath;
    
    if ( [imageExp valueIsEmpty] )
    {
        [self _setImage:nil];
        return;
    }
    
    id img = [imageExp valuesAsStrings];  // pot tornar string o array de strings

    NSTimeInterval duration = [item.animationDuration valueAsDouble];
    
    [filesModel().amImage getAnimatedOriginalImageWithNames:img duration:duration inDocumentName:item.redeemedName contentScale:0
    completionBlock:^(UIImage *image)
    {
        [self _setImage:image];
    }];
}


- (void)_updateWithResizedImageIfNeededWithOrientation:(UIInterfaceOrientation)orientation
{
    if ( self.frameEditing )
        return;
    
    SWButtonItem *item = [self _buttonItem];
    SWExpression *imageExp = item.imagePath;
    
    if ( [imageExp valueIsEmpty] )
    {
        [self _setImage:nil];
        return;
    }
    
    id img = [imageExp valuesAsStrings];  // pot tornar string o array de strings
    
    CGSize size = [item frameForOrientation:orientation idiom:item.docModel.interfaceIdiom].size;
    CGFloat contentScale = [[UIScreen mainScreen]scale]*self.zoomScaleFactor;
//    SWImageAspectRatio ratio = [item.aspectRatio valueAsInteger];
//    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
    
    NSTimeInterval duration = [item.animationDuration valueAsDouble];
    
    [filesModel().amImage getAnimatedImageWithNames:img duration:duration inDocumentName:item.redeemedName size:size
    contentMode:_buttonView.imageView.contentMode contentScale:contentScale completionBlock:^(UIImage *image)
    {
        [self _setImage:image];
    }];
}

- (void)_updateWithResizedImageIfNeeded
{
    [self _updateWithResizedImageIfNeededWithOrientation:self.interfaceOrientation];
}

//- (void)_updateWithResizedImageIfNeededXX
//{
//    if ( _imageName )
//    {
//        SWButtonItem *item = [self _buttonItem];
//        
//        if ( self.frameEditing )
//        {
//            [filesModel() getOriginalImageWithName:_imageName inDocumentName:item.redeemedName
//            completionBlock:^(UIImage *image)
//            {
//                [self _setImage:image];
//            }];
//        }
//        else
//        {
//            CGSize size = [item frameForOrientation:self.interfaceOrientation idiom:item.docModel.interfaceIdiom].size;
//            CGFloat contentScale = [[UIScreen mainScreen]scale]*self.zoomScaleFactor;
//            SWImageAspectRatio ratio = [item.aspectRatio valueAsInteger];
//            UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
//            
//            [filesModel() getImageWithName:_imageName inDocumentName:item.redeemedName size:size contentMode:contentMode contentScale:contentScale
//            completionBlock:^(UIImage *image)
//            {
//                [self _setImage:image];
//            }];
//        }
//    }
//}


//- (void)_updateViewWithImageName
//{
//    SWButtonItem *item = [self _buttonItem];
//    
//    NSString *imageName = [item.imagePath valueAsString];
//    if ( imageName.length > 0 ) _imageName = imageName;
//    else _imageName = nil;
//    
//    if ( _imageName )
//    {
//        [self _updateWithResizedImageIfNeeded];
//    }
//    else
//    {
//        [self _setImage:nil];
//    }
//}


- (void)_updateAspectRatio
{
    SWButtonItem *item = [self _buttonItem];
    SWImageAspectRatio ratio = [item.aspectRatio valueAsInteger];
    
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);

    _buttonView.imageView.contentMode = contentMode;
    _buttonView.contentMode = contentMode;
}



- (void)_setViewValue:(BOOL)bvalue
{
    UIButton *btn = _buttonView;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [btn setHighlighted:bvalue];
    });
}

- (void)_updateValue
{
    SWButtonItem *item = [self _buttonItem];
    BOOL value = item.value.valueAsBool;
    [self _setViewValue:value];
}


//- (void)_updateValue
//{
//    SWButtonItem *item = [self _buttonItem];
//    SWButtonStyle style = item.buttonStyle.valueAsInteger;
//    BOOL value = item.value.valueAsBool;
//
//    if ( style == SWButtonStyleToggle )
//    {
//        UIButton *btn = _buttonView;
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            [btn setHighlighted:value];
//        });
//    }
//}


- (void)_updateTextAlignement
{
    SWButtonItem *item = [self _buttonItem];
    SWTextAlignment textAlignment = [item.textAlignment valueAsInteger];
    
    NSTextAlignment aligment;
    
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
    
    [_buttonView setTextAlignment:aligment];
}


- (void)_updateVerticalTextAlignment
{
    SWButtonItem *item = [self _buttonItem];
    SWVerticalTextAlignment textAlignment = [item.verticalTextAlignment valueAsInteger];
    
    VerticalAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWVerticalTextAlignmentTop:
            aligment = VerticalAlignmentTop;
            break;
            
        default:
        case SWVerticalTextAlignmentCenter:
            aligment = VerticalAlignmentMiddle;
            break;
            
        case SWVerticalTextAlignmentBottom:
            aligment = VerticalAlignmentBottom;
            break;
    }
    
    [_buttonView setVerticalTextAlignment:aligment];
}



- (void)_updateLabel
{    
    SWButtonItem *item = [self _buttonItem];
    NSString *text = item.title.valueAsString;
    [_buttonView setOverTitle:text];
}

- (void)_updateFont
{
    SWButtonItem *item = [self _buttonItem];
    
    UIFont *font = [UIFont fontWithName:[item.font valueAsString] size:[item.fontSize valueAsDouble]];
    _buttonView.overFont = font;
}

- (void)_updateColor
{
    SWButtonItem *item = [self _buttonItem];
    
    UInt32 rgbColor = item.color.valueAsRGBColor;

    [_buttonView setRgbTintColor:rgbColor overWhite:NO];
}


- (void)_updateActivedState
{
    SWButtonItem *item = [self _buttonItem];

    BOOL active = item.active.valueAsBool;
    
    [_buttonView setUnactived:!active];
}

- (void)_updateEnabledState
{
    SWButtonItem *item = [self _buttonItem];

    BOOL enabled = item.enabled.valueAsBool;
    
    [_buttonView setEnabled:enabled];
}


#pragma mark - SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWButtonItem *item = [self _buttonItem];
    if ( value == item.buttonStyle)
    {
        [self _updateValue];
    }
    
    else if (value == item.value)
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
    
    else if ( value == item.verticalTextAlignment)
    {
        [self _updateVerticalTextAlignment];
    }
    
    else if (value == item.font || value == item.fontSize) 
    {
        [self _updateFont];
    }
    
    else if (value == item.enabled) 
    {
        [self _updateEnabledState];
        //[self _updateView];
    }
    
    else if (value == item.active)
    {
        [self _updateActivedState];
    }
    
    else if ( value == item.imagePath )
    {
        //[self _updateViewWithImageName];
        [self _updateImage];
    }
    
    else if ( value == item.aspectRatio)
    {
        [self _updateAspectRatio];
        [self _updateWithResizedImageIfNeeded];
    }
    
    else if ( value == item.animationDuration )
    {
        [self _updateImage];
    }
    
    else if ( value == item.framePortrait || value == item.frameLandscape ||
        value == item.framePortraitPhone || value == item.frameLandscapePhone )
    {
        [super value:value didEvaluateWithChange:changed];
        if ( [item frameValue:value matchesInterfaceIdiom:item.docModel.interfaceIdiom forOrientation:self.interfaceOrientation] )
            [self _updateWithResizedImageIfNeeded];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
