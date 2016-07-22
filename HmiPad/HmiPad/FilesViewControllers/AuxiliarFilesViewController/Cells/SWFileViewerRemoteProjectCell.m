//
//  SWFileViewerProjectCell.m
//  HmiPad
//
//  Created by Joan on 28/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerRemoteProjectCell.h"

@implementation SWFileViewerRemoteProjectCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        _shouldIndentImageWhileEditing = NO;
    }
    return self;
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
