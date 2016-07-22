//
//  SWImageItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWImageItemController.h"

#import "SWEnumTypes.h"
#import "SWImageItem.h"

//#import "AppFilesModel.h"

//#import "SWImageManager.h"
#import "AppModel.h"
#import "AppModelImage.h"

#import "SWTintedImageView.h"

@interface SWImageItemController ()
@end

@implementation SWImageItemController

@synthesize imageView = _imageView;

- (void)loadView
{
    _imageView = [[SWTintedImageView alloc] init];
    [_imageView setRgbTintColor:0xffffffff];
    _imageView.clipsToBounds = YES;
    
    self.view = _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
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
    
    [self _updateAspectRatio];
    [self _updateTintColor];
    [self _updateImage];
}

- (void)refreshZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    // no cridem el super
    
    [_imageView setZoomScaleFactor:zoomScaleFactor];
    [self _updateImage];
}

- (void)refreshFrameEditingState:(BOOL)frameEditing
{
    [super refreshFrameEditingState:frameEditing];
    [self _updateImage];
}

- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return YES;
}

#pragma mark - Private Methods

// -- Getters -- //
- (SWImageItem*)_imageItem
{
    SWItem *item = self.item;
    if ([item isKindOfClass:[SWImageItem class]])
        return (SWImageItem*)item;

    return nil;
}

//- (NSString*)_pathForOriginalImage
//{
//    SWImageItem *item = [self _imageItem];
//    NSString *imageName = item.imagePathExpression.valueAsString;
//    NSString *imagePath = [model() fileFullPathForFileName:imageName forCategory:kFileCategoryAssetFile];
//    return imagePath;
//}



// -- Refresh From Expression Methods -- //

- (void)_updateImage
{
    if (self.frameEditing)
        [self _updateWithOriginalImage];
    else
        [self _updateWithResizedImageIfNeeded];
}

- (void)_updateAspectRatio
{
    SWImageItem *item = [self _imageItem];
    SWImageAspectRatio ratio = item.aspectRatioValue.valueAsInteger;
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(ratio);
    _imageView.contentMode = contentMode;
}

- (void)_updateTintColor
{
    SWImageItem *item = [self _imageItem];
    UInt32 rgbColor = item.tintColorExpression.valueAsRGBColor;
    _imageView.rgbTintColor = rgbColor;
}


//- (void)_updateWithOriginalImageV
//{
//    SWImageItem *item = [self _imageItem];
//    NSString *imageName = item.imagePathExpression.valueAsString;
//    
//    SWTintedImageView *imageView = _imageView;
//    CGFloat contentScale = imageView.contentScaleFactor;
//    //contentScale = 0;
//    
//    [filesModel() getOriginalImageWithName:imageName inDocumentName:item.redeemedName contentScale:contentScale
//    completionBlock:^(UIImage *image)
//    {
//        [imageView setOriginalImage:image];
//    }];
//}






//- (void)_updateWithOriginalImageV
//{
//    SWImageItem *item = [self _imageItem];
//    
//    SWExpression *imageExp = item.imagePathExpression;
//    NSString *imageName = imageExp.valueAsString;
//    
//    SWTintedImageView *imageView = _imageView;
//    //CGFloat contentScale = [[UIScreen mainScreen]scale];
//    //contentScale = 0;
//    
//    [filesModel() getOriginalImageWithName:imageName inDocumentName:item.redeemedName /*contentScale:contentScale*/
//    completionBlock:^(UIImage *image)
//    {
//        [imageView setOriginalImage:image];
//    }];
//}


- (void)_updateWithOriginalImage
{
    SWImageItem *item = [self _imageItem];
    
    SWExpression *imageExp = item.imagePathExpression;
    id img = [imageExp valuesAsStrings];  // pot tornar string o array de strings
    
    SWTintedImageView *imageView = _imageView;
    //CGFloat contentScale = [[UIScreen mainScreen]scale];
    //contentScale = 0;
    
    NSTimeInterval duration = [item.animationDurationExpression valueAsDouble];
    
    [filesModel().amImage getAnimatedOriginalImageWithNames:img duration:duration inDocumentName:item.redeemedName contentScale:0 completionBlock:^(UIImage *image)
    {
        [imageView setOriginalImage:image];
    }];
}



//- (void)_updateWithResizedImageIfNeededWithOrientationV:(UIInterfaceOrientation)orientation
//{
//    if (self.frameEditing)
//        return;
//    
//    SWImageItem *item = [self _imageItem];
//    
//    CGSize size = [item frameForOrientation:orientation idiom:item.docModel.interfaceIdiom].size;
//    
//    SWExpression *imageExp = item.imagePathExpression;
//    NSString *imageName = imageExp.valueAsString;
//    
//    SWTintedImageView *imageView = _imageView;
//    //CGFloat contentScale = imageView.contentScaleFactor * self.zoomScaleFactor;
//    CGFloat contentScale = [[UIScreen mainScreen]scale]*self.zoomScaleFactor;
//    
//    [filesModel() getImageWithName:imageName inDocumentName:item.redeemedName size:size contentMode:_imageView.contentMode contentScale:contentScale
//    completionBlock:^(UIImage *image)
//    {
////        NSLog( @"imageSize = %@", NSStringFromCGSize(image.size));
////        NSLog( @"imageViewSize = %@", NSStringFromCGSize(imageView.bounds.size));
//    
//        [imageView setResizedImage:image];
//    }];
//}


- (void)_updateWithResizedImageIfNeededWithOrientation:(UIInterfaceOrientation)orientation
{
    if (self.frameEditing)
        return;
    
    SWImageItem *item = [self _imageItem];
    
    CGSize size = [item frameForOrientation:orientation idiom:item.docModel.interfaceIdiom].size;
    
    SWExpression *imageExp = item.imagePathExpression;
    id img = [imageExp valuesAsStrings];  // pot tornar strings o array de strings
    
    NSTimeInterval duration = [item.animationDurationExpression valueAsDouble];
    
    SWTintedImageView *imageView = _imageView;
    
    CGFloat contentScale = [[UIScreen mainScreen]scale]*self.zoomScaleFactor;
    
    [filesModel().amImage getAnimatedImageWithNames:img duration:duration inDocumentName:item.redeemedName size:size
    contentMode:_imageView.contentMode contentScale:contentScale completionBlock:^(UIImage *image)
    {
        [imageView setResizedImage:image];
    }];
}


- (void)_updateWithResizedImageIfNeeded
{
    [self _updateWithResizedImageIfNeededWithOrientation:self.interfaceOrientation];
}

#pragma mark - SWExpressionObserver

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    //[super value:value didEvaluateWithChange:changed];
    
    SWImageItem *item = [self _imageItem];
    
    if (value == item.imagePathExpression) 
    {
        [self _updateImage];
    }
    
    else if (value == item.tintColorExpression)
    {
        [self _updateTintColor];
    }
    
    else if (value == item.aspectRatioValue) 
    {
        [self _updateAspectRatio];
        [self _updateWithResizedImageIfNeeded];
    }
    
    else if ( value == item.animationDurationExpression )
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
