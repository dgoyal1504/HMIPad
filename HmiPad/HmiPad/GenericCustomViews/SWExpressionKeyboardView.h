//
//  SWExpressionKeyboardView.h
//  HmiPad
//
//  Created by Hermes Pique on 5/9/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#define USE_UIINPUTVIEW 0

@class SWKeyboardKey;
@class SWKeyboardTouchAndHoldKey;

@protocol SWExpressionKeyboardViewDelegate;

#if USE_UIINPUTVIEW
@interface SWExpressionKeyboardView : UIInputView<UIInputViewAudioFeedback>
#else
@interface SWExpressionKeyboardView : UIView<UIInputViewAudioFeedback>
#endif
{
    __weak IBOutlet SWKeyboardTouchAndHoldKey *_backspaceButton;
    __weak IBOutlet SWKeyboardKey *_connectorsKey;
    __weak IBOutlet SWKeyboardTouchAndHoldKey *_leftButton;
    __weak IBOutlet UIButton *_modeButton;
    __weak IBOutlet SWKeyboardTouchAndHoldKey *_rightButton;
    __weak IBOutlet SWKeyboardKey *_seekerKey;
}

@property (weak, nonatomic) id<SWExpressionKeyboardViewDelegate> delegate;
@property (weak, nonatomic) id<UITextInput> textInput;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *leftKeypadButtons;

- (IBAction)customKeyTouchUp:(id)sender;
- (IBAction)introTouchUp:(id)sender;
- (IBAction)keyTouchUp:(id)sender;
- (IBAction)keyTouchDown:(id)sender;
//- (IBAction)modeTouchUp:(id)sender;
- (IBAction)modeTouchDown:(id)sender;
- (IBAction)quoteTouchUp:(id)sender;

@end

@protocol SWExpressionKeyboardViewDelegate <NSObject>

//- (void) keyboard:(SWExpressionKeyboardView*)keyboard touchUpInsideCustomKey:(UIButton*)sender;

- (void)keyboard:(SWExpressionKeyboardView *)keyboard didTapSeekerKey:(UIView *)revealView;
- (void)keyboard:(SWExpressionKeyboardView *)keyboard didTapConnectorsKey:(UIView *)revealView;

@end
