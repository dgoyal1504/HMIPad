//
//  SWScaleItemController.h
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//


#import "SWScaleItemController.h"
#import "SWScaleView.h"
#import "SWScaleItem.h"
#import "SWColor.h"

#import "SWEnumTypes.h"

@implementation SWScaleItemController

@synthesize scaleView = _scaleView;

- (void)loadView
{
    _scaleView = [[SWScaleView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    self.view = _scaleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setScaleView:nil];
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWScaleItem *item = [self _scaleItem];
    
    [_scaleView setOrientation:item.orientation.valueAsInteger];
    
    [_scaleView setMajorTickInterval:item.majorTickInterval.valueAsDouble] ;
    [_scaleView setMinorTicksPerInterval:item.minorTicksPerInterval.valueAsDouble] ;
    
    SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble ) ;
    [_scaleView setRange:range animated:NO] ;
    
    [self _setFormat] ;
}

#pragma mark - Private Methods

- (SWScaleItem*)_scaleItem
{
    if ([self.item isKindOfClass:[SWScaleItem class]]) {
        return (SWScaleItem*)self.item;
    }
    
    return nil;
}

#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWScaleItem *item = [self _scaleItem];
    
    if ( value == item.minValue || value == item.maxValue )
    {
        SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble ) ;
        [_scaleView setRange:range animated:YES] ;
    } 
    else if ( value == item.majorTickInterval )
    {
        [_scaleView setMajorTickInterval:value.valueAsDouble] ;
    }
    else if (value == item.minorTicksPerInterval ) 
    {
        [_scaleView setMinorTicksPerInterval:value.valueAsDouble] ;
    }
    else if ( value == item.format )
    {
        [self _setFormat] ;
    }
    else if ( value == item.orientation )
    {
        [_scaleView setOrientation:value.valueAsInteger];   // nomes suportem left/right per ara
    }
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

- (void)_setFormat
{
    SWScaleItem *item = [self _scaleItem];
    SWExpression *expression = item.format ;
    NSString *format = [expression valueAsStringWithFormat:nil] ;
    //if ( format.length == 0 ) format = @"%g" ;
    [_scaleView setFormat:format] ;
}


@end
