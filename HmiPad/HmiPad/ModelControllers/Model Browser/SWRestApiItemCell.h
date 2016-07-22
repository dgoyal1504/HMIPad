//
//  SWRestApiItemCell.h
//  HmiPad
//
//  Created by Joan Lluch on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectCell.h"

#import "SWRestApiItem.h"

@interface SWRestApiItemCell : SWObjectCell

@property (nonatomic, strong) SWRestApiItem *modelObject;

@end