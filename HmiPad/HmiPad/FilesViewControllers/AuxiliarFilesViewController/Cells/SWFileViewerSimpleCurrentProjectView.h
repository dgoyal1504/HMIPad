//
//  SWTopFileViewerCell.h
//  HmiPad
//
//  Created by Joan on 14/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

//#import "SWFileViewerCell.h"

@class SWFileViewerSimpleCurrentProjectView;
@class ColoredButton;

@protocol SWFileViewerSimpleCurrentProjectViewDelegate<NSObject>

-(void)simpleCurrentProjectViewDidTouchIncludeButton:(SWFileViewerSimpleCurrentProjectView*)view;
-(void)simpleCurrentProjectViewDidTouchImageButton:(SWFileViewerSimpleCurrentProjectView*)view;

@end


@interface SWFileViewerSimpleCurrentProjectView : UIView

@property (nonatomic, weak) id<SWFileViewerSimpleCurrentProjectViewDelegate>delegate;

@property (nonatomic) IBOutlet UILabel *labelFileName;
@property (nonatomic) IBOutlet UILabel *labelFileIdent;
@property (nonatomic) IBOutlet UILabel *labelModDate;
@property (nonatomic) IBOutlet UILabel *labelSize;
@property (nonatomic) IBOutlet UILabel *emptyLabel;
@property (nonatomic) IBOutlet UILabel *labelPrompt1;
@property (nonatomic) IBOutlet UILabel *labelPrompt2;
@property (nonatomic) IBOutlet ColoredButton *buttonInclude;
@property (nonatomic) IBOutlet UIButton *buttonImage;

@property (nonatomic) BOOL disabled;

- (IBAction)buttonIncludeTouched:(id)sender;
- (IBAction)buttonImageTouched:(id)sender;

@end
