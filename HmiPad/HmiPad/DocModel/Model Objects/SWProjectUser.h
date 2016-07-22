//
//  SW.h
//  HmiPad
//
//  Created by Joan Lluch on 25/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWObject.h"

@interface SWProjectUser : SWObject

@property (nonatomic, readonly) SWValue *userName;
@property (nonatomic, readonly) SWValue *userP;
@property (nonatomic, readonly) SWValue *userL;

@end
