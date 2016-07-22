//
//  SWFileViewerAccessCodeCell.m
//  HmiPad
//
//  Created by Joan on 28/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerRemoteActivationCodeCell.h"

@implementation SWFileViewerRemoteActivationCodeCell


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        _shouldIndentImageWhileEditing = NO;
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    if ( IS_IOS7 )
    {
        [_labelProjectID setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [_labelRedemptions setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    }
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
