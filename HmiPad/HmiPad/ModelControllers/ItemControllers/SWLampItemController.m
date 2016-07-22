//
//  SWLampItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLampItemController.h"
#import "SWLampItem.h"
#import "SWLampView.h"

@implementation SWLampItemController
@synthesize lampView = _lampView;

- (void)loadView
{
    _lampView = [[SWLampView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view = _lampView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setLampView:nil];
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];

    SWLampItem *item = [self _lampItem];
    
    [_lampView setValue:item.value.valueAsBool animated:NO];
    [_lampView setBlink:item.blink.valueAsBool];
    [_lampView setColor:item.color.valueAsColor];
}

- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return YES;
}

#pragma mark - Private Methods

- (SWLampItem*)_lampItem
{
    return (SWLampItem*)self.item;
}


#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    SWLampItem *item = [self _lampItem];
    
    if (value == item.value) 
        [_lampView setValue:value.valueAsBool animated:YES];
        
    else if (value == item.blink)
        [_lampView setBlink:value.valueAsBool];
    
    else if (value == item.color)
        [_lampView setColor:value.valueAsColor];
        
    else
        [super value:value didEvaluateWithChange:changed];
}

@end
