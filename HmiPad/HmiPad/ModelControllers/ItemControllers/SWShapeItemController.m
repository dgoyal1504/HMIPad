//
//  SWShapeItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWShapeItemController.h"
#import "SWShapeItem.h"
#import "SWShapeView.h"

//#import "SWImageManager.h"
#import "AppModel.h"
#import "AppModelImage.h"

@implementation SWShapeItemController
@synthesize shapeView = _shapeView;

- (void)loadView
{
    _shapeView = [[SWShapeView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view = _shapeView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setShapeView:nil];
    [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self _updateWithResizedImageIfNeededWithOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
   // [self _updateWithResizedImageIfNeeded];
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

    SWShapeItem *item = [self _shapeItem];
    
    _shapeView.fillStyle = item.fillStyle.valueAsInteger;
    _shapeView.gradientDirection = item.gradientDirection.valueAsInteger;
    _shapeView.fillColor1 = item.fillColor1.valueAsColor;
    _shapeView.fillColor2 = item.fillColor2.valueAsColor;
    [self _updateAspectRatio];
    [self _updateImage];
    
    _shapeView.strokeStyle = item.strokeStyle.valueAsInteger;
    _shapeView.cornerRadius = item.cornerRadius.valueAsDouble;
    _shapeView.strokeColor = item.strokeColor.valueAsColor;
    _shapeView.lineWidth = item.lineWidth.valueAsDouble;
    _shapeView.gridColumns = item.gridColumns.valueAsInteger;
    _shapeView.gridRows = item.gridRows.valueAsInteger;
    
    _shapeView.shadowStyle = item.shadowStyle.valueAsDouble;
    _shapeView.shadowOffset = item.shadowOffset.valueAsDouble;
    _shapeView.shadowBlur = item.shadowBlur.valueAsDouble;
    _shapeView.shadowColor = item.shadowColor.valueAsColor;
    
    [_shapeView setLayerOpacity:item.opacity.valueAsDouble animated:NO];
    _shapeView.blink = item.blink.valueAsBool;
}

- (void)refreshFrameEditingState:(BOOL)frameEditing
{
    [super refreshFrameEditingState:frameEditing];
    [self _updateImage];
}

- (void)refreshZoomScaleFactor:(CGFloat)contentScaleFactor
{
    [super refreshZoomScaleFactor:contentScaleFactor];
    [self _updateImage];
}

- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return YES;
}

#pragma mark - Private Methods

- (SWShapeItem*)_shapeItem
{
    return (SWShapeItem*)self.item;
}


- (void)_updateImage
{
    if (self.frameEditing)
        [self _updateWithOriginalImage];
    else
        [self _updateWithResizedImageIfNeeded];
}

- (void)_updateAspectRatio
{
    SWShapeItem *item = [self _shapeItem];
    SWImageAspectRatio ratio = [item.aspectRatioValue valueAsInteger];
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
    _shapeView.contentMode = contentMode;
}


//
//- (void)_updateTintColor
//{
//    SWImageItem *item = [self _imageItem];
//    UInt32 rgbColor = item.tintColorExpression.valueAsRGBColor;
//    _imageView.rgbTintColor = rgbColor;
//}


- (void)_updateWithOriginalImage
{    
    SWShapeItem *item = [self _shapeItem];
    NSString *imageName = [item.fillImage valueAsString];
    
    SWShapeView *shapeView = _shapeView;
//    [[SWImageManager defaultManager] getOriginalImageWithName:imageName inDocumentName:item.docName
//    completionBlock:^(UIImage *image)
//    {
//        shapeView.originalImage = image;
//    }];
    
    [filesModel().amImage getOriginalImageWithName:imageName inDocumentName:item.redeemedName
    completionBlock:^(UIImage *image)
    {
        [shapeView setOriginalImage:image];
    }];
}



- (void)_updateWithResizedImageIfNeededWithOrientation:(UIInterfaceOrientation)orientation
{
    if (self.frameEditing)
        return;
    
    SWShapeItem *item = [self _shapeItem];

//    CGSize size;
//    
//    if (orientation == UIInterfaceOrientationLandscapeLeft ||
//        orientation == UIInterfaceOrientationLandscapeRight)
//        size = item.frameLandscape.valueAsCGRect.size;
//    else
//        size = item.framePortrait.valueAsCGRect.size;
    
    CGSize size = [item frameForOrientation:self.interfaceOrientation idiom:item.docModel.interfaceIdiom].size;
    
    NSString *imageName = [item.fillImage valueAsString];
    
    SWShapeView *shapeView = _shapeView;
    CGFloat contentScale = [[UIScreen mainScreen]scale]*self.zoomScaleFactor;

    [filesModel().amImage getImageWithName:imageName inDocumentName:item.redeemedName size:size contentMode:_shapeView.contentMode contentScale:contentScale
    completionBlock:^(UIImage *image)
    {
        [shapeView setResizedImage:image];
    }];

}


- (void)_updateWithResizedImageIfNeeded
{
    [self _updateWithResizedImageIfNeededWithOrientation:self.interfaceOrientation];
}



#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    SWShapeItem *item = [self _shapeItem];
        
    if ( value == item.fillStyle )
        _shapeView.fillStyle = value.valueAsInteger;
        
    else if ( value == item.gradientDirection )
        _shapeView.gradientDirection = value.valueAsInteger;
    
    else if ( value == item.fillColor1 )
        _shapeView.fillColor1 = value.valueAsColor;
    
    else if ( value == item.fillColor2 )
        _shapeView.fillColor2 = value.valueAsColor;
    
    else if ( value == item.fillImage )
        [self _updateImage];
    
    else if ( value == item.aspectRatioValue )
    {
        [self _updateAspectRatio];
        [self _updateWithResizedImageIfNeeded];
    }
    else if ( value == item.strokeStyle )
        _shapeView.strokeStyle = value.valueAsInteger;
    
    else if ( value == item.cornerRadius )
        _shapeView.cornerRadius = value.valueAsDouble;
    
    else if ( value == item.strokeColor )
        _shapeView.strokeColor = value.valueAsColor;
    
    else if ( value == item.lineWidth )
        _shapeView.lineWidth = value.valueAsDouble;
    
    else if ( value == item.shadowStyle )
        _shapeView.shadowStyle = value.valueAsDouble;
        
    else if ( value == item.shadowOffset )
        _shapeView.shadowOffset = value.valueAsDouble;
    
    else if ( value == item.shadowBlur )
        _shapeView.shadowBlur = value.valueAsDouble;
    
    else if ( value == item.shadowColor )
        _shapeView.shadowColor = value.valueAsColor;
    
    else if ( value == item.opacity )
        [_shapeView setLayerOpacity:value.valueAsDouble animated:YES];
    
    else if ( value == item.blink )
        _shapeView.blink = value.valueAsBool;
    
    else if ( value == item.gridColumns )
        _shapeView.gridColumns = value.valueAsInteger;
    
    else if ( value == item.gridRows )
        _shapeView.gridRows = value.valueAsInteger;
    
    else if (value == item.framePortrait || value == item.frameLandscape ||
        value == item.framePortraitPhone || value == item.frameLandscapePhone )
    {
        [super value:value didEvaluateWithChange:changed];
        if ( [item frameValue:value matchesInterfaceIdiom:item.docModel.interfaceIdiom forOrientation:self.interfaceOrientation] )
            [self _updateWithResizedImageIfNeeded];
    }
        
    else
        [super value:value didEvaluateWithChange:changed];
    
}

@end
