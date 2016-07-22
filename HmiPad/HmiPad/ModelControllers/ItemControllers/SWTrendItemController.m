//
//  SWTrendItemController.m
//  HmiPad
//
//  Created by Joan on 29/04/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWTrendItemController.h"
#import "SWTrendView.h"
#import "SWTrendItem.h"
#import "SWColor.h"
#import "SWDatabaseContext.h"

#import <QuartzCore/QuartzCore.h>
@interface SWTrendItemController ()<SWTrendViewDataSource,SWTrendViewDelegate>

- (SWTrendItem*)_trendItem;

@end

@implementation SWTrendItemController

@synthesize trendView = _trendView;

- (void)loadView
{
    _trendView = [[SWTrendView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    self.view = _trendView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _trendView.dataSource = self ;
    _trendView.delegate = self ;
}

- (void)viewDidUnload
{
    [self setTrendView:nil];
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWTrendItem *item = [self _trendItem] ;
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    
    for ( PlotData *plotData in plotGroup.plots )
    {
        id ident = plotData.plotKey ;
        [_trendView addPlotWithIdentifier:ident] ;
    }
    
    
    [_trendView setUpdatingStyle:item.updatingStyle.valueAsInteger];
    [_trendView setStyle:item.style.valueAsInteger];
    
    [_trendView setGesturesEnabled:item.enableGestures.valueAsBool];
    
    [_trendView setXMinorTicksPerInterval:item.xMinorTicksPerInterval.valueAsDouble] ;
    [_trendView setXMajorTickInterval:item.xMajorTickInterval.valueAsDouble] ;
    
    [_trendView setYMinorTicksPerInterval:item.yMinorTicksPerInterval.valueAsDouble] ;
    [_trendView setYMajorTickInterval:item.yMajorTickInterval.valueAsDouble] ;
    
    [_trendView setXPlotInterval:item.plotInterval.valueAsDouble] ;
    [_trendView setXRangeOffset:item.intervalOffset.valueAsDouble] ;
    
    [_trendView setTintsColor:item.tintColor.valueAsColor];
    [_trendView setBorderColor:item.borderColor.valueAsColor];
    
    [self _setGlobalYRangeAnimated:NO] ;
    [self _setPlotColors] ;
    [self _updateOptions];
    [self _updateTimeRange];
}



#pragma mark - view Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_trendView resetViewUpdating] ;
}

- (void)viewWillDisappear:(BOOL)animated
{    
    [super viewWillDisappear:animated];
    [_trendView stopViewUpdating] ;
    [_trendView removeAllPlots] ;
}



#pragma mark - Private Methods


- (void)dealloc
{
    //NSLog( @"trendController dealloc" ) ; // if ( _reLoadTimer ) dispatch_source_cancel( _reLoadTimer ) ;
}


- (SWTrendItem*)_trendItem
{
    if ([self.item isKindOfClass:[SWTrendItem class]]) {
        return (SWTrendItem*)self.item;
    }
    
    return nil;
}

- (SWBounds)_yRange
{
    SWTrendItem *item = [self _trendItem] ;
    SWBounds yRange = SWBoundsMake(item.yMin.valueAsDouble, item.yMax.valueAsDouble) ;
    return yRange ;
}

- (PlotGroup*)_mainPlotGroup
{
    SWTrendItem *item = [self _trendItem] ;
    NSArray *plotGroups = item.plotGroups ;
    PlotGroup *plotGroup = nil ;
    if ( plotGroups.count > 0 ) plotGroup = [item.plotGroups objectAtIndex:0] ;
    return plotGroup ;
}

- (void)_setGlobalYRangeAnimated:(BOOL)animated
{
    SWBounds yRange = [self _yRange] ;
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    [_trendView setYAxisRange:yRange animated:animated] ;
    for ( PlotData *plotData in plotGroup.plots )
    {
        id ident = plotData.plotKey ;
        [_trendView setYRange:yRange forPlotWithIdentifier:ident animated:animated] ;
       // [_trendView reloadPlotWithIdentifier:ident] ;
    }
    [_trendView reloadPlotsAnimated:animated];
}


- (void)_setColorToPlotData:(PlotData*)plotData value:(SWValue*)value
{
    UIColor *color ;
    id ident = plotData.plotKey ;
    if ( value == nil ) color = UIColorWithRgb( plotData.plotRgbColor ) ;
    else color = [value valueAsColor] ;
    [_trendView setColor:color forPlotWithIdentifier:ident] ;
}

- (void)_setPlotColors
{
    SWTrendItem *item = [self _trendItem] ;
    SWExpression *colorsExpression = item.colors ;
    
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    
    int i=0 ;
    for ( PlotData *plotData in plotGroup.plots )
    {
        SWValue *value = [colorsExpression valueAtIndex:i++] ;  // pot ser nil
        [self _setColorToPlotData:plotData value:value] ;
    }
}


//- (void)_setColorFillToPlotData:(PlotData*)plotData value:(SWValue*)value
//{
//    id ident = plotData.plotKey ;
//    UIColor *color = [value valueAsColor] ;  // pot ser nil
//    [_trendView setColorFill:color forPlotWithIdentifier:ident] ;
//}



- (void)_updateOptions
{
    SWTrendItem *item = [self _trendItem];
//    NSDictionary *defDict = [[item.options getDefaultValue] valueAsDictionaryWithValues];
//    NSDictionary *dict = [item.options valueAsDictionaryWithValues];
//    SWValue *colorFillsArray = _dictValueForKey(dict, defDict, @"colorFills");
    
    SWValue *colorFillsArray = [item.options valueForStringKey:@"colorFills"];
    
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    
    int i=0 ;
    for ( PlotData *plotData in plotGroup.plots )
    {
        id ident = plotData.plotKey;
        SWValue *value = [colorFillsArray valueAtIndex:i++] ;  // pot ser nil
        //[self _setColorFillToPlotData:plotData value:value] ;
        [_trendView setColorFill:value.valueIsEmpty?nil:value.valueAsColor forPlotWithIdentifier:ident] ;
    }   
}


- (void)_updateTimeRange
{
    SWTrendItem *item = [self _trendItem];
    CFTimeInterval interval = [SWDatabaseContext timeIntervalForRange:item.databaseTimeRange.valueAsInteger];
    [_trendView setMaxZoomInterval:interval];
}


#pragma mark - Protocol SWTrendViewDataSource

//- (NSData *)pointsForPlotWithIdentifier:(id)ident inRange:(SWPlotRange)range
//{
//    SWTrendItem *item = [self _trendItem] ;
//    return [item pointsForPlotDataWithKey:ident inRange:range] ;
//}

//- (NSArray *)pointsForPlotsWithIdentifiers:(NSArray *)idents inRange:(SWPlotRange)range
//{
//    NSMutableArray *array = [NSMutableArray array];
//    for ( NSString* ident in idents )
//    {
//        NSData *data = [self pointsForPlotWithIdentifier:ident inRange:range];
//        [array addObject:data];
//    }
//    return array;
//}

- (NSArray *)pointsForPlotsWithIdentifiers:(NSArray *)idents inRange:(SWPlotRange)range
{
    SWTrendItem *item = [self _trendItem] ;
    NSAssert( [[self _mainPlotGroup] plotsCount] == idents.count, @"inconsistency error" );
    
    return [item pointsDatasInRange:range];
}

#pragma mark - Protocol TrendViewDelegate


- (void)trendView:(SWTrendView*)trendView didFinishGestureWithPlotInterval:(double)xInterval xOffset:(double)xOffset
{
    SWTrendItem *item = [self _trendItem] ;
    [item.plotInterval evalWithConstantValue:xInterval];
    [item.intervalOffset evalWithConstantValue:xOffset];
}



#pragma mark - Protocol TrendItemObserver

- (void)trendItem:(SWTrendItem*)trendItem didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx 
{
    //NSLog( @"SWTrendItemController didAddPlotGroup (no suportem grups)" ) ;
}

- (void)trendItem:(SWTrendItem*)trendItem didremovePlotGroupAtIndex:(NSInteger)indx
{
    //NSLog( @"SWTrendItemController didremovePlotGroupAtIndex (no suportem grups)" ) ;
}

- (void)trendItem:(SWTrendItem*)trendItem didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx
{
    //NSLog( @"SWTrendItemController didAddPlotData" ) ;
    id ident = plotData.plotKey ;
    [_trendView addPlotWithIdentifier:ident] ;
    
    SWBounds yRange = [self _yRange] ;
    [_trendView setYRange:yRange forPlotWithIdentifier:ident animated:NO] ;
    //[_trendView setXRangeForPlotWithIdentifier:ident animated:NO] ;
    [_trendView reloadPlotsAnimated:NO];
    
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    NSInteger plotIndex = [plotGroup plotsCount] - 1 ;
    if ( plotIndex >= 0 )
    {
        SWTrendItem *item = [self _trendItem] ;
        
        SWValue *value = [item.colors valueAtIndex:plotIndex] ;
        [self _setColorToPlotData:plotData value:value] ;
        
        SWValue *colorFillsArray = [item.options valueForStringKey:@"colorFills"];
        value = [colorFillsArray valueAtIndex:plotIndex] ;
        //[self _setColorFillToPlotData:plotData value:value] ;
        
        [_trendView setColorFill:value.valueIsEmpty?nil:value.valueAsColor forPlotWithIdentifier:ident] ;
    }    
    
}

- (void)trendItem:(SWTrendItem*)trendItem didReplacePlotDatasForGroupAtIndex:(NSInteger)indx
{
    [_trendView reloadPlotsAnimated:YES];
}


//- (void)trendItem:(SWTrendItem*)trendItem didReplacePlotDatasWithRange:(SWPlotRange)dataRange forGroupAtIndex:(NSInteger)indx
//{
//   // [_trendView reloadPlotsAnimated:YES];
//    [_trendView reloadFetchedPlotsWithRange:dataRange animated:YES];
//}


- (void)trendItem:(SWTrendItem*)trendItem didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx
{
    //NSLog( @"SWTrendItemController didRemovePlotData" ) ;
    id ident = plotData.plotKey ;
    [_trendView removePlotWithIdentifier:ident] ;
}


#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWTrendItem *item = [self _trendItem];
    
    if ( value == item.plots )
    {
        // res (el item ho gestiona)
    }

    else if (value == item.plotInterval )
        [_trendView setXPlotInterval:value.valueAsDouble] ;
        
    else if ( value == item.intervalOffset )  
        [_trendView setXRangeOffset:value.valueAsDouble] ;
    
    else if ( value == item.enableGestures )
        [_trendView setGesturesEnabled:value.valueAsBool];

    else if ( value == item.yMin || value == item.yMax )
        [self _setGlobalYRangeAnimated:YES] ;

    else if ( value == item.xMajorTickInterval ) 
        [_trendView setXMajorTickInterval:value.valueAsDouble] ;

    else if ( value == item.xMinorTicksPerInterval ) 
        [_trendView setXMinorTicksPerInterval:value.valueAsDouble] ;

    else if ( value == item.yMajorTickInterval ) 
        [_trendView setYMajorTickInterval:value.valueAsDouble] ;

    else if ( value == item.yMinorTicksPerInterval ) 
        [_trendView setYMinorTicksPerInterval:value.valueAsDouble] ;
        
    else if (value == item.tintColor)
        [_trendView setTintsColor:value.valueAsColor];
        
    else if (value == item.borderColor)
        [_trendView setBorderColor:value.valueAsColor];

    else if ( value == item.colors )
        [self _setPlotColors] ;
        
    else if ( value == item.style )
        [_trendView setStyle:value.valueAsInteger];
        
    else if ( value == item.updatingStyle )
        [_trendView setUpdatingStyle:value.valueAsInteger];
    
    else if ( value == item.options )
        [self _updateOptions];
    
    else if ( value == item.databaseTimeRange )
        [self _updateTimeRange];
        
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
        
}




@end
