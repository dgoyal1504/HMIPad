//
//  SWTableSectionHeaderView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWTableSectionHeaderView : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIColor *tintsColor UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (id)initWithHeight:(CGFloat)height;  // default es 30

@end
