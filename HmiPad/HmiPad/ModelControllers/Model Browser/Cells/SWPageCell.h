//
//  SWPageCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectCell.h"

#import "SWPage.h"

typedef enum {
    SWPageCellRightDetailTypeItemCount,
    SWPageCellRightDetailTypeValueCount
} SWPageCellRightDetailType;

@interface SWPageCell : SWObjectCell <PageObserver>

@property (nonatomic, strong) SWPage *modelObject;
@property (nonatomic, assign) SWPageCellRightDetailType rightDetailType;

@end
