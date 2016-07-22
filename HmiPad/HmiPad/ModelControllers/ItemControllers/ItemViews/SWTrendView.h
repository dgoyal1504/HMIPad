//
//  SWTrendView.h
//  HmiPad
//
//  Created by Joan on 29/04/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlotGroup.h"
#import "SWEnumTypes.h"

@class SWTrendView ;

#pragma mark SWTrendViewDataSource

@protocol SWTrendViewDataSource <NSObject>

//- (NSInteger)numberOfRecordsForPlotWithIdentifier:(id)ident ;
//- (NSData *)pointsForPlotWithIdentifier:(id)ident inRange:(SWPlotRange)range;
- (NSArray*)pointsForPlotsWithIdentifiers:(NSArray*)idents inRange:(SWPlotRange)range;

@end

@protocol SWTrendViewDelegate <NSObject>
@optional

//- (void)trendView:(SWTrendView*)trendView didFinishGestureWithXRange:(SWPlotRange)range;
- (void)trendView:(SWTrendView*)trendView didFinishGestureWithPlotInterval:(double)xInterval xOffset:(double)xOffset;

@end

#pragma mark SWTrendView

@interface SWTrendView : UIView

@property (nonatomic,weak) id<SWTrendViewDataSource> dataSource;
@property (nonatomic,weak) id<SWTrendViewDelegate> delegate;

// propietats
@property (nonatomic, assign) SWTrendStyle style;
@property (nonatomic, assign) SWChartType chartType;
@property (nonatomic, assign) SWTrendUpdatingStyle updatingStyle;
@property (nonatomic, assign) BOOL gesturesEnabled;

@property (nonatomic, assign) CFTimeInterval xMajorTickInterval ;
@property (nonatomic, assign) int xMinorTicksPerInterval ;
@property (nonatomic, assign) double yMajorTickInterval ;
@property (nonatomic, assign) int yMinorTicksPerInterval ;
@property (nonatomic, strong) UIColor *tintsColor ;
@property (nonatomic, strong) UIColor *borderColor ;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, assign) CFTimeInterval maxZoomInterval;


// afagir i treure plots
- (void)addPlotWithIdentifier:(id)ident ;  // last one is on top
- (void)removePlotWithIdentifier:(id)ident ;
- (void)removeAllPlots ;

// plotejat conjunt
- (void)reloadPlotsAnimated:(BOOL)animated;
//- (void)reloadFetchedPlotsWithRange:(SWPlotRange)dataRange animated:(BOOL)animated;

// plotejat individual
//- (void)reloadPlotWithIdentifier:(id)ident ;
//- (void)setXRangeForPlotWithIdentifier:(id)ident animated:(BOOL)animated ;  // posa el rang del eix x
- (void)setYRange:(SWBounds)range forPlotWithIdentifier:(id)ident animated:(BOOL)animated;
- (void)setColor:(UIColor*)color forPlotWithIdentifier:(id)ident;
- (void)setColorFill:(UIColor *)color forPlotWithIdentifier:(id)ident;
- (void)setSymbol:(BOOL)symbol forPlotWithIdentifier:(id)ident;

// plotejat estatic (chart)
- (void)setXAxisRange:(SWPlotRange)xAxisRange animated:(BOOL)animated ;
- (void)setYAxisRange:(SWBounds)yAxisRange animated:(BOOL)animated ;

// plotejat dinamic (time chart)
- (void)setXRangeOffset:(CFTimeInterval)offset ;      // passar 0 per refresc dinamic
- (void)setXPlotInterval:(CFTimeInterval)length ;     // passar negatiu per display invertit
- (void)resetViewUpdating ;
- (void)stopViewUpdating ;

// gesture settings
- (void)setMaxZoomInterval:(CFTimeInterval)maxZoomInterval;



@end

