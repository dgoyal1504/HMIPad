//
//  SWGroupLayoutViewCell.h
//  HmiPad
//
//  Created by Joan Lluch on 31/12/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayoutViewCell.h"

@class SWLayoutView;

@interface SWGroupLayoutViewCell : SWLayoutViewCell

@property (nonatomic, readonly) SWLayoutView *contentLayoutView;

@end
