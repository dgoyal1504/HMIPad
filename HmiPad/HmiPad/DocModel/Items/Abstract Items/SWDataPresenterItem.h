//
//  SWDataPresenter.h
//  HmiPad
//
//  Created by Joan Lluch on 01/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@class SWDatabaseContext;

@interface SWDataPresenterItem : SWItem

@property (nonatomic,readonly) SWValue *databaseFile;
@property (nonatomic,readonly) SWValue *databaseTimeRange;
@property (nonatomic,readonly) SWExpression *databaseName;
@property (nonatomic,readonly) SWExpression *referenceTime;

@end
