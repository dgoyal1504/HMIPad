//
//  SWFileViewerHeaderView.h
//  HmiPad
//
//  Created by Joan on 10/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWFileViewerHeaderView;

@protocol SWFileViewerHeaderViewDelegate<NSObject>
- (void)fileViewerHeaderView:(SWFileViewerHeaderView*)viewerHeader didSelectSegmentAtIndex:(NSInteger)indx;
@end


@interface SWFileViewerHeaderView : UIView

@property (nonatomic) IBOutlet UISegmentedControl *segmented;
- (IBAction)segmentedValueChanged:(id)sender;

@property (nonatomic, weak) id<SWFileViewerHeaderViewDelegate>delegate;
- (void)setSegmentedValue:(NSInteger)value;

@end
