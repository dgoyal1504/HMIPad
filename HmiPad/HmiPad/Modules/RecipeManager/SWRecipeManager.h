//
//  SWRecipeManager.h
//  HmiPad
//
//  Created by Joan Lluch on 31/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWRecipeManagerKeys.h"


@interface SWRecipeManager : NSObject

// Get the default context calling this method.
+ (SWRecipeManager*)defaultManager;

// Set an external serial dispatch queue just after initialization to handle all the asynchronous operations,
// the queue must have a context data already set with the dispatch_queue_set_specific, you must provide the key.
- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key;

// This method finds or creates a new NSDictionary based on the recipeSheet file path
// and returns it as the parameter of the completion block.
// The completion block may be executed asynchronously
- (void)getRecipeSheetAtPath:(NSString*)path completionBlock:(void (^)(NSDictionary* sheetInfo))completionBlock;

@end
