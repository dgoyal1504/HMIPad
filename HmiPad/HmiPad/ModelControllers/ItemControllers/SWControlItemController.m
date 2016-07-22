//
//  SWControlItemController.m
//  HmiPad
//
//  Created by Joan on 21/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItemController.h"
#import "SWControlItem.h"


@interface SWControlItemController()<UIActionSheetDelegate>
{
    UIActionSheet *_actionSheet;
}
@end


@implementation SWControlItemController
{
    void (^completion)(BOOL, BOOL);
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_actionSheet dismissWithClickedButtonIndex:[_actionSheet cancelButtonIndex] animated:NO];
    _actionSheet = nil;
}


- (void)checkPointVerification:(id)noseQue completion:(void(^)(BOOL verified, BOOL success))block
{
    SWControlItem *item = (id)self.item;
    NSString *verificationText = [item.verificationText valueAsString];
    if ( verificationText.length == 0 )
    {
        if (block) block(NO, YES);
        return;
    }
    
    completion = block;
    
//    NSString *title = NSLocalizedString(@"Verification Alert", nil);
//    UIAlertView *alertView = [[UIAlertView alloc]
//        initWithTitle:title
//        message:verificationText
//        delegate:self
//        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
//        otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
//    
//    [alertView show];
    
    _actionSheet = [[UIActionSheet alloc]
        initWithTitle:verificationText delegate:self
        cancelButtonTitle:nil //NSLocalizedString(@"Cancel",nil)
        destructiveButtonTitle:nil
        otherButtonTitles:NSLocalizedString(@"Ok",nil), NSLocalizedString(@"Cancel",nil), nil];
    
    UIView *view = self.view;
//    [actionSheet showInView:view];
    [_actionSheet showFromRect:view.bounds inView:view animated:YES];
}



#pragma mark AlertViewDelegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex];
//    //NSInteger cancelButtonIndex = [alertView cancelButtonIndex];
//
//    if ( completion )
//        completion(buttonIndex == firstOtherButtonIndex);
//
//    completion = nil;
//}


#pragma mark ActionSheetDelegate

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstOtherButtonIndex = [actionSheet firstOtherButtonIndex];
//
//    if ( completion )
//        completion(buttonIndex == firstOtherButtonIndex);
//
//    completion = nil;
//
//}

//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
//{
//    for (UILabel *currentView in actionSheet.subviews)
//    {
//        if ([currentView isKindOfClass:[UILabel class]])
//        {
//            [currentView setFont:[UIFont boldSystemFontOfSize:15.f]];
//        }
//    }
//}


- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
// Utilitzem aquest en lloc de clickedButtonAtIndex: perque ens interesa captar el dismis programatic del viewWillDissapear
{
    NSInteger firstOtherButtonIndex = [actionSheet firstOtherButtonIndex];

    if ( completion )
        completion(YES, buttonIndex == firstOtherButtonIndex);

    completion = nil;
}







@end
