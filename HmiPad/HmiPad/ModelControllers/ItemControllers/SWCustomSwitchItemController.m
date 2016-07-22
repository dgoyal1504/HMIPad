//
//  SWCustomSwitchItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/5/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWCustomSwitchItemController.h"
#import "SWCustomSwitchItem.h"

//#import "SWImageManager.h"
#import "AppModel.h"
#import "AppModelImage.h"

//#import "AppFilesModel.h"
#import "SWColor.h"

#import "SWEnumTypes.h"





@implementation SWCustomSwitchItemController
{
//    BOOL _editingAllowed;
}

@synthesize button = _button;

- (void)loadView
{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0,0,100,100);
    _button.backgroundColor = [UIColor clearColor];
    [_button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    self.view = _button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[_button addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    _button = nil;
    [super viewDidUnload];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self _updateWithResizedImageIfNeeded];
}

#pragma mark Overriden Methods

- (void)refreshInterfaceIdiomFromModel
{
    [super refreshInterfaceIdiomFromModel];
    [self _updateWithResizedImageIfNeeded];
}

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateViewFromValue];
    [self _updateViewFromEnabled];
}

- (void)refreshFrameEditingState:(BOOL)frameEditing
{
    [super refreshFrameEditingState:frameEditing];
    [self _updateViewFromValue];
}

- (void)refreshZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    // no cridem el super
    
    [self _updateWithResizedImageIfNeeded];
}

- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return NO;
}

#pragma mark Public Methods

- (void)_checkPointForValue:(double)value
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
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
            [theSelf _updateViewFromValue];    // updatem el view
        }
    }];
}


- (void)buttonTouchUpInside:(id)sender
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    BOOL bvalue = !(item.value.valueAsBool);
    double value = bvalue?1.0:0.0;
    
    [item.continuousValue evalWithDouble:value];
    [self _setViewValue:bvalue];
    
    [self _checkPointForValue:value];
}


- (void)buttonTouchUpOutside:(id)sender
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    [item.continuousValue evalWithValue:item.value];   // tornem al valor original
    [self _updateViewFromValue];    // updatem el view
}


#pragma mark Private Methods

- (SWCustomSwitchItem*)_customSwitchItem
{
    return (SWCustomSwitchItem*)self.item;
}


- (NSString*)_imageNameForState:(BOOL)state
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    NSString *imageName =  nil;
    
    if (state)
        imageName = item.imagePathForStateOn.valueAsString;
    else
        imageName = item.imagePathForStateOff.valueAsString;
    
    if (imageName.length == 0 )
        return nil;
    
    return imageName;
}


- (void)_setAspectRatioForValue:(BOOL)bvalue
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    SWImageAspectRatio ratio = [(bvalue?item.aspectRatioForStateOn:item.aspectRatioForStateOff) valueAsInteger];
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
    [_button.imageView setContentMode:contentMode];
}

- (void)_setViewValue:(BOOL)bvalue
{    
    [self _setAspectRatioForValue:bvalue];
    
    NSString *imageName = [self _imageNameForState:bvalue];
    
    if (imageName)
    {
        SWCustomSwitchItem *item = [self _customSwitchItem];
        
        if (self.frameEditing)
        {
            [filesModel().amImage getOriginalImageWithName:imageName inDocumentName:item.redeemedName completionBlock:^(UIImage *image)
            {
                [self _setImage:image];
            }];
        }
        else
        {
            CGSize size = [item frameForOrientation:self.interfaceOrientation idiom:item.docModel.interfaceIdiom].size;
            CGFloat contentScale = [[UIScreen mainScreen]scale]*self.zoomScaleFactor;
            UIViewContentMode contentMode = _button.imageView.contentMode;
            
            [filesModel().amImage getImageWithName:imageName inDocumentName:item.redeemedName size:size contentMode:contentMode contentScale:contentScale completionBlock:^(UIImage *image)
            {
                [self _setImage:image];
            }]; 
        
        }
    }
    else
    {
        //UIImage *image = [UIImage imageNamed:@"PhotoNoAvailable300.png"];
        imageName = bvalue ? @"picture_filled-256.png" : @"picture-256.png";
        
        UIImage *image = [UIImage imageNamed:imageName];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self _setImage:image];
    }
}



- (void)_updateViewFromValue
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    BOOL bvalue = item.value.valueAsBool;
    [self _setViewValue:bvalue];
}

- (void)_updateWithResizedImageIfNeeded
{
    if ( !self.frameEditing )
        [self _updateViewFromValue];
}

- (void)_updateViewFromImageOn
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    if ( [item.value valueAsBool] != NO)
        [self _setViewValue:YES];
}

- (void)_updateViewFromImageOff
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    if ( [item.value valueAsBool] == NO)
         [self _setViewValue:NO];
}

- (void)_updateViewFromAspectRationOn
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    if ( [item.value valueAsBool] == NO )
        return;
    
    SWImageAspectRatio ratio = [item.aspectRatioForStateOn valueAsInteger];
    
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
    
    [_button.imageView setContentMode:contentMode];
}

- (void)_updateViewFromAspectRationOff
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    if ( [item.value valueAsBool] != NO )
        return;
    
    SWImageAspectRatio ratio = [item.aspectRatioForStateOff valueAsInteger];
    
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
    
    [_button.imageView setContentMode:contentMode];
}




- (void)_updateViewFromEnabled
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    BOOL enabled = item.enabled.valueAsBool;
    
//    [_button addTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
//    [_button addTarget:self action:NULL forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside];
//    //[_button addTarget:self action:NULL forControlEvents:UIControlEventTouchDown];
//    
//    if ( enabled )
//    {
//        [_button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//        [_button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside];
//        //[_button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
//    }
    
    [_button setEnabled:enabled];
}

- (void)_setImage:(UIImage*)image
{
    [_button setImage:image forState:UIControlStateNormal];
    [_button.imageView setContentScaleFactor:[[UIScreen mainScreen]scale]];
    // ^ Hack, el setImage implicitament posa el contentScale, ho overridem al valor normal.
    
    
//    [_button setTitle:@"HOLA" forState:UIControlStateNormal];
//    [_button setTitleEdgeInsets:UIEdgeInsetsMake(70.0, -150.0, 5.0, 5.0)];
//    [_button setImage:image forState:UIControlStateDisabled];
//    [_button setImage:image forState:UIControlStateHighlighted];
}

#pragma mark - SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWCustomSwitchItem *item = [self _customSwitchItem];
    
    if (value == item.value) 
    {
        [self _updateViewFromValue];
    }    
    else if (value == item.imagePathForStateOn) 
    {
        [self _updateViewFromImageOn];
    }
    else if (value == item.imagePathForStateOff) 
    {
        [self _updateViewFromImageOff];
    }
    else if (value == item.aspectRatioForStateOn) 
    {
        [self _updateViewFromAspectRationOn];
        [self _updateWithResizedImageIfNeeded];
    }
    else if (value == item.aspectRatioForStateOff) 
    {
        [self _updateViewFromAspectRationOff];
        [self _updateWithResizedImageIfNeeded];
    }
    else if (value == item.enabled) 
    {
        [self _updateViewFromEnabled];
    }
    else if (value == item.framePortrait || value == item.frameLandscape ||
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
