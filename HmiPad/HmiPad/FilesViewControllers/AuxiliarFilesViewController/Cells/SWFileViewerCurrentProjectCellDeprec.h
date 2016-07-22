//
//  SWTopFileViewerCell.h
//  HmiPad
//
//  Created by Joan on 14/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerCell.h"

@class SWFileViewerCurrentProjectCell;

@protocol SWFileViewerCurrentProjectCellDelegate<SWFileViewCellDelegate>

-(void)fileViewCellDidTouchUploadButton:(SWFileViewerCurrentProjectCell*)cell;

@end



@interface SWFileViewerCurrentProjectCell : SWFileViewerCell

@property (nonatomic) IBOutlet ColoredButton *buttonUpload;
//@property (nonatomic) IBOutlet UIProgressView *progressView;
//@property (nonatomic) IBOutlet UILabel *progressLabel;

//- (void)setProgressText:(NSString*)progressText;
//- (void)setProgressValue:(float)progress;
- (void)setDisabled:(BOOL)shouldDissable;

@end
