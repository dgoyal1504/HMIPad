//
//  SWNavBarTitleView.m
//  HmiPad
//
//  Created by Joan on 11/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWNavBarTitleView.h"
#import "SWColor.h"

@implementation SWNavBarTitleView

- (id)init0
{
    self = [super init];
    if (self)
    {
        UINib *nib = [UINib nibWithNibName:@"SWNavBarTitleView" bundle:nil];
        NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];
        id object = [topLevelObjects objectAtIndex:0];
        if ( [object isKindOfClass:[SWNavBarTitleView class]] ) self = object;
        else self = nil;
    }
    return self;
}


- (id)init
{
    UINib *nib = [UINib nibWithNibName:@"SWNavBarTitleView" bundle:nil];
    NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];
    id object = [topLevelObjects objectAtIndex:0];
    
    if ( ![object isKindOfClass:[SWNavBarTitleView class]] )
        return nil;
    
    self = object;
//    if ( IS_IOS7 )
//    {
//        //[_mainLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
//        [_mainLabel setFont:[UIFont boldSystemFontOfSize:17]];
//        [_secondaryLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//    }
    return self;
}


- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize size1 = [_mainLabel sizeThatFits:_mainLabel.bounds.size];
    CGSize size2 = [_secondaryLabel sizeThatFits:_secondaryLabel.bounds.size];
    
    CGSize result = CGSizeMake(size1.width, 44);
    if ( size2.width > size1.width ) result.width = size2.width;
    if ( result.width > 220 ) result.width = 220;
    return result;
}

- (void)setTintsColor:(UIColor *)tintColor
{
    _mainLabel.textColor = tintColor;
    _secondaryLabel.textColor = tintColor;
    
    UIColor *contrastColor = contrastColorForUIColor(tintColor);
    
    // TODO fer un metode per aixo i utilitzar-lo en appearance. 
    _mainLabel.shadowColor = contrastColor; //[UIColor whiteColor];
    _mainLabel.shadowOffset = CGSizeMake(0,1);
    _secondaryLabel.shadowColor = contrastColor ; //[UIColor whiteColor];
    _secondaryLabel.shadowOffset = CGSizeMake(0,1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
