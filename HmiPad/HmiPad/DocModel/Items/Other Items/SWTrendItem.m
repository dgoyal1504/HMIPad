//
//  SWTrendItem.m
//  HmiPad
//
//  Created by Joan on 29/04/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWTrendItem.h"

#import "SWPropertyDescriptor.h"
//#import "SWEnumTypes.h"

#import "SWChartCache.h"

#import "SWDocumentModel.h"
#import "SWHistoValues.h"


@interface SWTrendItem()<SWChartCacheDelegate>
{
    SWChartCache *_chartCache;
    SWHistoValuesDatabaseContext *_dbContext;
}
@end


@implementation SWTrendItem

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
    return @"trend";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"TREND", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumTrendStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTrendStyleCustom]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"updatingStyle" type:SWTypeEnumTrendUpdatingStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTrendUpdatingStyleDiscrete]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"options" type:SWTypeDictionary
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDictionary:@
                {
                    // @"colorFills": [SWValue valueWithArray:@[]],
                    @"colorFills": @[],
                }]],
            
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"enableGestures" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"plotInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:30.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"intervalOffset" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"yMin" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"yMax" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:100.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"xMajorTickInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:5.0]],
            
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
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"plots" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"colors" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Red"]],
            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"databaseIdentifier" type:SWTypeString
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
            
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

        //_dbIdentifier = @"db";
        
        [_chartCache setupWithPlotsCount:1 forPlotGroupIndex:0];
        
        [self _setupChartCache];
        [self.plots observerCountRetainBy:1];
    }
    return self;
}

#pragma mark - Coding, Sleeping

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
//        _plotGroups = [decoder decodeObject] ;
//        _plotDatas = [decoder decodeObject] ;
        _chartCache = [decoder decodeObject];
        _chartCache.delegate = self;

        //[self _setupChartStore];
        [self _plotsObserverRetainAfterDecode];
    }
        
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder] ;
//    [encoder encodeObject:_plotGroups] ;
//    [encoder encodeObject:_plotDatas] ;
    [encoder encodeObject:_chartCache];
}


- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWPage *)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:(id)parent] ;
    if (self) 
    {
        NSMutableArray *plotGroups = [decoder decodeCollectionOfObjectsForKey:@"plotGroups"];
        if ( plotGroups.count )   // <-- compatibilitat
        {
            _chartCache = [[SWChartCache alloc] init];
            _chartCache.plotGroups = plotGroups;
            [_chartCache makePlotDatasAfterDecodingGroup];
        }
        else
        {
            _chartCache = [decoder decodeObjectForKey:@"chartStore"];
        }
        
        _chartCache.delegate = self;
        //[self _setupChartCache];
        [self _plotsObserverRetainAfterDecode];
    }
    return self ;
}

-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [super encodeWithSymbolicCoder:encoder] ;
    //[encoder encodeCollectionOfObjects:_plotGroups forKey:@"plotGroups"] ;
    [encoder encodeObject:_chartCache forKey:@"chartStore"];
}

- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    [super retrieveWithQuickCoder:decoder];
  //  [self _setupChartCache];
}

- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
{
    [super retrieveWithSymbolicCoder:decoder identifier:ident parentObject:parent];
  //  [self _setupChartCache];
}



#warning moure a SWChartCache ?
- (void)_setupChartCache
{
    NSString *dbName = [self.databaseName valueAsString];
    if ( dbName.length)
        [self _handleDatabaseChange];
    else
        [self _addPlotsPointsToGroupAtIndex:0];
}


- (void)putToSleep
{
    if ( !self.isAsleep )
        [self.plots observerCountReleaseBy:1];
    
    [super putToSleep];
    
    _dbContext = nil;
    [_chartCache setDbContext:_dbContext forPlotGroupAtIndex:0];
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self.plots observerCountRetainBy:1];
}


- (void)dealloc
{
    if (!self.isAsleep)
        [self.plots observerCountReleaseBy:1];
    
//    if ( _dbContext )
//        [_docModel.histoValues releaseContext:_dbContext];
}

- (void)_plotsObserverRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self _setupChartCache];
        [self.plots observerCountRetainBy:1];
    }) ;
}

#pragma mark - Properties

- (SWValue*)style
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)updatingStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)options
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)enableGestures
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)plotInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)intervalOffset
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWExpression*)yMin
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)yMax
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWExpression*)xMajorTickInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWExpression*)xMinorTicksPerInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}

- (SWExpression*)yMajorTickInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}

- (SWExpression*)yMinorTicksPerInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 11];
}

- (SWExpression*)tintColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 12];
}

- (SWExpression*)borderColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 13];
}

- (SWExpression*)plots
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 14];
}

- (SWExpression*)colors
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 15];
}

//- (SWValue *)databaseIdentifier
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 15];
//}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeTrend;
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
    return @"An XY graph to plot trend values.";
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
    NSArray *pointsDatas = [_chartCache pointsDatasForPlotGroupAtIndex:0 inRange:range];
    
    //NSLog(@"cpu usage: %g", cpu_usage() );
    
    return pointsDatas;
}


- (NSArray *)plotGroups
{
    return _chartCache.plotGroups ;
}


#pragma mark - Private

//- (NSString*)_keyWithIndex:(NSUInteger)indx
//{
//    NSString *key = [NSString stringWithFormat:@"plot%03d", indx] ;
//    return key ;
//}




//#import <mach/mach.h>
//
//
//static float cpu_usage()
//{
//    kern_return_t kr;
//    task_info_data_t tinfo;
//    mach_msg_type_number_t task_info_count;
//
//    task_info_count = TASK_INFO_MAX;
//    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
//    if (kr != KERN_SUCCESS) {
//        return -1;
//    }
//
//    task_basic_info_t      basic_info;
//    thread_array_t         thread_list;
//    mach_msg_type_number_t thread_count;
//
//    thread_info_data_t     thinfo;
//    mach_msg_type_number_t thread_info_count;
//
//    thread_basic_info_t basic_info_th;
//    uint32_t stat_thread = 0; // Mach threads
//
//    basic_info = (task_basic_info_t)tinfo;
//
//    // get threads in the task
//    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
//    if (kr != KERN_SUCCESS) {
//        return -1;
//    }
//    if (thread_count > 0)
//        stat_thread += thread_count;
//
//    long tot_sec = 0;
//    long tot_usec = 0;
//    float tot_cpu = 0;
//    int j;
//
//    for (j = 0; j < thread_count; j++)
//    {
//        thread_info_count = THREAD_INFO_MAX;
//        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
//                         (thread_info_t)thinfo, &thread_info_count);
//        if (kr != KERN_SUCCESS) {
//            return -1;
//        }
//
//        basic_info_th = (thread_basic_info_t)thinfo;
//
//        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
//            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
//            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
//            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
//        }
//
//    } // for each thread
//
//    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
//    assert(kr == KERN_SUCCESS);
//
//    return tot_cpu;
//}






- (void)_handleDatabaseChange
{
    NSString *databaseName = [self.databaseName valueAsString];
    SWDatabaseContextTimeRange range = [self.databaseTimeRange valueAsInteger];
    double referenceTime = [self.referenceTime valueAsAbsoluteTime];
    
    SWDatabaseContext *previousDBcontext = _dbContext;
    
    if ( databaseName.length > 0 )
    {
        CFAbsoluteTime absoluteTime = CFAbsoluteTimeGetCurrent();
        if ( referenceTime > absoluteTime ) referenceTime = absoluteTime;
        
        _dbContext = [_docModel.histoValues dbContextForReadingWithName:databaseName range:range referenceTime:referenceTime];
    }
    else
    {
        _dbContext = nil;
    }
    
    if ( previousDBcontext != _dbContext )
    {
        NSString *keyName = [_dbContext keyName];
        [self.databaseFile evalWithString:keyName];
        [_chartCache setDbContext:_dbContext forPlotGroupAtIndex:0];
    }
}


- (void)_handlePlotsExpressionChange
{
    if ( _dbContext )
        return;

    SWExpression *plotsExp = self.plots ;
    NSInteger valuesCount = plotsExp.count;
    //valuesCount =
    [_chartCache setupWithPlotsCount:valuesCount forPlotGroupIndex:0];
    
    if ( valuesCount > 0 )
    {
        [self _addPlotsPointsToGroupAtIndex:0] ;
    }
}


- (void)_addPlotsPointsToGroupAtIndex:(NSInteger)indx
{
    SWExpression *plotsExp = self.plots ;
    
    NSArray *plots = [_chartCache plotsForPlotGroupAtIndex:indx];
    
    int i=0 ;
    double x = CFAbsoluteTimeGetCurrent() ;
    for ( SWValue *v in plotsExp )
    {
        double y = v.valueAsDouble;
        PlotData *plotData = [plots objectAtIndex:i++] ;
        [plotData addPoint:SWPlotPointMake(x,y)] ;
    }
    

//    // alternativa utilitzant indexos
//    double x = CFAbsoluteTimeGetCurrent() ;
//    NSInteger valuesCount = [expression count] ;
//    for ( int i=0 ; i<valuesCount ; i++ )
//    {
//        ExpValue *v = [expression valueAtIndex:i] ;
//        double y = [v valueAsDouble] ;
//        PlotData *plotData = [plots objectAtIndex:i] ;
//        [plotData addPoint:SWPlotPointMake(x,y)] ;
//    }

}


#pragma mark - SWValueHolder

-(void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.plots )
    {
        [self _handlePlotsExpressionChange] ;
    }
    
    else if ( expression == self.databaseTimeRange )
    {
        [self _handleDatabaseChange];
    }
    
    else if ( expression == self.databaseName )
    {
        [self _handleDatabaseChange];
    }
    
    else if ( expression == self.referenceTime )
    {
        [self _handleDatabaseChange];
    }
}


#pragma mark - SWChartCacheDelegate

- (void)chartCache:(SWChartCache*)chartCache didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx
{
    for ( id<TrendItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(trendItem:didAddPlotGroup:atIndex:)] )
            [observer trendItem:self didAddPlotGroup:plotGroup atIndex:indx] ;
    }
}


- (void)chartCache:(SWChartCache*)chartCache didremovePlotGroupAtIndex:(NSInteger)indx
{
    for ( id<TrendItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(trendItem:didremovePlotGroupAtIndex:)] )
            [observer trendItem:self didremovePlotGroupAtIndex:indx] ;
    }
}


- (void)chartCache:(SWChartCache*)chartCache didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx
{
    for ( id<TrendItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(trendItem:didAddPlotData:toGroupAtIndex:)] )
            [observer trendItem:self didAddPlotData:plotData toGroupAtIndex:indx] ;
    }
}


- (void)chartCache:(SWChartCache*)chartCache didUpdatePlotsAtRange:(SWPlotRange)dataRange forGroupAtIndex:(NSInteger)indx
{
    [self _handleDatabaseChange];
    for ( id<TrendItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(trendItem:didReplacePlotDatasForGroupAtIndex:)] )
            [observer trendItem:self didReplacePlotDatasForGroupAtIndex:indx] ;
    }
}

//- (void)chartCache:(SWChartCache*)chartCache didUpdatePlotsAtRange:(SWPlotRange)dataRange forGroupAtIndex:(NSInteger)indx
//{
//    for ( id<TrendItemObserver> observer in _observers )
//    {
//        if ( [observer respondsToSelector:@selector(trendItem:didReplacePlotDatasWithRange:forGroupAtIndex:)] )
//            [observer trendItem:self didReplacePlotDatasWithRange:dataRange forGroupAtIndex:indx] ;
//    }
//}


- (void)chartCache:(SWChartCache*)chartCache didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx
{
    for ( id<TrendItemObserver> observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(trendItem:didRemovePlotData:fromGroupAtIndex:)] )
            [observer trendItem:self didRemovePlotData:plotData fromGroupAtIndex:indx] ;
    }
}

@end
