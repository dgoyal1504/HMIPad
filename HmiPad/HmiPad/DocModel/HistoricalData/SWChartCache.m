//
//  SWChartCache.m
//  HmiPad
//
//  Created by Joan Lluch on 14/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWChartCache.h"
#import "SymbolicCoder.h"
#import "SWHistoValuesDatabaseContext.h"

@interface SWChartCache()
{
    SWHistoValuesDatabaseContext *_dbContext;
    NSMutableArray *_plotGroups;
    NSMutableDictionary *_plotDatas;
}
@end

@implementation SWChartCache
{
    BOOL _isReloadingData;
    BOOL _hasPendingRequest;
    BOOL _isWaitingResponse;
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) 
    {
        _plotGroups = [decoder decodeObject] ;
        _plotDatas = [decoder decodeObject] ;
    }
        
    return self;
}


- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_plotGroups] ;
    [encoder encodeObject:_plotDatas] ;
}

#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id)parent
{
    self = [super init] ;
    if (self) 
    {
        _plotGroups = [decoder decodeCollectionOfObjectsForKey:@"plotGroups"] ;
        [self _makePlotDatasAfterDecodingGroup];
    }
    return self ;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [encoder encodeCollectionOfObjects:_plotGroups forKey:@"plotGroups"] ;
}


#pragma mark - Private

- (void)_makePlotDatasAfterDecodingGroup
{
    // _plotDatas el generem dinamicament
    for ( PlotGroup *plotGroup in _plotGroups )
    {
        for ( PlotData *plotData in plotGroup.plots )
        {
            if ( _plotDatas == nil ) _plotDatas = [[NSMutableDictionary alloc] init] ;
            id plotKey = [plotData plotKey] ;
            [_plotDatas setObject:plotData forKey:plotKey] ;
        }
    }
}


- (NSString*)_keyWithIndex:(NSUInteger)indx
{
    NSString *key = [NSString stringWithFormat:@"plot%03lu", (unsigned long)indx] ;
    return key ;
}


//- (NSInteger)setupForPlotsCountV:(NSInteger)count
//{
//    NSInteger valuesCount = count;
//    PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:0] ;
//    NSInteger plotsCount = [plotGroup plotsCount];
//        
//    // afegim plots nous si el array es mes llarg
//    while ( valuesCount > plotsCount  )
//    {
//        id key = [self _keyWithIndex:plotsCount] ;
//        PlotData *plotData = [self _plotDataForKey:key addIfAbsent:YES] ;
//        [self _plotGroupsAddPlotData:plotData toGroupAtIndex:0] ;
//        plotsCount++ ;
//    }
//        
//    // eliminem plots si el array es mes curt
//    while ( valuesCount < plotsCount )
//    {
//        id key = [self _keyWithIndex:plotsCount-1] ;
//        PlotData *plotData = [self _plotDataForKey:key] ;
//        [self _plotGroupsRemovePlotDataV:plotData fromPlotGroupAtIndex:0] ;
//        [self _plotDataRemoveForKey:key] ;
//        plotsCount-- ;
//    }
//    
//    return valuesCount;
//}



- (void)setupWithPlotsCount:(NSInteger)count forPlotGroupIndex:(NSInteger)indx
{
    //NSInteger valuesCount = count;
    PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx] ;
    NSInteger plotsCount = [plotGroup plotsCount];
        
    // afegim plots nous si el array es mes llarg
    while ( count > plotsCount  )
    {
        id key = [self _keyWithIndex:plotsCount] ;
        PlotData *plotData = [self _plotDataForKey:key addIfAbsent:YES] ;
        [self _plotGroupsAddPlotData:plotData toGroupAtIndex:indx] ;
        plotsCount++ ;
    }
        
    // eliminem plots si el array es mes curt
    while ( count < plotsCount )
    {
        id key = [self _keyWithIndex:plotsCount-1] ;
        PlotData *plotData = [self _plotDataForKey:key] ;
        [self _plotGroupsRemovePlotData:plotData] ;
        [self _plotDataRemoveForKey:key] ;
        plotsCount-- ;
    }
    
    //return valuesCount;
}


#pragma mark - Methods

- (BOOL)plotGroupsAddPlotDataWithKey:(id)key toGroupAtIndex:(NSUInteger)indx
{
    // busquem o creem el plotData en el diccionari
    PlotData *plotData = [self _plotDataForKey:key addIfAbsent:YES] ;
    
    // la afegim al grup
    return [self _plotGroupsAddPlotData:plotData toGroupAtIndex:indx] ;
}


//- (BOOL)plotGroupsRemovePlotDataWithKeyV:(id)key fromGroupAtIndex:(NSUInteger)indx
//{
//    // busquem el plotData en el diccionari
//    PlotData *plotData = [self _plotDataForKey:key] ;
//    
//    // el treiem del grup
//    return [self _plotGroupsRemovePlotDataV:plotData fromPlotGroupAtIndex:indx] ;
//}


- (BOOL)plotGroupsRemovePlotDataWithKey:(id)key
{
    // busquem el plotData en el diccionari
    PlotData *plotData = [self _plotDataForKey:key] ;
    
    // el treiem del grup
    return [self _plotGroupsRemovePlotData:plotData] ;

}


- (NSData *)UNUSEDpointsForPlotDataWithKey:(id)key inRange:(SWPlotRange)range
{
    // busquem el plotData en el diccionari
    PlotData *plotData = [self _plotDataForKey:key] ;

    // tornem els punts
    return [plotData pointsForXRange:range] ;
}


- (NSArray *)pointsDatasForPlotGroupAtIndexVV:(NSInteger)indx inRange:(SWPlotRange)range
{
    NSMutableArray *array = [NSMutableArray array];
    PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx];
    for ( PlotData *plotData in plotGroup.plots )
    {
        NSData *points = [plotData pointsForXRange:range];
        [array addObject:points];
    }
    return array;
}

//- (void)setDbStoreIdentifier:(NSString *)dbStoreIdentifier
//{
//    _dbStoreIdentifier = dbStoreIdentifier;
//    _dbContext = nil ;   // buscar el dbcontext a partir del identifier
//}

- (void)setDbContext:(SWHistoValuesDatabaseContext *)dbContext forPlotGroupAtIndex:(NSInteger)indx
{
    _dbContext = dbContext;
    
    // resetegem els plotpoints
    if ( dbContext == nil )
    {
        PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx];
        for ( PlotData *plotData in plotGroup.plots )
        {
            [plotData setSequentialPointValues:NULL pointsCount:0 triggerFactor:0];
        }
    }
}




//- (NSArray *)pointsDatasForPlotGroupAtIndexV:(NSInteger)indx inRange:(SWPlotRange)range
//{
//    NSMutableArray *array = [NSMutableArray array];
//    PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx];
//    
//    if ( _dbContext != nil )
//    {
//        if ( _hasPendingRequest == NO )
//        {
//            _hasPendingRequest = YES;
//            [_dbContext fetchPointsDatasInRange:range completion:^(NSArray *pointDatas)
//            {
//                // handle possible count changes
//                NSInteger plotsCount = pointDatas.count;
//                [self setupForPlotsCount:plotsCount plotGroupIndex:indx];
//                
//                // store plot datas
//                NSArray *plotGroupPlots = plotGroup.plots;
//                for ( NSInteger i=0 ; i<plotsCount ; i++ )
//                {
//                    NSData *pointData = [pointDatas objectAtIndex:i];
//                    PlotData *plotData = [plotGroupPlots objectAtIndex:i];
//                    
//                    NSInteger pointCount = pointData.length/sizeof(SWPlotPoint) ;
//                    const SWPlotPoint *points = [pointData bytes] ;
//                    
//                    [plotData setSequentialPointValues:points pointsCount:pointCount];
//                }
//                
//                //NSLog( @"fetch range: %1.15g, %1.15g", range.min, range.max );
//                
//                // notify of the change
//                //[_delegate chartCache:self didUpdatePlotsForGroupAtIndex:indx];
//                _isReloadingData = YES;
//                [_delegate chartCache:self didUpdatePlotsAtRange:range forGroupAtIndex:indx];
//                _isReloadingData = NO;
//                _hasPendingRequest = NO;
//            }];
//        }
//    }
//    
//    // deliver what we have so far
//    for ( PlotData *plotData in plotGroup.plots )
//    {
//        NSData *pointData = [plotData pointsForXRange:range];
//        [array addObject:pointData];
//    }
//    //NSLog( @"points retu: %1.15g, %1.15g", range.min, range.max );
//    return array;
//}



- (void)_fetchForRange:(SWPlotRange)range atIndex:(NSInteger)indx
{
    if ( _delegate == nil )
        return;

    if ( _isWaitingResponse == NO )
    {
        PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx];
        _isWaitingResponse = YES;
        [_dbContext fetchPointsDatasInRange:range completion:^(NSArray *pointDatas, double factor)
        {
            // handle possible count changes
            NSInteger plotsCount = pointDatas.count;
            [self setupWithPlotsCount:plotsCount forPlotGroupIndex:indx];
            
            // store plot datas
            NSArray *plotGroupPlots = plotGroup.plots;
            for ( NSInteger i=0 ; i<plotsCount ; i++ )
            {
                NSData *pointData = [pointDatas objectAtIndex:i];
                PlotData *plotData = [plotGroupPlots objectAtIndex:i];
                
                NSInteger pointCount = pointData.length/sizeof(SWPlotPoint) ;
                const SWPlotPoint *points = [pointData bytes] ;
                
                [plotData setSequentialPointValues:points pointsCount:pointCount triggerFactor:factor];
    
            }
            
            //NSLog( @"fetch range: %1.15g, %1.15g", range.min, range.max );
            
            // notify of the change
            //[_delegate chartCache:self didUpdatePlotsForGroupAtIndex:indx];
            _isReloadingData = YES;
            [_delegate chartCache:self didUpdatePlotsAtRange:range forGroupAtIndex:indx];
            _isReloadingData = NO;
            _isWaitingResponse = NO;
            
            if ( _hasPendingRequest )
            {
                _hasPendingRequest = NO;
                _isReloadingData = YES;
                [_delegate chartCache:self didUpdatePlotsAtRange:range forGroupAtIndex:indx];
                _isReloadingData = NO;
            }
        }];
    }
    else
    {
        if ( !_isReloadingData )
        {
            _hasPendingRequest = YES;
        }
    }
}





- (NSArray *)pointsDatasForPlotGroupAtIndex:(NSInteger)indx inRange:(SWPlotRange)range
{
    NSMutableArray *array = [NSMutableArray array];
    PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx];
    
    //__block SWPlotRange stRange = range;

    if ( _dbContext != nil )
    {
        [self _fetchForRange:range atIndex:indx];
    }
    
    // deliver what we have so far
    for ( PlotData *plotData in plotGroup.plots )
    {
        NSData *points = [plotData pointsForXRange:range];
        [array addObject:points];
        
//        {
//            NSData *plotValuesx = points;
//            int countx = [plotValuesx length]/sizeof(SWPlotPoint);
//            SWPlotPoint *pointsx = (SWPlotPoint*)[plotValuesx bytes];
//            if ( countx > 0)
//            NSLog( @"after fetch: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:pointsx[countx-1].x] );
//        }
        
        
    }
    //NSLog( @"points retu: %1.15g, %1.15g", range.min, range.max );
    return array;
}






//- (NSData *)pointsForPlotDataWithKeyTEST:(id)key inRange:(SWPlotRange)range
//{
//    // busquem el plotData en el diccionari
//    PlotData *plotData = [self _plotDataForKey:key] ;
//    
//    if ( _isUpdatingData == NO )
//    {
//        [self performSelector:@selector(_delayedTESTWithPotData:) withObject:plotData afterDelay:0.5];
//        //return [NSData data];
//    }
//
//    // tornem els punts
//    return [plotData pointsForXRange:range] ;
//}
//
//
//- (void)_delayedTESTWithPotData:(PlotData*)plotData
//{
//    if ( [_delegate respondsToSelector:@selector(chartCache:didReplacePlotData:forGroupAtIndex:)])
//    {
//        NSInteger index = [_plotGroups indexOfObjectIdenticalTo:plotData];
//        _isUpdatingData = YES;
//        [_delegate chartCache:self didReplacePlotData:plotData forGroupAtIndex:index];
//        _isUpdatingData = NO;
//    }
//}


- (NSArray*)plotsForPlotGroupAtIndex:(NSInteger)indx
{
    PlotGroup *plotGroup = [self _plotGroupsPlotGroupAtIndex:indx] ;
    NSArray *plots = [plotGroup plots] ;
    return plots;
}


- (NSArray *)plotGroups
{
    return _plotGroups ;
}


#pragma mark private methods (PlotData)


//------------------------------------------------------------------------------------
- (UInt32)_generateNewRgbColor
{
    static int indx = 0 ; 
	const static UInt32 colors[] = 
    { 
    	0x00FF00, 0xFF8C00, 0xFFFF00, 0x8A2BE2, 0x00FFFF, 0xFF00FF,
        0xFF9966, 0x0099FF, 0xCC6600, 0x999900, 0x009900, 0xFF0000
    } ;
    UInt32 color = colors[indx++] ;
    if ( indx >= sizeof(colors)/sizeof(UInt32) ) indx = 0 ;
    return color;
}

//------------------------------------------------------------------------------------
- (PlotData *)_plotDataForKey:(id)key addIfAbsent:(BOOL)shouldAdd
{
    if ( _plotDatas == nil && shouldAdd )
    {
        _plotDatas = [[NSMutableDictionary alloc] init] ;
    }
    
    PlotData *plotData = [_plotDatas objectForKey:key] ;
    if ( plotData == nil && shouldAdd )
    {    
        //plotData = [self _newPlotDataWithKey:key] ; 
        plotData = [[PlotData alloc] initWithPlotKey:key bounds:SWBoundsMake(-INFINITY,+INFINITY)] ; 
        [_plotDatas setObject:plotData forKey:key] ;
        
        UInt32 plotRgbColor = [self _generateNewRgbColor] ;
        [plotData setPlotRgbColor:plotRgbColor] ;
    }
    return plotData ;
}

//------------------------------------------------------------------------------------
// a diferencia del anterior tornara nil si no existeix
- (PlotData *)_plotDataForKey:(id)key
{
	PlotData *plotData = nil ;
    if ( _plotDatas )
    {
    	plotData = [_plotDatas objectForKey:key] ;
    }
    return plotData ;
}


//------------------------------------------------------------------------------------
// elimna un plotData del diccionari
- (void)_plotDataRemoveForKey:(id)key
{
    [_plotDatas removeObjectForKey:key] ;
}


/*
//------------------------------------------------------------------------------------
// torna una nova instancia de plotData sense efectes en el diccionari
- (PlotData *)_newPlotDataWithKey:(id)key
{
	PlotData *plotData = [[PlotData alloc] initWithPlotKey:key bounds:SWBoundsMake(-INFINITY,+INFINITY)] ; 
    return plotData ;
}
*/



#pragma mark private methods (PlotGoups)


//------------------------------------------------------------------------------------
// Afageig un plot a un grup. Torna YES si ha fet un grup nou
- (BOOL)_plotGroupsAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSUInteger)indx
{
	BOOL groupAdded = NO ;
    
    // creem el plotGroups si cal
    if ( _plotGroups == nil ) _plotGroups = [[NSMutableArray alloc] init] ;
    NSUInteger count = [_plotGroups count] ;
    
    NSAssert( indx <= count, @"can not add groups beyond group count" );
    
    // afegim un grup si cal 
    if ( indx >= count ) 
    {
		indx = count ;
        PlotGroup *group = [[PlotGroup alloc] init] ;
		[_plotGroups addObject:group] ;
        
        [_delegate chartCache:self didAddPlotGroup:group atIndex:indx];
        groupAdded = YES ;
    }
    
    // afegim el plotData al grup en el index
    PlotGroup *group = [_plotGroups objectAtIndex:indx] ;
    if ( [group addPlotData:plotData] )
    {
        [_delegate chartCache:self didAddPlotData:plotData toGroupAtIndex:indx];
    }
    
    return groupAdded ;
}

////------------------------------------------------------------------------------------
//// Elimina un plot de un grup. Torna YES si ha eliminat el grup
//- (BOOL)_plotGroupsRemovePlotDataV:(PlotData*)plotData fromPlotGroupAtIndex:(NSUInteger)indx
//{
//
//    NSUInteger count = [_plotGroups count] ;
//    if ( indx >= count ) return NO ;
//    
//    // determinem el grup per index i esborrem l'objecte	
//    PlotGroup *group = [_plotGroups objectAtIndex:indx] ;
//    
//    BOOL plotRemoved = [group removePlotDataIdenticalTo:plotData] ;
//    if ( plotRemoved )
//    {
//        [_delegate chartCache:self didRemovePlotData:plotData fromGroupAtIndex:indx];
//    }
//    
//    // si no ha quedat cap plotData en el grup eliminem el grup
//    BOOL groupDeleted = NO ;
//    count = [group plotsCount] ;
//    if ( count == 0 ) 
//    {
//        [_plotGroups removeObjectAtIndex:indx] ;
//        groupDeleted = YES ;
//        
//        [_delegate chartCache:self didremovePlotGroupAtIndex:indx];
//    }
//    return groupDeleted ;
//}



//------------------------------------------------------------------------------------
// Elimina un plot de un grup. Torna YES si ha eliminat el grup
- (BOOL)_plotGroupsRemovePlotData:(PlotData*)plotData
{

    BOOL plotRemoved = NO;
    NSInteger indx = 0;
    PlotGroup *group = nil;
    
    // probem de eliminar el plotData del grup al que pertany
    for ( PlotGroup *g in _plotGroups )
    {
        plotRemoved = [g removePlotDataIdenticalTo:plotData] ;
        if ( plotRemoved ) break;
        indx += 1;
    }
    
    // determinem el grup per index i esborrem l'objecte
    if ( plotRemoved )
    {
        group = [_plotGroups objectAtIndex:indx] ;
        [_delegate chartCache:self didRemovePlotData:plotData fromGroupAtIndex:indx];
    }
    
    // si no ha quedat cap plotData en el grup eliminem el grup
    BOOL groupDeleted = NO ;
    NSInteger count = [group plotsCount] ;
    if ( count == 0 ) 
    {
        [_plotGroups removeObjectAtIndex:indx] ;
        groupDeleted = YES ;
        
        [_delegate chartCache:self didremovePlotGroupAtIndex:indx];
    }
    return groupDeleted ;
}



//------------------------------------------------------------------------------------
- (PlotGroup *)_plotGroupsPlotGroupAtIndex:(NSUInteger)indx
{
    if ( indx < _plotGroups.count ) return [_plotGroups objectAtIndex:indx] ;
    return nil ;
}



/*
//------------------------------------------------------------------------------------
- (NSUInteger)_indexOfPlotData:(PlotData*)plotData fromPlotGroupAtIndex:(NSUInteger)indx
{
    if ( plotData == nil || indx >= [_plotGroups count] ) return NSNotFound;
	
    PlotGroup *group = [_plotGroups objectAtIndex:indx] ;
    return [group indexOfPlotDataIdenticalTo:plotData] ;
}
*/


@end


#pragma mark - compatibility

//@implementation SWChartStore
@implementation SWChartCache(compatibility)

- (void)setPlotGroups:(NSMutableArray *)plotGroups
{
    _plotGroups = plotGroups;
}

- (void)makePlotDatasAfterDecodingGroup
{
    [self _makePlotDatasAfterDecodingGroup];
}

@end;

// DO NOT REMOVE. NEEDED FOR COMAPTIBILITY WITH *EXISTING* PROJECTS
@interface SWChartStore : SWChartCache
@end;
@implementation SWChartStore
@end;
