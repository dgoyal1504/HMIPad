//
//  SWSourceCell.h
//  HmiPad
//
//  Created by Joan Martin on 8/21/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectCell.h"

#import "SWSourceItem.h"

@class SWSourceItem;

typedef enum {
    SWSourceCellRightDetailTypeValueCount,
    SWSourceCellRightDetailTypeConnectionStatus
} SWSourceCellRightDetailType;

@interface SWSourceCell : SWObjectCell //<SourceItemObserver>

@property (nonatomic, strong) SWSourceItem *modelObject;
@property (nonatomic, assign) SWSourceCellRightDetailType rightDetailType;

@end