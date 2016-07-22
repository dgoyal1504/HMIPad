//
//  SWDeleteButtonView.m
//  HmiPad
//
//  Created by Joan on 18/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#define UseColoredButton true


#import "SWDeleteButtonView.h"

#if UseColoredButton
#import "ColoredButton.h"
#endif

@implementation SWDeleteButtonView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        // Initialization code
//    }
//    return self;
//}


#if UseColoredButton

- (id)init
{
    self = [super initWithFrame:CGRectMake(0,0,320,100)];
    if ( !self )
        return nil;

    const CGFloat hGap = 10.0f;
    const CGFloat vGap = 20.0f;
    ColoredButton *_button = [[ColoredButton alloc] init];;
    _button.frame = CGRectMake(hGap, vGap, 320-2*hGap, 44);
    _button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    [_button setTitle:NSLocalizedString(@"Delete User", nil) forState:UIControlStateNormal];
    [_button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [_button setRgbTintColor:0xc00000 overWhite:YES];
    
    [_button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];

    return self;
}

#else

- (id)init
{
    self = [super initWithFrame:CGRectMake(0,0,320,100)];
    if ( !self )
        return nil;
    
    UIImage *image = [UIImage imageNamed:@"UIPreferencesDeleteButtonNormal.png"];
    CGSize imageSize = image.size;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, imageSize.width/2, 0, imageSize.width/2);
    image = [image resizableImageWithCapInsets:insets];
    
    UIImage *image2 = [UIImage imageNamed:@"UIPreferencesDeleteButtonPressed.png"];
    CGSize imageSize2 = image.size;
    UIEdgeInsets insets2 = UIEdgeInsetsMake(0, imageSize2.width/2, 0, imageSize2.width/2);
    image2 = [image2 resizableImageWithCapInsets:insets2];

    const CGFloat hGap = 10.0f;
    const CGFloat vGap = 20.0f;
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(hGap, vGap, 320-2*hGap, imageSize.height);
    _button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    [_button setBackgroundImage:image forState:UIControlStateNormal];
    [_button setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [_button setTitle:NSLocalizedString(@"Delete User", nil) forState:UIControlStateNormal];
    [_button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_button.titleLabel setShadowOffset:CGSizeMake(0,-1)];
    
    [_button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    
    return self;
}

#endif

- (void)buttonTouched:(id)sender
{
    [_delegate deleteButtonViewDidTouch:self];
}


@end
