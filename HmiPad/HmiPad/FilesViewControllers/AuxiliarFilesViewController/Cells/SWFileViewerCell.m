//
//  SWFileViewCell.m
//  HmiPad
//
//  Created by Joan on 08/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerCell.h"
#import "ColoredButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWColor.h"

NSString * const SWFileViewerCellIdentifier = @"SWFileViewerCellIdentifier";

NSString * const SWFileViewerCurrentProjectCellIdentifier = @"SWFileViewerCurrentProjectCellIdentifier";
NSString * const SWFileViewerProjectCellIdentifier = @"SWFileViewerProjectCellIdentifier";
NSString * const SWFileViewerRemoteProjectCellIdentifier = @"SWFileViewerRemoteProjectCellIdentifier";
NSString * const SWFileViewerRemoteAssetCellIdentifier = @"SWFileViewerRemoteAssetCellIdentifier";
NSString * const SWFileViewerRemoteActivationCodeCellIdentifier = @"SWFileViewerRemoteActivationCodeCellIdentifier";
NSString * const SWFileViewerRemoteRedemptionCellIdentifier = @"SWFileViewerRemoteRedemptionCellIdentifier";


@implementation SWFileViewerCell
{
    UITableViewCellStateMask _state;
    CGRect _baseImageFrame;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        _shouldIndentImageWhileEditing = YES;
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    _baseImageFrame = _buttonImage.frame;
    
//    UIView *view = _buttonImage;
//    CALayer *layer = view.layer;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
//    layer.shadowPath = shadowPath.CGPath;
//    layer.shadowOffset = CGSizeMake(0, 0);
//    layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
//    layer.shadowRadius = 2.5f ;
//    layer.shadowOpacity = 1;


//    // posem borde i color al imageview del boto
//    CALayer *layer = _buttonImage.imageView.layer;
//    layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
//    layer.borderWidth = 1;
//    layer.cornerRadius = 5;
//    layer.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1].CGColor;
//    layer.masksToBounds = YES;
//
//    // rasteritzem el boto per guanyar performance
//    CALayer *bLayer = _buttonImage.layer;
//    bLayer.shouldRasterize = YES;
//    bLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [self setShouldApplyImageBorder:NO];
    
    UIImage *image = [[UIImage imageNamed:@"258-checkmark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    _imageViewTick.image = image;
//    _imageViewTick.hidden = YES;
    
    [_buttonTick setImage:image forState:UIControlStateNormal];
//    [_buttonTick setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
//    [_buttonTick setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
    
//    CGRect bounds = _buttonTick.bounds;
//    _buttonTick.layer.cornerRadius = _buttonTick.bounds.size.width / 2.0f;
//    _buttonTick.clipsToBounds = YES;
//    [_buttonTick setBackgroundColor:[UIColor redColor]];
    
//    UIImage *backImage = glossyImageWithSizeAndColor(bounds.size, [UIColor clearColor].CGColor, 3, NO, bounds.size.width/2, 1);
//    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    
//    [_buttonTick setBackgroundImage:backImage forState:UIControlStateNormal];
    
   // [_buttonReveal.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ( [_labelFileName respondsToSelector:@selector(setVerticalAlignment:)] )
        [_labelFileName setVerticalAlignment:VerticalAlignmentBottom];
    
    _buttonImage.backgroundColor = [UIColor clearColor];

//    if ( IS_IOS7 )
//    {
//        [_labelFileName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
//        [_labelFileIdent setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//        [_labelModDate setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//        [_labelSize setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self _showButtonForEditingState:editing];
}


- (void)setShouldHideButton:(BOOL)shouldHideButton
{
    _shouldHideButton = shouldHideButton;
    if ( shouldHideButton ) [_buttonInclude setHidden:YES];
    else [self _showButtonForEditingState:[self isEditing]];
}


- (void)setShouldHideButtonReveal:(BOOL)shouldHideButton
{
    _shouldHideButtonReveal = shouldHideButton;
    if ( shouldHideButton ) [_buttonReveal setHidden:YES];
    else [self _showButtonForEditingState:[self isEditing]];
}


- (void)setShouldHideButtonTick:(BOOL)shouldHideButton
{
    _shouldHideButtonTick = shouldHideButton;
    if ( shouldHideButton ) [_buttonTick setHidden:YES];
    else [self _showButtonForEditingState:[self isEditing]];
    
}


- (void)setShouldApplyImageBorder:(BOOL)shouldApplyImageBorder
{
    if ( _shouldApplyImageBorder == shouldApplyImageBorder )
        return;
    
    _shouldApplyImageBorder = shouldApplyImageBorder;
    if ( shouldApplyImageBorder )
    {
        // posem borde i color al imageview del boto
        CALayer *layer = _buttonImage.imageView.layer;
        //layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;

        layer.borderColor = [UIColor colorWithWhite:0.33 alpha:1.0].CGColor;
        layer.borderWidth = 1;
        layer.cornerRadius = 5;
        //layer.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1].CGColor;
        //layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
        layer.backgroundColor = checkeredBackgroundColor().CGColor;
        layer.masksToBounds = YES;

        // rasteritzem el boto per guanyar performance
        CALayer *buttonLayer = _buttonImage.layer;
        buttonLayer.shouldRasterize = YES;
        buttonLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    else
    {
        CALayer *layer = _buttonImage.imageView.layer;
        layer.borderColor = nil;
        layer.borderWidth = 0;
        layer.cornerRadius = 0;
        layer.backgroundColor = nil; //[UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1].CGColor;
        layer.masksToBounds = NO;
    
        CALayer *bLayer = _buttonImage.layer;
        bLayer.shouldRasterize = NO;
    }
}


- (void)_showButtonForEditingState:(BOOL)editing
{
    if ( !_shouldHideButton )
    {
        [_buttonInclude setHidden:editing];
        //[_buttonInclude setEnabled:!editing];
        [_buttonImage setUserInteractionEnabled:!editing];
    }
    
    if ( !_shouldHideButtonReveal)
    {
        [_buttonReveal setHidden:editing];
    }
    
    if ( !_shouldHideButtonTick)
    {
        [_buttonTick setHidden:editing];
    }
}

- (IBAction)buttonRevealTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(fileViewCellDidTouchRevealButton:)] )
        [_delegate fileViewCellDidTouchRevealButton:self];
}

- (IBAction)buttonIncludeTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(fileViewCellDidTouchIncludeButton:)] )
        [_delegate fileViewCellDidTouchIncludeButton:self];
}


- (IBAction)buttonImageTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(fileViewCellDidTouchImageButton:)] )
        [_delegate fileViewCellDidTouchImageButton:self];
}


//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext() ;
//    
//    UIColor *color1 = [UIColor colorWithWhite:1.0f alpha:1.0f];
//    UIColor *color2 = [UIColor colorWithWhite:0.8f alpha:1.0f];
//    
//    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5 ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5 ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, [color1 CGColor]) ;
//    CGContextStrokePath( context ) ;
//    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5 ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5 ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, [color2 CGColor]) ;
//    CGContextStrokePath( context ) ;
//    
//    [super drawRect:rect] ;
//}


//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
////    UIView *contentView = self.contentView;
////    CGRect rect = contentView.frame;
//    
//    CGRect labelSizRect = _labelSize.frame;
//    CGRect labelModDateRect = _labelModDate.frame;
//    CGRect buttonRect = _buttonInclude.frame;
//    
//    [_buttonInclude sizeToFit];
//    CGRect buttonRect2 = _buttonInclude.frame;
//    buttonRect2.size.width += 20;
//    
//    CGFloat displacement = buttonRect2.origin.x + buttonRect2.size.width - buttonRect.origin.x - buttonRect.size.width;
//    buttonRect2.origin.x -= displacement;
//    
//    labelSizRect.size.width -= displacement;
//    labelModDateRect.size.width -= displacement;
//    
//    _buttonInclude.frame = buttonRect2;
//    _labelSize.frame = labelSizRect;
//    _labelModDate.frame = labelModDateRect;
//}





- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( _shouldIndentImageWhileEditing )
    {
        //CGRect rect = _buttonImage.frame;
        CGRect rect = _baseImageFrame;

        CGFloat indentPoints = 0;
        if ( self.editing && (_state & UITableViewCellStateShowingEditControlMask) )
        {
            indentPoints = 5 ;
        }
    
        rect.origin.x += indentPoints;
        _buttonImage.frame = rect ;
    }
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    UIView *contentView = self.contentView;
//    CGRect rect = contentView.frame;
//
//    CGFloat indentPoints = 0;
//    if ( self.editing && (_state & UITableViewCellStateShowingEditControlMask) )
//    {
//        indentPoints = 40 ;
//    }
//    
//    rect.size.width = rect.origin.x + rect.size.width - indentPoints;
//    rect.origin.x = indentPoints;
//    contentView.frame = rect ;
//}

- (void)willTransitionToState:(UITableViewCellStateMask)aState
{
    [super willTransitionToState:aState];
    _state = aState;
}

@end
