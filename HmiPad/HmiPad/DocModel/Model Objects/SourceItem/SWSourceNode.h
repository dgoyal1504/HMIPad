//
//  SWSourceNode.h
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "QuickCoder.h"
#import "SymbolicCoder.h"
#import "SWValueProtocols.h"

@class SWSourceItem;
@class SWPlcTag;
@class SWReadExpression;

@interface SWSourceNode : NSObject <ValueHolder, QuickCoding, SymbolicCoding>

@property (nonatomic,weak,readonly) SWSourceItem *sourceItem;
@property (nonatomic,retain) NSString *name;  
@property (nonatomic,retain) SWPlcTag *plcTag;
@property (nonatomic,retain) SWReadExpression *readExpression;
@property (nonatomic,retain) SWExpression *writeExpression;
@property (nonatomic,assign) CFAbsoluteTime timeStamp;
@property (nonatomic,assign) UInt8 tagErrNum;

-(id)initWithSourceItem:(SWSourceItem*)sourceItem;

//- (BOOL)resultIsInvalid;
- (NSString *)tagErrorString;

//@property (nonatomic, readonly) int commRetainCount;
//- (SWSourceNode*)commRetain;
//- (void)commRelease;

- (BOOL)matchesSearchWithString:(NSString*)searchString;

@end
