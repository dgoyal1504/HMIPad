//
//  SWExpressionCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueCell.h"
#import "SWExpression.h"

//@class SWColorCoverView;
@class ExpressionTextView;
@class SWExpressionCell;
@class SWPropertyDescriptor;

extern NSString * const ExpressionCellIdentifier;
extern NSString * const ExpressionCellNibName;
extern NSString * const ExpressionCellNibName6;


@protocol SWExpressionCellDelegate <SWValueCellDelegate>

@required
- (void)expressionCell:(SWExpressionCell*)cell presentMessage:(NSString*)msg fromView:(UIView*)view;
- (void)expressionCell:(SWExpressionCell*)cell presentExpressionConfiguratorFromView:(UIView*)view;
- (void)expressionCellSourceStringDidChange:(SWExpressionCell*)cell;

@end

@interface SWExpressionCell : SWValueCell <ExpressionObserver> 
{
//    BOOL _showsBrowserButton;
    BOOL _showsAsValue;
}

@property (nonatomic, strong) SWExpression *value;

//@property (nonatomic, assign) BOOL showsBrowserButton;
@property (nonatomic, assign) BOOL showsAsValue;
@property (nonatomic, weak) id<SWExpressionCellDelegate>delegate;

@property (nonatomic, weak) IBOutlet ExpressionTextView *expressionTextView;
@property (nonatomic, strong) IBOutlet UIButton *warningButton;
@property (nonatomic, strong) IBOutlet UIButton *detailButton;


- (IBAction)configuratorButtonPushed:(id)sender;
- (IBAction)warningButtonPushed:(id)sender;
- (void)refreshExpressionSourceString;

//- (void)setShowsBrowserButton:(BOOL)showsBrowserButton animated:(BOOL)animated;

@end
