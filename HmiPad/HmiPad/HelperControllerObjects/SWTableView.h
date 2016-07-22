//
//  SWTableView.h
//  HmiPad
//
//  Created by Joan on 25/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWTableView : UITableView

@property (nonatomic,assign) CGPoint tableViewOffset;
- (void)adjustKeyboardInsetsIfNeeded;

@end


@interface UIViewController(TableViewOffset)

@property(nonatomic,assign) CGPoint tableViewOffset;
- (void)adjustKeyboardInsetsIfNeeded;
- (NSArray*)visibleViewControllers;
@end