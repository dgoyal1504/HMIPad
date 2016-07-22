//
//  SWBarLevelItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWBarLevelItemController.h"
#import "SWBarLevelView.h"
#import "SWBarLevelItem.h"
#import "SWColor.h"

@interface SWBarLevelItemController ()
{
    SWBarLevelView *_barLevelView;
}

@end

@implementation SWBarLevelItemController

- (void)loadView
{
    _barLevelView = [[SWBarLevelView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view = _barLevelView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _barLevelView = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWBarLevelItem *item = [self _barLevelItem];
    
    //[self _updateDirection];
    _barLevelView.direction = item.direction.valueAsInteger;
    
    //[self _updateFormat];
    _barLevelView.format = item.format.valueAsString;
    [self _updateRangeAnimated:NO] ;
   
   // [self _updateValueAnimated:NO];
    [_barLevelView setValue:item.value.valueAsDouble animated:NO] ;
   
     //[self _updateColor];
    _barLevelView.barColor = item.barColor.valueAsColor ;
    _barLevelView.borderColor = item.borderColor.valueAsColor;
    _barLevelView.tintsColor = item.tintColor.valueAsColor;
}

//- (void)refreshZoomScaleFactor:(CGFloat)zoomScaleFactor
//{
//    [super refreshZoomScaleFactor:zoomScaleFactor];
//    [_barLevelView setContentScaleFactor:[[UIScreen mainScreen]scale]*zoomScaleFactor];
//}

#pragma mark - Private Methods

- (SWBarLevelItem*)_barLevelItem
{
    if ([self.item isKindOfClass:[SWBarLevelItem class]]) {
        return (SWBarLevelItem*)self.item;
    }
    
    return nil;
}

////- (void)_updateValueAnimated:(BOOL)animated
//{
//    SWBarLevelItem *item = [self _barLevelItem];
//    [_barLevelView setValue:item.value.valueAsDouble animated:animated] ;
//}

- (void)_updateRangeAnimated:(BOOL)animated
{
    SWBarLevelItem *item = [self _barLevelItem];
    SWRange range = SWRangeMake( item.minValue.valueAsDouble, item.maxValue.valueAsDouble) ;
    [_barLevelView setRange:range animated:animated] ;
}

//- (void)_updateColor
//{
//    SWBarLevelItem *item = [self _barLevelItem];
//    _barLevelView.barColor = item.barColor.valueAsColor ;
//}

//- (void)_updateDirection
//{
//    SWBarLevelItem *item = [self _barLevelItem];
//    _barLevelView.direction = item.direction.valueAsInteger;
//}

//- (void)_updateFormat
//{
//    SWBarLevelItem *item = [self _barLevelItem];
//    _barLevelView.format = item.format.valueAsString;
//}

#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWBarLevelItem *item = [self _barLevelItem];
    
    if (value == item.value )
    {
        [_barLevelView setValue:value.valueAsDouble animated:YES];
    }
    
    else if ( value == item.minValue || value == item.maxValue) 
    {
        [self _updateRangeAnimated:YES];
    }
    
    else if (value == item.barColor)
    {
        _barLevelView.barColor = value.valueAsColor ;
    }
    
    else if (value == item.tintColor)
    {
        _barLevelView.tintsColor = value.valueAsColor ;
    }
    
    else if (value == item.borderColor)
    {
        _barLevelView.borderColor = value.valueAsColor ;
    }
    
    else if (value == item.direction)
    {
        //[self _updateDirection];
        _barLevelView.direction = value.valueAsInteger;
    }
    
    else if (value == item.format)
    {
        //[self _updateFormat];
        _barLevelView.format = value.valueAsString;
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
