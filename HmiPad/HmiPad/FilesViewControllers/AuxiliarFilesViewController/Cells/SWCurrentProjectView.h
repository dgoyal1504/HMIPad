//
//  SWTopFileViewerCell.h
//  HmiPad
//
//  Created by Joan on 14/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

//#import "SWFileViewerCell.h"

@class SWCurrentProjectView;
@class SWCircleButton;
//@class ColoredButton;

@protocol SWCurrentProjectViewDelegate<NSObject>

-(void)currentProjectViewDidTouchUploadButton:(SWCurrentProjectView*)view;
-(void)currentProjectViewDidTouchDuplicateButton:(SWCurrentProjectView*)view;
-(void)currentProjectViewDidTouchCloseButton:(SWCurrentProjectView*)view;
-(void)currentProjectViewDidTouchImageButton:(SWCurrentProjectView*)view;

@end



@interface SWCurrentProjectView : UIView

@property (nonatomic, weak) id<SWCurrentProjectViewDelegate>delegate;
//@property (nonatomic) IBOutlet UIImageView *imageViewThumbnail;
@property (nonatomic) IBOutlet UIButton *buttonImage;
@property (nonatomic) IBOutlet UILabel *labelFileName;
@property (nonatomic) IBOutlet UILabel *labelFileIdent;
@property (nonatomic) IBOutlet UILabel *labelModDate;
@property (nonatomic) IBOutlet UILabel *labelSize;
@property (nonatomic) IBOutlet UILabel *labelPrompt1;
@property (nonatomic) IBOutlet UILabel *labelPrompt2;
@property (nonatomic) IBOutlet UILabel *labelPrompt3;


@property (nonatomic) IBOutlet UILabel *labelPromptUpdate;
@property (nonatomic) IBOutlet UILabel *labelPromptDuplicate;
@property (nonatomic) IBOutlet UILabel *labelPromptClose;


@property (nonatomic) IBOutlet UILabel *emptyLabel;

@property (nonatomic) BOOL buttonUploadDisabled;
@property (nonatomic) BOOL viewsDisabled;
@property (nonatomic) BOOL runOnly;

@property (nonatomic) IBOutlet UILabel *labelUseAssets;
@property (nonatomic) IBOutlet UILabel *labelAssets;
@property (nonatomic) IBOutlet UISwitch *switchEmbedded;
@property (nonatomic) IBOutlet UITableView *tableAssets;
//@property (nonatomic) IBOutlet UITableView *tableEmbeededAssets;

@property (nonatomic) IBOutlet SWCircleButton *buttonUpload;
@property (nonatomic) IBOutlet SWCircleButton *buttonDuplicate;
@property (nonatomic) IBOutlet SWCircleButton *buttonClose;

- (IBAction)buttonImageTouched:(id)sender;
- (IBAction)buttonUploadTouched:(id)sender;
- (IBAction)buttonDuplicateTouched:(id)sender;
- (IBAction)buttonCloseTouched:(id)sender;

@end
