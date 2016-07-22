//
//  SWExpressionInputController.h
//  HmiPad
//
//  Created by Joan on 13/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RpnBuilder;
@class RoundedTextView;
@class SWExpressionInputController;
//@class SWDocumentModel;
@class SWModelManager;

@protocol SWExpressionInputControllerDelegate<NSObject>

- (void)expressionInputControllerApply:(SWExpressionInputController*)controller;
- (void)expressionInputControllerCancel:(SWExpressionInputController*)controller;


//- (void)expressionInputControllerWillDismiss:(SWExpressionInputController*)controller;
//- (void)expressionInputControllerDidDismiss:(SWExpressionInputController*)controller;

@end

@interface SWExpressionInputController : NSObject

- (id)initWithModelManager:(SWModelManager*)manager;
@property (nonatomic, weak) id<SWExpressionInputControllerDelegate> delegate;

- (BOOL)shouldPrepareForTextResponder:(RoundedTextView *)textResponder;
- (void)setTextResponder:(RoundedTextView *)textResponder;

- (void)resignResponder;

@end
