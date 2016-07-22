//
//  PlotGroup.h
//  HmiPad
//
//  Created by Lluch Joan on 02/05/12.
//  Copyright (c) 2012 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickCoder.h"
#import "SymbolicCoder.h"

@class PlotData ;

////--------------------------------------------------------------------
//#pragma mark SWPlotRange
//
//struct SWPlotRange
//{
//    CFAbsoluteTime min ;
//    CFAbsoluteTime max ; 
//} ;
//typedef struct SWPlotRange SWPlotRange ;
//
//static inline SWPlotRange SWPlotRangeMake( CFAbsoluteTime min, CFAbsoluteTime max )
//{
//    SWPlotRange plotRange = { min, max } ;
//    return plotRange ;
//}

#pragma mark SWPlotRange

struct SWPlotRange
{
    double min ;
    double max ;
} ;
typedef struct SWPlotRange SWPlotRange ;

static inline SWPlotRange SWPlotRangeMake( double min, double max )
{
    SWPlotRange plotRange = { min, max } ;
    return plotRange ;
}

//--------------------------------------------------------------------
#pragma mark SWBounds

struct SWBounds
{
	double min ;
	double max ;
};
typedef struct SWBounds SWBounds;

static inline SWBounds SWBoundsMake(double min, double max)
{
  SWBounds p = { min, max } ; 
  return p;
}

//--------------------------------------------------------------------
#pragma mark SWPlotPoint

struct SWPlotPoint
{
    //CFAbsoluteTime x ;
    double x ;
    double y ;
} ;
typedef struct SWPlotPoint SWPlotPoint ;

//static inline SWPlotPoint SWPlotPointMake( CFAbsoluteTime x, double y )
static inline SWPlotPoint SWPlotPointMake( double x, double y )
{
    SWPlotPoint plotPoint = { x, y } ;
    return plotPoint ;
}


#pragma mark RegionData

@interface RegionData : NSObject <QuickCoding, SymbolicCoding>
{
    id _plotKey ;
    
    UInt32 _plotRgbColor ;
    SWBounds _bounds ;
    
    unsigned int _numValues ;
    NSMutableData *_valuesData ;
    SWPlotPoint *_values ;  // apunta al mutableBytes de _valuesData
}


@property (nonatomic, readonly) id plotKey ;
@property (nonatomic, readonly) SWBounds bounds ;
@property (nonatomic, assign) UInt32 plotRgbColor ;

- (id)initWithPlotKey:(id)key bounds:(SWBounds)bounds ;

//- (void)prepareForXRange:(SWPlotRange)xRange;

//- (void)prepareForPointsCount:(NSInteger)count;
- (void)setRegionXStart:(double)xStart xInterval:(double)xInterval;
- (void)setRegionValues:(const double [])points pointsCount:(NSInteger)count xStart:(double)xStart xInterval:(double)xInterval;
- (SWPlotRange)xRange;

- (NSData *)pointsForXRange:(SWPlotRange)xRange ;   // torna un c_array de SWPlotPoint en un NSData


@end


#pragma mark PlotData

@interface PlotData : RegionData

- (void)addPoint:(SWPlotPoint)point ;
//- (void)setSequentialPointValues:(const SWPlotPoint [])points pointsCount:(NSInteger)count;
- (void)setSequentialPointValues:(const SWPlotPoint [])points pointsCount:(NSInteger)pointCount triggerFactor:(double)factor;

@end


#pragma mark PlotGroup

@interface PlotGroup : NSObject <QuickCoding, SymbolicCoding>
{
    NSMutableArray *plots ;  // conte objectes de tipus PlotData
}

@property (nonatomic, readonly) NSArray *plots ;  // atencio que la propietat que exposem es NSArray tot i que internament es un NSMutableArray

- (BOOL)addPlotData:(RegionData*)plotData ;  // torna YES si ho ha fet, NO si ja hi era
- (BOOL)removePlotDataIdenticalTo:(RegionData*)plotData ; // torna YES hi ho ha fet, NO si no hi era
- (NSInteger)plotsCount ;

@end

