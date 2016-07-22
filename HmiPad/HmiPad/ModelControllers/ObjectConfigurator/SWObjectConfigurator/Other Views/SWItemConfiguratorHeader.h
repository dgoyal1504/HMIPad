//
//  SWItemConfiguratorHeader.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/21/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableSectionHeaderView.h"

@class SWItemConfiguratorHeader;





@interface SWItemConfiguratorHeader : SWTableSectionHeaderView

@property (weak, nonatomic) IBOutlet UIImageView *imageButton;

- (void)expand:(BOOL)flag animated:(BOOL)animated;

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

- (void)setTarget:(id)target andAction:(SEL)action;

@end
