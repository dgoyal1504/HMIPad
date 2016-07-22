//
//  UIAlertView+Block.m
//  HmiPad
//
//  Created by Joan on 11/06/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBlockAlertView.h"

@interface SWBlockAlertView()<UIAlertViewDelegate>
{
    void (^_resultBlock)(BOOL success, NSInteger index);
}
@end

@implementation SWBlockAlertView

- (void)setResultBlock:( void (^)(BOOL success, NSInteger index))resultBlock
{
    self.delegate = self;
    _resultBlock = resultBlock;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger cancelIndex = [alertView cancelButtonIndex];
    BOOL success = !( buttonIndex == cancelIndex );
    if ( _resultBlock )
        _resultBlock(success,buttonIndex);
    
    _resultBlock = nil;  // ens carreguem _resultBlock per evitar retain cicles
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _resultBlock = nil;
}


@end




@implementation SWQuickAlert


+ (void)showAlertController:(UIViewController *)viewController
{
    UIViewController *topPresentedController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    UIViewController *controller=nil;
    while ( (controller=topPresentedController.presentedViewController) != nil )
        topPresentedController = controller;

    [topPresentedController presentViewController:viewController animated:YES completion:nil];
}


+ (void)presentQuickAlertWithTitle:(NSString*)title message:(NSString*)message actionTitle:(NSString*)actionTitle handler:(void (^)(UIAlertAction *action))handler
{
    [self presentQuickAlertWithTitle:title message:message actionTitle:actionTitle withCancel:NO handler:handler];
}


+ (void)presentQuickAlertWithTitle:(NSString*)title message:(NSString*)message actionTitle:(NSString*)actionTitle withCancel:(BOOL)withCancel
        handler:(void (^)(UIAlertAction *action))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if ( withCancel )
    {
        NSString *cancelText = NSLocalizedString(@"Cancel", nil);
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:handler];
    [alert addAction:action];
    
    [self showAlertController:alert];
}

@end