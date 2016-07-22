//
//  SWTagCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/23/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWExpression.h"

//#import "SWDrawRectCell.h"
#import "SWValueCell.h"

extern NSString *SWTagCellNibName;
extern NSString *SWTagCellNibName6;

extern NSString *SWTagCellIdentifier;


@class SWTagCell;

@class SWSourceNode;
@class SWExpression;
@class SWTagCell;

@protocol SWTagCellDelegate <SWValueCellDelegate>

@optional
- (void)tagCell:(SWTagCell*)cell presentMessage:(NSString*)msg fromView:(UIView*)view;
- (void)tagCellDismissMessage:(SWTagCell*)cell;
@end




@interface SWTagCell : SWValueCell <ExpressionObserver, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIButton *infoButton;
- (IBAction)warningButtonPushed:(id)sender;

@property (nonatomic, weak) id<SWTagCellDelegate>delegate;
- (void)setExpressionFieldTextColor:(UIColor *)expressionFieldTextColor;
@property (nonatomic,weak) SWSourceNode *sourceNode;

- (void)beginObservingModel;
- (void)endObservingModel;

@end
