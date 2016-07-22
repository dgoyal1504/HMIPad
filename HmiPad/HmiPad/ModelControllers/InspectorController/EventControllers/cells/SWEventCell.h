//
//  SWEventCell.h
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWDrawRectCell.h"

@class SWEvent;

//@interface SWEventCell : UITableViewCell
@interface SWEventCell : SWDrawRectCell

@property (nonatomic, weak) IBOutlet UILabel *eventLabelLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventCommentLabel;
@property (nonatomic, weak) IBOutlet UIImageView *alarmImageView;

@property (nonatomic, weak) SWEvent *event;
@property (nonatomic) BOOL isHisto;
//- (void)prepareForDisplay;

- (CGFloat)heightForComment:(NSString*)comment;

@end
