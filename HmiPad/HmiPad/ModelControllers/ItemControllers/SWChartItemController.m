//
//  SWChartItemController.m
//  HmiPad
//
//  Created by Joan Lluch on 13/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWChartItemController.h"
#import "SWTrendView.h"
#import "SWChartItem.h"
#import "SWChartCache.h"
#import "SWColor.h"

#import <QuartzCore/QuartzCore.h>
@interface SWChartItemController ()

- (SWChartItem*)_chartItem;

@end

@implementation SWChartItemController

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
    
    SWChartItem *item = [self _chartItem] ;
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    
    for ( PlotData *plotData in plotGroup.plots )
    {
        id ident = plotData.plotKey ;
        [_trendView addPlotWithIdentifier:ident] ;
    }
    
    
    [_trendView setUpdatingStyle:item.updatingStyle.valueAsInteger];
    [_trendView setStyle:item.style.valueAsInteger];
    [_trendView setChartType:item.chartType.valueAsInteger];
    
    //[_trendView setXMin:item.xMin.valueAsDouble];
    [_trendView setXMajorTickInterval:item.xMajorTickInterval.valueAsDouble] ;
    [_trendView setXMinorTicksPerInterval:item.xMinorTicksPerInterval.valueAsDouble] ;
    
//    [_trendView setXMinorTicksPerInterval:4] ;
//    [_trendView setXMajorTickInterval:1] ;
    
    [_trendView setYMinorTicksPerInterval:item.yMinorTicksPerInterval.valueAsDouble] ;
    [_trendView setYMajorTickInterval:item.yMajorTickInterval.valueAsDouble] ;
    
//    [_trendView setXRangeLength:item.plotInterval.valueAsDouble] ;
//    [_trendView setXRangeOffset:item.intervalOffset.valueAsDouble] ;

    
//    SWPlotRange xRange = [self _xRange];
//    [_trendView setXAxisRange:xRange animated:NO];
    
    [_trendView setTintsColor:item.tintColor.valueAsColor];
    [_trendView setBorderColor:item.borderColor.valueAsColor];
    
    [_trendView setFormat:item.format.valueAsString];
    [_trendView setLabels:CFBridgingRelease([item.labels createArrayWithValuesAsStringsWithFormat:nil])];
    
    [self _setGlobalYRangeAnimated:NO] ;
    [self _setPlotColors] ;
    [self _updateOptions];
    
    [self _reloadPlotsAnimated:NO];
}


#pragma mark - view Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  //  [_trendView resetViewUpdating] ;
}

- (void)viewWillDisappear:(BOOL)animated
{    
    [super viewWillDisappear:animated];
    //[_trendView stopViewUpdating] ;
    [_trendView removeAllPlots] ;
}



#pragma mark - Private Methods


- (void)dealloc
{
    //NSLog( @"trendController dealloc" ) ; // if ( _reLoadTimer ) dispatch_source_cancel( _reLoadTimer ) ;
}


- (SWChartItem*)_chartItem
{
    if ([self.item isKindOfClass:[SWChartItem class]]) {
        return (SWChartItem*)self.item;
    }
    
    return nil;
}

- (SWBounds)_yRange
{
    SWChartItem *item = [self _chartItem] ;
    SWBounds yRange = SWBoundsMake(item.yMin.valueAsDouble, item.yMax.valueAsDouble) ;
    return yRange ;
}

- (SWPlotRange)_xRange
{
//    SWChartItem *item = [self _chartItem] ;
//    SWValue *regionsExp = item.regions;
//    NSInteger xMax = -1;
//    for ( SWValue *regionExp in regionsExp )
//    {
//        NSInteger valuesCount = regionExp.count;
//        if ( valuesCount > xMax ) xMax = valuesCount;
//    }
//    
//    SWPlotRange xRange = SWPlotRangeMake(0, xMax);
//    return xRange;
    
    //SWPlotRange xRange = SWPlotRangeMake(0, -1);
    SWPlotRange xRange = SWPlotRangeMake(0, 0);   // cucurut
    PlotGroup *plotGroup = [self _mainPlotGroup];
    for ( PlotData *plotData in plotGroup.plots )
    {
        SWPlotRange xPlotRange = plotData.xRange;
        if ( xPlotRange.max-xPlotRange.min > xRange.max-xRange.min )
            xRange = xPlotRange;
    }
    
    return xRange;
}


- (PlotGroup*)_mainPlotGroup
{
    SWChartItem *item = [self _chartItem] ;
    NSArray *plotGroups = item.plotGroups ;
    PlotGroup *plotGroup = nil ;
    if ( plotGroups.count > 0 ) plotGroup = [item.plotGroups objectAtIndex:0] ;
    return plotGroup ;
}


- (void)_setGlobalXRangeAnimated:(BOOL)animated
{
    SWChartItem *item = [self _chartItem] ;
    
    [_trendView setXMajorTickInterval:item.xMajorTickInterval.valueAsDouble];
    
    SWPlotRange xRange = [self _xRange];
    [_trendView setXAxisRange:xRange animated:NO];
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
        //[_trendView reloadPlotWithIdentifier:ident] ;
    }
    [_trendView reloadPlotsAnimated:animated];
}


- (void)_reloadPlotsAnimated:(BOOL)animated
{
    //PlotGroup *plotGroup = [self _mainPlotGroup] ;
    SWPlotRange xRange = [self _xRange];
    [_trendView setXAxisRange:xRange animated:animated];
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
    SWChartItem *item = [self _chartItem] ;
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
    SWChartItem *item = [self _chartItem];
    
    SWValue *optionsDict = item.options;
    SWValue *colorFillsArray = [optionsDict valueForStringKey:@"colorFills"];
    SWValue *pointSymbolsArray = [optionsDict valueForStringKey:@"pointSymbols"];
    
    PlotGroup *plotGroup = [self _mainPlotGroup] ;
    
    int i=0 ;
    for ( PlotData *plotData in plotGroup.plots )
    {
        id ident = plotData.plotKey ;
        
        SWValue *value = [colorFillsArray valueAtIndex:i] ;  // pot ser nil
        [_trendView setColorFill:value.valueIsEmpty?nil:value.valueAsColor forPlotWithIdentifier:ident] ;
        
        value = [pointSymbolsArray valueAtIndex:i];
        [_trendView setSymbol:value==nil?YES:value.valueAsBool forPlotWithIdentifier:ident];
        
        i++;
    }   
}


#pragma mark - Protocol SWTrendViewDataSource

//- (NSData *)pointsForPlotWithIdentifier:(id)ident inRange:(SWPlotRange)range
//{
//    SWChartItem *item = [self _chartItem] ;
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

- (NSArray *)pointsForPlotsWithIdentifiers:(NSArray*)idents inRange:(SWPlotRange)range
{
    SWChartItem *item = [self _chartItem] ;
    NSAssert( [[self _mainPlotGroup] plotsCount] == idents.count, @"inconsistency error" );
    
    return [item pointsDatasInRange:range];
}


#pragma mark - Protocol ChartItemObserver

- (void)chartItem:(SWChartItem*)chartItem didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx
{
    //NSLog( @"SWChartItemController didAddPlotGroup (no suportem grups)" ) ;
}

- (void)chartItem:(SWChartItem*)chartItem didremovePlotGroupAtIndex:(NSInteger)indx
{
    //NSLog( @"SWChartItemController didremovePlotGroupAtIndex (no suportem grups)" ) ;
}

- (void)chartItem:(SWChartItem*)chartItem didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx
{
    //NSLog( @"SWChartItemController didAddPlotData" ) ;
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
        SWChartItem *item = [self _chartItem] ;
        
        SWValue *value = [item.colors valueAtIndex:plotIndex] ;
        [self _setColorToPlotData:plotData value:value] ;
        
        SWValue *optionsDict = item.options;
        
        SWValue *colorFillsArray = [optionsDict valueForStringKey:@"colorFills"];
        SWValue *pointSymbolsArray = [optionsDict valueForStringKey:@"pointSymbols"];

        value = [colorFillsArray valueAtIndex:plotIndex] ;
        [_trendView setColorFill:value.valueIsEmpty?nil:value.valueAsColor forPlotWithIdentifier:ident];
        
        value = [pointSymbolsArray valueAtIndex:plotIndex];
        [_trendView setSymbol:value==nil?YES:value.valueAsBool forPlotWithIdentifier:ident];
    }
}

//- (void)chartItem:(SWChartItem*)chartItem didReplacePlotData:(PlotData*)plotData forGroupAtIndex:(NSInteger)indx
//{
//    //NSLog( @"SWChartItemController didReplacePlotData" ) ;
//}


- (void)chartItem:(SWChartItem*)chartItem didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx
{
    //NSLog( @"SWChartItemController didRemovePlotData" ) ;
    id ident = plotData.plotKey ;
    [_trendView removePlotWithIdentifier:ident] ;
}


#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWChartItem *item = [self _chartItem];

//    if (value == item.plotInterval )
//        [_trendView setXRangeLength:value.valueAsDouble] ;
//
//    else if ( value == item.intervalOffset )  
//        [_trendView setXRangeOffset:value.valueAsDouble] ;
//
//    else

    if ( value == item.regions )
        [self _reloadPlotsAnimated:YES];

    else if ( value == item.xFirstTick || value == item.xMajorTickInterval )
        [self _setGlobalXRangeAnimated:YES];

    else if ( value == item.yMin || value == item.yMax )
        [self _setGlobalYRangeAnimated:YES] ;

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
    
    else if ( value == item.format )
        [_trendView setFormat:value.valueAsString];

    else if ( value == item.colors )
        [self _setPlotColors] ;
    
    else if ( value == item.labels )
        [_trendView setLabels:CFBridgingRelease([item.labels createArrayWithValuesAsStringsWithFormat:nil])];
        
    else if ( value == item.style )
        [_trendView setStyle:value.valueAsInteger];
        
    else if ( value == item.updatingStyle )
        [_trendView setUpdatingStyle:value.valueAsInteger];
    
    else if ( value == item.chartType )
        [_trendView setChartType:value.valueAsInteger];
    
    else if ( value == item.options )
        [self _updateOptions];
        
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}


#pragma mark - Protocol SWChartCache






@end

