//
//  SWMasterDetailViewControllerDelegate.h
//  HmiPad
//
//  Created by Joan Lluch on 11/23/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SWZoomableViewController <NSObject>

//- (void)setViewContentScaleFactor:(CGFloat)contentScale;
@required
//- (void)setViewZoomScaleFactor:(CGFloat)zoomScale;
//- (CGFloat)zoomScaleFactor;
@property (nonatomic,assign) CGFloat zoomScaleFactor;
@optional
- (void)willBeginZooming;
- (void)didEndZooming;

@end

