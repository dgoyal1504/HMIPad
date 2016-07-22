//
//  SWFileViewerProgressView.m
//  HmiPad
//
//  Created by Joan on 09/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerProgressView.h"
#import "SWColor.h"

@implementation SWFileViewerProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ( IS_IOS7 )
    {
        [_labelFile setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [_labelFile setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
        [_labelFile setShadowColor:[UIColor whiteColor]];
        
//        [_progresView setProgressTintColor:UIColorWithRgb(SystemDarkerBlueColor)];
        [_progresView setTrackTintColor:[UIColor clearColor]];
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
