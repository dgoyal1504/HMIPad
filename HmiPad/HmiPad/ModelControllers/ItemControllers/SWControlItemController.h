//
//  SWControlItemController.h
//  HmiPad
//
//  Created by Joan on 21/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWItemController.h"

@interface SWControlItemController : SWItemController

- (void)checkPointVerification:(id)noseQue completion:(void(^)(BOOL verified, BOOL success))block;

@end
