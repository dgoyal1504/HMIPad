//
//  SWErrorPresenterViewController.h
//  HmiPad
//
//  Created by Joan on 12/09/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWErrorPresenterViewController : UIViewController

@property (nonatomic,strong) IBOutlet UITextView *textView;

- (void)setTitle:(NSString*)title;
- (void)setMessage:(NSString*)message;

@end
