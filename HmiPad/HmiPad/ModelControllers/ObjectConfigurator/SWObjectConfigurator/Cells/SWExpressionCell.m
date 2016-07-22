//
//  SWExpressionCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWExpressionCell.h"
#import "RoundedTextView.h"
#import "BubbleView.h"
#import "SWObject.h"
#import "SWPropertyDescriptor.h"

#import "SWModelBrowserController.h"
#import "SWColor.h"

NSString * const ExpressionCellIdentifier = @"ExpressionCellIdentifier";
NSString * const ExpressionCellNibName = @"SWExpressionCell";
NSString * const ExpressionCellNibName6 = @"SWExpressionCell6";

@implementation SWExpressionCell


@dynamic value;
@synthesize showsAsValue = _showsAsValue;
//@synthesize showsBrowserButton = _showsBrowserButton;
@synthesize expressionTextView = _expressionTextView;
@synthesize warningButton = _warningButton;
@synthesize detailButton = _detailButton;

#pragma mark Overriden Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    //[_expressionString setLeftView:self.detailButton];
    //_showsBrowserButton = YES;
    _showsAsValue = NO;
    
    UIImage *loupeImage = [UIImage imageNamed:@"01-magnify.png"];
    //UIImage *loupeImage = [UIImage imageNamed:@"search-25.png"];
    if ( IS_IOS7 )
    {
        //loupeImage = [loupeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
       // [_detailButton setTintColor:UIColorWithRgb(TangerineSelectionColor)];
    }
    [_detailButton setImage:loupeImage forState:UIControlStateNormal];
}


- (void)refreshAll
{
    [super refreshAll];
    
    [self refreshExpressionSourceString];
    [self _refreshState];
}


#pragma mark Properties

- (void)setValue:(SWExpression *)value
{
    [super setValue:value];
}


- (void)setShowsAsValue:(BOOL)showsAsValue
{
    _showsAsValue = showsAsValue;
    
    UIColor *color = nil ;
    if ( showsAsValue )
        color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    else
        color = [UIColor colorWithRed:1.0f green:1.0f blue:0.96f alpha:1.0f];

    [_expressionTextView setBackgroundColor:color];
}


#pragma mark Public Methods

- (IBAction)warningButtonPushed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(expressionCell:presentMessage:fromView:)])
    {
        NSString *msg = [_value getResultErrorString];
        [_delegate expressionCell:self presentMessage:msg fromView:sender];
    }
}


- (IBAction)configuratorButtonPushed:(id)sender
{
    [_delegate expressionCell:self presentExpressionConfiguratorFromView:_detailButton];
}


- (void)refreshExpressionSourceString
{
    _expressionTextView.smartText = [_value getSourceString];
    
    if ( !_showsAsValue )
    {
        ExpressionKind kind = self.value.kind;
        BOOL enabled = (kind == ExpressionKindSymb || kind == ExpressionKindConst);
        _detailButton.enabled = enabled;
    }
    
}

//- (void)setShowsBrowserButton:(BOOL)showsBrowserButton
//{
//    [self setShowsBrowserButton:showsBrowserButton animated:NO];
//}
//
//- (void)setShowsBrowserButton:(BOOL)showsBrowserButton animated:(BOOL)animated
//{    
//    [self _presentDetailButton:showsBrowserButton animated:animated];
//}


#pragma mark Private Methods


- (void)_refreshState
{
    SWValue *exp = (id)_value;
    BOOL stateOK = exp.state == ExpressionStateOk;
    BOOL managedRetains = [exp hasManagedObserverRetains];
    
    void (^block)(void) = ^
    {
        CGFloat showLabel = stateOK || managedRetains;
    
        _warningButton.alpha = showLabel?0:1  ;
        _valueAsStringLabel.alpha = showLabel?1:0;
        
        UIFont *font = managedRetains&&!stateOK?[UIFont italicSystemFontOfSize:14]:[UIFont boldSystemFontOfSize:14];
        [_valueAsStringLabel setFont:font];
    };
        
    if (self.superview == nil)
        block();
    else
        [UIView animateWithDuration:0.10 animations:block];
    
}




//- (void)_presentDetailButton:(BOOL)flag animated:(BOOL)animated
//{
//    if (flag == _showsBrowserButton)
//        return;
//    
//    _showsBrowserButton = flag;
//    
//    void (^before)(void);
//    void (^animations)(void);
//    void (^after)(void);
//    
//    if (flag) 
//    {
//        before = ^{
//            _detailButton.alpha = 0;
//            [self.contentView addSubview:_detailButton];
//        };
//        animations = ^{
//            CGRect frame = _expressionTextView.frame;
//            frame.origin.x = _detailButton.frame.origin.x + _detailButton.frame.size.width + 5;
//            frame.size.width -= _detailButton.frame.size.width + 5;
//            _expressionTextView.frame = frame;
//            _detailButton.alpha = 1;
//        };
//        after = ^{
//            
//        };
//    } 
//    else 
//    {
//        before = ^{
//
//        };
//        animations = ^{
//            CGRect frame = _expressionTextView.frame;
//            frame.origin.x = _detailButton.frame.origin.x;
//            frame.size.width += _expressionTextView.frame.origin.x - _detailButton.frame.origin.x;
//            _expressionTextView.frame = frame;
//            _detailButton.alpha = 0;
//        };
//        after = ^{
//            [_detailButton removeFromSuperview];
//            _detailButton.alpha = 1;
//        };
//    }
//    
//    if (animated) 
//    {
//        before();
//        [UIView animateWithDuration:0.25 animations:^{
//            animations();
//        } completion:^(BOOL finished) {
//            after();
//        }];
//    } 
//    else 
//    {
//        before();
//        animations();
//        after();
//    }
//}

#pragma mark Protocol Expression Observer

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{    
    [super value:value didEvaluateWithChange:changed];
    if ( _showsAsValue ) [self refreshExpressionSourceString];
}

//- (void)expression:(SWExpression *)expression didChangeState:(UInt8)oldState
- (void)expressionStateDidChange:(SWExpression *)expression
{
    [self _refreshState];
}

- (void)expressionSourceStringDidChange:(SWExpression *)expression
{
    [self refreshExpressionSourceString];
    
    if ( [_delegate respondsToSelector:@selector(expressionCellSourceStringDidChange:)] )
        [_delegate expressionCellSourceStringDidChange:self];
}

@end
