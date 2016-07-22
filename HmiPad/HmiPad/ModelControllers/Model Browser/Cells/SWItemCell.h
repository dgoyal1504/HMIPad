//
//  SWItemCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectCell.h"

#import "SWItem.h"

@interface SWItemCell : SWObjectCell <SWItemObserver, UIGestureRecognizerDelegate>

@property (nonatomic, strong) SWItem *modelObject;

@end
