//
//  SWTopFileViewerCell.m
//  HmiPad
//
//  Created by Joan on 14/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWCurrentProjectView.h"
//#import "ColoredButton.h"
#import "SWCircleButton.h"
#import "SWColor.h"

@implementation SWCurrentProjectView
{
    //float _progressValue;
    //NSString *_progressText;
    //BOOL _shouldDissable;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [_emptyLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
    [self setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
    
//    if ( IS_IOS7 )
//    {
//        [_labelFileName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
//        [_labelFileIdent setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//        [_labelModDate setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//        [_labelSize setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//    }


    // posem borde i color al imageview del boto
    CALayer *layer = _buttonImage.imageView.layer;
//    layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
//    layer.borderWidth = 1;
//    layer.cornerRadius = 5;
//    layer.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1].CGColor;
//    layer.masksToBounds = YES;
    
    layer.borderColor = [UIColor colorWithWhite:0.33 alpha:1.0].CGColor;
    layer.borderWidth = 1;
    layer.cornerRadius = 5;
    layer.backgroundColor = checkeredBackgroundColor().CGColor;
    layer.masksToBounds = YES;
    
    // rasteritzem el boto per performance
    CALayer *buttonLayer = _buttonImage.layer;
    buttonLayer.shouldRasterize = YES;
    buttonLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _buttonUpload.tintColor = UIColorWithRgb(TheNiceGreenColor);
    _buttonClose.tintColor = [UIColor orangeColor]; // [UIColor redColor];
}

//-(void)fileViewCellDidTouchUploadButton:(SWTopFileViewerCell*)cell;

- (IBAction)buttonUploadTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(currentProjectViewDidTouchUploadButton:)] )
    {
        [_delegate currentProjectViewDidTouchUploadButton:self];
    }
}

- (IBAction)buttonDuplicateTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(currentProjectViewDidTouchDuplicateButton:)] )
    {
        [_delegate currentProjectViewDidTouchDuplicateButton:self];
    }
}

- (IBAction)buttonCloseTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(currentProjectViewDidTouchCloseButton:)] )
    {
        [_delegate currentProjectViewDidTouchCloseButton:self];
    }
}


- (IBAction)buttonImageTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(currentProjectViewDidTouchImageButton:)] )
    {
        [_delegate currentProjectViewDidTouchImageButton:self];
    }
}


- (void)setButtonUploadDisabled:(BOOL)buttonUploadDisabled
{
    _buttonUploadDisabled = buttonUploadDisabled;
   // _buttonUpload.hidden = /*_viewsDisabled ||*/ buttonUploadDisabled;
    _buttonUpload.enabled = !buttonUploadDisabled;
}


- (void)setRunOnly:(BOOL)runOnly
{
    _runOnly = runOnly;
    [self setViewsDisabled:_viewsDisabled];
}

- (void)setViewsDisabled:(BOOL)disabled
{
    _viewsDisabled = disabled;
    //_buttonImage.hidden = disabled;
    _labelFileName.hidden = disabled;
    _labelFileIdent.hidden = disabled;
    _labelModDate.hidden = disabled;
    _labelSize.hidden = disabled;
    _buttonUpload.hidden = disabled; /*|| _buttonUploadHidden*/;
    _buttonDuplicate.hidden = disabled;
    
    _labelPrompt1.hidden = disabled;
    _labelPrompt2.hidden = disabled;
    _labelPrompt3.hidden = disabled;
    _labelPromptUpdate.hidden = disabled;
    
    _emptyLabel.hidden = !disabled;
    
    NSString *text = nil;
    if ( disabled )
        text = NSLocalizedString(@"FileViewerViewNoProject", nil);
    
    _emptyLabel.text = text;
    
    _labelPromptDuplicate.hidden = disabled || _runOnly;
    _buttonDuplicate.hidden = disabled || _runOnly;
    _labelPromptClose.hidden = disabled || _runOnly;
    _buttonClose.hidden = disabled || _runOnly;
    _labelAssets.hidden = disabled || _runOnly;
    _labelUseAssets.hidden = disabled || _runOnly;
    _switchEmbedded.hidden = disabled || _runOnly;
    _tableAssets.hidden = disabled || _runOnly;
}


//-(void)setFrame:(CGRect)frame
//{
//    NSLog( @"Frame:%@", NSStringFromCGRect(frame));
//    [super setFrame:frame];
//}

@end
