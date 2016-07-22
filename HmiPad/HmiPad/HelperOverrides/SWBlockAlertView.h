//
//  UIAlertView+Block.h
//  HmiPad
//
//  Created by Joan on 11/06/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWBlockAlertView : UIAlertView

- (void)setResultBlock:( void (^)(BOOL success, NSInteger index))resultBlock;

@end




@interface SWQuickAlert : NSObject

//+ (void)showAlertController:(UIAlertController *)alert;

+ (void)showAlertController:(UIViewController *)viewController;
+ (void)presentQuickAlertWithTitle:(NSString*)title message:(NSString*)message actionTitle:(NSString*)actionTitle handler:(void (^)(UIAlertAction *action))handler;
+ (void)presentQuickAlertWithTitle:(NSString*)title message:(NSString*)message actionTitle:(NSString*)actionTitle withCancel:(BOOL)withCancel
        handler:(void (^)(UIAlertAction *action))handler;
@end