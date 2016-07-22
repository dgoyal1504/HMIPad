//
//  SWDocumentStatusView.h
//  HmiPad
//
//  Created by Joan Lluch on 05/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SWDocumentStatusView;

@protocol SWDocumentStatusViewDelegate <NSObject>
@optional
- (void)documentStatusViewDidTouchUp:(SWDocumentStatusView*)statusView;
@end



@class SWDocumentModel;

@interface SWDocumentStatusView : UIView


@property (nonatomic) IBOutlet UIView *contentView;

@property (nonatomic) IBOutlet UILabel *labelUser;
@property (nonatomic) IBOutlet UIImageView *imageViewAlarm;
@property (nonatomic) IBOutlet UILabel *labelAlarm;
@property (nonatomic) IBOutlet UIImageView *imageViewTag;
@property (nonatomic) IBOutlet UILabel *labelTag;
@property (nonatomic) IBOutlet UIImageView *imageViewConnection;
@property (nonatomic) IBOutlet UILabel *labelConnection;

@property (nonatomic,weak) SWDocumentModel *documentModel;
@property (nonatomic,weak) id<SWDocumentStatusViewDelegate> delegate;

@end
