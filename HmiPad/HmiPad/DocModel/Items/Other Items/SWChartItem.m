//
//  SWChartItem.m
//  HmiPad
//
//  Created by Joan Lluch on 13/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWChartItem.h"
#import "SWChartCache.h"
#import "SWPropertyDescriptor.h"
#import "SWPage.h"
#import "SWEnumTypes.h"


@interface SWChartItem()<SWChartCacheDelegate>
{
    SWChartCache *_chartCache;
}
@end

@implementation SWChartItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"chart";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"CHART", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumTrendStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTrendStyleCustom]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"updatingStyle" type:SWTypeEnumTrendUpdatingStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTrendUpdatingStyleContinuous]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"chartType" type:SWTypeEnumChartType
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWChartTypeLine]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"options" type:SWTypeDictionary
                propertyType:SWPropertyTypeExpression
                defaultValue:[SWValue valueWithDictionary:@
                {
                    @"colorFills": @[],
                    @"pointSymbols":@[],
                }]],
            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"plotInterval" type:SWTypeDouble
//                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:30.0]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"intervalOffset" type:SWTypeDouble       // a treure
//                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],

            
            [SWPropertyDescriptor propertyDescriptorWithName:@"yMin" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"yMax" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:100.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"xFirstTick" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"xMajorTickInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"xMinorTicksPerInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:4.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"yMajorTickInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:10.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"yMinorTicksPerInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:2.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"tintColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"White"]], 
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"borderColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Black"]],
            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"plots" type:SWTypeDouble
//                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],


            [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%0.4g"]],
            
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"labels" type:SWTypeString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithArray:@[]]],

            [SWPropertyDescriptor propertyDescriptorWithName:@"colors" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithArray:@[@"green",@"blue"]]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"regions" type:SWTypeColor
                propertyType:SWPropertyTypeExpression
                defaultValue:[SWValue valueWithArray:@
                [
                    @[ @(10), @(50), @(25), @(75)],
                    @[ @(60), @(15), @(70), @(50)]
                ]]],
            
            nil];
}

#pragma mark - Init

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {
        _chartCache = [[SWChartCache alloc] init];
        _chartCache.delegate = self;
        
        [_chartCache setupWithPlotsCount:2 forPlotGroupIndex:0];
        [self _addPlotsPointsToGroupAtIndex:0] ;

        //[self.regions observerCountRetainBy:1];
    }
    return self;
}


#pragma mark - Coding, Sleeping

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        _chartCache = [decoder decodeObject];
        _chartCache.delegate = self;
        
        [self _addPlotsPointsToGroupAtIndex:0] ;
        //[self _plotsObserverRetainAfterDecode];
    }
        
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder] ;
    [encoder encodeObject:_chartCache];
}


- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWPage *)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent] ;
    if (self) 
    {
        _chartCache = [decoder decodeObjectForKey:@"chartCache"];
        _chartCache.delegate = self;
        [self _addPlotsPointsToGroupAtIndex:0] ;
        //[self _plotsObserverRetainAfterDecode];
    }
    return self ;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder] ;
    [encoder encodeObject:_chartCache forKey:@"chartCache"];
}


- (NSString *)replacementKeyForKey:(NSString*)key
{
    if ( [key isEqualToString:@"chartCache"] )
        return @"chartStore";  // <-- provem "chartStore" si "chartCache" no el troba.

    return nil;
}


//- (void)putToSleep
//{
//    if ( !self.isAsleep )
//        [self.regions observerCountReleaseBy:1];
//    
//    [super putToSleep];
//}
//
//
//- (void)awakeFromSleepIfNeeded
//{
//    BOOL isAsleep = self.isAsleep;
//    
//    [super awakeFromSleepIfNeeded];
//    
//    if (isAsleep)
//        [self.regions observerCountRetainBy:1];
//}

//- (void)dealloc
//{
//    if (!self.isAsleep)
//        [self.regions observerCountReleaseBy:1];
//}

//- (void)_plotsObserverRetainAfterDecode
//{
//    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        [self.regions observerCountRetainBy:1];
//    }) ;
//}



#pragma mark - Properties

- (SWValue*)style
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)updatingStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)chartType
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)options
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

//- (SWExpression*)plotInterval
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
//}

//- (SWExpression*)intervalOffset
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
//}




- (SWExpression*)yMin
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)yMax
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}


- (SWExpression*)xFirstTick
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}


- (SWExpression*)xMajorTickInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}


- (SWExpression*)xMinorTicksPerInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}


- (SWExpression*)yMajorTickInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}


- (SWExpression*)yMinorTicksPerInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}


- (SWExpression*)tintColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 11];
}


- (SWExpression*)borderColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 12];
}

//- (SWExpression*)plots
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 13];
//}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 13];
}


- (SWExpression*)labels
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 14];
}


- (SWExpression*)colors
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 15];
}


- (SWExpression*)regions
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 16];
}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeChart;
}


- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}


- (CGSize)defaultSize
{
    return CGSizeMake(400, 250);
}


- (CGSize)minimumSize
{
    return CGSizeMake(80, 60);
}


+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}


+ (NSString*)itemDescription
{
    return @"A chart to plot X,Y values.";
}


+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

#pragma mark - Public Methods


//- (NSData *)pointsForPlotDataWithKey:(id)key inRange:(SWPlotRange)range
//{
//    return [_chartCache pointsForPlotDataWithKey:key inRange:range];
//}

- (NSArray *)pointsDatasInRange:(SWPlotRange)range
{
    return [_chartCache pointsDatasForPlotGroupAtIndex:0 inRange:range];
}


- (NSArray *)plotGroups
{
    return _chartCache.plotGroups ;
}



#pragma mark - Private


- (void)_handleRegionsExpressionChange
{
    SWExpression *expression = self.regions ;
    NSInteger valuesCount = expression.count;
    //valuesCount =
    [_chartCache setupWithPlotsCount:valuesCount forPlotGroupIndex:0];
    
    if ( valuesCount > 0 )
    {
        [self _addPlotsPointsToGroupAtIndex:0] ;
    }
}


- (void)_handleRegionsRangeChange
{
    [self _updatePlotRangeToGroupAtIndex:0];
}


- (void)_addPlotsPointsToGroupAtIndex:(NSInteger)indx
{
    SWExpression *regionsExp = self.regions ;
    double xFirstTick = [self.xFirstTick valueAsDouble];
    double xInterval = [self.xMajorTickInterval valueAsDouble];
    
    NSArray *plots = [_chartCache plotsForPlotGroupAtIndex:indx];
    
    int i=0 ;
    for ( SWValue *v in regionsExp )
    {
        CFDataRef cfDataValues = [v createDataWithValuesAsDoubles];
        const double *values = (double*)CFDataGetBytePtr(cfDataValues);
        const int numValues = CFDataGetLength(cfDataValues)/sizeof(double);
        PlotData *plotData = [plots objectAtIndex:i++] ;
        [plotData setRegionValues:values pointsCount:numValues xStart:xFirstTick xInterval:xInterval];
        CFRelease(cfDataValues);
    }
    
    // alternativa utilitzant indexos
    
//    int i=0 ;
//    for ( SWValue *regionExp in regionsExp )
//    {
//        NSInteger valuesCount = [regionExp count];
//        PlotData *plotData = [plots objectAtIndex:i++] ;
//        [plotData prepareForXRange:SWPlotRangeMake(0, valuesCount-1)];
//        
//        for ( NSInteger j=0; j<valuesCount; j++ )
//        {
//            double value = [regionExp doubleAtIndex:j];
//            [plotData setRegionValue:value atXRangeIndexPosition:j];
//        }
//    }
}


- (void)_updatePlotRangeToGroupAtIndex:(NSInteger)indx
{
    NSArray *plots = [_chartCache plotsForPlotGroupAtIndex:indx];
    
    if ( plots == nil )
        return;
    
    SWExpression *regionsExp = self.regions ;
    double xFirstTick = [self.xFirstTick valueAsDouble];
    double xInterval = [self.xMajorTickInterval valueAsDouble];
    
    int i=0 ;
    for ( SWValue *v in regionsExp )
    {
        PlotData *plotData = [plots objectAtIndex:i++];
        [plotData setRegionXStart:xFirstTick xInterval:xInterval];
    }
}



#pragma mark - SWValueHolder

-(void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.regions )
    {
        [self _handleRegionsExpressionChange] ;
    }
    
    else if ( expression == self.xFirstTick || expression == self.xMajorTickInterval )
    {
        [self _handleRegionsRangeChange];
    }
    
    else if ( expression == self.updatingStyle )
    {
        SWTrendUpdatingStyle style = [self.updatingStyle valueAsInteger];
        BOOL bShot = [self.takeShot valueAsBool];
        
        if ( bShot && style == SWTrendUpdatingStyleDiscrete)
        {
        
        }
    }
    
    
}

#pragma mark - SWChartCacheDelegate

- (void)chartCache:(SWChartCache*)chartCache didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx
{
    for ( id<ChartItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(chartItem:didAddPlotGroup:atIndex:)] )
            [observer chartItem:self didAddPlotGroup:plotGroup atIndex:indx] ;
    }
}


- (void)chartCache:(SWChartCache*)chartCache didremovePlotGroupAtIndex:(NSInteger)indx
{
    for ( id<ChartItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(chartItem:didremovePlotGroupAtIndex:)] )
            [observer chartItem:self didremovePlotGroupAtIndex:indx] ;
    }
}


- (void)chartCache:(SWChartCache*)chartCache didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx
{
    for ( id<ChartItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(chartItem:didAddPlotData:toGroupAtIndex:)] )
            [observer chartItem:self didAddPlotData:plotData toGroupAtIndex:indx] ;
    }
}


- (void)chartCache:(SWChartCache*)chartCache didUpdatePlotsAtRange:(SWPlotRange)dataRange forGroupAtIndex:(NSInteger)indx
{
}


- (void)chartCache:(SWChartCache*)chartCache didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx
{
    for ( id<ChartItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(chartItem:didRemovePlotData:fromGroupAtIndex:)] )
            [observer chartItem:self didRemovePlotData:plotData fromGroupAtIndex:indx] ;
    }
}

@end

