//
//  SWUploadUploadButtonCell.h
//  HmiPad
//
//  Created by Joan on 02/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColoredButton.h"

@class SWUploadBuyProductButtonCell;

@protocol SWUploadBuyProductButtonCellDelegate<NSObject>

- (void)buyProductCellDidTouchBuy:(SWUploadBuyProductButtonCell*)cell;

@end


@interface SWUploadBuyProductButtonCell : UITableViewCell


@property (nonatomic) IBOutlet ColoredButton *buttonBuy;
@property (nonatomic) IBOutlet UILabel *labelProduct;

@property (nonatomic,weak) id<SWUploadBuyProductButtonCellDelegate> delegate;
@property (nonatomic) id skProduct;

- (IBAction)buyProductAction:(id)sender;

@end
