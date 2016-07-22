//
//  PlotGroup.m
//  HmiPad
//
//  Created by Lluch Joan on 02/05/12.
//  Copyright (c) 2012 SweetWilliam, S.L. All rights reserved.
//

#import "PlotGroup.h"


#pragma mark -
#pragma mark - RegionData
#pragma mark -

@implementation RegionData

@synthesize plotRgbColor = _plotRgbColor ;
@synthesize plotKey = _plotKey ;
@synthesize bounds = _bounds ;


//@synthesize plotRgbColor = _plotRgbColor ;
//@synthesize plotKey = _plotKey ;
//@synthesize bounds = _bounds ;

//const static unsigned int _allowed_capacity = 500 ;
const static unsigned int _allowed_capacity = 2000 ;

- (void)doInit
{
    _numValues = 0 ;
    _valuesData = [NSMutableData data] ;
    _values = [_valuesData mutableBytes] ;
    _bounds = SWBoundsMake( INFINITY, -INFINITY ) ;   // atencio notar que min > max
}


- (id)initWithPlotKey:(id)key bounds:(SWBounds)bounds
{
    if ( (self = [super init]) )
    {
        [self doInit] ; 
        _plotKey = key ;
        if ( bounds.min != -INFINITY && bounds.max != INFINITY )
        {
            _bounds = bounds ;
        }
    }
    return self ; 
}


#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) 
    {
        [self doInit] ; 
        _plotKey = [decoder decodeObject] ;
        _plotRgbColor = [decoder decodeInt] ;
    }
        
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_plotKey] ;
    [encoder encodeInt:_plotRgbColor] ;
    // no codifiquem els valors
}


#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id)parent
{
    self = [super init] ;
    if (self) 
    {
        [self doInit] ;
        _plotKey = [decoder decodeStringForKey:@"plotKey"] ;
        _plotRgbColor = [decoder decodeIntForKey:@"defaultColor"] ;
    }
    return self ;
}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [encoder encodeString:_plotKey forKey:@"plotKey"] ;
    [encoder encodeInt:_plotRgbColor forKey:@"defaultColor"] ;
    // no codifiquem els valors
}


#pragma mark - Public Methods

- (NSData*)pointsForXRange:(SWPlotRange)xRange
{
    int imin = [self _indexOfX:xRange.min];
    int imax = [self _indexOfX:xRange.max];
    
    if ( imin == -1 || imax == -1 || imin>imax ) return [NSData data];
    
    if ( imax < _numValues-1 ) imax += 1;  // afegim dos punts per sobre del rang si es possible
    if ( imax < _numValues-1 ) imax += 1;
    
    //NSData *points = [NSData dataWithBytesNoCopy:&_values[imin] length:(imax+1-imin)*sizeof(SWPlotPoint) freeWhenDone:NO] ;
    NSData *points = [NSData dataWithBytes:&_values[imin] length:(imax+1-imin)*sizeof(SWPlotPoint)] ;
    
//    {
//        NSData *plotValuesx = points;
//        int countx = [plotValuesx length]/sizeof(SWPlotPoint);
//        SWPlotPoint *pointsx = (SWPlotPoint*)[plotValuesx bytes];
//        if ( countx > 0)
//        NSLog( @"pointsForXRange: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:pointsx[countx-1].x] );
//    }
    return points ;
}


//- (void)setRegionValues:(const double [])points forXRange:(SWPlotRange)xRange
//{
//    [self _doSetPoints:points forXRange:xRange];
//}


- (void)setRegionValues:(const double [])points pointsCount:(NSInteger)count xStart:(double)xStart xInterval:(double)xInterval
{
    [self _doSetPoints:points pointsCount:count xStart:xStart xInterval:xInterval];
}


- (void)setRegionXStart:(double)xStart xInterval:(double)xInterval
{
    [self _updatePointsWithXStart:xStart xInterval:xInterval];
}

//- (void)prepareForXRange:(SWPlotRange)xRange
//{
//    [self _prepareForXRange:xRange];
//}

//- (void)prepareForPointsCount:(NSInteger)count
//{
//    [self _prepareForPointsCount:count];
//}


//- (void)setRegionValue:(double)value atXRangeIndexPosition:(int)i
//{
//    _values[i].x = i;
//    _values[i].y = value;
//}

- (SWPlotRange)xRange
{
    //SWPlotRange xRange = SWPlotRangeMake(0, -1);
    SWPlotRange xRange = SWPlotRangeMake(0, 0);  // cucurut
    if ( _numValues > 0 )
    {
        xRange.min = _values[0].x;
        xRange.max = _values[_numValues-1].x;
    }
    return xRange;
}


#pragma mark - Private Methods

- (int)_indexOfX:(double)x
{
    if ( _numValues == 0 ) return -1 ;
    
    int beg = 0 ;
    if ( _values[beg].x >= x ) return beg ;
    
    int end = _numValues-1 ;
    if ( _values[end].x <= x ) return end ;
    
    int i = beg ;
    while ( i != (end+beg)/2 )
    {
        i = (end+beg)/2 ;
        double test = _values[i].x ;
        if ( test > x ) end = i-1 ;
        else if ( test < x ) beg = i ;
        //else break ;
    }
    return i ;
}


- (void)_prepareForPointsCount:(int)count
{
    int newLength = count;
    
    // si la capacitat excedeix la longitud maxima descartarem els ultims
    if ( newLength >= _allowed_capacity )
    {
        newLength = _allowed_capacity;
    }
    
    // actualitzem el contador
    _numValues = newLength;
    
    // pot ser necesitem modificar la capacitat
    int currentLength = [_valuesData length]/sizeof(SWPlotPoint);
    if ( _numValues != currentLength )
    {
        // incrementem la mida
        [_valuesData setLength:_numValues*sizeof(SWPlotPoint)] ;
        
        // els punters poden haver canviat
        _values = [_valuesData mutableBytes] ;
    }
}


//- (void)_prepareForXRange:(SWPlotRange)xRange
//{
//    int xMin = xRange.min;  // agafem els valors enters
//    int xMax = xRange.max;
//    
//    int newLength = xMax+1 - xMin;
//    
//    // si la capacitat excedeix la longitud maxima descartarem els ultims
//    if ( newLength >= _allowed_capacity )
//    {
//        xMax = xMin + _allowed_capacity-1;
//        newLength = _allowed_capacity;
//    }
//    
//    // actualitzem el contador
//    _numValues = newLength;
//    
//    // pot ser necesitem modificar la capacitat
//    int currentLength = [_valuesData length]/sizeof(SWPlotPoint);
//    if ( _numValues != currentLength )
//    {
//        // incrementem la mida
//        [_valuesData setLength:_numValues*sizeof(SWPlotPoint)] ;
//        
//        // els punters poden haver canviat
//        _values = [_valuesData mutableBytes] ;
//    }
//}


//- (void)_doSetPoints:(const double [])points forXRange:(SWPlotRange)xRange
//{
//    [self _prepareForXRange:xRange];
//    
//    // posem els valors
//    int xMin = xRange.min;  // agafem els valors enters
//    for ( int i=0 ; i<_numValues ; i++ )
//    {
//        _values[i].x = i+xMin;
//        _values[i].y = points[i];
//    }
//}


- (void)_doSetPoints:(const double [])points pointsCount:(NSInteger)count xStart:(double)xStart xInterval:(double)xInterval
{
    [self _prepareForPointsCount:count];
    
    // posem els valors
    double xMin = xStart;
    for ( int i=0 ; i<_numValues ; i++ )
    {
        _values[i].x = xMin + i*xInterval;
        _values[i].y = points[i];
    }
}


- (void)_updatePointsWithXStart:(double)xStart xInterval:(double)xInterval
{
    double xMin = xStart;
    for ( int i=0 ; i<_numValues ; i++ )
    {
        _values[i].x = xMin + i*xInterval;
    }
}

@end


#pragma mark -
#pragma mark - PlotData
#pragma mark -

@implementation PlotData


#define VALUETRIGGER 0.0
#define TRIGGERSHORT 0.1 // 0.1
#define TRIGGERLONG 0.7  // 0.2




- (void)addPoint:(SWPlotPoint)point
{
    [self addPoint:point withTriggerFactor:1];
}


- (void)addPoint:(SWPlotPoint)point withTriggerFactor:(double)factor
{
    if ( _numValues > 0 )
    {
        unsigned int lastI = _numValues-1 ;
        
        const double valueTrigger = VALUETRIGGER ;
        if ( fabs( _values[lastI].y - point.y ) <= valueTrigger )
        {
            // si el valor no ha canviat suficientment tornem sense fer res
            return ;
        }
        
        const CFAbsoluteTime trigger = point.x-TRIGGERSHORT ;
        if ( _values[lastI].x > trigger )  
        {
            // si fa poc que ha canviat machaquem el anterior
            _values[lastI].y = point.y ;
        }
        else 
        {
            // si fa molt que ha canviat generem un punt adicional
            if ( _values[lastI].x < point.x-factor*TRIGGERLONG ) [self _doAddPoint:SWPlotPointMake(trigger,_values[lastI].y)] ;
            
            // afegim el punt
            [self _doAddPoint:point] ;
        }
        
    }
    else
    {
        // afegim el punt directament
        [self _doAddPoint:point] ;
    }
    
	if ( point.y > _bounds.max ) _bounds.max = point.y ;     // TO DO: a treure -repensar-
    if ( point.y < _bounds.min ) _bounds.min = point.y ;
}


- (void)setSequentialPointValues:(const SWPlotPoint [])points pointsCount:(NSInteger)pointCount triggerFactor:(double)factor
{
    if ( factor <= 0 )
        factor = 1;
    
    _numValues = 0;
    for ( int i=0 ; i<pointCount ; i++ )
    {
        SWPlotPoint point = points[i];
//        if ( i == pointCount-1 )
//        {
//            NSLog( @"time add point: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:points[i].x] );
//        }
        [self addPoint:point withTriggerFactor:factor];
    }
}


#pragma mark - Private Methods

- (void)_doAddPoint:(SWPlotPoint)point
{

    // si la capacitat excedeix la longitud descartem el mes antic
    if ( _numValues >= _allowed_capacity )
    {
        // non destructive mem move
        memmove(&_values[0], &_values[1], (_numValues-1)*sizeof(SWPlotPoint)) ;  
    }

    else
    {
        // incrementem el contador
        _numValues ++ ;
    
        // incrementem la mida
        [_valuesData setLength:_numValues*sizeof(SWPlotPoint)] ;
        
        // els punters poden haver canviat
        _values = [_valuesData mutableBytes] ;
    }

    // afegim al final del buffer
    //NSLog( @"_doAddPoint[%d]: %@", _numValues-1, [NSDate dateWithTimeIntervalSinceReferenceDate:point.x] );
    _values[_numValues-1] = point ;
}





@end


#pragma mark -
#pragma mark - PlotGroup
#pragma mark -

@implementation PlotGroup

//@synthesize timeScale ;
@synthesize plots ;

- (void)doInit
{
    //timeScale = kPGBoundsTimeScale60s ;
}


//---------------------------------------------------------------------
- (id)init
{
	if ( (self = [super init] ) )
    {
        [self doInit] ;
    	plots = [[NSMutableArray alloc] init] ;
    }
    return self ;
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) 
    {
        [self doInit] ; 
        plots = [decoder decodeObject] ;
    }
        
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:plots] ;
}


#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id)parent
{
    self = [super init] ;
    if (self) 
    {
        [self doInit] ;
        plots = [decoder decodeCollectionOfObjectsForKey:@"plots"] ;
    }
    return self ;
}

-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [encoder encodeCollectionOfObjects:plots forKey:@"plots"] ;
}


#pragma mark - Metodes

//---------------------------------------------------------------------
- (void)dealloc
{
}

//---------------------------------------------------------------------
//- (void)setTimeScale:(PGBoundsTimeScale)scale
//{
//	timeScale = scale ;
//}

//---------------------------------------------------------------------
- (BOOL)addPlotData:(RegionData*)plotData
{
    NSInteger indx = [plots indexOfObjectIdenticalTo:plotData] ;
    if ( indx != NSNotFound ) return NO ;
    [plots addObject:plotData] ;
    return YES ;
}

/*
//---------------------------------------------------------------------
- (NSInteger)indexOfPlotDataIdenticalTo:(PlotData*)plotData
{
	return [plots indexOfObjectIdenticalTo:plotData] ;
}

//---------------------------------------------------------------------
- (void)removePlotDataAtIndex:(NSInteger)indx ;
{
	[plots removeObjectAtIndex:indx] ;
}
*/

//---------------------------------------------------------------------
- (BOOL)removePlotDataIdenticalTo:(RegionData*)plotData
{
    NSInteger indx = [plots indexOfObjectIdenticalTo:plotData] ;
    if ( indx == NSNotFound ) return NO ;
	[plots removeObjectAtIndex:indx] ;
    return YES ;
}

/*
//---------------------------------------------------------------------
- (BOOL)removePlotDataAtIndex:(NSUInteger)indx
{
    if ( indx >= plots.count ) return NO ;
	[plots removeObjectAtIndex:indx] ;
    return YES ;
}
*/

//---------------------------------------------------------------------
- (NSInteger)plotsCount
{
    return [plots count] ;
}

@end

