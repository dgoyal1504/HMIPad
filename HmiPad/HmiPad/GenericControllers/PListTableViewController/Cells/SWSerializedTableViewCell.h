//
//  SWSerializedTableViewCell.h
//  HmiPad
//
//  Created by Joan on 31/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *SWSerializedTableViewCellIdentifier;
extern NSString *SWSerializedTableViewCellNibName;
extern NSString *SWSerializedTableViewCellNibName6;

#define SWSerializedTableViewIdentifierImageSize (CGSizeMake(60,40))

@interface SWSerializedTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *labelMain;
@property (nonatomic) IBOutlet UILabel *labelDetail;
@property (nonatomic) IBOutlet UIImageView *imageViewThumbnail;

@property (nonatomic) BOOL shouldApplyImageBorder;

- (CGFloat)heightForComment:(NSString*)comment;

@end
