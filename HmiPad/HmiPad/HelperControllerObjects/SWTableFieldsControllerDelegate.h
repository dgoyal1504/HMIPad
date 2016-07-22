/*
 *  SWTableFieldsControllerDelegate.h
 *  HmiPad
 *
 *  Created by Joan on 16/05/2010.
 *  Copyright 2010 SweetWilliam, S.L. All rights reserved.
 *
 */
 
@class SWTableFieldsController ;

@protocol SWTableFieldsControllerDelegate<NSObject>

@optional
- (void)tableFieldsControllerDidStart:(SWTableFieldsController*)controller;
- (void)tableFieldsController:(SWTableFieldsController*)controller didProvideControl:(UIControl*)aControl animated:(BOOL)animated;
- (BOOL)tableFieldsController:(SWTableFieldsController*)controller validateField:(id)field 
        forCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath outErrorString:(NSString **)errorString;
- (UIView*)tableFieldsControllerBubblePresentingView:(SWTableFieldsController*)controller;

- (void)tableFieldsControllerWillStopWithCancel:(BOOL)cancel;

- (void)tableFieldsControllerCancel:(SWTableFieldsController*)controller animated:(BOOL)animated;

@required
- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated;

@end