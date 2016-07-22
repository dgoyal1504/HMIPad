//
//  RoundedTextView.h
//  ScadaMobile
//
//  Created by Joan on 02/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedTextViewDelegate.h"


@protocol RoundedTextViewDelegate ;
@class InnerTextView ;


///////////////////////////////////////////////////////////////////////////////////
#pragma mark RoundedTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface RoundedTextView : UIView<UITextViewDelegate,FieldControllerReady>
{
    UIView *_rightView ;
    UIView *_leftView ;
    __weak id<RoundedTextViewDelegate> _deleg ;
    InnerTextView *_textView ;
    UITextBorderStyle _borderStyle ;
    //UIView *_inputAccessoryView;
    BOOL _isCallingMe;
}

@property(nonatomic,readonly) UITextView* textView;

@property(nonatomic,assign) BOOL acceptNewlines;
@property(nonatomic,readwrite) NSString* text;
@property(nonatomic,assign) NSRange selectedRange;
@property(nonatomic,assign) UITextBorderStyle borderStyle ;
@property(nonatomic,assign) BOOL wantsFixedOffset;
@property(nonatomic,assign) BOOL singleLine;
@property(nonatomic,retain) NSString *suggestionString;
@property(nonatomic,retain) UIColor *backgroundColor ;
@property(nonatomic,retain) UIColor *borderColor ;

@property(nonatomic,weak) IBOutlet id<RoundedTextViewDelegate> delegate;


- (CGSize)sizeThatFitsWidth:(CGFloat)width ;
- (void)setOverlay:(BOOL)show ;
- (void)setRightView:(UIView*)view;
- (void)setLeftView:(UIView*)view;

@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark ExpressionTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface ExpressionTextView : RoundedTextView
@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark ValueTextView
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface ValueTextView : RoundedTextView
@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark SMTextField
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface SWTextField : UITextField<FieldControllerReady>
@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark Label
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface UILabel(sizeThatFitsExtensions)

- (CGSize)sizeThatFitsWidth:(CGFloat)width ;

@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextField
///////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------
@interface UITextField(sizeThatFitsExtensions)

- (CGSize)sizeThatFitsWidth:(CGFloat)width ;

@end




