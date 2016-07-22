//
//  SWKnobItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 26/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWKnobItemController.h"
#import "SWKnobControl.h"
#import "SWKnobItem.h"

@interface SWKnobItemController()
@property (nonatomic,readonly) SWKnobItem *item;
@end

@implementation SWKnobItemController

@synthesize knobControl = _knobControl ;

- (void)loadView
{
    _knobControl = [[SWKnobControl alloc] initWithFrame:CGRectMake(0,0,100,100)];
    self.view = _knobControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_knobControl addTarget:self action:@selector(knobValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_knobControl addTarget:self action:@selector(knobValueEnded:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
}

- (void)viewDidUnload
{
    _knobControl = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWKnobItem *item = self.item; //[self _knobItem];
    
    [_knobControl setEnabled:item.enabled.valueAsBool];
    [_knobControl setThumbStyle:item.thumbStyle.valueAsInteger];
    [_knobControl setMajorTickInterval:item.majorTickInterval.valueAsDouble] ;
    [_knobControl setMinorTicksPerInterval:item.minorTicksPerInterval.valueAsDouble] ;
    
    SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble ) ;
    [_knobControl setRange:range animated:NO] ;
    [_knobControl setValue:item.value.valueAsDouble animated:NO] ;
    
    [_knobControl setLabelText:item.label.valueAsString];
      
    [_knobControl setTintsColor:item.tintColor.valueAsColor];
    [_knobControl setNeedleColor:item.thumbColor.valueAsColor];
    [_knobControl setBorderColor:item.borderColor.valueAsColor];
    
    [self _setFormat] ;
}

- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return YES;
}

#pragma mark - Main Methods

- (void)_checkPointForValue:(double)value
{
    SWKnobItem *item = self.item;
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL verified, BOOL success)
    {
        if ( success )
        {
            [item.value evalWithConstantValue:value];
        }
        else
        {
            [item.continuousValue evalWithValue:item.value];   // tornem al valor original
            [_knobControl setValue:item.value.valueAsDouble animated:YES] ; // updatem el view
        }
    }];
}

- (void)knobValueChanged:(id)sender
{
    SWKnobItem *item = self.item; //[self _knobItem];
    double value = [_knobControl value];
    [item.continuousValue evalWithDouble:value];
    
    //[item.value evalWithConstantValue:value];
}


- (void)knobValueEnded:(id)sender
{
    double value = [_knobControl value];
    [self _checkPointForValue:value];
}

#pragma mark - Private Methods

//- (SWKnobItem*)_knobItem
//{
//    if ([self.item isKindOfClass:[SWKnobItem class]]) {
//        return (SWKnobItem*)self.item;
//    }
//    
//    return nil;
//}

#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWKnobItem *item = self.item; //[self _knobItem];
    
    if ( value == item.value )
        [_knobControl setValue:value.valueAsDouble animated:YES] ;
    
    else if ( value == item.minValue || value == item.maxValue )
    {
        SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble ) ;
        [_knobControl setRange:range animated:YES] ;
    } 
    else if ( value == item.majorTickInterval )
        [_knobControl setMajorTickInterval:value.valueAsDouble] ;
    
    else if (value == item.minorTicksPerInterval )
        [_knobControl setMinorTicksPerInterval:value.valueAsDouble] ;
    
    else if ( value == item.format )
        [self _setFormat] ;
    
    else if ( value == item.style )
    {
        // TO DO
    }
    else if ( value == item.thumbStyle )
        [_knobControl setThumbStyle:value.valueAsInteger];
    
    else if ( value == item.label )
        [_knobControl setLabelText:value.valueAsString];
    
    else if ( value == item.thumbColor )
        [_knobControl setNeedleColor:value.valueAsColor];
    
    else if ( value == item.tintColor )
        [_knobControl setTintsColor:value.valueAsColor];
    
    else if ( value == item.borderColor )
        [_knobControl setBorderColor:value.valueAsColor];
    
    else if ( value == item.enabled )
        [_knobControl setEnabled:item.enabled.valueAsBool];
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

- (void)_setFormat
{
    SWKnobItem *item = self.item; //[self _knobItem];
    NSString *format = [item.format valueAsStringWithFormat:nil] ;
    //if ( format.length == 0 ) format = @"%g" ;
    [_knobControl setFormat:format] ;
}

@end

