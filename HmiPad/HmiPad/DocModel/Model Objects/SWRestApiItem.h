//
//  SWRestApiItem.h
//  HmiPad
//
//  Created by joan on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import "SWObject.h"

@interface SWRestApiItem : SWObject

@property (nonatomic,readonly) SWValue *baseApiUrl;
@property (nonatomic,readonly) SWValue *method;
@property (nonatomic,readonly) SWExpression *restPath;
@property (nonatomic,readonly) SWExpression *httpHeaders;
@property (nonatomic,readonly) SWExpression *requestBody;
@property (nonatomic,readonly) SWExpression *trigger;
@property (nonatomic,readonly) SWValue *gotResponse;
@property (nonatomic,readonly) SWValue *response;
@property (nonatomic,readonly) SWValue *statusCode;

@end
