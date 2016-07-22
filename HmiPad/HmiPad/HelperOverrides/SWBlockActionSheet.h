//
//  UIAlertView+Block.h
//  HmiPad
//
//  Created by Joan on 11/06/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWBlockActionSheet : UIActionSheet

- (void)setResultBlock:( void (^)(BOOL success, NSInteger index))resultBlock;

@end
