//
//  SWImagePickerViewCell.m
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWImagePickerViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SWImagePickerViewCell
{
    UIImageView *_imageView;
    UIImageView *_checkmark;
    
    UITapGestureRecognizer *_tapGesture;
}

@synthesize showBorder = _showBorder;
@synthesize selected = _selected;
@synthesize delegate = _delegate;
@dynamic image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _selected = NO;
        _showBorder = NO;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognized:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

#pragma mark Properties

- (UIImage*)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)setShowBorder:(BOOL)showBorder
{
    if (_showBorder == showBorder)
        return;
    
    _showBorder = showBorder;
    
    if (showBorder) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor blackColor].CGColor;
    } else {
        self.layer.borderWidth = 0;
    }
}

- (void)setSelected:(BOOL)selected
{
    if (_selected == selected)
        return;
 
    _selected = selected;
    
    if (selected) {        
        _imageView.alpha = 0.5;        
        _checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
        _checkmark.frame = CGRectMake(self.frame.size.width-28-4,self.frame.size.height-28-4,28,28);
        [self addSubview:_checkmark];
    } else {
        _imageView.alpha = 1.0;
        
        [_checkmark removeFromSuperview];
        _checkmark = nil;
    }
}

#pragma mark Overriden Methods


#pragma mark Public Methods

- (void)prepareForReuse
{
    _imageView.image = nil;
    self.selected = NO;
}

#pragma mark Private Methods

- (void)_tapGestureRecognized:(UITapGestureRecognizer*)recognizer
{    
    if ([_delegate respondsToSelector:@selector(tapReceivedInImagePickerViewCell:)])
        [_delegate tapReceivedInImagePickerViewCell:self];
}

@end
