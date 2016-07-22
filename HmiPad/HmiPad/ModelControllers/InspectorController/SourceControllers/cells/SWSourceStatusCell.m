//
//  SWSourceStatusCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSourceStatusCell.h"

#import "SWSourceItem.h"
#import "SWColor.h"

@interface SWSourceStatusCell ()

- (void)_sourceItemStatusChanged:(NSNotification*)notification;

@end

@implementation SWSourceStatusCell
@synthesize statusLabel = _statusLabel;

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
    [self _sourceItemStatusChanged:nil];
}


- (void)startObserving
{
    [super startObserving];

    //SWSourceItem *sourceItem = self.sourceItem;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(_sourceItemStatusChanged:) name:kFinsStateDidChangeNotification object:_sourceItem];
}

- (void)stopObserving
{
    [super stopObserving];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark - Private Methods

- (void)_sourceItemStatusChanged:(NSNotification*)notification
{
    [_statusLabel setTextColor:_sourceItem.statusColor] ;
    [_statusLabel setText:_sourceItem.statusDescription];
}

@end
