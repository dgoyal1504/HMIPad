//
//  SWGaugeItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 01/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWGaugeItemController.h"
#import "SWGaugeView.h"
#import "SWGaugeItem.h"

#import "SWColor.h"


@implementation SWGaugeItemController

@synthesize gaugeView = _gaugeView ;


- (void)loadView
{
    _gaugeView = [[SWGaugeView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    self.view = _gaugeView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _gaugeView = nil ;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWGaugeItem *item = [self _gaugeItem];
    
    [_gaugeView setMajorTickInterval:item.majorTickInterval.valueAsDouble] ;
    [_gaugeView setMinorTicksPerInterval:item.minorTicksPerInterval.valueAsDouble] ;
    
    SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble ) ;
    [_gaugeView setRange:range animated:NO] ;
    [_gaugeView setValue:item.value.valueAsDouble animated:NO] ;

    [self _updateFormat];
    [self _updateOptions];
    [self _updateRanges];
    [self _updateRangeColors];
    
    [_gaugeView setLabelText:item.label.valueAsString];
    [_gaugeView setTintsColor:item.tintColor.valueAsColor];
    [_gaugeView setNeedleColor:item.needleColor.valueAsColor];
    [_gaugeView setBorderColor:item.borderColor.valueAsColor];
}


- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return YES;
}


- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
}


#pragma mark - Private Methods

- (SWGaugeItem*)_gaugeItem
{
    if ([self.item isKindOfClass:[SWGaugeItem class]]) {
        return (SWGaugeItem*)self.item;
    }
    
    return nil;
}


- (void)_updateFormat
{
    SWGaugeItem *item = [self _gaugeItem];
    NSString *format = [item.format valueAsStringWithFormat:nil] ;
    //if ( format.length == 0 ) format = @"%g" ;
    [_gaugeView setFormat:format] ;
}


- (void)_updateRanges
{
    SWGaugeItem *item = [self _gaugeItem];
    
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

    [_gaugeView setRanges:rangesData];
}

- (void)_updateRangeColors
{
    SWGaugeItem *item = [self _gaugeItem];
    
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

    [_gaugeView setRangeRgbColors:colorsData];

}



- (void)_updateOptions
{
    SWGaugeItem *item = [self _gaugeItem];
//    NSDictionary *defDict = [[item.options getDefaultValue] valueAsDictionary];
//    NSDictionary *dict = [item.options valueAsDictionary];
//    
//    [_gaugeView setAngleRange:_dictDoubleForKey(dict, defDict, @"angleRange")];
//    [_gaugeView setDeadAnglePosition:_dictDoubleForKey(dict, defDict, @"deadAnglePosition")];
    
    SWValue *optionsDict = item.options;
    
    [_gaugeView setAngleRange:[[optionsDict valueForStringKey:@"angleRange"] valueAsDouble]];
    [_gaugeView setDeadAnglePosition:[[optionsDict valueForStringKey:@"deadAnglePosition"] valueAsDouble]];

}



#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWGaugeItem *item = [self _gaugeItem];
    
    if ( value == item.value )
    {
        [_gaugeView setValue:value.valueAsDouble animated:YES] ;
    } 
    else if ( value == item.minValue || value == item.maxValue )
    {
        SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble ) ;
        [_gaugeView setRange:range animated:YES] ;
    }
    
    else if ( value == item.style )
    {
    
    }
    
    else if ( value == item.options )
    {
        [self _updateOptions];
    }
    
    else if ( value == item.majorTickInterval ) 
    {
        [_gaugeView setMajorTickInterval:value.valueAsDouble] ;
    }
    else if (value == item.minorTicksPerInterval ) 
    {
        [_gaugeView setMinorTicksPerInterval:value.valueAsDouble] ;
    }
    else if ( value == item.format )
    {
        [self _updateFormat] ;
    }
    else if ( value == item.label )
    {
        [_gaugeView setLabelText:value.valueAsString];
    }
    
    else if ( value == item.tintColor )
    {
        [_gaugeView setTintsColor:value.valueAsColor];
    }
    
    else if ( value == item.needleColor )
    {
        [_gaugeView setNeedleColor:value.valueAsColor];
    }
    
    else if ( value == item.borderColor )
    {
        [_gaugeView setBorderColor:value.valueAsColor];
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

