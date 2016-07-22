//
//  SWSystemItemScanner.h
//  HmiPad
//
//  Created by Joan Lluch on 03/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

@interface SWSystemItemScanner : SWSystemItem

@property (nonatomic,readonly) SWExpression *scan;
@property (nonatomic,readonly) SWValue *scanResult;

@end
