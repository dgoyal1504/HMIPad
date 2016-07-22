//
//  SWGroupItem.h
//  HmiPad
//
//  Created by Joan Lluch on 18/10/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"
#import "SWGroup.h"

@class SWGroupItem;

@protocol GroupItemObserver<SWItemObserver,SWGroupObserver>
@end

@interface SWGroupItem : SWItem<SWGroup>

- (void)adjustFrameToFitSubItemsForOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom;

@end
