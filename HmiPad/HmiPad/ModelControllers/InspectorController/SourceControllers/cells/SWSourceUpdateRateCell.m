//
//  SWSourceUpdateRateCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSourceUpdateRateCell.h"

@interface SWSourceUpdateRateCell (Private)

- (void)_pollUpdate:(NSNotification*)notification;

@end

@implementation SWSourceUpdateRateCell

@synthesize cpsLabel = _cpsLabel;
@synthesize rpsLabel = _rpsLabel;
@synthesize cpsProgressView = _cpsProgressView;
@synthesize rpsProgressView = _rpsProgressView;

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


- (void)connectToSourceItem
{
    [self _pollUpdate:nil];
}


- (void)startObserving
{
    [super startObserving];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_pollUpdate:) name:kFinsPollUpdateNotification object:_sourceItem];
    
    //[self _pollUpdate:nil];
}

- (void)stopObserving
{
    [super stopObserving];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc removeObserver:self name:nil object:self.sourceItem];
    [nc removeObserver:self];
}

@end

@implementation SWSourceUpdateRateCell (Private)

- (void)_pollUpdate:(NSNotification*)notification
{
    float cps = _sourceItem.commandsPerSecond ;
    float rps = _sourceItem.readsPerSecond ;
    float poll = _sourceItem.pollInterval ;
    
    if ( poll == 0 ) 
        poll = 1/100.0f ;
    
    _cpsLabel.text = [NSString stringWithFormat:@"%1.2f cps", cps] ;
    _rpsLabel.text = [NSString stringWithFormat:@"%1.2f rps", rps] ;
    [_cpsProgressView setProgress:rps/cps animated:YES] ;
    [_rpsProgressView setProgress:rps*poll animated:YES] ;
}
@end