//
//  SWFileViewCell.h
//  HmiPad
//
//  Created by Joan on 08/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWDrawRectCell.h"
#import "SWCircleButton.h"
#import "VerticallyAlignedLabel.h"

extern NSString * const SWFileViewerCellIdentifier;
extern NSString * const SWFileViewerCurrentProjectCellIdentifier;
extern NSString * const SWFileViewerProjectCellIdentifier;
extern NSString * const SWFileViewerRemoteProjectCellIdentifier;
extern NSString * const SWFileViewerRemoteAssetCellIdentifier;
extern NSString * const SWFileViewerRemoteActivationCodeCellIdentifier;
extern NSString * const SWFileViewerRemoteRedemptionCellIdentifier;

@class SWFileViewerCell;
@class ColoredButton;


@protocol SWFileViewerCellProtocol

@property (nonatomic) IBOutlet UIButton *buttonImage;
@property (nonatomic) IBOutlet VerticallyAlignedLabel *labelFileName;
@property (nonatomic) IBOutlet UILabel *labelFileIdent;
@property (nonatomic) IBOutlet UILabel *labelModDate;
@property (nonatomic) IBOutlet UILabel *labelSize;
@property (nonatomic) IBOutlet UIButton *buttonInclude;

@property (nonatomic) BOOL shouldHideButton;
@property (nonatomic) BOOL shouldApplyImageBorder;

@end



@protocol SWFileViewCellDelegate<NSObject>
-(void)fileViewCellDidTouchRevealButton:(SWFileViewerCell*)cell;
-(void)fileViewCellDidTouchIncludeButton:(SWFileViewerCell*)cell;
-(void)fileViewCellDidTouchImageButton:(SWFileViewerCell*)cell;
@end

@class SWCircleButton;

@interface SWFileViewerCell : SWDrawRectCell<SWFileViewerCellProtocol> //UITableViewCell
{
    //__weak id<SWFileViewCellDelegate> _delegate;  //DDDD // <-- protected access to the delegate
    BOOL _shouldIndentImageWhileEditing;
}


@property (nonatomic, weak) id<SWFileViewCellDelegate>delegate;
//@property (nonatomic) IBOutlet UIImageView *imageViewThumbnail;
@property (nonatomic) IBOutlet UIButton *buttonImage;
//@property (nonatomic) IBOutlet UILabel *labelFileName;
@property (nonatomic) IBOutlet VerticallyAlignedLabel *labelFileName;
@property (nonatomic) IBOutlet UILabel *labelFileIdent;
@property (nonatomic) IBOutlet UILabel *labelModDate;
@property (nonatomic) IBOutlet UILabel *labelSize;
@property (nonatomic) IBOutlet UIButton *buttonInclude;
@property (nonatomic) IBOutlet UIButton *buttonReveal;
@property (nonatomic) IBOutlet SWCircleButton *buttonTick;

@property (nonatomic) BOOL shouldHideButton;
@property (nonatomic) BOOL shouldHideButtonReveal;
@property (nonatomic) BOOL shouldHideButtonTick;
@property (nonatomic) BOOL shouldApplyImageBorder;

- (IBAction)buttonRevealTouched:(id)sender;
- (IBAction)buttonIncludeTouched:(id)sender;
- (IBAction)buttonImageTouched:(id)sender;

@end
