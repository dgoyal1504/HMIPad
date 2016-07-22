//
//  SWCustomSelectButton.m
//  HmiPad
//
//  Created by Joan on 29/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWCustomHighlightedButton.h"

@implementation SWCustomHighlightedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _setupView];
    }
    return self;
}


- (void)awakeFromNib
{
    [self _setupView];
}

- (void)_setupView
{

}


- (void)setHighlighted:(BOOL)highlighted
{
    // tallem la execucio
}


- (void)setSelected:(BOOL)selected
{
    // tallem la execucio
}


- (void)setCustomHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
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
