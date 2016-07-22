//
//  SWArrayPickerItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWSegmentedControlItemController.h"

#import "SWTouchUpSegmentedControl.h"
#import "SWSegmentedControlItem.h"
#import "SWEnumTypes.h"

#import "SWColor.h"


@interface SWSegmentedControlItemController()<UIPopoverControllerDelegate>

@property (nonatomic,retain) SWTouchUpSegmentedControl *segmented;

@end


@implementation SWSegmentedControlItemController
{
 //   UIPopoverController *_popover;
}

@synthesize segmented = _segmented;

- (void)loadView
{
    _segmented = [[SWTouchUpSegmentedControl alloc] init];
    [_segmented setFrame:CGRectMake(0,0,100,100)];
    [_segmented setToggleControl:YES];
    [_segmented setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_segmented addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    //[_segmented setSegmentedControlStyle:UISegmentedControlStyleBar];
    self.view = _segmented;
}

- (void)viewDidUnload
{
    _segmented = nil;
    [super viewDidUnload];
}


#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateActivedState];
    [self _updateView];
}


#pragma mark - Main Methods

- (void)_checkPointForValue:(NSInteger)index
{
    SWSegmentedControlItem *item = [self _segmentedItem];
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL verified, BOOL success)
    {
        if ( success )
        {
            [item.value evalWithConstantValue:(double)index];
        }
        else
        {
            [item.continuousValue evalWithValue:item.value];   // tornem al valor original
            [theSelf _updateValue];    // updatem el view
        }
    }];
}


- (void)segmentedChanged:(id)sender
{
    SWSegmentedControlItem *item = [self _segmentedItem];
    
    NSInteger index = [_segmented selectedSegmentIndex];
    
    [item.continuousValue evalWithDouble:(double)index];   // posem el valor temporal
    
    [self _checkPointForValue:index];
}



#pragma mark - Private Methods

- (SWSegmentedControlItem*)_segmentedItem
{
    return (SWSegmentedControlItem*)self.item;
}

- (void)_updateView
{
    [self _updateEnabledState];
    [self _updateArray];
    [self _updateValue];
    [self _updateColor];
}


- (void)_updateValue
{
    SWSegmentedControlItem *item = [self _segmentedItem];
    NSInteger index = [item.value valueAsInteger];
    
    [_segmented setSelectedSegmentIndex:index];
}


- (void)_updateArray
{
    SWSegmentedControlItem *item = [self _segmentedItem];

    SWValue *values = item.array;
    NSInteger count = [values count];
    NSInteger segmentedCount = [_segmented numberOfSegments];
    
    NSString *format = [item.format valueAsString];
    
    BOOL newSegments = (segmentedCount != count);
    if ( newSegments )
        [_segmented removeAllSegments];
    
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        SWValue *value = [values valueAtIndex:i];
        NSString *option = [value valueAsStringWithFormat:format];        
        
        if ( newSegments ) [_segmented insertSegmentWithTitle:option atIndex:i animated:NO];
        else [_segmented setTitle:option forSegmentAtIndex:i];
    }
}

- (void)_updateColor
{
    SWSegmentedControlItem *item = [self _segmentedItem];
    
    UIColor *color = [item.color valueAsColor];
    [_segmented setTintColor:color];
}


- (void)_updateActivedState
{
    SWSegmentedControlItem *item = [self _segmentedItem];

    BOOL active = [item.active valueAsBool];
    [_segmented setUserInteractionEnabled:active];
}


- (void)_updateEnabledState
{
    SWSegmentedControlItem *item = [self _segmentedItem];

    BOOL enabled = [item.enabled valueAsBool];
    [_segmented setEnabled:enabled];
}


#pragma mark - SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWSegmentedControlItem *item = [self _segmentedItem];
    
    if (value == item.value )
    {
        [self _updateValue];
    }
    
    else if (value == item.array || value == item.format)
    {
        [self _updateArray];
    }
    
    else if (value == item.color)
    {
        [self _updateColor];
    }
    
    
    else if (value == item.enabled) 
    {
        [self _updateEnabledState];
    }
    
    else if (value == item.active)
    {
        [self _updateActivedState];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
