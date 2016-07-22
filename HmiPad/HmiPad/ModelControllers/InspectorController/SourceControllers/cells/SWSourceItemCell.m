//
//  SWSourceItemCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSourceItemCell.h"

#import "SWSourceItem.h"

@implementation SWSourceItemCell

@synthesize sourceItem = _sourceItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    
//    if (newSuperview == nil)
//        [self stopObserving];
//    else
//        [self startObserving];
//}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil)  // woraround al radar 12307048 (https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa)
    {
        [self endObservingModel];
    }
}

- (void)setSourceItem:(SWSourceItem *)sourceItem
{    
    [self disconnectFromSourceItem];
    
    _sourceItem = sourceItem;
    
    [self connectToSourceItem];
}

- (void)beginObservingModel
{
    if ( !_isObserving )
    {
        _isObserving = YES;
        //NSLog( @"begin observing cell: %08x", (int)self);
        [self startObserving];
    }
}

- (void)endObservingModel
{
    if ( _isObserving )
    {
        _isObserving = NO;
        //NSLog( @"end observing cell: %08x", (int)self);
        [self stopObserving];
    }
}

- (void)startObserving
{
    //nothing
}

- (void)stopObserving
{
    //nothing
}

- (void)connectToSourceItem
{
 
}

- (void)disconnectFromSourceItem
{
    
}

- (void)dealloc
{
//    NSLog( @"SourceItemCell dealloc" ) ;
}

@end
