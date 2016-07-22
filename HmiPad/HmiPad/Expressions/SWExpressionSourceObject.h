//
//  SWExpressionSourceObject.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ValueHolder;

@protocol SWExpressionSourceObject <NSObject>

@required
- (NSString*)fullReference;
- (NSString*)symbol;
- (NSString*)property;
- (id<ValueHolder>)holder;

@end
