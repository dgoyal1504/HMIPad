//
//  RoundedTextViewDelegate.h
//  ScadaMobile
//
//  Created by Joan on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RoundedTextView ;

@protocol RoundedTextViewDelegate<NSObject> 

@optional
- (BOOL)roundedTextViewShouldBeginEditing:(RoundedTextView *)roundedTextView ;
- (void)roundedTextViewDidBeginEditing:(RoundedTextView *)roundedTextView ;
- (void)roundedTextViewDidChange:(RoundedTextView *)textView ;
- (void)roundedTextViewDidChangeSelection:(RoundedTextView *)textView;
- (BOOL)roundedTextView:(RoundedTextView *)roundedTextView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string ;
- (BOOL)roundedTextViewShouldEndEditing:(RoundedTextView *)roundedTextView ;
- (void)roundedTextViewDidEndEditing:(RoundedTextView *)roundedTextView ;
- (BOOL)roundedTextViewShouldReturn:(RoundedTextView *)roundedTextView ;
//- (void)roundedTextViewControlTouched:(RoundedTextView *)roundedTextView ;

@end


@protocol FieldControllerReady<NSObject>

@property (nonatomic, assign) BOOL hasBullet ;
- (void)setSmartText:(NSString*)text ;

@end