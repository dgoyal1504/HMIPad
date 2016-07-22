//
//  SWBackgroundItemDatabase.h
//  HmiPad
//
//  Created by Joan Lluch on 18/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWObject.h"
@class SWHistoValuesDatabaseContext;

@interface SWDataLoggerItem : SWObject

@property (nonatomic,readonly) SWValue *databaseTimeRange;
@property (nonatomic,readonly) SWValue *databaseName;
@property (nonatomic,readonly) SWValue *databaseFile;
@property (nonatomic,readonly) SWValue *fieldNames;
@property (nonatomic,readonly) SWExpression *values;

//@property (nonatomic,readonly) SWHistoValuesDatabaseContext *dbContext;

@end
