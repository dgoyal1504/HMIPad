//
//  SWDatabaseCell.h
//  HmiPad
//
//  Created by Joan Lluch on 18/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectCell.h"

#import "SWDataLoggerItem.h"

@interface SWDatabaseCell : SWObjectCell

@property (nonatomic, strong) SWDataLoggerItem *modelObject;

@end
