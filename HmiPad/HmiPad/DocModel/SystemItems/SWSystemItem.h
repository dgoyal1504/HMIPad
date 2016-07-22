//
//  SWSystemItem.h
//  HmiPad
//
//  Created by Joan on 01/09/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObject.h"

@class SWSystemTable;

@interface SWSystemItem : SWObject

//- (id)initForAddingToSystemTable:(SWSystemTable*)systemTable;

- (void)addToSystemTable:(SWSystemTable*)systemTable;

@end
