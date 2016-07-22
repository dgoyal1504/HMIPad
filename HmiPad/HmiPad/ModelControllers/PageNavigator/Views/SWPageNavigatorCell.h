//
//  SWPageNavigatorCell.h
//  HmiPad
//
//  Created by Joan Martin on 1/16/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWDrawRectCell.h"

extern NSString * const SWPageNavigatorCellIdentifier;
extern NSString * const SWPageNavigatorCellNibName;
extern NSString * const SWPageNavigatorCellNibName_Phone;

//@class SWPageNavigatorCell;
//
//@protocol SWPageNavigatorCellDelegate<NSObject>
//- (void)pageNavigatorCellButtonTouched:(SWPageNavigatorCell*)cell;
//@end



@class SWPage;
@class SWCustomHighlightedButton;

@interface SWPageNavigatorCell : UITableViewCell
//@interface SWPageNavigatorCell : SWDrawRectCell

@property (weak, nonatomic) IBOutlet UILabel *modalLabel;
@property (weak, nonatomic) IBOutlet UILabel *hiddenLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet SWCustomHighlightedButton *previewImageButton;

- (IBAction)previewImageButtonTouched:(id)sender;
//@property (weak, nonatomic) id<SWPageNavigatorCellDelegate>delegate;

@property (nonatomic,retain) SWPage *page;

+ (CGFloat)preferredHeight;

// per cridar desde el controlador
//- (void)prepareForDisplayAnimated:(BOOL)animated;
- (void)beginObservingModel;
- (void)endObservingModel;

@end
