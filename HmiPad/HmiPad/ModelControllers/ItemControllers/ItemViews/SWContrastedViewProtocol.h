//
//  UIView+SWContrastedView.h
//  HmiPad
//
//  Created by Joan Lluch on 09/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SWContrastedViewProtocol <NSObject>
- (void)setContrastForBackgroundColor:(UIColor *)color;
@end

//@interface UIView ()<SWContrastedViewProtocol>
//@end