//
//  SWEnableSourceCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWEnableSourceCell.h"
#import "SWSourceItem.h"

@interface SWEnableSourceCell ()

//- (void)_sourceItemStateChanged:(NSNotification*)notification;

@end

@implementation SWEnableSourceCell

@synthesize enableSourceSwitch = _enableSourceSwitch;

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
    [super connectToSourceItem];
    
    [_enableSourceSwitch setOn:_sourceItem.monitorOn];
    _enableSourceSwitch.enabled = _sourceItem.docModel.enableConnections;
}

- (void)startObserving
{
    [super startObserving];
    
    [_sourceItem.docModel addObserver:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(_sourceItemStatusChanged:) name:kFinsStateDidChangeNotification object:_sourceItem];
}

- (void)stopObserving
{
    [super stopObserving];
    
    [_sourceItem.docModel removeObserver:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (IBAction)switchChanged:(id)sender
{
    BOOL monitor = [sender isOn];
    [_sourceItem setMonitorState:monitor];
}

#pragma mark - Private Methods

- (void)_sourceItemStatusChanged:(NSNotification*)notification
{
    [_enableSourceSwitch setOn:_sourceItem.monitorOn animated:YES] ;
}


#pragma mark - DocumentModel Observer

- (void)documentModelEnableConnectionsDidChange:(SWDocumentModel *)docModel
{
    _enableSourceSwitch.enabled = docModel.enableConnections;
}

@end
