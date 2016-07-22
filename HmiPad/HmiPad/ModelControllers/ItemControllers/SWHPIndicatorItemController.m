//
//  SWHPIndicatorItemController.m
//  HmiPad
//
//  Created by Joan Lluch on 6/23/13.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWHPIndicatorItemController.h"
#import "SWHPIndicatorView.h"
#import "SWHPIndicatorItem.h"
#import "SWColor.h"

@interface SWHPIndicatorItemController ()
{
    SWHPIndicatorView *_hpIndicatorView;
}

@end

@implementation SWHPIndicatorItemController

- (void)loadView
{
    _hpIndicatorView = [[SWHPIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view = _hpIndicatorView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _hpIndicatorView = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWHPIndicatorItem *item = [self _hpIndicatorItem];
    
    _hpIndicatorView.direction = item.direction.valueAsInteger;
    
    _hpIndicatorView.format = item.format.valueAsString;
    
    SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble) ;
    [_hpIndicatorView setRange:range animated:NO] ;
   
    [_hpIndicatorView setValue:item.value.valueAsDouble animated:NO] ;
    
    [self _updateRanges];
    [self _updateRangeColors];
   
    _hpIndicatorView.needleColor = item.needleColor.valueAsColor ;
    _hpIndicatorView.tintsColor = item.tintColor.valueAsColor;
}

#pragma mark - Private Methods

- (SWHPIndicatorItem*)_hpIndicatorItem
{
    return (SWHPIndicatorItem*)self.item;
}

- (void)_updateRanges
{
    SWHPIndicatorItem *item = [self _hpIndicatorItem];
    
    SWValue *ranges = item.ranges;
    NSInteger count = [ranges count];
    
    NSMutableData *rangesData = [NSMutableData dataWithCapacity:count*sizeof(SWValueRange)];
    [rangesData setLength:count*sizeof(SWValueRange)];
    SWValueRange *cRanges = [rangesData mutableBytes];
    
    for ( NSInteger i=0; i<count ;i++ )
    {
        SWValue *range = [ranges valueAtIndex:i]; // hi ha un overhead de creacio de SWValue
        cRanges[i] = [range valueAsSWValueRange];
    }

    [_hpIndicatorView setRanges:rangesData];
}

- (void)_updateRangeColors
{
    SWHPIndicatorItem *item = [self _hpIndicatorItem];
    
    SWValue *colors = item.rangeColors;
    NSInteger count = [colors count];
    
    NSMutableData *colorsData = [NSMutableData dataWithCapacity:count*sizeof(UInt32)];
    [colorsData setLength:count*sizeof(UInt32)];
    UInt32 *cRgbColors = [colorsData mutableBytes];
    
    for ( NSInteger i=0; i<count ;i++ )
    {
        SWValue *color = [colors valueAtIndex:i];  // hi ha un overhead de creacio de SWValues
        cRgbColors[i] = [color valueAsRGBColor];
    }

    [_hpIndicatorView setRangeRgbColors:colorsData];

}

#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWHPIndicatorItem *item = [self _hpIndicatorItem];
    
    if (value == item.value )
    {
        [_hpIndicatorView setValue:value.valueAsDouble animated:YES];
    }
    
    else if ( value == item.minValue || value == item.maxValue) 
    {
        SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble) ;
        [_hpIndicatorView setRange:range animated:YES] ;
    }
    
    else if (value == item.needleColor)
    {
        _hpIndicatorView.needleColor = value.valueAsColor ;
    }
    
    else if (value == item.tintColor)
    {
        _hpIndicatorView.tintsColor = value.valueAsColor ;
    }
    
    else if (value == item.borderColor)
    {
        _hpIndicatorView.borderColor = value.valueAsColor ;
    }
    
    else if (value == item.direction)
    {
        _hpIndicatorView.direction = value.valueAsInteger;
    }
    
    else if (value == item.format)
    {
        _hpIndicatorView.format = value.valueAsString;
    }
    
    else if ( value == item.ranges )
    {
        [self _updateRanges];
    }
    
    else if ( value == item.rangeColors )
    {
        [self _updateRangeColors];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
