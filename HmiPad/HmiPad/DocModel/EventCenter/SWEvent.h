//
//  SWEvent.h
//  HmiPad
//
//  Created by Joan Martin on 8/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "QuickCoder.h"
//#import "SymbolicCoder.h"

#import "SWEventHolder.h"

@interface SWEvent : NSObject //<QuickCoding,SymbolicCoding>

@property (nonatomic, readonly, weak) id<SWEventHolder> holder;

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL acknowledged;
@property (nonatomic, readonly) CFAbsoluteTime timeStamp;
@property (nonatomic, readonly) NSString *labelText;
@property (nonatomic, readonly) NSString *commentText;

- (id)initWithHolder:(id<SWEventHolder>)holder;
- (id)initWithLabel:(NSString*)labelText comment:(NSString*)commentText;
- (id)initWithLabel:(NSString*)labelText comment:(NSString*)commentText active:(BOOL)active;
- (id)initWithLabel:(NSString*)labelText comment:(NSString*)commentText active:(BOOL)active timeStamp:(CFAbsoluteTime)timeStamp;
- (NSString *)getTimeStampString;

@end